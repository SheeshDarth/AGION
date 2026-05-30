import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/sl/sl_colors.dart';
import '../../../core/sl/sl_type.dart';
import '../../system/system_bg.dart';
import '../../system/system_panel.dart';
import '../../system/system_text.dart';

// ═══════════════════════════════════════════════════════════════
// AGION — Terms of Service Screen
//
// Full ToS displayed in AGION SL aesthetic.
// Accessible from: Settings → Terms of Service
//                  Onboarding page 5 → "Terms of Service" link
// ═══════════════════════════════════════════════════════════════

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                      SLText('◈ TERMS OF SERVICE',
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
                    'EFFECTIVE DATE: MAY 27, 2026  ·  AGION — PERSONAL ASCENSION OS',
                    style: SLType.body(size: 11, color: SLColors.textDim),
                  ),
                ),
              ),

              // ── Section 1: Acceptance ────────────────────────
              _section('1. ACCEPTANCE OF TERMS', items: const [
                'By accessing or using AGION you agree to be bound by these Terms of Service.',
                'If you do not agree to these Terms, do not use the App.',
                'You must be at least 13 years of age to use AGION.',
                'Continued use of the App after any changes to these Terms constitutes acceptance of the revised Terms.',
              ], body: null),

              // ── Section 2: Description ───────────────────────
              _section('2. DESCRIPTION OF SERVICE', items: const [
                'AGION is a personal self-improvement application with gamification elements inspired by the Solo Leveling fiction. It is not affiliated with or endorsed by the original creators of Solo Leveling.',
                'The App provides tools for tracking fitness, nutrition, finances, and personal goals.',
                'AGION is provided for personal, non-commercial use only.',
                'An optional AI Coach feature requires a valid Google Gemini API key provided by you and is subject to Google\'s Terms of Service.',
                'The App operates primarily offline. Internet access is required only for the AI Coach, food search, and exercise search features.',
                'Features, availability, and content may change at any time without prior notice.',
              ], body: null),

              // ── Section 3: User Responsibilities ────────────
              _section('3. USER RESPONSIBILITIES', items: const [
                'You are solely responsible for all data you enter into the App.',
                'Do not enter sensitive personal information such as banking passwords, government ID numbers, or payment card details into any App field.',
                'You are responsible for maintaining the physical security of your device and the data stored on it.',
                'The App is for personal use only — commercial use, resale, or redistribution is prohibited.',
                'Any Gemini API key you provide must be your own and must comply with Google\'s Terms of Service.',
                'You agree not to attempt to reverse-engineer, decompile, or modify the App or its assets.',
                'You agree not to use the App for any unlawful purpose or in violation of any applicable laws.',
              ], body: null),

              // ── Section 4: Data & Privacy ────────────────────
              _section('4. DATA & PRIVACY', items: const [
                'Your use of AGION is also governed by the AGION Privacy Policy, accessible from Settings.',
                'All personal health, fitness, nutrition, and financial data is stored locally on your device only — no cloud storage, no remote backup.',
                'AI chat messages you send are processed by Google LLC under their Terms of Service and Privacy Policy.',
                'You retain full ownership of all data you enter into AGION.',
              ], body: null),

              // ── Section 5: Disclaimer ────────────────────────
              _section('5. DISCLAIMER OF WARRANTIES', items: const [
                'AGION is provided "as is" and "as available" without warranties of any kind, express or implied.',
                'The developer does not warrant that the App will be error-free, uninterrupted, or free of harmful components.',
                'Health, nutrition, and fitness information provided by the App is for informational and motivational purposes only. It does not constitute medical, dietary, or clinical advice.',
                'Financial tracking features are for personal budgeting only. They do not constitute financial, investment, or accounting advice.',
                'Always consult qualified professionals (doctors, dietitians, financial advisors) before making significant health or financial decisions.',
                'XP values, stat calculations, and gamification elements are fictional and for motivational purposes only.',
              ], body: null),

              // ── Section 6: Limitation of Liability ──────────
              _section('6. LIMITATION OF LIABILITY', items: const [
                'To the maximum extent permitted by applicable law, the developer shall not be liable for any indirect, incidental, special, consequential, or punitive damages.',
                'This includes, but is not limited to, loss of data, loss of profits, personal injury, or any damages resulting from your use or inability to use the App.',
                'Since AGION is provided free of charge, the developer\'s total aggregate liability for any claim arising from these Terms or your use of the App shall not exceed zero.',
                'Some jurisdictions do not allow the exclusion or limitation of certain warranties or liabilities — in such cases, the developer\'s liability is limited to the minimum extent permitted by law.',
              ], body: null),

              // ── Section 7: Governing Law ─────────────────────
              _section('7. GOVERNING LAW', items: const [
                'These Terms of Service are governed by and construed in accordance with the laws of India.',
                'Any disputes, claims, or controversies arising out of or relating to these Terms or your use of AGION shall be subject to the exclusive jurisdiction of the competent courts in India.',
                'If any provision of these Terms is found to be unenforceable, the remaining provisions will remain in full force and effect.',
              ], body: null),

              // ── Section 8: Changes to Terms ──────────────────
              _section('8. CHANGES TO TERMS', items: const [
                'The developer reserves the right to modify these Terms of Service at any time.',
                'Material changes will be noted in the App\'s update description on Google Play.',
                'The "Effective Date" at the top of this document will be updated to reflect the date of changes.',
                'Your continued use of the App after changes to these Terms constitutes your acceptance of the new Terms.',
                'If you do not agree to the revised Terms, you must stop using the App and may delete all your data via Settings → Erase All Data.',
              ], body: null),

              // ── Section 9: Contact ───────────────────────────
              _section('9. CONTACT', items: const [
                'Developer: Siddharth',
                'Email: siddharthprashoo@gmail.com',
                'App: AGION — Personal Ascension OS',
              ], body:
                'For questions, feedback, or concerns about these Terms of Service, '
                'contact the developer at the email address above.'),

              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

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
