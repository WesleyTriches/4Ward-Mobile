import '../core/network/api_client.dart';
import '../models/specialty.dart';

class SpecialtyService {
  SpecialtyService(this._api);

  final ApiClient _api;

  /// GET /specialties — usada no filtro de busca.
  Future<List<Specialty>> list() async {
    final json = await _api.get('/specialties') as List<dynamic>;
    return json
        .map((item) => Specialty.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
