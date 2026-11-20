import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Logotipo em texto, como no web.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      '4Ward',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: AppColors.brand600,
      ),
    );
  }
}
