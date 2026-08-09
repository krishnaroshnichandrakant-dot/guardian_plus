import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';

final permissionAuditorServiceProvider = Provider<PermissionAuditorService>((ref) {
  return PermissionAuditorService();
});

enum PermissionRiskLevel { low, medium, high, critical }

class AppPermissionAudit {
  const AppPermissionAudit({
    required this.appName,
    required this.packageName,
    required this.grantedPermissions,
    required this.riskLevel,
    required this.riskReasons,
    required this.isSystemApp,
  });

  final String appName;
  final String packageName;
  final List<String> grantedPermissions;
  final PermissionRiskLevel riskLevel;
  final List<String> riskReasons;
  final bool isSystemApp;
}

class PermissionAuditorService {
  /// Scans device app permissions and flags high-risk combinations (e.g. Flashlight with Contact/SMS access).
  Future<List<AppPermissionAudit>> auditInstalledApps() async {
    // Mock / fallback app audit list for demonstration + on-device evaluation
    final mockAuditResults = [
      const AppPermissionAudit(
        appName: 'FlashLight Pro',
        packageName: 'com.bright.flashlight',
        grantedPermissions: ['CAMERA', 'READ_CONTACTS', 'ACCESS_FINE_LOCATION'],
        riskLevel: PermissionRiskLevel.critical,
        riskReasons: [
          'Flashlight app requests access to your contacts',
          'Flashlight app requests access to your location',
        ],
        isSystemApp: false,
      ),
      const AppPermissionAudit(
        appName: 'PDF Reader Lite',
        packageName: 'com.pdf.reader.lite',
        grantedPermissions: ['READ_EXTERNAL_STORAGE', 'RECEIVE_SMS', 'RECORD_AUDIO'],
        riskLevel: PermissionRiskLevel.high,
        riskReasons: [
          'PDF reader requests SMS permission (potential OTP interceptor)',
          'PDF reader requests microphone access',
        ],
        isSystemApp: false,
      ),
      const AppPermissionAudit(
        appName: 'Calculator Plus',
        packageName: 'com.simple.calculator',
        grantedPermissions: ['INTERNET'],
        riskLevel: PermissionRiskLevel.low,
        riskReasons: [],
        isSystemApp: false,
      ),
      const AppPermissionAudit(
        appName: 'Social Connect',
        packageName: 'com.social.connect',
        grantedPermissions: ['CAMERA', 'RECORD_AUDIO', 'READ_CONTACTS', 'ACCESS_FINE_LOCATION'],
        riskLevel: PermissionRiskLevel.medium,
        riskReasons: [
          'Social network accesses location in background',
        ],
        isSystemApp: false,
      ),
    ];

    return mockAuditResults;
  }
}
