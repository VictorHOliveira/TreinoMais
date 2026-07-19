class Exercise {
  final int id;
  final String nome;
  final String descricao;
  final String musculoPrincipal;
  final List<String> musculosSecundarios;
  final String? equipamento;
  final String? imagemUrl;
  final String? videoUrl;
  final String categoria;
  final bool isFavorito;

  Exercise({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.musculoPrincipal,
    this.musculosSecundarios = const [],
    this.equipamento,
    this.imagemUrl,
    this.videoUrl,
    required this.categoria,
    this.isFavorito = false,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int,
      nome: map['nome'] as String,
      descricao: map['descricao'] as String? ?? '',
      musculoPrincipal: map['musculo_principal'] as String,
      musculosSecundarios: (map['musculos_secundarios'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      equipamento: map['equipamento'] as String?,
      imagemUrl: map['imagem_url'] as String?,
      videoUrl: map['video_url'] as String?,
      categoria: map['categoria'] as String? ?? '',
      isFavorito: map['is_favorito'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'musculo_principal': musculoPrincipal,
      'musculos_secundarios': musculosSecundarios,
      'equipamento': equipamento,
      'imagem_url': imagemUrl,
      'video_url': videoUrl,
      'categoria': categoria,
    };
  }

  Exercise copyWith({bool? isFavorito}) {
    return Exercise(
      id: id,
      nome: nome,
      descricao: descricao,
      musculoPrincipal: musculoPrincipal,
      musculosSecundarios: musculosSecundarios,
      equipamento: equipamento,
      imagemUrl: imagemUrl,
      videoUrl: videoUrl,
      categoria: categoria,
      isFavorito: isFavorito ?? this.isFavorito,
    );
  }
}
