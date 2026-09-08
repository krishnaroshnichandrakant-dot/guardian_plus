# 🛡️ Guardian Plus

> **AI-Powered Family Safety, Women's Personal Protection & Cybersecurity Application**

Guardian Plus is a multi-platform security and safety application built with Flutter, Riverpod, and on-device Cryptography/Machine Learning.

For comprehensive technical architecture, feature matrices, and security specifications, please refer to **[PROJECT_DETAILS.md](PROJECT_DETAILS.md)**.

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (`>= 3.3.0`)
- Dart SDK (`>= 3.3.0`)

### Installation & Execution

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run Application**:
   - **Web (Chrome)**:
     ```bash
     flutter run -d chrome --web-port 8080
     ```
   - **macOS Desktop**:
     ```bash
     flutter run -d macos
     ```

---

## ✨ Highlights

- **🚺 Women's Safety**: 1-Tap & Shake SOS Trigger, Safe Route Navigation, Discreet Fake Call Generator, Live Location Sharing & High-Decibel Siren.
- **👨‍👩‍👧 Parental Controls**: Real-Time Child Telemetry, Screen Time Analytics, Remote App Pause & Risk Alert Feeds.
- **🛡️ Cybersecurity**: Wi-Fi Network Auditor, ML URL & Phishing Inspector, App Permission Risk Auditor & QR Code Scanner.
- **🔐 Security Architecture**: Hardware KeyStore / Secure Enclave integration, AES-256-GCM encryption, Root/Jailbreak detection, and anti-tamper runtime guards.

## 🌐 Netlify Deployment

This project includes zero-config Netlify integration out of the box via `netlify.toml` and `./scripts/build_netlify.sh`.

### Option A: Automatic Git-Integrated Deployment
1. Connect your GitHub repository (`krishnaroshnichandrakant-dot/guardian_plus`) to **[Netlify Dashboard](https://app.netlify.com)**.
2. Netlify will automatically detect `netlify.toml` and use the following settings:
   - **Publish directory**: `build/web`
   - **Build command**: `chmod +x ./scripts/build_netlify.sh && ./scripts/build_netlify.sh`
3. Click **Deploy Site** — Netlify will build and host your app with SPA client-side routing support (`/* -> /index.html`).

### Option B: Manual CLI or Drag-and-Drop Deployment
1. Build the production bundle:
   ```bash
   flutter build web --release
   ```
2. Drag & drop the `build/web` directory into **[Netlify Drop](https://app.netlify.com/drop)** or deploy via CLI:
   ```bash
   npx netlify-cli deploy --prod --dir=build/web
   ```

---

## 📖 Full Documentation

See **[PROJECT_DETAILS.md](PROJECT_DETAILS.md)** for in-depth system design, cryptography layer, and directory mapping.

