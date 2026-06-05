# Implementation Plan — Osbaldida 2026

## Prerequisites (before any code)

| Item | Owner | Blocking | Status |
|------|-------|---------|--------|
| Admin code value | Organizer | Phase 9 (production) only — use `.dev.vars` locally | Pending |
| Custom domain (if any) | Organizer | Phase 9 optional step | Pending |
| R2 photo serving | Developer | **Closed** — use public R2 bucket (see `docs/cloudflare-architecture.md`) | Resolved |
| Car logistics (who drives, how many cars) | Organizer | Non-blocking — add to roadbook before Phase 10 completes | Pending |
| Team-to-participant assignments | Organizer | Non-blocking — assigned via admin UI in Phase 7 before event | Done via admin UI |
| Saturday climb scoring rules | Organizer | Non-blocking — MVP uses manual entry | Resolved: manual entry |
| Green jersey voting scope | Organizer | Non-blocking | Resolved: 2 rounds |

---

## Dependency order

```
Phase 0 (docs validation) — no code
  └─ Phase 1 (project setup)
       └─ Phase 2 (static assets + design tokens)
            └─ Phase 3 (app shell + navigation)
                 ├─ Phase 4 (static pages) ── no DB required
                 └─ Phase 5 (D1 schema + seed data)
                      └─ Phase 6 (classification read layer)
                           └─ Phase 7 (admin + scoring flows)
                                └─ Phase 8 (gallery + R2)
                                     └─ Phase 9 (Cloudflare deployment)
                                          └─ Phase 10 (QA + event readiness)
```

Phases 4 and 5 are independent of each other and can be parallelized. Everything else is sequential.

---

## Phase 0 — Documentation validation

**Goal:** Confirm all docs are consistent and no blocking contradictions remain before writing a single line of code.

**Tasks:**
- [ ] Cross-check nav item count across all docs — must be 5 everywhere, not 6
- [ ] Confirm scoring model uses `score_events` and `scores` — no references to `mountain_scores` or `arrival_results`
- [ ] Confirm Gascona input is two independent checkboxes (not a radio chip)
- [ ] Confirm green jersey uses `green_vote_rounds` (2 rounds total, not "5 events")
- [ ] Confirm gallery file input uses `accept="image/*"` with no `capture` attribute anywhere
- [ ] Confirm jersey image file list in `reference/assets/maillots/` matches all paths referenced in `docs/pages.md` and `docs/design-reference.md`
- [ ] List any remaining open questions with explicit blocking/non-blocking status

**Expected files:** None. Documentation review only.

**Dependencies:** All files in `docs/` and `reference/`.

**Acceptance criteria:**
- No contradictions found between any two docs
- All open questions either resolved or explicitly flagged as non-blocking with a workaround
- A short written confirmation (comment or note) that the team is aligned before Phase 1 begins

**Out of scope:** Any code changes, file creation, scaffolding.

---

## Phase 1 — Project setup ✓ DONE

**Goal:** Bare Astro project wired to Cloudflare, TypeScript strict mode on, local dev server running.

**Tasks:**
- [x] Init Astro project with `@astrojs/cloudflare` adapter
- [x] Enable TypeScript strict mode in `tsconfig.json`
- [x] Configure `wrangler.toml` with D1 and R2 binding names only (no production IDs yet)
- [x] Add `src/env.d.ts` — environment variable types (`ADMIN_CODE`, `GALLERY_CODE`, `R2_PUBLIC_URL`, `DB`, `PHOTOS`)
- [x] Add `.dev.vars` template (gitignored)
- [x] Create folder structure as defined in `CLAUDE.md` (`src/pages/`, `src/components/`, `src/features/`, `src/server/`, `src/data/`)
- [x] Verify `wrangler dev` runs and serves a blank Astro page without errors

**Expected files:**
- `astro.config.mjs`
- `wrangler.toml`
- `tsconfig.json`
- `package.json`
- `src/env.d.ts`
- `.dev.vars` (gitignored template with placeholder values)

**Dependencies:** None.

