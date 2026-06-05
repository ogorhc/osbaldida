# Osbaldida 2026 — Project Brief

## Objective

Build a mobile-first web app for Osbaldida 2026, a cycling-themed bachelor party event.

The app will manage:

- event landing page
- general and stage classifications
- scoring forms
- rules
- roadbook / planning
- photo upload and gallery

## Technology

- Astro
- React
- TypeScript
- Tailwind CSS
- Cloudflare Workers
- Cloudflare D1
- Cloudflare R2

## Design direction

The visual style should be inspired by:

- Tour de France classification pages
- mobile-first race dashboards
- clean ranking tables
- yellow / black / white cycling visual language
- the provided Webflow HTML/CSS/JS template as visual reference only

The Webflow template must not be migrated directly.

## Event structure

There are two scoring stages:

### Friday — Stage 1: Llodio → Oviedo

Four scoring climbs:

1. Alto de Gardea — 3ª — 600 m
2. Alto del Avituallamiento — 2ª — 800 m
3. Alto del Gato Negro — HC — 1400 m
4. Alto de Gascona — 1ª — 1000 m

### Saturday — Stage 2: Oviedo → Viapará → Angliru

Three scoring climbs:

1. Alto de Viapará — 2ª
2. Alto del Angliru — HC
3. Alto del Café Torero — 1ª — 1000 m

### Sunday — Bajada y meta

Sunday is not a scoring stage.

It is a controlled finish, like the final stage into Paris:

- no points
- no attacks
- symbolic closure
- checkout before 12:00
- possible lunch on the way back

## Pages

The app must have six pages:

1. Landing
2. Classifications
3. Scoring
4. Rules
5. Roadbook
6. Gallery

## Important rule

Before implementing code, Claude must create and review documentation first.