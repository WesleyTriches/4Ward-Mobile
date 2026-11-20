import 'physiotherapist.dart';
import 'profile.dart';
import 'schedule.dart';

/// Status da consulta (enum AppointmentStatus do Prisma).
enum AppointmentStatus {
  scheduled('SCHEDULED', 'Agendada'),
  completed('COMPLETED', 'Realizada'),
  cancelled('CANCELLED', 'Cancelada'),
  noShow('NO_SHOW', 'Faltou');

  const AppointmentStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static AppointmentStatus fromApi(String? value) {
    return AppointmentStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => AppointmentStatus.scheduled,
    );
  }
}

class Appointment {
  const Appointment({
    required this.id,
    required this.status,
    required this.price,
    required this.schedule,
    required this.physiotherapist,
    this.reason,
    this.painLevel,
    this.cancelReason,
    this.patient,
  });

  final int id;
  final AppointmentStatus status;
  final double price;
  final String? reason;
  final int? painLevel;
  final String? cancelReason;
  final Schedule schedule;
  final Physiotherapist physiotherapist;
  final Profile? patient;

  DateTime get dateTime => schedule.dateTime;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'];
    return Appointment(
      id: json['id'] as int,
      status: AppointmentStatus.fromApi(json['status'] as String?),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      reason: json['reason'] as String?,
      painLevel: (json['painLevel'] as num?)?.toInt(),
      cancelReason: json['cancelReason'] as String?,
      schedule: Schedule.fromJson(json['schedule'] as Map<String, dynamic>),
      physiotherapist: Physiotherapist.fromJson(
        json['physiotherapist'] as Map<String, dynamic>,
      ),
      patient: patient is Map<String, dynamic> ? Profile.fromJson(patient) : null,
    );
  }
}
