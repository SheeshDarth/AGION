import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/sl/sl_colors.dart';
import '../../../core/sl/sl_type.dart';
import '../../../data/models/workout_session_model.dart';
import '../../../providers/workout_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../data/remote/exercise_api_client.dart';
import '../../system/system_bg.dart';
import '../../system/system_button.dart';
import '../../system/system_panel.dart';
import '../../system/system_text.dart';
import '../../overlays/xp_pop.dart';

class ActiveSessionScreen extends ConsumerStatefulWidget {
  const ActiveSessionScreen({super.key});

  @override
  ConsumerState<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  final _exerciseClient = ExerciseApiClient();
  late DateTime _startTime;
  late Timer _timer;
  Duration _elapsed = Duration.zero;
  final _titleCtrl = TextEditingController(text: 'TRAINING SESSION');

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = DateTime.now().difference(_startTime));
    });
    ref.read(activeSessionProvider.notifier).start(_titleCtrl.text);
  }

  @override
  void dispose() {
    _timer.cancel();
    _titleCtrl.dispose();
    super.dispose();
  }

  String get _elapsedStr {
    final m = _elapsed.inMinutes;
    final s = _elapsed.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _addExercise() async {
    final exercises = await _exerciseClient.fetchExercises();
    if (!mounted) return;
    final picked = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _ExercisePicker(exercises: exercises),
    );
    if (picked == null) return;
    ref.read(activeSessionProvider.notifier).addExercise(
      ExerciseEntry()..name = picked['name']!..category = picked['category']!..sets = [],
    );
  }

  Future<void> _finish() async {
    final session = ref.read(activeSessionProvider.notifier).finish(_elapsed.inMinutes);
    if (session == null) { context.pop(); return; }
    await ref.read(workoutProvider.notifier).save(session);
    final center = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 3,
    );
    ref.read(playerProvider.notifier).addXP(session.xpEarned, 'workout', center);
    if (mounted) context.pushReplacement('/workout/summary');
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeSessionProvider);

    return Scaffold(
      backgroundColor: SLColors.voidBg,
      body: SystemBg(
        child: SafeArea(
          child: Column(
            children: [
              // Timer bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ref.read(activeSessionProvider.notifier).cancel();
                        context.pop();
                      },
                      child: SLText('CANCEL', style: SLType.sysLabel(color: SLColors.danger)),
                    ),
                    const Spacer(),
                    SLText(_elapsedStr,
                        style: SLType.display(size: 32, color: SLColors.glowCore),
                        glowColor: SLColors.glowCore),
                    const Spacer(),
                    GestureDetector(
                      onTap: _finish,
                      child: SLText('FINISH', style: SLType.sysLabel(color: SLColors.success)),
                    ),
                  ],
                ),
              ),
              // Exercise list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (session != null)
                      ...session.exercises.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ExerciseBlock(
                            exercise: entry.value,
                            exerciseIdx: entry.key,
                            onSetChanged: (setIdx, set) {
                              ref.read(activeSessionProvider.notifier)
                                  .updateSet(entry.key, setIdx, set);
                              if (set.isCompleted) {
                                XPPop.show(context, 5, Offset(
                                  MediaQuery.of(context).size.width / 2,
                                  200,
                                ));
                              }
                            },
                            onAddSet: () => ref.read(activeSessionProvider.notifier).addSet(entry.key),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SystemButton(
                      label: 'ADD EXERCISE',
                      variant: SystemButtonVariant.ghost,
                      icon: Icons.add,
                      onTap: _addExercise,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseBlock extends StatelessWidget {
  final ExerciseEntry exercise;
  final int exerciseIdx;
  final void Function(int, SetEntry) onSetChanged;
  final VoidCallback onAddSet;

  const _ExerciseBlock({
    required this.exercise,
    required this.exerciseIdx,
    required this.onSetChanged,
    required this.onAddSet,
  });

  @override
  Widget build(BuildContext context) {
    return SystemPanel(
      glowColor: SLColors.rankS,
      glowIntensity: 0.3,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SLText(exercise.name, style: SLType.questTitle(size: 14, color: SLColors.textBright)),
              const SizedBox(width: 8),
              SLText(exercise.category, style: SLType.tag(size: 9, color: SLColors.rankS)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(width: 32, child: SLText('SET', style: SLType.sysLabel(size: 8, color: SLColors.textDim))),
              const SizedBox(width: 8),
              Expanded(child: SLText('KG', style: SLType.sysLabel(size: 8, color: SLColors.textDim))),
              Expanded(child: SLText('REPS', style: SLType.sysLabel(size: 8, color: SLColors.textDim))),
              SizedBox(width: 32, child: SLText('✓', style: SLType.sysLabel(size: 8, color: SLColors.textDim), align: TextAlign.center)),
            ],
          ),
          ...exercise.sets.asMap().entries.map((e) => _SetRow(
            setIndex: e.key,
            set: e.value,
            onChanged: (s) => onSetChanged(e.key, s),
          )),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onAddSet,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SLText('+ ADD SET', style: SLType.sysLabel(size: 9, color: SLColors.glowDim)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  final int setIndex;
  final SetEntry set;
  final ValueChanged<SetEntry> onChanged;

  const _SetRow({required this.setIndex, required this.set, required this.onChanged});

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _kgCtrl;
  late TextEditingController _repsCtrl;

  @override
  void initState() {
    super.initState();
    _kgCtrl = TextEditingController(text: widget.set.weightKg == 0 ? '' : '${widget.set.weightKg}');
    _repsCtrl = TextEditingController(text: widget.set.reps == 0 ? '' : '${widget.set.reps}');
  }

  @override
  void dispose() {
    _kgCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  void _commit(bool completed) {
    final s = SetEntry()
      ..weightKg = double.tryParse(_kgCtrl.text) ?? 0
      ..reps = int.tryParse(_repsCtrl.text) ?? 0
      ..isCompleted = completed;
    widget.onChanged(s);
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.set.isCompleted;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: done ? BoxDecoration(
        color: SLColors.success.withOpacity(0.06),
      ) : null,
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: SLText('${widget.setIndex + 1}',
                style: SLType.body(size: 13, color: SLColors.textMid)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _kgCtrl,
              keyboardType: TextInputType.number,
              style: SLType.body(size: 14, color: SLColors.textBright),
              decoration: const InputDecoration(hintText: '0', contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _repsCtrl,
              keyboardType: TextInputType.number,
              style: SLType.body(size: 14, color: SLColors.textBright),
              decoration: const InputDecoration(hintText: '0', contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
            ),
          ),
          SizedBox(
            width: 32,
            child: GestureDetector(
              onTap: () => _commit(!done),
              child: Icon(
                done ? Icons.check_circle : Icons.circle_outlined,
                color: done ? SLColors.success : SLColors.textDim,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExercisePicker extends StatefulWidget {
  final List<Map<String, String>> exercises;
  const _ExercisePicker({required this.exercises});

  @override
  State<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<_ExercisePicker> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.exercises
        .where((e) => e['name']!.toLowerCase().contains(_filter.toLowerCase()))
        .toList();

    return Dialog(
      backgroundColor: SLColors.panelMid,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SLText('SELECT EXERCISE', style: SLType.headline(size: 16, color: SLColors.textBright)),
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => setState(() => _filter = v),
              style: SLType.body(color: SLColors.textBright),
              decoration: InputDecoration(hintText: 'SEARCH...'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => Navigator.of(context).pop(filtered[i]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        SLText(filtered[i]['name']!, style: SLType.body(color: SLColors.textBright)),
                        const Spacer(),
                        SLText(filtered[i]['category']!, style: SLType.tag(size: 9, color: SLColors.glowDim)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
