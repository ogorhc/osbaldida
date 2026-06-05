export type StageId = 'etapa-1' | 'etapa-2' | 'domingo';

export interface Stage {
  id: StageId;
  label: string;
  stageNumber?: number;
  day: string;
  date: string;
  route: string;
  isScoring: boolean;
  imageUrl: string | null;
  climbIds: string[];
  summary: string;
}

export const STAGES: readonly Stage[] = [
  {
    id: 'etapa-1',
    stageNumber: 1,
    label: 'Etapa 1',
    day: 'Viernes',
    date: '5 Jun 2026',
    route: 'Llodio → Oviedo',
    isScoring: true,
    imageUrl: '/assets/stages/etapa-viernes.webp',
    climbIds: ['gardea', 'avituallamiento', 'gato-negro', 'gascona'],
    summary: 'Jornada de aproximación, emboscada, cena y primeros ataques nocturnos.',
  },
  {
    id: 'etapa-2',
    stageNumber: 2,
    label: 'Etapa 2',
    day: 'Sábado',
    date: '6 Jun 2026',
    route: 'Oviedo → Oviedo',
    isScoring: true,
    imageUrl: '/assets/stages/etapa-sabado.webp',
    climbIds: ['viapar', 'angliru', 'cafe-torero'],
    summary: 'La etapa reina. El día donde se separan los hombres de los que dicen "solo bajo a tomar un café".',
  },
  {
    id: 'domingo',
    label: 'Bajada y Meta',
    day: 'Domingo',
    date: '7 Jun 2026',
    route: 'Regreso controlado',
    isScoring: false,
    imageUrl: null,
    climbIds: [],
    summary: 'Sin puntuación. Bajada neutralizada. Salida del alojamiento antes de las 12:00.',
  },
] as const;
