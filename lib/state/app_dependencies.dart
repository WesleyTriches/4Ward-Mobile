import 'package:flutter/widgets.dart';

import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../services/physiotherapist_service.dart';
import '../services/profile_service.dart';
import '../services/schedule_service.dart';
import '../services/specialty_service.dart';
import 'auth_controller.dart';
import 'home_controller.dart';

/// Tudo o que as telas precisam, criado uma vez em main.
class AppDependencies {
  AppDependencies._({
    required this.auth,
    required this.home,
    required this.physiotherapists,
    required this.specialties,
    required this.schedules,
    required this.appointments,
    required this.profiles,
  });

  factory AppDependencies.create() {
    final tokenStorage = TokenStorage();
    final api = ApiClient(tokenStorage: tokenStorage);

    final auth = AuthController(
      authService: AuthService(api),
      tokenStorage: tokenStorage,
    );
    api.onUnauthorized = auth.handleUnauthorized;

    return AppDependencies._(
      auth: auth,
      home: HomeController(),
      physiotherapists: PhysiotherapistService(api),
      specialties: SpecialtyService(api),
      schedules: ScheduleService(api),
      appointments: AppointmentService(api),
      profiles: ProfileService(api),
    );
  }

  final AuthController auth;
  final HomeController home;
  final PhysiotherapistService physiotherapists;
  final SpecialtyService specialties;
  final ScheduleService schedules;
  final AppointmentService appointments;
  final ProfileService profiles;
}

/// Disponibiliza as dependências para a árvore de widgets.
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.deps, required super.child});

  final AppDependencies deps;

  static AppDependencies of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado acima na árvore.');
    return scope!.deps;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => deps != oldWidget.deps;
}
