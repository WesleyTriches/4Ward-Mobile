/// Validações simples dos formulários de acesso.
abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Informe seu e-mail.';
    if (!_email.hasMatch(text)) return 'E-mail inválido.';
    return null;
  }

  static String? required(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }
}
