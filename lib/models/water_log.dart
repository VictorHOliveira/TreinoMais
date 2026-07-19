class WaterLog {
  final String id;
  final String userId;
  final DateTime data;
  final int quantidadeMl;
  final DateTime createdAt;

  WaterLog({
    required this.id,
    required this.userId,
    required this.data,
    this.quantidadeMl = 200,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory WaterLog.fromMap(Map<String, dynamic> map) {
    return WaterLog(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      data: DateTime.parse(map['data'] as String),
      quantidadeMl: map['quantidade_ml'] as int? ?? 200,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'data': data.toIso8601String().substring(0, 10),
      'quantidade_ml': quantidadeMl,
    };
  }
}
