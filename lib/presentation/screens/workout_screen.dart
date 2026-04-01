import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../domain/models/workout.dart';
import '../../features/workouts/workout_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/system_toast.dart';
import '../widgets/xp_gain_overlay.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(workoutListProvider.notifier).init());
  }

  @override
  Widget build(BuildContext context) {
    final workouts = ref.watch(workoutListProvider);

    return Scaffold(
      backgroundColor: AgionColors.backgroundDeep,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AgionSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AgionColors.accentGradient.createShader(bounds),
                    child: const Text(
                      'WORKOUT LOG',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  _buildAddButton(),
                ],
              ),
            ),

            // Workout list
            Expanded(
              child: workouts.isEmpty
                  ? _buildEmptyState()
                  : _buildWorkoutList(workouts),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _openNewWorkout,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AgionSpacing.md,
          vertical: AgionSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: AgionColors.accentGradient,
          borderRadius: AgionRadius.smallBR,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 18, color: AgionColors.backgroundDeep),
            SizedBox(width: 4),
            Text(
              'NEW',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AgionColors.backgroundDeep,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚔️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AgionSpacing.md),
          const Text(
            'NO WORKOUTS YET',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AgionColors.mutedText,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AgionSpacing.sm),
          const Text(
            'Tap + to log your first session',
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 16,
              color: AgionColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutList(List<Workout> workouts) {
    // Group by week
    final Map<String, List<Workout>> grouped = {};
    for (final w in workouts) {
      final weekStart = w.date.subtract(Duration(days: w.date.weekday - 1));
      final key =
          '${weekStart.day}/${weekStart.month}/${weekStart.year}';
      grouped.putIfAbsent(key, () => []).add(w);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AgionSpacing.md),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final weekKey = grouped.keys.elementAt(index);
        final weekWorkouts = grouped[weekKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week header
            Padding(
              padding: const EdgeInsets.only(
                top: AgionSpacing.md,
                bottom: AgionSpacing.sm,
              ),
              child: Text(
                'WEEK OF $weekKey',
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AgionColors.mutedText,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            ...weekWorkouts.map((w) => _buildWorkoutCard(w)),
          ],
        );
      },
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    final exerciseCount = workout.exercises.length;
    final totalSets =
        workout.exercises.fold<int>(0, (sum, e) => sum + e.sets.length);
    final duration = Duration(seconds: workout.duration);
    final durationStr = duration.inMinutes > 0
        ? '${duration.inMinutes}m'
        : '${duration.inSeconds}s';

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AgionSpacing.sm),
      showGlow: true,
      child: InkWell(
        onTap: () => _openEditWorkout(workout),
        onLongPress: () => _showWorkoutOptions(workout),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(workout.date),
                  style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AgionColors.neonCyan,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AgionSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AgionColors.white06,
                    borderRadius: AgionRadius.smallBR,
                  ),
                  child: Text(
                    durationStr,
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AgionColors.mutedText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AgionSpacing.sm),

            // Exercises summary
            ...workout.exercises.take(3).map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${e.name} — ${e.sets.length} sets',
                    style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 15,
                      color: AgionColors.white,
                    ),
                  ),
                )),
            if (workout.exercises.length > 3)
              Text(
                '+${workout.exercises.length - 3} more',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 13,
                  color: AgionColors.mutedText.withValues(alpha: 0.7),
                ),
              ),

            const SizedBox(height: AgionSpacing.sm),

            // Bottom stats
            Row(
              children: [
                _statChip('$exerciseCount exercises'),
                const SizedBox(width: AgionSpacing.sm),
                _statChip('$totalSets sets'),
                const Spacer(),
                // Duplicate button
                GestureDetector(
                  onTap: () => _duplicateWorkout(workout),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AgionSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AgionColors.neonViolet.withValues(alpha: 0.4),
                      ),
                      borderRadius: AgionRadius.smallBR,
                    ),
                    child: const Text(
                      'DUPLICATE',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: AgionColors.neonViolet,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AgionColors.white06,
        borderRadius: AgionRadius.smallBR,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 12,
          color: AgionColors.mutedText,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month]}';
  }

  void _openNewWorkout() {
    ref.read(activeWorkoutProvider.notifier).startNew();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _WorkoutEditorScreen()),
    );
  }

  void _openEditWorkout(Workout workout) {
    ref.read(activeWorkoutProvider.notifier).loadExisting(workout);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _WorkoutEditorScreen()),
    );
  }

  void _duplicateWorkout(Workout workout) {
    ref.read(activeWorkoutProvider.notifier).duplicate(workout);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _WorkoutEditorScreen()),
    );
    SystemToast.show(context, 'Workout duplicated — edit and save');
  }

  void _showWorkoutOptions(Workout workout) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(AgionSpacing.lg),
        decoration: const BoxDecoration(
          color: AgionColors.backgroundDeep,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy, color: AgionColors.neonViolet),
              title: const Text('Duplicate',
                  style: TextStyle(color: AgionColors.white)),
              onTap: () {
                Navigator.pop(context);
                _duplicateWorkout(workout);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AgionColors.danger),
              title: const Text('Delete',
                  style: TextStyle(color: AgionColors.danger)),
              onTap: () {
                Navigator.pop(context);
                ref.read(workoutListProvider.notifier).deleteWorkout(workout.id);
                SystemToast.show(context, 'Workout deleted');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WORKOUT EDITOR SCREEN (add/edit session)
// ═══════════════════════════════════════════════════════════════════════════

class _WorkoutEditorScreen extends ConsumerStatefulWidget {
  const _WorkoutEditorScreen();

  @override
  ConsumerState<_WorkoutEditorScreen> createState() =>
      _WorkoutEditorScreenState();
}

class _WorkoutEditorScreenState extends ConsumerState<_WorkoutEditorScreen> {
  final _notesController = TextEditingController();
  final _exerciseNameController = TextEditingController();
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    final workout = ref.read(activeWorkoutProvider);
    if (workout != null) {
      _notesController.text = workout.notes;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _exerciseNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(activeWorkoutProvider);
    if (workout == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AgionColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AgionColors.backgroundDeep,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AgionColors.mutedText),
          onPressed: () {
            ref.read(activeWorkoutProvider.notifier).clear();
            Navigator.pop(context);
          },
        ),
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AgionColors.accentGradient.createShader(bounds),
          child: const Text(
            'LOG WORKOUT',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _saveWorkout,
            child: Container(
              margin: const EdgeInsets.only(right: AgionSpacing.md),
              padding: const EdgeInsets.symmetric(
                horizontal: AgionSpacing.md,
                vertical: AgionSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: AgionColors.accentGradient,
                borderRadius: AgionRadius.smallBR,
              ),
              child: const Text(
                'SAVE',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AgionColors.backgroundDeep,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AgionSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise list
            ...workout.exercises.asMap().entries.map(
                  (entry) =>
                      _buildExerciseBlock(entry.key, entry.value, workout),
                ),

            const SizedBox(height: AgionSpacing.md),

            // Add exercise button
            _buildAddExerciseButton(),

            const SizedBox(height: AgionSpacing.lg),

            // Notes
            GlassCard(
              child: TextField(
                controller: _notesController,
                onChanged: (v) =>
                    ref.read(activeWorkoutProvider.notifier).setNotes(v),
                style: const TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 16,
                  color: AgionColors.white,
                ),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Notes...',
                  hintStyle: TextStyle(color: AgionColors.mutedText),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: AgionSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseBlock(
      int exerciseIndex, Exercise exercise, Workout workout) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AgionSpacing.sm),
      showGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exercise.name.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AgionColors.neonCyan,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => ref
                    .read(activeWorkoutProvider.notifier)
                    .removeExercise(exerciseIndex),
                child: const Icon(Icons.close,
                    size: 18, color: AgionColors.mutedText),
              ),
            ],
          ),

          const SizedBox(height: AgionSpacing.sm),

          // Sets header
          const Row(
            children: [
              SizedBox(width: 32, child: Text('SET', style: _setHeaderStyle)),
              Expanded(
                  child: Center(
                      child: Text('KG', style: _setHeaderStyle))),
              Expanded(
                  child: Center(
                      child: Text('REPS', style: _setHeaderStyle))),
              SizedBox(width: 32),
            ],
          ),
          const SizedBox(height: AgionSpacing.xs),

          // Sets
          ...exercise.sets.asMap().entries.map(
                (entry) =>
                    _buildSetRow(exerciseIndex, entry.key, entry.value),
              ),

          // Add set button
          GestureDetector(
            onTap: () => ref
                .read(activeWorkoutProvider.notifier)
                .addSet(exerciseIndex),
            child: Container(
              margin: const EdgeInsets.only(top: AgionSpacing.sm),
              padding: const EdgeInsets.symmetric(vertical: AgionSpacing.sm),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AgionColors.neonCyan.withValues(alpha: 0.2),
                ),
                borderRadius: AgionRadius.smallBR,
              ),
              child: const Center(
                child: Text(
                  '+ ADD SET',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AgionColors.neonCyan,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(int exerciseIndex, int setIndex, ExerciseSet set) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${setIndex + 1}',
              style: const TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AgionColors.mutedText,
              ),
            ),
          ),
          // Weight input
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AgionColors.white06,
                borderRadius: AgionRadius.smallBR,
              ),
              child: TextFormField(
                initialValue: set.weight > 0 ? '${set.weight}' : '',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AgionColors.white,
                ),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(color: AgionColors.mutedText),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) {
                  final weight = double.tryParse(v) ?? 0;
                  ref
                      .read(activeWorkoutProvider.notifier)
                      .updateSet(exerciseIndex, setIndex, weight: weight);
                },
              ),
            ),
          ),
          // Reps input
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AgionColors.white06,
                borderRadius: AgionRadius.smallBR,
              ),
              child: TextFormField(
                initialValue: set.reps > 0 ? '${set.reps}' : '',
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AgionColors.white,
                ),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(color: AgionColors.mutedText),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) {
                  final reps = int.tryParse(v) ?? 0;
                  ref
                      .read(activeWorkoutProvider.notifier)
                      .updateSet(exerciseIndex, setIndex, reps: reps);
                },
              ),
            ),
          ),
          // Remove set
          SizedBox(
            width: 32,
            child: GestureDetector(
              onTap: () => ref
                  .read(activeWorkoutProvider.notifier)
                  .removeSet(exerciseIndex, setIndex),
              child: const Icon(Icons.remove_circle_outline,
                  size: 18, color: AgionColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddExerciseButton() {
    return GestureDetector(
      onTap: _showAddExerciseDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AgionSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: AgionColors.neonViolet.withValues(alpha: 0.3),
          ),
          borderRadius: AgionRadius.cardBR,
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 20, color: AgionColors.neonViolet),
              SizedBox(width: AgionSpacing.sm),
              Text(
                'ADD EXERCISE',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AgionColors.neonViolet,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddExerciseDialog() {
    _exerciseNameController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AgionColors.backgroundDeep,
        shape: RoundedRectangleBorder(
          borderRadius: AgionRadius.cardBR,
          side: const BorderSide(color: AgionColors.neonCyan, width: 0.5),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AgionColors.accentGradient.createShader(bounds),
          child: const Text(
            'ADD EXERCISE',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
        content: TextField(
          controller: _exerciseNameController,
          autofocus: true,
          style: const TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 18,
            color: AgionColors.white,
          ),
          decoration: const InputDecoration(
            hintText: 'e.g. Bench Press',
            hintStyle: TextStyle(color: AgionColors.mutedText),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AgionColors.neonCyan),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AgionColors.neonCyan, width: 2),
            ),
          ),
          onSubmitted: (_) => _addExercise(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AgionColors.mutedText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AgionColors.neonCyan,
              foregroundColor: AgionColors.backgroundDeep,
            ),
            onPressed: () => _addExercise(ctx),
            child: const Text('ADD',
                style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _addExercise(BuildContext dialogCtx) {
    final name = _exerciseNameController.text.trim();
    if (name.isEmpty) return;
    ref.read(activeWorkoutProvider.notifier).addExercise(name);
    ref.read(activeWorkoutProvider.notifier).addSet(
          ref.read(activeWorkoutProvider)!.exercises.length - 1,
        );
    Navigator.pop(dialogCtx);
  }

  void _saveWorkout() {
    final workout = ref.read(activeWorkoutProvider);
    if (workout == null) return;

    // Calculate duration
    final duration = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds
        : workout.duration;

    final finalWorkout = workout.copyWith(
      duration: duration,
      notes: _notesController.text,
      updatedAt: DateTime.now(),
    );

    ref.read(workoutListProvider.notifier).saveWorkout(finalWorkout);
    ref.read(activeWorkoutProvider.notifier).clear();

    // Celebration animations
    WorkoutCompleteAnimation.show(context);
    XpGainOverlay.show(context, XpConfig.workoutXp);

    Navigator.pop(context);
    SystemToast.show(context, 'Workout saved! +${XpConfig.workoutXp} XP ⚔️');
  }

  static const _setHeaderStyle = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 9,
    fontWeight: FontWeight.w500,
    color: AgionColors.mutedText,
    letterSpacing: 1,
  );
}
