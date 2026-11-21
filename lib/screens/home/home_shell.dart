import 'package:flutter/material.dart';

import '../../state/app_dependencies.dart';
import '../appointments/appointments_screen.dart';
import '../physios/physios_screen.dart';
import '../profile/profile_screen.dart';

/// Área logada: três abas na barra inferior, como o menu lateral do web
/// (sem as telas exclusivas do fisioterapeuta).
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final home = AppScope.of(context).home;

    return ListenableBuilder(
      listenable: home,
      builder: (context, _) {
        return Scaffold(
          // IndexedStack mantém cada aba viva (busca, formulário e lista
          // não são perdidos ao trocar de aba).
          body: IndexedStack(
            index: home.tab,
            children: const [
              PhysiosScreen(),
              AppointmentsScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: home.tab,
            onDestinationSelected: home.selectTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Fisioterapeutas',
              ),
              NavigationDestination(
                icon: Icon(Icons.event_available_outlined),
                selectedIcon: Icon(Icons.event_available),
                label: 'Consultas',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }
}
