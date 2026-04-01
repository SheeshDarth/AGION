import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized audio manager for all AGION sounds.
/// Manages theme music, SFX, and AI guide voice playback.
class AudioService {
  AudioService._();
  static final AudioService _instance = AudioService._();
  static AudioService get instance => _instance;

  // Separate players for concurrent playback
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _voicePlayer = AudioPlayer();

  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _sfxEnabled = prefs.getBool('sfx_enabled') ?? true;
    _musicEnabled = prefs.getBool('music_enabled') ?? true;

    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.25);
    await _sfxPlayer.setVolume(1.0);
    await _voicePlayer.setVolume(1.0);
  }

  // ─── MUSIC ──────────────────────────────────────────────────
  Future<void> playThemeMusic() async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.play(AssetSource('audio/theme.mp3'));
    } catch (e) {
      debugPrint('[Audio] Theme music not found, skipping: $e');
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMusic() async {
    if (_musicEnabled) await _musicPlayer.resume();
  }

  // ─── SFX ────────────────────────────────────────────────────
  Future<void> playAppOpen() async {
    await _playSound('audio/app_open.mp3');
  }

  Future<void> playXpGain() async {
    await _playSound('audio/xp_gain.mp3');
  }

  Future<void> playLevelUp() async {
    await _playSound('audio/level_up.mp3');
  }

  Future<void> playRankUp() async {
    await _playSound('audio/rank_up.mp3');
  }

  Future<void> playWaterDrop() async {
    await _playSound('audio/water_drop.mp3');
  }

  Future<void> playWorkoutDone() async {
    await _playSound('audio/workout_done.mp3');
  }

  Future<void> playBossFight() async {
    await _playSound('audio/boss_fight.mp3');
  }

  Future<void> playBossDefeated() async {
    await _playSound('audio/boss_defeated.mp3');
  }

  Future<void> playButtonTap() async {
    await _playSound('audio/button_tap.mp3');
  }

  Future<void> playFocusStart() async {
    await _playSound('audio/focus_start.mp3');
  }

  Future<void> playFocusEnd() async {
    await _playSound('audio/focus_end.mp3');
  }

  Future<void> playQuestStart() async {
    await _playSound('audio/quest_start.mp3');
  }

  // ─── AI VOICE GUIDE ─────────────────────────────────────────
  Future<void> playVoice(String fileName) async {
    if (!_sfxEnabled) return;
    try {
      await _voicePlayer.stop();
      await _voicePlayer.play(AssetSource('audio/$fileName'));
    } catch (e) {
      debugPrint('[Audio] Voice not found: $fileName — $e');
    }
  }

  // ─── SETTINGS ───────────────────────────────────────────────
  bool get sfxEnabled => _sfxEnabled;
  bool get musicEnabled => _musicEnabled;

  Future<void> setSfxEnabled(bool value) async {
    _sfxEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sfx_enabled', value);
    if (!value) await _sfxPlayer.stop();
  }

  Future<void> setMusicEnabled(bool value) async {
    _musicEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', value);
    if (!value) {
      await _musicPlayer.pause();
    } else {
      await _musicPlayer.resume();
    }
  }

  Future<void> setMusicVolume(double volume) async {
    await _musicPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  // ─── PRIVATE ────────────────────────────────────────────────
  Future<void> _playSound(String path) async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(path));
    } catch (e) {
      debugPrint('[Audio] SFX not found: $path — $e');
    }
  }

  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
    _voicePlayer.dispose();
  }
}

// Riverpod provider
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService.instance;
  ref.onDispose(() => service.dispose());
  return service;
});
