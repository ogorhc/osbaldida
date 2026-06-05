# Data Model — Osbaldida 2026

Cloudflare D1 (SQLite). All tables use integer primary keys.
Timestamps are stored as ISO 8601 strings in UTC.
SQLite integer booleans: `0` = false, `1` = true.

---

## Entity overview

```
participants ──┬── teams
               │
               ├── scores ── score_events ──┬── stages
               │                            └── climbs
               │
               ├── green_votes ── green_vote_rounds ── stages
               │
               ├── yellow_jersey_validations
               │
               ├── jersey_awards ── stages
               │
               └── photos ── stages
```

---

## Tables

### `teams`

The five predefined cycling teams. Participants are assigned to teams via the admin page.

```sql
CREATE TABLE teams (
  id                INTEGER PRIMARY KEY,
  slug              TEXT NOT NULL UNIQUE,  -- 'mapei', 'rabobank', 'once', 'kelme', 'festina'
  name              TEXT NOT NULL UNIQUE,  -- 'Mapei', 'Rabobank', 'ONCE', 'Kelme', 'Festina'
  color_hex         TEXT NOT NULL,         -- Primary color for UI badges and fallback
  jersey_image_path TEXT NOT NULL,         -- Public path to jersey image, e.g. '/assets/maillots/mapei.png'
  created_at        TEXT NOT NULL DEFAULT (datetime('now'))
);
```

`jersey_image_path` is a static public path served by Astro from `public/assets/maillots/`.
It is used in classification rows, participant grids, the admin team assignment picker,
and any UI context showing which team a participant belongs to.

Seed data (colors are placeholders — final palette to be confirmed):

| id | slug | name | color_hex | jersey_image_path |
|----|------|------|-----------|------------------|
| 1 | mapei | Mapei | #8B3A8B | /assets/maillots/mapei.png |
| 2 | rabobank | Rabobank | #F5821E | /assets/maillots/rabobank.png |
| 3 | once | ONCE | #FFD700 | /assets/maillots/once.png |
| 4 | kelme | Kelme | #E30613 | /assets/maillots/kelme.png |
| 5 | festina | Festina | #1A3E8B | /assets/maillots/festina.png |

---

### Jersey assets — static UI configuration

Special competition jerseys (yellow, green, mountain/points) are **not stored in the `teams` table**.
They are static image paths referenced directly in UI components and configuration.

| Jersey | Public path | Source file |
|--------|-------------|-------------|
| Yellow (Maillot Amarillo) | `/assets/maillots/amarillo.png` | `reference/assets/maillots/amarillo.png` |
| Green (Maillot Verde) | `/assets/maillots/verde.png` | `reference/assets/maillots/verde.png` |
| Mountain/Points (Maillot de Puntos) | `/assets/maillots/puntos-rojo-balnco.png` | `reference/assets/maillots/puntos-rojo-balnco.png` |
| Iker / custom | `/assets/maillots/maillot-iker.png` | `reference/assets/maillots/maillot-iker.png` |

> **Filename note:** `puntos-rojo-balnco.png` appears to contain a typo ("balnco" instead of "blanco").
> The current filename is preserved exactly as-is. It may be renamed to `puntos-rojo-blanco.png`
> pending explicit approval. Until renamed, use the filename as it exists.

**Asset handling:** Files currently live in `reference/assets/maillots/`. Before the first deployment,
they must be copied to `public/assets/maillots/` so Astro can serve them as static files.
Do not rename or transform the files during this copy unless the typo rename is approved.

These paths are used in:
- Landing jersey overview cards
- `/clasificaciones` current jersey holders
- `/reglas` jersey rule sections (one image per jersey rule block)
- `/roadbook` visual sections (maillot-iker where relevant)

---

### `participants`

The 19 event participants. `team_id` is the team jersey assignment, set via the admin page.
It starts as NULL ("Sin equipo") and is assigned before or during the event.
The team classification is a separate derived ranking (see Derived data section).

```sql
CREATE TABLE participants (
  id         INTEGER PRIMARY KEY,
  nickname   TEXT NOT NULL UNIQUE,  -- Primary display name in public UI: 'Truebasson', 'Java', etc.
  first_name TEXT,                  -- Given name(s): nullable
  last_name  TEXT,                  -- Surname(s): nullable
  team_id    INTEGER REFERENCES teams(id),  -- NULL until assigned via admin
  is_active  INTEGER NOT NULL DEFAULT 1,    -- Set to 0 on abandonment or withdrawal
  created_at TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT    NOT NULL DEFAULT (datetime('now'))
);
```

