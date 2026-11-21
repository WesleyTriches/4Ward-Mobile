import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../models/appointment.dart';
import '../../state/app_dependencies.dart';
import '../../widgets/app_button.dart';
import '../../widgets/empty_box.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/page_header.dart';
import 'appointment_card.dart';
import 'booking_screen.dart';

enum _Tab { upcoming, history }

/// Aba "Consultas": próximas e histórico, com cancelamento e atalho de agendar.
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late final AppDependencies _deps;
  late int _lastRefreshTick;

  List<Appointment> _appointments = [];
  _Tab _tab = _Tab.upcoming;
  bool _loading = true;
  String _error = '';
  String _notice = '';

  @override
  void initState() {
    super.initState();
    _deps = AppScope.of(context);
    _lastRefreshTick = _deps.home.refreshTick;
    _deps.home.addListener(_onHomeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _deps.home.removeListener(_onHomeChanged);
    super.dispose();
  }

  /// Chamado quando outra tela pede para recarregar (ex.: após agendar).
  void _onHomeChanged() {
    final tick = _deps.home.refreshTick;
    if (tick == _lastRefreshTick) return;
    _lastRefreshTick = tick;

    final notice = _deps.home.takeNotice();
    setState(() {
      _tab = _Tab.upcoming;
      _notice = notice ?? '';
    });
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await _deps.appointments.mine();
      if (mounted) {
        setState(() {
          _appointments = list;
          _error = '';
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = errorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Appointment> get _upcoming => _appointments
      .where((a) => a.status == AppointmentStatus.scheduled)
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<Appointment> get _history => _appointments
      .where((a) => a.status != AppointmentStatus.scheduled)
      .toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  Future<void> _openBooking() async {
    setState(() => _notice = '');
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BookingScreen()),
    );
  }

  void _handleCancelled() {
    setState(() => _notice = 'Consulta cancelada.');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _upcoming;
    final history = _history;
    final visible = _tab == _Tab.upcoming ? upcoming : history;
    final now = DateTime.now();

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() => _notice = '');
          await _load();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const PageHeader(
              title: 'Minhas consultas',
              subtitle: 'Acompanhe seus agendamentos e histórico.',
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Agendar consulta',
              icon: Icons.add,
              expanded: true,
              onPressed: _openBooking,
            ),
            if (_notice.isNotEmpty) ...[
              const SizedBox(height: 16),
              FeedbackBanner.success(_notice),
            ],
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 16),
              FeedbackBanner.error(_error),
            ],
            const SizedBox(height: 16),
            _Tabs(
              tab: _tab,
              upcomingCount: upcoming.length,
              historyCount: history.length,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.brand600),
                ),
              )
            else if (visible.isEmpty)
              EmptyBox(
                _tab == _Tab.upcoming
                    ? 'Você não tem consultas agendadas.'
                    : 'Nenhuma consulta no histórico.',
              )
            else
              for (final appointment in visible) ...[
                AppointmentCard(
                  key: ValueKey(appointment.id),
                  appointment: appointment,
                  canCancel:
                      appointment.status == AppointmentStatus.scheduled &&
                          appointment.dateTime.isAfter(now),
                  onCancelled: _handleCancelled,
                ),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}

/// Abas "Próximas (n)" e "Histórico (n)".
class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.tab,
    required this.upcomingCount,
    required this.historyCount,
    required this.onChanged,
  });

  final _Tab tab;
  final int upcomingCount;
  final int historyCount;
  final ValueChanged<_Tab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Próximas ($upcomingCount)',
              active: tab == _Tab.upcoming,
              onTap: () => onChanged(_Tab.upcoming),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Histórico ($historyCount)',
              active: tab == _Tab.history,
              onTap: () => onChanged(_Tab.history),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.brand600 : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.brand700 : AppColors.ink500,
            ),
          ),
        ),
      ),
    );
  }
}
