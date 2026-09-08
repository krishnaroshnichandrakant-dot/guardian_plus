import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Home Risk State ────────────────────────────────────────────────────────

enum RiskLevel { low, medium, high, critical }

class HomeState {
  const HomeState({
    required this.overallRisk,
    required this.cyberRiskScore,
    required this.safetyStatus,
    required this.recentAlerts,
    required this.activeFeatures,
  });

  final RiskLevel overallRisk;
  final int cyberRiskScore;           // 0–100, higher = safer
  final String safetyStatus;
  final List<HomeAlert> recentAlerts;
  final List<String> activeFeatures;

  String get riskLabel {
    switch (overallRisk) {
      case RiskLevel.low:      return 'LOW RISK';
      case RiskLevel.medium:   return 'MODERATE RISK';
      case RiskLevel.high:     return 'ELEVATED RISK';
      case RiskLevel.critical: return 'CRITICAL';
    }
  }

  String get riskSubtitle {
    switch (overallRisk) {
      case RiskLevel.low:      return 'Your protection systems are active.';
      case RiskLevel.medium:   return 'Some items need attention.';
      case RiskLevel.high:     return 'Action recommended.';
      case RiskLevel.critical: return 'Immediate action required.';
    }
  }

  HomeState copyWith({
    RiskLevel? overallRisk,
    int? cyberRiskScore,
    String? safetyStatus,
    List<HomeAlert>? recentAlerts,
    List<String>? activeFeatures,
  }) =>
      HomeState(
        overallRisk:    overallRisk    ?? this.overallRisk,
        cyberRiskScore: cyberRiskScore ?? this.cyberRiskScore,
        safetyStatus:   safetyStatus   ?? this.safetyStatus,
        recentAlerts:   recentAlerts   ?? this.recentAlerts,
        activeFeatures: activeFeatures ?? this.activeFeatures,
      );
}

class HomeAlert {
  const HomeAlert({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.severity,
    this.featureTag,
  });
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final RiskLevel severity;
  final String? featureTag;
}

// ── HomeNotifier ───────────────────────────────────────────────────────────

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(_buildInitialState());

  static HomeState _buildInitialState() => HomeState(
    overallRisk: RiskLevel.low,
    cyberRiskScore: 94,
    safetyStatus: 'All systems active',
    activeFeatures: ['CyberShield', 'Guardian Safety', 'Audit'],
    recentAlerts: [
      HomeAlert(
        id: 'a1',
        title: 'Suspicious link blocked',
        subtitle: 'CyberShield intercepted a phishing URL',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        severity: RiskLevel.medium,
        featureTag: 'CyberShield',
      ),
      HomeAlert(
        id: 'a2',
        title: 'Wi-Fi scan complete',
        subtitle: 'Network appears secure (WPA2)',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        severity: RiskLevel.low,
        featureTag: 'CyberShield',
      ),
    ],
  );

  void refresh() {
    // In production: fetch fresh aggregated state from Firestore
    state = state.copyWith(cyberRiskScore: state.cyberRiskScore);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(),
);