Display convention:
- **Public UI** (classifications, pelotón grid): `nickname`
- **Admin UI** (scoring forms, team assignment): `nickname — first_name last_name`

`is_active = 0` means the participant has abandoned or withdrew. They remain in the database
for history but are excluded from live classifications. A participant with `team_id = NULL`
shows as "Sin equipo" and does not contribute to any team's total.

Seed data (19 participants, all unassigned, all active):

| id | nickname | first_name | last_name | team_id | is_active |
|----|----------|------------|-----------|---------|-----------|
| 1 | Truebasson | Eneko | Trueba | NULL | 1 |
| 2 | Java | Jagoba | Pereda | NULL | 1 |
| 3 | Ogor | Igor | Hinojosa | NULL | 1 |
| 4 | Motri | Asier | Motriko | NULL | 1 |
| 5 | Maka | Iñaki | Saez de Adana | NULL | 1 |
| 6 | Sopas | David Pelayo | Seoane | NULL | 1 |
| 7 | La Embarazada | Zaloa | Sanjurjo | NULL | 1 |
| 8 | Malware404 | Kamil Dariusz | Mazurkiewicz | NULL | 1 |
| 9 | Fiti | Ibai | Santisteban | NULL | 1 |
| 10 | Luchenko | Patiño Pelayo | Patiño | NULL | 1 |
| 11 | Hiru Gurutzeta | Uxue | Canibe | NULL | 1 |
| 12 | Gambo | Borja | Oliva | NULL | 1 |
| 13 | Bakana | Aritza | García | NULL | 1 |
| 14 | Tru | Unai | Albisua | NULL | 1 |
| 15 | Culiao | Fabio Ignacio | Cáceres | NULL | 1 |
| 16 | Fokro | Fikri | Arakraki | NULL | 1 |
| 17 | La Presi | Aintzane | García | NULL | 1 |
| 18 | Txete | Oier | Cerro | NULL | 1 |
| 19 | Osbal | Iker | Bravo | NULL | 1 |

> **Pending:** Team-to-participant assignments must be entered via the admin page before the event.

---

### `stages`

The two scoring stages and the ceremonial Sunday.

```sql
CREATE TABLE stages (
  id           INTEGER PRIMARY KEY,
  stage_number INTEGER NOT NULL,
  slug         TEXT NOT NULL UNIQUE,  -- 'etapa-1', 'etapa-2', 'bajada'
  name         TEXT NOT NULL,
  date         TEXT NOT NULL,         -- ISO date: '2026-06-05'
  route_from   TEXT NOT NULL,
  route_to     TEXT NOT NULL,
  is_scoring   INTEGER NOT NULL DEFAULT 1  -- 0 for Sunday (Bajada y Meta)
);
```

Seed data:

| id | stage_number | slug | name | date | route_from | route_to | is_scoring |
|----|-------------|------|------|------|------------|----------|------------|
| 1 | 1 | etapa-1 | Etapa 1 | 2026-06-05 | Llodio | Oviedo | 1 |
| 2 | 2 | etapa-2 | Etapa 2 | 2026-06-06 | Oviedo | Angliru | 1 |
| 3 | 3 | bajada | Bajada y meta | 2026-06-07 | Oviedo | TBD | 0 |

---

### `climbs`

The seven scoring mountain passes.

```sql
CREATE TABLE climbs (
  id             INTEGER PRIMARY KEY,
  stage_id       INTEGER NOT NULL REFERENCES stages(id),
  climb_number   INTEGER NOT NULL,  -- Within-stage position, 1-indexed, restarts per stage
  name           TEXT NOT NULL,
  nickname       TEXT,              -- Optional subtitle: 'La emboscada de Jonhy', etc.
  category       TEXT NOT NULL,     -- '3ª', '2ª', '1ª', 'HC'
  altitude_m     INTEGER,           -- Summit altitude in metres (NULL if unknown)
  scoring_type   TEXT NOT NULL      -- 'individual', 'team', 'accumulative', 'choice', 'manual'
);
```

`scoring_type = 'manual'` means rules are not yet defined; the admin enters points directly.

Seed data:

| id | stage_id | climb_number | name | nickname | category | altitude_m | scoring_type |
|----|----------|-------------|------|----------|----------|------------|--------------|
| 1 | 1 | 1 | Alto de Gardea | La emboscada de Jonhy | 3ª | 600 | individual |
| 2 | 1 | 2 | Alto del Avituallamiento | NULL | 2ª | 800 | team |
| 3 | 1 | 3 | Alto del Gato Negro | NULL | HC | 1400 | accumulative |
| 4 | 1 | 4 | Alto de Gascona | NULL | 1ª | 1000 | accumulative |
| 5 | 2 | 1 | Alto de Viapará | La salida del condenado | 2ª | NULL | manual |
| 6 | 2 | 2 | Alto del Angliru | La etapa reina de la vergüenza | HC | NULL | manual |
| 7 | 2 | 3 | Alto del Café Torero | NULL | 1ª | 1000 | manual |

