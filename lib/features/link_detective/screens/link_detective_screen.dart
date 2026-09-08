import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../providers/link_detective_provider.dart';

/// Link Detective — Gamified phishing literacy trainer (child-only).
///
/// Shows one pre-verified challenge link at a time (plain text, never opened).
/// Child guesses: Safe / Suspicious / Unsafe.
/// Earns points for correct answers, builds streaks, hits daily limit (10/day).
///
/// This is NOT the CyberShield URL Scanner — it uses a curated, pre-verified
/// challenge bank. Children's guesses are never used as training data labels
/// for unverified external links.
class LinkDetectiveScreen extends ConsumerWidget {
  const LinkDetectiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(linkDetectiveProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.detectiveTeal)),
      );
    }

    if (state.sessionComplete) {
      return _SessionCompleteScreen(score: state.score, streak: state.streak, completed: state.todayCompleted);
    }

    return _ChallengeScreen(state: state);
  }
}

// ── Challenge Screen ──────────────────────────────────────────────────────

class _ChallengeScreen extends ConsumerStatefulWidget {
  const _ChallengeScreen({required this.state});
  final LinkDetectiveState state;

  @override
  ConsumerState<_ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends ConsumerState<_ChallengeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scoreRollController;

  @override
  void initState() {
    super.initState();
    _scoreRollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _scoreRollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final challenge = state.currentChallenge;
    if (challenge == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(state),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(DesignTokens.screenPadding),
                child: Column(
                  children: [
                    const SizedBox(height: DesignTokens.spacingMd),
                    _buildProgressBar(state),
                    const SizedBox(height: DesignTokens.spacingXl),
                    _buildChallengeCard(challenge, state),
                    const SizedBox(height: DesignTokens.spacingXl),
                    if (!state.showResult) ...[
                      _buildAnswerButtons(state),
                    ] else ...[
                      _buildResultCard(state, challenge),
                      const SizedBox(height: DesignTokens.spacingLg),
                      _buildNextButton(state),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LinkDetectiveState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        children: [
          // Shield mascot logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.gradientDetective,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Text('🕵️', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LINK DETECTIVE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Phishing Literacy Trainer',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.detectiveTeal,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Score display
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${state.score} pts',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.detectiveTeal,
                ),
              ),
              if (state.streak > 1)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 12)),
                    Text(
                      ' ${state.streak} streak',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.detectiveOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(LinkDetectiveState state) {
    final progress = state.todayCompleted / LinkDetectiveState.dailyLimit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Progress',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.onSurfaceMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${state.todayCompleted}/${LinkDetectiveState.dailyLimit}',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: AppColors.detectiveTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceElevated,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.detectiveTeal),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeCard(LinkChallenge challenge, LinkDetectiveState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: AppColors.detectiveTeal.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.detectiveTeal.withValues(alpha: 0.06),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.detectiveTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
                child: Text(
                  _difficultyLabel(challenge.difficulty),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.detectiveTeal,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Q${state.currentIndex + 1}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: AppColors.onSurfaceMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Is this link safe to click?',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // Link display (plain text, styled like a browser address bar)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded,
                    size: 16, color: AppColors.onSurfaceMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    challenge.displayUrl,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '⚠️ Do not try to open this link — this is a training exercise.',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.onSurfaceMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.04, end: 0);
  }

  Widget _buildAnswerButtons(LinkDetectiveState state) {
    return Column(
      children: [
        Text(
          'What do you think?',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceMuted,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _AnswerButton(
              label: 'Safe',
              emoji: '✅',
              color: AppColors.emeraldGreen,
              onTap: () => _onAnswer(ChallengeLabel.safe),
            )),
            const SizedBox(width: 10),
            Expanded(child: _AnswerButton(
              label: 'Suspicious',
              emoji: '⚠️',
              color: AppColors.warningAmber,
              onTap: () => _onAnswer(ChallengeLabel.suspicious),
            )),
            const SizedBox(width: 10),
            Expanded(child: _AnswerButton(
              label: 'Unsafe',
              emoji: '🚫',
              color: AppColors.errorRed,
              onTap: () => _onAnswer(ChallengeLabel.unsafe),
            )),
          ],
        ),
      ],
    );
  }

  void _onAnswer(ChallengeLabel label) {
    HapticFeedback.mediumImpact();
    ref.read(linkDetectiveProvider.notifier).selectAnswer(label);
  }

  Widget _buildResultCard(LinkDetectiveState state, LinkChallenge challenge) {
    final correct = state.isCorrect;
    final color = correct ? AppColors.emeraldGreen : AppColors.errorRed;
    final userLabel = state.selectedLabel;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    correct ? '🎉 Correct!' : '❌ Not quite',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  if (correct)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                      ),
                      child: Text(
                        '+${_pointsForDifficulty(challenge.difficulty)} pts',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.emeraldGreen,
                        ),
                      ),
                    ),
                ],
              ),
              if (!correct && userLabel != null) ...[
                const SizedBox(height: 6),
                Text(
                  'You said: ${userLabel.emoji} ${userLabel.displayName}  •  Answer: ${challenge.correctLabel.emoji} ${challenge.correctLabel.displayName}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 1,
                color: AppColors.outline,
              ),
              const SizedBox(height: 12),
              Text(
                challenge.explanation,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurface,
                  height: 1.5,
                ),
              ),
              if (state.streak > 1) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '${state.streak} in a row! Keep going!',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.detectiveOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.03, end: 0)
            .then()
            .shimmer(duration: 600.ms, color: color.withValues(alpha: 0.1)),
      ],
    );
  }

  Widget _buildNextButton(LinkDetectiveState state) {
    final label = state.hasNext && !state.sessionComplete
        ? 'Next Challenge →'
        : 'See Results';
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        ref.read(linkDetectiveProvider.notifier).nextChallenge();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.detectiveTeal,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, DesignTokens.buttonHeightLg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _difficultyLabel(ChallengeDifficulty d) {
    switch (d) {
      case ChallengeDifficulty.easy:   return 'EASY';
      case ChallengeDifficulty.medium: return 'MEDIUM';
      case ChallengeDifficulty.hard:   return 'HARD';
    }
  }

  int _pointsForDifficulty(ChallengeDifficulty d) {
    switch (d) {
      case ChallengeDifficulty.easy:   return 10;
      case ChallengeDifficulty.medium: return 20;
      case ChallengeDifficulty.hard:   return 35;
    }
  }
}

// ── Answer Button ──────────────────────────────────────────────────────────

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onTap,
  });
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.95, 0.95));
  }
}

// ── Session Complete Screen ────────────────────────────────────────────────

class _SessionCompleteScreen extends StatelessWidget {
  const _SessionCompleteScreen({
    required this.score,
    required this.streak,
    required this.completed,
  });
  final int score;
  final int streak;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🎉', style: const TextStyle(fontSize: 64))
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text(
                  'Great job, Detective!',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "You've completed today's challenges.\nCome back tomorrow for more! 🌟",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.onSurfaceMuted,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Score summary card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                    border: Border.all(color: AppColors.detectiveTeal.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(value: '$score', label: 'Points', color: AppColors.detectiveTeal),
                      _StatItem(value: '$completed', label: 'Completed', color: AppColors.emeraldGreen),
                      _StatItem(value: '$streak 🔥', label: 'Best Streak', color: AppColors.detectiveOrange),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 14, color: AppColors.onSurfaceMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Daily limit: 10 challenges/day. This keeps the game fun and the learning effective.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onSurfaceMuted,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.onSurfaceMuted,
          ),
        ),
      ],
    );
  }
}
