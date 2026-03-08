import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'water_log.g.dart';

@HiveType(typeId: 4)
class WaterLog extends Equatable {
  @HiveField(0)
  final String date; // YYYY-MM-DD string for easy keying

  @HiveField(1)
  final int consumed; // ml consumed today

  @HiveField(2)
  final int target; // daily goal in ml

  @HiveField(3)
  final List<WaterEntry> entries;

  const WaterLog({
    required this.date,
    this.consumed = 0,
    this.target = 3000,
    this.entries = const [],
  });

  double get progress => target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0;

  bool get goalReached => consumed >= target;

  WaterLog addWater(int ml) {
    final now = DateTime.now();
    final newEntries = [...entries, WaterEntry(amount: ml, time: now)];
    return copyWith(
      consumed: consumed + ml,
      entries: newEntries,
    );
  }

  WaterLog copyWith({
    String? date,
    int? consumed,
    int? target,
    List<WaterEntry>? entries,
  }) {
    return WaterLog(
      date: date ?? this.date,
      consumed: consumed ?? this.consumed,
      target: target ?? this.target,
      entries: entries ?? this.entries,
    );
  }

  factory WaterLog.today({int target = 3000}) {
    final now = DateTime.now();
    return WaterLog(
      date: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      target: target,
    );
  }

  @override
  List<Object?> get props => [date, consumed, target, entries];
}

@HiveType(typeId: 5)
class WaterEntry extends Equatable {
  @HiveField(0)
  final int amount; // ml

  @HiveField(1)
  final DateTime time;

  const WaterEntry({
    required this.amount,
    required this.time,
  });

  @override
  List<Object?> get props => [amount, time];
}
