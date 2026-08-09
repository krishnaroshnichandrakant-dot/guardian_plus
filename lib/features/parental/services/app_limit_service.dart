import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final appLimitServiceProvider = Provider<AppLimitService>((ref) {
  return AppLimitService();
});

class AppLimitRule {
  const AppLimitRule({
    required this.packageName,
    required this.appName,
    required this.maxMinutesPerDay,
    required this.isEnabled,
  });

  final String packageName;
  final String appName;
  final int maxMinutesPerDay;
  final bool isEnabled;

  Map<String, dynamic> toMap() => {
        'packageName': packageName,
        'appName': appName,
        'maxMinutesPerDay': maxMinutesPerDay,
        'isEnabled': isEnabled,
      };

  factory AppLimitRule.fromMap(Map map) => AppLimitRule(
        packageName: map['packageName'] as String,
        appName: map['appName'] as String,
        maxMinutesPerDay: map['maxMinutesPerDay'] as int,
        isEnabled: map['isEnabled'] as bool,
      );
}

class AppLimitService {
  static const _boxName = 'gp_app_limits';

  Future<Box<Map>> _getBox() async {
    return await Hive.openBox<Map>(_boxName);
  }

  Future<void> setLimit(AppLimitRule rule) async {
    final box = await _getBox();
    await box.put(rule.packageName, rule.toMap());
  }

  Future<List<AppLimitRule>> getLimits() async {
    final box = await _getBox();
    if (box.isEmpty) {
      // Default limits for demonstration
      final defaults = [
        const AppLimitRule(
          packageName: 'com.zhiliaoapp.musically',
          appName: 'TikTok',
          maxMinutesPerDay: 120, // 2 hrs
          isEnabled: true,
        ),
        const AppLimitRule(
          packageName: 'com.instagram.android',
          appName: 'Instagram',
          maxMinutesPerDay: 90, // 1.5 hrs
          isEnabled: true,
        ),
      ];
      for (final d in defaults) {
        await box.put(d.packageName, d.toMap());
      }
      return defaults;
    }

    return box.values.map((map) => AppLimitRule.fromMap(map)).toList();
  }
}
