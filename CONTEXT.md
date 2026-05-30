# AGION — Project Context & Living Documentation

> **Update this file after every development session.**  
> It is the memory of the project across Claude conversations.

---

## Identity

**AGION** is a real-life Solo Leveling System mobile app for Android.  
The user is "Sung Jin-Woo" — every screen must feel like a STATUS WINDOW
projected by a supernatural system. It must NOT look like a mobile app.

- **Package name:** `com.agion.agion`
- **Version:** 1.0.0+1
- **Min SDK:** Android 24 (Flutter 3.x)
- **GitHub:** https://github.com/SheeshDarth/AGION
- **Developer:** Siddharth (siddharthprashoo@gmail.com)

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
| Notifications | flutter_local_notifications | ^17.2.2 |
| Timezone | timezone | ^0.9.4 |

---

## Architecture

```
lib/
├── main.dart                  ← Hive init, ProviderScope, app bootstrap
├── main_demo.dart             ← Demo mode with seeded data (port 8083)
├── app.dart                   ← MaterialApp.router wrapping GoRouter
│
├── core/
│   ├── sl/                    ← CANONICAL DESIGN SYSTEM (read-only sources of truth)
│   │   ├── sl_colors.dart     ← All hex values — no other hex exists anywhere
│   │   ├── sl_type.dart       ← All TextStyles — no inline TextStyle elsewhere
│   │   └── sl_theme.dart      ← ThemeData for MaterialApp
│   ├── engine/
│   │   ├── xp_engine.dart     ← Level/rank/stat derivation from XP
│   │   └── body_engine.dart   ← BMI, BMR, TDEE, macro calculations
│   ├── router/
│   │   └── app_router.dart    ← GoRouter — 16 flat top-level routes
│   └── services/
│       ├── device_tier.dart   ← Tier.low/mid/high for perf scaling
│       ├── hive_service.dart  ← Box registration + adapter setup
│       ├── notification_service.dart ← flutter_local_notifications wrapper
│       └── system_event_bus.dart     ← Broadcast streams for XP/level/rank events
│
├── data/
│   ├── models/                ← Hive TypeAdapters (typeId 0-8)
│   │   ├── player_model.dart       (typeId 0)
│   │   ├── workout_session_model.dart (typeIds 1, 2, 3)
│   │   ├── nutrition_log_model.dart   (typeIds 4, 5, 6)
│   │   ├── finance_entry_model.dart   (typeId 7)
│   │   └── quest_model.dart           (typeId 8)
│   └── remote/
│       ├── gemini_client.dart
│       ├── food_api_client.dart      ← Open Food Facts API
│       └── exercise_api_client.dart  ← wger Exercise API
│
├── providers/
│   ├── player_provider.dart   ← PlayerNotifier — uses box.put() not object.save()
│   ├── quest_provider.dart    ← QuestNotifier
│   ├── workout_provider.dart  ← WorkoutNotifier + ActiveSessionNotifier
│   ├── nutrition_provider.dart
│   ├── finance_provider.dart
│   └── ai_provider.dart
│
└── ui/
    ├── system/                ← Component primitives (ALWAYS use these, never raw Material)
    │   ├── sl_bg.dart         ← Energy particle network background
    │   ├── sl_panel.dart      ← Corner-bracket panel (canonical)
    │   ├── sl_bar.dart        ← HP/MP/XP progress bars
    │   ├── sl_stat_row.dart   ← Icon + LABEL: VALUE stat rows
    │   ├── sl_window.dart     ← System notification overlay (SLWindow)
    │   ├── system_bg.dart     ← Delegate → SLBg (API unchanged)
    │   ├── system_panel.dart  ← Delegate → SLPanel (API unchanged)
    │   ├── system_nav.dart    ← Bottom navigation bar (5 tabs)
    │   ├── system_button.dart ← The only button widget
    │   ├── system_text.dart   ← SLText glow text wrapper
    │   └── system_window.dart ← Legacy window (keep for backward compat)
    ├── hud/
    │   ├── xp_ring.dart       ← Animated XP arc ring (CustomPainter)
    │   ├── quest_card.dart    ← Quest row card
    │   ├── stat_panel.dart    ← Single stat tile
    │   ├── streak_bar.dart    ← Daily streak + XP progress (sharp corners, no ClipRRect)
    │   └── rank_diamond.dart  ← Rank badge
    ├── overlays/
    │   ├── level_up_overlay.dart
    │   ├── rank_up_overlay.dart
    │   ├── boss_cleared_overlay.dart
    │   └── xp_pop.dart
    └── screens/
        ├── splash/            ← Boot animation + route decision
        ├── onboarding/        ← 5-page first-run setup WITH legal consent
        ├── home/              ← Main HUD dashboard
        ├── profile/           ← STATUS window (Solo Leveling redesign)
        ├── workout/           ← hub, active_session, session_summary
        ├── nutrition/         ← Fuel log
        ├── finance/           ← Finance tracker
        ├── planner/           ← Daily planner + focus timer
        ├── analytics/         ← Analytics charts
        ├── ai_coach/          ← AI Ascension Guide (Gemini)
        ├── settings/          ← System settings (links to legal screens)
        └── legal/             ← NEW: privacy_policy_screen + terms_screen
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
| `glowBloom` | `#4A9BB5` | Bloom shadow around panels / icon brackets |
| `rankS` | `#E8603A` | Ember — S rank |
| `rankA` | `#D4A843` | Gold — A rank |
| `rankB` | `#9B6DC9` | Purple — B rank |
| `rankC` | `#5B9BD5` | System blue — C rank |
| `rankD` | `#4CAF82` | Muted green — D rank |
| `rankE` | `#8A9BA8` | Grey-blue — E rank |
| `hpBright` | `#C94040` | HP bar fill |
| `mpBright` | `#3A7BD5` | MP bar fill |
| `xpBright` | `#C8A43A` | XP bar/ring fill |
| `textBright` | `#E8F4FF` | Primary HUD text |
| `textMid` | `#6A8FA8` | Secondary labels |
| `textDim` | `#2A4055` | Ghost/placeholder |
| `danger` | `#D94050` | Warnings, alerts, erase button |
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

