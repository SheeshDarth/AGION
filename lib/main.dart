import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/device_tier.dart';
import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Status bar styling — transparent, light icons
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF030810),
  ));

  // Device tier detection (low/mid/high) — non-fatal
  try {
    await DeviceTier.init();
  } catch (e) {
    debugPrint('DeviceTier init error (non-fatal): $e');
  }

  // Hive local storage
  try {
    await Hive.initFlutter();
    HiveService.registerAdapters();
    await HiveService.openBoxes();
  } catch (e) {
    debugPrint('Hive init error (non-fatal): $e');
    // Continue without local data — app will function in empty state
  }

  // Notifications — NEVER let this crash the app
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('NotificationService init error (non-fatal): $e');
  }

  runApp(const ProviderScope(child: AgionApp()));
}
