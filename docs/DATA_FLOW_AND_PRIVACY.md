# Guardian Plus — Data Flow & Privacy Specification

## Core Data Philosophy: On-Device First, Zero-Knowledge Cloud

Guardian Plus is designed under strict data minimization principles:
1. **Raw Message Content**: Never leaves the device. Processed locally via ML Kit / on-device regex classifiers.
2. **Location Data**: Only accessed during user-initiated SOS or active time-boxed location sharing sessions. Never tracked silently in the background.
3. **Cryptographic Identity**: Master keys remain in hardware TEE (Android Keystore / iOS Secure Enclave). Key exchange uses X25519; payloads are signed with Ed25519.

---

## 1. Data Flow Diagrams

### A. SMS Risk Scoring Flow (On-Device Local Processing)

```
[ Incoming SMS ] ──> [ SmsReceiver (Local) ] ──> [ SmsRiskScorer (Local ML) ]
                                                            │
                                                            ▼
                                                [ Risk Level & Category ]
                                                            │
                            ┌───────────────────────────────┴──────────────────────────────┐
                            ▼                                                              ▼
               [ Risk Level == Low ]                                      [ Risk Level == Medium/High ]
                        │                                                                  │
              [ Discard from Memory ]                                     [ Create HMAC Audit Log Entry ]
                                                                                           │
                                                                                           ▼
                                                                            [ Encrypt Alert (Ed25519) ]
                                                                                           │
                                                                                           ▼
                                                                           [ Send FCM Metadata to Parent ]
```

---

### B. Device Pairing Flow (Parent ↔ Child)

```
[ Parent Device ]                                              [ Child Device ]
       │                                                              │
       ├─ 1. Generate Ephemeral X25519 Keypair                        │
       ├─ 2. Display Signed QR Code (Expires in 5 min) ───────────────>│
       │                                                              ├─ 3. Scan QR Code
       │                                                              ├─ 4. Verify Ed25519 Signature
       │<───────────────── 5. Send Child Identity Public Key ─────────┤
       │                                                              │
       ▼                                                              ▼
[ Derives Shared Session Key (HKDF) ]                     [ Derives Shared Session Key (HKDF) ]
```

---

## 2. Regulatory Compliance Summary

| Regulation | Compliance Status | Implementation Detail |
|---|---|---|
| **DPDPA 2023 (India)** | Fully Compliant | Age-verification gate (13+), explicit consent dialog before monitoring, right to erase (key wipe mechanism). |
| **COPPA (US)** | Fully Compliant | Parental consent flow, strict data minimization, no targeted advertising or data selling. |
| **GDPR (EU)** | Fully Compliant | Local storage only, HMAC signed audit trail, data portability/wipe via `KeyManager.wipeAllKeys()`. |

---

## 3. Data Retention Table

| Data Type | Storage Location | Retention Period | Encryption Status |
|---|---|---|---|
| Audit Logs | Local Hive Box (`gp_audit_log`) | 30 days (rolling) | HMAC-SHA-256 Authenticated |
| User Passcode/PIN | TEE / Android Keystore | Until reset | Derived via Argon2id (64MB) |
| App Limits | Local Hive Box (`gp_app_limits`) | Persistent | Local Storage |
| Raw SMS Content | Transitory Memory | 0 seconds (Immediate Zeroing) | Never Persisted |
