# Mobile UI Guidelines — Osbaldida 2026

The app is designed for mobile-first use. Desktop is a secondary concern.
Target: 360px minimum width, iOS and Android browsers.

The app will be used outdoors, in mountain terrain, and party conditions — gloved fingers,
bright sunlight, poor connectivity, and divided attention. All UI decisions must reflect this.

---

## Core principles

1. **Tap targets minimum 44×44px.** Smaller targets cause mis-taps in a party context.
2. **One primary action per screen.** Users must not hunt for what to do next.
3. **No horizontal scroll on data.** All table columns must fit within 360px.
4. **Minimum 16px body text.** No exceptions for any interactive label or primary information.
5. **High contrast.** Yellow on black and black on yellow both meet WCAG AA.
6. **Fast to reach key info.** Classifications and roadbook within one tap from anywhere.
7. **Prevent data loss.** Score entry forms must confirm before navigating away.

---

## Breakpoints

| Name | Width | Target devices |
|------|-------|----------------|
| `mobile` | ≤ 479px | Phones (primary target) |
| `tablet` | 480px – 767px | Large phones, small tablets |
| `desktop` | ≥ 768px | Tablets, laptops (secondary) |

All Tailwind/CSS styles start from the mobile layout.
Use `sm:` / `md:` / `lg:` prefixes only to enhance, never to define the base.

---

## Navigation

### Sticky bottom bar (mobile) — final decision

The primary navigation for mobile is a sticky bottom tab bar with **five items**.
This decision is final. Do not add a sixth tab.

| Tab | Route | Icon |
|-----|-------|------|
| Inicio | `/` | Home icon |
| Clasificación | `/clasificaciones` | Trophy/ranking icon |
| Puntuar | `/puntuaciones` | Pencil icon (lock when not authenticated) |
| Roadbook | `/roadbook` | Map icon |
| Galería | `/galeria` | Camera icon |

Specs:
- `position: fixed; bottom: 0; width: 100%`
- `padding-bottom: env(safe-area-inset-bottom)` — required for iPhone home bar
- Height: 56px + safe area
- Background: `#051408` (race-black)
- Active: yellow icon + yellow label
- Inactive: white icon + white label, `opacity: 0.6`
- Label font size: **11px**, Inter Tight, weight 500 (one consistent value)
- Icon size: 24px
- Minimum tab width: 64px (5 × 64px = 320px, fits within 360px with margin)

**`/reglas` secondary access** — Rules are not in the bottom nav. Accessible via:
- Landing page quick links section
- Roadbook page "Ver reglas" link
- Desktop top navbar

### Top navigation (desktop)

On `md:` (≥768px), bottom bar is hidden. A horizontal top navbar appears with links to all six pages including Reglas.

---

## Component inventory

See `docs/design-reference.md` — "Component inventory" section — for the full list of UI
components with one-line descriptions and page usage.

---

## Tables and classifications

### Column rules

| Column | Width | Notes |
|--------|-------|-------|
| Position | 36px | Large, bold PT Sans Narrow |
| Name | flex-grow | Truncate with ellipsis if needed |
| Team badge | 28px | 28×28px jersey `<img>` — not emoji, not a letter abbreviation |
| Points | 48px | Right-aligned, bold |

Total: 36 + flex + 28 + 48 ≈ 360px. All columns always visible. Never use `overflow-x: auto` on classification rows.

Use cards (`<div>`), not `<table>`, on mobile. Cards are easier to style responsively.
Sticky header row stays visible when scrolling a long list.

### Classification card anatomy

```
┌──────────────────────────────────────────┐
│ #1  Trueba   [jersey img 28px]   42 pts  │
│ #2  Java     [jersey img 28px]   38 pts  │
│ #3  Igor     [jersey img 28px]   35 pts  │
└──────────────────────────────────────────┘
```

Team badge: 28×28px `<img>` from `teams.jersey_image_path`. If the image fails to load, fall back to a color dot using `teams.color_hex`. See the jersey image fallback section below.

Row height: 52–56px minimum. This ensures a comfortable tap target on each row.

### Empty state (pre-event)

Before any scoring starts, all classification lists will be empty. Show a friendly empty state rather than an empty table or blank space.

```
Sin datos aún.
Las clasificaciones se mostrarán cuando
se registren los primeros puntos.
```

- Centered text in muted color
- Optional empty-state icon (empty trophy, empty list)
- Do not render an empty table header with no rows

---

## Jersey image fallback

Jersey images may fail to load during the event due to poor mountain connectivity.
**All `<img>` jersey tags must include a visible fallback.**

```html
<img
  src="/assets/maillots/amarillo.png"
  alt="Maillot amarillo"
  class="w-7 h-7 object-contain"
  onerror="this.style.display='none'; this.nextElementSibling.removeAttribute('hidden')"
/>
<span hidden class="w-7 h-7 rounded-full inline-block bg-[#FFBE00]"></span>
```

