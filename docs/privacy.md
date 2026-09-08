# Guardian Plus — Privacy & Minor Data Policy

## Data Minimization Principles

Guardian Plus follows data minimization — only the data necessary for each feature
is collected, stored, or transmitted.

| Feature | Data Collected | Retention | Shared With |
|---------|---------------|-----------|-------------|
| Guardian Safety (SOS) | Location at time of SOS only | Alert duration + 24h | Trusted contacts only |
| CyberShield | Scanned URL hash (k-anonymity) | Not stored | Breach API (anonymized) |
| Guardian Family | Child device name, app usage metadata | Parent-set retention | Parent account only |
| Link Detective | Score, streak count, daily count | Session only (no PII) | Nobody |
| Guardian Identity | Auth method flags, device name | Account lifetime | Nobody |
| ScamGuard | Scanned URL/UPI ID | Not stored server-side | Nobody |

## Child / Minor Data Compliance

### Consent Requirements

Before any minor (user age < 18) account is created:

1. **Parental consent gate**: A parent or guardian must create the family admin account first
   and then explicitly invite/add the child account. The child cannot self-register.
2. **Consent record**: Consent timestamp, version (e.g. "1.0"), and parent UID stored in
   Firestore at `users/{childUid}/consentRecord`.
3. **Age gating**: If user self-declares age < 13 during registration, account creation is blocked
   with a message directing them to a parent or guardian.

### What We Collect from Children

- **Collected**: child's first name (for UI display), device name, daily Link Detective score + streak
  (non-identifiable), app usage metadata (for parental monitoring feature)
- **Never collected**: real name in Link Detective leaderboard (nickname only, parent-opted-in),
  photo, school name, location history, contact list, message content
- **No behavioral profiling**: Link Detective answers are used for immediate feedback only;
  they are never stored as behavioral profiles or used to infer psychological attributes

### Leaderboard Privacy (Link Detective)

- Opt-in only — parent must explicitly enable leaderboard participation in Guardian Family settings
- Child shown on leaderboard by nickname only (never real name, avatar photo, school, or location)
- Parent can revoke leaderboard participation at any time — entry is removed within 24h
- Weekly data purge: non-participating children's session data purged after 7 days

### Data Deletion

Parents can request full deletion of child data via in-app settings.
All child data is permanently deleted within 30 days of the request.
Firebase Auth account deletion triggers a Cloud Function that cascades deletion
to all Firestore documents tagged with that UID.

## Adult User Privacy

- Location is only captured during an active SOS event or Safety Walk session
- No passive location tracking or location history retention
- CyberShield URL scans are processed on-device (heuristics) or anonymized via
  k-anonymity (breach check uses SHA-1 prefix, never the full email)
- Audit log entries are stored locally with HMAC-SHA-256 integrity protection;
  the log is never transmitted to servers without explicit export by the user

## Data Residency

Firebase project is configured for the **asia-south1 (Mumbai)** region to keep
Indian users' data within India (DPDP Act 2023 compliance for non-critical data).

## Contact

For privacy questions, data deletion requests, or to exercise data rights:
privacy@guardianplus.app (placeholder — replace before launch)
