import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Título e subtítulo no topo de cada tela (`.title` e `.subtitle` do web).
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: AppColors.ink900,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(fontSize: 14, color: AppColors.ink500),
          ),
        ],
      ],
    );
  }
}