Rules:
- The fallback must occupy the same 28×28px space — the classification row layout must not break
- Use the jersey's `color_hex` as the fallback background (neutral gray for special jerseys if unknown)
- The fallback is a colored circle or square — not text, not a broken-image icon

---

## Scoring entry forms (`/puntuaciones`)

### General input patterns

- **Participant selector:** vertical list of names with tap-to-select. No `<select>` dropdown — hard to use outdoors or with gloves.
- **Points chips:** for small point options (0 / +1 / +2), show three large tappable chips.
- **Confirmation:** every save shows an inline "Guardado ✓" success badge before any navigation.
- **Error state:** full-width red banner with the error message. Not just a border-color change.
- **Data loss prevention:** if the user tries to navigate away from an unsaved form, show a confirmation dialog. Do not silently discard data.

### Friday scoring forms (fixed rules from Excel)

Each Friday climb shows its scoring rules inline as reference. Input style adapts to `scoring_type`:

| Climb | Input type |
|-------|-----------|
| Gardea | 3-option chip per participant (0 / +1 / +2) |
| Avituallamiento | Group selector → percentage chip → auto-applies to all in the group |
| Gato Negro | Accumulative checkboxes per drink type, per participant |
| Gascona | Two checkboxes per participant (piruleta +3 / Jäger +8) — both can be ticked (max +11) |

### Saturday manual scoring form

Saturday climbs are `scoring_type = 'manual'`. Points are entered directly by the admin.

Flow:
1. Stage selector (Stage 2 preselected on Saturdays)
2. Scoring event selector (lists active `score_events` for the selected stage)
3. Per-participant form rows:
   - **Points** — numeric stepper or input (positive or negative integer)
   - **Reason** — free text (e.g. "consumición en cima", "reto superado")
   - **Evidence note** — free text (photo reference, description)
4. Save button — full width, 56px height
5. Confirmation: "Puntos guardados ✓" inline toast

Mobile layout:
- Participant rows: full-width, 56px minimum height
- Numeric input: minimum 52px height, font-size ≥ 16px
- Reason and evidence fields: expandable textarea
- If the participant list is long, collapse entered rows and allow tap to expand for editing

### Green jersey voting — round selector

Voting is organized in two rounds, not per-climb.

Round selector at the top of the voting form:

```
[ Ronda 1 — Sábado: evalúa Viernes ] [ Ronda 2 — Domingo: evalúa Sábado ]
```

Per voter per round:
1. Select voter (shown separately, excluded from vote targets)
2. Assign +5 — tap to select one other participant (best performance)
3. Assign +3 — tap to select one other participant
4. Assign +1 — tap to select one other participant
5. Assign -1 — tap to select one other participant

Validation:
- All four tiers must be assigned before saving
- Each tier must go to a different participant
- The voter cannot vote for themselves
- If the user selects the same participant for two tiers, show an inline error

UI guidance:
- Use a vertical list of participant names; each row shows which tier (if any) they've been assigned
- Disable a participant row once they have been assigned a tier
- Show remaining unassigned tiers prominently at the top of the form
- Show a full summary before the final save button: "X: +5, Y: +3, Z: +1, W: -1"

### Form layout

- Full-width inputs — no two-column layouts on mobile forms
- Label above input (not placeholder-only labels)
- Submit button: full width, 56px height, bottom of form
- Top padding: 20px. Inter-field gap: 16px
- If the form is long, pin the save button to the bottom of the viewport

---

## Photo upload

### Upload form

```html
<input type="file" accept="image/*" />
```

- Use `accept="image/*"` **without** a `capture` attribute.
- On iOS and Android, this gives the user a choice: take a new photo or pick from camera roll. This is the correct behavior for MVP.
- **Do not use `capture="environment"`** — it forces the camera and bypasses the photo library on some devices. Camera capture is not a requirement for MVP.
- Wrap the input in a large `<label>` for tap area

### Upload button

- Full-width `<label>` wrapping the `<input>`
- Height: 56px minimum
- Background: `yellow` (`#FFBE00`)
- Text: "Subir foto", black, 16px semi-bold
- Icon: plus or image icon

### Upload feedback

- **Progress:** show a spinner or thin progress bar during upload
- **Success:** display the uploaded image thumbnail + "Foto subida ✓"
- **Error:** show the error message + a "Reintentar" button. Do not lose the selected image file.
- Do not auto-navigate away on success — let the user choose

---

## Loading, success, and error states

### Loading

- Classification pages: show skeleton placeholder rows (3–5 rows with shimmer) while data loads
- Score form submit: disable save button + spinner on the button label during the request
- Photo upload: progress indicator above the upload area

### Success

