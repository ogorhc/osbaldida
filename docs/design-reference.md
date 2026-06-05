# Design Reference — Osbaldida 2026

Visual decisions extracted from the Webflow template at `reference/webflow-template/`
and interpreted for the Osbaldida cycling context.

The Webflow template is used **only as a visual reference**. No Webflow HTML, class names,
or JavaScript is carried into the implementation. All UI is rebuilt using Astro + React + Tailwind CSS.

---

## Color palette

### Cycling identity (primary)

| Token | Hex | Usage |
|-------|-----|-------|
| `yellow` | `#FFBE00` | Yellow jersey, primary CTAs, top-3 row accent, active nav state |
| `black` | `#051408` | Text, hero backgrounds, bottom nav, dark section fills |
| `white` | `#FFFFFF` | Text on dark backgrounds, card backgrounds |
| `green` | `#93E360` | Green jersey accent, success states |

### UI neutrals (from Webflow template)

| Token | Hex | Usage |
|-------|-----|-------|
| `bg` | `#FCFBFB` | Page background (light sections) |
| `surface` | `#F5F3F3` | Card and input backgrounds, alternating rows |
| `stroke` | `#E5E3E3` | Borders, dividers |
| `grey-lite` | `#E5E5E5` | Subtle separators |
| `grey-soft` | `#EFEFEF` | Secondary backgrounds |
| `text-secondary` | `#313131` | Secondary text |
| `gray` | `#676F68` | Muted/placeholder text |

Additional Webflow tokens (available when needed):
- `orange`: `#F96E12` — warm accent for stage badges or warning states
- `green-ash`: `#2A570D` — dark green for green jersey card backgrounds
- `green-soft`: `#223D0D` — deeper dark green variant

### Contrast pairings

All body text must meet WCAG AA (4.5:1 minimum). Use this table to decide which pairings are safe.

| Background | Foreground | Approx. ratio | Safe for |
|-----------|-----------|--------------|---------|
| `#051408` black | `#FFFFFF` white | ~18:1 | Body text, headings, any size |
| `#051408` black | `#FFBE00` yellow | ~12:1 | Body text, headings, any size |
| `#FFFFFF` white | `#051408` black | ~18:1 | Body text, headings, any size |
| `#FFBE00` yellow | `#051408` black | ~12:1 | Body text, headings, any size |
| `#FCFBFB` bg | `#051408` black | ~18:1 | Body text |
| `#93E360` green | `#051408` black | ~13:1 | Body text, headings |
| `#FCFBFB` bg | `#676F68` gray | ~5:1 | Body text (WCAG AA) |
| `#FFFFFF` white | `#FFBE00` yellow | ~1.3:1 | ❌ Never for text — decoration only |
| `#FCFBFB` bg | `#FFBE00` yellow | ~1.3:1 | ❌ Never for text — decoration only |

**Rule:** Yellow text is only safe on black or near-black backgrounds. Yellow on white or `bg` fails contrast and must not be used for any text, including labels, captions, or badges.

### Jersey badge fallback colors

These colors are used only as fallbacks when jersey images fail to load.

| Jersey | Fallback color | Image asset |
|--------|---------------|-------------|
| Yellow (Amarillo) | `#FFBE00` | `/assets/maillots/amarillo.png` |
| Green (Verde) | `#93E360` | `/assets/maillots/verde.png` |
| Mountain/Points (Puntos) | `#EF4444` red | `/assets/maillots/puntos-rojo-balnco.png` |
| Team (Equipos) | Per-team `color_hex` | Per-team `/assets/maillots/<slug>.png` |

### Team jersey images

Team hex values are **pending confirmation from the organizer**. Do not build UI that depends on these values. Use the jersey image as the primary team identifier — not the hex color.

| Team | Hex (pending) | Jersey image |
|------|--------------|--------------|
| Mapei | TBD | `/assets/maillots/mapei.png` |
| Rabobank | TBD | `/assets/maillots/rabobank.png` |
| ONCE | TBD | `/assets/maillots/once.png` |
| Kelme | TBD | `/assets/maillots/kelme.png` |
| Festina | TBD | `/assets/maillots/festina.png` |

