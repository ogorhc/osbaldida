# Pages — Osbaldida 2026

Six pages. Public except `/puntuaciones` (admin code required for score entry).

**Context of use:** This app is mobile-first and will be used primarily from Android and iOS phones during the event — outdoors, in mountain terrain, and party conditions. All pages must work fluidly at 360px width without horizontal scroll.

---

## 1. `/` — Landing page

**Purpose:** Event introduction. Orient first-time visitors, create anticipation. Entry point to all other pages.

**Sections:**

1. **Hero** — Event name, date, and tagline. Background uses one of the stage images
   (`reference/assets/etapa_viernes.webp` or `etapa_sabado.webp`).
   Primary call-to-action: "Ver clasificaciones" → `/clasificaciones`.
   Secondary links: "Roadbook" → `/roadbook`, "Reglas" → `/reglas`.

2. **Event summary** — 3 cards: Stage 1, Stage 2, Day 3.
   Each shows: date, route, key info (scoring / ceremonial).

3. **Participants** — Grid of participant names with team badge/color.
   No profile photos in MVP.
   Team badge shows the team jersey image (`teams.jersey_image_path`) as a small thumbnail.
   Participants with no team assigned show a neutral "Sin equipo" placeholder.

4. **Jersey overview** — 4 jersey cards: yellow, green, mountain/points, team.
   Each card uses the local jersey image at the top of the card:
   - Yellow: `/assets/maillots/amarillo.png`
   - Green: `/assets/maillots/verde.png`
   - Mountain/Points: `/assets/maillots/puntos-rojo-balnco.png`
   - Team (classification winner): winning team's `jersey_image_path`
   Brief one-line description of what each jersey represents.
   If the event has started, shows current leader in each.

5. **Quick links** — Chips/buttons to all main sections, including a direct link to `/reglas`.

**Auth:** Public (no auth required).

**Notes:**
- Landing is primarily motivational, not functional.
- If the event is over, the landing should show final results prominently.

---

## 2. `/clasificaciones` — Classifications

**Purpose:** Main reference page during the event. Shows all standings.

For MVP, the General leaderboard is the mountain/points classification — it combines all individual point sources (climbs, arrival bonus, manual bonuses, sanctions) across all scoring stages into one ranking. A separate "Puntos de montaña" tab is not needed unless the organizer requests it.

**Sections (tab or chip switcher):**

1. **General** — Overall individual points leaderboard.
   Ranked by total accumulated points from all active scoring events across all stages
   (climbs, arrival/repecho bonus, manual bonuses, sanctions).
   This is the mountain/points jersey classification.
   Columns: Position, Name, Team jersey thumbnail, Points.
   Team thumbnail: `<img>` from `teams.jersey_image_path` (28×28px, fallback to color dot).

2. **Etapa** — Per-stage leaderboard.
   Stage selector: Stage 1 / Stage 2.
   Includes all active scoring events for that stage only.
   Same team thumbnail as General tab.

3. **Maillot verde** — Green jersey classification.
   Total votes received across all completed voting rounds.
   Columns: Position, Name, Points.
   No team jersey image needed here.

4. **Equipos** — Team classification.
   Sum of all active scoring event points for all active members of each team.
   Columns: Position, Team jersey image, Team name, Total points.
   Team jersey image: `<img>` from `teams.jersey_image_path` (40×40px).

5. **Jerseys actuales** — Who is wearing each jersey today.
   Each jersey shows its image alongside the current holder's name:
   - Yellow: `/assets/maillots/amarillo.png`
   - Green: `/assets/maillots/verde.png`
   - Mountain/Points: `/assets/maillots/puntos-rojo-balnco.png`
   - Team classification winner: winning team's `jersey_image_path`
   Shows "Por determinar" if the jersey has not yet been awarded.

**Auth:** Public.

**Interactive elements:**
- Tab switcher between classification types (React island).
- Stage selector within the "Etapa" tab.

**Mobile considerations:**
- No wide tables on mobile. Use full-width cards or compact rows.
- Position number is prominent (large, left-aligned).
- Points column must always be visible without horizontal scroll.
- Tables must be scannable at a glance.

---

## 3. `/puntuaciones` — Scoring (admin)

**Purpose:** Organization interface to enter scores, votes, and jersey awards.

**Access control:** Protected by a simple shared code (entered once per session).
No user accounts. Code is stored server-side as an env variable (`ADMIN_CODE`).

