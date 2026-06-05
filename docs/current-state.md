# Current State — Osbaldida 2026

Handoff summary for resuming the project after a compacted conversation.
All detail lives in `docs/` and `reference/`. This file is an orientation map, not a duplicate.

---

## Project goal

Mobile-first web app for a cycling-themed bachelor party, 5–7 June 2026, 19 participants.
Manages live scoring classifications, jersey competitions, event roadbook, rules, and photo gallery.
Used almost exclusively from mobile phones during the event.

---

## Tech stack (decided — do not revisit)

| Layer | Decision |
|-------|---------|
| Framework | Astro with `@astrojs/cloudflare` adapter (SSR on Workers) |
| Interactivity | React islands only where needed (tab switchers, scoring forms, voting) |
| Types | TypeScript strict mode |
| Styling | Tailwind CSS with custom cycling design tokens |
| Runtime | Cloudflare Workers |
| Database | Cloudflare D1 (SQLite) |
| File storage | Cloudflare R2 (photos) — public bucket |
| Input validation | Zod on all API inputs |
| Local dev | `wrangler dev` with D1 + R2 simulation |

No external services. No real-time push. No user accounts.

---

## Six pages

| Route | Auth | Rendering | Purpose |
|-------|------|-----------|---------|
| `/` | Public | SSR | Landing, event intro, jersey overview, participants |
| `/clasificaciones` | Public | SSR | All classification tabs (live from D1) |
| `/puntuaciones` | Shared code | SSR | Admin: scoring, voting, yellow jersey, team assignment, awards |
| `/reglas` | Public | Prerender | Rules accordion: jerseys, Friday/Saturday/Sunday scoring, voting |
| `/roadbook` | Public | Prerender | Full event programme from `reference/plan/planning.md` |
| `/galeria` | Browse: public / Upload: optional code | SSR | Photo upload + grid |

---

## Mobile-first requirements (non-negotiable)

- Minimum viewport: **360px** — all tables and layouts must fit without horizontal scroll
- Tap targets: **≥ 44×44px** on every interactive element
- Input `font-size`: **≥ 16px** on all `<input>` elements (prevents iOS auto-zoom)
- Bottom nav: `padding-bottom: env(safe-area-inset-bottom)` for iPhone home bar
- No `overflow-x: auto` on classification tables
- Jersey images: always include `onerror` fallback to same-size color dot (poor mountain connectivity)
- Gallery input: `<input type="file" accept="image/*">` — **no `capture` attribute**

---

## Cloudflare architecture

```
Browser → Cloudflare Workers (Astro SSR)
               ├── env.DB     → D1 database (all structured data)
               └── env.PHOTOS → R2 bucket   (photo storage, public URL)
```

Server data flow: `Astro page → service → repository → env.DB`. No raw SQL outside `src/server/repositories/`.

Env vars: `ADMIN_CODE`, `GALLERY_CODE` (optional), `R2_PUBLIC_URL`.
Local dev: `.dev.vars` file (gitignored). Production: `wrangler secret put`.
Full wiring spec: `docs/cloudflare-architecture.md`.

---

## Source of truth files

| What | File |
|------|------|
| Event logistics, roadbook content, timings, practical info | `reference/plan/planning.md` ← primary source |
| Friday scoring rules (drink tables per climb) | `docs/scoring-system.md` (derived from `reference/scoring/Puntuacion.xlsx`) |
| App page specs and UI interactions | `docs/pages.md` |
| D1 schema and seed data | `docs/data-model.md` |
| Visual design tokens, component specs | `docs/design-reference.md` |
| Mobile layout rules and form patterns | `docs/mobile-ui-guidelines.md` |
| Cloudflare wiring and env vars | `docs/cloudflare-architecture.md` |

The Webflow template at `reference/webflow-template/` is visual reference only — fonts, spacing tokens, color palette. Do not migrate its HTML, `w-` classes, or JavaScript.

---

## Scoring summary

**Event structure:**

| Day | Route | Scoring |
|-----|-------|---------|
| Friday 5 June | Llodio → Oviedo | Stage 1 — 4 climbs, fixed rules from Excel |
| Saturday 6 June | Oviedo → Viapará → Angliru | Stage 2 — 3 climbs, manual admin entry |
| Sunday 7 June | Bajada y meta | Ceremonial — no scoring |

**Friday climbs (fixed rules):**
- Gardea: chip per participant (0 / +1 / +2)
- Avituallamiento: car group selector → percentage chip → same points to all in group
- Gato Negro: accumulative checkboxes per drink type per participant
- Gascona: **two independent checkboxes** — piruleta (+3) AND Jäger (+8), both tickable simultaneously, max +11 per participant. Not a radio chip.

**Saturday climbs (manual):** Viapará, Angliru, Café Torero — admin enters points + reason + evidence per participant per climb. No fixed drink tables.

**Arrival bonus:** Friday active. Saturday inactive for MVP (`is_active = 0` in seed).

**Green jersey voting:** 2 rounds, stored in `green_vote_rounds` table.
- Round 1 (Saturday morning): evaluates Friday performance
- Round 2 (Sunday): evaluates Saturday performance
- Per voter: assign +5 / +3 / +1 / -1 to 4 different participants. No self-vote.

