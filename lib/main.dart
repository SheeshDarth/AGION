import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'domain/models/player.dart';
import 'domain/models/workout.dart';
import 'domain/models/water_log.dart';
import 'domain/models/quest_arc.dart';
import 'domain/models/fitness_profile.dart';
import 'data/remote/firebase_auth_helper.dart';
import 'data/remote/firestore_sync_service.dart';
import 'app.dart';

/// Whether Firebase was successfully initialized.
bool firebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
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
  Hive.registerAdapter(PlayerAdapter());       // typeId: 0
  Hive.registerAdapter(WorkoutAdapter());      // typeId: 1
  Hive.registerAdapter(ExerciseAdapter());     // typeId: 2
  Hive.registerAdapter(ExerciseSetAdapter());  // typeId: 3
  Hive.registerAdapter(WaterLogAdapter());     // typeId: 4
  Hive.registerAdapter(WaterEntryAdapter());   // typeId: 5
  Hive.registerAdapter(QuestArcAdapter());     // typeId: 6
  Hive.registerAdapter(ArcPhaseAdapter());     // typeId: 7
  Hive.registerAdapter(ArcExerciseAdapter());  // typeId: 8
  Hive.registerAdapter(BossFightAdapter());    // typeId: 9
  Hive.registerAdapter(ArcProgressAdapter());  // typeId: 10
  Hive.registerAdapter(FitnessProfileAdapter()); // typeId: 11

  // Try initializing Firebase (gracefully fails if not configured)
  try {
    await Firebase.initializeApp();
    await FirebaseAuthHelper.markInitialized();
    FirestoreSyncService.markInitialized();
    firebaseInitialized = true;
  } catch (_) {
    // Firebase not configured — app runs in offline-only mode
    firebaseInitialized = false;
  }

  runApp(
    const ProviderScope(
      child: AgionApp(),
    ),
  );
}
