class UserProfile {
  final String id;
  final String email;
  final String? nome;
  final double? alturaCm;
  final DateTime? dataNascimento;
  final String? fotoUrl;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    this.nome,
    this.alturaCm,
    this.dataNascimento,
    this.fotoUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      nome: map['nome'] as String?,
      alturaCm: (map['altura_cm'] as num?)?.toDouble(),
      dataNascimento: map['data_nascimento'] != null
          ? DateTime.tryParse(map['data_nascimento'] as String)
          : null,
      fotoUrl: map['foto_url'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (nome != null) 'nome': nome,
      if (alturaCm != null) 'altura_cm': alturaCm,
      if (dataNascimento != null) 'data_nascimento': dataNascimento!.toIso8601String(),
      if (fotoUrl != null) 'foto_url': fotoUrl,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? nome,
    double? alturaCm,
    DateTime? dataNascimento,
    String? fotoUrl,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      alturaCm: alturaCm ?? this.alturaCm,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
