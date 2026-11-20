import '../core/network/api_client.dart';
import '../models/physiotherapist.dart';
import '../models/service_mode.dart';

class PhysiotherapistService {
  PhysiotherapistService(this._api);

  final ApiClient _api;

  /// GET /physiotherapists com os filtros da busca.
  Future<List<Physiotherapist>> list({
    String? city,
    int? specialtyId,
    ServiceMode? serviceMode,
  }) async {
    final query = <String, String>{};
    if (city != null && city.trim().isNotEmpty) query['city'] = city.trim();
    if (specialtyId != null) query['specialtyId'] = '$specialtyId';
    if (serviceMode != null) query['serviceMode'] = serviceMode.apiValue;

    final json = await _api.get('/physiotherapists', query: query)
        as List<dynamic>;
    return json
        .map((item) => Physiotherapist.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
