# AGION — Project Context & Living Documentation

> **Update this file after every development session.**  
> It is the memory of the project across Claude conversations.

---

## Identity

**AGION** is a real-life Solo Leveling System mobile app for Android.  
The user is "Sung Jin-Woo" — every screen must feel like a STATUS WINDOW
projected by a supernatural system. It must NOT look like a mobile app.

- **Package name:** `agion` / `com.agion.app`
- **Version:** 1.0.0+1
- **Min SDK:** Android 24 (Flutter 3.x)
- **GitHub:** https://github.com/SheeshDarth/AGION

---

## Tech Stack

| Layer | Library | Version |
|---|---|---|
| State management | flutter_riverpod | ^2.5.1 |
| Local storage | hive + hive_flutter | ^2.2.3 / ^1.1.0 |
| Navigation | go_router | ^14.2.0 |
| Animations | flutter_animate | ^4.5.0 |
| Charts | fl_chart | ^0.68.0 |
| Fonts | google_fonts | ^6.2.1 |
| AI | Gemini API (gemini_client.dart) | — |

---

## Architecture

```
lib/
├── main.dart                  ← Hive init, ProviderScope, app bootstrap
├── main_demo.dart             ← Demo mode with seeded data (port 8081)
├── app.dart                   ← MaterialApp.router wrapping GoRouter
│
├── core/
│   ├── sl/                    ← CANONICAL DESIGN SYSTEM (read-only sources of truth)
│   │   ├── sl_colors.dart     ← All hex values — no other hex exists
│   │   ├── sl_type.dart       ← All TextStyles — no inline TextStyle elsewhere
│   │   └── sl_theme.dart      ← ThemeData for MaterialApp
│   ├── engine/
│   │   ├── xp_engine.dart     ← Level/rank/stat derivation from XP
│   │   └── body_engine.dart   ← BMI, calorie, activity calculations
│   ├── router/
│   │   └── app_router.dart    ← GoRouter routes + shell
│   └── services/
│       └── device_tier.dart   ← Tier.low/mid/high for perf scaling
│
├── data/
│   ├── models/                ← Hive TypeAdapters (typeId 0-5)
│   │   ├── player_model.dart  ← PlayerModel (typeId 0)
│   │   ├── workout_model.dart ← WorkoutModel (typeId 1)
│   │   ├── nutrition_model.dart
│   │   ├── finance_model.dart
│   │   └── quest_model.dart
│   └── remote/
│       ├── gemini_client.dart
│       ├── food_api_client.dart
│       └── exercise_api_client.dart
│
├── providers/
│   ├── player_provider.dart   ← StateNotifierProvider<PlayerNotifier, PlayerModel?>
│   ├── quest_provider.dart    ← StateNotifierProvider<QuestNotifier, List<QuestModel>>
│   ├── workout_provider.dart
│   ├── nutrition_provider.dart
│   └── finance_provider.dart
│
└── ui/
    ├── system/                ← Component primitives (ALWAYS use these, never raw Material)
    │   ├── sl_bg.dart         ← Energy particle network background (NEW — reference spec)
    │   ├── sl_panel.dart      ← Corner-bracket panel (NEW — reference spec)
    │   ├── sl_bar.dart        ← HP/MP/XP progress bars (NEW — reference spec)
    │   ├── sl_stat_row.dart   ← Icon + LABEL: VALUE stat rows (NEW — reference spec)
    │   ├── sl_window.dart     ← System notification overlay (NEW — reference spec)
    │   ├── system_bg.dart     ← Delegate → SLBg (API unchanged)
    │   ├── system_panel.dart  ← Delegate → SLPanel (API unchanged)
    │   ├── system_nav.dart    ← Bottom navigation bar
    │   ├── system_button.dart ← The only button widget
    │   ├── system_text.dart   ← SLText wrapper with glow
    │   └── system_window.dart ← Old window (keep; SLWindow is the new canonical)
    ├── hud/
    │   ├── xp_ring.dart       ← Animated XP arc ring
    │   ├── quest_card.dart    ← Quest row card
    │   ├── stat_panel.dart    ← Single stat tile
    │   ├── streak_bar.dart    ← Daily streak + XP progress
    │   └── rank_diamond.dart  ← Rank badge (diamond shape)
    ├── overlays/              ← Cinematic overlays (level up, rank up, boss, xp pop)
    └── screens/
        ├── splash/            ← Boot animation
        ├── onboarding/        ← First-run setup
        ├── home/              ← Main HUD dashboard
        ├── profile/           ← STATUS window (full Solo Leveling redesign)
        ├── workout/           ← 3 screens: hub, active session, summary
        ├── nutrition/         ← Fuel log
        ├── finance/           ← Finance tracker
        ├── planner/           ← Daily planner + focus timer
        ├── analytics/         ← Analytics charts
        ├── ai_coach/          ← AI Ascension Guide (Gemini)
        └── settings/          ← System settings
```

