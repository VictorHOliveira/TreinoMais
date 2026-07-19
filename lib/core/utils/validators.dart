class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email obrigatório';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Email inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Senha obrigatória';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? required(String? value, [String field = 'Campo']) {
    if (value == null || value.trim().isEmpty) return '$field obrigatório';
    return null;
  }

  static String? number(String? value, [String field = 'Valor']) {
    if (value == null || value.trim().isEmpty) return '$field obrigatório';
    if (double.tryParse(value.replaceAll(',', '.')) == null) {
      return '$field inválido';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String field = 'Valor']) {
    final error = number(value, field);
    if (error != null) return error;
    final num = double.parse(value!.replaceAll(',', '.'));
    if (num <= 0) return '$field deve ser positivo';
    return null;
  }
}
