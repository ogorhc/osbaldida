# Product Context — Osbaldida 2026

## What is this

Osbaldida 2026 is a cycling-themed bachelor party event for approximately 18 participants.
It takes place over three days: Friday 5 June, Saturday 6 June, and Sunday 7 June 2026.

The event involves two cycling stages with drink-based scoring challenges at mountain passes,
social/party performance voting, jersey competitions, and a final ceremonial day.

This web app supports the event by:
- Keeping all participants informed about the programme (roadbook)
- Displaying live classifications and jersey standings
- Allowing the organization to enter scores and votes
- Hosting the event gallery
- Explaining the rules

## Reference files

The project maintains a clean separation between raw planning material and the app's documentation:

| File | Role |
|------|------|
| `reference/plan/planning.md` | **Source of truth for event logistics** — full programme, timings, accommodation, practical info, Angliru logistics, required kit. Written in Spanish in the voice of the organizers. |
| `reference/scoring/Puntuacion.xlsx` | Source of truth for Friday climb scoring rules (drink tables). |
| `docs/scoring-system.md` | Structured scoring rules derived from the Excel, with open questions resolved. |
| `docs/pages.md` | How the app displays all of the above. |

The `/roadbook` page derives its static content from `reference/plan/planning.md`.
Scoring rules are never copied from planning.md — they live in `docs/scoring-system.md`.

## Users

There are two user types:

### Participants (18 people)

Trueba, Java, Igor, Motri, Maka, David, Zaloa, Kamil, Fiti, Patiño, Uxue, Gambo, Bakana,
Tru, Fabio, Fikri, Aintzane, Txete.

They are:
- Mobile-only (Android and iOS)
- Not necessarily tech-savvy
- Checking classifications casually between activities
- Uploading photos from the gallery
- Reading the rules and roadbook

### Organization (1–2 admins)

The organizer(s) responsible for:
- Entering scores at each climb checkpoint
- Recording arrival times and results
- Managing green jersey votes after each scoring event
- Approving or moderating photos
- Awarding jerseys

Admins use the same mobile devices as participants, via a protected `/puntuaciones` page.

## Context of use

- The app will be used **almost exclusively from mobile phones during the event**
- Coverage and connectivity may be limited in mountain areas
- Participants are in a party atmosphere — interfaces must be large, clear, and forgiving
- There is no time for complex navigation or small touch targets
- The app does not need real-time push notifications
- Classifications can be refreshed manually by the user

## Event programme overview

| Day | Route | Type |
|-----|-------|------|
| Friday 5 June | Llodio → Oviedo | Stage 1 — 4 scoring climbs |
| Saturday 6 June | Oviedo → Viapará → Angliru | Stage 2 — 3 scoring climbs |
| Sunday 7 June | Bajada y meta | Ceremonial — no scoring |

## Teams

Each participant belongs to one of five predefined cycling teams:
- Mapei
- Rabobank
- ONCE
- Kelme
- Festina

Team assignments are fixed before the event. The team classification accumulates
points from all members across all scoring stages.

> **Open question:** Team–participant assignment is not in the reference files.
> Assignments must be provided by the organizer before the event, or at first use.

## Jersey competition overview

| Jersey | Awarded for | Determined by |
|--------|------------|---------------|
| Yellow (amarillo) | Arriving latest at hotel Saturday morning | Manual validation by org |
| Green (verde) | Best social/party performance during Friday | Collective vote by all participants |
| Mountain/Points (puntos) | Highest accumulated climb scores | Automatic from scored climbs |
| Team (equipos) | Best cumulative team score | Automatic from mountain scores |

Full jersey rules are in `docs/scoring-system.md`.

## Core user stories

### Participants

- As a participant, I want to see the current general classification so I know who is leading.
- As a participant, I want to see the stage classification after each stage.
- As a participant, I want to see which jersey each person is wearing.
- As a participant, I want to read the scoring rules before the event.
- As a participant, I want to read the roadbook to know what is planned each day.
- As a participant, I want to upload photos from the event to the shared gallery.
- As a participant, I want to browse the gallery to see photos from others.

### Admins

- As an admin, I want to enter climb scores for each participant after each checkpoint.
- As an admin, I want to record the arrival order at the end of each stage.
- As an admin, I want to collect green jersey votes after each scoring event.
- As an admin, I want to record the yellow jersey (hotel arrival time on Saturday morning).
- As an admin, I want to see the current state of all classifications at any time.
- As an admin, I want to award jerseys after each stage.

## Out of scope for MVP

- Real-time live tracking (GPS, Strava)
- User accounts or per-participant login
- In-app messaging or chat
- Route map rendering
- Full photo moderation queue
- Notifications

## Open questions

1. **Team–participant assignments** — All 18 participants start unassigned (`team_id = NULL`).
   The organizer assigns each participant to a team via `/puntuaciones → Equipos — asignación`
   before the event.

2. **Saturday climb scoring rules** — No formal drink/challenge tables exist for Viapará, Angliru,
   or Café Torero. MVP uses manual point entry per participant per climb. The organizer may define
   formal rules before the event; if so, update `docs/scoring-system.md` and the scoring form UI.

3. **Car logistics** — Which participants are in which car is not yet confirmed. The Avituallamiento
   scoring form uses ad-hoc group selection on the day. No car table in the database.

4. **Café Torero location** — Opción A (Mieres) vs Opción B (Oviedo) is decided on the day based
   on group condition. The roadbook notes both options without committing to one.