---

### `score_events`

Configurable scoring moments. Every scorable moment in the event — climbs, arrival bonuses,
manual bonuses, and sanctions — is represented as a row here.

This replaces the previous `mountain_scores` and `arrival_results` tables.

```sql
CREATE TABLE score_events (
  id           INTEGER PRIMARY KEY,
  stage_id     INTEGER NOT NULL REFERENCES stages(id),
  climb_id     INTEGER REFERENCES climbs(id),  -- NULL for non-climb events
  event_type   TEXT NOT NULL,    -- 'climb', 'arrival_bonus', 'manual_bonus', 'sanction', 'other'
  name         TEXT NOT NULL,    -- Display name: 'Alto de Gardea', 'Llegada Etapa 1', etc.
  event_order  INTEGER NOT NULL, -- Sequence within the stage for display ordering
  is_active    INTEGER NOT NULL DEFAULT 1,  -- 0 to disable without deleting (e.g. unconfirmed Saturday arrival bonus)
  created_at   TEXT NOT NULL DEFAULT (datetime('now')),
  CHECK(event_type IN ('climb', 'arrival_bonus', 'manual_bonus', 'sanction', 'other'))
);
```

Seed data:

| id | stage_id | climb_id | event_type | name | event_order | is_active |
|----|----------|----------|------------|------|-------------|-----------|
| 1 | 1 | 1 | climb | Alto de Gardea | 1 | 1 |
| 2 | 1 | 2 | climb | Alto del Avituallamiento | 2 | 1 |
| 3 | 1 | 3 | climb | Alto del Gato Negro | 3 | 1 |
| 4 | 1 | 4 | climb | Alto de Gascona | 4 | 1 |
| 5 | 1 | NULL | arrival_bonus | Llegada / Repecho Etapa 1 | 5 | 1 |
| 6 | 2 | 5 | climb | Alto de Viapará | 1 | 1 |
| 7 | 2 | 6 | climb | Alto del Angliru | 2 | 1 |
| 8 | 2 | 7 | climb | Alto del Café Torero | 3 | 1 |
| 9 | 2 | NULL | arrival_bonus | Llegada Etapa 2 | 4 | 0 |

Row 9 (`is_active = 0`) represents the Saturday arrival bonus, which is **inactive for MVP**.
Only Friday (Stage 1) has the arrival/repecho bonus enabled. Do not activate row 9 without
an explicit decision to add a Saturday arrival bonus.

---

### `scores`

All points earned by each participant at each scoring moment.

Replaces the previous `mountain_scores` and `arrival_results` tables.
Handles climb points, arrival bonuses, manual bonuses, and sanctions in one place.

```sql
CREATE TABLE scores (
  id              INTEGER PRIMARY KEY,
  participant_id  INTEGER NOT NULL REFERENCES participants(id),
  score_event_id  INTEGER NOT NULL REFERENCES score_events(id),
  points          INTEGER NOT NULL DEFAULT 0,  -- Negative for sanctions
  position        INTEGER,   -- Finish position for arrival_bonus events (1 = first); NULL otherwise
  evidence_notes  TEXT,      -- What was consumed, photo evidence, car group, validation notes
  entered_by      TEXT,      -- Admin identifier (free text for MVP)
  created_at      TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at      TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(participant_id, score_event_id)
);
```

For `arrival_bonus` events, `position` stores the finish order and `points` stores the
bonus (1st→+5, 2nd→+4, 3rd→+3, 4th→+2, 5th→+1, 6th+→0).
For `sanction` events, `points` is negative.
For `manual_bonus` events (Saturday climbs with rules TBD), the admin enters `points` directly.
For the Alto del Avituallamiento team/car challenge, `evidence_notes` records the car group name
or reference. The admin selects participants per car and applies the same points to all of them.

---

### `green_vote_rounds`

One voting round per previous scoring day. Replaces `green_vote_events`.

Voting is next-day: participants evaluate the performance of the previous stage.
Sunday is not a scoring stage but can be used to close Round 2 voting.

