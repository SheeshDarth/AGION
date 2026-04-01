import '../models/quest_arc.dart';

/// Pre-built Quest Arcs — anime & pop culture themed workout programs.
class QuestArcCatalog {
  QuestArcCatalog._();

  static List<QuestArc> get all => [
        shadowMonarch,
        saitamaRegimen,
        scoutRegiment,
        breathOfSun,
        domainExpansion,
        hyperbolicChamber,
        peakyDiscipline,
      ];

  // ═══════════════════════════════════════════════════════════════════════
  // 1. SHADOW MONARCH PROTOCOL — Solo Leveling
  // ═══════════════════════════════════════════════════════════════════════
  static final shadowMonarch = QuestArc(
    id: 'shadow_monarch',
    name: 'Shadow Monarch Protocol',
    theme: 'Solo Leveling',
    emoji: '👑',
    description:
        'The system has chosen you. 8 weeks of progressive overload to '
        'forge a body worthy of the Shadow Monarch.',
    durationWeeks: 8,
    difficulty: 'B',
    xpMultiplier: 2.0,
    phases: [
      ArcPhase(
        name: 'Awakening',
        description: 'Survive the Double Dungeon. Build your foundation.',
        weekNumber: 1,
        exercises: [
          ArcExercise(name: 'Push-ups', sets: 3, reps: 15, type: 'strength',
              instruction: 'Full ROM, chest to floor'),
          ArcExercise(name: 'Bodyweight Squats', sets: 3, reps: 20,
              type: 'strength', instruction: 'Below parallel'),
          ArcExercise(name: 'Plank', sets: 3, reps: 45, type: 'endurance',
              instruction: '45-second holds'),
          ArcExercise(name: 'Burpees', sets: 3, reps: 10, type: 'cardio',
              instruction: 'Full extension at top'),
          ArcExercise(name: 'Running', sets: 1, reps: 1, type: 'cardio',
              instruction: '2km at steady pace'),
        ],
      ),
      ArcPhase(
        name: 'E-Rank Grind',
        description: 'Clear low-level dungeons. Increase volume.',
        weekNumber: 3,
        exercises: [
          ArcExercise(name: 'Diamond Push-ups', sets: 4, reps: 12,
              type: 'strength', instruction: 'Hands close together'),
          ArcExercise(name: 'Jump Squats', sets: 4, reps: 15, type: 'strength',
              instruction: 'Explosive upward, soft landing'),
          ArcExercise(name: 'Mountain Climbers', sets: 4, reps: 30,
              type: 'cardio', instruction: '30 reps each side'),
          ArcExercise(name: 'Pull-ups', sets: 3, reps: 8, type: 'strength',
              instruction: 'Full dead hang, chin over bar'),
          ArcExercise(name: 'Running', sets: 1, reps: 1, type: 'cardio',
              instruction: '3km with 2 sprints'),
        ],
      ),
      ArcPhase(
        name: 'Rank Up',
        description: 'The System pushes harder. Heavy compound lifts begin.',
        weekNumber: 5,
        exercises: [
          ArcExercise(name: 'Barbell Squat', sets: 5, reps: 5,
              type: 'strength', instruction: 'Progressive overload each week'),
          ArcExercise(name: 'Bench Press', sets: 5, reps: 5, type: 'strength',
              instruction: 'Controlled descent, explosive press'),
          ArcExercise(name: 'Deadlift', sets: 5, reps: 5, type: 'strength',
              instruction: 'Neutral spine, hip hinge'),
          ArcExercise(name: 'Weighted Pull-ups', sets: 4, reps: 6,
              type: 'strength', instruction: 'Add weight progressively'),
          ArcExercise(name: 'HIIT Sprints', sets: 8, reps: 1, type: 'cardio',
              restSeconds: 30, instruction: '30sec sprint / 30sec rest'),
        ],
      ),
      ArcPhase(
        name: 'Shadow Army',
        description: 'Command your shadows. Peak performance week.',
        weekNumber: 7,
        daysPerWeek: 6,
        exercises: [
          ArcExercise(name: 'Front Squat', sets: 5, reps: 5, type: 'strength',
              instruction: 'PR attempt week'),
          ArcExercise(name: 'Overhead Press', sets: 5, reps: 5,
              type: 'strength', instruction: 'Strict form, no leg drive'),
          ArcExercise(name: 'Weighted Dips', sets: 4, reps: 8,
              type: 'strength', instruction: 'Full depth'),
          ArcExercise(name: 'Barbell Row', sets: 4, reps: 8, type: 'strength',
              instruction: 'Squeeze scapula at top'),
          ArcExercise(name: 'Running', sets: 1, reps: 1, type: 'cardio',
              instruction: '5km timed run'),
        ],
      ),
    ],
    bossFight: BossFight(
      name: 'Architect\'s Trial',
      description: 'Set new PRs across all 4 major lifts. Prove your worth.',
      bonusXp: 500,
      challenges: [
        ArcExercise(name: 'Squat 1RM Test', sets: 1, reps: 1,
            type: 'strength', instruction: 'Attempt new 1-rep max'),
        ArcExercise(name: 'Bench 1RM Test', sets: 1, reps: 1,
            type: 'strength', instruction: 'Attempt new 1-rep max'),
        ArcExercise(name: 'Deadlift 1RM Test', sets: 1, reps: 1,
            type: 'strength', instruction: 'Attempt new 1-rep max'),
        ArcExercise(name: '2km Time Trial', sets: 1, reps: 1, type: 'cardio',
            instruction: 'Beat your Week 1 time'),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════
  // 2. SAITAMA'S REGIMEN — One Punch Man
  // ═══════════════════════════════════════════════════════════════════════
  static final saitamaRegimen = QuestArc(
    id: 'saitama',
    name: 'Saitama\'s Regimen',
    theme: 'One Punch Man',
    emoji: '👊',
    description:
        '100 push-ups, 100 sit-ups, 100 squats, 10km run. Every single day. '
        'No AC, no excuses.',
    durationWeeks: 4,
    difficulty: 'A',
    xpMultiplier: 2.5,
    phases: [
      ArcPhase(
        name: 'Limiter Break Phase 1',
        description: 'Start with 50% volume. Build the habit.',
        weekNumber: 1,
        daysPerWeek: 6,
        exercises: [
          ArcExercise(name: 'Push-ups', sets: 5, reps: 10, type: 'strength',
              instruction: '50 total. Break into sets.'),
          ArcExercise(name: 'Sit-ups', sets: 5, reps: 10, type: 'strength',
              instruction: '50 total. Full range.'),
          ArcExercise(name: 'Squats', sets: 5, reps: 10, type: 'strength',
              instruction: '50 total. Below parallel.'),
          ArcExercise(name: 'Running', sets: 1, reps: 1, type: 'cardio',
              instruction: '5km run. Any pace.'),
        ],
      ),
      ArcPhase(
        name: 'Limiter Break Phase 2',
        description: '75% volume. The pain is temporary.',
        weekNumber: 2,
        daysPerWeek: 6,
        exercises: [
          ArcExercise(name: 'Push-ups', sets: 5, reps: 15, type: 'strength',
              instruction: '75 total'),
          ArcExercise(name: 'Sit-ups', sets: 5, reps: 15, type: 'strength',
              instruction: '75 total'),
          ArcExercise(name: 'Squats', sets: 5, reps: 15, type: 'strength',
              instruction: '75 total'),
          ArcExercise(name: 'Running', sets: 1, reps: 1, type: 'cardio',
              instruction: '7.5km run'),
        ],
      ),
      ArcPhase(
        name: 'Full Power',
        description: 'The complete Saitama workout. Every. Single. Day.',
        weekNumber: 3,
        daysPerWeek: 7,
        exercises: [
          ArcExercise(name: 'Push-ups', sets: 10, reps: 10, type: 'strength',
              instruction: '100 total. No excuses.'),
          ArcExercise(name: 'Sit-ups', sets: 10, reps: 10, type: 'strength',
              instruction: '100 total. Full ROM.'),
          ArcExercise(name: 'Squats', sets: 10, reps: 10, type: 'strength',
              instruction: '100 total.'),
          ArcExercise(name: 'Running', sets: 1, reps: 1, type: 'cardio',
              instruction: '10km run. This is the way.'),
        ],
      ),
    ],
    bossFight: BossFight(
      name: 'ONE PUNCH',
      description: 'Complete the full Saitama workout in under 2 hours.',
      bonusXp: 750,
      challenges: [
        ArcExercise(name: '100 Push-ups', sets: 1, reps: 100,
            type: 'strength', instruction: 'Unbroken or minimal rest'),
        ArcExercise(name: '100 Sit-ups', sets: 1, reps: 100,
            type: 'strength', instruction: 'Unbroken or minimal rest'),
        ArcExercise(name: '100 Squats', sets: 1, reps: 100, type: 'strength',
            instruction: 'Unbroken or minimal rest'),
        ArcExercise(name: '10km Run', sets: 1, reps: 1, type: 'cardio',
            instruction: 'Complete without walking'),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════
  // 3. SCOUT REGIMENT TRAINING — Attack on Titan
  // ═══════════════════════════════════════════════════════════════════════
  static final scoutRegiment = QuestArc(
    id: 'scout_regiment',
    name: 'Scout Regiment Training',
    theme: 'Attack on Titan',
    emoji: '⚔️',
    description:
        'Train like the Scout Regiment. HIIT + endurance to survive '
        'beyond the walls.',
    durationWeeks: 6,
    difficulty: 'C',
    xpMultiplier: 1.8,
    phases: [
      ArcPhase(
        name: 'Cadet Corps',
        description: 'Basic military fitness. Build your base.',
        weekNumber: 1,
        exercises: [
          ArcExercise(name: 'Sprints', sets: 6, reps: 1, type: 'cardio',
              restSeconds: 45, instruction: '100m sprints, 45s rest'),
          ArcExercise(name: 'Pull-ups', sets: 4, reps: 8, type: 'strength',
              instruction: 'ODM gear upper body strength'),
          ArcExercise(name: 'Box Jumps', sets: 4, reps: 10, type: 'strength',
              instruction: 'Explosive power for 3DMG'),
          ArcExercise(name: 'Hanging Leg Raises', sets: 3, reps: 12,
              type: 'strength', instruction: 'Core for aerial maneuvers'),
          ArcExercise(name: 'Shuttle Runs', sets: 5, reps: 1, type: 'cardio',
              instruction: '20m shuttles, max speed'),
        ],
      ),
      ArcPhase(
        name: 'ODM Training',
        description: 'Master the Omni-Directional Gear movements.',
        weekNumber: 3,
        exercises: [
          ArcExercise(name: 'Muscle-ups', sets: 3, reps: 5, type: 'strength',
              instruction: 'Or assisted muscle-ups'),
          ArcExercise(name: 'Pistol Squats', sets: 3, reps: 8,
              type: 'strength', instruction: 'Each leg, use support if needed'),
          ArcExercise(name: 'Tabata Burpees', sets: 8, reps: 1, type: 'cardio',
              restSeconds: 10,
              instruction: '20sec work / 10sec rest × 8'),
          ArcExercise(name: 'Rope Climbs', sets: 3, reps: 3, type: 'strength',
              instruction: 'Or towel pull-ups'),
          ArcExercise(name: '400m Repeats', sets: 4, reps: 1, type: 'cardio',
              restSeconds: 90, instruction: '400m fast, 90s rest'),
        ],
      ),
      ArcPhase(
        name: 'Beyond the Walls',
        description: 'Face the Titans. Peak endurance + power.',
        weekNumber: 5,
        daysPerWeek: 6,
        exercises: [
          ArcExercise(name: 'Weighted Pull-ups', sets: 5, reps: 5,
              type: 'strength', instruction: 'Add weight each set'),
          ArcExercise(name: 'Plyometric Push-ups', sets: 4, reps: 10,
              type: 'strength', instruction: 'Hands leave ground'),
          ArcExercise(name: 'Hill Sprints', sets: 8, reps: 1, type: 'cardio',
              restSeconds: 60, instruction: 'Find a hill, sprint up, walk down'),
          ArcExercise(name: 'Turkish Get-ups', sets: 3, reps: 5,
              type: 'strength', instruction: 'Each side, moderate weight'),
          ArcExercise(name: '5km Timed Run', sets: 1, reps: 1, type: 'cardio',
              instruction: 'Beat previous time'),
        ],
      ),
    ],
    bossFight: BossFight(
      name: 'Colossal Titan',
      description: 'Complete the Scout Regiment Challenge without stopping.',
      bonusXp: 400,
      challenges: [
        ArcExercise(name: '20 Pull-ups', sets: 1, reps: 20, type: 'strength',
            instruction: 'Unbroken'),
        ArcExercise(name: '30 Box Jumps', sets: 1, reps: 30, type: 'strength',
            instruction: 'No rest'),
        ArcExercise(name: '800m Sprint', sets: 1, reps: 1, type: 'cardio',
            instruction: 'All-out effort'),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════
  // 4. BREATH OF THE SUN — Demon Slayer
  // ═══════════════════════════════════════════════════════════════════════
  static final breathOfSun = QuestArc(
    id: 'breath_of_sun',
    name: 'Breath of the Sun',
    theme: 'Demon Slayer',
    emoji: '🔥',
    description:
        'Master Total Concentration Breathing. Cardio, flexibility, '
        'and explosive power — the way of the blade.',
    durationWeeks: 6,
    difficulty: 'C',
    xpMultiplier: 1.8,
    phases: [
      ArcPhase(
        name: 'Water Breathing',
        description: 'Flow like water. Build your aerobic base.',
        weekNumber: 1,
        exercises: [
          ArcExercise(name: 'Yoga Sun Salutations', sets: 3, reps: 5,
              type: 'flexibility',
              instruction: 'Full flow, sync with breath'),
          ArcExercise(name: 'Jump Rope', sets: 5, reps: 100, type: 'cardio',
              instruction: '500 total skips'),
          ArcExercise(name: 'Lunges', sets: 3, reps: 12, type: 'strength',
              instruction: 'Walking lunges, each leg'),
          ArcExercise(name: 'Deep Breathing', sets: 3, reps: 10,
              type: 'flexibility',
              instruction: 'Box breathing: 4s in, 4s hold, 4s out, 4s hold'),
        ],
      ),
      ArcPhase(
        name: 'Thunder Breathing',
        description: 'Speed. Explosion. Quick feet.',
        weekNumber: 3,
        exercises: [
          ArcExercise(name: 'Agility Ladder', sets: 5, reps: 1, type: 'cardio',
              instruction: 'Various patterns, max speed'),
          ArcExercise(name: 'Power Cleans', sets: 4, reps: 5, type: 'strength',
              instruction: 'Explosive hip extension'),
          ArcExercise(name: 'Box Jumps', sets: 4, reps: 8, type: 'strength',
              instruction: 'Max height, soft landing'),
          ArcExercise(name: 'Sprint Intervals', sets: 6, reps: 1,
              type: 'cardio', restSeconds: 60,
              instruction: '200m repeats'),
        ],
      ),
      ArcPhase(
        name: 'Sun Breathing',
        description: 'Combine everything. Total concentration.',
        weekNumber: 5,
        daysPerWeek: 6,
        exercises: [
          ArcExercise(name: 'Bear Crawls', sets: 3, reps: 1, type: 'strength',
              instruction: '20m forward, 20m backward'),
          ArcExercise(name: 'Kettlebell Swings', sets: 5, reps: 15,
              type: 'strength', instruction: 'Russian swings, snap hips'),
          ArcExercise(name: 'Handstand Hold', sets: 3, reps: 30,
              type: 'strength',
              instruction: '30-second holds against wall'),
          ArcExercise(name: 'Full Body Stretch', sets: 1, reps: 1,
              type: 'flexibility', instruction: '15min deep stretching'),
        ],
      ),
    ],
    bossFight: BossFight(
      name: 'Muzan\'s Domain',
      description: 'Endurance gauntlet — continuous movement for 30 minutes.',
      bonusXp: 400,
      challenges: [
        ArcExercise(name: '5min Jump Rope', sets: 1, reps: 1, type: 'cardio',
            instruction: 'No stopping'),
        ArcExercise(name: '5min Burpees', sets: 1, reps: 1, type: 'cardio',
            instruction: 'Steady pace, no stopping'),
        ArcExercise(name: '5min Mountain Climbers', sets: 1, reps: 1,
            type: 'cardio', instruction: 'Keep moving'),
        ArcExercise(name: '15min Run', sets: 1, reps: 1, type: 'cardio',
            instruction: 'Fastest pace you can sustain'),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════
  // 5. DOMAIN EXPANSION — Jujutsu Kaisen
  // ═══════════════════════════════════════════════════════════════════════
  static final domainExpansion = QuestArc(
    id: 'domain_expansion',
    name: 'Domain Expansion',
    theme: 'Jujutsu Kaisen',
    emoji: '🟣',
    description:
        'Compound lifts, heavy. Expand your domain of strength. '
        'Cursed energy flows through the barbell.',
    durationWeeks: 8,
    difficulty: 'B',
    xpMultiplier: 2.0,
    phases: [
      ArcPhase(
        name: 'Cursed Energy Awakening',
        description: 'Learn the lifts. Perfect form over weight.',
        weekNumber: 1,
        exercises: [
          ArcExercise(name: 'Back Squat', sets: 4, reps: 8, type: 'strength',
              instruction: 'Moderate weight, ATG depth'),
          ArcExercise(name: 'Bench Press', sets: 4, reps: 8, type: 'strength',
              instruction: 'Pause at bottom'),
          ArcExercise(name: 'Barbell Row', sets: 4, reps: 8, type: 'strength',
              instruction: 'Strict form, no bouncing'),
          ArcExercise(name: 'Overhead Press', sets: 4, reps: 8,
              type: 'strength', instruction: 'Standing, strict'),
        ],
      ),
      ArcPhase(
        name: 'Black Flash',
        description: '5×5 strength protocol. Spatial distortion.',
        weekNumber: 3,
        exercises: [
          ArcExercise(name: 'Back Squat', sets: 5, reps: 5, type: 'strength',
              instruction: 'Add 2.5kg from Phase 1'),
          ArcExercise(name: 'Bench Press', sets: 5, reps: 5, type: 'strength',
              instruction: 'Add 2.5kg from Phase 1'),
          ArcExercise(name: 'Deadlift', sets: 5, reps: 5, type: 'strength',
              instruction: 'Conventional or sumo'),
          ArcExercise(name: 'Weighted Chin-ups', sets: 5, reps: 5,
              type: 'strength', instruction: 'Add weight'),
        ],
      ),
      ArcPhase(
        name: 'Reverse Cursed Technique',
        description: 'Deload then peak. Recover and grow.',
        weekNumber: 5,
        daysPerWeek: 4,
        exercises: [
          ArcExercise(name: 'Back Squat', sets: 3, reps: 8, type: 'strength',
              instruction: 'Deload: 70% of Phase 2 weight'),
          ArcExercise(name: 'Bench Press', sets: 3, reps: 8, type: 'strength',
              instruction: 'Deload: 70%'),
          ArcExercise(name: 'Romanian Deadlift', sets: 3, reps: 10,
              type: 'strength', instruction: 'Light, stretch hamstrings'),
          ArcExercise(name: 'Face Pulls', sets: 3, reps: 15, type: 'strength',
              instruction: 'Shoulder health'),
        ],
      ),
      ArcPhase(
        name: 'Unlimited Void',
        description: 'Peak performance. Challenge your limits.',
        weekNumber: 7,
        daysPerWeek: 5,
        exercises: [
          ArcExercise(name: 'Back Squat', sets: 5, reps: 3, type: 'strength',
              instruction: 'Heavy triples'),
          ArcExercise(name: 'Bench Press', sets: 5, reps: 3, type: 'strength',
              instruction: 'Heavy triples'),
          ArcExercise(name: 'Deadlift', sets: 5, reps: 3, type: 'strength',
              instruction: 'Heavy triples'),
          ArcExercise(name: 'Overhead Press', sets: 5, reps: 3,
              type: 'strength', instruction: 'Heavy triples'),
        ],
      ),
    ],
    bossFight: BossFight(
      name: 'Sukuna\'s Domain',
      description: 'Set new PRs. Cleave through your limits.',
      bonusXp: 500,
      challenges: [
        ArcExercise(name: 'Squat 1RM', sets: 1, reps: 1, type: 'strength',
            instruction: 'New personal record'),
        ArcExercise(name: 'Bench 1RM', sets: 1, reps: 1, type: 'strength',
            instruction: 'New personal record'),
        ArcExercise(name: 'Deadlift 1RM', sets: 1, reps: 1, type: 'strength',
            instruction: 'New personal record'),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════
  // 6. HYPERBOLIC CHAMBER — Dragon Ball Z
  // ═══════════════════════════════════════════════════════════════════════
  static final hyperbolicChamber = QuestArc(
    id: 'hyperbolic_chamber',
    name: 'Hyperbolic Time Chamber',
    theme: 'Dragon Ball Z',
    emoji: '💥',
    description:
        'Train under 100× gravity. Supersets, drop sets, giant sets — '
        'maximum muscle stimulation in minimum time.',
    durationWeeks: 6,
    difficulty: 'A',
    xpMultiplier: 2.2,
    phases: [
      ArcPhase(
        name: '10× Gravity',
        description: 'Supersets. Two exercises, no rest between.',
        weekNumber: 1,
        exercises: [
          ArcExercise(name: 'Bench Press + Row Superset', sets: 4, reps: 10,
              type: 'strength', restSeconds: 30,
              instruction: 'Bench → Row, 30s rest, repeat'),
          ArcExercise(name: 'Squat + RDL Superset', sets: 4, reps: 10,
              type: 'strength', restSeconds: 30,
              instruction: 'Squat → RDL, 30s rest'),
          ArcExercise(name: 'OHP + Chin-up Superset', sets: 4, reps: 8,
              type: 'strength', restSeconds: 30,
              instruction: 'Press → Chins, 30s rest'),
        ],
      ),
      ArcPhase(
        name: '50× Gravity',
        description: 'Drop sets. Push past failure.',
        weekNumber: 3,
        exercises: [
          ArcExercise(name: 'Bench Press Drop Set', sets: 3, reps: 10,
              type: 'strength',
              instruction: '3 drops per set: heavy→medium→light, no rest'),
          ArcExercise(name: 'Leg Press Drop Set', sets: 3, reps: 12,
              type: 'strength',
              instruction: '3 drops per set'),
          ArcExercise(name: 'Cable Row Drop Set', sets: 3, reps: 10,
              type: 'strength',
              instruction: '3 drops per set'),
          ArcExercise(name: 'Lateral Raise Drop Set', sets: 3, reps: 15,
              type: 'strength', instruction: '3 drops per set'),
        ],
      ),
      ArcPhase(
        name: '100× Gravity',
        description: 'Giant sets. 4 exercises back-to-back.',
        weekNumber: 5,
        daysPerWeek: 5,
        exercises: [
          ArcExercise(name: 'Total Body Giant Set', sets: 4, reps: 10,
              type: 'strength',
              instruction: 'Squat→Bench→Row→Shoulder Press. No rest between.'),
          ArcExercise(name: 'Core Giant Set', sets: 3, reps: 15,
              type: 'strength',
              instruction: 'Crunch→Plank(30s)→Leg Raise→Russian Twist'),
          ArcExercise(name: 'Finisher', sets: 1, reps: 1, type: 'cardio',
              instruction: '500m row or 1min assault bike, all out'),
        ],
      ),
    ],
    bossFight: BossFight(
      name: 'Final Form Frieza',
      description: 'The ultimate superset gauntlet. 50 minutes non-stop.',
      bonusXp: 600,
      challenges: [
        ArcExercise(name: 'Giant Set × 5 rounds', sets: 5, reps: 10,
            type: 'strength',
            instruction: 'Squat→Press→Row→Curl→Dip. 60s rest between rounds.'),
        ArcExercise(name: 'Finisher: 2km Row', sets: 1, reps: 1,
            type: 'cardio', instruction: 'Best time possible'),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════
  // 7. PEAKY DISCIPLINE — Peaky Blinders
  // ═══════════════════════════════════════════════════════════════════════
  static final peakyDiscipline = QuestArc(
    id: 'peaky_discipline',
    name: 'Peaky Discipline',
    theme: 'Peaky Blinders',
    emoji: '🎩',
    description:
        'By order of the Peaky Blinders. Cold showers, boxing, '
        'posture work, and unshakeable discipline.',
    durationWeeks: 4,
    difficulty: 'D',
    xpMultiplier: 1.5,
    phases: [
      ArcPhase(
        name: 'Small Heath',
        description: 'Build the foundation. Discipline over motivation.',
        weekNumber: 1,
        exercises: [
          ArcExercise(name: 'Shadow Boxing', sets: 3, reps: 1, type: 'cardio',
              instruction: '3-minute rounds, stay sharp'),
          ArcExercise(name: 'Push-ups', sets: 4, reps: 20, type: 'strength',
              instruction: 'Perfect form, slow negatives'),
          ArcExercise(name: 'Wall Sits', sets: 3, reps: 60, type: 'endurance',
              instruction: '60-second holds'),
          ArcExercise(name: 'Dead Hangs', sets: 3, reps: 30, type: 'strength',
              instruction: '30-second holds for posture'),
          ArcExercise(name: 'Cold Shower', sets: 1, reps: 1,
              type: 'endurance', instruction: '2-minute cold finish'),
        ],
      ),
      ArcPhase(
        name: 'Camden Town',
        description: 'Take on London. Increase intensity.',
        weekNumber: 3,
        exercises: [
          ArcExercise(name: 'Heavy Bag Work', sets: 5, reps: 1, type: 'cardio',
              instruction: '3-minute rounds, 1-min rest'),
          ArcExercise(name: 'Farmer\'s Walk', sets: 4, reps: 1,
              type: 'strength',
              instruction: '40m carries, heaviest you can'),
          ArcExercise(name: 'Face Pulls', sets: 4, reps: 15, type: 'strength',
              instruction: 'Posture correction'),
          ArcExercise(name: 'Copenhagen Plank', sets: 3, reps: 30,
              type: 'strength', instruction: '30s each side'),
          ArcExercise(name: 'Cold Shower', sets: 1, reps: 1,
              type: 'endurance', instruction: '4-minute cold finish'),
        ],
      ),
    ],
    bossFight: BossFight(
      name: 'Tommy\'s War',
      description: 'Complete 12 rounds of shadow boxing + cold plunge.',
      bonusXp: 300,
      challenges: [
        ArcExercise(name: '12 Rounds Shadow Boxing', sets: 12, reps: 1,
            type: 'cardio', instruction: '3-min rounds, 1-min rest'),
        ArcExercise(name: '5-min Cold Shower', sets: 1, reps: 1,
            type: 'endurance', instruction: 'Full cold, no flinching'),
      ],
    ),
  );
}
