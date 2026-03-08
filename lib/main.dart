import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'domain/models/player.dart';
import 'domain/models/workout.dart';
import 'domain/models/water_log.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode for mobile-first UX
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF020513),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize Hive + register all type adapters
  await Hive.initFlutter();
  Hive.registerAdapter(PlayerAdapter());     // typeId: 0
  Hive.registerAdapter(WorkoutAdapter());    // typeId: 1
  Hive.registerAdapter(ExerciseAdapter());   // typeId: 2
  Hive.registerAdapter(ExerciseSetAdapter()); // typeId: 3
  Hive.registerAdapter(WaterLogAdapter());   // typeId: 4
  Hive.registerAdapter(WaterEntryAdapter()); // typeId: 5

  runApp(
    const ProviderScope(
      child: AgionApp(),
    ),
  );
}
