import '../core/network/api_client.dart';
import '../models/schedule.dart';

class ScheduleService {
  ScheduleService(this._api);

  final ApiClient _api;

  /// GET /schedules?physiotherapistId= — horários livres do fisioterapeuta.
  Future<List<Schedule>> available(int physiotherapistId) async {
    final json = await _api.get(
      '/schedules',
      query: {'physiotherapistId': '$physiotherapistId'},
    ) as List<dynamic>;
    return json
        .map((item) => Schedule.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