**Acceptance criteria:**
- `wrangler dev` serves a blank Astro page with no TypeScript or runtime errors
- TypeScript strict mode enabled — any type error fails the build
- Folder structure matches `CLAUDE.md` architecture section exactly
- No D1 or R2 connection required for `wrangler dev` to start

**Out of scope:** Tailwind config, fonts, design tokens, images, any page content.

---

## Phase 2 — Static assets and design tokens ✓ DONE

**Goal:** All design tokens in Tailwind; all jersey and stage images at their final public paths; fonts loading locally.

**Tasks:**
- [x] Copy maillot images from `reference/assets/maillots/` → `public/assets/maillots/` (amarillo, verde, puntos-rojo-balnco, maillot-iker, and all 5 team jerseys)
- [x] Copy stage images → `public/assets/stages/` (etapa-viernes.webp, etapa-sabado.webp, alto-del-angliru.webp)
- [x] Add Inter Tight and PT Sans Narrow as local font files (from `reference/webflow-template/fonts/`)
- [x] Configure Tailwind CSS v4 via `src/styles/global.css` `@theme`: color tokens, font families, all 5 shadow tokens, border-radius pill, jersey/safe-area utilities
- [x] Create `src/data/jerseys.ts` — jersey path constants and fallback colors per jersey type
- [x] Verify `reference/` directory is not served as public assets

**Expected files:**
- `public/assets/maillots/*.png` (amarillo, verde, puntos-rojo-balnco, maillot-iker, 5 team jerseys)
- `public/assets/stages/*.webp`
- `public/assets/fonts/` (Inter Tight + PT Sans Narrow woff2 files)
- `tailwind.config.ts` (or `.mjs`)
- `src/data/jerseys.ts`
- Global CSS / font-face declarations (e.g. `src/styles/global.css`)

**Dependencies:** Phase 1.

**Acceptance criteria:**
- All jersey images accessible at their public URLs
- All Tailwind custom tokens resolvable in any component (`bg-yellow`, `text-race-black`, `shadow-card`, etc.)
- `font-family: 'Inter Tight'` and `'PT Sans Narrow'` load with no network request (local files only — verify with DevTools Network tab)
- `onerror` fallback renders a same-size colored dot and does not break layout
- No files from `reference/` are served under any public URL

**Out of scope:** Any page content, navigation, DB schema, components beyond `src/data/jerseys.ts`.

---

## Phase 3 — App shell and navigation

**Goal:** Five-tab sticky bottom nav present on all pages; AppShell renders correctly at 360px; no content yet.

**Tasks:**
- [ ] Create `src/components/layout/Layout.astro` — AppShell wrapper (slots for nav + content)
- [ ] Create `src/components/ui/PageHeader.astro` — page title block
- [ ] Create `src/components/navigation/BottomNav.astro` — 5 tabs: Inicio, Clasificación, Puntuar, Roadbook, Galería
  - `position: fixed; bottom: 0; width: 100%`
  - `padding-bottom: env(safe-area-inset-bottom)`
  - Height: 56px + safe area; background: `#051408`
  - Active: yellow icon + yellow 11px label; inactive: white + `opacity: 0.6`
  - Minimum tab width 64px (5 × 64px = 320px fits in 360px)
- [ ] Create `src/components/navigation/TopNav.astro` — desktop only, includes all 6 links (including Reglas)
- [ ] Create 5 empty Astro pages: `/`, `/clasificaciones`, `/puntuaciones`, `/roadbook`, `/galeria`
- [ ] Create `/reglas` as a prerendered empty page — not in bottom nav
- [ ] Wire BottomNav and TopNav to all pages via Layout.astro
- [ ] Bottom nav hidden on `md:` (≥768px); top nav shown on `md:`
- [ ] Verify 5 bottom tabs visible at 360px; all tap targets ≥ 44×44px
- [ ] Verify iOS safe area clears the iPhone home indicator bar

