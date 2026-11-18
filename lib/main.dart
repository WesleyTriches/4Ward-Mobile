import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const FourWardApp());
}

class FourWardApp extends StatelessWidget {
  const FourWardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '4Ward',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Scaffold(body: Center(child: Text('4Ward'))),
    );
  }
}
