import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../widgets/brand_logo.dart';

/// Mostrada enquanto o token guardado é verificado.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandLogo(size: 40),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.brand600),
          ],
        ),
      ),
    );
  }
}
