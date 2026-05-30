import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/sl/sl_colors.dart';
import '../../../core/sl/sl_type.dart';
import '../../system/system_bg.dart';
import '../../system/system_panel.dart';
import '../../system/system_text.dart';

// ═══════════════════════════════════════════════════════════════
// AGION — Privacy Policy Screen
//
// Full privacy policy displayed in AGION SL aesthetic.
// Accessible from: Settings → Privacy Policy
//                  Onboarding page 5 → "Privacy Policy" link
// ═══════════════════════════════════════════════════════════════

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SLColors.voidBg,
      body: SystemBg(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(Icons.arrow_back,
                            color: SLColors.textMid, size: 20),
                      ),
                      const SizedBox(width: 12),
                      SLText('◈ PRIVACY POLICY',
                          style: SLType.headline(size: 18)),
                    ],
                  ),
                ),
              ),

              // ── Effective date ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: SLText(
                    'EFFECTIVE DATE: MAY 27, 2026  ·  COM.AGION.AGION',
                    style: SLType.body(size: 11, color: SLColors.textDim),
                  ),
                ),
              ),

              // ── Section 1: Introduction ──────────────────────
              _section('1. INTRODUCTION', items: const [], body:
                'AGION ("the App", "we", "our") is a personal self-improvement application. '
                'This Privacy Policy explains how we collect, use, and protect your information '
                'when you use AGION.\n\n'
                'We take your privacy seriously. The vast majority of your data never leaves your device.'),

              // ── Section 2: Information We Collect ───────────
              _sectionWithSubs('2. INFORMATION WE COLLECT', subs: [
                const _Sub('INFORMATION YOU PROVIDE (STORED LOCALLY ON YOUR DEVICE)', [
                  'Identity: Your chosen "Hunter" name (not verified, can be a pseudonym)',
                  'Biometrics: Height, weight, age, gender (entered voluntarily for BMR/TDEE calculations)',
                  'Health & Fitness: Workout sessions, sets, reps, weight — entered manually by you',
                  'Nutrition: Food logs, calorie/macro data — entered manually by you',
                  'Finance: Income, expense, and savings entries you log manually',
                  'Quests & XP: Quest completions, experience points, streak data',
                  'App preferences: Notification settings, onboarding completion status',
                ]),
                const _Sub('INFORMATION TRANSMITTED TO THIRD-PARTY SERVICES', [
                  'AI Coach: Your typed chat message is sent to Google Gemini API to generate a response. No profile data is attached.',
                  'Food Search: Your food search query is sent to Open Food Facts (public database) to return nutrition data.',
                  'Exercise Search: Your exercise search query is sent to wger.de (public database) to return exercise data.',
                ]),
                const _Sub('INFORMATION WE DO NOT COLLECT', [
                  'No analytics, crash reporting, or telemetry (no Firebase, Sentry, or similar)',
                  'No advertising identifiers, device fingerprints, or location data',
                  'No camera, microphone, contacts, or calendar data',
                  'No biometric authentication data (fingerprint, face ID)',
                  'No network scanning or Wi-Fi data',
                ]),
              ]),

              // ── Section 3: How We Use ────────────────────────
              _section('3. HOW WE USE YOUR INFORMATION', items: const [
                'Biometric data → BMR and TDEE calculations displayed in Profile',
                'Workout logs → volume calculations and XP awards',
                'Nutrition data → daily macro tracking and compliance scoring',
                'Finance entries → income/expense summaries and savings rate',
                'XP and streaks → gamification levels, rank progression, quest rewards',
                'Notification preferences → scheduling of daily system alerts',
              ], body: null),

              // ── Section 4: Data Storage & Security ──────────
              _sectionWithSubs('4. DATA STORAGE & SECURITY', subs: [
                const _Sub('LOCAL STORAGE', [
                  'All personal data is stored via Hive (an encrypted key-value database) on your device only',
                  'No cloud sync, no remote backup, no account required',
                ]),
                const _Sub('NETWORK SECURITY', [
                  'HTTPS-only connections enforced via Android Network Security Config',
                  'No cleartext (HTTP) traffic permitted for any API calls',
                  'TLS/SSL encryption used for all third-party API requests',
                ]),
                const _Sub('RELEASE BUILD SECURITY', [
                  'Code minified and obfuscated using R8/ProGuard in release builds',
                  'No debug logging in release builds',
                  'Android backup to Google servers disabled (android:allowBackup="false")',
                ]),
              ]),

              // ── Section 5: Data Sharing ──────────────────────
              _section('5. DATA SHARING', items: const [
                'Google LLC (Gemini API) — only when you actively use the AI Coach feature',
                'Open Food Facts (openfoodfacts.org) — only when you search for food items',
                'wger.de — only when you search for exercises',
              ], body:
                'We do NOT sell, rent, or share your personal data with any third party '
                'for advertising or commercial purposes. The services above receive only your '
                'typed search queries — no profile, biometric, or financial data is ever transmitted.'),

              // ── Section 6: Your Rights ───────────────────────
              _section('6. YOUR RIGHTS & DATA DELETION', items: const [
                'Delete all your data: Go to Settings → Erase All Data. This permanently deletes all locally stored data from your device.',
                'App uninstall: Uninstalling the app removes all Hive database files and local data.',
                'Third-party data: For data processed by Google Gemini, refer to Google\'s Privacy Policy at policies.google.com/privacy',
              ], body:
                'Since we do not collect data on any servers, there is no "account" to '
                'delete and no server-side data to request or export.'),

              // ── Section 7: Children's Privacy ───────────────
              _section("7. CHILDREN'S PRIVACY", items: const [], body:
                'AGION is not directed at children under 13 years of age. The app does not '
                'knowingly collect personal information from children under 13. If you are a '
                'parent and believe your child has used this app, you can delete all data via '
                'Settings → Erase All Data or by uninstalling the app.'),

              // ── Section 8: Policy Changes ────────────────────
              _section('8. CHANGES TO THIS POLICY', items: const [], body:
                'If we make material changes to this Privacy Policy, we will update the '
                '"Effective Date" at the top of this document and note the changes in the '
                'app update description on Google Play. Your continued use of the app after '
                'such changes constitutes acceptance of the updated policy.'),

              // ── Section 9: Contact ───────────────────────────
              _section('9. CONTACT', items: const [
                'Developer: Siddharth',
                'Email: siddharthprashoo@gmail.com',
                'App: AGION — Personal Ascension OS',
              ], body: null),

              // ── Section 10: Third-Party Links ───────────────
              _section('10. THIRD-PARTY PRIVACY POLICIES', items: const [
                'Google: https://policies.google.com/privacy',
                'Open Food Facts: https://world.openfoodfacts.org/privacy',
                'wger: https://wger.de/en/software/privacy-policy',
              ], body:
                'AGION is a solo developer project. No personal data is collected for commercial purposes.'),

              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _Sub {
  final String title;
  final List<String> items;
  const _Sub(this.title, this.items);
}

