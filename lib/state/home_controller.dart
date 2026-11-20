import 'package:flutter/foundation.dart';

/// Índices das abas da tela principal.
abstract final class HomeTab {
  static const physios = 0;
  static const appointments = 1;
  static const profile = 2;
}

/// Estado da navegação principal: aba atual e aviso a mostrar em "Consultas"
/// (por exemplo, depois de agendar por uma tela empilhada).
class HomeController extends ChangeNotifier {
  int _tab = HomeTab.appointments;
  String? _notice;
  int _refreshTick = 0;

  int get tab => _tab;

  /// Aumenta toda vez que a lista de consultas precisa ser recarregada.
  int get refreshTick => _refreshTick;

  void selectTab(int index) {
    if (index == _tab) return;
    _tab = index;
    notifyListeners();
  }

  /// Vai para "Consultas", recarrega a lista e guarda o aviso de sucesso.
  void showAppointments({String? notice}) {
    _tab = HomeTab.appointments;
    _notice = notice;
    _refreshTick++;
    notifyListeners();
  }

  /// Entrega o aviso uma única vez.
  String? takeNotice() {
    final notice = _notice;
    _notice = null;
    return notice;
  }

  void reset() {
    _tab = HomeTab.appointments;
    _notice = null;
  }
}
