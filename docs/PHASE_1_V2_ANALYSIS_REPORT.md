# AURUM — PHASE 1 V2: COMPLETE ANALYSIS + ARCHITECTURE + PREMIUM UI CONCEPT

**Date:** 2026-08-12  
**Prompt:** MASTER PROJECT PROMPT V2  
**Status:** PHASE 1 COMPLETE  
**Directive:** Strict Phase 1 only. No full implementation until approved.

---

## 1. EXECUTIVE SUMMARY

AURUM is a **premium AI-powered cryptocurrency market analysis and intelligence mobile application**.

**Core Philosophy (V2):**
REAL MARKET DATA + DATA INTEGRITY + TECHNICAL ANALYSIS + MARKET REGIME DETECTION + EXPLAINABLE SIGNALS + AI MARKET ANALYST + PERSONALIZATION

This is a **full restart from Phase 1** per the V2 prompt.

**Current Project State (Inspected):**
- 61 Dart files
- Solid foundation exists (Obsidian+Gold theme, backend with 13 models, auth screens, biometric service, Google sign-in wiring, domain layer, multiple features)
- **Strengths:** Theme, backend Prisma schema, some auth work, repository pattern, design system
- **Gaps (per V2):** No market regime, weak data integrity layer, limited AI chat/history, no dedicated Security Center + 2FA, no professional charting, incomplete search, missing feature flags, incomplete offline + deep linking handling, architecture drift in places

**Recommendation:** 
- Keep the strong theme + backend + core abstractions
- Rebuild/enhance key layers for V2 requirements (Data Integrity, Market Regime, AI Analyst/Chat, Security Center, Professional Charts)
- Follow the exact new architecture and design language

**Phase 1 Deliverables:**
- Deep inspection completed
- Full requirements analysis
- Updated architectures (Flutter, Backend, AI, Security, Data)
- Centralized Design System confirmed
- 6 new premium V2 UI concepts generated
- Clear Phase 1 report

---

## 2. PROJECT INSPECTION (Fresh V2 Analysis)

### Flutter
- **pubspec.yaml**: Updated with `google_sign_in` + `local_auth` (good for auth requirements)
- Structure: `core/`, `features/` (14 modules), `shared/`, `domain/` — mostly aligned with V2 recommendation
- Theme: `AurumColors` (Obsidian + Gold) — **perfect match** for "premium financial intelligence"
- Navigation: GoRouter + shell — solid
- Current auth: Login/Signup + Google + Biometric service + splash logic already present (can be refined)

### Android
- Package: `com.aurum.marketintel`
- Manifest: Has `USE_BIOMETRIC` + `USE_FINGERPRINT` (correct for V2)
- Needs: Proper release signing config (standard for production)

### Backend
- Fastify + TypeScript + Prisma (very strong)
- Controllers for auth, watchlist, alerts, notifications, intelligence
- 13 Prisma models (User, Session, Alert, Notification, AIAnalysis, Signal, etc.)
- Good foundation for 2FA, security events, AI history

### Database
- Mature Prisma schema — ready for V2 additions (AI conversations, security logs, device sessions, regime history)

### Existing Problems Identified
1. **Data Integrity Layer** — missing (critical per V2)
2. **Market Regime Detection** — not implemented
3. **AI Analyst + Chat + History** — basic AI screen exists, needs full conversational + history + explainability
4. **Professional Charting** — basic charts, needs candlesticks + overlays + crosshair
5. **Security Center** — partial (needs 2FA, active sessions, login history, sign-out-all)
6. **Search** — basic in markets, needs global powerful search
7. **Architecture** — some mixing of concerns; needs stricter domain/services separation
8. **Feature flags / Cost control / Observability** — not present
9. **Deep linking + full lifecycle** — partial
10. **UI polish** — many screens exist but need to strictly follow new premium V2 concepts

**What to Keep / Strengthen**
- Theme system (lock it)
- Backend + Prisma
- Repository + state management pattern
- Biometric + Google wiring (refine)
- Existing analysis services (enhance)

**What Must Be Rebuilt / Added**
- Data integrity pipeline
- Market regime engine
- Full AI Analyst (chat + history + structured output)
- Professional charting component
- Security Center + 2FA
- Global search
- Enhanced offline + deep link handling
- Feature flag system
- Strict adherence to new UI concepts

---

## 3. PRODUCT REQUIREMENTS (V2)

**Must Answer for Users:**
- What is happening?
- Why?
- Supporting / Conflicting indicators?
- Current market regime?
- Risks?
- Scenarios?
- Invalidation conditions?

**New/Emphasized V2 Features:**
- Market Regime Detection
- Data Integrity Layer (validate before analysis)
- Professional Charting (candles + indicators)
- AURUM AI Analyst (conversational)
- AI History + Explainability
- Security Center (2FA, sessions, etc.)
- Global Search
- Advanced Personalization
- Cost control for AI
- Full audit logging

---

## 4. ARCHITECTURE DESIGN (V2 — APPROVED FOR PHASE 1)

### Flutter Architecture (Recommended)

