import type { TeamKey } from './jerseys';
import { TEAM_JERSEY_PATHS } from './jerseys';

export interface Team {
  key: TeamKey;
  name: string;
  jerseyPath: string;
  bgColor: string;
  fallbackColor: string;
  description: string;
}

export const TEAMS: readonly Team[] = [
  {
    key: 'mapei',
    name: 'Mapei',
    jerseyPath: TEAM_JERSEY_PATHS.mapei,
    bgColor: '#EDE6ED',
    fallbackColor: '#B8A8B8',
    description: 'Los cubos italianos. Especialistas en clásicas, bloques tácticos y resistencia en grupo.',
  },
  {
    key: 'rabobank',
    name: 'Rabobank',
    jerseyPath: TEAM_JERSEY_PATHS.rabobank,
    bgColor: '#F0E8DC',
    fallbackColor: '#C4A88A',
    description: 'La naranja holandesa. Equipo de regularidad, ritmo constante y puertos largos.',
  },
  {
    key: 'once',
    name: 'ONCE',
    jerseyPath: TEAM_JERSEY_PATHS.once,
    bgColor: '#F0ECD8',
    fallbackColor: '#C4B88A',
    description: 'El amarillo español de los 90. Disciplina, control del pelotón y dominio en ruta.',
  },
  {
    key: 'kelme',
    name: 'Kelme',
    jerseyPath: TEAM_JERSEY_PATHS.kelme,
    bgColor: '#E4EDE4',
    fallbackColor: '#92B892',
    description: 'El rojo valenciano. Combativos en puerto y agresivos cuando toca atacar.',
  },
  {
    key: 'festina',
    name: 'Festina',
    jerseyPath: TEAM_JERSEY_PATHS.festina,
    bgColor: '#E8F0F8',
    fallbackColor: '#A8C4DC',
    description: 'El reloj suizo. Historia dudosa, ritmo metódico y resistencia cuestionable.',
  },
] as const;