**Sections (tab or accordion):**

1. **Puntuación de eventos** — Score entry for all configurable scoring events.

   Scoring is structured by `score_events` rows in the database. Each event has a type
   (`climb`, `arrival_bonus`, `manual_bonus`, `sanction`, `other`) and an `is_active` flag.
   Only active events accept new scores.

   **Flow:** Select stage → select scoring event → enter points/quantity/evidence per participant.

   **Stage 1 — Friday climbs (fixed rules from Excel):**
   Each climb shows its scoring rules as inline reference. Input adapts to the scoring type:
   - Alto de Gardea: radio chip per participant (0, +1, +2)
   - Alto del Avituallamiento: select participants in the car group → select percentage consumed → same points applied to all selected participants; car name stored in evidence notes
   - Alto del Gato Negro: accumulative checkboxes per drink type per participant
   - Alto de Gascona: checkbox pair (piruleta +3 / Jäger +8) per participant; both can be ticked (max +11 per participant)

   **Stage 2 — Saturday climbs (manual/configurable):**
   Saturday climbs are open configurable scoring events. The admin enters points directly per
   participant for each climb. Each score entry includes:
   - Points (numeric, positive or negative)
   - Reason (free text — e.g. "consumición en cima", "reto completado")
   - Evidence note (photo reference, description)
   - Optional: mark as a bonus (+) or sanction (−) for display purposes

   The three Saturday climbs are seeded as active `score_events` of type `climb` with
   `scoring_type = 'manual'`:
   - Puerto 1 — Alto de Viapará (2ª)
   - Puerto 2 — Alto del Angliru (HC)
   - Puerto 3 — Alto del Café Torero (1ª)

   If the organizer defines formal scoring rules before the event, the input form can be
   updated to match — but the data model supports manual entry from day one.

   **Saturday arrival bonus:**
   Listed as a scoring event within Stage 2 but marked inactive (`is_active = 0`) for MVP.
   Shown with a "pendiente de confirmación" label. If the organizer confirms it, toggling `is_active`
   enables the standard ranked entry form.

   **Manual bonuses and sanctions:**
   Admin can create manual bonus or sanction entries per participant with a notes field,
   corresponding to `score_events` rows of type `manual_bonus` or `sanction`.

   On save, points are written to the `scores` table (upsert — existing scores are overwritten).

2. **Llegada** — Arrival/repecho bonus entry.

   Shortcut to the `arrival_bonus` score event for each stage.
   Stage selector — only stages with an active arrival bonus event are enabled:
   - Friday: active.
   - Saturday: disabled for MVP (shows "pendiente de confirmación").

   For enabled stages: ordered input for top 5 finishers (drag-to-rank or position number input).
   Points auto-calculated from rank position: 1st +5, 2nd +4, 3rd +3, 4th +2, 5th +1.

3. **Maillot verde — votación** — Green jersey voting entry.

   Voting is organized in **rounds**, one per previous scoring day:
   - **Round 1 — Saturday morning:** evaluates Friday (Stage 1) social/party performance.
   - **Round 2 — Sunday:** evaluates Saturday (Stage 2) social/party performance.

   Round selector at the top. For each round, admin enters votes one voter at a time.

   Per voter per round:
   - Select voter (participant name)
   - Assign +5 to one other participant (best performance)
   - Assign +3 to one other participant (second best)
   - Assign +1 to one other participant (third best)
   - Assign -1 to one other participant (failure)
   - All four tiers must go to different participants. Self-voting not allowed.
   - Save per voter per round.

   The UI should indicate which participants have already had their vote recorded for this round.

4. **Maillot amarillo** — Yellow jersey form.
   - Participant selector.
   - Arrival time input.
   - Selfie received checkbox.
   - Present at departure checkbox.
   - Notes field.
   - Save button.

5. **Equipos — asignación** — Team assignment per participant.

   All 18 participants start with `team_id = NULL` (unassigned). The organizer assigns each
   participant to one of the five teams before the event via this section.

   - List of all participants, each showing current team jersey thumbnail (or "Sin equipo" badge).
   - Tap a participant to assign or change their team.
   - Team picker shows all five options with jersey image + team name:
     Mapei, Rabobank, ONCE, Kelme, Festina.
   - Changes apply immediately and affect all classification queries.
   - Unassigned participants are shown as "Sin equipo" on public pages and are excluded
     from team classification totals until assigned.

