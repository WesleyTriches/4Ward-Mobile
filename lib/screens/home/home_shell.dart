import 'package:flutter/material.dart';

import '../../state/app_dependencies.dart';

/// Provisória: será substituída pela navegação por abas.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context).auth;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Olá, ${auth.user?.name ?? ''}'),
            TextButton(onPressed: auth.logout, child: const Text('Sair')),
          ],
        ),
      ),
    );
  }
}
