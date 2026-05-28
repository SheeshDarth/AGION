import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/sl/sl_colors.dart';
import '../../../core/sl/sl_type.dart';
import '../../../providers/ai_provider.dart';
import '../../system/system_bg.dart';
import '../../system/system_button.dart';
import '../../system/system_panel.dart';
import '../../system/system_text.dart';

class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  static const _presets = [
    'GENERATE MY QUESTS',
    'OPTIMIZE MY WORKOUT',
    'ANALYZE MY NUTRITION',
    'REVIEW MY FINANCES',
    'GIVE ME A 4-WEEK PLAN',
    'HOW DO I LEVEL UP FASTER?',
  ];

  @override
  void dispose() { _ctrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  Future<void> _send([String? preset]) async {
    final msg = preset ?? _ctrl.text.trim();
    if (msg.isEmpty) return;
    _ctrl.clear();
    await ref.read(aiChatProvider.notifier).send(msg);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiChatProvider);
    final notifier = ref.read(aiChatProvider.notifier);

    return Scaffold(
      backgroundColor: SLColors.voidBg,
      body: SystemBg(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(onTap: () => context.pop(),
                      child: Icon(Icons.arrow_back, color: SLColors.textMid, size: 20)),
                    const SizedBox(width: 12),
                    SLText('◈ AI ASCENSION GUIDE', style: SLType.headline(size: 16)),
                  ],
                ),
              ),
              // Presets
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _presets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _send(_presets[i]),
                    child: SystemPanel(
                      glowIntensity: 0.2,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: SLText(_presets[i], style: SLType.sysLabel(size: 8, color: SLColors.textMid)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Chat
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: messages.length + (notifier.isLoading ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == messages.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SystemPanel(
                            glowIntensity: 0.2,
                            padding: const EdgeInsets.all(12),
                            child: SLText(
                              '◈ SYSTEM: ANALYZING...',
                              style: SLType.body(size: 12, color: SLColors.textMid),
                            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1000.ms, color: SLColors.glowCore.withOpacity(0.2)),
                          ),
                        ),
                      );
                    }
                    final msg = messages[i];
                    return Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SystemPanel(
                          glowColor: msg.isUser ? SLColors.glowDim : SLColors.textDim,
                          glowIntensity: msg.isUser ? 0.5 : 0.15,
                          padding: const EdgeInsets.all(12),
                          child: SLText(
                            msg.text,
                            style: SLType.body(size: 13, color: msg.isUser ? SLColors.textBright : SLColors.textMid),
                          ),
                        ),
                      ),
                    ).animate().fade(duration: 200.ms).slideY(begin: 0.1, end: 0, duration: 200.ms);
                  },
                ),
              ),
              // Input
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        style: SLType.body(color: SLColors.textBright),
                        maxLines: null,
                        decoration: InputDecoration(hintText: 'QUERY THE SYSTEM...'),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SystemButton(
                      label: 'SEND',
                      icon: Icons.send,
                      isLoading: notifier.isLoading,
                      onTap: _send,
                    ),
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
