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

  static const _goalsList = [
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
                    goals: _goals, allGoals: _goalsList,
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
            decoration: const InputDecoration(
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
          // Fixed-height goal pills — same size on every screen width
          GridView.custom(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 64, // fixed px — no aspect ratio scaling
            ),
            childrenDelegate: SliverChildListDelegate(
              allGoals.map((g) {
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

// ─── Page 5: Confirm (Stateful — holds legal consent state) ──────────────────

class _PageConfirm extends StatefulWidget {
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
  State<_PageConfirm> createState() => _PageConfirmState();
}

class _PageConfirmState extends State<_PageConfirm> {
  bool _acceptedPrivacy = false;
  bool _acceptedTerms   = false;

  bool get _canBegin => _acceptedPrivacy && _acceptedTerms;

  @override
  Widget build(BuildContext context) {
    final bmr    = BodyEngine.bmr(weightKg: widget.weight, heightCm: widget.height,
                                  age: widget.age, gender: widget.gender);
    final tdee   = BodyEngine.tdee(bmr: bmr, activityLevel: widget.activity);
    final macros = BodyEngine.macroTargets(tdee: tdee, goals: widget.goals.toList());

    return Padding(
      padding: const EdgeInsets.all(24),
      // SingleChildScrollView prevents overflow on small screens with the legal rows
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            SLText('SYSTEM CALIBRATION COMPLETE',
              style: SLType.headline(size: 20), align: TextAlign.center),
            const SizedBox(height: 24),

            // ── Stats panel ──────────────────────────────────────
            SystemPanel(
              child: Column(
                children: [
                  _row('HUNTER', widget.name.isEmpty ? 'HUNTER' : widget.name.toUpperCase()),
                  _row('BIOMETRICS', '${widget.height}cm • ${widget.weight}kg • ${widget.age} y'),
                  _row('BMR', '${bmr.round()} kcal'),
                  _row('TDEE', '${tdee.round()} kcal'),
                  _row('DAILY TARGET', '${macros['calories']!.round()} kcal'),
                  _row('PROTEIN', '${macros['proteinG']!.round()}g'),
                  _row('CARBS', '${macros['carbsG']!.round()}g'),
                  _row('FAT', '${macros['fatG']!.round()}g'),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Legal consent checkboxes ─────────────────────────
            _LegalCheckbox(
              checked: _acceptedPrivacy,
              onChanged: (v) => setState(() => _acceptedPrivacy = v),
              label: 'I have read and accept the ',
              linkText: 'Privacy Policy',
              onLinkTap: () => context.push('/legal/privacy'),
            ),
            const SizedBox(height: 12),
            _LegalCheckbox(
              checked: _acceptedTerms,
              onChanged: (v) => setState(() => _acceptedTerms = v),
              label: 'I agree to the ',
              linkText: 'Terms of Service',
              onLinkTap: () => context.push('/legal/terms'),
            ),

            const SizedBox(height: 24),

            // ── BEGIN ASCENSION — disabled until both checked ────
            SystemButton(
              label: 'BEGIN ASCENSION',
              variant: _canBegin ? SystemButtonVariant.boss : SystemButtonVariant.ghost,
              onTap: _canBegin ? widget.onBegin : null,
              color: _canBegin ? null : SLColors.textDim,
              width: double.infinity,
            ),
          ],
        ),
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

// ─── SL-styled legal consent checkbox ────────────────────────────────────────

class _LegalCheckbox extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;
  final String label;      // e.g. "I accept the "
  final String linkText;   // e.g. "Privacy Policy"
  final VoidCallback onLinkTap;

  const _LegalCheckbox({
    required this.checked,
    required this.onChanged,
    required this.label,
    required this.linkText,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Square SL-styled checkbox (NO rounded corners — design rule)
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: checked
                  ? SLColors.glowCore.withValues(alpha: 0.15)
                  : Colors.transparent,
              border: Border.all(
                color: checked ? SLColors.glowCore : SLColors.textDim,
                width: 1.5,
              ),
              borderRadius: BorderRadius.zero,
              boxShadow: checked
                  ? [BoxShadow(
                      color: SLColors.glowCore.withValues(alpha: 0.40),
                      blurRadius: 8,
                      spreadRadius: -2,
                    )]
                  : null,
            ),
            child: checked
                ? const Icon(Icons.check, size: 13, color: SLColors.glowCore)
                : null,
          ),
          const SizedBox(width: 12),
          // Label text + tappable link
          Expanded(
            child: Row(
              children: [
                SLText(label,
                    style: SLType.body(size: 12, color: SLColors.textMid)),
                GestureDetector(
                  onTap: () {
                    // Navigate without toggling checkbox
                    onLinkTap();
                  },
                  // Absorb the tap so it doesn't bubble up to the outer GestureDetector
                  behavior: HitTestBehavior.opaque,
                  child: SLText(
                    linkText,
                    style: SLType.body(size: 12, color: SLColors.glowCore),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
