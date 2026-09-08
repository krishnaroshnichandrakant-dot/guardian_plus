# Guardian Plus — Architecture Overview

## System Design

Guardian Plus is a cross-platform Flutter application (Android + iOS) with a Firebase backend.
It implements a **role-gated, triple-experience architecture** — one codebase, three distinct
product surfaces determined by the authenticated user's role.

## Role Architecture

```
                    ┌─────────────────────────────────┐
                    │          Firebase Auth           │
                    │   + Firestore users/{uid}.role   │
                    └───────────────┬─────────────────┘
                                    │
                  ┌─────────────────┼─────────────────┐
                  │                 │                  │
         ┌────────▼──────┐ ┌───────▼──────┐  ┌───────▼──────┐
         │  Individual   │ │    Parent    │  │    Child    │
         │  WomensSafety │ │  (Guardian   │  │   (Child    │
         │  (Guardian    │ │   Family     │  │    Home)    │
         │   Safety)     │ │   Admin)     │  │             │
         └───────────────┘ └──────────────┘  └─────────────┘
             4 tabs              6 tabs            5 tabs
```

## Module Map

| Module | Feature Directory | Problem Statement |
|--------|-----------------|-------------------|
| Guardian Home | `lib/features/home/` | Cross-cutting |
| Guardian Safety | `lib/features/womens_safety/` | PS #21, PS #22 |
| CyberShield | `lib/features/cybersecurity/` | PS #19 |
| ScamGuard | `lib/features/fraud/` | PS #17 |
| Guardian Family | `lib/features/parental/` | Child safety |
| Link Detective | `lib/features/link_detective/` | Phishing literacy |
| Guardian Identity | `lib/features/identity/` | PS #20 |
| Child Home | `lib/features/child_home/` | Transparent monitoring |
| Auth | `lib/features/auth/` | All roles |
| Shared Security | `lib/shared/security/` | All modules |

## State Management

Riverpod (2.x) with `StateNotifierProvider` for mutable state and `StreamProvider`
for reactive Firebase Auth state.

Key providers:
- `authStateProvider` — Stream<GuardianUser?> from Firebase Auth + Firestore role resolution
- `familyProfileProvider` — Family state (StateNotifier backed, Firestore-ready)
- `homeProvider` — Aggregated risk state for Guardian Home dashboard
- `linkDetectiveProvider` — Challenge bank + game state

## Routing

GoRouter with two guard layers:

1. **Auth guard** — unauthenticated users redirected to `/auth/role`
2. **Role guard** — parent-only routes (family, fraud) reject child/individual users

Single source of truth for route paths: `lib/core/router/app_router.dart#Routes`

## Security Architecture

```
    Client                          Firebase Backend
    ─────────────────────           ──────────────────────
    RuntimeGuard (Frida/debug)  →   Firestore Security Rules
    IntegrityGuard (root/jb)    →   Cloud Functions (server-side validation)
    AuditLogger (HMAC-SHA-256)  →   Auth Custom Claims (role verification)
    CryptoService (AES-256-GCM) →   Admin SDK (server-side only)
    KeyManager (Keystore/SE)
```

Dual-layer enforcement: UI-layer guards prevent navigation to unauthorized routes.
Server-side Firestore Rules enforce the same rules — UI guards alone are insufficient.

## Data Flow

See `docs/data-flow.md` for detailed SOS alert delivery and family data flows.

## Technology Stack

- **Framework**: Flutter 3.x (Dart)
- **Backend**: Firebase (Auth, Firestore, Cloud Functions, FCM)
- **State**: Riverpod 2.x
- **Routing**: GoRouter 13.x
- **Crypto**: pointycastle (AES-GCM, ChaCha20, HKDF), cryptography package
- **Key Storage**: flutter_secure_storage, Android Keystore, iOS Secure Enclave
- **Background**: flutter_background_service
- **Animations**: flutter_animate
- **Typography**: Google Fonts (Space Grotesk + Inter)