6. **Premios** — Jersey award confirmation.
   - Shows current automatic jersey leaders (mountain/points total, green vote total, team classification).
   - Confirm or manually override the awarded participant/team per jersey type.
   - Notes field per award — records tie-break reasoning or override justification.
   - Supports both provisional (Saturday 10:00, based on Friday results only) and final (after Stage 2) award scopes.

**Auth:** Code-protected. Code entered on first visit per session; session stored in HTTP-only cookie.

**Mobile considerations:**
- Large, accessible form inputs. Minimum font-size 16px on inputs.
- Participant selectors should use full names, not dropdowns where possible.
- Autosave or confirmation on submit to prevent accidental loss.
- Saturday manual scoring inputs must be as simple as possible — numeric stepper or chip picker.

---

## 4. `/reglas` — Rules

**Purpose:** Explain the event rules and scoring system clearly before and during the event.
Accessed via secondary links from Landing and Roadbook; not in the primary bottom nav.

**Sections:**

1. **Jerseys** — Four collapsible sections, one per jersey.
   Each section header shows the jersey image alongside the jersey name:
   - Maillot Amarillo: `/assets/maillots/amarillo.png`
   - Maillot Verde: `/assets/maillots/verde.png`
   - Maillot de Puntos: `/assets/maillots/puntos-rojo-balnco.png`
   - Maillot de Equipos: representative team jersey (e.g. first team alphabetically, or all five shown as a strip)
   Each section explains: what the jersey is, how it is won, and qualifying conditions.

2. **Puntuación de Etapa 1 — Viernes** — Friday scoring rules (fixed, from Excel reference).
   4 climbs, each with:
   - Climb name, category, altitude
   - Scoring table (condition → points)
   - Evidence requirement (photo, show organization, etc.)
   Arrival/repecho bonus: shown if confirmed active. Points table (positions 1–5).

3. **Puntuación de Etapa 2 — Sábado** — Saturday scoring.
   Saturday climbs are manually scored by the organization during the stage.
   This section explains that each climb has configurable scoring: the admin assigns points
   directly per participant, with a reason and evidence note.
   3 climbs:
   - Puerto 1 — Alto de Viapará (2ª): manual scoring
   - Puerto 2 — Alto del Angliru (HC): manual scoring
   - Puerto 3 — Alto del Café Torero (1ª): manual scoring
   If the organizer defines formal scoring rules before the event, they are shown here
   alongside the manual entry note. Until then, only the manual process is described.

4. **Domingo — Bajada y Meta** — Note that Sunday is ceremonial. No scoring. No attacks.
   Checkout before 12:00. Return journey.

5. **Maillot verde — votación** — Voting rules.
   Who votes (all participants), when (next-day rounds: Round 1 Saturday morning for Friday,
   Round 2 Sunday for Saturday), points scale (+5/+3/+1/-1), tie-break rule.

6. **Normas generales** — General event rules and expectations.

**Auth:** Public.

**Mobile considerations:**
- Collapsible sections (accordion) to avoid overwhelming on small screens.
- Scoring tables must be readable at 360px width.

---

## 5. `/roadbook` — Roadbook

**Content source:** `reference/plan/planning.md` — this is the source of truth for all roadbook
content. The page derives its static text, timings, logistics, and climb descriptions from that file.
Do not invent or paraphrase roadbook content; copy it from `reference/plan/planning.md`.

**Purpose:** Full event planning document. Reference for what happens each day, where to meet, and when.
Should be reviewed by all participants before 5 June 2026.

**Required sections (all content from `reference/plan/planning.md`):**

1. **Programa general** — Three-day overview with timeline chips (Friday, Saturday, Sunday).

2. **Etapa 1 — Viernes: Llodio → Oviedo** — Stage 1 programme.
   - Stage image (`etapa_viernes.webp`)
   - Meeting point: Polideportivo Gardea, Llodio — 16:30
   - Departure toward Oviedo: ~18:00
   - 4 scoring climb cards: Gardea, Avituallamiento, Gato Negro, Gascona
     (name, nickname, category, altitude, programme note)
   - Evening: dinner at Sidrería El Gato Negro 22:00, then Gascona area

3. **Etapa 2 — Sábado: Oviedo → Viapará → Angliru** — Stage 2 programme.
   - Stage image (`etapa_sabado.webp`)
   - 10:00 jersey delivery and signature control
   - 10:15 departure; Iker's car departs later so the group can position along the Angliru climb
   - 3 scoring climb cards: Viapará, Angliru, Café Torero (name, nickname, category, programme note)
   - Angliru logistics: group positions along the climb for challenges and penalties