- Score entry: inline green badge "Guardado ✓" replaces the save button briefly, then re-enables
- Photo upload: uploaded thumbnail + "Foto subida ✓" message
- Voting form: "Voto registrado ✓" confirmation shown per voter before moving to the next

### Error

- All errors: full-width red banner with the error message, shown above the relevant form
- Not just a border-color change — errors must be immediately visible without scanning the page
- Network error on classification page: "Sin conexión — inténtalo de nuevo" banner
- Upload error: error message + "Reintentar" button, keep the selected file

---

## Typography on mobile

| Element | Size | Font | Weight |
|---------|------|------|--------|
| Body text | 16px | Inter Tight | 500 |
| Form labels | 16px | Inter Tight | 500 |
| Classification position number | 28–32px | PT Sans Narrow | 700 |
| Classification name | 16px | Inter Tight | 500 |
| Classification points | 18–20px | Inter Tight | 700 |
| Jersey card title | 20–22px | Inter Tight | 600 |
| Stage card title | 18px | PT Sans Narrow | 700 |
| Button label | 16px | Inter Tight | 600 |
| Bottom nav label | **11px** | Inter Tight | 500 |
| Captions, timestamps, meta | 14px | Inter Tight | 500 |

**Minimum: 16px** for all interactive labels and primary information. 14px is for captions and timestamps only.

---

## Touch interaction patterns

### Tap feedback

All interactive elements must show a visual response immediately on tap:
- Buttons: `active:scale-[0.97]` + background color shift
- Table rows: `active:bg-surface`
- Nav items: `active:opacity-100` from reduced opacity
- Chips and checkboxes: `active:ring-2 active:ring-yellow-400`

### Swipe

Avoid relying on swipe gestures for primary navigation. Bottom tabs + tap is primary.
Gallery swipe (previous/next photo) is optional, but visible tap-to-advance arrows are required as fallback.

### Pull-to-refresh

Not required in MVP. Users can tap the current page tab in the nav to reload.

---

## Offline and slow connections

The event takes place in mountain areas with potentially poor connectivity.

- Avoid large JavaScript bundles on classification and rules pages
- `loading="lazy"` on all gallery images
- Prerender `/reglas` and `/roadbook` so they load from cache
- Classification pages SSR on every request — no stale static data
- Jersey images: always include `onerror` fallback — images may fail on poor connections
- Upload failure: show a clear error and allow retry without losing the selected file

No full offline/PWA mode required for MVP.

---

## iOS/Android specific

| Issue | Mitigation |
|-------|------------|
| iOS tap delay (300ms) | `touch-action: manipulation` on all interactive elements |
| iOS viewport height bug (`100vh` ≠ visible area) | Use `dvh` units or `min-height: -webkit-fill-available` |
| Android back button | Navigation uses browser history — no custom back intercepts |
| iOS safe area (home bar) | `env(safe-area-inset-bottom)` on bottom nav |
| iOS input zoom | Font-size ≥ 16px on all `<input>` elements prevents auto-zoom |
| iOS overscroll | `overscroll-behavior: none` on modal/bottom-sheet elements |

---

## Accessibility requirements

These are concrete minimum requirements. The app is used outdoors in physically demanding conditions — poor accessibility makes it unusable regardless of the event context.

| Requirement | Rule |
|-------------|------|
| Body text size | Minimum 16px for all interactive labels and primary text |
| Contrast | All body text must meet WCAG AA (4.5:1 minimum). See contrast pairings table in `docs/design-reference.md` |
| Focus states | All interactive elements must have visible `:focus-visible` styles (e.g. yellow ring outline) |
| Color as sole indicator | Never use color alone — always pair with icon, label, or shape |
| Images | All jersey and stage `<img>` tags must have descriptive `alt` attributes |
| Navigation | Bottom nav icon-only items must have `aria-label` |
| Forms | Every `<input>` must have an associated `<label>`. No placeholder-only labels |
| Hover interactions | No hover-only actions. Every interaction must be accessible by tap/touch |
| Tap targets | 44×44px minimum for all interactive elements |
| Loading states | Communicate loading to screen readers: `aria-busy`, `aria-live` region updates |
| Form data loss | Unsaved forms must warn before navigation. Do not silently discard entered data |

---

## Component size reference

| Component | Height | Min width |
|-----------|--------|-----------|
| Bottom nav bar | 56px + safe area | 100% |
| Primary button | 52–56px | 100% (mobile), auto (desktop) |
| Input field | 52px | 100% |
| Classification row | 52–56px | 100% |
| Stage card (image block) | 160px image + ~80px body | 100% |
| Jersey card | ~80px top block + ~60px body | 100% |
| Climb card | 100–120px | 100% |
| Photo grid cell | square ratio | 48% (2-col grid) |
| Bottom sheet backdrop | full screen | full screen |