Widget _section(String title, {required List<String> items, required String? body}) {
  return SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
    sliver: SliverToBoxAdapter(
      child: SystemPanel(
        glowIntensity: 0.15,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SLText(title,
                style: SLType.sysLabel(size: 9, color: SLColors.glowCore)),
            if (body != null) ...[
              const SizedBox(height: 10),
              SLText(body, style: SLType.body(size: 12, color: SLColors.textMid)),
            ],
            if (items.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...items.map((item) => _bullet(item)),
            ],
          ],
        ),
      ),
    ),
  );
}

Widget _sectionWithSubs(String title, {required List<_Sub> subs}) {
  return SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
    sliver: SliverToBoxAdapter(
      child: SystemPanel(
        glowIntensity: 0.15,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SLText(title,
                style: SLType.sysLabel(size: 9, color: SLColors.glowCore)),
            ...subs.map((sub) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                SLText(sub.title,
                    style: SLType.sysLabel(size: 8, color: SLColors.textMid)),
                const SizedBox(height: 6),
                ...sub.items.map((item) => _bullet(item)),
              ],
            )),
          ],
        ),
      ),
    ),
  );
}

Widget _bullet(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 5),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SLText('◈  ', style: SLType.body(size: 11, color: SLColors.glowDim)),
      Expanded(
          child: SLText(text, style: SLType.body(size: 12, color: SLColors.textMid))),
    ],
  ),
);
