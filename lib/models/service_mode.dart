/// Modalidade de atendimento (enum ServiceMode do Prisma).
enum ServiceMode {
  inPerson('IN_PERSON', 'Presencial'),
  online('ONLINE', 'Online'),
  both('BOTH', 'Presencial e online');

  const ServiceMode(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static ServiceMode fromApi(String? value) {
    return ServiceMode.values.firstWhere(
      (mode) => mode.apiValue == value,
      orElse: () => ServiceMode.inPerson,
    );
  }
}
