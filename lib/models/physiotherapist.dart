import 'profile.dart';
import 'service_mode.dart';
import 'specialty.dart';

class Physiotherapist {
  const Physiotherapist({
    required this.id,
    required this.crefito,
    required this.sessionPrice,
    required this.city,
    required this.serviceMode,
    required this.experienceYears,
    required this.profile,
    required this.specialty,
    this.bio,
    this.rating,
  });

  final int id;
  final String crefito;
  final String? bio;
  final double sessionPrice;
  final String city;
  final ServiceMode serviceMode;
  final int experienceYears;
  final double? rating;
  final Profile profile;
  final Specialty specialty;

  String get name => profile.fullName;

  factory Physiotherapist.fromJson(Map<String, dynamic> json) {
    return Physiotherapist(
      id: json['id'] as int,
      crefito: (json['crefito'] as String?) ?? '',
      bio: json['bio'] as String?,
      sessionPrice: (json['sessionPrice'] as num?)?.toDouble() ?? 0,
      city: (json['city'] as String?) ?? '',
      serviceMode: ServiceMode.fromApi(json['serviceMode'] as String?),
      experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
      specialty: Specialty.fromJson(json['specialty'] as Map<String, dynamic>),
    );
  }
}
