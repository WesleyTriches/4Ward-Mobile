/// Erro devolvido pela API (ou falha de conexão, com [status] 0).
class ApiException implements Exception {
  const ApiException(this.status, this.message);

  final int status;
  final String message;

  bool get isConnection => status == 0;

  @override
  String toString() => message;
}

/// Mensagem amigável para qualquer erro capturado numa tela.
String errorMessage(Object error) {
  if (error is ApiException) return error.message;
  return 'Ocorreu um erro inesperado. Tente novamente.';
}
