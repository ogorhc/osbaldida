export const JERSEY_PATHS = {
  amarillo: '/assets/maillots/amarillo.png',
  verde: '/assets/maillots/verde.png',
  puntos: '/assets/maillots/puntos-rojo-balnco.png',
  iker: '/assets/maillots/maillot-iker.png',
} as const;

export const TEAM_JERSEY_PATHS = {
  mapei: '/assets/maillots/mapei.png',
  rabobank: '/assets/maillots/rabobank.png',
  once: '/assets/maillots/once.png',
  kelme: '/assets/maillots/kelme.png',
  festina: '/assets/maillots/festina.png',
} as const;

export const JERSEY_FALLBACK_COLORS = {
  amarillo: '#FFBE00',
  verde: '#93E360',
  puntos: '#EF4444',
} as const;

export const STAGE_IMAGE_PATHS = {
  etapa1: '/assets/stages/etapa-viernes.webp',
  etapa2: '/assets/stages/etapa-sabado.webp',
  angliru: '/assets/stages/alto-del-angliru.webp',
} as const;

export type JerseyKey = keyof typeof JERSEY_PATHS;
export type TeamKey = keyof typeof TEAM_JERSEY_PATHS;
export type StageKey = keyof typeof STAGE_IMAGE_PATHS;
