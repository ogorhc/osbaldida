import type { TeamKey } from './jerseys';

export interface Participant {
  nickname: string;
  firstName: string;
  lastName: string;
  teamKey?: TeamKey | null;
}

export const PARTICIPANTS: readonly Participant[] = [
  { nickname: 'Truebasson', firstName: 'Eneko', lastName: 'Trueba' },
  { nickname: 'Java', firstName: 'Jagoba', lastName: 'Pereda' },
  { nickname: 'Ogor', firstName: 'Igor', lastName: 'Hinojosa' },
  { nickname: 'Motri', firstName: 'Asier', lastName: 'Motriko' },
  { nickname: 'Maka', firstName: 'Iñaki', lastName: 'Saez de Adana' },
  { nickname: 'Sopas', firstName: 'David Pelayo', lastName: 'Seoane' },
  { nickname: 'La Embarazada', firstName: 'Zaloa', lastName: 'Sanjurjo' },
  { nickname: 'Malware404', firstName: 'Kamil Dariusz', lastName: 'Mazurkiewicz' },
  { nickname: 'Fiti', firstName: 'Ibai', lastName: 'Santisteban' },
  { nickname: 'Luchenko', firstName: 'Patiño Pelayo', lastName: 'Patiño' },
  { nickname: 'Hiru Gurutzeta', firstName: 'Uxue', lastName: 'Canibe' },
  { nickname: 'Gambo', firstName: 'Borja', lastName: 'Oliva' },
  { nickname: 'Bakana', firstName: 'Aritza', lastName: 'García' },
  { nickname: 'Tru', firstName: 'Unai', lastName: 'Albisua' },
  { nickname: 'Culiao', firstName: 'Fabio Ignacio', lastName: 'Cáceres' },
  { nickname: 'Fokro', firstName: 'Fikri', lastName: 'Arakraki' },
  { nickname: 'La Presi', firstName: 'Aintzane', lastName: 'García' },
  { nickname: 'Txete', firstName: 'Oier', lastName: 'Cerro' },
  { nickname: 'Osbal', firstName: 'Iker', lastName: 'Bravo' },
] as const;
