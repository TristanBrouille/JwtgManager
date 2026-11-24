/** ADN (espèce débloquée), super ADN (super hybride débloqué), ambre (espèce non débloquée). */
export type Currency = 'DNA' | 'SUPER_DNA' | 'AMBER';

export const CURRENCY_LABEL: Record<Currency, string> = {
  DNA: 'ADN',
  SUPER_DNA: 'Super ADN',
  AMBER: 'Ambre',
};
export type CurrencyFilter = Currency | 'ALL';
export type RarityCode = 'C' | 'R' | 'E' | 'L' | 'T';
/** Super hybride = hybride dont au moins un composant est lui-même un hybride. */
export type HybridKind = 'NONE' | 'HYBRID' | 'SUPER_HYBRID';

export const HYBRID_KIND_LABEL: Record<HybridKind, string> = {
  NONE: 'espèce de base',
  HYBRID: 'hybride',
  SUPER_HYBRID: 'super hybride',
};

export interface User {
  id: string;
  email: string;
  pseudo: string;
  role: string;
}

export interface AuthResponse {
  token: string;
  user: User;
}

export interface Rarity {
  code: RarityCode;
  label: string;
  sortOrder: number;
}

export interface Hybrid {
  hybridId: number;
  name: string;
  kind: Exclude<HybridKind, 'NONE'>;
  componentIds: number[];
}

export interface SpeciesProgress {
  speciesId: number;
  name: string;
  rarityCode: RarityCode;
  hybridKind: HybridKind;
  unlocked: boolean;
  /** Épinglée en favori pour un accès rapide. */
  favorite: boolean;
  lvl10: number;
  lvl20: number;
  lvl30: number;
  lvl40: number;
  targetLvl40: number;
  currency: Currency;
  unitCost: number | null;
  units: number;
  /** Unités de palier restant à payer (colonne « Rest » de l'Excel) ; peut valoir 0 avant d'avoir fini. */
  unitsRemaining: number;
  progress: number;
  /** Objectif de niveaux 40 atteint. */
  done: boolean;
  invested: number;
  remaining: number;
}

export interface SpeciesUpdate {
  unlocked: boolean;
  lvl10: number;
  lvl20: number;
  lvl30: number;
  lvl40: number;
  targetLvl40: number;
}

export interface Settings {
  weeklyDna: number;
  weeklySuperDna: number;
  weeklyAmber: number;
  defaultTarget: number;
}

export interface Investment {
  id: number;
  speciesId: number;
  speciesName: string;
  fromLevel: number | null;
  toLevel: number;
  quantity: number;
  cost: number;
  currency: Currency;
  investedOn: string;
}

export interface NewInvestment {
  speciesId: number;
  fromLevel: number | null;
  toLevel: number;
  quantity: number;
  investedOn: string;
}

export interface Projection {
  remaining: number;
  weeklyIncome: number;
  weeks: number | null;
  finishDate: string | null;
}

export interface Dashboard {
  currencyFilter: CurrencyFilter;
  summary: {
    completion: number;
    done: number;
    tracked: number;
    lvl40: number;
    lvl40Target: number;
    dnaInvested: number;
    dnaRemaining: number;
    superDnaInvested: number;
    superDnaRemaining: number;
    amberInvested: number;
    amberRemaining: number;
  };
  previousCompletion: number | null;
  hybridsUnlocked: number;
  hybridsTotal: number;
  superHybridsUnlocked: number;
  superHybridsTotal: number;
  byRarity: {
    code: RarityCode;
    label: string;
    completion: number;
    done: number;
    tracked: number;
    dnaRemaining: number;
    superDnaRemaining: number;
    amberRemaining: number;
  }[];
  closest: {
    speciesId: number;
    name: string;
    rarityCode: RarityCode;
    progress: number;
    remaining: number;
    currency: Currency;
  }[];
  dna: Projection;
  superDna: Projection;
  amber: Projection;
}

export interface HistoryPoint {
  day: string;
  completion: number;
  lvl40Count: number;
  lvl40Target: number;
}

/**
 * État de déblocage d'une espèce :
 * débloquée, bloquée mais achetable en ambre, ou bloquée sans coût ambre (comptée en ADN en attendant).
 */
export type LockState = 'UNLOCKED' | 'LOCKED_AMBER' | 'LOCKED';

export function lockState(s: SpeciesProgress): LockState {
  if (s.unlocked) {
    return 'UNLOCKED';
  }
  return s.currency === 'AMBER' ? 'LOCKED_AMBER' : 'LOCKED';
}

/** Multiplicateur de coût de chaque palier (niv. 10, 20, 30, 40). */
export const LEVEL_MULTIPLIER: Record<number, number> = { 10: 1, 20: 2, 30: 4, 40: 8 };

/** Statistiques d'un palier (niveau 10, 20, 30 ou 40). */
export interface CreatureLevel {
  level: number;
  health: number;
  attack: number;
  portraitUrl: string;
}

/** Fiche de jeu importée de paleo.gg ; les durées sont en minutes. */
export interface CreatureSheet {
  region: string | null;
  creatureClass: string | null;
  releaseDate: string | null;
  levels: CreatureLevel[];
  ferocity: number | null;
  coins: number | null;
  coinMinutes: number | null;
  coinsPerMinute: number | null;
  hatchMinutes: number | null;
  dnaBuy: number | null;
  dnaSell: number | null;
  imageUrl: string;
  sourceUrl: string;
}

export interface SpeciesDetail {
  id: number;
  name: string;
  rarityCode: RarityCode;
  hybridKind: HybridKind;
  dnaCost: number | null;
  amberCost: number | null;
  /** Espèces qui composent cet hybride (vide pour une espèce de base). */
  componentIds: number[];
  /** Hybrides dont cette espèce est un composant. */
  usedInIds: number[];
  /** Null si aucune fiche de jeu n'a été importée pour cette espèce. */
  sheet: CreatureSheet | null;
}
