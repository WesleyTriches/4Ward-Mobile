/// Perfil pessoal (GET/PUT /profiles/me).
class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    this.phone,
    this.birthDate,
    this.avatarUrl,
  });

  final int id;
  final String fullName;
  final String? phone;

  /// "AAAA-MM-DD". A API devolve ISO; guardamos só a data, como o web faz
  /// (slice(0, 10)), para o fuso não mudar o dia.
  final String? birthDate;
  final String? avatarUrl;

  factory Profile.fromJson(Map<String, dynamic> json) {
    final birth = json['birthDate'] as String?;
    return Profile(
      id: json['id'] as int,
      fullName: (json['fullName'] as String?) ?? '',
      phone: json['phone'] as String?,
      birthDate: (birth != null && birth.length >= 10)
          ? birth.substring(0, 10)
          : null,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
