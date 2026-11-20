import 'dart:convert';

/// Usuário logado, lido do payload do JWT (equivale ao sessionService.ts).
/// Serve só para decidir o que mostrar; a autorização real é do backend.
class SessionUser {
  const SessionUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final int id;
  final String name;
  final String email;
  final String role;

  bool get isPatient => role == 'PATIENT';

  factory SessionUser.fromJson(Map<String, dynamic> json) => SessionUser(
        id: json['sub'] as int,
        name: (json['name'] as String?) ?? '',
        email: (json['email'] as String?) ?? '',
        // Token antigo sem role cai em PATIENT (menor privilégio).
        role: (json['role'] as String?) ?? 'PATIENT',
      );

  /// Decodifica o JWT. Devolve null se estiver malformado ou expirado.
  static SessionUser? fromToken(String token, {DateTime? now}) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;

      final exp = payload['exp'];
      if (exp is num) {
        final expiresAt =
            DateTime.fromMillisecondsSinceEpoch((exp * 1000).toInt());
        if (!expiresAt.isAfter(now ?? DateTime.now())) return null;
      }

      return SessionUser.fromJson(payload);
    } catch (_) {
      return null;
    }
  }
}