```sql
CREATE TABLE green_vote_rounds (
  id                  INTEGER PRIMARY KEY,
  name                TEXT NOT NULL,         -- 'Etapa 1 — Viernes', 'Etapa 2 — Sábado'
  evaluates_stage_id  INTEGER NOT NULL REFERENCES stages(id),  -- Stage being evaluated
  voting_day          TEXT NOT NULL,         -- ISO date when voting happens
  round_order         INTEGER NOT NULL,
  created_at          TEXT NOT NULL DEFAULT (datetime('now'))
);
```

Seed data:

| id | name | evaluates_stage_id | voting_day | round_order |
|----|------|-------------------|------------|-------------|
| 1 | Etapa 1 — Viernes | 1 | 2026-06-06 | 1 |
| 2 | Etapa 2 — Sábado | 2 | 2026-06-07 | 2 |

Round 1 voting happens Saturday morning and determines the provisional green jersey.
Round 2 voting closes on Sunday and feeds the final green jersey.

---

### `green_votes`

Individual votes cast within a voting round.

```sql
CREATE TABLE green_votes (
  id            INTEGER PRIMARY KEY,
  round_id      INTEGER NOT NULL REFERENCES green_vote_rounds(id),
  voter_id      INTEGER NOT NULL REFERENCES participants(id),
  recipient_id  INTEGER NOT NULL REFERENCES participants(id),
  points        INTEGER NOT NULL,  -- One of: 5, 3, 1, -1
  created_at    TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(round_id, voter_id, points),  -- One vote per point tier per voter per round
  CHECK(voter_id != recipient_id),
  CHECK(points IN (5, 3, 1, -1))
);
```

Each voter casts exactly four votes per round: one +5, one +3, one +1, one -1,
each to a different participant.

---

### `yellow_jersey_validations`

Manual validation record for the yellow jersey. This is not a points classification —
it is a special award confirmed entirely by the organization.

```sql
CREATE TABLE yellow_jersey_validations (
  id                    INTEGER PRIMARY KEY,
  participant_id        INTEGER NOT NULL REFERENCES participants(id) UNIQUE,
  arrival_time          TEXT,    -- ISO datetime of Saturday morning hotel arrival
  selfie_received       INTEGER NOT NULL DEFAULT 0,  -- Selfie sent to WhatsApp group
  present_at_departure  INTEGER NOT NULL DEFAULT 0,  -- Present at Saturday departure time
  validated             INTEGER NOT NULL DEFAULT 0,  -- All conditions confirmed by org
  notes                 TEXT,
  created_at            TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at            TEXT NOT NULL DEFAULT (datetime('now'))
);
```

A participant with `present_at_departure = 0` is considered to have abandoned and their
`participants.is_active` should be set to 0.

The yellow jersey is awarded to the `validated = 1` participant with the latest `arrival_time`.

---

### `jersey_awards`

Jersey award records. Supports both provisional (after Stage 1) and final (after Stage 2) awards.

Note: the team jersey each participant wears is determined by `participants.team_id`
and is not recorded here. A `jersey_type = 'team'` row in this table records which
**team won the team classification**, not individual team jersey assignments.

```sql
CREATE TABLE jersey_awards (
  id              INTEGER PRIMARY KEY,
  jersey_type     TEXT NOT NULL,   -- 'yellow', 'green', 'mountain', 'team'
  award_scope     TEXT NOT NULL,   -- 'provisional', 'final'
  stage_id        INTEGER NOT NULL REFERENCES stages(id),  -- Points basis at time of award
  participant_id  INTEGER REFERENCES participants(id),     -- NULL for team classification winner
  team_id         INTEGER REFERENCES teams(id),            -- Only for jersey_type = 'team'
  notes           TEXT,
  awarded_at      TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(jersey_type, award_scope),
  CHECK(award_scope IN ('provisional', 'final')),
  CHECK(jersey_type IN ('yellow', 'green', 'mountain', 'team')),
  CHECK(
    (jersey_type = 'team' AND team_id IS NOT NULL AND participant_id IS NULL) OR
    (jersey_type != 'team' AND participant_id IS NOT NULL AND team_id IS NULL)
  )
);
```

The provisional mountain and green jerseys are awarded at Saturday 10:00 based on
Stage 1 results only. Final awards are made after Stage 2.

---

### `photos`

Gallery photos uploaded by participants during the event.

```sql
CREATE TABLE photos (
  id             INTEGER PRIMARY KEY,
  uploader_name  TEXT NOT NULL,                        -- Free text — no user accounts in MVP
  stage_id       INTEGER REFERENCES stages(id),        -- Optional day tag; NULL = general
  r2_key         TEXT NOT NULL UNIQUE,                 -- Full R2 object path
  caption        TEXT,
  uploaded_at    TEXT NOT NULL DEFAULT (datetime('now'))
);
```

