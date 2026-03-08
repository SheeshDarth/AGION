# Agion — Personal Ascension System

> A futuristic, Solo-Leveling–style mobile-first personal ascension system built with Flutter.

## 🎮 Features (Sprint 0–1)

- **XP Ring HUD** — Animated gradient ring with level display and smooth 600ms easing
- **Quick Actions** — Tap to earn XP: Workout (+50), Water (+20), Steps (+30), Diet (+25), Focus (+30), Discipline (+20)
- **Level & Rank System** — Linear XP growth with ranks E → D → C → B → A → S
- **Streak Tracking** — Daily activity streak with visual indicator
- **Offline-First** — All data persisted locally with Hive; no network required
- **System Toasts** — Cinematic notification overlays for XP gains and level-ups

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (stable channel) |
| State | Riverpod (StateNotifier) |
| Local DB | Hive |
| Animations | CustomPainter + planned Rive |
| Fonts | Google Fonts (Orbitron, Rajdhani, Inter) |
| CI | GitHub Actions |

## 📋 Prerequisites

- **Flutter SDK** ≥ 3.10.x (stable channel)
- **Dart SDK** ≥ 3.10.x
- **Android Studio** or **VS Code** with Flutter extension
- **Android device/emulator** (API 21+)

## 🚀 Setup

```bash
# 1. Clone
git clone <repo-url> && cd AGION

# 2. Get dependencies
flutter pub get

# 3. Run on connected device / emulator
flutter run

# 4. Build release APK
flutter build apk --release
# APK at: build/app/outputs/flutter-apk/app-release.apk
```

## 🧪 Tests

```bash
# Run all tests
flutter test

# Run XP math unit tests only
flutter test test/player_xp_test.dart

# Run Home HUD widget tests only
flutter test test/home_screen_test.dart

# Static analysis
dart analyze lib/
```

## 📁 Architecture

```
lib/
├── main.dart                          # Entry point (Hive init, Riverpod)
├── app.dart                           # MaterialApp with dark theme
├── core/
│   ├── constants.dart                 # Colors, spacing, XP formulas, ranks
│   └── theme.dart                     # ThemeData (Orbitron/Rajdhani/Inter)
├── data/
│   ├── local/player_local_source.dart # Hive CRUD
│   └── repositories/player_repository.dart
├── domain/
│   └── models/
│       ├── player.dart                # Player model with XP math
│       └── player.g.dart             # Hive TypeAdapter
├── features/
│   └── player/player_state.dart       # Riverpod StateNotifier
└── presentation/
    ├── screens/home_screen.dart        # Home HUD
    └── widgets/
        ├── xp_ring_widget.dart         # Animated XP ring
        ├── quick_action_button.dart    # Glow press button
        ├── rank_badge_widget.dart      # Pulsing rank badge
        ├── glass_card.dart             # Glassmorphism container
        └── system_toast.dart           # SYSTEM toast overlay
```

## 🎨 Design System

| Token | Value |
|-------|-------|
| Background | `#020513` |
| Neon Cyan | `#00F6FF` |
| Neon Violet | `#7F5CFF` |
| Muted Text | `#8FA3C7` |
| Danger | `#FF5C6C` |
| Card Glass | `rgba(255,255,255,0.03)` |
| Spacing | 4 / 8 / 16 / 24 / 32 |
| Radius | 8 / 16 / 24 |

## 📊 XP System

- **Formula:** `xpForLevel(n) = 100 + (n-1) × 50`
- **Ranks:** E (L1) → D (L5) → C (L10) → B (L20) → A (L35) → S (L50)
- **Actions:** Workout +50, Steps +30, Focus +30, Diet +25, Water +20, Discipline +20

## 🔐 Privacy

- No ads. No data selling.
- Offline-first. Network only for optional sync.
- Minimal permissions (PHONE for OTP only when auth is added).
- Default telemetry OFF.

## 📅 Roadmap

- [ ] Sprint 2: Workout logger (Hevy-style) + Water tracker
- [ ] Sprint 3: Firebase Auth (Phone OTP) + Firestore sync
- [ ] Sprint 4: Steps + Google Fit integration
- [ ] Sprint 5: Rive animations + rank-up cinematics + release APK

## License

Private — not for redistribution.
