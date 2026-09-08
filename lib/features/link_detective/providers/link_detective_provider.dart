import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single phishing literacy challenge from the curated challenge bank.
/// IMPORTANT: These are pre-verified, admin-curated entries.
/// Children's guesses are NEVER used as ground-truth labels for unverified links.
class LinkChallenge {
  const LinkChallenge({
    required this.id,
    required this.displayUrl,
    required this.correctLabel,
    required this.explanation,
    required this.difficulty,
    required this.tags,
  });

  final String id;
  /// Displayed as plain text — NEVER navigated to or opened
  final String displayUrl;
  final ChallengeLabel correctLabel;
  final String explanation;  // Age-appropriate explanation of why
  final ChallengeDifficulty difficulty;
  final List<String> tags;    // e.g. ['phishing', 'banking', 'lookalike']
}

enum ChallengeLabel { safe, suspicious, unsafe }
enum ChallengeDifficulty { easy, medium, hard }

extension ChallengeLabelExt on ChallengeLabel {
  String get displayName {
    switch (this) {
      case ChallengeLabel.safe:       return 'Safe';
      case ChallengeLabel.suspicious: return 'Suspicious';
      case ChallengeLabel.unsafe:     return 'Unsafe';
    }
  }

  String get emoji {
    switch (this) {
      case ChallengeLabel.safe:       return '✅';
      case ChallengeLabel.suspicious: return '⚠️';
      case ChallengeLabel.unsafe:     return '🚫';
    }
  }
}

// ── Link Detective State ────────────────────────────────────────────────────

class LinkDetectiveState {
  const LinkDetectiveState({
    required this.challenges,
    required this.currentIndex,
    required this.selectedLabel,
    required this.showResult,
    required this.score,
    required this.streak,
    required this.todayCompleted,
    required this.sessionComplete,
    required this.isLoading,
  });

  final List<LinkChallenge> challenges;
  final int currentIndex;
  final ChallengeLabel? selectedLabel;
  final bool showResult;
  final int score;
  final int streak;
  final int todayCompleted;
  final bool sessionComplete;  // Reached daily limit (10/day)
  final bool isLoading;

  static const int dailyLimit = 10;

  bool get isCorrect =>
      selectedLabel != null &&
      currentIndex < challenges.length &&
      selectedLabel == challenges[currentIndex].correctLabel;

  LinkChallenge? get currentChallenge =>
      currentIndex < challenges.length ? challenges[currentIndex] : null;

  bool get hasNext => currentIndex < challenges.length - 1;

  LinkDetectiveState copyWith({
    List<LinkChallenge>? challenges,
    int? currentIndex,
    ChallengeLabel? selectedLabel,
    bool clearSelectedLabel = false,
    bool? showResult,
    int? score,
    int? streak,
    int? todayCompleted,
    bool? sessionComplete,
    bool? isLoading,
  }) =>
      LinkDetectiveState(
        challenges:      challenges      ?? this.challenges,
        currentIndex:    currentIndex    ?? this.currentIndex,
        selectedLabel:   clearSelectedLabel ? null : (selectedLabel ?? this.selectedLabel),
        showResult:      showResult      ?? this.showResult,
        score:           score           ?? this.score,
        streak:          streak          ?? this.streak,
        todayCompleted:  todayCompleted  ?? this.todayCompleted,
        sessionComplete: sessionComplete ?? this.sessionComplete,
        isLoading:       isLoading       ?? this.isLoading,
      );
}

// ── LinkDetectiveNotifier ────────────────────────────────────────────────────

class LinkDetectiveNotifier extends StateNotifier<LinkDetectiveState> {
  LinkDetectiveNotifier() : super(_buildInitialState());

  static LinkDetectiveState _buildInitialState() {
    return LinkDetectiveState(
      challenges: _curatedChallenges,
      currentIndex: 0,
      selectedLabel: null,
      showResult: false,
      score: 0,
      streak: 0,
      todayCompleted: 0,
      sessionComplete: false,
      isLoading: false,
    );
  }

  void selectAnswer(ChallengeLabel label) {
    if (state.showResult) return; // Already answered
    final challenge = state.currentChallenge;
    if (challenge == null) return;

    final isCorrect = label == challenge.correctLabel;
    final newScore = isCorrect ? state.score + _pointsForDifficulty(challenge.difficulty) : state.score;
    final newStreak = isCorrect ? state.streak + 1 : 0;
    final newCompleted = state.todayCompleted + 1;
    final reachedLimit = newCompleted >= LinkDetectiveState.dailyLimit;

    state = state.copyWith(
      selectedLabel: label,
      showResult: true,
      score: newScore,
      streak: newStreak,
      todayCompleted: newCompleted,
      sessionComplete: reachedLimit,
    );
  }

