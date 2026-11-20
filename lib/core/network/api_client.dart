import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Cliente HTTP autenticado com JWT Bearer (equivale ao apiClient.ts do web).
///
/// - 401 em rota autenticada: limpa o token e chama [onUnauthorized].
/// - Resposta de erro: lança [ApiException] com a mensagem do Nest.
class ApiClient {
  ApiClient({required TokenStorage tokenStorage, http.Client? client})
      : _tokenStorage = tokenStorage,
        _http = client ?? http.Client();

  final TokenStorage _tokenStorage;
  final http.Client _http;

  /// Chamado quando a sessão expira (o AuthController faz o logout).
  void Function()? onUnauthorized;

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      _send('POST', path, body: body, auth: auth);

  Future<dynamic> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);

  Future<dynamic> patch(String path, {Object? body}) =>
      _send('PATCH', path, body: body);

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
  }) async {
    var uri = Uri.parse('${ApiConfig.baseUrl}$path');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: query);
    }

    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';

    if (auth) {
      final token = await _tokenStorage.read();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }

    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    http.Response response;
    try {
      final streamed = await _http.send(request).timeout(ApiConfig.timeout);
      response = await http.Response.fromStream(streamed);
    } catch (_) {
      throw const ApiException(0, 'Não foi possível conectar ao servidor.');
    }

    final decoded = _decode(response);

    if (response.statusCode == 401 && auth) {
      await _tokenStorage.clear();
      onUnauthorized?.call();
      throw ApiException(401, _extractMessage(decoded, 'Sessão expirada.'));
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        response.statusCode,
        _extractMessage(
          decoded,
          'Erro ${response.statusCode} ao chamar a API.',
        ),
      );
    }

    return decoded;
  }

  dynamic _decode(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      return null;
    }
  }

  String _extractMessage(dynamic body, String fallback) {
    if (body is Map && body['message'] != null) {
      final message = body['message'];
      // O ValidationPipe do Nest devolve uma lista de mensagens.
      if (message is List) return message.join(' · ');
      if (message is String) return message;
    }
    return fallback;
  }
}
