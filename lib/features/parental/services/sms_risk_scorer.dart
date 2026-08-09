import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/parent_dashboard.dart';
import '../../../shared/security/audit_logger.dart';

final smsRiskScorerProvider = Provider<SmsRiskScorer>((ref) {
  return SmsRiskScorer();
});

class SmsRiskScoreResult {
  const SmsRiskScoreResult({
    required this.sender,
    required this.riskLevel,
    required this.confidenceScore, // 0 to 100
    required this.category,
    required this.matchedSignals,
  });

  final String sender;
  final RiskLevel riskLevel;
  final int confidenceScore;
  final String category;
  final List<String> matchedSignals;
}

class SmsRiskScorer {
  // Pattern categories
  static final _groomingKeywords = [
    'dont tell your parents', "don't tell anyone", 'our secret', 'keep it quiet',
    'send a photo', 'send pic', 'are you alone', 'where do you live', 'meet me at'
  ];

  static final _phishingKeywords = [
    'claim your prize', 'bank account suspended', 'verify identity immediately',
    'urgent action required', 'win \$', 'free gift card', 'click here to claim'
  ];

  static final _explicitKeywords = [
    'hate you', 'kill yourself', 'nobody likes you', 'ugly', 'freak', 'loser'
  ];

  /// Performs on-device risk assessment of incoming SMS text.
  /// Raw text is evaluated locally and NOT sent to external servers.
  Future<SmsRiskScoreResult> evaluateMessage({
    required String sender,
    required String messageBody,
  }) async {
    final lower = messageBody.toLowerCase();
    final matchedSignals = <String>[];
    int score = 0;
    String category = 'Safe Message';

    // 1. Check grooming indicators
    for (final kw in _groomingKeywords) {
      if (lower.contains(kw)) {
        score += 35;
        matchedSignals.add('Grooming indicator phrase: "$kw"');
        category = 'Potential Grooming Risk';
      }
    }

    // 2. Check phishing indicators
    for (final kw in _phishingKeywords) {
      if (lower.contains(kw)) {
        score += 30;
        matchedSignals.add('Phishing / scam phrase: "$kw"');
        category = 'Scam / Phishing';
      }
    }

    // 3. Check cyberbullying / toxic language
    for (final kw in _explicitKeywords) {
      if (lower.contains(kw)) {
        score += 25;
        matchedSignals.add('Harmful / toxic language: "$kw"');
        category = 'Harassment / Cyberbullying';
      }
    }

    // 4. Check embedded URL
    if (RegExp(r'https?://[^\s]+').hasMatch(messageBody)) {
      score += 15;
      matchedSignals.add('Contains unverified external web link');
    }

    // Determine risk level
    RiskLevel level;
    if (score >= 60) {
      level = RiskLevel.high;
    } else if (score >= 30) {
      level = RiskLevel.medium;
    } else {
      level = RiskLevel.low;
    }

    if (level != RiskLevel.low) {
      await AuditLogger.log(
        event: SecurityEvent.smsRiskDetected,
        detail: 'sender=$sender category=$category score=$score signals_count=${matchedSignals.length}',
      );
    }

    return SmsRiskScoreResult(
      sender: sender,
      riskLevel: level,
      confidenceScore: score.clamp(0, 100),
      category: category,
      matchedSignals: matchedSignals,
    );
  }
}
