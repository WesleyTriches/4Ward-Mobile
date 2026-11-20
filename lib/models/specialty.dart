class Specialty {
  const Specialty({
    required this.id,
    required this.name,
    this.description,
    this.icon,
  });

  final int id;
  final String name;
  final String? description;
  final String? icon;

  factory Specialty.fromJson(Map<String, dynamic> json) => Specialty(
        id: json['id'] as int,
        name: (json['name'] as String?) ?? '',
        description: json['description'] as String?,
        icon: json['icon'] as String?,
      );
}
