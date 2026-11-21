import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/date_utils.dart';
import '../../models/physiotherapist.dart';
import '../../models/schedule.dart';
import '../../state/app_dependencies.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/pain_level_picker.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/week_picker.dart';

/// Fluxo de agendamento: profissional → horário → detalhes → confirmar.
/// Com [initialPhysio] o profissional já vem escolhido (vindo da busca).
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, this.initialPhysio});

  final Physiotherapist? initialPhysio;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _reason = TextEditingController();
  final DateTime _now = DateTime.now();

  List<Physiotherapist> _physios = [];
  Physiotherapist? _physio;
  List<Schedule> _schedules = [];
  late DateTime _selectedDate = _now;
  int? _scheduleId;
  int? _painLevel;

  bool _loadingPhysios = false;
  bool _loadingSlots = false;
  bool _submitting = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPhysio;
    if (initial != null) _physio = initial;
    // Depois do primeiro frame, para poder usar setState e o AppScope.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (initial != null) {
        _loadSlots(initial, jumpToFirstDay: true);
      } else {
        _loadPhysios();
      }
    });
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _loadPhysios() async {
    final service = AppScope.of(context).physiotherapists;
    setState(() => _loadingPhysios = true);
    try {
      final list = await service.list();
      if (mounted) setState(() => _physios = list);
    } catch (error) {
      if (mounted) setState(() => _error = errorMessage(error));
    } finally {
      if (mounted) setState(() => _loadingPhysios = false);
    }
  }

  Future<void> _selectPhysio(Physiotherapist physio) async {
    setState(() {
      _physio = physio;
      _scheduleId = null;
      _schedules = [];
      _error = '';
    });
    await _loadSlots(physio, jumpToFirstDay: true);
  }

  Future<void> _loadSlots(
    Physiotherapist physio, {
    bool jumpToFirstDay = false,
  }) async {
    final service = AppScope.of(context).schedules;
    setState(() => _loadingSlots = true);
    try {
      final list = await service.available(physio.id);
      if (!mounted || _physio?.id != physio.id) return;
      setState(() {
        _schedules = list;
        if (jumpToFirstDay) {
          final future = _futureSchedules;
          if (future.isNotEmpty) _selectedDate = future.first.dateTime;
        }
      });
    } catch (error) {
      if (mounted) setState(() => _error = errorMessage(error));
    } finally {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  /// Horários ainda no futuro, do mais cedo para o mais tarde.
  List<Schedule> get _futureSchedules {
    final list = _schedules.where((s) => s.dateTime.isAfter(_now)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  List<Schedule> get _daySlots => _futureSchedules
      .where((s) => isSameDay(s.dateTime, _selectedDate))
      .toList();

  Schedule? get _chosen {
    for (final slot in _daySlots) {
      if (slot.id == _scheduleId) return slot;
    }
    return null;
  }

  Future<void> _confirm() async {
    final chosen = _chosen;
    final physio = _physio;
    if (chosen == null || physio == null) return;

    final deps = AppScope.of(context);
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = '';
    });

    try {
      await deps.appointments.create(
        scheduleId: chosen.id,
        reason: _reason.text.trim(),
        painLevel: _painLevel,
      );
      if (!mounted) return;
      deps.home.showAppointments(notice: 'Consulta agendada com sucesso!');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = errorMessage(error));
      // Horário tomado por outro paciente: atualiza a grade.
      if (error is ApiException && error.status == 409) {
        setState(() => _scheduleId = null);
        await _loadSlots(physio);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final physio = _physio;
    final chosen = _chosen;
    final markedKeys =
        _futureSchedules.map((s) => toDateKey(s.dateTime)).toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('Agendar consulta')),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: AppButton(
            label: 'Confirmar agendamento',
            expanded: true,
            loading: _submitting,
            onPressed: chosen == null ? null : _confirm,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('Profissional'),
          const SizedBox(height: 8),
          _buildPhysioSection(),
          if (physio != null) ...[
            const SizedBox(height: 24),
            const _SectionTitle('Escolha um horário'),
            const SizedBox(height: 8),
            WeekPicker(
              selected: _selectedDate,
              minDate: _now,
              markedKeys: markedKeys,
              onSelect: (date) => setState(() {
                _selectedDate = date;
                _scheduleId = null;
              }),
            ),
            const SizedBox(height: 16),
            Text(
              formatLongDate(_selectedDate),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink700,
              ),
            ),
            const SizedBox(height: 8),
            _buildSlots(),
          ],
          if (chosen != null) ...[
            const SizedBox(height: 24),
            LabeledField(
              label: 'Motivo da consulta',
              controller: _reason,
              maxLines: 3,
              maxLength: 500,
              hint: 'Ex.: dor no joelho, avaliação, acompanhamento...',
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            PainLevelPicker(
              value: _painLevel,
              onChanged: (level) => setState(() => _painLevel = level),
            ),
            const SizedBox(height: 16),
            Text(
              '${formatLongDate(chosen.dateTime)} · ${formatDMY(chosen.dateTime)}'
              ' às ${formatTime(chosen.dateTime)} · '
              '${formatCurrency(physio!.sessionPrice)}',
              style: const TextStyle(fontSize: 14, color: AppColors.ink600),
            ),
          ],
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 16),
            FeedbackBanner.error(_error),
          ],
        ],
      ),
    );
  }

  Widget _buildPhysioSection() {
    final initial = widget.initialPhysio;
    if (initial != null) return _PhysioSummary(initial);

    if (_loadingPhysios) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return InputDecorator(
      decoration: const InputDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          isDense: true,
          value: _physio?.id,
          hint: const Text(
            'Selecione um fisioterapeuta',
            style: TextStyle(fontSize: 14, color: AppColors.ink400),
          ),
          items: [
            for (final physio in _physios)
              DropdownMenuItem<int>(
                value: physio.id,
                child: Text(
                  '${physio.name} — ${physio.specialty.name} (${physio.city})',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
          ],
          onChanged: (id) {
            if (id == null) return;
            _selectPhysio(_physios.firstWhere((p) => p.id == id));
          },
        ),
      ),
    );
  }

  Widget _buildSlots() {
    if (_loadingSlots) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final slots = _daySlots;
    if (slots.isEmpty) {
      return const Text(
        'Nenhum horário livre neste dia. Os dias com ponto têm horários.',
        style: TextStyle(fontSize: 14, color: AppColors.ink500),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final slot in slots)
          _SlotButton(
            time: formatTime(slot.dateTime),
            selected: slot.id == _scheduleId,
            onTap: () => setState(() => _scheduleId = slot.id),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.ink900,
      ),
    );
  }
}

class _SlotButton extends StatelessWidget {
  const _SlotButton({
    required this.time,
    required this.selected,
    required this.onTap,
  });

  final String time;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Horário $time',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Container(
          width: 84,
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.brand600 : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(
              color: selected ? AppColors.brand600 : AppColors.inputBorder,
            ),
          ),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.ink700,
            ),
          ),
        ),
      ),
    );
  }
}

class _PhysioSummary extends StatelessWidget {
  const _PhysioSummary(this.physio);

  final Physiotherapist physio;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          UserAvatar(
            name: physio.name,
            url: physio.profile.avatarUrl,
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  physio.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${physio.specialty.name} · ${physio.city}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.ink500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(physio.sessionPrice),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.brand700,
            ),
          ),
        ],
      ),
    );
  }
}
