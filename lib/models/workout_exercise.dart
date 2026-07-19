class WorkoutExercise {
  final String id;
  final String workoutId;
  final int exerciseId;
  final int ordem;
  final int? seriesPadrao;
  final int? repsPadrao;
  final int? descansoSegundos;

  WorkoutExercise({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.ordem,
    this.seriesPadrao,
    this.repsPadrao,
    this.descansoSegundos,
  });

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      id: map['id'] as String,
      workoutId: map['workout_id'] as String,
      exerciseId: map['exercise_id'] as int,
      ordem: map['ordem'] as int,
      seriesPadrao: map['series_padrao'] as int?,
      repsPadrao: map['reps_padrao'] as int?,
      descansoSegundos: map['descanso_segundos'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'ordem': ordem,
      'series_padrao': seriesPadrao,
      'reps_padrao': repsPadrao,
      'descanso_segundos': descansoSegundos,
    };
  }
}
