import 'package:hive/hive.dart';
import '../../domain/models/water_log.dart';

/// Local data source for water tracking using Hive.
class WaterLocalSource {
  static const String _boxName = 'water_box';

  late Box<WaterLog> _box;

  Future<void> init() async {
    _box = await Hive.openBox<WaterLog>(_boxName);
  }

  /// Get water log for a specific date (YYYY-MM-DD key).
  WaterLog? getForDate(String dateKey) {
    return _box.get(dateKey);
  }

  /// Save water log keyed by date.
  Future<void> save(WaterLog log) async {
    await _box.put(log.date, log);
  }

  /// Get today's log or create a new one.
  WaterLog getOrCreateToday({int target = 3000}) {
    final today = _todayKey();
    final existing = _box.get(today);
    if (existing != null) return existing;
    return WaterLog.today(target: target);
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
