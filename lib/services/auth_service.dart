import '../core/network/api_client.dart';

/// Resposta de POST /auth/login e /auth/register.
class AuthResult {
  const AuthResult({required this.token, required this.role});

  final String token;
  final String role;
}

class AuthService {
  AuthService(this._api);

  final ApiClient _api;

  Future<AuthResult> login(String email, String password) async {
    final json = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      auth: false,
    ) as Map<String, dynamic>;
    return _parse(json);
  }

  /// O app é só do paciente: o cadastro sempre envia role PATIENT.
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final json = await _api.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': 'PATIENT',
      },
      auth: false,
    ) as Map<String, dynamic>;
    return _parse(json);
  }

  AuthResult _parse(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return AuthResult(
      token: json['access_token'] as String,
      role: (user?['role'] as String?) ?? 'PATIENT',
    );
  }
}
