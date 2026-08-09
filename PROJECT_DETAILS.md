# 🛡️ Guardian Plus — Technical Architecture & Project Documentation

**Guardian Plus** is a multi-platform, high-security family safety, women's personal protection, and cybersecurity application built using Flutter, Riverpod, and on-device Machine Learning / Cryptography.

---

## 📊 Quick System Summary

| Category | Technology / Specification |
| :--- | :--- |
| **Framework** | Flutter (Dart `^3.3.0`) |
| **Supported Platforms** | Android, iOS, Web (Chrome), macOS Desktop |
| **State Management** | Flutter Riverpod (`^2.5.1`) |
| **Routing & Navigation** | GoRouter (`^14.2.0`) |
| **Local Storage** | Encrypted Hive (`hive_flutter ^1.1.0`) + `flutter_secure_storage ^9.2.2` |
| **Backend & Cloud** | Firebase Core, Auth, Firestore, Messaging, Storage |
| **Security & Encryption** | AES-256-GCM, Argon2id, HKDF, Keystore/Secure Enclave |
| **On-Device ML** | Google ML Kit (Text Recognition, Smart Reply), TFLite |
| **Sensors & Hardware** | Sensors Plus (Shake-to-SOS), Geolocator, Mobile Scanner |

---

## 🏗️ Architecture Overview

Guardian Plus follows a **Feature-First + Layered Architecture** with strict isolation between the UI, business logic (Riverpod providers), security infrastructure, and platform services.

```
lib/
├── core/                       # App-wide foundational modules
│   ├── router/                 # GoRouter route declarations & guards
│   └── theme/                  # Design tokens, AppColors, custom typography & dark theme
│
├── features/                   # Core application features (Feature-First)
│   ├── auth/                   # Splash, Onboarding, Role Selection, Pairing, Consent
│   ├── womens_safety/          # SOS Trigger, Safe Route, Fake Call, Siren Audio
│   ├── parental/               # Parent Dashboard, Linked Device Controls, Risk Alerts
│   ├── cybersecurity/          # Threat Dashboard, Wi-Fi Scanner, URL Safety, Permission Auditor
│   └── shared/                 # Shared UI components across features
│
└── shared/                     # Enterprise Security Layer & Core Services
    ├── security/               # CryptoService, KeyManager, IntegrityGuard, RuntimeGuard, AuditLogger
    └── services/               # Background Services, Local Notifications, WorkManager
```

---

## 🌟 Core Feature Matrix

### 1. 🚺 Women's Safety & Personal Protection
- **🚨 1-Tap & Shake SOS Panic Trigger**:
  - Activated via UI button hold or accelerometer shake detection (`sensors_plus`).
  - Broadcasts live GPS coordinates to configured emergency contacts.
  - Triggers local high-decibel siren (Web Audio API synth on web, audio player natively).
- **🗺️ Safe Route Navigation**:
  - Google Maps integration (`google_maps_flutter`).
  - Evaluates routes based on safety scores, lighted paths, and danger zone avoidance.
- **📞 Discreet Fake Call Generator**:
  - Realistic incoming phone call overlay with customizable caller name, delay timer, and audio/vibration feedback to safely escape uncomfortable or risky situations.
- **📍 Real-Time Location Sharing**:
  - Background location streaming (`geolocator`) with encrypted payload transmission.

### 2. 👨‍👩‍👧 Parental Controls & Family Safety
- **📱 Child Device Overview**:
  - Live device telemetry: Battery percentage, last seen timestamp, screen time usage breakdown (`fl_chart`), and precise location.
- **🔒 Remote Device Management**:
  - Remote app locking, screen time restriction toggles, and device pause controls.
- **⚠️ Risk Alert Center**:
  - Real-time notification feed flagging suspicious URLs, explicit language, geofence breaches, or unauthorized app installs.

### 3. 🛡️ Cybersecurity & Threat Protection
- **🌐 URL & Phishing Inspector**:
  - On-device Machine Learning / heuristic engine to evaluate links scanned or opened.
- **📶 Wi-Fi Security Auditor**:
  - Scans connected network SSID/BSSID metadata, checks for open/unencrypted Wi-Fi, rogue APs, and ARP spoofing risks.
- **📱 Permission Auditor**:
  - Scans all installed apps (`device_apps`) and evaluates privacy risk levels based on sensitive permission requests (Camera, Microphone, Location, SMS, Contacts).
- **📷 QR Code Threat Scanner**:
  - Embedded camera scanner (`mobile_scanner`) that inspects payload safety before navigating.

---

## 🔐 Enterprise Security Architecture

Guardian Plus incorporates multi-layered defense-in-depth principles:

