import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency.dart';
import '../../models/physiotherapist.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/user_avatar.dart';

/// Resumo de um fisioterapeuta na lista de busca.
class PhysioCard extends StatelessWidget {
  const PhysioCard({
    super.key,
    required this.physio,
    required this.onOpen,
    required this.onBook,
  });

  final Physiotherapist physio;
  final VoidCallback onOpen;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(
                name: physio.name,
                url: physio.profile.avatarUrl,
                size: 52,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      physio.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      physio.specialty.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.brand700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${physio.city} · ${physio.serviceMode.label}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.ink500,
                      ),
                    ),
                  ],
                ),
              ),
              if (physio.rating != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: AppColors.warning500,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      physio.rating!.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: formatCurrency(physio.sessionPrice),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    children: const [
                      TextSpan(
                        text: ' / sessão',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.ink500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppButton(label: 'Agendar', onPressed: onBook),
            ],
          ),
        ],
      ),
    );
  }
}
