import 'package:flutter_test/flutter_test.dart';
import 'package:fourward_mobile/core/utils/currency.dart';
import 'package:fourward_mobile/core/utils/date_utils.dart';

void main() {
  test('formata datas e horas', () {
    final date = DateTime(2026, 10, 13, 9, 5);
    expect(formatDMY(date), '13.10.2026');
    expect(formatBR(date), '13/10/2026');
    expect(formatTime(date), '09:05');
    expect(toDateKey(date), '2026-10-13');
    expect(formatLongDate(date), 'Terça-feira, 13 de outubro');
    expect(formatMonthYear(date), 'Outubro 2026');
    expect(formatIsoDateBR('1990-05-10'), '10/05/1990');
  });

  test('semana começa na segunda e termina no domingo', () {
    // 13/10/2026 é terça-feira
    final days = weekDays(DateTime(2026, 10, 13));
    expect(days.length, 7);
    expect(days.first, DateTime(2026, 10, 12));
    expect(days.last, DateTime(2026, 10, 18));
    expect(isSameDay(days[1], DateTime(2026, 10, 13, 23)), isTrue);
  });

  test('formata reais', () {
    expect(formatCurrency(150), 'R\$ 150,00');
    expect(formatCurrency(1234.5), 'R\$ 1.234,50');
  });
}
