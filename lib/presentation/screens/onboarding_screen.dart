import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../core/audio_service.dart';
import '../../core/ai_guide_voice.dart';
import '../../features/player/player_state.dart';
import '../../features/profile/fitness_profile_state.dart';
import '../widgets/glass_card.dart';

/// 3-step onboarding wizard shown on first launch.
class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Step 2: Name
  final _nameController = TextEditingController(text: 'Hunter');

  // Step 3: Fitness profile
  String _fitnessLevel = 'beginner';
  String _primaryGoal = 'general';
  String _equipment = 'bodyweight';
  int _daysPerWeek = 5;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      AiGuideVoice.instance.speak(
          'Welcome to Agion. The Personal Ascension System. Let us begin your calibration.');
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    AudioService.instance.playButtonTap();
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _complete();
    }
  }

  Future<void> _complete() async {
    // Save display name
    ref.read(playerProvider.notifier).setDisplayName(_nameController.text.trim().isEmpty
        ? 'Hunter'
        : _nameController.text.trim());

    // Save fitness profile
    await ref.read(fitnessProfileProvider.notifier).updateField(
          fitnessLevel: _fitnessLevel,
          primaryGoal: _primaryGoal,
          equipment: _equipment,
          workoutDaysPerWeek: _daysPerWeek,
        );

    // Mark onboarding complete
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);

    AiGuideVoice.instance.speak(
        'Calibration complete. Welcome, ${_nameController.text}. Your ascension begins now.');
    AudioService.instance.playQuestStart();

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgionColors.backgroundDeep,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AgionColors.neonViolet.withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AgionColors.neonCyan.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Step indicator
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.all(AgionSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final isActive = i == _currentPage;
                      final isDone = i < _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : (isDone ? 16 : 8),
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: isActive || isDone
                              ? AgionColors.accentGradient
                              : null,
                          color: isActive || isDone
                              ? null
                              : AgionColors.white06,
                        ),
                      );
                    }),
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                      _buildStep3(),
                    ],
                  ),
                ),

                // CTA button
                Padding(
                  padding: const EdgeInsets.all(AgionSpacing.lg),
                  child: GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: AgionSpacing.md),
                      decoration: BoxDecoration(
                        gradient: AgionColors.accentGradient,
                        borderRadius: AgionRadius.cardBR,
                        boxShadow: [
                          BoxShadow(
                            color: AgionColors.neonCyan.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _currentPage == 2 ? 'BEGIN ASCENSION' : 'CONTINUE',
                          style: const TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AgionColors.backgroundDeep,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0.0, delay: 800.ms),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP 1: WELCOME ─────────────────────────────────────────────────────

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(AgionSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Big emoji icon
          const Text('🗡️', style: TextStyle(fontSize: 72))
              .animate()
              .scale(
                begin: const Offset(0.0, 0.0),
                end: const Offset(1.0, 1.0),
                duration: 700.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 400.ms),

          const SizedBox(height: AgionSpacing.xl),

          ShaderMask(
            shaderCallback: (bounds) =>
                AgionColors.accentGradient.createShader(bounds),
            child: const Text(
              'YOUR ASCENSION\nBEGINS HERE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 2,
                height: 1.3,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0.0, delay: 400.ms, duration: 600.ms),

          const SizedBox(height: AgionSpacing.lg),

          const Text(
            'Transform your daily habits into a real-life RPG. '
            'Train harder, level up, and rise through the ranks.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AgionColors.mutedText,
              height: 1.6,
            ),
          )
              .animate()
              .fadeIn(delay: 700.ms, duration: 600.ms),

          const SizedBox(height: AgionSpacing.xl),

          // Feature highlights
          ..._features.asMap().entries.map((e) {
            final delay = Duration(milliseconds: 900 + e.key * 120);
            return Padding(
              padding: const EdgeInsets.only(bottom: AgionSpacing.sm),
              child: Row(
                children: [
                  Text(e.value.$1, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: AgionSpacing.sm),
                  Text(
                    e.value.$2,
                    style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AgionColors.white,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: delay, duration: 400.ms)
                  .slideX(begin: -0.2, end: 0.0, delay: delay, duration: 400.ms),
            );
          }),
        ],
      ),
    );
  }

  static const _features = [
    ('⚔️', 'Workout Logging & XP System'),
    ('💧', 'Water & Hydration Tracker'),
    ('🏴', 'Quest Arcs with Boss Fights'),
    ('📊', 'Progress Analytics & Stats'),
    ('🔥', 'Streak System & Rank Milestones'),
  ];

  // ─── STEP 2: NAME ────────────────────────────────────────────────────────

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(AgionSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👤', style: TextStyle(fontSize: 56))
              .animate()
              .scale(
                begin: const Offset(0.0, 0.0),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: AgionSpacing.xl),

          const Text(
            'YOUR HUNTER NAME',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AgionColors.white,
              letterSpacing: 2,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: AgionSpacing.sm),

          const Text(
            'This is how the system will address you.',
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 15,
              color: AgionColors.mutedText,
            ),
          ).animate().fadeIn(delay: 350.ms),

          const SizedBox(height: AgionSpacing.xl),

          GlassCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AgionSpacing.md,
              vertical: AgionSpacing.sm,
            ),
            child: TextField(
              controller: _nameController,
              autofocus: false,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AgionColors.white,
                letterSpacing: 2,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'HUNTER',
                hintStyle: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 22,
                  color: AgionColors.mutedText,
                  letterSpacing: 2,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0.0, delay: 500.ms),

          const SizedBox(height: AgionSpacing.xl),

          const Text(
            'E-Rank → D-Rank → C-Rank → B-Rank → A-Rank → S-Rank',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 13,
              color: AgionColors.mutedText,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 700.ms),
        ],
      ),
    );
  }

  // ─── STEP 3: FITNESS PROFILE ─────────────────────────────────────────────

  Widget _buildStep3() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AgionSpacing.lg),
      child: Column(
        children: [
          const Text('⚙️', style: TextStyle(fontSize: 48))
              .animate()
              .scale(
                begin: const Offset(0.0, 0.0),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: AgionSpacing.md),

          const Text(
            'CALIBRATE YOUR PROFILE',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AgionColors.white,
              letterSpacing: 2,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: AgionSpacing.sm),

          const Text(
            'This personalizes your Quest Arcs and training intensity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 14,
              color: AgionColors.mutedText,
            ),
          ).animate().fadeIn(delay: 350.ms),

          const SizedBox(height: AgionSpacing.lg),

          _buildSectionLabel('FITNESS LEVEL'),
          _buildChipRow(
            options: const ['beginner', 'intermediate', 'advanced'],
            labels: const ['Beginner', 'Intermediate', 'Advanced'],
            selected: _fitnessLevel,
            onSelect: (v) => setState(() => _fitnessLevel = v),
          ),

          const SizedBox(height: AgionSpacing.md),

          _buildSectionLabel('PRIMARY GOAL'),
          _buildChipRow(
            options: const ['fat_loss', 'muscle_gain', 'strength', 'endurance', 'general'],
            labels: const ['Fat Loss', 'Muscle', 'Strength', 'Endurance', 'General'],
            selected: _primaryGoal,
            onSelect: (v) => setState(() => _primaryGoal = v),
          ),

          const SizedBox(height: AgionSpacing.md),

          _buildSectionLabel('EQUIPMENT'),
          _buildChipRow(
            options: const ['bodyweight', 'minimal', 'full_gym'],
            labels: const ['Bodyweight', 'Minimal', 'Full Gym'],
            selected: _equipment,
            onSelect: (v) => setState(() => _equipment = v),
          ),

          const SizedBox(height: AgionSpacing.md),

          _buildSectionLabel('DAYS PER WEEK: $_daysPerWeek'),
          Slider(
            value: _daysPerWeek.toDouble(),
            min: 3,
            max: 7,
            divisions: 4,
            activeColor: AgionColors.neonCyan,
            inactiveColor: AgionColors.white06,
            onChanged: (v) => setState(() => _daysPerWeek = v.round()),
          ),

          const SizedBox(height: AgionSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
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

  Widget _buildChipRow({
    required List<String> options,
    required List<String> labels,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: AgionSpacing.sm),
      child: Wrap(
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
                horizontal: AgionSpacing.md,
                vertical: AgionSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: isSelected ? AgionColors.accentGradient : null,
                color: isSelected ? null : AgionColors.white06,
                borderRadius: AgionRadius.smallBR,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AgionColors.white06,
                ),
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
      ),
    );
  }
}
