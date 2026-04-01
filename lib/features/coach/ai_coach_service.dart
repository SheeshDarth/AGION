import 'dart:math';

/// AI Coach — personalized tips, motivation, and form cues.
/// Runs entirely on-device. For smarter responses, can hook into
/// Vertex AI later via API call.
class AiCoachService {
  AiCoachService._();

  static final _random = Random();

  /// Get a context-aware coaching tip.
  static String getTip({
    required String fitnessLevel,
    required String currentArcTheme,
    required int streak,
    required String rank,
    required int workoutsToday,
  }) {
    // Streak-based motivation
    if (streak == 0) {
      return _pick(_comebackTips);
    }
    if (streak >= 30) {
      return _pick(_legendaryTips);
    }
    if (streak >= 14) {
      return _pick(_veteranTips);
    }
    if (streak >= 7) {
      return _pick(_momentumTips);
    }

    // Post-workout
    if (workoutsToday > 0) {
      return _pick(_postWorkoutTips);
    }

    // Level-specific
    switch (fitnessLevel) {
      case 'beginner':
        return _pick(_beginnerTips);
      case 'advanced':
        return _pick(_advancedTips);
      default:
        return _pick(_generalTips);
    }
  }

  /// Get a form cue for a specific exercise.
  static String getFormCue(String exerciseName) {
    final lower = exerciseName.toLowerCase();
    if (lower.contains('squat')) {
      return _pick(_squatCues);
    }
    if (lower.contains('push') || lower.contains('bench')) {
      return _pick(_pushCues);
    }
    if (lower.contains('deadlift')) {
      return _pick(_deadliftCues);
    }
    if (lower.contains('pull') || lower.contains('row')) {
      return _pick(_pullCues);
    }
    if (lower.contains('run') || lower.contains('sprint')) {
      return _pick(_runCues);
    }
    return _pick(_generalFormCues);
  }

  static String _pick(List<String> list) => list[_random.nextInt(list.length)];

  // ─── TIP BANKS ───────────────────────────────────────────────────────

  static const _comebackTips = [
    'The system notices your absence. One workout is all it takes to restart your momentum.',
    'Even the Shadow Monarch had to rise from 0. Start today.',
    'Your streak broke, but your spirit didn\'t. Get back in there.',
    'The pain of regret is worse than the pain of training. Move.',
  ];

  static const _legendaryTips = [
    'You\'ve been consistent for over a month. You\'re in the top 1%.',
    'At this point, training isn\'t discipline — it\'s identity.',
    'Your body has adapted. Time to increase intensity or try a harder arc.',
    'You\'re training like a hunter. The monsters should be afraid.',
  ];

  static const _veteranTips = [
    'Two weeks strong. The habit is forming — don\'t stop now.',
    'Your body is starting to change. Trust the process.',
    'Recovery is part of training. Sleep well tonight.',
    'Consider progressive overload: add weight or reps this week.',
  ];

  static const _momentumTips = [
    'One week in. The hardest part is over. Keep pushing.',
    'Consistency beats intensity. But together? Unstoppable.',
    'Hydration matters. Are you hitting your water target?',
    'Every workout is a deposit into your future self.',
  ];

  static const _postWorkoutTips = [
    'Workout complete. Your muscles grow during rest — fuel and recover.',
    'Great session. Protein within 2 hours for optimal recovery.',
    'You showed up, you trained, you earned it. Respect.',
    'One more day closer to your A-Rank evaluation.',
  ];

  static const _beginnerTips = [
    'Focus on form over weight. Perfect reps build perfect bodies.',
    'Start lighter than you think. Your ego isn\'t worth an injury.',
    'If it\'s your first week — focus on showing up consistently.',
    'Don\'t compare your Chapter 1 to someone else\'s Chapter 20.',
  ];

  static const _advancedTips = [
    'Time for periodization. Consider deloading this week.',
    'Track your lifts. Progressive overload requires data.',
    'Sleep 7-9 hours. Growth happens during deep sleep.',
    'At your level, nutrition is the biggest lever. Track macros.',
  ];

  static const _generalTips = [
    'Warm up properly. 5-10min dynamic stretching prevents injuries.',
    'Compound movements build the most muscle. Prioritize them.',
    'Train the muscle, not the ego. Control the weight.',
    'Breathe: exhale during effort, inhale during reset.',
  ];

  // ─── FORM CUES ──────────────────────────────────────────────────────

  static const _squatCues = [
    'Push knees out. Weight in mid-foot. Chest up.',
    'Break at the hips first, then bend knees.',
    'Aim below parallel. Partial reps = partial results.',
    'Brace your core like someone\'s about to punch you.',
  ];

  static const _pushCues = [
    'Retract your scapula. Tight upper back = safe shoulders.',
    'Full range of motion. Touch chest, full lockout.',
    'Elbows at ~45°, not flared out to 90°.',
    'Control the negative. 2-3 seconds down.',
  ];

  static const _deadliftCues = [
    'Neutral spine. No rounding. Ever.',
    'Push the floor away with your legs, don\'t yank with your back.',
    'Bar stays close to your body throughout.',
    'Hip hinge, not a squat. Feel your hamstrings load.',
  ];

  static const _pullCues = [
    'Initiate with your back, not your biceps.',
    'Squeeze your scapula together at the top.',
    'Full dead hang at the bottom. No kipping.',
    'Controlled descent. Don\'t just drop.',
  ];

  static const _runCues = [
    'Land midfoot, not on your heels.',
    'Lean slightly forward from the ankles.',
    'Short, quick strides. ~180 steps per minute.',
    'Breathe rhythmically. In through nose, out through mouth.',
  ];

  static const _generalFormCues = [
    'Controlled tempo. If you can\'t control it, it\'s too heavy.',
    'Full range of motion always beats half-reps with more weight.',
    'Breathe. Don\'t hold your breath on any rep.',
    'Mind-muscle connection: think about the muscle working.',
  ];
}
