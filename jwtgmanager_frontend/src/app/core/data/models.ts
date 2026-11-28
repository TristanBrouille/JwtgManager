/** ADN (espèce débloquée), super ADN (super hybride débloqué), ambre (espèce non débloquée). */
export type Currency = 'DNA' | 'SUPER_DNA' | 'AMBER';

export const CURRENCY_LABEL: Record<Currency, string> = {
  DNA: 'ADN',
  SUPER_DNA: 'Super ADN',
  AMBER: 'Ambre',
};
export type CurrencyFilter = Currency | 'ALL';
/** Raretés du jeu (paleo.gg) : commun, rare, extra rare, légendaire, tournoi, vedette, superstar, jouet, VIP. */
export type RarityCode = 'C' | 'R' | 'E' | 'L' | 'T' | 'S' | 'U' | 'J' | 'V';
export const RARITY_CODES: readonly RarityCode[] = ['C', 'R', 'E', 'L', 'T', 'S', 'U', 'J', 'V'];
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
  /** Budget restant pour terminer les espèces favorites suivies. */
  favorites: {
    species: number;
    done: number;
    /** Favorites non terminées sans coût renseigné (non chiffrées). */
    unknownCost: number;
    dna: Projection;
    superDna: Projection;
    amber: Projection;
  };
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

/**
 * Espèce proposée à la fusion : au moins 2 spécimens au niveau 10, 20 ou 30.
 * Les VIP ne sont pas proposées à la fusion.
 */
export function canFuse(s: SpeciesProgress): boolean {
  return s.rarityCode !== 'V' && (s.lvl10 >= 2 || s.lvl20 >= 2 || s.lvl30 >= 2);
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

/** Profil de combat d'après le rapport attaque / santé. */
export type CombatProfile = 'TANK' | 'BALANCED' | 'STRIKER';
export type TournamentCode = 'JURASSIC' | 'AQUATIC' | 'CENOZOIC';
export type LeagueCode = 'NEWBORN' | 'HUNTER' | 'PREDATOR' | 'DOMINANT';

export interface TeamMember {
  speciesId: number;
  name: string;
  level: number;
  creatureClass: string;
  health: number;
  attack: number;
  ferocity: number;
  profile: CombatProfile;
  profileLabel: string;
  portraitUrl: string | null;
}

/** Idéal (paire complémentaire) ou paire non complémentaire ; les fureurs sont toujours à 10 % près. */
export type TeamQuality = 'IDEAL' | 'UNMATCHED_PAIR';

/** Trio : members[0] et members[1] forment la paire, members[2] est le dino seul. */
export interface TournamentTeam {
  rank: number;
  totalFerocity: number;
  ferocityGap: number;
  pairClass: string;
  singleClass: string;
  quality: TeamQuality;
  qualityLabel: string;
  members: TeamMember[];
}

/** Spécimens identiques restés sans trio. */
export interface TournamentLeftover {
  specimen: TeamMember;
  count: number;
}

export interface TournamentResult {
  code: TournamentCode;
  label: string;
  /** Dinos du joueur jouables dans ce tournoi. */
  specimens: number;
  /** Dinos répartis en trios. */
  placed: number;
  teamCount: number;
  idealTeams: number;
  leagues: TournamentLeague[];
  leftovers: TournamentLeftover[];
}

export interface TournamentLeague {
  code: LeagueCode;
  label: string;
  /** Fureur totale minimale, exclue (sauf 0). */
  above: number;
  /** Fureur totale maximale, incluse ; null pour la ligue dominant. */
  upTo: number | null;
  /** Fureur minimale de chaque dino de la ligue. */
  minUnit: number;
  /** Fureur maximale de chaque dino ; null si aucune. */
  maxUnit: number | null;
  teams: TournamentTeam[];
}

export interface TournamentPlan {
  /** Null tant qu'aucun calcul n'a été lancé. */
  computedAt: string | null;
  /** La collection a changé depuis le dernier calcul. */
  outdated: boolean;
  tournaments: TournamentResult[];
}
