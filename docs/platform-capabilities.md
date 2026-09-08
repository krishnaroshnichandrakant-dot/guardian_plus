# Guardian Plus — Platform Capabilities Reference

This document is the **single source of truth** for what Guardian Plus can and cannot do
on each platform. Features must be labeled in the UI when platform limitations apply.

## Control/Feature Matrix

| Feature | Android | iOS | Implementation | Notes |
|---------|---------|-----|----------------|-------|
| **SOS Alert (FCM)** | ✅ Full | ✅ Full | Firebase FCM | Requires internet |
| **SOS Alert (SMS)** | ✅ Automatic | ⚠️ Platform Limited | Android: SEND_SMS permission; iOS: requires one user tap in Messages app | |
| **SOS Alert (Offline)** | ⚠️ Queued | ⚠️ Queued | flutter_background_service + retry | Queue stored encrypted locally |
| **Shake to SOS** | ✅ Full | ✅ Full | accelerometer | Background mode on iOS is limited |
| **Live Location Share** | ✅ Full | ⚠️ Partial | geolocator | iOS background location requires Always permission — shown in permissions request |
| **Siren** | ✅ Full | ✅ Full | audioplayers | Volume control API limited on iOS |
| **Fake Call** | ✅ Full | ✅ Full | Custom Flutter UI | Simulated only — not a real call |
| **Safe Route (Maps)** | ✅ Full | ✅ Full | google_maps_flutter | Safety score is an **estimate** — not a crime prediction |
| **URL Safety Scan** | ✅ Full | ✅ Full | On-device heuristics | No network call for core scan |
| **Breach Check** | ✅ Full | ✅ Full | k-anonymity (haveibeenpwned prefix API) | Requires internet |
| **QR Scanner** | ✅ Full | ✅ Full | mobile_scanner | |
| **Permission Audit** | ✅ Full | ⚠️ Partial | device_apps (Android) / limited iOS | iOS does not expose app permission lists to other apps |
| **Wi-Fi Security Check** | ⚠️ Limited | ⚠️ Limited | SSID name heuristics only | ARP / Rogue AP detection NOT available on either platform |
| **App Screen Time Limits** | ⚠️ Partial | 🚫 Platform Limited | Android UsageStatsManager (requires manual permission) | iOS Screen Time API is private — cannot be accessed by third-party apps |
| **App Blocking** | ⚠️ Partial | 🚫 Platform Limited | Android Accessibility Service overlay | iOS cannot block apps without MDM |
| **Internet Pause** | ⚠️ Partial | 🚫 Platform Limited | Android: DNS-level via VpnService (requires VPN permission) | iOS: VPN approach theoretically possible but impractical without MDM |
| **Content Filtering (Web)** | ⚠️ Partial | 🚫 Platform Limited | Android: VPN DNS filter | iOS: requires MDM enrollment or Screen Time restrictions set by Apple |
| **Bedtime Curfew** | ⚠️ Partial | 🚫 Platform Limited | Android: combination of app block + Wi-Fi control | iOS: advisory only — the app can remind but cannot enforce |
| **SMS Risk Monitoring** | ✅ Full | 🚫 Platform Limited | Android: READ_SMS permission | iOS apps cannot read SMS messages |
| **Background Monitoring** | ⚠️ Partial | ⚠️ Partial | flutter_background_service | iOS: aggressive background termination limits monitoring frequency |
| **ARP Spoofing Detection** | 🚫 Not Available | 🚫 Not Available | — | Neither platform exposes ARP table to user-space apps |

## UI Labeling Convention

When a feature is unavailable or limited on a platform, the UI must show:

```
🔒 Platform Limited: [brief plain-language explanation]
   [what the app CAN do instead]
```

Never silently degrade. Never show a control that appears to work but does nothing.

## Android-Only Features (labeled in UI on iOS)

- Automatic SMS sending without user tap
- App permission list audit (full list)
- UsageStatsManager (screen time data)
- Native VPN Service for content/internet control
- READ_SMS for parental SMS risk monitoring

## iOS-Only Considerations

- Screen Time enforcement: iOS users must configure Apple's built-in Screen Time manually;
  Guardian Plus can display usage recommendations but cannot enforce them
- Background GPS: user must grant "Always Allow" location permission explicitly
- SMS: always requires user to tap Send — cannot be automated