---

## Typography

### Font families

Both fonts are self-hosted from `reference/webflow-template/fonts/`. Do not load from Google Fonts.

| Role | Family | Weights | Usage |
|------|--------|---------|-------|
| Primary body | **Inter Tight** | 400, 500, 600, 700 | Body text, UI elements, labels, forms |
| Display/headings | **PT Sans Narrow** | 400, 700 | Stage names, hero titles, position numbers, classification headers |

### Type scale

Desktop sizes are extracted from the Webflow CSS variables. **Mobile sizes are approximated** — they are not present as distinct tokens in the Webflow CSS. Treat mobile sizes as implementation starting points; verify readability at 360px during development.

`text-default` is 16px at all sizes — this matches the Webflow source. Do not use 15px.

| Step | Desktop | Mobile (approx.) | Line height | Weight | Usage |
|------|---------|-----------------|-------------|--------|-------|
| `display-01` | 130px | 40px | 1.1em | 700 | Hero numbers, "1st place" display |
| `h1` | 96px | 36px | 1.1em | 700 | Page heroes |
| `h2` | 68px | 34px | 1.2em | 700 | Section titles |
| `h3` | 50px | 30px | 1.2em | 700 | Subsection titles, climb names |
| `h4` | 40px | 24px | 1.2em | 600 | Card headings |
| `h5` | 30px | 20px | 1.2em | 700 | Table headers, label-size titles |
| `h6` | 24px | 16px | 1.2em | 700 | Badges, small section heads |
| `text-xlarge` | 22px | 20px | 1.2em | 500 | Points display, jersey totals |
| `text-medium` | 18px | 16px | 1.4em | 500 | Primary body text |
| `text-default` | 16px | 16px | 1.4em | 500 | Standard paragraphs, form labels |
| `text-small` | 14px | 14px | 1.4em | 500 | Captions, timestamps, fine print only |

**Minimum body text on mobile: 16px.** Do not use `text-small` (14px) for any interactive label, form element, or primary information. Use it only for secondary meta.

### Letter spacing

| Name | Value | Use for |
|------|-------|---------|
| `tracking-extra-large` | `-0.05em` | H1, H2 (matches Webflow source) |
| `tracking-large` | `-0.04em` | H3, H4 |
| `tracking-medium` | `-0.03em` | Display numbers |
| `tracking-default` | `-0.02em` | H5, H6 |
| `tracking-normal` | `0em` | Body, buttons, tags |

---

## Spacing scale

Derived from Webflow CSS spacing tokens.

| Token | px | Tailwind equiv |
|-------|----|----------------|
| `space-xl` | 4px | `p-1` |
| `space-2xl` | 8px | `p-2` |
| `space-3xl` | 10px | `p-2.5` |
| `space-4xl` | 12px | `p-3` |
| `space-5xl` | 14px | `p-3.5` |
| `space-6xl` | 16px | `p-4` |
| `space-7xl` | 18px | `p-[18px]` |
| `space-8xl` | 20px | `p-5` |
| `space-9xl` | 22px | `p-[22px]` |
| `space-10xl` | 24px | `p-6` |
| `space-11xl` | 26px | `p-[26px]` |
| `space-13xl` | 32px | `p-8` |
| `space-15xl` | 36px | `p-9` |
| `space-16xl` | 40px | `p-10` |
| `space-17xl` | 48px | `p-12` |
| `space-18xl` | 50px | `p-[50px]` |
| `space-19xl` | 60px | `p-[60px]` |
| `space-21xl` | 80px | `p-20` |
| `space-23xl` | 100px | `p-[100px]` |

Mobile section padding: 40px. Desktop: 80–120px.
Card internal padding: 20–24px on mobile, 24–32px on desktop.

---

## Border radius scale

