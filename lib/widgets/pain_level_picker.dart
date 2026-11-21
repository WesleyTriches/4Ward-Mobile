import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Escala de dor de 0 a 10. Tocar de novo no nível escolhido desmarca.
class PainLevelPicker extends StatelessWidget {
  const PainLevelPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            text: 'Nível de dor ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink700,
            ),
            children: [
              TextSpan(
                text: '(opcional)',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: AppColors.ink500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var level = 0; level <= 10; level++)
              _PainButton(
                level: level,
                selected: value == level,
                onTap: () => onChanged(value == level ? null : level),
              ),
          ],
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sem dor',
              style: TextStyle(fontSize: 12, color: AppColors.ink500),
            ),
            Text(
              'Dor intensa',
              style: TextStyle(fontSize: 12, color: AppColors.ink500),
            ),
          ],
        ),
      ],
    );
  }
}

class _PainButton extends StatelessWidget {
  const _PainButton({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  final int level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Nível de dor $level',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.brand600 : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(
              color: selected ? AppColors.brand600 : AppColors.line,
            ),
          ),
          child: Text(
            '$level',
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? Colors.white : AppColors.ink700,
            ),
          ),
        ),
      ),
    );
  }
}