**Yellow jersey:** Manual validation by admin. Awarded to participant who arrives latest at hotel Saturday.

**Teams:** Mapei, Rabobank, ONCE, Kelme, Festina. All 19 participants start with `team_id = NULL`, assigned via admin UI before the event.

Full rules: `docs/scoring-system.md`.

---

## Data model summary (12 tables)

| Table | Contents |
|-------|---------|
| `teams` | 5 teams with `jersey_image_path` and `color_hex` (hex values TBD) |
| `participants` | 19 participants with `nickname`, `first_name`, `last_name`; `team_id` nullable (NULL at seed) |
| `stages` | 3 stages (Friday, Saturday, Sunday) |
| `climbs` | 7 climbs with `scoring_type` (`individual`, `team`, `accumulative`, `manual`) |
| `score_events` | 9 rows — all active scoring events; row 9 (Saturday arrival) `is_active = 0` |
| `scores` | Per-participant per-event scores, upsert on re-entry |
| `green_vote_rounds` | 2 rounds (seeded) |
| `green_votes` | Per-voter per-round votes; UNIQUE (round, voter, points) |
| `yellow_jersey_validations` | Yellow jersey candidate data |
| `jersey_awards` | Confirmed jersey holders per type per scope (provisional / final) |
| `photos` | Photo metadata (R2 key, uploader, caption, stage, timestamp) |
| `admin_sessions` | Session tokens for admin code auth |

Full schema with constraints and derived queries: `docs/data-model.md`.

---

## Design direction

**Identity:** Yellow / black / white cycling palette. Inspired by Tour de France classification UI.

**Key tokens:**
- `yellow: #FFBE00` — primary accent (never use for text on white — fails contrast)
- `race-black: #051408` — primary dark background
- `green: #93E360` — green jersey accent
- `orange: #F96E12` — secondary accent

**Fonts (self-hosted from `reference/webflow-template/fonts/`):**
- Inter Tight — body, UI, labels (weights 400/500/600/700)
- PT Sans Narrow — display, position numbers, stage titles (400/700)

**Jersey images** are the primary team/jersey identifiers — not emoji, not letter abbreviations.
Image sizes: 28×28px (table row), 32–40px (badge), max-height 80px (card).
Always include `onerror` fallback: same-size colored dot using `color_hex`.

**5-tab bottom nav (final — do not add a sixth):** Inicio / Clasificación / Puntuar / Roadbook / Galería.
Reglas is secondary access only: landing quick links, roadbook "Ver reglas" link, desktop top nav.

**Classification rows:** Top-3 get yellow/silver/bronze left border treatment.

Full tokens, shadows, component specs: `docs/design-reference.md`.
Mobile layout rules, form patterns, accessibility: `docs/mobile-ui-guidelines.md`.

---

## Implementation phases

| Phase | Goal | Status |
|-------|------|--------|
| 0 | Documentation validation — confirm no contradictions | Not started |
| 1 | Project setup — Astro + Cloudflare + TypeScript + folder structure | **Done** |
| 2 | Static assets + design tokens — images at public paths, Tailwind config | **Done** |
| 3 | App shell + navigation — 5-tab bottom nav at 360px | **Done** |
| 4 | Static pages — `/reglas`, `/roadbook`, `/` landing (no DB) | **Done** |
| 5 | D1 schema + seed data — all 12 tables, repositories | **Done** |
| 6 | Classification read layer — 5-tab `/clasificaciones`, SSR, team badge fallback | Not started |
| 7 | Admin + scoring flows — auth, all 6 form variants, voting, team assignment | Not started |
| 8 | Gallery with R2 — upload + grid, no `capture` attribute | Not started |
| 9 | Cloudflare deployment — production D1 + R2, env vars, smoke test | Not started |
| 10 | QA + event readiness — real devices, calculation verify, team assignments | Not started |

Phases 4 and 5 are independent and can be parallelized. Everything else is sequential.
Full phase specs with acceptance criteria, expected files, and out-of-scope items: `docs/implementation-plan.md`.

---

## Current status

**Phase 5 complete.** D1 schema and seed data done. Ready for Phase 6.

All design and architecture decisions are resolved:
- 5-tab navigation is final
- `score_events` / `scores` table model is final (no `mountain_scores` / `arrival_results`)
- Gascona form uses two independent checkboxes — not a radio chip
- Green jersey uses 2 `green_vote_rounds` — not "5 events per stage"
- Gallery uses `accept="image/*"` without `capture` — final
- R2 photo serving via public bucket — decision closed

**One pending item (non-blocking):** Car logistics (who drives which car) not yet confirmed by organizer. Noted as a placeholder in roadbook Información práctica. The Avituallamiento scoring form uses ad-hoc group selection on the day.

---

## Next recommended step

**Start Phase 6 from `docs/implementation-plan.md`.**

Phase 6 is the classification read layer: connect `/clasificaciones` to D1, implement the 5-tab ranking view (general, mountain, green, team, yellow), and create repositories and services for the ranking queries. No admin forms yet.