**Expected files:**
- `src/components/layout/Layout.astro`
- `src/components/ui/PageHeader.astro`
- `src/components/navigation/BottomNav.astro`
- `src/components/navigation/TopNav.astro`
- `src/pages/index.astro`
- `src/pages/clasificaciones.astro`
- `src/pages/puntuaciones.astro`
- `src/pages/roadbook.astro`
- `src/pages/galeria.astro`
- `src/pages/reglas.astro`

**Dependencies:** Phase 2 (design tokens required for nav styling).

**Acceptance criteria:**
- All 5 bottom tabs render and navigate correctly at 360px
- Active tab highlighted in yellow; inactive at reduced opacity
- Reglas is NOT in the bottom nav
- TopNav includes all 6 links on desktop (≥768px)
- Bottom nav hidden and top nav shown on desktop
- iOS home bar clearance confirmed (safe area inset)
- No JavaScript errors on any empty page
- Tab labels are 11px Inter Tight weight 500 — not 12px or 14px

**Out of scope:** Any page content, DB queries, auth, interactive components, the content of `/reglas` or any other page.

---

## Phase 4 — Static pages (with static data)

**Goal:** `/reglas` and `/roadbook` fully implemented with content from reference files; landing page `/` with static data; no DB required for any of these pages.

**Tasks:**

`/reglas`:
- [ ] Jersey accordion sections (one per jersey), each showing the jersey image alongside the name
- [ ] Friday scoring section (Etapa 1): 4 climbs with scoring tables, arrival bonus rules — all from `docs/scoring-system.md`
- [ ] Saturday scoring section (Etapa 2): 3 climbs, explain manual scoring process, no fixed point tables
- [ ] Sunday section: ceremonial note (no scoring, no attacks, checkout before 12:00)
- [ ] Green jersey voting rules: who votes, timing (2 rounds), points scale (+5/+3/+1/-1), tie-break
- [ ] General rules section (Normas generales)
- [ ] Mark page as `prerender = true`
- [ ] Verify all scoring tables readable at 360px without horizontal scroll

`/roadbook`:
- [ ] **Read `reference/plan/planning.md` in full before writing any roadbook content**
- [ ] Programa general: 3-day overview with timeline chips
- [ ] Etapa 1 (Viernes): stage image, meeting point (Polideportivo Gardea 16:30), departure ~18:00, 4 climb cards, evening (Sidrería El Gato Negro 22:00, Gascona area)
- [ ] Etapa 2 (Sábado): stage image, 10:00 jersey delivery, 10:15 departure (Iker departs later), 3 climb cards, Angliru logistics
- [ ] Domingo: ceremonial, checkout before 12:00, optional lunch
- [ ] Información práctica: accommodation (Viviendas Oviedo Catedral), key pickup (Gran Hotel España, Calle Jovellanos, 2), pedestrian street note, DNI required, parking via Gran Hotel España, dinner (El Gato Negro 22:00), car logistics placeholder (add when organizer confirms)
- [ ] Material obligatorio: kit list from `reference/plan/planning.md`
- [ ] Mark page as `prerender = true`
- [ ] Include "Ver reglas" link to `/reglas`
- [ ] **Verify all roadbook content matches `reference/plan/planning.md` before marking done**

`/` Landing page:
- [ ] Hero section: stage image background, event name/date, CTA "Ver clasificaciones", secondary links (Roadbook, Reglas)
- [ ] Event summary: 3 static cards (Stage 1, Stage 2, Sunday)
- [ ] Participants grid: static names list, "Sin equipo" placeholder badge for all (no team data yet)
- [ ] Jersey overview: 4 jersey images with names, "Por determinar" for all holders (no DB yet)
- [ ] Quick links section including direct link to `/reglas`

**Expected files:**
- `src/pages/reglas.astro` (or `src/pages/reglas/index.astro`)
- `src/pages/roadbook.astro` (updated with full content)
- `src/pages/index.astro` (updated with static content)
- `src/features/rules/` (accordion components)
- `src/features/roadbook/ClimbCard.astro`
- `src/features/roadbook/StageCard.astro`
- `src/data/event.ts` (static event config: dates, routes, stage names)
- `src/data/climbs.ts` (static climb data: names, categories, altitudes)
- `src/data/participants.ts` (static participant name list for pre-DB landing)

