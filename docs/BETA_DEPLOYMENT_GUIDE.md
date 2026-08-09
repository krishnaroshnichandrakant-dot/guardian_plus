# Guardian Plus — Beta Deployment & Verification Guide

## 1. Prerequisites

- Flutter SDK v3.24+ / Dart 3.5+
- Android Studio / Xcode
- Firebase Project created on [Firebase Console](https://console.firebase.google.com)

---

## 2. Firebase Configuration Setup

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. Run configuration command in project root:
   ```bash
   flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
   ```
   This will update `lib/firebase_options.dart` with real credentials.

3. Download `google-services.json` and place in `android/app/google-services.json`.

---

## 3. Building Debug & Release APKs

### Build Debug APK (Internal Testing):
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Build Obfuscated Release App Bundle (Play Store Submission):
```bash
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols
```
Output: `build/app/outputs/bundle/release/app-release.aab`

---

## 4. Security & Quality Audit Checklist

Run the following commands before submitting any build:

1. **Static Analysis & Linting**:
   ```bash
   flutter analyze
   ```
   *Requirement: 0 errors.*

2. **Automated Unit & Widget Tests**:
   ```bash
   flutter test
   ```
   *Requirement: All tests pass.*

3. **Dependency Vulnerability Audit**:
   ```bash
   flutter pub outdated
   ```

---

## 5. Manual Verification Matrix

| Test Case | Procedure | Expected Result |
|---|---|---|
| **Root Detection** | Launch app on rooted device or emulator | IntegrityGuard triggers warning overlay |
| **FLAG_SECURE** | Attempt screenshot on sensitive screen | Android blocks screenshot ("Can't take screenshot due to security policy") |
| **PIN Lockout** | Enter incorrect PIN 10 times consecutively | KeyManager executes key wipe; audit log records `bruteForceTriggered` |
| **Persistent Notification** | Check notification drawer after role setup | Non-dismissible "Guardian Plus Active" notification is visible |
| **QR Code Scanner** | Point camera at phishing link QR code | Shows Red Warning Sheet with risk score and reasons |
| **Fake Call** | Tap "Fake Call" on Women's Safety screen | Fullscreen incoming call UI with ring timer and answer/decline |
