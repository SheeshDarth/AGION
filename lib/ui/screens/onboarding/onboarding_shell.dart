import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/sl/sl_colors.dart';
import '../../../core/sl/sl_type.dart';
import '../../../data/models/player_model.dart';
import '../../../providers/player_provider.dart';
import '../../../ui/system/system_bg.dart';
import '../../../ui/system/system_button.dart';
import '../../../ui/system/system_panel.dart';
import '../../../ui/system/system_text.dart';
import '../../../core/engine/body_engine.dart';

class OnboardingShell extends ConsumerStatefulWidget {
  const OnboardingShell({super.key});

  @override
  ConsumerState<OnboardingShell> createState() => _OnboardingShellState();
}

class _OnboardingShellState extends ConsumerState<OnboardingShell> {
  final _controller = PageController();
  int _page = 0;

  // Collected data
  String _name = '';
  int _age = 20;
  double _height = 170;
  double _weight = 70;
  String _gender = 'male';
  String _activity = 'moderate';
  final Set<String> _goals = {};

  static const _goals_list = [
    'PHYSICAL DOMINANCE',
    'BODY RECOMPOSITION',
    'ENDURANCE',
    'MENTAL ASCENSION',
    'FINANCIAL DISCIPLINE',
    'TOTAL ASCENSION',
  ];

  static const _activities = [
    ('DORMANT',       'sedentary'),
    ('LIGHTLY ACTIVE', 'light'),
    ('MODERATE WARRIOR', 'moderate'),
    ('ELITE FIGHTER', 'active'),
    ('TRANSCENDENT',  'elite'),
  ];

  void _next() {
    if (_page < 4) {
      _controller.nextPage(duration: 300.ms, curve: Curves.easeOut);
      setState(() => _page++);
    }
  }

  void _prev() {
    if (_page > 0) {
      _controller.previousPage(duration: 300.ms, curve: Curves.easeOut);
      setState(() => _page--);
    }
  }

  Future<void> _complete() async {
    final player = PlayerModel()
      ..id = const Uuid().v4()
      ..name = _name.isEmpty ? 'HUNTER' : _name
      ..totalXP = 0
      ..streakDays = 0
      ..heightCm = _height
      ..weightKg = _weight
      ..age = _age
      ..gender = _gender
      ..activityLevel = _activity
      ..goals = _goals.toList()
      ..createdDate = DateTime.now().toIso8601String().substring(0, 10);

    await ref.read(playerProvider.notifier).createPlayer(player);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);

    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SLColors.voidBg,
      body: SystemBg(
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    if (_page > 0)
                      GestureDetector(
                        onTap: _prev,
                        child: SLText('← BACK', style: SLType.sysLabel(color: SLColors.textMid)),
                      ),
                    const Spacer(),
                    // Page indicators
                    Row(
                      children: List.generate(5, (i) => Container(
                        width: i == _page ? 16 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i == _page ? SLColors.glowCore : SLColors.textDim,
                        ),
                      )),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _PageName(onChanged: (v) => setState(() => _name = v), onNext: _next),
                  _PageBody(
                    age: _age, height: _height, weight: _weight, gender: _gender,
                    onChanged: (age, height, weight, gender) => setState(() {
                      _age = age; _height = height; _weight = weight; _gender = gender;
                    }),
                    onNext: _next,
                  ),
                  _PageGoals(
                    goals: _goals, allGoals: _goals_list,
                    onToggle: (g) => setState(() => _goals.contains(g) ? _goals.remove(g) : _goals.add(g)),
                    onNext: _next,
                  ),
                  _PageActivity(
                    activities: _activities, selected: _activity,
                    onSelect: (a) => setState(() => _activity = a),
                    onNext: _next,
                  ),
                  _PageConfirm(
                    name: _name, age: _age, height: _height, weight: _weight,
                    gender: _gender, activity: _activity, goals: _goals,
                    onBegin: _complete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 1: Name ─────────────────────────────────────────────────────────

class _PageName extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;
  const _PageName({required this.onChanged, required this.onNext});

  @override
  State<_PageName> createState() => _PageNameState();
}

class _PageNameState extends State<_PageName> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SLText('ENTER YOUR NAME, HUNTER.', style: SLType.sysLabel(color: SLColors.textMid), align: TextAlign.center),
          const SizedBox(height: 8),
          SLText('DESIGNATION', style: SLType.headline(size: 22, color: SLColors.textBright), align: TextAlign.center),
          const SizedBox(height: 32),
          TextField(
            controller: _ctrl,
            style: SLType.headline(size: 24, color: SLColors.textBright),
            textAlign: TextAlign.center,
            maxLength: 20,
            decoration: InputDecoration(
              hintText: 'HUNTER',
              counterText: '',
            ),
            onChanged: widget.onChanged,
          ),
          const SizedBox(height: 48),
          SystemButton(label: 'INITIALIZE', onTap: widget.onNext, width: 200),
        ],
      ),
    );
  }
}

