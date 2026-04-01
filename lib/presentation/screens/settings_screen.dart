import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/audio_service.dart';
import '../../core/ai_guide_voice.dart';
import '../../features/player/player_state.dart';
import '../../features/profile/fitness_profile_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/system_toast.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  late int _waterTarget;
  late int _stepGoal;
  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  bool _voiceEnabled = true;
  double _musicVolume = 0.25;

  @override
  void initState() {
    super.initState();
    final player = ref.read(playerProvider);
    _nameController.text = player.displayName;
    _waterTarget = player.dailyWaterTarget;
    _stepGoal = player.stepGoal;
    _sfxEnabled = AudioService.instance.sfxEnabled;
    _musicEnabled = AudioService.instance.musicEnabled;
    _voiceEnabled = AiGuideVoice.instance.enabled;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgionColors.backgroundDeep,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AgionSpacing.md),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios,
                          color: AgionColors.mutedText, size: 20),
                    ),
                    const SizedBox(width: AgionSpacing.sm),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AgionColors.accentGradient.createShader(bounds),
                      child: const Text(
                        'SETTINGS',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AgionSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ─── PROFILE ──────────────────────────────────────

                  _sectionHeader('PROFILE'),

                  GlassCard(
                    showGlow: true,
                    padding: const EdgeInsets.all(AgionSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('HUNTER NAME'),
                        const SizedBox(height: AgionSpacing.sm),
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AgionColors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your name',
                            hintStyle: const TextStyle(
                                color: AgionColors.mutedText),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: AgionColors.neonCyan.withValues(alpha: 0.3)),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: AgionColors.neonCyan, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: AgionSpacing.md),
                        _saveButton('SAVE NAME', () {
                          final name = _nameController.text.trim();
                          if (name.isNotEmpty) {
                            ref.read(playerProvider.notifier).setDisplayName(name);
                            SystemToast.show(context, 'Name updated');
                            AudioService.instance.playButtonTap();
                          }
                        }),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0.0, delay: 100.ms),

                  const SizedBox(height: AgionSpacing.md),

                  // ─── FITNESS PROFILE ──────────────────────────────

                  _sectionHeader('FITNESS PROFILE'),
                  _buildFitnessProfileEditor(),

                  const SizedBox(height: AgionSpacing.md),

                  // ─── GOALS ────────────────────────────────────────

                  _sectionHeader('DAILY GOALS'),

                  GlassCard(
                    padding: const EdgeInsets.all(AgionSpacing.md),
                    child: Column(
                      children: [
                        _sliderRow(
                          label: 'WATER TARGET',
                          value: _waterTarget.toDouble(),
                          min: 1000,
                          max: 5000,
                          divisions: 16,
                          format: (v) => '${v.round()} ml',
                          onChanged: (v) {
                            setState(() => _waterTarget = v.round());
                            ref.read(playerProvider.notifier).setWaterTarget(v.round());
                          },
                        ),
                        const Divider(color: AgionColors.white06, height: 24),
                        _sliderRow(
                          label: 'STEP GOAL',
                          value: _stepGoal.toDouble(),
                          min: 2000,
                          max: 20000,
                          divisions: 18,
                          format: (v) => '${(v / 1000).toStringAsFixed(1)}k',
                          onChanged: (v) {
                            setState(() => _stepGoal = v.round());
                            ref.read(playerProvider.notifier).setStepGoal(v.round());
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0.0, delay: 300.ms),

                  const SizedBox(height: AgionSpacing.md),

                  // ─── AUDIO ────────────────────────────────────────

                  _sectionHeader('AUDIO'),

                  GlassCard(
                    padding: const EdgeInsets.all(AgionSpacing.md),
                    child: Column(
                      children: [
                        _switchRow(
                          'Sound Effects',
                          '⚔️',
                          _sfxEnabled,
                          (v) async {
                            setState(() => _sfxEnabled = v);
                            await AudioService.instance.setSfxEnabled(v);
                          },
                        ),
                        const Divider(color: AgionColors.white06, height: 16),
                        _switchRow(
                          'Theme Music',
                          '🎵',
                          _musicEnabled,
                          (v) async {
                            setState(() => _musicEnabled = v);
                            await AudioService.instance.setMusicEnabled(v);
                          },
                        ),
                        if (_musicEnabled) ...[
                          const SizedBox(height: 8),
                          _sliderRow(
                            label: 'MUSIC VOLUME',
                            value: _musicVolume,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            format: (v) => '${(v * 100).round()}%',
                            onChanged: (v) {
                              setState(() => _musicVolume = v);
                              AudioService.instance.setMusicVolume(v);
                            },
                          ),
                        ],
                        const Divider(color: AgionColors.white06, height: 16),
                        _switchRow(
                          'AI Guide Voice',
                          '🤖',
                          _voiceEnabled,
                          (v) {
                            setState(() => _voiceEnabled = v);
                            AiGuideVoice.instance.setEnabled(v);
                            if (v) {
                              AiGuideVoice.instance.speak('AI Guide voice activated.');
                            }
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0.0, delay: 400.ms),

                  const SizedBox(height: AgionSpacing.md),

                  // ─── APP INFO ─────────────────────────────────────

                  _sectionHeader('APP INFO'),

                  GlassCard(
                    padding: const EdgeInsets.all(AgionSpacing.md),
                    child: Column(
                      children: [
                        _infoRow('Version', '1.0.0'),
                        _infoRow('Build', '2026.03'),
                        _infoRow('Storage', 'Local + Cloud Sync'),
                        _infoRow('Framework', 'Flutter 3.38.5'),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: AgionSpacing.xl * 2),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── FITNESS PROFILE EDITOR ───────────────────────────────────────────────

  Widget _buildFitnessProfileEditor() {
    final profile = ref.watch(fitnessProfileProvider);
    return GlassCard(
      padding: const EdgeInsets.all(AgionSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('FITNESS LEVEL'),
          const SizedBox(height: AgionSpacing.sm),
          _chipRow(
            options: const ['beginner', 'intermediate', 'advanced'],
            labels: const ['Beginner', 'Intermediate', 'Advanced'],
            selected: profile.fitnessLevel,
            onSelect: (v) => ref.read(fitnessProfileProvider.notifier)
                .updateField(fitnessLevel: v),
          ),
          const SizedBox(height: AgionSpacing.md),
          _label('PRIMARY GOAL'),
          const SizedBox(height: AgionSpacing.sm),
          _chipRow(
            options: const ['fat_loss', 'muscle_gain', 'strength', 'endurance', 'general'],
            labels: const ['Fat Loss', 'Muscle', 'Strength', 'Endurance', 'General'],
            selected: profile.primaryGoal,
            onSelect: (v) => ref.read(fitnessProfileProvider.notifier)
                .updateField(primaryGoal: v),
          ),
          const SizedBox(height: AgionSpacing.md),
          _label('EQUIPMENT'),
          const SizedBox(height: AgionSpacing.sm),
          _chipRow(
            options: const ['bodyweight', 'minimal', 'full_gym'],
            labels: const ['Bodyweight', 'Minimal', 'Full Gym'],
            selected: profile.equipment,
            onSelect: (v) => ref.read(fitnessProfileProvider.notifier)
                .updateField(equipment: v),
          ),
          const SizedBox(height: AgionSpacing.md),
          _sliderRow(
            label: 'DAYS/WEEK: ${profile.workoutDaysPerWeek}',
            value: profile.workoutDaysPerWeek.toDouble(),
            min: 3,
            max: 7,
            divisions: 4,
            format: (v) => '${v.round()} days',
            onChanged: (v) => ref.read(fitnessProfileProvider.notifier)
                .updateField(workoutDaysPerWeek: v.round()),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0.0, delay: 200.ms);
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AgionSpacing.sm),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AgionColors.mutedText,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AgionColors.mutedText,
          letterSpacing: 2,
        ),
      );

  Widget _chipRow({
    required List<String> options,
    required List<String> labels,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Wrap(
      spacing: AgionSpacing.sm,
      runSpacing: AgionSpacing.sm,
      children: List.generate(options.length, (i) {
        final isSelected = options[i] == selected;
        return GestureDetector(
          onTap: () {
            AudioService.instance.playButtonTap();
            onSelect(options[i]);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: AgionSpacing.md, vertical: AgionSpacing.xs),
            decoration: BoxDecoration(
              gradient: isSelected ? AgionColors.accentGradient : null,
              color: isSelected ? null : AgionColors.white06,
              borderRadius: AgionRadius.smallBR,
            ),
            child: Text(
              labels[i],
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AgionColors.backgroundDeep
                    : AgionColors.mutedText,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _sliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String Function(double) format,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 9,
                  color: AgionColors.mutedText,
                  letterSpacing: 1,
                )),
            Text(
              format(value),
              style: const TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AgionColors.neonCyan,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AgionColors.neonCyan,
          inactiveColor: AgionColors.white06,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _switchRow(
      String label, String emoji, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: AgionSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AgionColors.white,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AgionColors.neonCyan,
          inactiveThumbColor: AgionColors.mutedText,
          inactiveTrackColor: AgionColors.white06,
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AgionSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 14,
                color: AgionColors.mutedText,
              )),
          Text(value,
              style: const TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AgionColors.white,
              )),
        ],
      ),
    );
  }

  Widget _saveButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AgionSpacing.md, vertical: AgionSpacing.sm),
        decoration: BoxDecoration(
          gradient: AgionColors.accentGradient,
          borderRadius: AgionRadius.smallBR,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AgionColors.backgroundDeep,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
