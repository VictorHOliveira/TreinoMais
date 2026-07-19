import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/constants.dart';
import '../models/exercise.dart';

class WgerApiService {
  static final WgerApiService _instance = WgerApiService._();
  factory WgerApiService() => _instance;
  WgerApiService._();

  final _client = http.Client();
  int? _totalCount;

  Future<List<Exercise>> fetchExercises({int page = 1, String? muscle}) async {
    final params = {
      'limit': AppConstants.wgerPageSize.toString(),
      'offset': ((page - 1) * AppConstants.wgerPageSize).toString(),
      'language': '2',
      if (muscle != null) 'muscles': muscle,
    };

    final uri = Uri.parse('${AppConstants.wgerBaseUrl}/exerciseinfo/')
        .replace(queryParameters: params);

    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch exercises: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    _totalCount = data['count'] as int?;

    final results = data['results'] as List<dynamic>;
    final exercises = <Exercise>[];

    for (final item in results) {
      final exercise = _parseExercise(item as Map<String, dynamic>);
      if (exercise != null) exercises.add(exercise);
    }

    return exercises;
  }

  Exercise? _parseExercise(Map<String, dynamic> json) {
    final id = json['id'] as int?;
    final name = json['name'] as String?;
    if (id == null || name == null) return null;

    final description = _cleanHtml(json['description'] as String? ?? '');
    final muscles = (json['muscles'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [];
    final musclesSecondary = (json['muscles_secondary'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        [];

    final equipment = (json['equipment'] as List<dynamic>?)
            ?.map((e) => _getEquipmentName(e as int))
            .join(', ') ??
        '';

    String? imageUrl;
    final images = json['images'] as List<dynamic>?;
    if (images != null && images.isNotEmpty) {
      imageUrl = (images.first as Map<String, dynamic>)['image'] as String?;
    }

    String? videoUrl;
    final videos = json['videos'] as List<dynamic>?;
    if (videos != null && videos.isNotEmpty) {
      videoUrl = (videos.first as Map<String, dynamic>)['video'] as String?;
    }

    final category = json['category'] as Map<String, dynamic>?;
    final categoryName = category?['name'] as String? ?? '';

    return Exercise(
      id: id,
      nome: name,
      descricao: description,
      musculoPrincipal: _getMuscleName(muscles.isNotEmpty ? muscles.first : 0),
      musculosSecundarios: musclesSecondary.map((e) => _getMuscleName(e)).toList(),
      equipamento: equipment,
      imagemUrl: imageUrl,
      videoUrl: videoUrl,
      categoria: categoryName,
    );
  }

  String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  String _getMuscleName(int id) {
    const muscles = {
      1: 'Peito', 2: 'Costas', 3: 'Ombros', 4: 'Bíceps',
      5: 'Tríceps', 6: 'Abdômen', 7: 'Quadríceps', 8: 'Posterior',
      9: 'Glúteos', 10: 'Panturrilha', 11: 'Antebraço', 12: 'Trapézio',
      13: 'Adutores', 14: 'Serrátil',
    };
    return muscles[id] ?? 'Outro';
  }

  String _getEquipmentName(int id) {
    const equipment = {
      1: 'Barra', 2: 'Halteres', 3: 'Máquina', 4: 'Cabo',
      5: 'Kettlebell', 6: 'Bola', 7: 'Elástico', 8: 'Peso corporal',
      9: 'Banco', 10: 'Poleiro',
    };
    return equipment[id] ?? 'Outro';
  }

  Future<String?> getImageUrl(int exerciseId) async {
    final uri = Uri.parse('${AppConstants.wgerBaseUrl}/exerciseimage/?exercise=$exerciseId');
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) return null;

    final data = json.decode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) return null;

    final image = (results.first as Map<String, dynamic>)['image'] as String?;
    return image;
  }

  int? get totalCount => _totalCount;
}
