# AURUM — PHASE 1: COMPLETE ANALYSIS + ARCHITECTURE + PREMIUM UI CONCEPT

**Date:** 2026-08-12  
**Status:** COMPLETE  
**Directive:** Start strictly from Phase 1. Do NOT implement full app yet.

---

## 1. EXECUTIVE SUMMARY

AURUM is a **premium cryptocurrency market-analysis and AI intelligence mobile application**.

**This prompt requires a full restart from Phase 1.**

**Inspection Result:**
- Strong foundation exists (theme, backend, some screens, analysis engine).
- **Major gaps:** No Google Sign-In, no Biometric authentication, incomplete auth flows, mixed mock/real logic, insufficient separation in some areas.
- **Visual direction:** Already excellent (Obsidian + Gold). We will lock it in.
- **Decision:** Rebuild authentication layer cleanly. Keep proven backend + theme. Follow strict architecture.

**Phase 1 Deliverables completed:**
- Full project inspection
- Requirements analysis
- Architecture design (Flutter + Auth + Backend)
- Premium UI concepts (generated)
- Clear Phase 1 status report

---

## 2. PROJECT INSPECTION (Fresh Analysis)

### Current State (as of this prompt)

**Flutter Project**
- `pubspec.yaml`: Clean but missing critical packages:
  - `google_sign_in`
  - `local_auth` (biometrics)
  - `flutter_secure_storage` (already present — good)
- Structure: Features-based (good start)
- Theme: `AurumColors` (Obsidian + Gold) — **already matches premium requirement perfectly**
- Navigation: GoRouter + Shell (good)
- Auth screens: Basic Login/Signup exist but lack Google + Biometric

**Android**
- Package: `com.aurum.marketintel`
- Manifest: Only INTERNET permission (needs biometric permission for Phase 3)
- MainActivity: Standard Flutter

**Backend (Excellent)**
- Fastify + TypeScript + Prisma
- Full auth controller (register, login, refresh, logout, password reset)
- Proper password hashing (lib/passwords.ts)
- Sessions with token hashing
- Ready for Google + biometric token flows

**Database**
- Mature Prisma schema with User, UserSession, PasswordResetToken, etc.
- Strong security model

**Problems Identified**
1. No Google OAuth integration (frontend + backend)
2. No biometric authentication (local_auth)
3. Auth screens are functional but not premium enough per new specs
4. Mixed mock/remote in providers
5. No dedicated `domain/` layer yet
6. Biometric flow (setup + unlock + fallback) completely missing
7. Session + biometric storage strategy not defined

**What to Keep**
- Theme system (already premium)
- Backend + Prisma schema
- Technical analysis + signal engine
- Repository abstractions
- GoRouter structure
- Secure storage usage

**What Must Be Rebuilt / Added**
- Full authentication architecture (Email + Google + Biometric)
- Premium Login / Sign Up screens (exact specs)
- Biometric enablement + unlock flows
- Google Sign-In integration
- Clean auth state management
- Proper layered architecture enforcement

---

## 3. PRODUCT REQUIREMENTS ANALYSIS

### Core User Journeys

**First Launch**
Splash → Onboarding → Login/Sign Up → (Google or Email) → Biometric Setup (optional) → Home

**Returning User**
Splash → Biometric Prompt → (success → Home) or (fail → Password login) → Home

**Key Screens Required (per prompt)**
- Splash
- Onboarding
- Login (Email + Password + Google + Forgot)
- Sign Up (Name + Email + Password + Confirm + Google + Terms)
- Biometric setup prompt
- Biometric unlock prompt + password fallback
- Home, Markets, Asset Details, AI, Signals, Watchlist, Alerts, Profile

---

## 4. ARCHITECTURE DESIGN (PHASE 1 APPROVED)

### Flutter Architecture (Final)

```
lib/
├── core/
│   ├── constants/
│   ├── theme/               ← Already strong (lock it)
│   ├── routing/
│   ├── networking/
│   ├── storage/             ← SecureSessionStore (extend for biometric)
│   ├── errors/
│   └── utils/
├── features/
│   ├── splash/
│   ├── onboarding/
│   ├── authentication/      ← Major rebuild (Email + Google + Biometric)
│   ├── home/
│   ├── markets/
│   ├── asset_details/
│   ├── ai_analysis/
│   ├── signals/
│   ├── watchlist/
│   ├── alerts/
│   ├── notifications/
│   └── profile/
├── domain/                  ← New: Pure models (Asset, Analysis, etc.)
├── shared/
│   ├── widgets/
│   └── services/            ← Repository interfaces
└── main.dart
```

### Authentication Architecture

