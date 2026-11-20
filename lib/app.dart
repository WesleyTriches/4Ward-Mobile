import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_shell.dart';
import 'screens/splash_screen.dart';
import 'state/app_dependencies.dart';
import 'state/auth_controller.dart';

class FourWardApp extends StatefulWidget {
  const FourWardApp({super.key});

  @override
  State<FourWardApp> createState() => _FourWardAppState();
}

class _FourWardAppState extends State<FourWardApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AppDependencies _deps;
  AuthStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    _deps = AppDependencies.create();
    _deps.auth.addListener(_onAuthChanged);
    _deps.auth.restore();
  }

  @override
  void dispose() {
    _deps.auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  /// Ao entrar ou sair, fecha qualquer tela empilhada (cadastro, agendamento,
  /// detalhe...) para a raiz mostrar login ou área logada.
  void _onAuthChanged() {
    final status = _deps.auth.status;
    if (status == _lastStatus) return;
    _lastStatus = status;

    if (status == AuthStatus.unauthenticated) _deps.home.reset();
    if (status != AuthStatus.unknown) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      deps: _deps,
      child: MaterialApp(
        title: '4Ward',
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: ListenableBuilder(
          listenable: _deps.auth,
          builder: (context, _) {
            return switch (_deps.auth.status) {
              AuthStatus.unknown => const SplashScreen(),
              AuthStatus.unauthenticated => const LoginScreen(),
              AuthStatus.authenticated => const HomeShell(),
            };
          },
        ),
      ),
    );
  }
}