---

## Design System — The Single Visual Law

> Every screen is a STATUS WINDOW projected by a supernatural system.  
> It looks like it was built by something non-human.

### Colors (`lib/core/sl/sl_colors.dart`)

| Name | Hex | Use |
|---|---|---|
| `voidBg` | `#030810` | AMOLED base — background of everything |
| `panelDeep` | `#060E1C` | Outer panel fill |
| `panelMid` | `#091525` | Inner panel fill, stat boxes, HP bars |
| `panelLine` | `#0D1E30` | Separator lines between sections |
| `glowCore` | `#7EC8E3` | Primary border/glow — warm cyan |
| `glowDim` | `#2A5A72` | Dimmed border, inactive states |
| `glowBloom` | `#4A9BB5` | Bloom shadow around panels |
| `rankS` | `#E8603A` | Ember — S rank |
| `rankA` | `#D4A843` | Gold — A rank |
| `rankB` | `#9B6DC9` | Purple — B rank |
| `rankC` | `#5B9BD5` | System blue — C rank |
| `rankD` | `#4CAF82` | Muted green — D rank |
| `rankE` | `#8A9BA8` | Grey-blue — E rank |
| `hpBright` | `#C94040` | HP bar fill |
| `mpBright` | `#3A7BD5` | MP bar fill |
| `xpBright` | `#C8A43A` | XP bar fill |
| `textBright` | `#E8F4FF` | Primary HUD text — near-white cool |
| `textMid` | `#6A8FA8` | Secondary labels |
| `textDim` | `#2A4055` | Ghost/placeholder |
| `danger` | `#D94050` | Warnings, alerts |
| `success` | `#3AC890` | Completions |

**Backward-compatible aliases (do not use in new code):**
`void_`=voidBg, `abyss`=panelDeep, `surface`=panelMid, `cyan`=glowCore,
`cyanDim`=glowDim, `textPrime`=textBright, `textMuted`=textMid,
`textGhost`=textDim, `xpGold`=xpBright, `holoPure`=textBright

### Typography (`lib/core/sl/sl_type.dart`)

| Font | Use | Methods |
|---|---|---|
| Orbitron | Level numbers, rank letters, screen titles, stat values | `display`, `headline`, `hudNum`, `sysLabel`, `levelNum`, `screenTitle`, `statValue`, `subLabel` |
| Rajdhani | Stat labels, descriptions, body text | `questTitle`, `body`, `tag`, `statLabel`, `jobTitle` |
| Exo 2 | Small system labels, bar values, timestamps | `barValue`, `micro` |

**Rules:** All text UPPERCASE where possible. Letter spacing min 1.5, titles 4.0+.
Never construct `TextStyle` inline — always use `SLType.method()`.

### Panels (`lib/ui/system/sl_panel.dart`)

