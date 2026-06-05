export type ClimbCategory = 'HC' | '1ª' | '2ª' | '3ª';
export type ScoringType = 'individual' | 'team' | 'accumulative' | 'manual';

export interface Climb {
  id: string;
  stageId: string;
  order: number;
  name: string;
  nickname: string;
  category: ClimbCategory;
  altitude?: string;
  location?: string;
  programmeNote: string;
  scoringType: ScoringType;
  maxPoints?: string;
}

export const CLIMBS: Climb[] = [
  // ── Etapa 1 — Viernes ──────────────────────────────────────────────────────
  {
    id: 'gardea',
    stageId: 'etapa-1',
    order: 1,
    name: 'Alto de Gardea',
    nickname: 'La emboscada de Jonhy',
    category: '3ª',
    altitude: '600 m',
    location: 'Polideportivo Gardea, Llodio',
    programmeNote: 'Concentración a las 16:30. Primera emboscada oficial de la Osbaldida.',
    scoringType: 'individual',
    maxPoints: '+2',
  },
  {
    id: 'avituallamiento',
    stageId: 'etapa-1',
    order: 2,
    name: 'Alto del Avituallamiento',
    nickname: 'Enlace Llodio → Oviedo',
    category: '2ª',
    altitude: '800 m',
    programmeNote: 'Salida hacia Oviedo sobre las 18:00. Avituallamiento oficial en ruta: 3 cervezas por persona en cada coche.',
    scoringType: 'team',
    maxPoints: '+8',
  },
  {
    id: 'gato-negro',
    stageId: 'etapa-1',
    order: 3,
    name: 'Alto del Gato Negro',
    nickname: 'La cena de equipo',
    category: 'HC',
    altitude: '1400 m',
    location: 'Sidrería El Gato Negro',
    programmeNote: 'Cena a las 22:00 en la Sidrería El Gato Negro. Después, salida neutralizada por Gascona.',
    scoringType: 'accumulative',
    maxPoints: '~+9',
  },
  {
    id: 'gascona',
    stageId: 'etapa-1',
    order: 4,
    name: 'Alto de Gascona',
    nickname: 'Rampas de doble chupito',
    category: '1ª',
    altitude: '1000 m',
    location: 'Calle Gascona',
    programmeNote: 'Primer bar después de cenar. Doble chupito, de más suave a más duro. Sin excusas.',
    scoringType: 'accumulative',
    maxPoints: '+11',
  },

  // ── Etapa 2 — Sábado ───────────────────────────────────────────────────────
  {
    id: 'viapar',
    stageId: 'etapa-2',
    order: 1,
    name: 'Alto de Viapará',
    nickname: 'La salida del condenado',
    category: '2ª',
    location: 'Viapará',
    programmeNote: 'Iker empieza la subida desde Viapará. El pelotón se coloca por la subida del Angliru.',
    scoringType: 'manual',
  },
  {
    id: 'angliru',
    stageId: 'etapa-2',
    order: 2,
    name: 'Alto del Angliru',
    nickname: 'La etapa reina de la vergüenza',
    category: 'HC',
    programmeNote: 'Puerto central. Preguntas y pruebas durante la subida. Penalizaciones previstas. Foto de equipo en la cima.',
    scoringType: 'manual',
  },
  {
    id: 'cafe-torero',
    stageId: 'etapa-2',
    order: 3,
    name: 'Alto del Café Torero',
    nickname: 'Tercera semana de carrera',
    category: '1ª',
    altitude: '1000 m',
    programmeNote: 'Después del Angliru. Café Torero u otra parada según el estado del pelotón. Fuego hasta la noche.',
    scoringType: 'manual',
  },
];

export const FRIDAY_CLIMBS = CLIMBS.filter((c) => c.stageId === 'etapa-1');
export const SATURDAY_CLIMBS = CLIMBS.filter((c) => c.stageId === 'etapa-2');
