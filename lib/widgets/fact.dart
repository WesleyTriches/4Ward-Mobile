import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Rótulo pequeno em cima e valor embaixo (o `dt` / `dd` do web).
class Fact extends StatelessWidget {
  const Fact({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.ink500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ],
    );
  }
}