4. **Domingo — Bajada y Meta** — Ceremonial day.
   - No scoring, no attacks
   - Checkout before 12:00
   - Return journey; optional lunch stop if group condition allows

5. **Información práctica** — Static logistics content.
   - Accommodation: Viviendas Oviedo Catedral
   - Key pickup: Gran Hotel España, Calle Jovellanos, 2
   - Note: apartment street is pedestrian — leave cars before entering
   - DNI required for check-in
   - Parking info: request at Gran Hotel España
   - Car logistics: pending organizer confirmation (add before deployment)

6. **Material obligatorio** — Required kit list (from `reference/plan/planning.md`):
   DNI, sports clothing, warm layer, rain gear, provisions for Angliru, fancy dress / accessories,
   attitude, respect for Jonhy Labios Sellados.

**Auth:** Public.

**Jersey images:**
- `maillot-iker.png` (`/assets/maillots/maillot-iker.png`) may be used decoratively
  where contextually relevant (e.g. alongside a yellow jersey summary, or in the Saturday
  evening section). Not required; organizer's call at content time.

**Mobile considerations:**
- Climb cards should be horizontally scrollable chips or vertical stack.
- Stage images should be displayed as full-width hero banners.
- Timeline should be a vertical timeline component, not a dense table.

---

## 6. `/galeria` — Gallery

**Purpose:** Shared photo album for the event. Participants upload and browse freely.

**Sections:**

1. **Subir foto** — Upload form (always visible at top).
   - Image file input: `<input type="file" accept="image/*">`.
     Do not use `capture="environment"` — it forces the camera on some devices and
     prevents users from uploading from their photo gallery.
   - Uploader name input (free text, no auth).
   - Optional caption input.
   - Stage/day tag selector (Friday / Saturday / Sunday).
   - Submit button.
   - Upload may be optionally gated by a shared participation code (separate from the admin code, stored as `GALLERY_CODE` env var; if not set, upload is open).

2. **Galería** — Grid of uploaded photos.
   - Masonry or uniform grid.
   - Tap to expand with caption and uploader name.
   - Filter chips by stage/day.
   - Sorted by upload time (newest first).

**Auth for upload:** Optional shared code gate (`GALLERY_CODE`). Browsing is always public.

**Technical notes:**
- Photos stored in Cloudflare R2.
- Metadata (uploader name, caption, stage, timestamp) stored in D1.
- Thumbnail generation: not in MVP (use originals with responsive sizing).
- Photos are not moderated in MVP (trust-based event).

**Jersey images:** No jersey image usage required on this page.

**Mobile considerations:**
- Upload button must be a large, prominent tap target (minimum 44×44px).
- Use `<input type="file" accept="image/*">` to allow users to select from their camera roll
  or take a new photo, depending on device behavior. Tested on both iOS Safari and Android Chrome.
- Grid must be touch-scrollable.
- Photo expansion must support pinch-to-zoom.

---

## Navigation

All pages share a global navigation component.

**Mobile navigation (primary — sticky bottom bar):**

Five tabs, always visible at the bottom:

| Tab label | Route | Notes |
|-----------|-------|-------|
| Inicio | `/` | |
| Clasificación | `/clasificaciones` | |
| Puntuar | `/puntuaciones` | Lock icon when not authenticated |
| Roadbook | `/roadbook` | |
| Galería | `/galeria` | |

Height: 56px minimum + `padding-bottom: env(safe-area-inset-bottom)` for iPhone home bar.
Active item: yellow icon + label. Inactive: white icon + label (reduced opacity).

**`/reglas` — secondary access (not in bottom nav):**
Rules are accessed via:
- A "Reglas" link/chip in the landing page quick links section.
- A "Ver reglas" link within the Roadbook page.
- A secondary overflow menu or hamburger menu (desktop and optionally mobile).

**Desktop navigation:**
- Horizontal top navbar with links to all six pages including Reglas.

---

## URL structure

| Path | Page |
|------|------|
| `/` | Landing |
| `/clasificaciones` | Classifications |
| `/puntuaciones` | Scoring (admin) |
| `/reglas` | Rules |
| `/roadbook` | Roadbook |
| `/galeria` | Gallery |
| `/api/*` | Server API routes (Cloudflare Workers) |
