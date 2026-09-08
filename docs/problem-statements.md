# Guardian Plus — Problem Statement Mapping
## IIC 3.0 Umbrella PS #35 — Open Innovation

Guardian Plus addresses four of the five Problem Statements under the IIC 3.0
umbrella theme (PS #35). Each PS maps to a named feature module within the app.

| IIC PS | Title | Guardian Plus Module | Approach |
|--------|-------|---------------------|----------|
| **PS #17** | AI-based fraud detection in digital transactions | **ScamGuard** | Rule-based heuristic risk engine for payment QR codes, UPI IDs, and transaction destination URLs. Explainable risk score (0–100) with category labels (SAFE / SUSPICIOUS / HIGH RISK). Never auto-executes or blocks a payment. Clearly labeled as a rule-based engine, not AI. |
| **PS #19** | AI-based cyber threat detection | **CyberShield** | Multi-layer URL safety analysis (lookalike detection, TLD reputation, IP-host detection, subdomain stacking, SSL check), QR scanner, Wi-Fi network audit, app permission audit, and breach check via k-anonymity. |
| **PS #20** | Secure digital identity & authentication | **Guardian Identity** | Firebase Auth, PIN (Argon2id hashed), biometrics (local_auth), X25519 ephemeral key exchange for device pairing, Ed25519-signed pairing payloads, HKDF session key derivation, session revocation, Android Keystore / iOS Secure Enclave key storage. |
| **PS #21** | AI-based real-time women safety alerts | **Guardian Safety** | Hold-to-SOS with configurable countdown and accidental-trigger prevention, Shake-to-SOS, Safety Walk, Live Location, Trusted Contacts, Safe Route (labeled as an estimate), Fake Call, Siren, Emergency Numbers (India: 112, 1091). Hybrid alert delivery: FCM primary, SMS fallback. |
| **PS #22** | Safe route recommendation | **Guardian SafeRoute** | Route comparison with a safety score, integrated into Guardian Safety dashboard. Explicitly labeled as an estimate based on available data — not a crime prediction or a guarantee. Powered by Google Maps with safety scoring heuristics. |

## Notes

- PS #17 and PS #19 overlap on QR scanning. Guardian Plus routes **payment QR** through
  ScamGuard and **non-payment QR** (general URLs, Wi-Fi credentials) through CyberShield.
- PS #21 is explicitly framed as **personal safety alerts to trusted contacts**, not emergency
  service dispatch. The app states clearly in-UI: "This notifies your trusted contacts. It does
  not call emergency services automatically."
- The "AI" label for PS #17 and PS #21 is interpreted as intelligent, automated risk assessment.
  Where Guardian Plus uses rule-based engines (URL analysis, SMS scoring), these are explicitly
  labeled as **rule-based risk engines** in the UI and code, not "AI." Where ML adds real value
  (future TFLite URL classifier), it is labeled with confidence and explainability.
