class Workout {
  final String id;
  final String userId;
  final String nome;
  final String? descricao;
  final int? diaSemana;
  final DateTime createdAt;

  Workout({
    required this.id,
    required this.userId,
    required this.nome,
    this.descricao,
    this.diaSemana,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      nome: map['nome'] as String,
      descricao: map['descricao'] as String?,
      diaSemana: map['dia_semana'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'nome': nome,
      'descricao': descricao,
      'dia_semana': diaSemana,
    };
  }

  String get diaSemanaLabel {
    if (diaSemana == null) return 'Livre';
    const dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
    return dias[diaSemana! - 1];
  }
}