  void nextChallenge() {
    if (state.sessionComplete) return;
    if (!state.hasNext) {
      state = state.copyWith(sessionComplete: true);
      return;
    }
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      showResult: false,
      clearSelectedLabel: true,
    );
  }

  void resetForTesting() {
    state = _buildInitialState();
  }

  static int _pointsForDifficulty(ChallengeDifficulty d) {
    switch (d) {
      case ChallengeDifficulty.easy:   return 10;
      case ChallengeDifficulty.medium: return 20;
      case ChallengeDifficulty.hard:   return 35;
    }
  }

  // ── Curated challenge bank (pre-verified, admin-maintained) ──────────────
  // These are EDUCATIONAL examples, not live links. Phishing examples use
  // clearly fictitious or known-bad domains from public phishing datasets.
  static final List<LinkChallenge> _curatedChallenges = [
    const LinkChallenge(
      id: 'c1',
      displayUrl: 'https://www.google.com/maps',
      correctLabel: ChallengeLabel.safe,
      explanation: '✅ This is the real Google Maps website. "google.com" is Google\'s official domain, and "https://" means the connection is secure. The path "/maps" is a normal section of their website.',
      difficulty: ChallengeDifficulty.easy,
      tags: ['legitimate', 'search-engine'],
    ),
    const LinkChallenge(
      id: 'c2',
      displayUrl: 'http://paypa1.com/account/verify',
      correctLabel: ChallengeLabel.unsafe,
      explanation: '🚫 Tricky! "paypa1.com" uses the number "1" instead of the letter "l" to look like PayPal. It\'s also using "http://" (no padlock). This is a fake site designed to steal your password!',
      difficulty: ChallengeDifficulty.medium,
      tags: ['lookalike', 'typosquatting', 'financial'],
    ),
    const LinkChallenge(
      id: 'c3',
      displayUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      correctLabel: ChallengeLabel.safe,
      explanation: '✅ This is a real YouTube link. "youtube.com" is the official site, and the long code after "v=" is just the video ID — completely normal for YouTube URLs.',
      difficulty: ChallengeDifficulty.easy,
      tags: ['legitimate', 'video'],
    ),
    const LinkChallenge(
      id: 'c4',
      displayUrl: 'http://193.142.58.23/win-prize-click-now',
      correctLabel: ChallengeLabel.unsafe,
      explanation: '🚫 Three big red flags! 1) Uses a raw number address (193.142.58.23) instead of a real website name. 2) Uses "http://" (not secure). 3) "win-prize-click-now" is a classic scam phrase. Never click these!',
      difficulty: ChallengeDifficulty.easy,
      tags: ['ip-address', 'prize-scam'],
    ),
    const LinkChallenge(
      id: 'c5',
      displayUrl: 'https://signin.amazon.co.uk.security-update.com/login',
      correctLabel: ChallengeLabel.unsafe,
      explanation: '🚫 This is very sneaky! It starts with "amazon.co.uk" which looks real — but the actual website is "security-update.com". Scammers add real brand names as sub-parts to trick you. Always read the domain from right to left!',
      difficulty: ChallengeDifficulty.hard,
      tags: ['subdomain-trick', 'brand-impersonation'],
    ),
    const LinkChallenge(
      id: 'c6',
      displayUrl: 'https://en.wikipedia.org/wiki/Cybersecurity',
      correctLabel: ChallengeLabel.safe,
      explanation: '✅ This is Wikipedia\'s real website. "wikipedia.org" is the official domain, "en." means it\'s the English version, and the path shows it\'s an article about Cybersecurity.',
      difficulty: ChallengeDifficulty.easy,
      tags: ['legitimate', 'educational'],
    ),
    const LinkChallenge(
      id: 'c7',
      displayUrl: 'https://bit.ly/3xKzAbc',
      correctLabel: ChallengeLabel.suspicious,
      explanation: '⚠️ Bit.ly is a link shortener — it hides where the link actually goes. It could lead to a safe site, but you can\'t know without checking. Always be cautious with shortened links, and use a scanner before clicking!',
      difficulty: ChallengeDifficulty.medium,
      tags: ['url-shortener', 'unknown-destination'],
    ),
    const LinkChallenge(
      id: 'c8',
      displayUrl: 'http://free-iphone15-winner.tk/claim',
      correctLabel: ChallengeLabel.unsafe,
      explanation: '🚫 Multiple red flags: 1) ".tk" domains are free and loved by scammers. 2) "free-iphone15-winner" is a prize scam. 3) Uses insecure "http://". Nobody gives away free iPhones like this!',
      difficulty: ChallengeDifficulty.easy,
      tags: ['prize-scam', 'suspicious-tld'],
    ),
    const LinkChallenge(
      id: 'c9',
      displayUrl: 'https://www.instagram.com/p/ABC123XYZ/',
      correctLabel: ChallengeLabel.safe,
      explanation: '✅ This is a real Instagram post link. "instagram.com" is the official domain, and the "/p/..." path is how Instagram shares individual posts.',
      difficulty: ChallengeDifficulty.easy,
      tags: ['legitimate', 'social-media'],
    ),
    const LinkChallenge(
      id: 'c10',
      displayUrl: 'https://login-secure.hdfc-bank-update.co.in/verify',
      correctLabel: ChallengeLabel.unsafe,
      explanation: '🚫 This looks like HDFC Bank but it\'s not! The real website would be "hdfcbank.com". "hdfc-bank-update.co.in" is a completely different fake domain using HDFC\'s name to trick you. Banks never ask you to verify your account through random links!',
      difficulty: ChallengeDifficulty.hard,
      tags: ['banking-phishing', 'brand-impersonation', 'india'],
    ),
  ];
}

final linkDetectiveProvider =
    StateNotifierProvider<LinkDetectiveNotifier, LinkDetectiveState>(
  (ref) => LinkDetectiveNotifier(),
);