```
SLPanel(
  title: 'STATUS',          ← optional floating title header on top border
  glowColor: SLColors.rankC, ← optional color override
  glowIntensity: 0.6,       ← 0.0-1.0
  padding: ...,
  child: ...,
)
SLSubPanel(child: ...)      ← inner darker box for HP bars, stat groups
SLDivider()                 ← 1px panelLine separator
```

Corner brackets: 18px arms, 1.5px thick, glowCore at 0.9 opacity.
Panel border: 1px glowCore at 0.35 opacity (dim edges, bright corners).

### Background (`lib/ui/system/sl_bg.dart`)

Energy particle network: 18 nodes drifting at 0.008 speed, connected by
lines when dist < 0.28. 40-second animation loop. `intensity` param (0-1).
`SystemBg` delegates to `SLBg` — all existing screen imports unchanged.

---

## XP Engine (`lib/core/engine/xp_engine.dart`)

| Method | Formula |
|---|---|
| `progress(totalXP)` | Returns `(level, xpIn, xpNeeded)` |
| `rank(level)` | E(1-4), D(5-9), C(10-19), B(20-34), A(35-49), S(50+) |
| `strength(workouts)` | Base 10 + workouts scaled |
| `agility(steps)` | Base 10 + steps/1000 |
| `intelligence(mins)` | Base 10 + studyMinutes/30 |
| `vitality(x)` | Base stat |
| `endurance(streak)` | Base 10 + streakDays×2 |

**HP/MP derivation on profile screen (no model fields needed):**
- HP = `min(streakDays × 150, 9999)` / hpMax = 9999
- MP = `min(totalXP ÷ 10, 9999)` / mpMax = 9999
- FATIGUE = `max(0, 7 - streakDays).clamp(0, 100)`

---

## Hive Boxes

| Box | TypeAdapter | typeId |
|---|---|---|
| `playerBox` | PlayerModel | 0 |
| `workoutBox` | WorkoutModel | 1 |
| `nutritionBox` | NutritionModel | 2 |
| `financeBox` | FinanceModel | 3 |
| `questBox` | QuestModel | 4 |

---

## Navigation (GoRouter)

Routes: `/` (splash) → `/onboarding` → `/home` → `/train` → `/fuel` →
`/finance` → `/ai` (shell routes) + `/settings` + `/profile` + `/workout/active`

Shell: `ScaffoldWithNav` wrapping `SystemNav` (5 tabs).

---

## Android Config

- **minSdk:** 24 | **targetSdk:** 34
- **ProGuard:** enabled (R8 in release mode)
- **Permissions:** `INTERNET`
- **Network security config:** `android/app/src/main/res/xml/network_security_config.xml`
- **Build fix (Windows JDK loopback bug):** `$env:TEMP = "C:\tmp"` before `flutter build apk`

---

## Rules — What Never Exists in This Codebase

```
❌ BorderRadius.circular(anything)   → ALL corners are sharp (0)
❌ ElevatedButton / TextButton       → Use system_button.dart only
❌ SnackBar / AlertDialog            → Use SLWindow only
❌ BottomNavigationBar (Material)    → Use SystemNav only
❌ Colors.blue / Colors.white        → Use ONLY SLColors constants
❌ TextStyle inline in widget        → Use ONLY SLType static methods
❌ Card widget                       → Use SLPanel only
❌ InkWell with visible ripple       → GestureDetector only
❌ Bold text (W700+) for labels      → Only for numbers/ranks
❌ LinearProgressIndicator           → Use SLBar / SLBarAnimated
```

---

## Commit History (UI Enhancement Session — 2026-05-28)