| Name | px | Usage |
|------|----|-------|
| `radius-xl` | 4px | Small UI elements |
| `radius-2xl` | 6px | Buttons, tags, chips |
| `radius-3xl` | 8px | Small cards, inputs |
| `radius-4xl` | 10px | Cards |
| `radius-5xl` | 12px | Cards |
| `radius-6xl` | 14px | Large cards |
| `radius-7xl` | 16px | Large cards, drawers |
| `radius-8xl` | 18px | Panels |
| `radius-9xl` | 20px | Elevated panels |
| `radius-10xl` | 24px | Modal containers |
| `radius-11xl` | 32px | Large modals |
| `radius-12xl` | 40px | Pill buttons (primary CTA) |
| `radius-round` | 50% | Circular badges, avatar circles |

---

## Shadow and elevation scale

Derived from Webflow CSS. Use sparingly — the visual identity is flat and high-contrast.
On dark-background sections (hero, bottom nav), shadows are not needed; use borders or background contrast instead.

| Name | CSS value | Usage |
|------|-----------|-------|
| `shadow-card` | `0 12px 20px rgba(0,0,0,0.04)` | Default card on light backgrounds |
| `shadow-card-elevated` | `0 20px 50px rgba(0,0,0,0.10)` | Selected/hover card, top-1 classification row |
| `shadow-sticky` | `0 5px 25px rgba(0,0,0,0.25)` | Sticky bottom nav, sticky headers |
| `shadow-modal` | `0 16px 80px rgba(0,0,0,0.06)` | Drawers, modal overlays |
| `shadow-fab` | `0 0 28px rgba(0,0,0,0.10)` | Floating action buttons |

---

## Buttons

### Primary button

- Background: `yellow` (`#FFBE00`)
- Text: `black` (`#051408`)
- Border radius: pill (`radius-12xl`, 40px)
- Padding: `18px 24px` desktop, `14px 20px` mobile
- Font: Inter Tight, 16px, weight 600
- Active/pressed: `scale(0.97)`, background slightly dims
- Transition: `all 0.2s ease`

### Secondary / outline button

- Background: transparent
- Text: `black`
- Border: 1.5px solid `stroke` (`#E5E3E3`)
- Same radius as primary
- Active: background becomes `surface`

### Icon button (navigation, small actions)

- Circular shape, 44×44px minimum
- Background: transparent or `surface`
- Must have `aria-label`

---

## Cards

### Classification card (mobile)

Used in all ranking tabs on `/clasificaciones`. Full width. Compact and scannable.

```
┌──────────────────────────────────────────┐
│ #1  Trueba   [jersey img 28px]   42 pts  │
│ #2  Java     [jersey img 28px]   38 pts  │
│ #3  Igor     [jersey img 28px]   35 pts  │
└──────────────────────────────────────────┘
```

Layout:
- Position: 36px wide, bold PT Sans Narrow, large (28–32px)
- Name: flex-grow, 16px Inter Tight, ellipsis if needed
- Team badge: 28×28px `<img>` from `teams.jersey_image_path`; `object-fit: contain`; fallback to color dot on error
- Points: 48px wide, right-aligned, bold

Top-3 treatment:
- `#1`: 4px left border in `yellow`, `shadow-card-elevated`
- `#2`: 4px left border in `#C0C0C0` (silver)
- `#3`: 4px left border in `#CD7F32` (bronze)
- `#4+`: no accent border

Row height: 52–56px. Background: `white` alternating with `surface`.
Use cards (`<div>`), not `<table>`, on mobile.

### Stage card

Used on the landing page and roadbook. Full width on mobile.

```
┌──────────────────────────────────────────────┐
│ [Stage image — 160px tall, object-fit:cover] │
│  ETAPA 1 — VIERNES    5 Jun 2026             │
├──────────────────────────────────────────────┤
│ Llodio → Oviedo               [Puntuable]    │
│ ─────────────────────────────────────────    │
│ [Gardea] [Avituallamiento] [Gato Negro] ...  │
│                               [Ver etapa →]  │
└──────────────────────────────────────────────┘
```

Fields:
- **Stage image banner:** `object-fit: cover`, `height: 160px` mobile, full width.
  Gradient overlay: `linear-gradient(to bottom, rgba(5,20,8,0.3), rgba(5,20,8,0.65))`
  Overlay text: PT Sans Narrow bold white — stage number + day + date.
