import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../features/auth/auth_state.dart';
import '../widgets/glass_card.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AgionColors.backgroundDeep,
      body: Stack(
        children: [
          // Background gradient circles
          Positioned(
            top: -size.height * 0.15,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AgionColors.neonViolet.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.15,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AgionColors.neonCyan.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AgionSpacing.lg),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo / Title
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AgionColors.accentGradient.createShader(bounds),
                    child: const Text(
                      'AGION',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: AgionSpacing.sm),
                  const Text(
                    'PERSONAL ASCENSION SYSTEM',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AgionColors.mutedText,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: AgionSpacing.xl),

                  // Subtitle
                  const Text(
                    'Rise through the ranks.\nForge your discipline.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AgionColors.mutedText,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Error message
                  if (authState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AgionSpacing.md),
                      child: GlassCard(
                        padding: const EdgeInsets.all(AgionSpacing.md),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AgionColors.danger, size: 20),
                            const SizedBox(width: AgionSpacing.sm),
                            Expanded(
                              child: Text(
                                authState.error!,
                                style: const TextStyle(
                                  fontFamily: 'Rajdhani',
                                  fontSize: 14,
                                  color: AgionColors.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Google Sign-In Button
                  _buildButton(
                    onTap: authState.isLoading
                        ? null
                        : () => ref.read(authProvider.notifier).signInWithGoogle(),
                    icon: Icons.g_mobiledata_rounded,
                    label: 'SIGN IN WITH GOOGLE',
                    gradient: AgionColors.accentGradient,
                    textColor: AgionColors.backgroundDeep,
                  ),

                  const SizedBox(height: AgionSpacing.md),

                  // Guest Mode
                  _buildButton(
                    onTap: authState.isLoading
                        ? null
                        : () => ref.read(authProvider.notifier).continueAsGuest(),
                    icon: Icons.shield_outlined,
                    label: 'ENTER AS GUEST',
                    isOutlined: true,
                  ),

                  const SizedBox(height: AgionSpacing.md),

                  if (authState.isLoading)
                    const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AgionColors.neonCyan,
                      ),
                    ),

                  const SizedBox(height: AgionSpacing.sm),

                  // Guest disclaimer
                  const Text(
                    'Guest data is stored locally only.\nSign in to sync across devices.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 12,
                      color: AgionColors.mutedText,
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    VoidCallback? onTap,
    required IconData icon,
    required String label,
    LinearGradient? gradient,
    Color? textColor,
    bool isOutlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AgionSpacing.md),
        decoration: BoxDecoration(
          gradient: isOutlined ? null : gradient,
          borderRadius: AgionRadius.cardBR,
          border: isOutlined
              ? Border.all(color: AgionColors.neonCyan.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 24,
                color: textColor ?? AgionColors.neonCyan),
            const SizedBox(width: AgionSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor ?? AgionColors.neonCyan,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