`r2_key` example: `photos/2026-06-05/abc123.webp`.
No moderation in MVP. No thumbnail generation in MVP.

---

### `admin_sessions`

Simple shared-code sessions for `/puntuaciones`.

```sql
CREATE TABLE admin_sessions (
  id          INTEGER PRIMARY KEY,
  token_hash  TEXT NOT NULL UNIQUE,  -- SHA-256 of the session token
  created_at  TEXT NOT NULL DEFAULT (datetime('now')),
  expires_at  TEXT NOT NULL          -- ISO datetime
);
```

The shared code is stored as the `ADMIN_CODE` environment variable. On successful entry,
the server creates a session token, stores its hash here, and returns the token as an
HTTP-only cookie.

---

## Derived data (not stored — calculated at query time)

### Mountain/points jersey — overall total

Sums all score types for active participants. All `event_type` values except `other`
count toward the mountain jersey total. Inactive participants are excluded.

```sql
SELECT
  p.id,
  p.name,
  t.slug AS team_slug,
  t.name AS team_name,  -- NULL if participant has no team assigned
  COALESCE(SUM(s.points), 0) AS total_points
FROM participants p
LEFT JOIN teams t ON t.id = p.team_id
LEFT JOIN scores s ON s.participant_id = p.id
LEFT JOIN score_events se ON se.id = s.score_event_id
  AND se.event_type IN ('climb', 'arrival_bonus', 'manual_bonus', 'sanction')
  AND se.is_active = 1
WHERE p.is_active = 1
GROUP BY p.id
ORDER BY total_points DESC;
```

### Mountain/points jersey — single stage

```sql
SELECT
  p.id,
  p.name,
  COALESCE(SUM(s.points), 0) AS stage_points
FROM participants p
LEFT JOIN scores s ON s.participant_id = p.id
LEFT JOIN score_events se ON se.id = s.score_event_id
  AND se.stage_id = ?        -- bind: target stage_id
  AND se.is_active = 1
WHERE p.is_active = 1
GROUP BY p.id
ORDER BY stage_points DESC;
```

### Green jersey total

```sql
SELECT
  p.id,
  p.name,
  COALESCE(SUM(gv.points), 0) AS total_votes
FROM participants p
LEFT JOIN green_votes gv ON gv.recipient_id = p.id
WHERE p.is_active = 1
GROUP BY p.id
ORDER BY total_votes DESC;
```

### Team classification

Sums mountain/points scores across all active members of each team.
Arrival bonus points count toward team totals. Participants with `team_id = NULL` are excluded.

```sql
SELECT
  t.id,
  t.slug,
  t.name,
  COALESCE(SUM(s.points), 0) AS total_points
FROM teams t
JOIN participants p ON p.team_id = t.id AND p.is_active = 1
LEFT JOIN scores s ON s.participant_id = p.id
LEFT JOIN score_events se ON se.id = s.score_event_id
  AND se.event_type IN ('climb', 'arrival_bonus', 'manual_bonus', 'sanction')
  AND se.is_active = 1
GROUP BY t.id
ORDER BY total_points DESC;
```

---

## Notes

- Migration files belong in `src/server/db/migrations/`. None are defined in this doc.
- All timestamps are UTC ISO 8601. No `DATETIME` type — use `TEXT`.
- `score_events` rows with `is_active = 0` exist in the database but contribute no scores
  to any classification. Row 9 (Saturday arrival bonus) is inactive for MVP.
- `scoring_type = 'manual'` on a climb means the admin enters a free point value on
  `/puntuaciones` with no structured rule enforcement.
- `scoring_type = 'accumulative'` on Gascona: both options (soft +3, hard +8) can be scored
  once each per participant, for a maximum of +11.
- `participants.team_id` starts as NULL ("Sin equipo"). The admin assigns teams before the event.
  Participants with NULL `team_id` are excluded from team classification totals.
- `jersey_awards` with `jersey_type = 'team'` records the team classification winner.
  Individual team jersey assignment is stored in `participants.team_id`, not in `jersey_awards`.
- Green jersey tie-breaks are resolved via manual override in the `jersey_awards.notes` field
  and by admin confirmation on `/puntuaciones`.

---

## Open questions

1. **Team-to-participant assignments** — all 18 start unassigned. Must be entered via the
   admin page before the event begins.
2. **Saturday climb scoring rules** — rules for Viapará, Angliru, and Café Torero are not
   yet defined. Admin uses manual point entry (`scoring_type = 'manual'`) until confirmed.
