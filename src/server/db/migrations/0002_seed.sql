-- 0002_seed.sql
-- Reference data: teams, participants (19), stages, climbs, score_events, green_vote_rounds.

-- teams
INSERT INTO teams (id, slug, name, color_hex, jersey_image_path) VALUES
  (1, 'mapei',    'Mapei',    '#8B3A8B', '/assets/maillots/mapei.png'),
  (2, 'rabobank', 'Rabobank', '#F5821E', '/assets/maillots/rabobank.png'),
  (3, 'once',     'ONCE',     '#FFD700', '/assets/maillots/once.png'),
  (4, 'kelme',    'Kelme',    '#E30613', '/assets/maillots/kelme.png'),
  (5, 'festina',  'Festina',  '#1A3E8B', '/assets/maillots/festina.png');

-- participants (19, team_id NULL until assigned, all active)
-- display as: nickname in public UI; "nickname — first_name last_name" in admin UI
INSERT INTO participants (id, nickname, first_name, last_name, team_id, is_active) VALUES
  (1,  'Truebasson',     'Eneko',         'Trueba',          NULL, 1),
  (2,  'Java',           'Jagoba',        'Pereda',          NULL, 1),
  (3,  'Ogor',           'Igor',          'Hinojosa',        NULL, 1),
  (4,  'Motri',          'Asier',         'Motriko',         NULL, 1),
  (5,  'Maka',           'Iñaki',         'Saez de Adana',   NULL, 1),
  (6,  'Sopas',          'David Pelayo',  'Seoane',          NULL, 1),
  (7,  'La Embarazada',  'Zaloa',         'Sanjurjo',        NULL, 1),
  (8,  'Malware404',     'Kamil Dariusz', 'Mazurkiewicz',    NULL, 1),
  (9,  'Fiti',           'Ibai',          'Santisteban',     NULL, 1),
  (10, 'Luchenko',       'Patiño Pelayo', 'Patiño',          NULL, 1),
  (11, 'Hiru Gurutzeta', 'Uxue',          'Canibe',          NULL, 1),
  (12, 'Gambo',          'Borja',         'Oliva',           NULL, 1),
  (13, 'Bakana',         'Aritza',        'García',          NULL, 1),
  (14, 'Tru',            'Unai',          'Albisua',         NULL, 1),
  (15, 'Culiao',         'Fabio Ignacio', 'Cáceres',         NULL, 1),
  (16, 'Fokro',          'Fikri',         'Arakraki',        NULL, 1),
  (17, 'La Presi',       'Aintzane',      'García',          NULL, 1),
  (18, 'Txete',          'Oier',          'Cerro',           NULL, 1),
  (19, 'Osbal',          'Iker',          'Bravo',           NULL, 1);

-- stages
INSERT INTO stages (id, stage_number, slug, name, date, route_from, route_to, is_scoring, type) VALUES
  (1, 1, 'etapa-1', 'Etapa 1',      '2026-06-05', 'Llodio', 'Oviedo',  1, 'stage'),
  (2, 2, 'etapa-2', 'Etapa 2',      '2026-06-06', 'Oviedo', 'Angliru', 1, 'mountain_stage'),
  (3, 3, 'bajada',  'Bajada y meta','2026-06-07', 'Oviedo', 'TBD',     0, 'ceremonial');

-- climbs
INSERT INTO climbs (id, stage_id, climb_number, name, nickname, category, altitude_m, scoring_type) VALUES
  (1, 1, 1, 'Alto de Gardea',           'La emboscada de Jonhy',          '3ª', 600,  'individual'),
  (2, 1, 2, 'Alto del Avituallamiento', NULL,                             '2ª', 800,  'team'),
  (3, 1, 3, 'Alto del Gato Negro',      NULL,                             'HC', 1400, 'accumulative'),
  (4, 1, 4, 'Alto de Gascona',          NULL,                             '1ª', 1000, 'accumulative'),
  (5, 2, 1, 'Alto de Viapará',          'La salida del condenado',        '2ª', NULL, 'manual'),
  (6, 2, 2, 'Alto del Angliru',         'La etapa reina de la vergüenza', 'HC', NULL, 'manual'),
  (7, 2, 3, 'Alto del Café Torero',     NULL,                             '1ª', 1000, 'manual');

-- score_events (9 total; row 9 Saturday arrival is_active=0 for MVP)
INSERT INTO score_events (id, stage_id, climb_id, event_type, name, event_order, is_active) VALUES
  (1, 1, 1,    'climb',         'Alto de Gardea',           1, 1),
  (2, 1, 2,    'climb',         'Alto del Avituallamiento', 2, 1),
  (3, 1, 3,    'climb',         'Alto del Gato Negro',      3, 1),
  (4, 1, 4,    'climb',         'Alto de Gascona',          4, 1),
  (5, 1, NULL, 'arrival_bonus', 'Llegada / Repecho Etapa 1',5, 1),
  (6, 2, 5,    'climb',         'Alto de Viapará',          1, 1),
  (7, 2, 6,    'climb',         'Alto del Angliru',         2, 1),
  (8, 2, 7,    'climb',         'Alto del Café Torero',     3, 1),
  (9, 2, NULL, 'arrival_bonus', 'Llegada Etapa 2',          4, 0);

-- green_vote_rounds (2 rounds)
-- Round 1: Saturday morning, evaluates Friday
-- Round 2: Sunday, evaluates Saturday
INSERT INTO green_vote_rounds (id, name, evaluates_stage_id, voting_day, round_order) VALUES
  (1, 'Etapa 1 — Viernes', 1, '2026-06-06', 1),
  (2, 'Etapa 2 — Sábado',  2, '2026-06-07', 2);
