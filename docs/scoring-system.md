# Scoring System — Osbaldida 2026

Extracted from `reference/scoring/Puntuacion.xlsx` and `CLAUDE.md`.

---

## Overview

There are three active scoring systems running in parallel:

| Classification | System | Scored when |
|---------------|--------|-------------|
| Mountain/Points jersey | Drink-based points at each scoring climb | During each stage |
| Arrival/repecho bonus | Finish order at the end of confirmed scoring stages | Confirmed: Friday only for MVP |
| Green jersey | Social/party performance voting | Next-day voting (per previous scoring day) |

The Yellow jersey is a special manually validated award, not a points classification.
The Team jersey is assigned via the admin page. Team classification is derived from points.

---

## Jersey award timing

Jersey awards happen at two distinct moments:

### Provisional awards — Saturday 10:00

Jerseys awarded at the Saturday morning departure are based on **Friday results only**:
- Mountain/Points jersey leader after Stage 1
- Green jersey leader after the Saturday morning vote (evaluating Friday performance)
- Yellow jersey (Saturday morning hotel arrival — see below)
- Team classification leader after Stage 1

These are provisional. The final classification may differ once Saturday scores are added.

### Final awards — after Stage 2

The final mountain/points and team classifications include all accumulated points from
both Stage 1 and Stage 2.

The green jersey final award is based on all completed voting rounds.

Sunday (Bajada y Meta) does not score and does not trigger a new voting round.
It is used only for final validation and Round 2 voting closure.

---

## Jersey 1 — Yellow jersey (Maillot Amarillo)

The yellow jersey is a **special manually validated award**. It is not a points classification
and does not feed into any ranking table.

### Rule

Awarded to the participant who arrives **latest** at the hotel on Saturday morning.

### Conditions to qualify

All three conditions must be met:
1. The participant must send a **selfie to the WhatsApp group** on arrival.
2. The participant must be **present at the Saturday departure time**.
3. Arriving late scores. Missing the Saturday departure entirely counts as **abandonment** and disqualifies.

### Tie-break

Resolved by the admin using the exact WhatsApp selfie timestamp.

### Validation

Manual. The organization validates the selfie and presence at departure.
The award is confirmed or denied by the admin on `/puntuaciones` — it is not auto-calculated.

---

## Jersey 2 — Green jersey (Maillot Verde)

### Rule

Awarded to the participant with the highest accumulated vote score across all completed voting rounds.

The green jersey is determined by **collective voting by all participants**.
Voting is **next-day**: each round evaluates the performance of the previous scoring day.

### Voting schedule

| Voting round | When | Evaluates |
|-------------|------|-----------|
| Round 1 | Saturday morning | Friday (Stage 1) performance |
| Round 2 | Sunday | Saturday (Stage 2) performance |

Sunday is not a scoring stage, but is used for Round 2 voting closure.

### What is voted on

Each voting round evaluates **social and party performance** during that day:
- Most drunk
- Most regular in the party
- Most socially dominant
- Biggest survivor

### Points per voting round

| Rank | Points |
|------|--------|
| Best performance | +5 |
| Second best performance | +3 |
| Third best performance | +1 |
| Failure | -1 |

Each voter awards exactly one +5, one +3, one +1, and one -1 per round
(one per tier, to different participants). Voting for yourself is not allowed.

The green jersey total is the sum of all votes received across all completed rounds.

### Provisional green jersey (Saturday 10:00)

The green jersey worn at Saturday's departure is based on Round 1 only (Friday performance votes).

### Tie-break

Tie-break is a **manual organizer decision**. The app allows manual override when confirming
any jersey award.

Suggested criteria:
- **Provisional green jersey (Saturday 10:00):** latest valid hotel arrival on Saturday morning
  (same moment being tracked for the yellow jersey).
- **Final green jersey:** organizer's discretion based on overall event context.

### Validation

Votes are entered by the admin on `/puntuaciones`. No self-service voting in MVP.

---

## Jersey 3 — Mountain/Points jersey (Maillot de Puntos)

### Rule

Awarded to the participant with the highest total accumulated points from all completed scoring events.

Points from all climbs and arrival bonuses are **additive** across both stages. Sunday does not score.

### Arrival/repecho bonus

The arrival bonus is a configurable scoring moment, enabled per stage.

**Confirmed for Friday (Stage 1):** includes a final arrival/repecho bonus for the top finishers.

| Position | Points |
|----------|--------|
| 1st | +5 |
| 2nd | +4 |
| 3rd | +3 |
| 4th | +2 |
| 5th | +1 |

**Saturday (Stage 2):** arrival bonus is **inactive for MVP**. Saturday points come only from
the three scoring climbs and any manually entered score events.

### What counts toward the mountain/points total

All active scoring events contribute to the individual mountain/points classification:
- Climb points (all stages)
- Arrival/repecho bonus (Friday confirmed; Saturday inactive)
- Manual bonuses (if entered by admin)
- Sanctions (negative, if applied)

