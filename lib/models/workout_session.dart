class WorkoutSession {
  final String id;
  final String userId;
  final String workoutId;
  final DateTime data;
  final int? duracaoMinutos;
  final String? observacoes;
  final int? energiaPerceived;

  WorkoutSession({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.data,
    this.duracaoMinutos,
    this.observacoes,
    this.energiaPerceived,
  });

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      workoutId: map['workout_id'] as String,
      data: DateTime.parse(map['data'] as String),
      duracaoMinutos: map['duracao_minutos'] as int?,
      observacoes: map['observacoes'] as String?,
      energiaPerceived: map['energia_perceived'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'workout_id': workoutId,
      'data': data.toIso8601String(),
      'duracao_minutos': duracaoMinutos,
      'observacoes': observacoes,
      'energia_perceived': energiaPerceived,
    };
  }
}
