import '../core/network/api_client.dart';
import '../models/profile.dart';

class ProfileService {
  ProfileService(this._api);

  final ApiClient _api;

  /// GET /profiles/me
  Future<Profile> me() async {
    final json = await _api.get('/profiles/me') as Map<String, dynamic>;
    return Profile.fromJson(json);
  }

  /// PUT /profiles/me — só os campos enviados são alterados.
  Future<Profile> update({
    String? fullName,
    String? birthDate,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (birthDate != null) body['birthDate'] = birthDate;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

    final json = await _api.put('/profiles/me', body: body)
        as Map<String, dynamic>;
    return Profile.fromJson(json);
  }
}
