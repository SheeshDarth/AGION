import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/sl/sl_colors.dart';
import '../../../core/sl/sl_type.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/quest_provider.dart';
import '../../../providers/workout_provider.dart';
import '../../../providers/nutrition_provider.dart';
import '../../../providers/finance_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../system/system_bg.dart';
import '../../system/system_panel.dart';
import '../../system/system_text.dart';
import '../../system/system_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
    if (value) {
      await NotificationService.init();
    }
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SLColors.panelMid,
        title: SLText('◈ SYSTEM WARNING', style: SLType.headline(size: 16, color: SLColors.danger)),
        content: SLText(
          'This will delete ALL data — player profile, workouts, nutrition, finance, and quests. This action is permanent.',
          style: SLType.body(color: SLColors.textMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCEL', style: SLType.sysLabel(color: SLColors.textMid)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('ERASE ALL', style: SLType.sysLabel(color: SLColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _eraseAll();
  }

  Future<void> _eraseAll() async {
    await ref.read(questProvider.notifier).clearAll();
    await ref.read(workoutProvider.notifier).clearAll();
    await ref.read(nutritionProvider.notifier).clearAll();
    await ref.read(financeProvider.notifier).clearAll();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);

    return Scaffold(
      backgroundColor: SLColors.voidBg,
      body: SystemBg(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Icon(Icons.arrow_back, color: SLColors.textMid, size: 20),
                      ),
                      const SizedBox(width: 12),
                      SLText('◈ SYSTEM SETTINGS', style: SLType.headline(size: 18)),
                    ],
                  ),
                ),
              ),

              // ── Account ──────────────────────────────────────
              _sectionHeader('HUNTER ACCOUNT'),
              if (player != null)
                _settingsTile(
                  title: player.name.toUpperCase(),
                  subtitle: 'Level ${_level(player.totalXP)} · ${player.totalXP} Total XP',
                  leading: Icon(Icons.person_outline, color: SLColors.glowCore, size: 20),
                ),

              // ── Notifications ─────────────────────────────────
              _sectionHeader('NOTIFICATIONS'),
              _switchTile(
                title: 'Daily System Alerts',
                subtitle: 'Morning briefing, combat reminders, hydration pings',
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),

              // ── Data ─────────────────────────────────────────
              _sectionHeader('DATA & PRIVACY'),
              _settingsTile(
                title: 'Privacy Policy',
                subtitle: 'How AGION handles your data',
                leading: Icon(Icons.privacy_tip_outlined, color: SLColors.textMid, size: 20),
                onTap: () => _showPrivacyPolicy(),
              ),
              _settingsTile(
                title: 'All Data Stored Locally',
                subtitle: 'Your data never leaves your device (except AI queries)',
                leading: Icon(Icons.lock_outline, color: SLColors.success, size: 20),
              ),

              // ── About ─────────────────────────────────────────
              _sectionHeader('ABOUT'),
              _settingsTile(
                title: 'AGION',
                subtitle: 'Version 1.0.0  ·  Personal Ascension OS',
                leading: Icon(Icons.info_outline, color: SLColors.textMid, size: 20),
              ),
              _settingsTile(
                title: 'AI Provider',
                subtitle: 'Google Gemini 1.5 Flash (requires API key)',
                leading: Icon(Icons.all_inclusive_rounded, color: SLColors.textMid, size: 20),
              ),

              // ── Danger Zone ───────────────────────────────────
              _sectionHeader('DANGER ZONE'),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                sliver: SliverToBoxAdapter(
                  child: SystemButton(
                    label: '◈ ERASE ALL DATA',
                    variant: SystemButtonVariant.danger,
                    icon: Icons.delete_outline,
                    onTap: _confirmReset,
                    width: double.infinity,
                  ),
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          ),
        ),
      ),
    );
  }

  int _level(int totalXP) {
    int level = 1, remaining = totalXP;
    while (remaining >= 100 + (level - 1) * 50) {
      remaining -= 100 + (level - 1) * 50;
      level++;
    }
    return level;
  }

  Widget _sectionHeader(String label) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
    sliver: SliverToBoxAdapter(
      child: SLText(label, style: SLType.sysLabel(size: 9, color: SLColors.glowCore)),
    ),
  );

  Widget _settingsTile({
    required String title,
    required String subtitle,
    Widget? leading,
    VoidCallback? onTap,
  }) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    sliver: SliverToBoxAdapter(
      child: SystemPanel(
        onTap: onTap,
        glowIntensity: onTap != null ? 0.25 : 0.1,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 14)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SLText(title, style: SLType.body(size: 14, color: SLColors.textBright)),
                  const SizedBox(height: 2),
                  SLText(subtitle, style: SLType.body(size: 11, color: SLColors.textMid)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: SLColors.textDim, size: 18),
          ],
        ),
      ),
    ),
  );

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    sliver: SliverToBoxAdapter(
      child: SystemPanel(
        glowIntensity: 0.2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SLText(title, style: SLType.body(size: 14, color: SLColors.textBright)),
                  const SizedBox(height: 2),
                  SLText(subtitle, style: SLType.body(size: 11, color: SLColors.textMid)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: SLColors.glowCore,
              activeTrackColor: SLColors.glowDim,
              inactiveTrackColor: SLColors.textDim,
            ),
          ],
        ),
      ),
    ),
  );

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: SLColors.panelMid,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SLText('AGION PRIVACY POLICY', style: SLType.headline(size: 16, color: SLColors.glowCore)),
              const SizedBox(height: 16),
              _privacySection('DATA COLLECTED', [
                'Health metrics you enter (weight, height, workouts)',
                'Nutrition logs you create',
                'Financial entries you log',
                'App usage data stored locally on your device',
              ]),
              _privacySection('DATA STORAGE', [
                'All personal data is stored locally on your device only',
                'No account required — no cloud sync',
                'Data is not transmitted to AGION servers',
              ]),
              _privacySection('THIRD-PARTY SERVICES', [
                'Google Gemini AI: AI chat messages are sent to Google\'s API when you use the AI Coach feature. Subject to Google\'s Privacy Policy.',
                'Open Food Facts: Food search queries are sent to openfoodfacts.org (public database).',
                'wger Exercise API: Exercise search queries are sent to wger.de (public database).',
              ]),
              _privacySection('YOUR RIGHTS', [
                'Delete all your data at any time via Settings → Erase All Data',
                'The app works fully offline (AI features require internet)',
              ]),
              _privacySection('CONTACT', [
                'For privacy inquiries, contact the developer.',
              ]),
              const SizedBox(height: 16),
              SystemButton(
                label: 'CLOSE',
                onTap: () => Navigator.pop(context),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _privacySection(String title, List<String> items) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SLText(title, style: SLType.sysLabel(size: 9, color: SLColors.textMid)),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SLText('◈ ', style: SLType.body(size: 12, color: SLColors.glowDim)),
              Expanded(child: SLText(item, style: SLType.body(size: 12, color: SLColors.textMid))),
            ],
          ),
        )),
      ],
    ),
  );
}
