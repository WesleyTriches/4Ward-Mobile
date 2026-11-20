import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

enum BannerKind { success, error }

/// Faixa de aviso (o `.notice` verde e o `.alert` vermelho do web).
class FeedbackBanner extends StatelessWidget {
  const FeedbackBanner.success(this.message, {super.key})
      : kind = BannerKind.success;

  const FeedbackBanner.error(this.message, {super.key})
      : kind = BannerKind.error;

  final String message;
  final BannerKind kind;

  @override
  Widget build(BuildContext context) {
    final success = kind == BannerKind.success;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: success ? AppColors.success50 : AppColors.danger50,
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: success ? AppColors.success700 : AppColors.danger700,
          ),
        ),
      ),
    );
  }
}