**Dependencies:** Phase 3 (AppShell required for layout).

**Acceptance criteria:**
- `/reglas` fully readable at 360px; no scoring table overflows horizontally
- All 4 Friday climb scoring tables present and accurate (matches `docs/scoring-system.md`)
- Saturday section describes manual process clearly without fake point tables
- `/roadbook` content verified line-by-line against `reference/plan/planning.md`
- `/roadbook` includes "Ver reglas" link
- `/reglas` and `/roadbook` built as prerendered static pages (no SSR)
- Landing page renders all 5 sections with static data; "Por determinar" shown for jersey holders; "Sin equipo" shown for all participants
- No DB connection required for any of these 3 pages

**Out of scope:** Live DB data on any page, team assignment form, classification tabs, gallery, auth.

---

## Phase 5 — D1 schema and seed data

**Goal:** Full D1 schema applied locally; all seed data queryable; repository layer compiles clean.

**Tasks:**
- [ ] Write `001_initial_schema.sql` from `docs/data-model.md` (all 12 tables: teams, participants, stages, climbs, score_events, scores, green_vote_rounds, green_votes, yellow_jersey_validations, jersey_awards, photos, admin_sessions)
- [ ] Apply migration locally: `wrangler d1 migrations apply osbaldida-2026 --local`
- [ ] Write seed script: 5 teams, 3 stages, 7 climbs, 9 score_events (row 9 `is_active = 0`), 2 green_vote_rounds, 18 participants (all `team_id = NULL`)
- [ ] Write `src/server/db/client.ts` — D1 client wrapper
- [ ] Write repository files (raw D1 queries only, no business logic):
  - `participants.ts`, `teams.ts`, `stages.ts`, `climbs.ts`
  - `scores.ts`, `score_events.ts`
  - `votes.ts` (green_votes + green_vote_rounds)
  - `photos.ts`
  - `sessions.ts`
- [ ] Verify seed data: run queries manually and confirm row counts

**Expected files:**
- `src/server/db/migrations/001_initial_schema.sql`
- `src/server/db/client.ts`
- `src/server/db/seed.ts`
- `src/server/repositories/participants.ts`
- `src/server/repositories/teams.ts`
- `src/server/repositories/stages.ts`
- `src/server/repositories/climbs.ts`
- `src/server/repositories/scores.ts`
- `src/server/repositories/score_events.ts`
- `src/server/repositories/votes.ts`
- `src/server/repositories/photos.ts`
- `src/server/repositories/sessions.ts`

**Dependencies:** Phase 1 (folder structure and `client.ts` location). Independent of Phase 4.

**Acceptance criteria:**
- All 12 tables created with correct schema (check `docs/data-model.md` for constraints and foreign keys)
- Seed data loaded: 5 teams, 18 participants, 3 stages, 7 climbs, 9 score_events, 2 green_vote_rounds
- `score_events` row 9 (Saturday arrival bonus) has `is_active = 0`
- All repository files compile without TypeScript errors
- No raw SQL outside repository files (enforced by convention, not by a linter)

**Out of scope:** Services layer, API endpoints, any UI changes, production database.

---

## Phase 6 — Classification read layer

**Goal:** `/clasificaciones` shows live data from D1; all 5 tabs working; team badge with fallback.

**Tasks:**
- [ ] Write `src/server/services/classification.ts` — ranking logic:
  - **General:** sum of all active `score_events` scores per participant across all stages
  - **Etapa:** same, filtered by `stage_id`
  - **Verde:** sum of `green_votes` per participant across completed rounds
  - **Equipos:** sum of scores for all participants in each team (exclude `team_id = NULL`)
  - **Jerseys actuales:** latest `jersey_awards` row per jersey type
