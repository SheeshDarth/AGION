import 'dart:math';

/// Curated daily quotes with deep meanings — not generic "you can do it" fluff.
/// Each quote is paired with its real-world meaning/context.
class DailyQuotes {
  DailyQuotes._();

  static final _random = Random();

  /// Get the quote of the day (deterministic by date so it stays the same).
  static Quote ofTheDay() {
    final dayOfYear = DateTime.now().difference(
        DateTime(DateTime.now().year, 1, 1)).inDays;
    return _quotes[dayOfYear % _quotes.length];
  }

  /// Get a random quote.
  static Quote random() => _quotes[_random.nextInt(_quotes.length)];

  static const _quotes = [
    // ─── DISCIPLINE & CONSISTENCY ─────────────────────────────────
    Quote(
      text: '"We do not rise to the level of our goals, we fall to the level of our systems."',
      author: 'James Clear',
      meaning: 'Goals mean nothing without daily systems. Your habits define your ceiling. Build the system first.',
      category: 'discipline',
    ),
    Quote(
      text: '"The pain you feel today will be the strength you feel tomorrow."',
      author: 'Arnold Schwarzenegger',
      meaning: 'Muscle fibers tear during training and rebuild stronger. Discomfort is literally the mechanism of growth.',
      category: 'growth',
    ),
    Quote(
      text: '"I fear not the man who has practiced 10,000 kicks once, but I fear the man who has practiced one kick 10,000 times."',
      author: 'Bruce Lee',
      meaning: 'Mastery comes from depth, not breadth. Consistency in a few key movements beats variety without focus.',
      category: 'mastery',
    ),
    Quote(
      text: '"The obstacle is the way."',
      author: 'Marcus Aurelius',
      meaning: 'Stoic principle: the hardest thing in front of you is exactly what will make you stronger. Don\'t avoid it — go through it.',
      category: 'stoic',
    ),
    Quote(
      text: '"You have power over your mind — not outside events. Realize this, and you will find strength."',
      author: 'Marcus Aurelius',
      meaning: 'Control what\'s in your control: your effort, your discipline, your response. Let go of what you can\'t.',
      category: 'stoic',
    ),
    Quote(
      text: '"Suffer the pain of discipline or suffer the pain of regret."',
      author: 'Jim Rohn',
      meaning: 'Pick your pain. Discipline is temporary and productive. Regret is permanent and hollow.',
      category: 'discipline',
    ),

    // ─── TRANSFORMATION ───────────────────────────────────────────
    Quote(
      text: '"The last three or four reps is what makes the muscle grow. This area of pain divides a champion from someone who is not a champion."',
      author: 'Arnold Schwarzenegger',
      meaning: 'Growth happens at the edge of failure, not in comfortable sets. Train to that uncomfortable place.',
      category: 'intensity',
    ),
    Quote(
      text: '"No man has the right to be an amateur in the matter of physical training."',
      author: 'Socrates',
      meaning: 'The ancient Greeks believed physical fitness was a philosophical duty. Your body is the vehicle for everything else you do.',
      category: 'philosophy',
    ),
    Quote(
      text: '"The body achieves what the mind believes."',
      author: 'Napoleon Hill',
      meaning: 'Visualization and mental commitment precede physical change. Your mind gives up before your body does.',
      category: 'mindset',
    ),
    Quote(
      text: '"What stands in the way becomes the way."',
      author: 'Ryan Holiday',
      meaning: 'Modern stoicism: your biggest obstacle is your greatest opportunity for growth. The heavy weight IS the training.',
      category: 'stoic',
    ),

    // ─── LONG-TERM THINKING ───────────────────────────────────────
    Quote(
      text: '"A year from now you will wish you had started today."',
      author: 'Karen Lamb',
      meaning: 'Compound effect. Every day you delay is a day of progress lost. Future you will thank present you for starting.',
      category: 'urgency',
    ),
    Quote(
      text: '"It does not matter how slowly you go as long as you do not stop."',
      author: 'Confucius',
      meaning: 'Progress isn\'t linear. Bad days happen. What matters is you come back. Even a 50% effort day beats a 0% day.',
      category: 'patience',
    ),
    Quote(
      text: '"The man who moves a mountain begins by carrying away small stones."',
      author: 'Confucius',
      meaning: 'S-rank isn\'t achieved in a day. It\'s achieved by showing up 300+ times. Small daily actions = massive transformation.',
      category: 'patience',
    ),
    Quote(
      text: '"Doubt kills more dreams than failure ever will."',
      author: 'Suzy Kassem',
      meaning: 'You won\'t fail because you tried and fell short. You\'ll fail because you never tried. Start.',
      category: 'mindset',
    ),

    // ─── INTENSITY & WARRIOR MINDSET ──────────────────────────────
    Quote(
      text: '"If you always put limits on everything you do, physical or anything else, it will spread into your work and into your life."',
      author: 'Bruce Lee',
      meaning: 'How you train is how you live. Train with intent and it flows into career, relationships, everything.',
      category: 'intensity',
    ),
    Quote(
      text: '"I\'m not telling you it\'s going to be easy. I\'m telling you it\'s going to be worth it."',
      author: 'Art Williams',
      meaning: 'Transformation requires sacrifice. But the person you become on the other side is unrecognizable from who you were.',
      category: 'growth',
    ),
    Quote(
      text: '"The iron never lies to you. Two hundred pounds is always two hundred pounds."',
      author: 'Henry Rollins',
      meaning: 'The gym is the most honest place on earth. You either lift it or you don\'t. No politics, no excuses.',
      category: 'intensity',
    ),
    Quote(
      text: '"Arise from the darkness."',
      author: 'Solo Leveling',
      meaning: 'Sung Jin-Woo started as the weakest E-Rank and became the Shadow Monarch. Your starting point doesn\'t define your ceiling.',
      category: 'anime',
    ),
    Quote(
      text: '"I am the one thing in life I can control."',
      author: 'Hamilton',
      meaning: 'You can\'t control genetics, circumstances, or other people. But you can control your effort, your diet, your sleep, and your training.',
      category: 'discipline',
    ),
    Quote(
      text: '"Don\'t count the days. Make the days count."',
      author: 'Muhammad Ali',
      meaning: 'It\'s not about how many days you\'ve been training. It\'s about how much intent you brought to each one.',
      category: 'intensity',
    ),

    // ─── SELF-IMPROVEMENT ─────────────────────────────────────────
    Quote(
      text: '"Your body hears everything your mind says."',
      author: 'Naomi Judd',
      meaning: 'Negative self-talk physically limits performance. Talk to yourself like you would talk to your best friend.',
      category: 'mindset',
    ),
    Quote(
      text: '"Champions aren\'t made in gyms. Champions are made from something deep inside them — a desire, a dream, a vision."',
      author: 'Muhammad Ali',
      meaning: 'The gym is just the tool. What drives you — your vision of who you want to become — that\'s the real engine.',
      category: 'growth',
    ),
    Quote(
      text: '"Comfort is the enemy of progress."',
      author: 'P.T. Barnum',
      meaning: 'If your workouts feel easy, you\'re not growing. Progressive overload isn\'t optional — it\'s the law.',
      category: 'intensity',
    ),
    Quote(
      text: '"What\'s the point of being alive if you don\'t at least try to do something remarkable?"',
      author: 'John Green',
      meaning: 'You have one body, one life. Building it into something extraordinary isn\'t vanity — it\'s respect for the gift.',
      category: 'philosophy',
    ),

    // ─── SOLO LEVELING INSPIRED ───────────────────────────────────
    Quote(
      text: '"I alone level up."',
      author: 'Sung Jin-Woo',
      meaning: 'No one can do the reps for you. No one can eat clean for you. Your ascension is yours alone.',
      category: 'anime',
    ),
    Quote(
      text: '"The difference between the novice and the master is that the master has failed more times than the novice has tried."',
      author: 'Koro-sensei (Assassination Classroom)',
      meaning: 'Failure is data. Every failed rep, every missed day, every setback teaches you something. Fail forward.',
      category: 'anime',
    ),
    Quote(
      text: '"A lesson without pain is meaningless. That\'s because no one can gain without sacrificing something."',
      author: 'Edward Elric (FMA)',
      meaning: 'Equivalent exchange applies to fitness. You sacrifice comfort, time, and convenience. In return, you gain a body and mind most only dream of.',
      category: 'anime',
    ),
    Quote(
      text: '"Giving up kills people. When people reject giving up, they finally win the right to transcend humanity."',
      author: 'Aizen Sosuke (Bleach)',
      meaning: 'The people who achieve S-Rank aren\'t special. They\'re just the ones who refused to quit before everyone else.',
      category: 'anime',
    ),
  ];
}

class Quote {
  final String text;
  final String author;
  final String meaning;
  final String category;

  const Quote({
    required this.text,
    required this.author,
    required this.meaning,
    required this.category,
  });
}
