class AppConstants {
  static const String appName = 'FitTrack';
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String wgerBaseUrl = 'https://wger.de/api/v2';
  static const int wgerPageSize = 50;
  static const double defaultWaterMl = 200;
  static const int defaultWaterGoal = 8;
  static const int waterReminderIntervalMinutes = 60;
}

class MuscleGroups {
  static const List<String> all = [
    'Peito', 'Costas', 'Ombros', 'Bíceps', 'Tríceps', 'Perna',
    'Quadríceps', 'Posterior', 'Glúteos', 'Panturrilha', 'Abdômen',
    'Antebraço', 'Trapézio', 'Cardio',
  ];
}

class CardioTypes {
  static const List<String> all = [
    'Corrida', 'Bike', 'Elíptico', 'Escada', 'Natação',
    'Corda', 'Remo', 'Jump', 'Caminhada', 'Outro',
  ];
}
