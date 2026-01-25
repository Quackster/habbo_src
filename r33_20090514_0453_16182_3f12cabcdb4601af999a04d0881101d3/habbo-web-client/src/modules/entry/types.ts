/**
 * Entry Module Type Definitions
 *
 * Ported from: hh_entry/*.ls, hh_entry_base/*.ls, hh_entry_init/*.ls
 * and regional variants (hh_entry_es, hh_entry_fr, hh_entry_it, etc.)
 */

/**
 * Available entry/login types
 */
export type EntryType = 'sso' | 'credentials' | 'quickLogin' | 'auto';

/**
 * Entry states matching the original Lingo implementation
 */
export type EntryState = 'reset' | 'hotelView' | 'entryBar' | 'initialize';

/**
 * Available hotel regions with different hotel view animations
 */
export type HotelRegion =
  | 'default'  // Base hotel view
  | 'es'       // Spain - clouds, cars
  | 'fr'       // France - clouds, cars
  | 'it'       // Italy - clouds, cars, boats
  | 'jp'       // Japan - clouds, cars, trains, bubbles, image scroller
  | 'nl'       // Netherlands - clouds, cars, trains
  | 'no'       // Norway - clouds, cars, sailboats, twinkle
  | 'pl'       // Poland - clouds, cars
  | 'ru'       // Russia - clouds, cars
  | 'se'       // Sweden - clouds, cars
  | 'sg'       // Singapore - clouds, boats
  | 'uk'       // UK - clouds, cars
  | 'us';      // USA - clouds, cars

/**
 * Hotel view animation types supported by the system
 */
export type HotelViewAnimationType =
  | 'cloud'
  | 'car'
  | 'boat'
  | 'train'
  | 'sailboat'
  | 'twinkle'
  | 'bubbles'
  | 'imageScroller'
  | 'swap';

/**
 * Animation definition for hotel view
 */
export interface HotelViewAnimation {
  /** Animation sprite ID prefix (e.g., "cloud_", "car_") */
  spritePrefix: string;
  /** Animation class to instantiate */
  animationType: HotelViewAnimationType;
  /** Optional configuration for the animation */
  config?: Record<string, unknown>;
}

/**
 * Regional hotel view configuration
 */
export interface RegionalHotelConfig {
  /** Region identifier */
  region: HotelRegion;
  /** List of animations to use in the hotel view */
  animations: HotelViewAnimation[];
  /** Swap animation class configuration */
  swapAnimations?: SwapAnimationConfig[];
  /** Visual asset identifier */
  visualId?: string;
}

/**
 * Swap animation configuration (palette/member frame swaps)
 */
export interface SwapAnimationConfig {
  /** Sprite to animate */
  spriteId: string;
  /** Animation type: member swap or palette swap */
  animType: 'memberSwap' | 'paletteSwap';
  /** Frame list (optional, will auto-detect if not specified) */
  frameList?: number[];
  /** Initial delay before animation starts */
  initDelay: number;
  /** Delay type for initial delay */
  initDelayType: 'fixed' | 'random';
  /** Delay between animation frames */
  animDelay: number;
  /** Delay type for animation delay */
  animDelayType: 'fixed' | 'random';
  /** Number of times to loop (0 = infinite) */
  animLoopCount: number;
}

/**
 * Entry configuration options
 */
export interface EntryConfig {
  /** Which login method to use */
  entryType: EntryType;

  /** Hotel region for hotel view animations */
  region: HotelRegion;

  /** SSO ticket for SSO login */
  ssoTicket?: string;

  /** Whether registration is disabled */
  registrationDisabled?: boolean;

  /** Quick login credentials (for development) */
  quickLogin?: {
    username: string;
    password: string;
  };

  /** Connection settings */
  connection: {
    host: string;
    port: number;
    id?: string;
  };

  /** Client version */
  clientVersion?: number;

  /** External variables URL */
  externalVarsUrl?: string;

  /** Figurepartlist URL */
  figurePartListUrl?: string;

  /** Whether room events are disabled */
  disableRoomEvents?: boolean;

  /** Whether to use wide entry bar (960px+) */
  useWideEntryBar?: boolean;

  /** Custom hotel view animations override */
  customAnimations?: HotelViewAnimation[];
}

/**
 * Default regional configurations
 */
