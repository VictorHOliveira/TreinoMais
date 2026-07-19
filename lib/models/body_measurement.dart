class BodyMeasurement {
  final String id;
  final String userId;
  final double pesoKg;
  final double? gorduraPercent;
  final double? massaMuscularKg;
  final double? circunferenciaCintura;
  final DateTime data;
  final String? observacao;

  BodyMeasurement({
    required this.id,
    required this.userId,
    required this.pesoKg,
    this.gorduraPercent,
    this.massaMuscularKg,
    this.circunferenciaCintura,
    required this.data,
    this.observacao,
  });

  factory BodyMeasurement.fromMap(Map<String, dynamic> map) {
    return BodyMeasurement(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      pesoKg: (map['peso_kg'] as num).toDouble(),
      gorduraPercent: (map['gordura_percent'] as num?)?.toDouble(),
      massaMuscularKg: (map['massa_muscular_kg'] as num?)?.toDouble(),
      circunferenciaCintura: (map['circunferencia_cintura'] as num?)?.toDouble(),
      data: DateTime.parse(map['data'] as String),
      observacao: map['observacao'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'peso_kg': pesoKg,
      'gordura_percent': gorduraPercent,
      'massa_muscular_kg': massaMuscularKg,
      'circunferencia_cintura': circunferenciaCintura,
      'data': data.toIso8601String().substring(0, 10),
      'observacao': observacao,
    };
  }
}
