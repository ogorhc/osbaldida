-- 0001_initial_schema.sql
-- All 12 tables for Osbaldida 2026.
-- Foreign key enforcement must be enabled in application code: PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS teams (
  id                INTEGER PRIMARY KEY,
  slug              TEXT    NOT NULL UNIQUE,
  name              TEXT    NOT NULL UNIQUE,
  color_hex         TEXT,
  jersey_image_path TEXT    NOT NULL,
  created_at        TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at        TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS participants (
  id         INTEGER PRIMARY KEY,
  nickname   TEXT    NOT NULL UNIQUE,  -- primary display name in public UI
  first_name TEXT,
  last_name  TEXT,
  team_id    INTEGER REFERENCES teams(id),
  is_active  INTEGER NOT NULL DEFAULT 1,
  created_at TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS stages (
  id           INTEGER PRIMARY KEY,
  stage_number INTEGER NOT NULL,
  slug         TEXT    NOT NULL UNIQUE,
  name         TEXT    NOT NULL,
  date         TEXT    NOT NULL,
  route_from   TEXT    NOT NULL,
  route_to     TEXT    NOT NULL,
  is_scoring   INTEGER NOT NULL DEFAULT 1,
  type         TEXT    NOT NULL DEFAULT 'stage'
);

CREATE TABLE IF NOT EXISTS climbs (
  id           INTEGER PRIMARY KEY,
  stage_id     INTEGER NOT NULL REFERENCES stages(id),
  climb_number INTEGER NOT NULL,
  name         TEXT    NOT NULL,
  nickname     TEXT,
  category     TEXT    NOT NULL,
  altitude_m   INTEGER,
  scoring_type TEXT    NOT NULL,
  CHECK(scoring_type IN ('individual', 'team', 'accumulative', 'choice', 'manual'))
);

CREATE TABLE IF NOT EXISTS score_events (
  id            INTEGER PRIMARY KEY,
  stage_id      INTEGER NOT NULL REFERENCES stages(id),
  climb_id      INTEGER REFERENCES climbs(id),
  event_type    TEXT    NOT NULL,
  name          TEXT    NOT NULL,
  description   TEXT,
  points_config TEXT,
  event_order   INTEGER NOT NULL,
  is_active     INTEGER NOT NULL DEFAULT 1,
  created_at    TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at    TEXT    NOT NULL DEFAULT (datetime('now')),
  CHECK(event_type IN ('climb', 'arrival_bonus', 'manual_bonus', 'sanction', 'other'))
);

CREATE TABLE IF NOT EXISTS scores (
  id             INTEGER PRIMARY KEY,
  participant_id INTEGER NOT NULL REFERENCES participants(id),
  score_event_id INTEGER NOT NULL REFERENCES score_events(id),
  points         INTEGER NOT NULL DEFAULT 0,
  quantity       INTEGER,
  position       INTEGER,
  reason         TEXT,
  evidence_notes TEXT,
  entered_by     TEXT,
  created_at     TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at     TEXT    NOT NULL DEFAULT (datetime('now')),
  UNIQUE(participant_id, score_event_id)
);

CREATE TABLE IF NOT EXISTS green_vote_rounds (
  id                 INTEGER PRIMARY KEY,
  name               TEXT    NOT NULL,
  evaluates_stage_id INTEGER NOT NULL REFERENCES stages(id),
  voting_day         TEXT    NOT NULL,
  round_order        INTEGER NOT NULL,
  is_closed          INTEGER NOT NULL DEFAULT 0,
  created_at         TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS green_votes (
  id           INTEGER PRIMARY KEY,
  round_id     INTEGER NOT NULL REFERENCES green_vote_rounds(id),
  voter_id     INTEGER NOT NULL REFERENCES participants(id),
  recipient_id INTEGER NOT NULL REFERENCES participants(id),
  points       INTEGER NOT NULL,
  created_at   TEXT    NOT NULL DEFAULT (datetime('now')),
  UNIQUE(round_id, voter_id, points),
  CHECK(voter_id != recipient_id),
  CHECK(points IN (5, 3, 1, -1))
);

CREATE TABLE IF NOT EXISTS yellow_jersey_validations (
  id                   INTEGER PRIMARY KEY,
  participant_id       INTEGER NOT NULL REFERENCES participants(id) UNIQUE,
  arrival_time         TEXT,
  selfie_received      INTEGER NOT NULL DEFAULT 0,
  present_at_departure INTEGER NOT NULL DEFAULT 0,
  validated            INTEGER NOT NULL DEFAULT 0,
  notes                TEXT,
  created_at           TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at           TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS jersey_awards (
  id             INTEGER PRIMARY KEY,
  jersey_type    TEXT    NOT NULL,
  award_scope    TEXT    NOT NULL,
  stage_id       INTEGER NOT NULL REFERENCES stages(id),
  participant_id INTEGER REFERENCES participants(id),
  team_id        INTEGER REFERENCES teams(id),
  notes          TEXT,
  is_active      INTEGER NOT NULL DEFAULT 1,
  awarded_at     TEXT    NOT NULL DEFAULT (datetime('now')),
  UNIQUE(jersey_type, award_scope),
  CHECK(award_scope IN ('provisional', 'final')),
  CHECK(jersey_type IN ('yellow', 'green', 'mountain', 'team')),
  CHECK(
    (jersey_type = 'team' AND team_id IS NOT NULL AND participant_id IS NULL) OR
    (jersey_type != 'team' AND participant_id IS NOT NULL AND team_id IS NULL)
  )
);

CREATE TABLE IF NOT EXISTS photos (
  id            INTEGER PRIMARY KEY,
  uploader_name TEXT    NOT NULL,
  stage_id      INTEGER REFERENCES stages(id),
  r2_key        TEXT    NOT NULL UNIQUE,
  caption       TEXT,
  uploaded_at   TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS admin_sessions (
  id         INTEGER PRIMARY KEY,
  token_hash TEXT NOT NULL UNIQUE,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  expires_at TEXT NOT NULL
);
