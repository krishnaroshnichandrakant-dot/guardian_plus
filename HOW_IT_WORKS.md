# 🛡️ How Guardian Plus Works: Under The Hood

> **A Simple, Plain-English Guide to How Guardian Plus Protects You, Checks Links, Scans Emails, and Secures Your Family.**

---

## 📌 Table of Contents
1. [How Website & Link Checking Works (With Just a URL)](#1-how-website--link-checking-works-with-just-a-url)
2. [How Email & Data Breach Checking Works (With Just an Email)](#2-how-email--data-breach-checking-works-with-just-an-email)
3. [How QR Code Safety Scanner Works](#3-how-qr-code-safety-scanner-works)
4. [How Wi-Fi Network Safety Checking Works](#4-how-wi-fi-network-safety-checking-works)
5. [How App Permission Auditing & Spyware Detection Works](#5-how-app-permission-auditing--spyware-detection-works)
6. [How Family Admin & Per-Child Rules Work](#6-how-family-admin--per-child-rules-work)
7. [How Women's Safety SOS & Protection Works](#7-how-womens-safety-sos--protection-works)

---

## 1. How Website & Link Checking Works (With Just a URL)

When you receive a suspicious link via SMS, WhatsApp, or email, Guardian Plus can analyze and score it **before** you click on it. Here is how it does that in milliseconds:

```
Suspicious Link ──► [ URL Deconstruction ] ──► [ Heuristic Rules + AI Score ] ──► [ Safe / Suspicious / Malicious ]
```

### Step 1: Breaking Down the Link (URL Anatomy)
A link is broken down into parts:
- **Protocol:** `https://` (encrypted) vs `http://` (unencrypted, insecure)
- **Domain/Host:** `secure-login-paypal.com`
- **Top-Level Domain (TLD):** `.com`, `.zip`, `.tk`, `.xyz`
- **Path & Query:** `/verify?user=123`

### Step 2: Running the 5-Layer Security Inspection

#### A. Lookalike & Typosquatting Check (Visual Trick Detection)
Scammers register fake websites that look almost identical to real ones (e.g., using `1` instead of `l`, or `0` instead of `o`).
- Example: `paypa1.com`, `g00gle.com`, `app1e-support.net`
- **How Guardian Plus catches it:** It compares the name against a whitelist of trusted services. If a site contains words like `paypal`, `banking`, `login`, or `update` but is **not** the official domain, it flags it immediately as a spoofing attempt.

#### B. Top-Level Domain (TLD) Reputation
Anyone can buy certain domain endings for free or pennies (such as `.tk`, `.ml`, `.ga`, `.zip`, `.top`, `.click`).
- Hackers love these because they can create 10,000 throwaway scam sites per day.
- Guardian Plus maintains a database of high-risk TLDs and increases the risk penalty when one is detected.

#### C. Raw IP Address Detection
Legitimate companies have web domain names (like `google.com`). Scammers hosting quick malware or phishing kits often just use numeric addresses like `http://192.241.20.1/login`.
- If a link uses an IP address directly, Guardian Plus adds a **+40 high risk score** immediately.

#### D. Subdomain & Hyphen Stacking
Scammers often create URLs like:
`http://paypal.com.account-verification.login-secure.xyz/`
- Humans only notice the first word `paypal.com` and think it is real.
- Guardian Plus reads from right to left, recognizing the real destination is actually `xyz`, and flags excessive subdomains and hyphens.

#### E. SSL / Encryption Verification
- `https://` means the connection between your device and the site is encrypted.
- Plain `http://` means anyone on your Wi-Fi can see passwords you type.

### Step 3: Calculating the Final Risk Score (0 to 100)
- **0 – 24 (Green / Safe):** Clean legitimate website.
- **25 – 59 (Amber / Suspicious):** Caution advised (unusual domain or unencrypted).
- **60 – 100 (Red / Malicious):** Phishing, fake login, or malware site blocked!

---

## 2. How Email & Data Breach Checking Works (With Just an Email)

You might wonder: *How can the app know if an email account has been compromised just by typing the email address?*

```
Your Email ──► [ SHA-1 Cryptographic Hash ] ──► [ Global Breach Index ] ──► [ List of Leaks & Compromised Services ]
```

### What is a "Data Breach"?
A data breach happens when a major service you use (like LinkedIn, Adobe, Canva, Yahoo, or a shopping website) gets hacked. The hackers steal user databases containing millions of email addresses, passwords, phone numbers, and birth dates, and leak them online or on the dark web.

### Step 1: The Breach Database Lookup
Security researchers (such as the global *Have I Been Pwned* project) gather public database leaks from thousands of hacks over the last 15 years and index which emails appeared in which leak.
- When you type `youremail@example.com`, Guardian Plus queries these indexed records of verified breaches.

### Step 2: Privacy-Preserving Lookups (k-Anonymity)
Guardian Plus protects your privacy when checking:
1. Your email/password is never sent in plain text.
2. It generates a cryptographic mathematical fingerprint called a **Hash** (e.g. SHA-1: `2FD4E1C67A2D28FCED849EE1BB76E7391B93EB12`).
3. Only the first **5 characters** (`2FD4E`) are sent to the breach directory.
4. The directory sends back all matching hash prefixes, and your phone matches the rest **locally on your device**.
5. **Result:** The server never knows what exact email or password was checked!

### Step 3: What It Tells You
If a breach is found, Guardian Plus tells you:
- **Which website was hacked** (e.g., *Canva 2019 breach*).
- **When it happened**.
- **What was stolen** (e.g., *Passwords, Names, Phone Numbers*).
- **Actionable advice:** Change that password immediately, especially if you reused that same password on other websites!

---

## 3. How QR Code Safety Scanner Works

QR codes are simply black-and-white barcodes that hold text or website URLs. Hackers stick fake QR codes over parking meters, restaurant menus, or send them in phishing emails ("Quishing").

```
[ Camera Scans QR ] ──► [ Decodes Text Payload ] ──► [ URL Safety Engine ] ──► [ Opens only if Safe ]
```

1. **Camera Read:** Decodes the pixel matrix into raw text or a link.
2. **Pre-flight Sandbox:** Instead of immediately opening the link in your phone's browser (where malware could download), Guardian Plus intercepts it.
3. **Automated Analysis:** It runs the decoded link through the **URL Safety Engine** described in Section 1.
4. **Warning Barrier:** If the QR code leads to a fake login or malicious APK download, Guardian Plus alerts you before any connection is made.

---

## 4. How Wi-Fi Network Safety Checking Works

When you connect to public Wi-Fi (like in coffee shops, airports, or hotels), you may be exposed to "Man-in-the-Middle" (MITM) attacks or fake Wi-Fi hotspots ("Evil Twins").

```
[ Wi-Fi Connection ] ──► [ Encryption Level ] ──► [ Captive Portal Check ] ──► [ ARP / Gateway Validation ]
```

1. **Encryption Analysis:** Checks whether the router uses secure **WPA3/WPA2** encryption or is an **Open / WEP** network where anyone nearby can sniff your traffic.
2. **ARP Spoofing & Gateway Check:** Detects if another computer on the same Wi-Fi is impersonating the router to intercept your data.
3. **Captive Portal Verification:** Verifies whether the Wi-Fi login screen is legitimate or attempting to harvest personal data.

---

## 5. How App Permission Auditing & Spyware Detection Works

When apps are installed on your phone, some request permissions they don't actually need (e.g., a simple flashlight app requesting access to your SMS, contacts, and microphone).

```
[ Installed Apps Scan ] ──► [ Permission Matrix ] ──► [ Dangerous Combinations ] ──► [ Privacy Risk Grade ]
```

Guardian Plus inspects the manifest of every app on the device and flags high-risk permissions:
- 🔴 **Accessibility Services:** Can read everything on your screen and tap buttons automatically (common in banking trojans).
- 🔴 **SMS / Notification Access:** Can read 2-Factor Authentication (OTP) codes sent by banks.
- 🟡 **Background Location:** Tracks where you go 24/7.
- 🟡 **Microphone / Camera in Background:** Potential eavesdropping risk.
- 🟡 **Display Over Other Apps (Overlay):** Can draw fake login screens over your real banking or social media apps.

---

## 6. How Family Admin & Per-Child Rules Work

Guardian Plus is designed so **one parent (Family Admin)** can configure rules, while children or family members use the app without seeing or tampering with the administrative controls.

```
[ Family Admin Device ] ──► [ Cloud / Local Profile Sync ] ──► [ Child Device Enforcement ]
  • Set Screen Time             • Rules Stored Securely           • Enforces Limits
  • Block TikTok/Games          • Push Rule Updates               • Reports Geofence
  • Bedtime Curfews                                               • Safe/Filtered Net
```

### How Specific Rules Are Enforced:
- **⏱ Screen Time Limits:** The background service monitors the foreground application package. When the daily time limit is reached, it displays a lock screen overlay.
- **🚫 App Blocking:** When a blocked app (like TikTok or games during school hours) starts, the app detection interceptor pauses the application.
- **🌙 Bedtime Curfew:** At scheduled hours (e.g. 9:00 PM), background network policies prevent internet access for entertainment apps.
- **📍 Safe Zones (Geofencing):** The child's device checks GPS coordinates against defined safe circular zones (like home or school). If the device exits the radius, an automated alert is sent to the Family Admin.

---

## 7. How Women's Safety SOS & Protection Works

Women's safety features are built for rapid response during emergencies:

```
[ Panic SOS Trigger ] ──► [ High-Precision GPS Fix ] ──► [ Automated Emergency Broadcast ]
  • Triple-tap / Shake       • Battery & Lat/Long             • SMS to Emergency Contacts
  • Large Red SOS Button                                       • Audible Siren / Silent Mode
```

- **One-Tap / Shake SOS:** Initiates instant emergency dispatch even if the screen is locked, using the device accelerometer.
- **Live Location Telemetry:** Transmits real-time coordinates, street address, and device battery level to trusted emergency contacts.
- **Fake Call Generator:** Simulates a realistic incoming phone call with ringtone and caller ID to help exit uncomfortable or unsafe situations gracefully.

---

## 💡 Summary Comparison Table

| Feature | Input Given | How It Inspects | What Protects You |
| :--- | :--- | :--- | :--- |
| **Link / Site Checker** | Website URL | Analyzes domain spoofing, TLD risk, IP host, encryption, subdomains | Blocks phishing before you visit |
| **Data Breach Checker** | Email address | Checks global breach indexes using k-Anonymity cryptographic hashes | Alerts you to leaked passwords |
| **QR Code Scanner** | Camera scan | Intercepts decoded data & runs it through the URL engine | Stops malicious links before browser opens |
| **Wi-Fi Scanner** | Active Wi-Fi | Checks encryption protocols (WPA2/WPA3), ARP spoofing, rogue gateways | Prevents network eavesdropping |
| **Permission Auditor** | Installed apps | Scans app permissions for dangerous combinations (SMS, Accessibility, Overlays) | Detects stalkerware & trojans |
| **Parental Controls** | Admin rules | Intercepts foreground app usage & GPS geofencing | Enforces per-child limits & curfews |
| **Women's Safety SOS** | One tap / shake | Gathers live GPS coordinates & broadcasts emergency alerts | Rapid emergency contact response |

---

*Guardian Plus — Intelligent, transparent security designed for everyday peace of mind.*