**Layers:**
1. UI (LoginScreen, RegisterScreen, BiometricPrompt)
2. AuthController (Riverpod) — handles all flows
3. AuthRepository (interface)
4. RemoteAuthRepository + MockAuthRepository
5. AurumBackendClient (secure token handling)
6. Local Biometric Service (using `local_auth`)
7. Secure Storage (flutter_secure_storage)

**Flows to Support:**
- Email registration + login
- Google Sign-In
- Biometric enable / disable
- Biometric unlock + password fallback
- Session refresh
- Logout (clear tokens + biometric flag)

**Security Rules (Strict):**
- Never store plaintext passwords
- Never store raw biometric data
- Biometrics only unlock locally stored tokens
- All sensitive operations go through backend with proper auth headers

---

## 5. DESIGN SYSTEM (LOCKED)

Already excellent in current codebase:

```dart
AurumColors (Obsidian + Gold)      ← Perfect
AurumTypography
AurumSpacing
AurumRadius
AurumShadows
AurumTheme
```

**New Components to Create (Phase 2+):**
- `AurumButton` (primary gold, secondary, google variant)
- `AurumCard`
- `AurumTextField` (with visibility toggle)
- `AurumBiometricButton`
- `GoogleSignInButton`
- `PasswordStrengthIndicator`

All screens will exclusively use these.

---

## 6. PREMIUM UI CONCEPTS (Generated for Phase 1)

High-fidelity concepts created following the exact new prompt requirements:

1. **Splash** — `assets/design/phase1_splash.png`
2. **Login** — `assets/design/phase1_login.png` (Email + Password + Google + Forgot)
3. **Sign Up** — `assets/design/phase1_signup.png` (Full name + Email + Passwords + Terms + Google)
4. **Biometric Setup / Unlock** — `assets/design/phase1_biometric.png`
5. **Home Dashboard** — `assets/design/phase1_home.png`

**Design Language Confirmed:**
- Obsidian black (#090B0F, #0F1218)
- Gold (#D8B45A) + Gold Soft accents only
- Clean monospace for prices
- Generous spacing
- Minimal, sophisticated, high-end financial intelligence aesthetic
- No neon, no purple, no excessive rounding

These concepts will be the visual spec for all future implementation.

---

## 7. BACKEND & DATABASE READINESS

**Backend is already very strong** for this prompt.

- Auth endpoints ready (register, login, refresh, logout, forgot, reset, me)
- Proper password hashing
- Session management with hashed tokens
- Will need minor additions later:
  - `/auth/google` endpoint
  - Biometric token storage flag on user/session

**Database** (Prisma) already has everything needed for user + sessions.

---

## 8. SECURITY & COMPLIANCE

**Must Implement (later phases):**
- HTTPS only
- Secure storage for tokens
- Biometric = local only
- Google OAuth handled via official plugin + backend verification
- No secrets in Dart code
- Proper authorization checks on every private endpoint

**Authorization Test Case (mandatory):**
User A must never access User B's watchlist/alerts/etc.

---

## 9. PHASE 1 STATUS REPORT

**PHASE:** 1 — Complete Analysis + Architecture + Premium UI Concept  
**STATUS:** ✅ COMPLETE

### Implemented
- Full fresh inspection of Flutter + Android + Backend
- Requirements analysis from the new master prompt
- Correct architecture designed (Flutter + Authentication focus)
- Design system locked (Obsidian + Gold)
- 5 new premium UI concept images generated (Splash, Login, Sign Up, Biometric, Home)

### Tested
- N/A (analysis phase)

### Working (Existing Strong Foundation)
- Theme system
- Backend auth infrastructure
- Repository pattern
- GoRouter navigation

### Identified Gaps (Must Fix)
- Missing `google_sign_in` + `local_auth` dependencies
- No Google or Biometric flows
- Basic auth screens need major premium upgrade
- No biometric enable/unlock UX

### Blocked
- None

### Remaining (Phase 1)
- None — Phase 1 is complete

**Next Phase Recommendation:** Phase 2 — Flutter Foundation + Theme Refinement + Authentication UI Shell

---

## 10. RECOMMENDATION

**Phase 1 is complete.**

The project has been properly analyzed.

**Premium visual direction is defined and visualized.**

**Architecture is clear**, with special emphasis on the complex authentication requirements (Email + Google + Biometric + fallback).

**Please reply with one of the following:**

1. `APPROVE PHASE 1 — PROCEED TO PHASE 2`  
   (Flutter foundation + premium Login/SignUp/Biometric UI + Google + local_auth setup)

2. Request specific changes to Phase 1 concepts or architecture.

We will not proceed to implementation until you explicitly approve.

---

**End of Phase 1 Report**