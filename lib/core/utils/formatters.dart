import 'package:intl/intl.dart';

class Formatters {
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('HH:mm');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _monthFormat = DateFormat('MMM yyyy');

  static String date(DateTime? date) {
    if (date == null) return '';
    return _dateFormat.format(date);
  }

  static String time(DateTime? date) {
    if (date == null) return '';
    return _timeFormat.format(date);
  }

  static String dateTime(DateTime? date) {
    if (date == null) return '';
    return _dateTimeFormat.format(date);
  }

  static String monthYear(DateTime? date) {
    if (date == null) return '';
    return _monthFormat.format(date);
  }

  static String weight(double? kg) {
    if (kg == null) return '--';
    return '${kg.toStringAsFixed(1)} kg';
  }

  static String percent(double? value) {
    if (value == null) return '--';
    return '${value.toStringAsFixed(1)}%';
  }

  static String duration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) return '${h}h ${m}min';
    return '${m}min';
  }

  static String distance(double? km) {
    if (km == null) return '--';
    if (km < 1) return '${(km * 1000).toStringAsFixed(0)} m';
    return '${km.toStringAsFixed(2)} km';
  }

  static String calories(int? cal) {
    if (cal == null) return '--';
    return '$cal cal';
  }

  static String water(int ml) {
    if (ml >= 1000) return '${(ml / 1000).toStringAsFixed(1)}L';
    return '${ml}ml';
  }
}