export const RegionalConfigs: Record<HotelRegion, RegionalHotelConfig> = {
  default: {
    region: 'default',
    animations: [],
  },
  es: {
    region: 'es',
    animations: [
      { spritePrefix: 'cloud_', animationType: 'cloud' },
      { spritePrefix: 'car_', animationType: 'car' },
    ],
  },
  fr: {
    region: 'fr',
    animations: [
      { spritePrefix: 'cloud_', animationType: 'cloud' },
      { spritePrefix: 'car_', animationType: 'car' },
    ],
  },
  it: {
    region: 'it',
    animations: [
      { spritePrefix: 'cloud_', animationType: 'cloud' },
      { spritePrefix: 'car_', animationType: 'car' },
      { spritePrefix: 'boat_', animationType: 'boat' },
    ],
  },
  jp: {
    region: 'jp',
    animations: [
      { spritePrefix: 'cloud_', animationType: 'cloud' },
      { spritePrefix: 'car_', animationType: 'car' },
      { spritePrefix: 'train_', animationType: 'train' },
      { spritePrefix: 'bubbles_', animationType: 'bubbles' },
      { spritePrefix: 'scroller_', animationType: 'imageScroller' },
    ],
  },
  nl: {
    region: 'nl',
    animations: [
      { spritePrefix: 'cloud_', animationType: 'cloud' },
      { spritePrefix: 'car_', animationType: 'car' },
      { spritePrefix: 'train_', animationType: 'train' },
    ],
  },
  no: {
    region: 'no',
    animations: [
      { spritePrefix: 'cloud_', animationType: 'cloud' },
      { spritePrefix: 'car_', animationType: 'car' },
      { spritePrefix: 'sailboat_', animationType: 'sailboat' },
      { spritePrefix: 'twinkle_', animationType: 'twinkle' },
    ],
  },
  pl: {
    region: 'pl',
    animations: [
      { spritePrefix: 'cloud_', animationType: 'cloud' },
      { spritePrefix: 'car_', animationType: 'car' },
    ],
  },
  ru: {
    region: 'ru',
    animations: [
      { spritePrefix: 'cloud_', animationType: 'cloud' },
      { spritePrefix: 'car_', animationType: 'car' },
    ],
  },
  se: {
    region: 'se',
    animations: [
      { spritePrefix: 'cloud_', animationType: 'cloud' },
      { spritePrefix: 'car_', animationType: 'car' },
    ],
  },
  sg: {
    region: 'sg',
    animations: [
      { spritePrefix: 'cloud_', animationType: 'cloud' },
      { spritePrefix: 'boat_', animationType: 'boat' },
    ],
  },
  uk: {
    region: 'uk',
    animations: [
      { spritePrefix: 'cloud_', animationType: 'cloud' },
      { spritePrefix: 'car_', animationType: 'car' },
    ],
  },
  us: {
    region: 'us',
    animations: [
      { spritePrefix: 'cloud_', animationType: 'cloud' },
      { spritePrefix: 'car_', animationType: 'car' },
    ],
  },
};

/**
 * Hotel closing status values
 */
export enum HotelClosingStatus {
  Open = 0,
  Closing = 1,
  Closed = 2,
}

/**
 * Opening hours state
 */
export interface OpeningHoursState {
  hotelClosingStatus: HotelClosingStatus;
  hotelClosedDisconnectStatus: boolean;
  openHour?: number;
  openMinute?: number;
  minutesUntilClose?: number;
}

/**
 * Login state
 */
export interface LoginState {
  username: string;
  password: string;
  okToLogin: boolean;
  isConnecting: boolean;
  loginFailed: boolean;
  failureReason?: string;
}

/**
 * Session parameters from server
 */
export interface SessionParameters {
  coppa: boolean;
  strongCoppaRequired: boolean;
  voucher: boolean;
  parentEmailRequest: boolean;
  dateFormat: string;
  tutorialEnabled: number;
}

/**
 * User object from server
 */
export interface UserObject {
  userId: string;
  name: string;
  figure: string;
  sex: 'M' | 'F';
  customData: string;
  phTickets: number;
  phFigure: string;
  photoFilm: number;
  directMail: number;
}

/**
 * Crypto parameters from server
 */
export interface CryptoParameters {
  clientToServer: boolean;
  serverToClient: boolean;
}

/**
 * Opening hours message IDs
 */
export const OpeningHoursMessages = {
  AVAILABILITY_STATUS: 290,
  INFO_HOTEL_CLOSING: 291,
  INFO_HOTEL_CLOSED: 292,
  AVAILABILITY_TIME: 293,
  LOGIN_FAILED_HOTEL_CLOSED: 294,
} as const;

/**
 * Opening hours command IDs
 */
export const OpeningHoursCommands = {
  GET_AVAILABILITY_TIME: 212,
} as const;
