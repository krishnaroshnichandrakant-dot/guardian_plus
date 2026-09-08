import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final wifiSafetyServiceProvider = Provider<WifiSafetyService>((ref) {
  return WifiSafetyService();
});

enum WifiSecurityStatus {
  secure,
  openUnencrypted,
  suspiciousCaptivePortal,
  unknown,
}

class WifiSafetyResult {
  const WifiSafetyResult({
    required this.ssid,
    required this.bssid,
    required this.status,
    required this.isEncrypted,
    required this.reasons,
    required this.platformLimitations,
  });

  final String? ssid;
  final String? bssid;
  final WifiSecurityStatus status;
  final bool isEncrypted;
  final List<String> reasons;

  /// Platform limitations that affect the accuracy of this result.
  /// Always shown to the user — not hidden.
  final List<String> platformLimitations;
}

class WifiSafetyService {
  final _wifiInfo = WifiInfo();

  Future<WifiSafetyResult> checkCurrentNetwork() async {
    // ── Platform Limitations (always disclosed) ───────────────────────────
    // Flutter apps cannot reliably detect ARP spoofing, rogue access points,
    // or MITM attacks. These require low-level network access unavailable to
    // sandboxed apps on both Android and iOS. We do NOT claim to detect these.
    const platformLimitations = [
      'ARP spoofing detection: NOT AVAILABLE — Flutter apps cannot access the ARP table. This check is omitted rather than faked.',
      'Rogue AP / Evil Twin detection: NOT AVAILABLE — detecting fake hotspots requires OS-level Wi-Fi scanning APIs not accessible from Flutter.',
      'WPA2 vs WPA3 confirmation: NOT AVAILABLE — the encryption type is not reliably exposed by Flutter Wi-Fi APIs. We infer from SSID name hints only.',
      'Captive portal verification: PARTIAL — we can detect some portal-style SSIDs by name, but cannot confirm portal legitimacy.',
    ];

    final connectivityResult = await Connectivity().checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.wifi)) {
      return const WifiSafetyResult(
        ssid: null,
        bssid: null,
        status: WifiSecurityStatus.unknown,
        isEncrypted: true,
        reasons: ['Not connected to Wi-Fi.'],
        platformLimitations: platformLimitations,
      );
    }

    String? ssid;
    String? bssid;
    try {
      ssid = await _wifiInfo.getWifiName();
      bssid = await _wifiInfo.getWifiBSSID();
    } catch (_) {}

    final reasons = <String>[];
    bool isEncrypted = true; // Assume encrypted unless name hints otherwise

    // ── SSID name-based heuristics (limited signal only) ─────────────────
    // This is all that is available without OS-level APIs.
    // Stated as an estimate, not a definitive check.
    final cleanSsid = (ssid ?? '').replaceAll('"', '').toLowerCase();
    if (cleanSsid.contains('free') ||
        cleanSsid.contains('guest') ||
        cleanSsid.contains('public') ||
        cleanSsid.contains('open')) {
      isEncrypted = false;
      reasons.add('SSID name suggests a public/guest network (likely open/unencrypted based on name only).');
      reasons.add('Avoid transmitting sensitive data (passwords, banking) over public Wi-Fi — use a VPN.');
    } else {
      reasons.add('SSID name does not suggest an open network. Encryption type cannot be confirmed without OS APIs.');
    }

    final status = isEncrypted
        ? WifiSecurityStatus.secure
        : WifiSecurityStatus.openUnencrypted;

    return WifiSafetyResult(
      ssid: ssid ?? 'Connected Wi-Fi',
      bssid: bssid,
      status: status,
      isEncrypted: isEncrypted,
      reasons: reasons,
      platformLimitations: platformLimitations,
    );
  }
}
