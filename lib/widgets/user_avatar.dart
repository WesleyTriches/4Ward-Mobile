import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Foto do usuário (URL) ou, na falta dela, a inicial do nome.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.url, this.size = 48});

  final String name;
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    final fallback = Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: AppColors.brand700,
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.brand100,
      ),
      clipBehavior: Clip.antiAlias,
      child: (url == null || url!.isEmpty)
          ? fallback
          : Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            ),
    );
  }
}