### 1. Cryptography (`shared/security/crypto_service.dart`)
- **Symmetric Encryption**: AES-256-GCM and ChaCha20-Poly1305.
- **Password Hashing**: Argon2id via Pointycastle.
- **Key Derivation**: HKDF (HMAC-based Extract-and-Expand Key Derivation Function).
- **Secure Key Storage**: Hardware-backed KeyManager utilizing Android Keystore and iOS Secure Enclave via `flutter_secure_storage`.

### 2. Runtime & Integrity Protection
- **Integrity Guard (`shared/security/integrity_guard.dart`)**:
  - Root & Magisk detection (`/system/app/Superuser.apk`, `su` binary checks, `test-keys` verification).
  - Signature integrity metadata verification.
- **Runtime Guard (`shared/security/runtime_guard.dart`)**:
  - Frida hooking detection, memory modification checks, and debugger attachment prevention.
- **Audit Logging (`shared/security/audit_logger.dart`)**:
  - Encrypted, tamper-evident local event log (`gp_audit_log`) stored in Hive for all security operations.

---

## 🎨 Design System & Theme

Guardian Plus utilizes a modern, dark cyber-security aesthetic (`AppTheme.dark`):

- **Background Colors**: Deep Obsidian (`#0A0E1A`), Midnight Surface (`#121829`), Card Surface (`#1A2238`).
- **Accent Palette**:
  - **Neon Cyan (`#00F2FE`)**: Primary action buttons & active highlights.
  - **Emerald Safety (`#00E676`)**: Safe status indicators & positive confirmation.
  - **Danger Red (`#FF2A6D`)**: SOS emergency & critical risk warnings.
  - **Warning Amber (`#FFD166`)**: Medium risk alerts & warnings.
- **Typography**: Google Fonts Inter (UI elements) and Space Grotesk (Headings & numerical metrics).
- **Visual Effects**: Glassmorphic frosted-glass cards, micro-animations (`flutter_animate`), and custom canvas safety meters.

---

## 🚀 How to Run the Project

### Prerequisites
- Flutter SDK (`>= 3.3.0`)
- Dart SDK (`>= 3.3.0`)
- Google Chrome browser (for Web execution) or macOS Xcode / Android Studio (for native execution).

### Step-by-Step Run Instructions

1. **Get Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run Static Analysis (Optional)**:
   ```bash
   flutter analyze
   ```

3. **Launch Application**:

   - **Run on Web (Chrome)**:
     ```bash
     flutter run -d chrome --web-port 8080
     ```

   - **Run on macOS Desktop**:
     ```bash
     flutter run -d macos
     ```

   - **Run on Android / iOS**:
     ```bash
     flutter run
     ```

---

## 📁 Key File Map

| File Path | Description |
| :--- | :--- |
| [lib/main.dart](file:///Users/krishnavishwakarma/Documents/projects/guardian%20plus/lib/main.dart) | Application entrypoint & security bootstrapping logic |
| [lib/core/router/app_router.dart](file:///Users/krishnavishwakarma/Documents/projects/guardian%20plus/lib/core/router/app_router.dart) | Route configuration & app navigation map |
| [lib/core/theme/app_theme.dart](file:///Users/krishnavishwakarma/Documents/projects/guardian%20plus/lib/core/theme/app_theme.dart) | Global dark theme & typography definition |
| [lib/features/womens_safety/screens/womens_dashboard.dart](file:///Users/krishnavishwakarma/Documents/projects/guardian%20plus/lib/features/womens_safety/screens/womens_dashboard.dart) | Women's safety dashboard (SOS, Fake Call, Siren) |
| [lib/features/parental/screens/parent_dashboard.dart](file:///Users/krishnavishwakarma/Documents/projects/guardian%20plus/lib/features/parental/screens/parent_dashboard.dart) | Parental dashboard (Child devices, risk alerts, pause toggles) |
| [lib/features/cybersecurity/screens/cybersecurity_dashboard.dart](file:///Users/krishnavishwakarma/Documents/projects/guardian%20plus/lib/features/cybersecurity/screens/cybersecurity_dashboard.dart) | Cybersecurity threat dashboard (Wi-Fi, URL, Threat score) |
| [lib/features/cybersecurity/screens/permission_auditor_screen.dart](file:///Users/krishnavishwakarma/Documents/projects/guardian%20plus/lib/features/cybersecurity/screens/permission_auditor_screen.dart) | Installed apps privacy & permission auditor |
| [lib/shared/security/crypto_service.dart](file:///Users/krishnavishwakarma/Documents/projects/guardian%20plus/lib/shared/security/crypto_service.dart) | Cryptographic primitives & AES-256 implementation |
| [lib/shared/security/integrity_guard.dart](file:///Users/krishnavishwakarma/Documents/projects/guardian%20plus/lib/shared/security/integrity_guard.dart) | Root, su binary, and Magisk detection guard |

---

## 📌 Status & Verification
- All dependencies verified and fetched.
- App verified running cleanly on Chrome web engine (`http://localhost:8080`).
