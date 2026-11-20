import 'package:flutter/foundation.dart';

/// Endereço da API NestJS.
///
/// Em dispositivo físico (ou outro host) informe o endereço da sua máquina:
///   flutter run --dart-define=API_URL=http://192.168.0.10:3000/api
abstract final class ApiConfig {
  static const String _fromEnv = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_fromEnv.isNotEmpty) return _fromEnv;
    // No emulador Android, "localhost" é o próprio emulador; 10.0.2.2 é o PC.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  static const Duration timeout = Duration(seconds: 15);
}
