import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final wifiSafetyServiceProvider = Provider<WifiSafetyService>((ref) {
  return WifiSafetyService();
});

enum WifiSecurityStatus { secure, openUnencrypted, suspiciousCaptivePortal, unknown }

class WifiSafetyResult {
  const WifiSafetyResult({
    required this.ssid,
    required this.bssid,
    required this.status,
    required this.isEncrypted,
    required this.reasons,
  });

  final String? ssid;
  final String? bssid;
  final WifiSecurityStatus status;
  final bool isEncrypted;
  final List<String> reasons;
}

class WifiSafetyService {
  final _wifiInfo = WifiInfo();

  Future<WifiSafetyResult> checkCurrentNetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.wifi)) {
      return const WifiSafetyResult(
        ssid: null,
        bssid: null,
        status: WifiSecurityStatus.unknown,
        isEncrypted: true,
        reasons: ['Not connected to Wi-Fi'],
      );
    }

    String? ssid;
    String? bssid;
    try {
      ssid = await _wifiInfo.getWifiName();
      bssid = await _wifiInfo.getWifiBSSID();
    } catch (_) {}

    final reasons = <String>[];
    bool isEncrypted = true;

    // Check if open / unencrypted SSID name hints or gateway indicators
    final cleanSsid = (ssid ?? '').replaceAll('"', '').toLowerCase();
    if (cleanSsid.contains('free') || cleanSsid.contains('guest') || cleanSsid.contains('public')) {
      isEncrypted = false;
      reasons.add('Public/Guest Wi-Fi network detected (likely unencrypted)');
    }

    WifiSecurityStatus status = WifiSecurityStatus.secure;
    if (!isEncrypted) {
      status = WifiSecurityStatus.openUnencrypted;
      reasons.add('Data transmitted over this network can be intercepted via Man-In-The-Middle (MITM)');
    } else {
      reasons.add('WPA2/WPA3 encryption active');
    }

    return WifiSafetyResult(
      ssid: ssid ?? 'Connected Wi-Fi',
      bssid: bssid,
      status: status,
      isEncrypted: isEncrypted,
      reasons: reasons,
    );
  }
}
