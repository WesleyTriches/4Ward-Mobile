/// 150 -> "R$ 150,00" | 1234.5 -> "R$ 1.234,50"
String formatCurrency(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final integer = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return 'R\$ $integer,${parts[1]}';
}
