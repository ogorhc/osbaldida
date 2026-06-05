/// <reference types="astro/client" />

type Runtime = import('@astrojs/cloudflare').Runtime<Env>;

interface Env {
  DB: import('@cloudflare/workers-types').D1Database;
  PHOTOS: import('@cloudflare/workers-types').R2Bucket;
  ADMIN_CODE: string;
  GALLERY_CODE: string;
  R2_PUBLIC_URL: string;
}

declare namespace App {
  interface Locals extends Runtime {}
}
