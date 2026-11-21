import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency.dart';
import '../../models/physiotherapist.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/fact.dart';
import '../../widgets/user_avatar.dart';
import '../appointments/booking_screen.dart';

/// Perfil profissional de um fisioterapeuta, com atalho para agendar.
class PhysioDetailScreen extends StatelessWidget {
  const PhysioDetailScreen({super.key, required this.physio});

  final Physiotherapist physio;

  String get _experience {
    final years = physio.experienceYears;
    if (years <= 0) return 'Menos de 1 ano';
    return years == 1 ? '1 ano' : '$years anos';
  }

  void _book(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingScreen(initialPhysio: physio),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bio = physio.bio?.trim() ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Fisioterapeuta')),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: AppButton(
            label: 'Agendar consulta',
            icon: Icons.calendar_month_outlined,
            expanded: true,
            onPressed: () => _book(context),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Row(
              children: [
                UserAvatar(
                  name: physio.name,
                  url: physio.profile.avatarUrl,
                  size: 64,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        physio.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        physio.specialty.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.brand700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'CREFITO ${physio.crefito}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.ink500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Wrap(
              runSpacing: 16,
              children: [
                _half(Fact(label: 'Cidade', value: physio.city)),
                _half(
                  Fact(label: 'Atendimento', value: physio.serviceMode.label),
                ),
                _half(Fact(label: 'Experiência', value: _experience)),
                _half(
                  Fact(
                    label: 'Valor da sessão',
                    value: formatCurrency(physio.sessionPrice),
                  ),
                ),
                _half(
                  Fact(
                    label: 'Avaliação',
                    value: physio.rating == null
                        ? 'Sem avaliações'
                        : '${physio.rating!.toStringAsFixed(1)} de 5',
                  ),
                ),
              ],
            ),
          ),
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sobre',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.ink600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Metade da largura do cartão (duas colunas de fatos).
  Widget _half(Widget child) => FractionallySizedBox(
        widthFactor: 0.5,
        child: child,
      );
}