// ─── Page 2: Biometrics ───────────────────────────────────────────────────

class _PageBody extends StatefulWidget {
  final int age;
  final double height, weight;
  final String gender;
  final void Function(int, double, double, String) onChanged;
  final VoidCallback onNext;
  const _PageBody({required this.age, required this.height, required this.weight,
    required this.gender, required this.onChanged, required this.onNext});

  @override
  State<_PageBody> createState() => _PageBodyState();
}

class _PageBodyState extends State<_PageBody> {
  late int _age;
  late double _height, _weight;
  late String _gender;

  @override
  void initState() {
    super.initState();
    _age = widget.age; _height = widget.height;
    _weight = widget.weight; _gender = widget.gender;
  }

  void _update() => widget.onChanged(_age, _height, _weight, _gender);

  Widget _numField(String label, String value, VoidCallback dec, VoidCallback inc) {
    return SystemPanel(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SLText(label, style: SLType.sysLabel(size: 9, color: SLColors.textMid)),
          Row(children: [
            GestureDetector(onTap: dec,
              child: Container(padding: const EdgeInsets.all(8),
                child: SLText('−', style: SLType.hudNum(size: 16, color: SLColors.glowCore)))),
            SLText(value, style: SLType.hudNum(size: 18, color: SLColors.textBright)),
            GestureDetector(onTap: inc,
              child: Container(padding: const EdgeInsets.all(8),
                child: SLText('+', style: SLType.hudNum(size: 16, color: SLColors.glowCore)))),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SLText('BIOMETRIC SCAN', style: SLType.headline(size: 24), align: TextAlign.center),
          const SizedBox(height: 32),
          _numField('AGE', '$_age',
            () { setState(() { _age = (_age - 1).clamp(10, 100); _update(); }); },
            () { setState(() { _age = (_age + 1).clamp(10, 100); _update(); }); }),
          const SizedBox(height: 12),
          _numField('HEIGHT (CM)', '$_height',
            () { setState(() { _height = (_height - 1).clamp(100, 250); _update(); }); },
            () { setState(() { _height = (_height + 1).clamp(100, 250); _update(); }); }),
          const SizedBox(height: 12),
          _numField('WEIGHT (KG)', '$_weight',
            () { setState(() { _weight = (_weight - 0.5).clamp(30, 300); _update(); }); },
            () { setState(() { _weight = (_weight + 0.5).clamp(30, 300); _update(); }); }),
          const SizedBox(height: 12),
          SystemPanel(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SLText('GENDER', style: SLType.sysLabel(size: 9, color: SLColors.textMid)),
                Row(children: ['male', 'female'].map((g) => GestureDetector(
                  onTap: () { setState(() { _gender = g; _update(); }); },
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _gender == g ? SLColors.glowCore : SLColors.textDim,
                        width: 1,
                      ),
                    ),
                    child: SLText(g.toUpperCase(),
                      style: SLType.sysLabel(size: 9, color: _gender == g ? SLColors.glowCore : SLColors.textMid)),
                  ),
                )).toList()),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SystemButton(label: 'CONTINUE', onTap: widget.onNext, width: 200),
        ],
      ),
    );
  }
}

// ─── Page 3: Goals ────────────────────────────────────────────────────────

