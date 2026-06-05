# Cloudflare Architecture — Osbaldida 2026

## Overview

The app runs entirely on the Cloudflare platform:

| Layer | Service | Purpose |
|-------|---------|---------|
| Rendering | Cloudflare Workers (via Astro SSR) | Server-side page rendering |
| Database | Cloudflare D1 | All structured data |
| Storage | Cloudflare R2 | Photo uploads |
| Build/deploy | Wrangler CLI | Local dev + production deploy |

No external services. No Node.js server. No Docker. No VPS.

---

## Astro + Cloudflare Workers

Astro is configured with the `@astrojs/cloudflare` adapter, which compiles the
app to a Cloudflare Workers-compatible format.

- Astro pages with `export const prerender = false` are SSR.
- Static pages (rules, roadbook) can be prerendered.
- API routes live under `src/pages/api/` as Astro endpoints.

### Rendering strategy

| Page | Strategy | Reason |
|------|----------|--------|
| `/` | SSR | Shows live jersey leaders |
| `/clasificaciones` | SSR | Always live data |
| `/puntuaciones` | SSR | Auth check on every request |
| `/reglas` | Prerender (static) | Content doesn't change |
| `/roadbook` | Prerender (static) | Content doesn't change |
| `/galeria` | SSR | Photo list changes dynamically |

---

## Cloudflare D1

### Configuration (wrangler.toml)

```toml
[[d1_databases]]
binding = "DB"
database_name = "osbaldida-2026"
database_id   = "<to be filled after creation>"
```

The binding name `DB` is available in Workers via `env.DB`.

### Access pattern

All database access goes through repository functions in `src/server/db/`.
No raw SQL in pages or components.

```
Astro page → service → repository → env.DB (D1)
```

### Migration approach

Migrations live in `src/server/db/migrations/`.
Applied with `wrangler d1 migrations apply osbaldida-2026`.

The migrations must be idempotent and use `CREATE TABLE IF NOT EXISTS`.

---

## Cloudflare R2

Photo uploads are stored in R2.

### Configuration (wrangler.toml)

```toml
[[r2_buckets]]
binding  = "PHOTOS"
bucket_name = "osbaldida-photos"
```

The binding `PHOTOS` is available in Workers via `env.PHOTOS`.

### Access pattern

Photos are uploaded through an API endpoint (`POST /api/gallery/upload`).
The Worker:
1. Validates the file type and size.
2. Generates a unique object key.
3. Writes to R2 via `env.PHOTOS.put(key, body)`.
4. Saves metadata to D1.

Photo retrieval:
- Option A (MVP): Serve photos via a Worker route that reads from R2.
- Option B: Configure R2 public bucket access with a custom domain.

> **Decision needed:** R2 public access vs Worker-served photos.
> Public access is simpler and avoids Worker CPU for every image load.
> Worker-served is more controllable. For a 3-day event with 18 participants,
> either works. Recommend public R2 bucket for simplicity.

### File size limit

Cloudflare Workers request body limit: **100 MB** (for paid plan) or **100 MB** (for free plan with `--compatibility-date`).
Target: limit photo uploads to **10 MB** max at the application level.

---

## Environment variables

| Variable | Purpose | Where set |
|----------|---------|-----------|
| `ADMIN_CODE` | Shared code for `/puntuaciones` | Cloudflare dashboard → Workers secret |
| `GALLERY_CODE` | Optional code for photo uploads | Cloudflare dashboard → Workers secret |
| `R2_PUBLIC_URL` | Base URL for R2 public bucket | wrangler.toml vars or env |

Set secrets with:
```bash
wrangler secret put ADMIN_CODE
```

---

## Local development

Uses Wrangler's local D1 and R2 simulation.

```bash
wrangler dev
```

Local D1 is persisted at `.wrangler/state/v3/d1/`.
Local R2 is persisted at `.wrangler/state/v3/r2/`.

A local `.dev.vars` file (gitignored) holds secrets:
```
ADMIN_CODE=local-admin-code
GALLERY_CODE=local-gallery-code
```

---

## Folder structure (server-side)

```
src/
  pages/
    api/
      classifications/
        index.ts         -- GET /api/classifications
      scores/
        index.ts         -- POST /api/scores
      gallery/
        upload.ts        -- POST /api/gallery/upload
      auth/
        login.ts         -- POST /api/auth/login
  server/
    db/
      client.ts          -- D1 client wrapper
      migrations/        -- SQL migration files
      seed.ts            -- Seed data
    repositories/
      participants.ts
      scores.ts
      classifications.ts
      votes.ts
      photos.ts
    services/
      classification.ts  -- Business logic for rankings
      scoring.ts         -- Point calculation logic
      auth.ts            -- Session management
    validation/
      score.ts           -- Zod schemas for API inputs
      vote.ts
      upload.ts
    storage/
      photos.ts          -- R2 upload/read helpers
```

---

## wrangler.toml structure

```toml
name            = "osbaldida-2026"
compatibility_date = "2024-09-23"
main            = "dist/_worker.js"

[vars]
R2_PUBLIC_URL = "https://photos.osbaldida.pages.dev"  # placeholder

[[d1_databases]]
binding      = "DB"
database_name = "osbaldida-2026"
database_id  = ""  # fill after creation

[[r2_buckets]]
binding     = "PHOTOS"
bucket_name = "osbaldida-photos"
```

---

## Deployment

```bash
# Build
npm run build

# Deploy Workers app
wrangler deploy

# Apply migrations to production
wrangler d1 migrations apply osbaldida-2026 --remote

# Apply migrations locally
wrangler d1 migrations apply osbaldida-2026 --local
```

---

## TypeScript and Worker bindings

Cloudflare bindings need type declarations. Add to `src/env.d.ts`:

```typescript
interface Env {
  DB:     D1Database;
  PHOTOS: R2Bucket;
  ADMIN_CODE:   string;
  GALLERY_CODE: string;
}
```

Astro exposes the runtime environment via `Astro.locals.runtime.env` when using
the Cloudflare adapter.

---

## Constraints

- Workers CPU time limit: 10 ms on free plan, 30 s on paid (Bundled).
  Photo uploads and DB queries should be fast. No CPU-heavy image processing.
- D1 has no real-time subscriptions. Classifications refresh on page load.
- R2 has no built-in CDN by default. Public bucket URL or Workers route needed.

---

## Open questions

1. Will the project use a custom domain? (e.g. `osbaldida2026.com`)
2. Paid Workers plan needed for larger file uploads? (Free plan: 100 MB body limit should be fine)
3. R2 public bucket vs Worker-served photos — confirm before gallery implementation.
4. Single deployment for the whole event or Cloudflare Pages with Workers integration?
   Pages + Workers is also a viable option but adds deployment complexity.
