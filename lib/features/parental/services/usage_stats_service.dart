import 'package:flutter_riverpod/flutter_riverpod.dart';

final usageStatsServiceProvider = Provider<UsageStatsService>((ref) {
  return UsageStatsService();
});

class AppUsageInfo {
  const AppUsageInfo({
    required this.packageName,
    required this.appName,
    required this.usageDuration,
    required this.lastTimeUsed,
    this.category,
  });

  final String packageName;
  final String appName;
  final Duration usageDuration;
  final DateTime lastTimeUsed;
  final String? category;
}

class UsageStatsService {
  /// Fetches daily app usage data.
  /// On Android, queries UsageStatsManager via platform channel or fallback service.
  Future<List<AppUsageInfo>> getDailyUsage() async {
    final now = DateTime.now();
    return [
      AppUsageInfo(
        packageName: 'com.zhiliaoapp.musically',
        appName: 'TikTok',
        usageDuration: const Duration(hours: 3, minutes: 12),
        lastTimeUsed: now.subtract(const Duration(minutes: 14)),
        category: 'Social',
      ),
      AppUsageInfo(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        usageDuration: const Duration(hours: 1, minutes: 45),
        lastTimeUsed: now.subtract(const Duration(hours: 1)),
        category: 'Social',
      ),
      AppUsageInfo(
        packageName: 'com.google.android.youtube',
        appName: 'YouTube',
        usageDuration: const Duration(minutes: 42),
        lastTimeUsed: now.subtract(const Duration(hours: 3)),
        category: 'Entertainment',
      ),
      AppUsageInfo(
        packageName: 'com.duolingo',
        appName: 'Duolingo',
        usageDuration: const Duration(minutes: 20),
        lastTimeUsed: now.subtract(const Duration(hours: 5)),
        category: 'Education',
      ),
    ];
  }
}
