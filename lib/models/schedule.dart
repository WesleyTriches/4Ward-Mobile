/// Horário publicado pelo fisioterapeuta (GET /schedules?physiotherapistId=).
class Schedule {
  const Schedule({
    required this.id,
    required this.physiotherapistId,
    required this.dateTime,
    required this.available,
  });

  final int id;
  final int physiotherapistId;

  /// Já convertido para o fuso do aparelho.
  final DateTime dateTime;
  final bool available;

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        id: json['id'] as int,
        physiotherapistId: json['physiotherapistId'] as int,
        dateTime: DateTime.parse(json['dateTime'] as String).toLocal(),
        available: (json['available'] as bool?) ?? true,
      );
}
