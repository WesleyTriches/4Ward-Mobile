import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../state/app_dependencies.dart';
import '../../widgets/app_button.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/labeled_field.dart';
import 'auth_layout.dart';
import 'validators.dart';

/// Cadastro de paciente (o fisioterapeuta se cadastra pelo web).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _showPassword = false;
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = AppScope.of(context).auth;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      // Em caso de sucesso o AuthController leva para a tela principal.
      await auth.register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
    } catch (error) {
      if (mounted) setState(() => _error = errorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Crie sua conta',
      subtitle: 'Cadastre-se para começar a usar o 4Ward.',
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Já tem uma conta?',
            style: TextStyle(fontSize: 14, color: AppColors.ink500),
          ),
          TextButton(
            onPressed: _loading ? null : () => Navigator.of(context).pop(),
            child: const Text('Entrar'),
          ),
        ],
      ),
      children: [
        if (_error.isNotEmpty) ...[
          FeedbackBanner.error(_error),
          const SizedBox(height: 16),
        ],
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LabeledField(
                label: 'Nome',
                controller: _name,
                hint: 'Seu nome',
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.length < 3 || text.length > 100) {
                    return 'O nome deve ter entre 3 e 100 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'E-mail',
                controller: _email,
                hint: 'seu@email.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Senha',
                controller: _password,
                hint: '••••••••',
                obscureText: !_showPassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) => _submit(),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres.';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  tooltip: _showPassword ? 'Ocultar senha' : 'Mostrar senha',
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.ink500,
                  ),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Criar conta',
                loading: _loading,
                expanded: true,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