```
lib/
├── core/
│   ├── constants/
│   ├── theme/                    ← Lock (Obsidian + Gold)
│   ├── routing/
│   ├── networking/
│   ├── storage/                  ← Secure + Biometric
│   ├── errors/
│   ├── security/                 ← New (biometric, 2FA helpers)
│   └── utils/
├── domain/                       ← Pure models (Asset, Regime, Signal, AIResult, etc.)
├── features/
│   ├── splash/
│   ├── onboarding/               ← Enhanced with personalization
│   ├── authentication/           ← Email + Google + Biometric + 2FA
│   ├── home/                     ← Market regime + personalized
│   ├── markets/
│   ├── search/                   ← Global (new)
│   ├── asset_details/
│   ├── charts/                   ← Professional (new dedicated)
│   ├── technical_analysis/
│   ├── market_regime/            ← New
│   ├── signals/
│   ├── ai_analyst/               ← Chat + History (new)
│   ├── watchlist/
│   ├── alerts/
│   ├── notifications/
│   ├── profile/
│   ├── security/                 ← Security Center (new)
│   └── settings/
├── shared/
│   ├── widgets/                  ← Reusable premium components
│   └── services/                 ← Repositories + Services
└── main.dart
```

### Data Flow (Strict)

```
UI (features)
  ↓ (Riverpod)
State / Controllers
  ↓
Repository (domain-aware)
  ↓
Service (Technical / Regime / Signal / AI)
  ↓
Data Integrity Layer ← NEW CRITICAL
  ↓
Backend API / Market Provider
  ↓
Database
```

### Key New Architectural Components

1. **DataIntegrityService** — Validate timestamps, missing data, outliers before any analysis
2. **MarketRegimeService** — Detect trending/ranging/volatility/breakout
3. **AIOrchestrator** — Structured context → AI → Validated output + conversation memory
4. **ChartService** — Provider-agnostic professional chart data
5. **SecurityService** — Biometric, 2FA, session, audit
6. **FeatureFlagService** — For cost control and phased rollouts

### Backend Architecture (Enhance Existing)

- Add endpoints:
  - `/auth/google`
  - `/auth/2fa/*`
  - `/ai/analyze`, `/ai/chat`, `/ai/history`
  - `/regime`
  - `/security/*`
  - `/search`

- Enhance Prisma for:
  - AIConversation + AIMessage
  - SecurityEvent
  - DeviceSession
  - MarketRegimeHistory (optional)

---

## 5. DESIGN SYSTEM (LOCKED)

**Already excellent** — we lock it for V2.

- `AurumColors` (Obsidian + Gold)
- `AurumTypography`
- `AurumSpacing`, `AurumRadius`, `AurumShadows`
- New: `AurumIcons`, `AurumAnimations` (minimal)

**Core Components to Enforce:**
- `AurumButton` (primary gold, secondary, Google, danger)
- `AurumCard`
- `AurumTextField` (with visibility, strength)
- `RegimeBadge`
- `SignalCard` (with explainability)
- `AIResponseCard`
- `ProfessionalChart`
- `SecurityTile`

All future screens must use only these tokens and components.

---

## 6. PREMIUM UI CONCEPTS (V2 — Generated)

New high-fidelity concepts created specifically for V2 prompt (Obsidian + Gold, sophisticated financial intelligence):

1. **Splash** — `assets/design/v2_splash.png`
2. **Login** — `assets/design/v2_login.png` (Email + Google + Forgot)
3. **Home Dashboard** — `assets/design/v2_home.png` (Regime + AI Insight + Movers)
4. **Asset Details** — `assets/design/v2_asset_detail.png` (Professional chart + Regime + AI + Signal)
5. **AI Analyst** — `assets/design/v2_ai_analyst.png` (Conversational + structured)
6. **Security Center** — `assets/design/v2_security_center.png` (2FA, Sessions, Biometric, etc.)

**Design Language Enforced:**
- Obsidian black + gold accents only
- Clean monospace prices
- Generous spacing
- Minimal, powerful, trustworthy
- No neon / excessive purple / clutter

These are the visual spec going forward.

---

## 7. PHASE 1 STATUS REPORT

**PHASE:** 1 — Complete Analysis + Architecture + Premium UI Concept (V2)  
**STATUS:** ✅ COMPLETE

### Implemented
- Deep inspection of current project (Flutter 61 files + Backend + Android)
- Full V2 requirements analysis
- Updated architectures (Flutter, Data Integrity, AI, Security, Backend)
- Design system locked
- 6 new premium V2 UI concepts generated

### Tested
- N/A (analysis phase)

### Working (Strong Foundation)
- Theme (Obsidian + Gold)
- Backend (Prisma + auth controllers)
- Biometric + Google wiring
- Repository pattern
- Multiple feature screens

### Identified Gaps (Must Address in Later Phases)
- Data Integrity Layer (critical)
- Market Regime Detection
- Professional Charting
- Full AI Analyst (chat + history)
- Security Center + 2FA
- Global Search
- Feature flags / cost control

### Blocked
- None

### Remaining (Phase 1)
- None

**Next Phase:**
Phase 2 — Flutter Foundation + Design System + Navigation + Core Premium Components + Onboarding Shell

---

## 8. RECOMMENDATION

**Phase 1 V2 is complete.**

We have:
- Properly analyzed the V2 prompt
- Inspected the existing code
- Designed the correct system architecture
- Locked the premium visual direction with new concepts

**Please reply with:**

> **APPROVE PHASE 1 V2 — PROCEED TO PHASE 2**

We will then systematically build:
- Phase 2: Foundation + Theme + Navigation + Auth UI shell
- And continue phase-by-phase as specified.

Do not proceed without explicit approval.

---

**End of Phase 1 V2 Report**