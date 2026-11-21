import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../models/profile.dart';
import '../../state/app_dependencies.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/page_header.dart';
import '../../widgets/user_avatar.dart';

/// Aba "Meu perfil": dados pessoais (GET/PUT /profiles/me) e sair da conta.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _birthDate = TextEditingController();
  final _avatarUrl = TextEditingController();

  /// "AAAA-MM-DD", o formato que a API espera.
  String? _birthIso;

  bool _loading = true;
  bool _saving = false;
  String _error = '';
  String _notice = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _fullName.dispose();
    _birthDate.dispose();
    _avatarUrl.dispose();
    super.dispose();
  }

  void _fill(Profile profile) {
    _fullName.text = profile.fullName;
    _avatarUrl.text = profile.avatarUrl ?? '';
    _birthIso = profile.birthDate;
    _birthDate.text =
        profile.birthDate == null ? '' : formatIsoDateBR(profile.birthDate!);
  }

  Future<void> _load() async {
    final service = AppScope.of(context).profiles;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final profile = await service.me();
      if (mounted) setState(() => _fill(profile));
    } catch (error) {
      if (mounted) setState(() => _error = errorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final current = _birthIso == null ? null : DateTime.tryParse(_birthIso!);

    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(now.year - 30, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Data de nascimento',
    );
    if (picked == null) return;

    setState(() {
      _birthIso = toDateKey(picked);
      _birthDate.text = formatBR(picked);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final service = AppScope.of(context).profiles;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = '';
      _notice = '';
    });

    try {
      final avatar = _avatarUrl.text.trim();
      final updated = await service.update(
        fullName: _fullName.text.trim(),
        birthDate: _birthIso,
        avatarUrl: avatar.isEmpty ? null : avatar,
      );
      if (mounted) {
        setState(() {
          _fill(updated);
          _notice = 'Perfil atualizado com sucesso!';
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = errorMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmLogout() async {
    final auth = AppScope.of(context).auth;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você precisará entrar novamente para continuar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger600),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed == true) await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = AppScope.of(context).auth.user;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const PageHeader(title: 'Meu perfil', subtitle: 'Seus dados pessoais.'),
            if (_notice.isNotEmpty) ...[
              const SizedBox(height: 16),
              FeedbackBanner.success(_notice),
            ],
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 16),
              FeedbackBanner.error(_error),
            ],
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.brand600),
                ),
              )
            else
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          UserAvatar(
                            name: _fullName.text.isEmpty
                                ? (user?.name ?? '')
                                : _fullName.text,
                            url: _avatarUrl.text.trim(),
                            size: 56,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fullName.text.isEmpty
                                      ? (user?.name ?? '')
                                      : _fullName.text,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (user != null)
                                  Text(
                                    user.email,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.ink500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      LabeledField(
                        label: 'Nome completo',
                        controller: _fullName,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.length < 2 || text.length > 120) {
                            return 'O nome deve ter entre 2 e 120 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      LabeledField(
                        label: 'Data de nascimento',
                        controller: _birthDate,
                        hint: 'dd/mm/aaaa',
                        readOnly: true,
                        onTap: _pickBirthDate,
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: AppColors.ink500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LabeledField(
                        label: 'URL da foto',
                        controller: _avatarUrl,
                        hint: 'https://...',
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        maxLength: 500,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Link de uma imagem já publicada na internet.',
                        style: TextStyle(fontSize: 12, color: AppColors.ink500),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'Salvar alterações',
                        expanded: true,
                        loading: _saving,
                        onPressed: _save,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Sair da conta',
              icon: Icons.logout,
              variant: AppButtonVariant.ghost,
              expanded: true,
              onPressed: _confirmLogout,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
