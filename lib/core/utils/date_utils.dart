/// Datas em português, sem depender do pacote intl (equivale ao lib/date.ts).
const weekdaysShort = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

const weekdaysLong = [
  'Segunda-feira',
  'Terça-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sábado',
  'Domingo',
];

const months = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

String _pad(int value) => value.toString().padLeft(2, '0');

/// 13.10.2026 (mesmo formato usado no web)
String formatDMY(DateTime date) =>
    '${_pad(date.day)}.${_pad(date.month)}.${date.year}';

/// 13/10/2026
String formatBR(DateTime date) =>
    '${_pad(date.day)}/${_pad(date.month)}/${date.year}';

/// "2026-10-13" -> 13/10/2026
String formatIsoDateBR(String isoDate) {
  final parts = isoDate.split('-');
  if (parts.length != 3) return isoDate;
  return '${parts[2]}/${parts[1]}/${parts[0]}';
}

/// 10:00
String formatTime(DateTime date) => '${_pad(date.hour)}:${_pad(date.minute)}';

/// 2026-10-13 (data local; serve de chave e de parâmetro `date`)
String toDateKey(DateTime date) =>
    '${date.year}-${_pad(date.month)}-${_pad(date.day)}';

/// Terça-feira, 13 de outubro (weekday: 1 = segunda ... 7 = domingo)
String formatLongDate(DateTime date) =>
    '${weekdaysLong[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';

/// Outubro 2026
String formatMonthYear(DateTime date) {
  final month = months[date.month - 1];
  return '${month[0].toUpperCase()}${month.substring(1)} ${date.year}';
}

DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

/// Soma dias sem se perder em mudança de horário de verão.
DateTime addDays(DateTime date, int amount) =>
    DateTime(date.year, date.month, date.day + amount);

/// Segunda-feira da semana de [date].
DateTime startOfWeek(DateTime date) =>
    startOfDay(addDays(date, -(date.weekday - 1)));

/// Segunda a domingo.
List<DateTime> weekDays(DateTime date) {
  final start = startOfWeek(date);
  return List.generate(7, (index) => addDays(start, index));
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