- [ ] Write classification repository queries (from `docs/data-model.md` derived queries section)
- [ ] Build `src/components/teams/TeamBadge.astro` — 28×28px team jersey `<img>` with `onerror` fallback to color dot (see `docs/design-reference.md` — jersey fallback pattern)
- [ ] Build `src/features/classification/ClassificationCard.astro` — single participant row (position, name, TeamBadge, points)
- [ ] Build `src/components/jerseys/JerseyCard.astro` — jersey image + holder name
- [ ] Build `src/features/classification/ClassificationTabs.tsx` React island (tab switcher: General / Etapa / Verde / Equipos / Jerseys actuales)
- [ ] Stage selector within "Etapa" tab
- [ ] Update `/clasificaciones` with SSR data fetch (every request)
- [ ] Update `/` landing page: replace static jersey overview with live DB data; replace static participant names with live team badge data
- [ ] Top-3 rows: yellow / silver / bronze left border treatment
- [ ] Empty state "Sin datos aún" for all tabs before any scoring
- [ ] Verify no column overflow at 360px

**Expected files:**
- `src/server/services/classification.ts`
- `src/server/repositories/classifications.ts`
- `src/components/teams/TeamBadge.astro`
- `src/features/classification/ClassificationCard.astro`
- `src/components/jerseys/JerseyCard.astro`
- `src/features/classification/ClassificationTabs.tsx`
- `src/pages/clasificaciones.astro` (updated with SSR data)
- `src/pages/index.astro` (updated with live jersey + participant data)

**Dependencies:** Phase 5 (D1 schema and repositories).

**Acceptance criteria:**
- All 5 classification tabs render data from local D1 seed
- General tab shows 18 participants with 0 points each ("Sin datos aún" or zero-state)
- Equipos tab excludes participants with `team_id = NULL`
- Team badge renders correctly at 28×28px; `onerror` fallback shows same-size color dot without breaking row layout
- No horizontal scroll at 360px on any tab
- SSR confirmed: no client-side fetch for initial load (check Network tab — no `/api/classifications` XHR on page load)
- Empty state shown gracefully on all tabs before event starts

**Out of scope:** Score entry, auth, voting, gallery, yellow jersey, team assignment form. Do not wire any scoring API yet.

---

## Phase 7 — Admin and scoring flows

**Goal:** `/puntuaciones` fully functional: auth, all scoring forms, arrival form, green jersey voting, yellow jersey, team assignment, jersey awards.

**Tasks:**

Auth:
- [ ] Write `src/server/services/auth.ts` — session creation and validation
- [ ] Write `POST /api/auth/login` — validate `ADMIN_CODE`, create session token, set HTTP-only cookie
- [ ] Write `src/server/repositories/sessions.ts` (if not already from Phase 5)
- [ ] Build code entry UI: full-screen overlay, single input, submit button
- [ ] Test: correct code → access; wrong code → inline error; expired session → redirect to code entry

Puntuación de eventos — Stage 1 (Friday, fixed rules):
- [ ] Write `src/server/validation/score.ts` — Zod schemas for all score input types
- [ ] Write `POST /api/scores` — upsert into `scores` table
- [ ] Build `ScoreForm` section framework: stage → scoring event selector (from active `score_events`)
- [ ] **Alto de Gardea:** 3-chip per participant (0 / +1 / +2)
- [ ] **Alto del Avituallamiento:** participant group selector → percentage chip → auto-apply to all selected; car name stored in evidence
- [ ] **Alto del Gato Negro:** accumulative checkboxes per drink type per participant
- [ ] **Alto de Gascona:** two independent checkboxes per participant — piruleta (+3) AND Jäger (+8) — **both can be ticked simultaneously (max +11)**. Not a radio chip. Not mutually exclusive.
- [ ] Show current saved state when opening any scoring form
- [ ] Auto-calculate points from input, display before saving
- [ ] Confirmation "Guardado ✓" inline toast on save
- [ ] Data loss prevention: warn on navigate-away from unsaved form

Puntuación de eventos — Stage 2 (Saturday, manual):
- [ ] Saturday manual scoring form: stage → event selector → per-participant rows (points stepper, reason free text, evidence note free text)
- [ ] Minimum numeric input height 52px, font-size ≥ 16px
- [ ] Save to `scores` table with `scoring_type = 'manual'`

