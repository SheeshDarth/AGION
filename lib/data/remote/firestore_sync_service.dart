import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/player.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/water_log.dart';

/// Firestore cloud sync service — offline-first, sync when connected.
/// All methods are no-ops if Firestore is unavailable.
class FirestoreSyncService {
  static FirebaseFirestore? _firestore;
  static bool _initialized = false;

  static void markInitialized() {
    _initialized = true;
    _firestore = FirebaseFirestore.instance;
    // Enable offline persistence
    _firestore!.settings = const Settings(persistenceEnabled: true);
  }

  static bool get isAvailable => _initialized && _firestore != null;

  // ─── PLAYER SYNC ────────────────────────────────────────────────────

  static Future<void> syncPlayer(String uid, Player player) async {
    if (!isAvailable || uid == 'guest') return;
    try {
      await _firestore!.collection('users').doc(uid).set({
        'level': player.level,
        'xp': player.xp,
        'rank': player.rank,
        'title': player.title,
        'streak': player.streak,
        'dailyWaterTarget': player.dailyWaterTarget,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Silently fail — data is safe in Hive
    }
  }

  static Future<Player?> fetchPlayer(String uid) async {
    if (!isAvailable || uid == 'guest') return null;
    try {
      final doc = await _firestore!.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      final d = doc.data()!;
      return Player(
        uid: uid,
        level: d['level'] as int? ?? 1,
        xp: d['xp'] as int? ?? 0,
        rank: d['rank'] as String? ?? 'E',
        title: d['title'] as String? ?? 'Awakened',
        streak: d['streak'] as int? ?? 0,
        dailyWaterTarget: d['dailyWaterTarget'] as int? ?? 3000,
        lastActive: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  // ─── WORKOUT SYNC ──────────────────────────────────────────────────

  static Future<void> syncWorkout(String uid, Workout workout) async {
    if (!isAvailable || uid == 'guest') return;
    try {
      await _firestore!
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .doc(workout.id)
          .set({
        'date': Timestamp.fromDate(workout.date),
        'duration': workout.duration,
        'notes': workout.notes,
        'exercises': workout.exercises
            .map((e) => {
                  'name': e.name,
                  'sets': e.sets
                      .map((s) => {
                            'reps': s.reps,
                            'weight': s.weight,
                          })
                      .toList(),
                })
            .toList(),
        'createdAt': Timestamp.fromDate(workout.createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Offline — will sync when connected
    }
  }

  static Future<void> deleteWorkoutRemote(String uid, String workoutId) async {
    if (!isAvailable || uid == 'guest') return;
    try {
      await _firestore!
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .doc(workoutId)
          .delete();
    } catch (_) {}
  }

  // ─── WATER SYNC ────────────────────────────────────────────────────

  static Future<void> syncWaterLog(String uid, WaterLog log) async {
    if (!isAvailable || uid == 'guest') return;
    try {
      await _firestore!
          .collection('users')
          .doc(uid)
          .collection('water')
          .doc(log.date)
          .set({
        'consumed': log.consumed,
        'target': log.target,
        'entries': log.entries
            .map((e) => {
                  'amount': e.amount,
                  'time': Timestamp.fromDate(e.time),
                })
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}