class _PageGoals extends StatelessWidget {
  final Set<String> goals;
  final List<String> allGoals;
  final ValueChanged<String> onToggle;
  final VoidCallback onNext;

  const _PageGoals({required this.goals, required this.allGoals,
    required this.onToggle, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SLText('DEFINE YOUR OBJECTIVE', style: SLType.headline(size: 22), align: TextAlign.center),
          const SizedBox(height: 8),
          SLText('SELECT ALL THAT APPLY', style: SLType.sysLabel(color: SLColors.textMid), align: TextAlign.center),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: allGoals.map((g) {
                final selected = goals.contains(g);
                return SystemPanel(
                  glowColor: selected ? SLColors.glowCore : SLColors.textDim,
                  glowIntensity: selected ? 0.8 : 0.1,
                  onTap: () => onToggle(g),
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: SLText(g, style: SLType.sysLabel(
                      size: 9,
                      color: selected ? SLColors.glowCore : SLColors.textMid,
                    ), align: TextAlign.center),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          SystemButton(label: 'CONTINUE', onTap: onNext, width: 200),
        ],
      ),
    );
  }
}

// ─── Page 4: Activity ────────────────────────────────────────────────────

class _PageActivity extends StatelessWidget {
  final List<(String, String)> activities;
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  const _PageActivity({required this.activities, required this.selected,
    required this.onSelect, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SLText('COMBAT CLASSIFICATION', style: SLType.headline(size: 22), align: TextAlign.center),
          const SizedBox(height: 24),
          ...activities.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SystemPanel(
              glowColor: selected == a.$2 ? SLColors.glowCore : SLColors.textDim,
              glowIntensity: selected == a.$2 ? 0.8 : 0.1,
              onTap: () => onSelect(a.$2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  SLText(a.$1, style: SLType.sysLabel(
                    size: 11,
                    color: selected == a.$2 ? SLColors.glowCore : SLColors.textMid,
                  )),
                  const Spacer(),
                  if (selected == a.$2)
                    SLText('◈', style: SLType.sysLabel(color: SLColors.glowCore)),
                ],
              ),
            ),
          )),
          const SizedBox(height: 24),
          SystemButton(label: 'CONTINUE', onTap: onNext, width: 200),
        ],
      ),
    );
  }
}

// ─── Page 5: Confirm ─────────────────────────────────────────────────────

class _PageConfirm extends StatelessWidget {
  final String name, gender, activity;
  final int age;
  final double height, weight;
  final Set<String> goals;
  final VoidCallback onBegin;

  const _PageConfirm({
    required this.name, required this.age, required this.height,
    required this.weight, required this.gender, required this.activity,
    required this.goals, required this.onBegin,
  });

  @override
  Widget build(BuildContext context) {
    final bmr = BodyEngine.bmr(weightKg: weight, heightCm: height, age: age, gender: gender);
    final tdee = BodyEngine.tdee(bmr: bmr, activityLevel: activity);
    final macros = BodyEngine.macroTargets(tdee: tdee, goals: goals.toList());

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SLText('SYSTEM CALIBRATION COMPLETE',
            style: SLType.headline(size: 20), align: TextAlign.center),
          const SizedBox(height: 24),
          SystemPanel(
            child: Column(
              children: [
                _row('HUNTER', name.isEmpty ? 'HUNTER' : name.toUpperCase()),
                _row('BIOMETRICS', '${height}cm • ${weight}kg • $age y'),
                _row('BMR', '${bmr.round()} kcal'),
                _row('TDEE', '${tdee.round()} kcal'),
                _row('DAILY TARGET', '${macros['calories']!.round()} kcal'),
                _row('PROTEIN', '${macros['proteinG']!.round()}g'),
                _row('CARBS', '${macros['carbsG']!.round()}g'),
                _row('FAT', '${macros['fatG']!.round()}g'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SystemButton(label: 'BEGIN ASCENSION', variant: SystemButtonVariant.boss, onTap: onBegin, width: double.infinity),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SLText(label, style: SLType.sysLabel(size: 9, color: SLColors.textMid)),
          SLText(value, style: SLType.body(size: 13, color: SLColors.textBright)),
        ],
      ),
    );
  }
}
