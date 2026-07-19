class CardioSession {
  final String id;
  final String userId;
  final DateTime data;
  final String tipo;
  final int duracaoMinutos;
  final double? distanciaKm;
  final int? calorias;
  final int? frequenciaCardiacaMedia;
  final int? percepcaoEsforco;
  final String? observacao;

  CardioSession({
    required this.id,
    required this.userId,
    required this.data,
    required this.tipo,
    required this.duracaoMinutos,
    this.distanciaKm,
    this.calorias,
    this.frequenciaCardiacaMedia,
    this.percepcaoEsforco,
    this.observacao,
  });

  factory CardioSession.fromMap(Map<String, dynamic> map) {
    return CardioSession(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      data: DateTime.parse(map['data'] as String),
      tipo: map['tipo'] as String,
      duracaoMinutos: map['duracao_minutos'] as int,
      distanciaKm: (map['distancia_km'] as num?)?.toDouble(),
      calorias: map['calorias'] as int?,
      frequenciaCardiacaMedia: map['frequencia_cardiaca_media'] as int?,
      percepcaoEsforco: map['percecao_esforco'] as int?,
      observacao: map['observacao'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'data': data.toIso8601String(),
      'tipo': tipo,
      'duracao_minutos': duracaoMinutos,
      'distancia_km': distanciaKm,
      'calorias': calorias,
      'frequencia_cardiaca_media': frequenciaCardiacaMedia,
      'percecao_esforco': percepcaoEsforco,
      'observacao': observacao,
    };
  }
}
