/// Recursive key-style converter for JSON maps and nested lists.
///
/// The backend emits camelCase keys; the legacy Flutter models still consume
/// snake_case. We translate at the transport boundary so neither side has to
/// move.
abstract final class CaseConverter {
  CaseConverter._();

  /// Recursively rewrites every map key from camelCase to snake_case.
  static dynamic toSnakeCase(dynamic value) {
    if (value is Map) {
      final out = <String, dynamic>{};
      value.forEach((key, v) {
        out[_camelToSnake(key.toString())] = toSnakeCase(v);
      });
      return out;
    }
    if (value is List) {
      return value.map(toSnakeCase).toList();
    }
    return value;
  }

  /// Recursively rewrites every map key from snake_case to camelCase.
  static dynamic toCamelCase(dynamic value) {
    if (value is Map) {
      final out = <String, dynamic>{};
      value.forEach((key, v) {
        out[_snakeToCamel(key.toString())] = toCamelCase(v);
      });
      return out;
    }
    if (value is List) {
      return value.map(toCamelCase).toList();
    }
    return value;
  }

  static String _camelToSnake(String input) {
    if (input.isEmpty) return input;
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      final code = ch.codeUnitAt(0);
      final isUpper = code >= 0x41 && code <= 0x5A; // A-Z
      if (isUpper && i > 0) {
        buffer.write('_');
      }
      buffer.write(isUpper ? ch.toLowerCase() : ch);
    }
    return buffer.toString();
  }

  static String _snakeToCamel(String input) {
    if (!input.contains('_')) return input;
    final parts = input.split('_');
    final buffer = StringBuffer(parts.first);
    for (int i = 1; i < parts.length; i++) {
      final p = parts[i];
      if (p.isEmpty) continue;
      buffer.write(p[0].toUpperCase());
      if (p.length > 1) buffer.write(p.substring(1));
    }
    return buffer.toString();
  }
}