Llegada — arrival bonus:
- [ ] Llegada form: ordered input for top 5 (drag-to-rank or position number input)
- [ ] Points auto-calculated: 1st +5, 2nd +4, 3rd +3, 4th +2, 5th +1
- [ ] Friday: active. Saturday: disabled (shows "pendiente de confirmación")

Maillot verde — voting:
- [ ] Write `src/server/validation/vote.ts` — Zod schemas
- [ ] Write `POST /api/votes`
- [ ] Build `VotingForm` React island:
  - Round selector at top: Round 1 (Saturday, evaluates Friday) / Round 2 (Sunday, evaluates Saturday)
  - Per voter per round: select voter, assign +5 / +3 / +1 / -1 to 4 different participants
  - Validation: all 4 tiers required; no duplicates; voter cannot self-vote
  - Round summary shown before final save: "X: +5, Y: +3, Z: +1, W: -1"
  - Indicate which voters have already voted for the selected round

Maillot amarillo:
- [ ] Build `YellowJerseyForm`: participant selector, arrival time input, selfie received checkbox, present at departure checkbox, notes field
- [ ] Write `POST /api/yellow-jersey`

Equipos — asignación:
- [ ] Build team assignment form: participant list → tap → team picker (jersey image + team name)
- [ ] Write `POST /api/participants/team` — updates `participants.team_id`
- [ ] Changes must propagate immediately to classification queries

Premios — jersey awards:
- [ ] Build jersey awards UI: current automatic leaders + confirm/override per jersey type
- [ ] Write `POST /api/jersey-awards`
- [ ] Notes field per award (tie-break reasoning, override justification)
- [ ] Support provisional scope (Saturday, Friday results only) and final scope (after Stage 2)

**Expected files:**
- `src/server/services/auth.ts`
- `src/server/validation/score.ts`
- `src/server/validation/vote.ts`
- `src/pages/api/auth/login.ts`
- `src/pages/api/scores.ts`
- `src/pages/api/votes.ts`
- `src/pages/api/yellow-jersey.ts`
- `src/pages/api/participants/team.ts`
- `src/pages/api/jersey-awards.ts`
- `src/features/scoring/ScoreForm.tsx`
- `src/features/scoring/GardeaForm.tsx`
- `src/features/scoring/AvitualllamientoForm.tsx`
- `src/features/scoring/GatoNegroForm.tsx`
- `src/features/scoring/GasconaForm.tsx`
- `src/features/scoring/SaturdayManualForm.tsx`
- `src/features/scoring/LlegadaForm.tsx`
- `src/features/scoring/YellowJerseyForm.tsx`
- `src/features/scoring/TeamAssignmentForm.tsx`
- `src/features/scoring/JerseyAwardsForm.tsx`
- `src/features/voting/VotingForm.tsx`
- `src/pages/puntuaciones.astro` (updated with all sections)
- `src/components/ui/` (shared chip, confirmation, toast patterns as needed)

**Dependencies:** Phase 6 (classification service used to show current leaders in Premios).

**Acceptance criteria:**
- Auth: correct code grants session cookie; wrong code shows error; expired session redirects
- All Friday scoring forms save to `scores` table correctly
- **Gascona: both piruleta and Jäger checkboxes can be ticked simultaneously — verify max +11 is possible**
- Saturday manual form saves points + reason + evidence per participant
- Llegada form active for Friday, disabled with label for Saturday
- Green jersey voting: 2 rounds selectable independently; validates no duplicates and no self-vote; shows round summary before save
- Team assignment: assigning a participant to a team immediately changes their classification output
- Jersey awards support provisional and final scopes
- Data loss prevention active on all unsaved forms
- All form inputs ≥ 16px font-size (no iOS auto-zoom)

**Out of scope:** Gallery, photo upload, R2 wiring, production deployment.

---

## Phase 8 — Gallery with R2

**Goal:** Photo upload and gallery browsing work on mobile.