- **Route:** 16px Inter Tight bold (e.g. "Llodio → Oviedo")
- **Date:** 14px muted
- **Scoring status:** pill badge — "Puntuable" (yellow bg, black text) or "Ceremonial" (gray)
- **Climb chips:** small pill chips per climb name
- **CTA:** "Ver etapa →" text link to the roadbook stage section

Mobile: full-width card, stacked vertically. No side-by-side layout at 360px.

Available stage images (in `reference/assets/`):
- `etapa_viernes.webp` — Stage 1
- `etapa_sabado.webp` — Stage 2
- `Alto-del-Angliru-Ciclismo-Epico-1024x865.webp` — Angliru summit reference

### Climb card

Used in roadbook and rules pages.

```
┌──────────────────────────────────────────┐
│ [HC]  Puerto 3 — Alto del Gato Negro     │
│       ↑ 1400 m  ·  max ~9 pts           │
│       La cena de equipo                  │
└──────────────────────────────────────────┘
```

- Background: `black` on light-page sections, or `surface` in lighter context
- Border radius: `radius-6xl` (14px)
- Category badge pill: colored by category

Category badge colors:
- `HC` — `#051408` background, white text
- `1ª` — `#B91C1C` dark red
- `2ª` — `#1D4ED8` dark blue
- `3ª` — `#15803D` dark green

### Jersey card

Used on the landing page and jersey overview.

```
┌──────────────────────────────────────┐
│ [Jersey image — max-height 80px,     │
│  centered on jersey color background]│
├──────────────────────────────────────┤
│ Maillot Amarillo                     │
│ Java                                 │
│ Para quien llegue más tarde...       │
└──────────────────────────────────────┘
```

- Top block: `color_hex` background + jersey `<img>` centered, `max-height: 80px`, `object-fit: contain`, padded
- Image source: static path from jersey assets config (e.g. `/assets/maillots/amarillo.png`)
- Fallback: if image fails, show color block with jersey icon glyph
- White text on the colored top block; black text on white card body

### Photo card (gallery)

- Aspect ratio: maintained, not forced square
- Rounded corners: `radius-5xl` (12px)
- Caption below on expand

---

## Navigation

### Mobile — sticky bottom bar (final decision)

Five tabs. This is the resolved structure. Do not add a sixth tab.

| Tab | Route | Icon |
|-----|-------|------|
| Inicio | `/` | Home |
| Clasificación | `/clasificaciones` | Trophy/ranking |
| Puntuar | `/puntuaciones` | Pencil (lock when not authenticated) |
| Roadbook | `/roadbook` | Map |
| Galería | `/galeria` | Camera |

Specs:
- `position: fixed; bottom: 0; width: 100%`
- `padding-bottom: env(safe-area-inset-bottom)` — required for iPhone home bar
- Height: 56px + safe area
- Background: `#051408`
- Active: yellow icon + yellow label
- Inactive: white icon + white label, `opacity: 0.6`
- Label font: **11px**, Inter Tight, weight 500
- Icon size: 24px
- Minimum tab width: 64px (5 × 64px = 320px fits within 360px)

**`/reglas` secondary access:** not in the bottom nav. Link from:
- Landing page quick links section
- Roadbook page "Ver reglas" link
- Desktop top navbar

### Desktop — horizontal top bar

- Transparent on scroll-top, black background on scroll
- Logo left, links center-right (including Reglas), CTA button right

---

## Section composition

### Hero section

- Full-width dark background (`#051408` or stage image with dark overlay)
- Centered text: eyebrow pill tag + H1 + description + CTA buttons
- Stage image overlay: `linear-gradient(to bottom, rgba(5,20,8,0.35), rgba(5,20,8,0.7))`
- Mobile: 40px padding, smaller type

### Feature/card grid

- 1 column on mobile
- 2–3 columns on desktop
- Gap: 16–20px mobile, 24–32px desktop

### Data table (classification)

- Full-width on mobile
- No horizontal scroll — all columns within 360px
- Sticky header row: `background: black`, white text
- Alternating rows: `white` / `surface`
- Position column: 36px, bold PT Sans Narrow

