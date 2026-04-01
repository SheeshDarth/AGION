import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../features/auth/auth_state.dart';
import '../../features/player/player_state.dart';
import '../../features/sync/sync_state.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final player = ref.watch(playerProvider);
    final sync = ref.watch(syncProvider);

    return Scaffold(
      backgroundColor: AgionColors.backgroundDeep,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AgionSpacing.md),
          child: Column(
            children: [
              // Header
              ShaderMask(
                shaderCallback: (bounds) =>
                    AgionColors.accentGradient.createShader(bounds),
                child: const Text(
                  'PROFILE',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: AgionSpacing.xl),

              // Avatar + name
              CircleAvatar(
                radius: 40,
                backgroundColor: AgionColors.neonViolet.withValues(alpha: 0.2),
                backgroundImage: auth.photoUrl != null
                    ? NetworkImage(auth.photoUrl!)
                    : null,
                child: auth.photoUrl == null
                    ? const Text('🗡️', style: TextStyle(fontSize: 32))
                    : null,
              ),
              const SizedBox(height: AgionSpacing.md),
              Text(
                auth.displayName ?? 'Hunter',
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AgionColors.white,
                  letterSpacing: 1,
                ),
              ),
              if (auth.email != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    auth.email!,
                    style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 14,
                      color: AgionColors.mutedText,
                    ),
                  ),
                ),

              const SizedBox(height: AgionSpacing.lg),

              // Stats card
              GlassCard(
                showGlow: true,
                padding: const EdgeInsets.all(AgionSpacing.md),
                child: Column(
                  children: [
                    _statRow('Rank', '${player.rank}-Rank'),
                    _statRow('Level', 'LV ${player.level}'),
                    _statRow('Title', player.title),
                    _statRow('Streak', '${player.streak} days'),
                    _statRow('Mode', auth.isGuest ? 'Guest (Local)' : 'Cloud Sync'),
                  ],
                ),
              ),

              const SizedBox(height: AgionSpacing.md),

              // Sync status
              if (!auth.isGuest)
                GlassCard(
                  padding: const EdgeInsets.all(AgionSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _syncIcon(sync.status),
                            size: 18,
                            color: _syncColor(sync.status),
                          ),
                          const SizedBox(width: AgionSpacing.sm),
                          Text(
                            _syncLabel(sync.status),
                            style: TextStyle(
                              fontFamily: 'Rajdhani',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _syncColor(sync.status),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () =>
                            ref.read(syncProvider.notifier).syncAll(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AgionSpacing.md,
                            vertical: AgionSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AgionColors.neonCyan.withValues(alpha: 0.3),
                            ),
                            borderRadius: AgionRadius.smallBR,
                          ),
                          child: const Text(
                            'SYNC',
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
                    ],
                  ),
                ),

              const SizedBox(height: AgionSpacing.xl),

              // Sign out button
              GestureDetector(
                onTap: () => ref.read(authProvider.notifier).signOut(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AgionSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AgionColors.danger.withValues(alpha: 0.5),
                    ),
                    borderRadius: AgionRadius.cardBR,
                  ),
                  child: const Center(
                    child: Text(
                      'SIGN OUT',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AgionColors.danger,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AgionSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 15,
              color: AgionColors.mutedText,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AgionColors.neonCyan,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _syncIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Icons.cloud_off;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.synced:
        return Icons.cloud_done;
      case SyncStatus.error:
        return Icons.error_outline;
      case SyncStatus.offline:
        return Icons.wifi_off;
    }
  }

  Color _syncColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return AgionColors.neonCyan;
      case SyncStatus.error:
        return AgionColors.danger;
      case SyncStatus.offline:
        return AgionColors.mutedText;
      default:
        return AgionColors.mutedText;
    }
  }

  String _syncLabel(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Not synced';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.error:
        return 'Sync failed';
      case SyncStatus.offline:
        return 'Offline';
    }
  }
}
