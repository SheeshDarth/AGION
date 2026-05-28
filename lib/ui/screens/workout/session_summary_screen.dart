import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/sl/sl_colors.dart';
import '../../../core/sl/sl_type.dart';
import '../../../providers/workout_provider.dart';
import '../../system/system_bg.dart';
import '../../system/system_button.dart';
import '../../system/system_panel.dart';
import '../../system/system_text.dart';

class SessionSummaryScreen extends ConsumerWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(workoutProvider);
    if (sessions.isEmpty) { context.go('/home'); return const SizedBox(); }
    final session = sessions.first;

    return Scaffold(
      backgroundColor: SLColors.voidBg,
      body: SystemBg(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SLText('◈ SESSION COMPLETE', style: SLType.sysLabel(color: SLColors.success), align: TextAlign.center),
                const SizedBox(height: 16),
                SLText(session.title, style: SLType.headline(size: 22, color: SLColors.textBright), align: TextAlign.center),
                const SizedBox(height: 32),
                SystemPanel(
                  child: Column(
                    children: [
                      _row('DURATION', '${session.durationMinutes} min'),
                      _row('EXERCISES', '${session.exercises.length}'),
                      _row('TOTAL VOLUME', '${session.totalVolumeKg.round()} kg'),
                      _row('XP EARNED', '+${session.xpEarned} XP'),
                    ],
                  ),
                ),
                const Spacer(),
                SystemButton(
                  label: 'RETURN TO BASE',
                  onTap: () => context.go('/home'),
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SLText(label, style: SLType.sysLabel(size: 10, color: SLColors.textMid)),
        SLText(value, style: SLType.hudNum(size: 18, color: SLColors.glowCore)),
      ],
    ),
  );
}