```dart
SLPanel(
  title: 'STATUS',           // optional floating title on top border
  glowColor: SLColors.rankC, // optional color override
  glowIntensity: 0.6,        // 0.0 – 1.0
  padding: ...,
  child: ...,
)
SLSubPanel(child: ...)       // inner darker box for HP bars, stat groups
SLDivider()                  // 1px panelLine separator
```

Corner brackets: 18px arms, 1.5px thick, glowCore at 0.9 opacity.
Panel border: 1px glowCore at 0.35 opacity (dim edges, bright corners).

### Background (`lib/ui/system/sl_bg.dart`)

Energy particle network: 18 nodes drifting (fixed seed 42), connected by
lines when dist < 0.28. 40-second animation loop. `intensity` param (0–1).
`SystemBg` is a thin delegate to `SLBg`.

### App Icon (`tools/generate_icon.py`)

Custom branded icon generated via Python/Pillow. Design layers:
1. AMOLED navy background (#030810) with subtle radial bloom
2. Faint hexagonal ring (radius 320px, #2A5A72)
3. Corner L-brackets matching SLPanel style (#4A9BB5)
4. Geometric "A" glyph (polygon primitives, not text) with 3-layer cyan glow
5. 12 fixed-position energy particle dots

Run: `python tools/generate_icon.py` from project root (requires `pip install Pillow`).
Outputs: `assets/images/agion_icon.png` (1024×1024) + all 10 mipmap PNGs.

---

## XP Engine (`lib/core/engine/xp_engine.dart`)

| Method | Formula |
|---|---|
| `progress(totalXP)` | Returns `(level, xpIn, xpNeeded)` |
| `rank(level)` | E(1–4), D(5–9), C(10–19), B(20–34), A(35–49), S(50+) |
| `xpForLevel(n)` | `100 + (n-1) × 50` |
| `strength(volumeKg)` | `(volumeKg / 80).clamp(0, 9999)` |
| `agility(steps)` | `(steps / 100).clamp(0, 9999)` |
| `intelligence(mins)` | `(mins / 8).clamp(0, 9999)` |
| `vitality(compliance%)` | `(x × 10).clamp(0, 1000)` |
| `endurance(streak)` | `(streak × 15).clamp(0, 9999)` |

**HP/MP/FATIGUE derivation (profile screen — no model changes needed):**
- HP = `min(streakDays × 150, 9999)` / hpMax = 9999
- MP = `min(totalXP ÷ 10, 9999)` / mpMax = 9999
- FATIGUE = `max(0, 7 − streakDays).clamp(0, 100)`

---

## Hive Boxes & TypeAdapters

| Box key | Type | TypeAdapter | typeId |
|---|---|---|---|
| `players` | `PlayerModel` | `PlayerModelAdapter` | 0 |
| `workouts` | `WorkoutSession` | `WorkoutSessionAdapter` | 1 |
| — | `ExerciseEntry` | `ExerciseEntryAdapter` | 2 |
| — | `SetEntry` | `SetEntryAdapter` | 3 |
| `nutrition` | `NutritionLog` | `NutritionLogAdapter` | 4 |
| — | `MealEntry` | `MealEntryAdapter` | 5 |
| — | `FoodItem` | `FoodItemAdapter` | 6 |
| `finance` | `FinanceEntry` | `FinanceEntryAdapter` | 7 |
| `quests` | `QuestModel` | `QuestModelAdapter` | 8 |
| `cache` | `dynamic` | — | — |

**Critical**: Always use `box.put(key, obj)` — NEVER `hiveObject.save()`.
`object.save()` fails on web (IndexedDB returns fresh untracked copies).
`PlayerNotifier` and `QuestNotifier` both use `box.put()` exclusively.

---

## Navigation (GoRouter — 16 routes)

```
/splash          → SplashScreen      (decides onboarding vs home)
/onboarding      → OnboardingShell   (5 pages, legal consent on page 5)
/home            → HomeScreen
/workout         → WorkoutHubScreen
/workout/session → ActiveSessionScreen
/workout/summary → SessionSummaryScreen
/nutrition       → NutritionScreen
/finance         → FinanceScreen
/planner         → PlannerScreen
/focus           → FocusTimerScreen
/analytics       → AnalyticsScreen
/ai              → AiCoachScreen
/profile         → ProfileScreen
/settings        → SettingsScreen
/legal/privacy   → PrivacyPolicyScreen   ← NEW
/legal/terms     → TermsScreen           ← NEW
```

---

## Legal Documents (NEW — Session 3)

### In-App Display
- **Privacy Policy** (`/legal/privacy`): Full 10-section policy in SL aesthetic
  - Accessible from: Settings → Data & Privacy → Privacy Policy
  - Accessible from: Onboarding page 5 → "Privacy Policy" link text
- **Terms of Service** (`/legal/terms`): Full 9-section ToS in SL aesthetic
  - Accessible from: Settings → Data & Privacy → Terms of Service
  - Accessible from: Onboarding page 5 → "Terms of Service" link text

### Onboarding Consent Gate
Page 5 (`_PageConfirm`) requires both checkboxes checked before BEGIN ASCENSION:
- SL-styled square checkboxes (no rounded corners, glowCore glow when checked)
- Button shows as ghost/dim until both accepted; full boss ember style when ready
- Tapping link text navigates to the full legal screen and back returns to onboarding

### Source Files
- Privacy policy source: `PRIVACY_POLICY.md` (project root, effective 2026-05-27)
- Terms of Service: inline in `lib/ui/screens/legal/terms_screen.dart`
- **Public URL required for Play Store**: host PRIVACY_POLICY.md on GitHub Pages

---

## Android Config

- **minSdk:** 24 | **targetSdk:** 34
- **Package:** `com.agion.agion`
- **ProGuard:** R8 in release mode (`android/app/proguard-rules.pro`)
- **Permissions:** INTERNET, ACCESS_NETWORK_STATE, POST_NOTIFICATIONS,
  RECEIVE_BOOT_COMPLETED, ACTIVITY_RECOGNITION, VIBRATE, WAKE_LOCK
- **No** SCHEDULE_EXACT_ALARM (removed — requires special user grant on Android 12+;
  notifications use `AndroidScheduleMode.inexact` instead)
- **Icons:** Custom AGION branded icon (geometric A glyph, hex ring, corner brackets)
  Square + round variants at all 5 mipmap densities (mdpi/hdpi/xhdpi/xxhdpi/xxxhdpi)
- **Network security:** HTTPS-only, `android:allowBackup="false"`
- **Build fix (Windows JDK loopback):** `$env:TEMP = "C:\tmp"` before flutter build

---

## Notification Service

3 daily notifications scheduled via `flutter_local_notifications`:
- 08:00 — Morning briefing: "Daily missions loaded. Initiate ascension."
- 19:00 — Evening reminder: "Combat training unregistered. Streak at risk."
- 22:45 — Night warning: "Daily reset in 75 minutes. Complete active quests."

Timezone mapped from UTC offset at runtime (IST +5 → Asia/Kolkata hardcoded).
All notification code wrapped in try/catch — never crashes the app.
`_initialized` flag prevents scheduling if init failed.

---

## Rules — What Never Exists in This Codebase

```
❌ BorderRadius.circular(anything)   → ALL corners are sharp (BorderRadius.zero)
❌ ElevatedButton / TextButton       → system_button.dart only
❌ SnackBar / AlertDialog            → SLWindow only
❌ BottomNavigationBar (Material)    → SystemNav only
❌ Colors.blue / Colors.white        → SLColors constants only
❌ TextStyle inline in widgets       → SLType static methods only
❌ Card widget                       → SLPanel only
❌ InkWell with visible ripple       → GestureDetector only
❌ LinearProgressIndicator           → SLBar / SLBarAnimated only
❌ HiveObject.save()                 → box.put(key, object) only
❌ Rounded ClipRRect on progress bar → Sharp Stack/Container approach
```

---

## Commit History

### Session 3 — 2026-05-30 (Legal Documents + Logo + Bug Fixes)

| SHA | Message |
|---|---|
| `d1df6e6` | feat: add legal documents, onboarding consent, and custom AGION logo |
| `c621671` | fix: eliminate HiveError 'not in a box' runtime crash on XP award |
| `f82b979` | fix: resolve all dart analyze issues — zero warnings, zero errors |
| `01a38d7` | fix: resolve APK crash-on-launch and replace default Flutter icon |

**What was built/fixed in Session 3:**
1. **HiveError crash fix** — `player_provider.dart` and `quest_provider.dart` rewrote
   all `object.save()` calls to `box.put()`. Added `_persist()` + `_copy()` helpers.
   `_load()` now uses `box.get('player')` (named key) not `box.getAt(0)` (index).
2. **dart analyze — 52 → 0 issues** — Fixed `use_build_context_synchronously`
   (active_session_screen), deprecated `activeColor` → `activeThumbColor` (settings),
   `_goals_list` → `_goalsList` naming, 46 `prefer_const_constructors` via dart fix.
3. **Custom AGION Logo** — `tools/generate_icon.py` generates 1024×1024 master PNG
   + 10 mipmap PNGs using Pillow polygon primitives. Geometric "A" with 3-layer glow.
4. **Privacy Policy screen** (`lib/ui/screens/legal/privacy_policy_screen.dart`) —
   Full 10-section policy in SL aesthetic, replaces old 5-section dialog.
5. **Terms of Service screen** (`lib/ui/screens/legal/terms_screen.dart`) —
   New 9-section ToS (didn't exist before).
6. **Router** — 2 new routes: `/legal/privacy`, `/legal/terms`.
7. **Settings** — Privacy Policy tile navigates to full screen; ToS tile added;
   deleted 70 lines of dead `_showPrivacyPolicy()` + `_privacySection()` code.
8. **Onboarding** — `_PageConfirm` converted to StatefulWidget; legal consent gate
   with 2 SL-styled checkboxes; BEGIN ASCENSION disabled until both accepted.

### Session 2 — 2026-05-28 (UI Enhancement from UI.zip)

| SHA | Message |
|---|---|
| `8944044` | docs: add CONTEXT.md with full project history and architecture |
| `658955b` | design: migrate all screens and overlays to canonical color system |
| `a5bdf4d` | feat: redesign profile screen as authentic Solo Leveling STATUS window |
| `ffbd5d5` | design: update HUD widgets to canonical color system |
| `8dc9dfa` | design: replace backgrounds and panels with canonical Solo Leveling style |
| `c51d475` | design: update color palette and typography to canonical Solo Leveling spec |
| `158ea1e` | chore: add reference design system components from UI.zip |

**What was built in Session 2:**
Transplanted canonical Solo Leveling design system (sl_bg, sl_panel, sl_bar,
sl_stat_row, sl_window) from UI.zip reference spec. Replaced harsh #00E5FF palette
with warm #7EC8E3 cyan. Replaced grid/scanline background with energy particle network.
Replaced notched glass panels with corner-bracket SLPanel. Redesigned profile screen
as authentic STATUS window with HP/MP bars and stat grid.

### Session 1 — 2026-03-08 (Initial Build)

Built from scratch: design system, Hive models, providers, router,
all screens (splash → settings), Gemini + food/exercise API clients,
demo mode, ProGuard rules, network security config.

---

## How to Run

```powershell
# Dev server (demo data seeded, hot reload)
$env:TEMP = "C:\tmp"
flutter run -d chrome --web-port 8083 --target=lib/main_demo.dart

# Android release APK (Windows — TEMP fix for JDK loopback bug)
$env:TEMP = "C:\tmp"; $env:TMP = "C:\tmp"
flutter build apk --release --target=lib/main.dart
# Output: build\app\outputs\flutter-apk\app-release.apk

# Code quality
dart analyze lib/        # must show: No issues found!
dart fix --apply lib/    # auto-fix prefer_const_constructors etc.

# Regenerate app icon (after design changes)
pip install Pillow
python tools/generate_icon.py   # run from project root
```

---

## Play Store Readiness Checklist

- [x] Privacy Policy written (`PRIVACY_POLICY.md`)
- [x] Privacy Policy displayed in-app (full 10-section screen)
- [x] Terms of Service displayed in-app (full 9-section screen)
- [x] Legal consent required at onboarding
- [x] `android:allowBackup="false"`
- [x] `android:requestLegacyExternalStorage="false"`
- [x] ProGuard/R8 rules for all dependencies
- [x] Network security config (HTTPS-only)
- [x] No SCHEDULE_EXACT_ALARM (removed)
- [x] Custom app icon (square + round, all densities)
- [ ] Privacy Policy hosted at public URL (required for Play Console)
- [ ] Data Safety Form filled in Play Console
- [ ] Content Rating questionnaire completed in Play Console
- [ ] App signing key generated and stored securely
- [ ] Store listing: screenshots, description, category

---

## Backlog / Next Steps

- [ ] Host Privacy Policy at public URL (GitHub Pages from PRIVACY_POLICY.md)
- [ ] Real step counter integration (pedometer plugin)
- [ ] Gemini AI coach: real responses with context (currently seeded demo)
- [ ] Workout tracking: track actual exercise volume for real STR/AGI stats
- [ ] S-rank unlock animation at Level 50
- [ ] Onboarding: skip option for returning users who cleared data
- [ ] Widget (home screen Android widget showing daily XP + streak)
- [ ] Google Play Store submission
