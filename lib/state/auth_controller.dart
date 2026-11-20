import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/storage/token_storage.dart';
import '../models/session_user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

/// Sessão do usuário: restaura o token ao abrir o app, faz login, cadastro e
/// logout. O app é exclusivo do paciente (profissionais usam o web).
class AuthController extends ChangeNotifier {
  AuthController({required this.authService, required this.tokenStorage});

  final AuthService authService;
  final TokenStorage tokenStorage;

  AuthStatus _status = AuthStatus.unknown;
  SessionUser? _user;

  AuthStatus get status => _status;
  SessionUser? get user => _user;

  /// Lê o token guardado; token ausente, expirado ou de fisio = deslogado.
  Future<void> restore() async {
    final token = await tokenStorage.read();
    final user = token == null ? null : SessionUser.fromToken(token);

    if (user == null || !user.isPatient) {
      await tokenStorage.clear();
      _set(AuthStatus.unauthenticated, null);
      return;
    }
    _set(AuthStatus.authenticated, user);
  }

  Future<void> login(String email, String password) async {
    final result = await authService.login(email, password);
    await _startSession(result.token);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await authService.register(
      name: name,
      email: email,
      password: password,
    );
    await _startSession(result.token);
  }

  Future<void> logout() async {
    await tokenStorage.clear();
    _set(AuthStatus.unauthenticated, null);
  }

  /// Chamado pelo ApiClient num 401 (o token já foi apagado por ele).
  void handleUnauthorized() {
    if (_status == AuthStatus.unauthenticated) return;
    _set(AuthStatus.unauthenticated, null);
  }

  Future<void> _startSession(String token) async {
    final user = SessionUser.fromToken(token);
    if (user == null) {
      throw const ApiException(500, 'Resposta inválida do servidor.');
    }
    if (!user.isPatient) {
      throw const ApiException(
        403,
        'Este app é exclusivo para pacientes. '
        'Profissionais devem acessar pela versão web.',
      );
    }
    await tokenStorage.save(token);
    _set(AuthStatus.authenticated, user);
  }

  void _set(AuthStatus status, SessionUser? user) {
    _status = status;
    _user = user;
    notifyListeners();
  }
}