**Tasks:**
- [ ] Write `src/server/storage/photos.ts` — R2 helpers (upload, generate unique key, read URL)
- [ ] Write `POST /api/gallery/upload`:
  - Validate file type (JPEG, PNG, WebP only)
  - Validate file size (max 10 MB)
  - Generate unique R2 key (timestamp + random suffix)
  - Write to R2 (`env.PHOTOS`)
  - Save metadata to D1 `photos` table (uploader name, caption, stage, R2 key, timestamp)
- [ ] Build `PhotoUploadForm` React island:
  - File input: `<input type="file" accept="image/*">` — **no `capture` attribute**
  - Uploader name input
  - Optional caption input
  - Stage tag selector (Friday / Saturday / Sunday)
  - Progress indicator during upload (spinner or thin progress bar)
  - Success: thumbnail + "Foto subida ✓"
  - Error: message + "Reintentar" button — do not lose selected file
- [ ] Build `PhotoGrid` (Astro or React island):
  - Responsive 2-column grid on mobile
  - Filter chips by stage/day
  - Tap to expand (modal or dedicated page)
  - Sorted newest first
  - `loading="lazy"` on all images
- [ ] Optional: `GALLERY_CODE` env var gate on upload (if set, require code; if not set, upload is open)
- [ ] Test upload on real iOS Safari and Android Chrome
- [ ] Test large file upload (5–10 MB)

**Expected files:**
- `src/server/storage/photos.ts`
- `src/pages/api/gallery/upload.ts`
- `src/features/gallery/PhotoUploadForm.tsx`
- `src/features/gallery/PhotoGrid.tsx` (or `.astro`)
- `src/pages/galeria.astro` (updated)

**Dependencies:** Phase 5 (photos table and D1 client). Phase 3 (AppShell). R2 binding in `wrangler.toml` already present from Phase 1 — no production bucket needed yet.

**Acceptance criteria:**
- Upload works on iOS Safari (file picker shown, not forced camera)
- File type and size validation returns clear errors
- Metadata saved to D1 `photos` table after upload
- Gallery grid shows uploaded photos sorted by upload time
- Filter by stage works correctly
- Upload error shows retry option without losing the selected file
- **No `capture="environment"` attribute anywhere in the upload form**

**Out of scope:** Photo moderation, thumbnail generation, production R2 bucket (Phase 9). No new scoring features.

---

## Phase 9 — Cloudflare deployment

**Goal:** App running in production on Cloudflare Workers with D1 and R2 fully wired.

**Tasks:**
- [ ] Create production D1 database: `wrangler d1 create osbaldida-2026` — copy the `database_id` into `wrangler.toml`
- [ ] Create production R2 bucket: `wrangler r2 bucket create osbaldida-photos` — confirm public access is enabled
- [ ] Set production secrets via `wrangler secret put`: `ADMIN_CODE`, `GALLERY_CODE`, `R2_PUBLIC_URL`
- [ ] Update `wrangler.toml` with production D1 `database_id` and R2 bucket name
- [ ] Apply migrations to production: `wrangler d1 migrations apply osbaldida-2026 --remote`
- [ ] Load seed data to production (teams, stages, climbs, score_events, green_vote_rounds, participants — all `team_id = NULL`)
- [ ] Build and deploy: `npm run build && wrangler deploy`
- [ ] Smoke test production URL: all 6 pages load; admin code works; fonts load locally (no network request in DevTools)
- [ ] Configure custom domain if requested by organizer
- [ ] Confirm R2 photo upload works end-to-end in production

**Expected files:**
- `wrangler.toml` (updated with production `database_id`)
- Any deployment notes or runbook (optional — not required)

**Dependencies:** Phase 8 (all features complete before production deployment).

**Acceptance criteria:**
- Production URL accessible and all 6 pages render
- Admin code grants access to `/puntuaciones` in production
- D1 seed data queryable from production (5 teams, 18 participants, etc.)
- R2 bucket writable from production Workers — test upload in production
- Fonts load from local files (no `fonts.googleapis.com` request)
- Custom domain resolves (if configured)

**Out of scope:** QA, real device testing, team assignments, content entry — all Phase 10.

