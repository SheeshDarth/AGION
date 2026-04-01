import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AI Guide Voice Service — speaks coaching tips out loud via TTS.
/// Falls back to silent mode if TTS is not available.
class AiGuideVoice {
  AiGuideVoice._();
  static final AiGuideVoice _instance = AiGuideVoice._();
  static AiGuideVoice get instance => _instance;

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _enabled = true;
  bool _speaking = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.85); // Slightly slower = more authoritative
      await _tts.setVolume(1.0);
      await _tts.setPitch(0.9); // Slightly lower pitch = AI feel
      _tts.setCompletionHandler(() => _speaking = false);
      _tts.setErrorHandler((msg) {
        _speaking = false;
        debugPrint('[AiGuide] TTS error: $msg');
      });
    } catch (e) {
      debugPrint('[AiGuide] TTS init failed: $e');
    }
  }

  bool get enabled => _enabled;
  bool get isSpeaking => _speaking;

  void setEnabled(bool value) => _enabled = value;

  /// Speak a system message (coaching tip, level-up announcement, etc.)
  Future<void> speak(String text) async {
    if (!_enabled) return;
    try {
      if (_speaking) await _tts.stop();
      _speaking = true;
      await _tts.speak(text);
    } catch (e) {
      _speaking = false;
      debugPrint('[AiGuide] TTS speak failed: $e');
    }
  }

  Future<void> stop() async {
    try {
      _speaking = false;
      await _tts.stop();
    } catch (_) {}
  }

  // ─── PRE-WRITTEN VOICE LINES ────────────────────────────────────────────

  Future<void> announceWelcome(String name) =>
      speak('System online. Welcome back, $name. The ascension continues.');

  Future<void> announceXpGain(int xp) =>
      speak('+$xp experience points acquired.');

  Future<void> announceLevelUp(int level) =>
      speak('Level $level reached. You grow stronger, Hunter.');

  Future<void> announceRankUp(String rank) =>
      speak('Rank $rank unlocked. A new tier of power awaits you.');

  Future<void> announceStreakMilestone(int days) =>
      speak('$days-day streak achieved. Consistency is your superpower.');

  Future<void> announceWaterGoal() =>
      speak('Hydration goal complete. Your body operates at peak efficiency.');

  Future<void> announceWorkoutDone() =>
      speak('Training session logged. Recovery begins now.');

  Future<void> announceBossDefeated(String bossName) =>
      speak('Boss $bossName defeated. Exceptional performance, Hunter.');

  Future<void> announceQuestComplete(String arcName) =>
      speak('Quest arc $arcName completed. You have transcended your limits.');

  Future<void> speakTip(String tip) =>
      speak('System Advisory: $tip');

  Future<void> announceFocusStart(int minutes) =>
      speak('Focus session initiated. $minutes minutes of deep concentration. Begin.');

  Future<void> announceFocusEnd() =>
      speak('Focus session complete. Well done. Take a short break.');

  void dispose() {
    _tts.stop();
  }
}

final aiGuideProvider = Provider<AiGuideVoice>((ref) {
  final guide = AiGuideVoice.instance;
  ref.onDispose(() => guide.dispose());
  return guide;
});
