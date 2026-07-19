class ExerciseSet {
  final String id;
  final String sessionId;
  final int exerciseId;
  final int setNumero;
  final double? pesoKg;
  final int? reps;
  final double? rpe;
  final bool falhou;

  ExerciseSet({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setNumero,
    this.pesoKg,
    this.reps,
    this.rpe,
    this.falhou = false,
  });

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      id: map['id'] as String,
      sessionId: map['session_id'] as String,
      exerciseId: map['exercise_id'] as int,
      setNumero: map['set_numero'] as int,
      pesoKg: (map['peso_kg'] as num?)?.toDouble(),
      reps: map['reps'] as int?,
      rpe: (map['rpe'] as num?)?.toDouble(),
      falhou: map['falhou'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'exercise_id': exerciseId,
      'set_numero': setNumero,
      'peso_kg': pesoKg,
      'reps': reps,
      'rpe': rpe,
      'falhou': falhou,
    };
  }

  double? get volume => pesoKg != null && reps != null ? pesoKg! * reps! : null;

  double? get estimated1Rm {
    if (pesoKg == null || reps == null || reps! < 1) return null;
    return pesoKg! * (1 + reps! / 30.0);
  }
}
