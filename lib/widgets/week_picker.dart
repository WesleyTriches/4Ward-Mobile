import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_utils.dart';

/// Seletor de semana (segunda a domingo). Dias com horário livre ganham um
/// ponto; dias antes de [minDate] ficam desabilitados.
class WeekPicker extends StatefulWidget {
  const WeekPicker({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.markedKeys,
    required this.minDate,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  /// Datas (toDateKey) que têm horário livre.
  final Set<String> markedKeys;
  final DateTime minDate;

  @override
  State<WeekPicker> createState() => _WeekPickerState();
}

class _WeekPickerState extends State<WeekPicker> {
  late DateTime _weekStart = startOfWeek(widget.selected);

  @override
  void didUpdateWidget(WeekPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se a data escolhida mudou por fora (ex.: primeiro dia com horário),
    // mostra a semana dela.
    if (!isSameDay(oldWidget.selected, widget.selected)) {
      _weekStart = startOfWeek(widget.selected);
    }
  }

  void _moveWeek(int weeks) {
    setState(() => _weekStart = addDays(_weekStart, weeks * 7));
  }

  @override
  Widget build(BuildContext context) {
    final days = weekDays(_weekStart);
    final min = startOfDay(widget.minDate);
    final canGoBack = startOfWeek(min).isBefore(_weekStart);
    final today = startOfDay(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Semana anterior',
                onPressed: canGoBack ? () => _moveWeek(-1) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  formatMonthYear(days[3]),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Próxima semana',
                onPressed: () => _moveWeek(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final day in days)
                Expanded(
                  child: _DayCell(
                    day: day,
                    selected: isSameDay(day, widget.selected),
                    isToday: isSameDay(day, today),
                    marked: widget.markedKeys.contains(toDateKey(day)),
                    enabled: !day.isBefore(min),
                    onTap: () => widget.onSelect(day),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.marked,
    required this.enabled,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final bool isToday;
  final bool marked;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    if (selected) {
      textColor = Colors.white;
    } else if (!enabled) {
      textColor = AppColors.ink400;
    } else {
      textColor = AppColors.ink900;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Semantics(
        button: true,
        selected: selected,
        enabled: enabled,
        label: formatLongDate(day),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.brand600 : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: isToday && !selected
                  ? Border.all(color: AppColors.brand500)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  weekdaysShort[day.weekday - 1],
                  style: TextStyle(
                    fontSize: 11,
                    color: selected ? Colors.white : AppColors.ink500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: marked
                        ? (selected ? Colors.white : AppColors.brand500)
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
