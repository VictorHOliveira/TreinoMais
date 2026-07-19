import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/constants.dart';
import 'supabase_service.dart';

class ExerciseSyncService {
  final SupabaseService _supabase;
  final http.Client _client = http.Client();

  ExerciseSyncService(this._supabase);

  Future<SyncResult> syncAll() async {
    int total = 0;
    int imported = 0;
    int skipped = 0;
    String? next = '${AppConstants.wgerBaseUrl}/exerciseinfo/?limit=50&language=2';

    while (next != null) {
      final uri = Uri.parse(next);
      final response = await _client.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        return SyncResult(
          total: total,
          imported: imported,
          skipped: skipped,
          error: 'Erro HTTP ${response.statusCode}',
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      final exercises = <Map<String, dynamic>>[];

      for (final item in results) {
        total++;
        final parsed = _parseItem(item as Map<String, dynamic>);
        if (parsed != null) {
          exercises.add(parsed);
          imported++;
        } else {
          skipped++;
        }
      }

      if (exercises.isNotEmpty) {
        await _supabase.cacheExercises(exercises);
      }

      next = data['next'] as String?;
    }

    return SyncResult(total: total, imported: imported, skipped: skipped);
  }

  Map<String, dynamic>? _parseItem(Map<String, dynamic> json) {
    final id = json['id'] as int?;
    final name = json['name'] as String?;
    if (id == null || name == null) return null;

    final description = _cleanHtml(json['description'] as String? ?? '');

    final muscles = (json['muscles'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        [];

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

    final category = json['category'] as Map<String, dynamic>?;
    final categoryName = category?['name'] as String? ?? '';

    return {
      'id': id,
      'nome': name,
      'descricao': description,
      'musculo_principal': _getMuscleName(muscles.isNotEmpty ? muscles.first : 0),
      'musculos_secundarios':
          musclesSecondary.map((e) => _getMuscleName(e)).toList(),
      'equipamento': equipment,
      'imagem_url': imageUrl,
      'categoria': categoryName,
    };
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

  void dispose() {
    _client.close();
  }
}

class SyncResult {
  final int total;
  final int imported;
  final int skipped;
  final String? error;

  SyncResult({
    required this.total,
    required this.imported,
    required this.skipped,
    this.error,
  });

  bool get isSuccess => error == null;
}