---

## Phase 10 — QA and event readiness

**Goal:** App verified on real devices; calculations correct; team assignments complete; ready for 5 June 2026.

**Tasks:**
- [ ] Test all 6 pages on iOS Safari (iPhone)
- [ ] Test all 6 pages on Android Chrome
- [ ] Test scoring entry outdoors (simulate gloved finger, bright sunlight)
- [ ] Test photo upload on both iOS Safari and Android Chrome
- [ ] Test admin code entry: correct code → access; wrong code → clear error
- [ ] Simulate network failure: verify jersey image `onerror` fallback renders without breaking layout
- [ ] Verify empty state "Sin datos aún" shown on all classification tabs (pre-event)
- [ ] **Verify Gascona form: both piruleta and Jäger can be ticked simultaneously — max +11**
- [ ] Verify Saturday manual scoring form: saves reason and evidence correctly
- [ ] Verify green jersey voting: Round 1 and Round 2 operate independently; no self-vote; duplicate tier prevention
- [ ] Verify no hover-only interactions on any page (all actions accessible by tap)
- [ ] Verify scoring calculations: enter a known set of scores, confirm classification totals match manual calculation
- [ ] Re-read `reference/plan/planning.md` — verify roadbook content still matches
- [ ] Add car logistics to roadbook Información práctica when organizer confirms
- [ ] Enter all team assignments from organizer (via `/puntuaciones → Equipos — asignación`)
- [ ] Verify team classification excludes unassigned participants ("Sin equipo")
- [ ] Verify classifications page loads in under 1s on a 4G connection
- [ ] Verify fonts load from local files — confirm no Google Fonts network request in production

**Expected files:** No new files. Minor content edits only (e.g. roadbook car logistics).

**Dependencies:** Phase 9 (production environment required for real device testing).

**Acceptance criteria:**
- All 6 pages fully functional on iOS Safari and Android Chrome
- Scoring calculation verified against manual totals
- Jersey image fallback confirmed on both platforms
- Saturday manual scoring and green jersey voting (2 rounds) both work end-to-end
- No horizontal scroll at 360px on any page
- Roadbook content verified against `reference/plan/planning.md`
- All 18 participants assigned to teams (or "Sin equipo" shown where intentional)
- App ready before 5 June 2026

**Out of scope:** New features, schema changes, architectural changes. If a new requirement surfaces after Phase 10 begins, assess whether it fits within existing schema and forms — do not add tables or new pages at this stage.

---

## Estimated complexity

| Phase | Complexity | Notes |
|-------|------------|-------|
| 0 | Low | Documentation review only — no code |
| 1 | Low | Standard Astro + Cloudflare setup |
| 2 | Low | File copying + Tailwind config |
| 3 | Medium | Bottom nav safe area, responsive layout, iOS clearance |
| 4 | Medium | Content-heavy; scoring tables must fit 360px; roadbook must match planning.md exactly |
| 5 | Low | Mechanical SQL schema work |
| 6 | High | 5-tab classification, SSR, team badge fallback, live data on landing |
| 7 | High | 6 scoring form variants (including Gascona 2-checkbox); auth; 2-round voting; team assignment |
| 8 | Medium | R2 upload; mobile file input; gallery grid |
| 9 | Medium | Production wiring, env vars, smoke test |
| 10 | Medium | Real device testing, calculation verification, content entry |

---

## Decisions deferred to implementation

1. **Classification display:** Astro server components vs React islands with fetch.
   Recommendation: SSR via Astro for initial page load, React island only for tab switching.

2. **Gallery grid:** CSS grid with fixed aspect-ratio cells vs masonry.
   Recommendation: CSS grid (simpler, faster to build) for MVP.

3. **Scoring form layout:** Full page per climb vs accordion within one page.
   Recommendation: one accordion page per stage — less navigation overhead on mobile.

4. ~~R2 photo serving: public URL vs Worker route.~~ **Closed — use public R2 bucket.** Confirmed in `docs/cloudflare-architecture.md`. Simpler and faster for participants on slow connections.
