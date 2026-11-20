import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fourward_mobile/models/appointment.dart';
import 'package:fourward_mobile/models/session_user.dart';

String _jwt(Map<String, dynamic> payload) {
  String enc(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${enc({'alg': 'HS256'})}.${enc(payload)}.assinatura';
}

void main() {
  group('SessionUser', () {
    test('lê o payload do token', () {
      final user = SessionUser.fromToken(_jwt({
        'sub': 7,
        'email': 'ana@x.com',
        'name': 'Ana',
        'role': 'PATIENT',
      }));
      expect(user?.id, 7);
      expect(user?.name, 'Ana');
      expect(user?.isPatient, isTrue);
    });

    test('token expirado ou inválido vira null', () {
      final expired = _jwt({
        'sub': 1,
        'exp': DateTime(2020).millisecondsSinceEpoch ~/ 1000,
      });
      expect(SessionUser.fromToken(expired), isNull);
      expect(SessionUser.fromToken('lixo'), isNull);
    });
  });

  test('Appointment.fromJson lê o formato de GET /appointments/me', () {
    final appointment = Appointment.fromJson({
      'id': 1,
      'status': 'CANCELLED',
      'price': 150,
      'reason': 'Dor no joelho',
      'painLevel': 4,
      'cancelReason': 'Imprevisto',
      'schedule': {
        'id': 3,
        'physiotherapistId': 2,
        'dateTime': '2026-10-13T13:00:00.000Z',
        'available': true,
      },
      'patient': {'id': 9, 'fullName': 'Ana', 'birthDate': '1990-05-10T00:00:00.000Z'},
      'physiotherapist': {
        'id': 2,
        'crefito': '123-F',
        'sessionPrice': 150,
        'city': 'Passo Fundo',
        'serviceMode': 'BOTH',
        'experienceYears': 5,
        'rating': null,
        'profile': {'id': 5, 'fullName': 'Dr. João'},
        'specialty': {'id': 1, 'name': 'Ortopedia'},
      },
    });

    expect(appointment.status, AppointmentStatus.cancelled);
    expect(appointment.price, 150.0);
    expect(appointment.physiotherapist.name, 'Dr. João');
    expect(appointment.physiotherapist.serviceMode.label, 'Presencial e online');
    expect(appointment.patient?.birthDate, '1990-05-10');
    expect(appointment.schedule.dateTime.toUtc().hour, 13);
  });
}
