import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../state/app_dependencies.dart';
import '../../widgets/app_button.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/labeled_field.dart';
import 'auth_layout.dart';
import 'register_screen.dart';
import 'validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _showPassword = false;
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
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
      // Em caso de sucesso o AuthController troca esta tela pela principal.
      await auth.login(_email.text.trim(), _password.text);
    } catch (error) {
      if (mounted) setState(() => _error = errorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Bem-vindo de volta',
      subtitle: 'Acesse sua conta para continuar.',
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Ainda não tem uma conta?',
            style: TextStyle(fontSize: 14, color: AppColors.ink500),
          ),
          TextButton(
            onPressed: _loading
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const RegisterScreen(),
                      ),
                    ),
            child: const Text('Cadastre-se'),
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
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submit(),
                validator: (value) =>
                    Validators.required(value, 'Informe sua senha.'),
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
                label: 'Entrar',
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