| SHA (short) | Date | Message |
|---|---|---|
| `158ea1e` | 2026-05-28 | chore: add reference design system components from UI.zip |
| `c51d475` | 2026-05-28 | design: update color palette and typography to canonical Solo Leveling spec |
| `8dc9dfa` | 2026-05-28 | design: replace backgrounds and panels with canonical Solo Leveling style |
| `ffbd5d5` | 2026-05-28 | design: update HUD widgets to canonical color system |
| `a5bdf4d` | 2026-05-28 | feat: redesign profile screen as authentic Solo Leveling STATUS window |
| `658955b` | 2026-05-28 | design: migrate all screens and overlays to canonical color system |

### Earlier commits
| SHA (short) | Date | Message |
|---|---|---|
| `0b490f2` | 2026-04-01 | Update project files |
| `e44fa86` | 2026-03-08 | feat: Sprint 0-2 — Home HUD, Workout Logger, Water Tracker, 45 tests pass |

---

## Session History

### Session 2 — 2026-05-28 (UI Enhancement)

**Goal:** Extract `UI.zip` reference design files and transplant canonical
Solo Leveling visual language into the codebase.

**What was built:**

1. **sl_colors.dart** — Replaced with canonical palette (glowCore #7EC8E3 instead
   of harsh #00E5FF, AMOLED navy #030810, full rank/HP/MP/XP colors). All old
   names kept as backward-compatible aliases — zero breakage to 238 existing usages.

2. **sl_type.dart** — Added `_orbitronGlow()` and `_softGlow()` helpers. Added 8
   new canonical type methods. Applied glow shadows to all Orbitron styles.

3. **sl_theme.dart** — Fixed `BorderRadius.circular(4)` → `BorderRadius.zero` on
   all input borders; updated internal color names.

4. **sl_bg.dart, sl_panel.dart, sl_bar.dart, sl_stat_row.dart, sl_window.dart** —
   5 new reference components added to `lib/ui/system/`. Corrected import paths
   and fixed `fontFamily: 'ExoTwo'` raw string → `GoogleFonts.exo2()`.

5. **system_bg.dart** — Old grid/scanline/particle painters removed; now delegates
   to `SLBg`. All 11 screens automatically get energy particle network.

6. **system_panel.dart** — Old NotchClipper + BackdropFilter removed; now delegates
   to `SLPanel`. All panels get corner brackets.

7. **system_nav.dart** — Color names migrated to canonical.

8. **HUD widgets** (xp_ring, quest_card, stat_panel, rank_diamond) — Color names
   migrated. `streak_bar.dart`: replaced `ClipRRect` rounded LinearProgressIndicator
   with sharp-cornered Stack/Container bar per spec.

9. **profile_screen.dart** — Full rewrite as authentic STATUS window using
   `SLPanel(title:'STATUS')`, `SLBarAnimated` (HP/MP), `SLStatGrid`, with derived
   HP/MP/FATIGUE values from existing player data. No model changes needed.

10. **All screens + overlays** (17 files) — Bulk color name migration via sed.

**Result:** dart analyze lib/ → 0 errors after all changes.

---

### Session 1 — 2026-03-08 (Initial Build)

Built from scratch: design system, Hive models, providers, router,
all screens, Gemini + food/exercise API clients, demo server (`main_demo.dart`),
ProGuard rules, network security config, Android build fix. 

---

## How to Run

```bash
# Dev server (demo data, hot reload)
flutter run -d chrome --web-port 8081 --target=lib/main_demo.dart

# Android release APK
$env:TEMP = "C:\tmp"   # Windows loopback fix
flutter build apk --release --target=lib/main.dart

# Analysis
dart analyze lib/   # must show 0 errors
```

---

## Next Steps / Backlog

- [ ] Implement real step counter / workout tracking (pedometer plugin)
- [ ] Gemini AI coach: wire real responses (currently demo)
- [ ] Push notifications for daily quest assignments
- [ ] Google Play Store submission (see `PLAY_STORE_GUIDE.md`)
- [ ] Privacy Policy hosted URL (see `PRIVACY_POLICY.md`)
- [ ] S-rank unlock animation at Level 50
- [ ] Leaderboard / social features
