import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/appointment.dart';

/// Selo de status da consulta, com as mesmas cores do web.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      AppointmentStatus.scheduled => (AppColors.brand50, AppColors.brand700),
      AppointmentStatus.completed => (AppColors.success50, AppColors.success700),
      AppointmentStatus.cancelled => (AppColors.danger50, AppColors.danger700),
      AppointmentStatus.noShow => (AppColors.warning50, AppColors.warning700),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}
