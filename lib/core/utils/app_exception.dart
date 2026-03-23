class AppException implements Exception {
  final int statusCode;
  final String errorCode;
  final String message;
  final Map<String, List<String>>? errors;

  AppException({
    required this.statusCode,
    required this.errorCode,
    required this.message,
    this.errors,
  });

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      StringBuffer buffer = StringBuffer();
      errors!.forEach((fieldName, errorList) {
        for (String error in errorList) {
          buffer.writeln('  - $error');
        }
      });
      return buffer.toString().trim();
    }

    return message;
  }
}

