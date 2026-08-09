# Guardian Plus — Google Play Stalkerware & Families Policy Compliance Checklist

> **Auditor Reference Document**: This document verifies Guardian Plus compliance against Google Play's **Stalkerware Policy**, **Families Policy**, and **High-Risk Permissions Policy** (§5 of prompt specification).

---

## 1. Google Play Stalkerware Policy Self-Audit

| Policy Requirement | Pass/Fail | Implementation Evidence |
|---|:---:|---|
| **Must NOT be presented as a secret or covert monitoring solution** | **PASS** | App title, icon, and onboard explicitly state safety monitoring purpose. No hidden stealth modes exist in codebase. |
| **Must display a persistent, non-dismissible notification while monitoring is active** | **PASS** | `flutter_background_service` runs an active Android Foreground Service with channel priority `HIGH` and `ONGOING` notification flag. |
| **Notification must clearly identify the app** | **PASS** | Notification text explicitly displays "Guardian Plus is actively monitoring this device for your safety". |
| **Child must be able to see who is monitoring them** | **PASS** | `ChildMonitoringIndicatorCard` widget in app home screen shows parent name, pairing timestamp, and a prominent "Request Unpair" button. |
| **No Accessibility Service scraping of third-party messaging apps** | **PASS** | Zero usage of Android `AccessibilityService` for text scraping. Only standard `READ_SMS` permission declared with disclosure. |

---

## 2. High-Risk Permission Rationale (`READ_SMS`)

```
Package: com.guardianplus.guardian_plus
Permission: android.permission.READ_SMS / RECEIVE_SMS

Purpose Statement for Google Play Review:
Guardian Plus uses READ_SMS solely for on-device risk assessment of incoming SMS text messages 
to protect children from phishing links, grooming patterns, and harassment. Raw SMS content is 
evaluated locally in real-time memory and NEVER transmitted off-device or stored on remote servers. 
Parents receive only risk categories (e.g. "Phishing Risk") and confidence scores via encrypted FCM.
```

---

## 3. Mandatory Transparency UI Elements

1. **Role Selection**: User explicitly selects "Parent" or "Child" during onboarding.
2. **Consent Screen**: Explicit age gate (13+) and data usage disclosure checkbox before setup.
3. **QR Pairing**: Unambiguous pairing flow requiring physical proximity or direct code entry.
4. **Persistent Indicator**: Always-visible notification and home card on child device.
