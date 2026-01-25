/**
 * Registration Module Types
 *
 * Ported from: hh_registrat/*.ls
 */

/**
 * Registration mode
 */
export type RegistrationMode =
  | 'registration'
  | 'update'
  | 'forced'
  | 'parent_email'
  | 'parent_email_strong_coppa'
  | 'parent_email_forced'
  | 'parent_email_coppa_forced'
  | 'coppa_forced';

/**
 * Registration state
 */
export type RegistrationState =
  | 'reset'
  | 'loadFigurePartList'
  | 'initialize'
  | 'start'
  | 'openFigureCreator'
  | 'openFigureUpdate'
  | 'openForcedUpdate';

/**
 * Registration message structure for server communication
 */
export interface RegistrationMessageStruct {
  id: number;
  type: 'boolean' | 'string' | 'short';
}

/**
 * Registration message fields
 */
export const RegistrationFields: Record<string, RegistrationMessageStruct> = {
  parentagree: { id: 1, type: 'boolean' },
  name: { id: 2, type: 'string' },
  password: { id: 3, type: 'string' },
  figure: { id: 4, type: 'string' },
  sex: { id: 5, type: 'string' },
  customData: { id: 6, type: 'string' },
  email: { id: 7, type: 'string' },
  birthday: { id: 8, type: 'string' },
  directMail: { id: 9, type: 'boolean' },
  has_read_agreement: { id: 10, type: 'boolean' },
  isp_id: { id: 11, type: 'string' },
  partnersite: { id: 12, type: 'string' },
  oldpassword: { id: 13, type: 'string' },
};

/**
 * Props to send to server
 */
export interface RegistrationProps {
  parentagree?: boolean | number;
  name?: string;
  password?: string;
  figure?: Record<string, FigurePartData> | string;
  sex?: 'M' | 'F';
  customData?: string;
  email?: string;
  birthday?: string;
  directMail?: string | boolean;
  has_read_agreement?: string | boolean;
  isp_id?: string;
  partnersite?: string;
  oldpassword?: string;
}

/**
 * Figure part data
 */
export interface FigurePartData {
  model: string;
  color: string;
  setid?: number;
  colorid?: number;
}

/**
 * Name approval result codes
 */
export const NameApprovalResult = {
  OK: 0,
  TOO_LONG: 1,
  UNACCEPTABLE: 2,
  UNACCEPTABLE_CHARS: 3,
  ALREADY_RESERVED: 4,
} as const;

/**
 * Password validation result codes
 */
export const PasswordValidationResult = {
  OK: 0,
  TOO_SHORT: 1,
  TOO_LONG: 2,
  INVALID_CHARS: 3,
  NO_NUMBER: 4,
  TOO_SIMILAR_TO_NAME: 5,
} as const;

/**
 * Account update status codes
 */
export const AccountUpdateStatus = {
  SUCCESS: '0',
  INCORRECT_PASSWORD: '1',
  INCORRECT_BIRTHDAY: '2',
} as const;

/**
 * Message IDs
 */
export const RegistrationMessages = {
  OK: 1,
  LOGIN_OK: 3,
  AVAILABLE_SETS: 8,
  APPROVE_NAME_REPLY: 36,
  NAME_UNACCEPTABLE: 37,
  REG_OK: 51,
  AGE_CHECK_RESULT: 164,
  UPDATE_OK: 211,
  RE_REGISTRATION_REQUIRED: 167,
  COPPA_CHECKTIME: 214,
  COPPA_GETREALTIME: 215,
  PARENT_EMAIL_REQUIRED: 217,
  PARENT_EMAIL_VALIDATED: 218,
  UPDATE_ACCOUNT: 169,
  EMAIL_APPROVED: 271,
  EMAIL_REJECTED: 272,
  UPDATE_REQUEST: 275,
  PASSWORD_APPROVED: 282,
} as const;

/**
 * Command IDs
 */
export const RegistrationCommands = {
  INFORETRIEVE: 7,
  GETAVAILABLESETS: 9,
  FINDUSER: 41,
  APPROVENAME: 42,
  REGISTER: 43,
  UPDATE: 44,
  AC: 46,
  COPPA_REG_CHECKTIME: 130,
  COPPA_REG_GETREALTIME: 131,
  PARENT_EMAIL_REQUIRED: 146,
  VALIDATE_PARENT_EMAIL: 147,
  SEND_PARENT_EMAIL: 148,
  UPDATE_ACCOUNT: 149,
  APPROVEEMAIL: 197,
  APPROVE_PASSWORD: 203,
} as const;

/**
 * Registration window types
 */
export type RegistrationWindow =
  | 'reg_loading.window'
  | 'reg_welcome.window'
  | 'reg_legal.window'
  | 'reg_namepage.window'
  | 'reg_namepage_mission.window'
  | 'reg_infopage.window'
  | 'reg_infopage_no_age.window'
  | 'reg_confirm.window'
  | 'reg_parent_email.window'
  | 'reg_age_check.window'
  | 'reg_done.window'
  | 'reg_info_update.window'
  | 'reg_coppa_forced.window'
  | 'reg_update_password.window'
  | 'reg_update_email.window'
  | 'reg_update_success.window'
  | 'reg_update_progress.window';

/**
 * Body part types for figure editor
 */
export type BodyPartType =
  | 'lh' | 'ls' | 'bd' | 'sh' | 'lg'
  | 'ch' | 'hd' | 'fc' | 'ey' | 'hr'
  | 'rh' | 'rs';

/**
 * Main editable body parts
 */
export const EDITABLE_PARTS: BodyPartType[] = ['hr', 'hd', 'ch', 'lg', 'sh'];

/**
 * All body parts
 */
export const ALL_BODY_PARTS: BodyPartType[] = [
  'lh', 'ls', 'bd', 'sh', 'lg', 'ch', 'hd', 'fc', 'ey', 'hr', 'rh', 'rs'
];

/**
 * Part change buttons state
 */
export interface PartChangeButtonState {
  partmodel: Record<string, number>;
  partcolor: Record<string, number>;
}

/**
 * Update account properties
 */
export interface UpdateAccountProps {
  currPwd?: string;
  newPwd?: string;
  day?: number;
  month?: number;
  year?: number;
}

/**
 * Default permitted characters
 */
export const DEFAULT_PERMITTED_NAME_CHARS = '1234567890qwertyuiopasdfghjklzxcvbnm_-=+?!@<>:.,';
export const DEFAULT_PERMITTED_PASSWORD_CHARS = DEFAULT_PERMITTED_NAME_CHARS;
export const DEFAULT_DENIED_NAME_CHARS = '_';