### Section divider

- 1px solid `stroke` (#E5E3E3)
- or full-bleed background change (white → black, or black → white)

---

## Race visual language

Inspired by Tour de France classification boards, cycling broadcast UI, and race dashboards.

### Dark hero sections

Key entry points use dark (`#051408`) with yellow and white text:
- Page heroes and stage banners
- Classification section headers (sticky row)
- Bottom navigation bar
- Score callout areas

Light (`bg`, `surface`) backgrounds are used for the body of classification lists and general content.

### Position number treatment

Position numbers are the dominant visual element in classification rows.

- Font: PT Sans Narrow, bold
- Size: 28–32px on mobile
- Color: `black` on light rows, `white` on dark rows
- Top-3 left border accents: yellow / silver / bronze (4px solid)
- `#1` row also gets `shadow-card-elevated` — slightly lifted

### Yellow accent rule

Yellow (`#FFBE00`) is reserved for maximum impact. Use it sparingly:
- Primary CTAs
- Active nav tab
- `#1` classification row border
- Current jersey leader name highlight
- Score/point values in prominent callouts

Do not use yellow as a large background fill. Use it for borders, small chips, and accent highlights.

### Stage image banner treatment

Stage images are used as full-width banners with a dark gradient overlay:
```css
background: linear-gradient(to bottom, rgba(5,20,8,0.35), rgba(5,20,8,0.7));
```
Overlay text (white, PT Sans Narrow bold): stage number, route, date.
Always ensure white overlay text has ≥4.5:1 contrast against the image below.

### Jersey imagery as primary visual identifier

Jersey images take priority over team names and hex colors:
- A participant's team is communicated by their jersey `<img>` thumbnail
- Jersey cards lead with the jersey image, not the name
- Never use a jersey color as the sole team indicator — always pair with the image

### Classification cards — cycling race inspiration

Cycling race rankings are information-dense, not content cards. Apply:
- No decorative graphics inside classification rows
- Narrow, tight rows — data density over whitespace
- Bold position numbers dominant
- Minimal team indicator (28×28px image only, no text label)

---

## Jersey image usage

### Sizes by context

| Context | Size | Behavior |
|---------|------|----------|
| Classification row badge | 28×28px | Square `<img>`, `object-fit: contain`, fallback color dot |
| Small inline badge | 32–40px tall | Height-constrained, aspect-ratio preserved |
| Jersey card top block | max-height 80px | Centered, padded, `object-fit: contain` |
| Rules/reglas section header | 40–48px tall | Inline with section title |

**Do not stretch jersey images.** Always use `object-fit: contain`. Preserve aspect ratio at all sizes.

### Fallback pattern

All jersey `<img>` tags must include an `onerror` fallback. Images may fail in mountain areas with poor connectivity.

```html
<img
  src="/assets/maillots/amarillo.png"
  alt="Maillot amarillo"
  class="w-7 h-7 object-contain"
  onerror="this.style.display='none'; this.nextElementSibling.removeAttribute('hidden')"
/>
<span hidden class="w-7 h-7 rounded-full inline-block bg-[#FFBE00]"></span>
```

The fallback must preserve the same dimensions so the classification row layout does not break.

---

## Jersey and team image assets

### Source and public paths

Copy from `reference/assets/maillots/` to `public/assets/maillots/` before deployment.

| File | Public path | Type |
|------|------------|------|
| `amarillo.png` | `/assets/maillots/amarillo.png` | Special jersey |
| `verde.png` | `/assets/maillots/verde.png` | Special jersey |
| `puntos-rojo-balnco.png` | `/assets/maillots/puntos-rojo-balnco.png` | Special jersey |
| `maillot-iker.png` | `/assets/maillots/maillot-iker.png` | Custom/decorative |
| `mapei.png` | `/assets/maillots/mapei.png` | Team jersey |
| `rabobank.png` | `/assets/maillots/rabobank.png` | Team jersey |
| `once.png` | `/assets/maillots/once.png` | Team jersey |
| `kelme.png` | `/assets/maillots/kelme.png` | Team jersey |
| `festina.png` | `/assets/maillots/festina.png` | Team jersey |

> **Typo note:** `puntos-rojo-balnco.png` has a misspelling ("balnco" instead of "blanco").
> Use the exact filename as-is. Do not rename without explicit approval.

### Where images are used

| Location | Which images |
|----------|-------------|
| Landing — jersey overview cards | `amarillo.png`, `verde.png`, `puntos-rojo-balnco.png`, winning team jersey |
| `/clasificaciones` — all ranking tabs | Team jersey thumbnail (28×28px) per row |
| `/clasificaciones` — Jerseys actuales | All four special jerseys + winning team jersey |
| `/puntuaciones` — team assignment | Team jersey thumbnails as picker options |
| `/reglas` — jersey rule sections | One special jersey per section header |
| `/roadbook` — stage sections | `maillot-iker.png` where contextually appropriate |
| `/galeria` | No jersey image usage |

### Implementation notes

- Team jersey images loaded server-side via `teams.jersey_image_path` (D1)
- Special jersey paths are constants in `src/data/jerseys.ts`
- All `<img>` jersey tags require `alt` and `onerror` fallback

---

## Component inventory

Expected UI components to design and implement. One-line description and page usage.

| Component | Description | Used in |
|-----------|-------------|---------|
| `AppShell` | Layout wrapper: page content slot + BottomNavigation + optional desktop top bar | All pages |
| `BottomNavigation` | Sticky 5-tab bottom bar with active state, safe-area inset, lock state for Puntuar | All pages (mobile) |
| `PageHeader` | Page title + optional subtitle + optional right-side action button | All main pages |
| `StageCard` | Stage overview: image banner, route, date, scoring status pill, climb chips, CTA | `/`, `/roadbook` |
| `ClimbCard` | Single climb: name, category badge, altitude, programme note | `/roadbook`, `/reglas` |
| `JerseyCard` | Jersey overview: image on colored top block, name, current holder, description | `/`, `/clasificaciones` |
| `ClassificationCard` | Ranked row: position number, name, team badge (28×28px img), points | `/clasificaciones` |
| `TeamBadge` | Jersey image thumbnail (28×28px) with `onerror` color fallback | All classification tables, participant list |
| `ParticipantRow` | Participant name + team badge + optional status | `/`, `/puntuaciones` |
| `ScoreForm` | Score entry for one scoring event — inputs vary by `scoring_type` | `/puntuaciones` |
| `PhotoGrid` | Responsive 2-col photo grid with stage/day filter chips | `/galeria` |
| `PhotoUploadForm` | File input + uploader name + caption + stage tag selector + submit | `/galeria` |

---

## Tailwind configuration hints

```js
// tailwind.config.mjs
theme: {
  extend: {
    colors: {
      yellow: '#FFBE00',
      'race-black': '#051408',
      green: '#93E360',
      orange: '#F96E12',
      surface: '#F5F3F3',
      stroke: '#E5E3E3',
      'text-secondary': '#313131',
      muted: '#676F68',
    },
    fontFamily: {
      sans: ['InterTight', 'Arial', 'sans-serif'],
      display: ['PTSansNarrow', 'Arial', 'sans-serif'],
    },
    borderRadius: {
      pill: '40px',
    },
    boxShadow: {
      card: '0 12px 20px rgba(0,0,0,0.04)',
      'card-elevated': '0 20px 50px rgba(0,0,0,0.10)',
      sticky: '0 5px 25px rgba(0,0,0,0.25)',
      modal: '0 16px 80px rgba(0,0,0,0.06)',
      fab: '0 0 28px rgba(0,0,0,0.10)',
    },
  },
}
```

---

## What NOT to carry over from the Webflow template

- Commerce/cart components
- Webflow-specific `w-` class names
- JavaScript animation library (GSAP, Webflow scripts)
- Dropdown mega-nav
- Blog/CMS patterns
- Checkout or pricing UI
- Any `data-wf-*` attributes
- Desktop-first max-width layout logic
- The bundled `normalize.css` — use Tailwind's preflight instead