---

## Stage 1 — Friday scoring climbs

### Puerto 1 — Alto de Gardea (3ª, 600 m)

**Nickname:** La emboscada de Jonhy

#### Scoring rules

| Condition | Points |
|-----------|--------|
| 2 or more beers or wines consumed | +2 |
| 1 beer or wine consumed | +1 |
| 0 | 0 |

**Evidence requirement:** The participant must show what they consumed to the organization.

---

### Puerto 2 — Alto del Avituallamiento (2ª, 800 m)

#### Scoring rules — team/car effort

This is a **car-based team challenge**. Each car receives 3 cans of beer per person.
All members of the same car receive the same score.

| Condition | Points per person |
|-----------|-------------------|
| 100% of the car's cans consumed | +8 |
| 75% of the car's cans consumed | +3 |
| 50% of the car's cans consumed | +1 |
| Less than 50% | 0 |

**Evidence requirement:** A group photo with the crushed cans, taken **before reaching Oviedo**.

**Car group assignment:** Car groups are defined ad-hoc on the day. The admin selects
the participants in each car, selects the completion percentage, and the app applies
the same points to all selected participants. No dedicated car_groups table is required.
The car name or photo reference is stored in the evidence notes.

---

### Puerto 3 — Alto del Gato Negro (HC, 1400 m)

#### Scoring rules — accumulative

Points accumulate. A participant can earn from multiple options.

| What was consumed | Points |
|-------------------|--------|
| 1 soft shot (piruleta or similar) | +1 per shot |
| 3 glasses of cider | +1 per 3 glasses |
| 1 hard shot of orujo (max 1) | +2 |
| 1 full glass of wine or beer "de trago" (max 2) | +3 per glass |

**Rules:**
- Only full glasses count. Half glasses do not score.
- Maximum 1 orujo shot.
- Maximum 2 full glasses of wine or beer.
- The organization assigns validators to count each drink.

**Example:** 2 full glasses of wine + 1 orujo shot + 1 piruleta = +3 + +3 + +2 + +1 = **9 points**.

---

### Puerto 4 — Alto de Gascona (1ª, 1000 m)

#### Scoring rules — accumulative, limited

Both options can be scored. Each option can only be scored **once per participant**.

| What was consumed | Points |
|-------------------|--------|
| 1 soft shot (piruleta or similar) | +3 |
| 1 hard shot (Jagger/Jägermeister) | +8 |

A participant who completes both scores **+11**. Each option is capped at one per participant.

---

## Stage 2 — Saturday scoring climbs

Saturday climb scoring rules are **not yet defined**. The MVP admin form for Stage 2
supports **manual point entry per participant per climb** until rules are confirmed.

Do not mirror or assume Friday climb rules for Saturday climbs.

### Puerto 1 — Alto de Viapará (2ª)

**Nickname:** La salida del condenado

> Scoring rules pending. Admin enters points manually.

---

### Puerto 2 — Alto del Angliru (HC)

**Nickname:** La etapa reina de la vergüenza

> Scoring rules pending. Admin enters points manually.

---

### Puerto 3 — Alto del Café Torero (1ª, 1000 m)

> Scoring rules pending. Admin enters points manually.

---

## Jersey 4 — Team jersey (Maillot de Equipos)

### Team jersey assignment

Each participant is assigned to one of the five teams via the admin page.
Until assigned, a participant is shown as "Sin equipo" and does not contribute to any team total.

Teams:
- Mapei
- Rabobank
- ONCE
- Kelme
- Festina

The team jersey a participant wears is determined by their assignment. It does not change
based on performance and is distinct from the team classification.

### Team classification

The app calculates a **team classification**: the team whose active members accumulate
the highest total points wins.

Points counted toward the team classification:
- Climb points (all active scoring events)
- Arrival/repecho bonus points
- Manual bonus points
- Sanctions (negative)

This matches the individual mountain/points classification scope. All active scoring events
count for both individual and team totals.

---

## Participants

18 participants (from the Excel voting tables):

Trueba, Java, Igor, Motri, Maka, David, Zaloa, Kamil, Fiti, Patiño, Uxue, Gambo,
Bakana, Tru, Fabio, Fikri, Aintzane, Txete.

---

## Summary — Stage 1 Friday scoring

| Moment | Max points (individual) |
|--------|------------------------|
| Alto de Gardea (3ª) | +2 |
| Alto del Avituallamiento (2ª) | +8 |
| Alto del Gato Negro (HC) | up to ~9 (accumulative) |
| Alto de Gascona (1ª) | +11 (both options: +3 + +8) |
| Arrival/repecho bonus | +5 |

---

## Open questions

1. **Saturday climb scoring rules** — not in reference files. Admin uses manual point entry
   until the organizer provides the rules for Viapará, Angliru, and Café Torero.
2. **Team-to-participant assignments** — all 18 are unassigned. The organizer must assign
   each participant to a team via the admin page before the event.
