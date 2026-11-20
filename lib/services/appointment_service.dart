import '../core/network/api_client.dart';
import '../models/appointment.dart';

class AppointmentService {
  AppointmentService(this._api);

  final ApiClient _api;

  /// GET /appointments/me — consultas do paciente logado.
  Future<List<Appointment>> mine() async {
    final json = await _api.get('/appointments/me') as List<dynamic>;
    return json
        .map((item) => Appointment.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// POST /appointments — agenda um horário.
  Future<Appointment> create({
    required int scheduleId,
    String? reason,
    int? painLevel,
  }) async {
    final body = <String, dynamic>{'scheduleId': scheduleId};
    if (reason != null && reason.isNotEmpty) body['reason'] = reason;
    if (painLevel != null) body['painLevel'] = painLevel;

    final json = await _api.post('/appointments', body: body)
        as Map<String, dynamic>;
    return Appointment.fromJson(json);
  }

  /// PATCH /appointments/:id/cancel — o paciente precisa de 24h de antecedência
  /// (a regra é validada pela API, que devolve a mensagem de erro).
  Future<void> cancel(int id, String cancelReason) async {
    await _api.patch(
      '/appointments/$id/cancel',
      body: {'cancelReason': cancelReason},
    );
  }
}
