/**
 * Games Module Types
 *
 * Ported from: hh_games/*.ls
 */

/**
 * Game types supported
 */
export type GameType = 'TicTacToe' | 'Chess' | 'BattleShip' | 'Poker';

/**
 * Player info for games
 */
export interface GamePlayer {
  type: string;  // 'x', 'o' for TicTacToe; 'w', 'b' for Chess
  name: string;
}

/**
 * Base game properties
 */
export interface BaseGameProps {
  id: string;
  name: GameType;
  data?: string;
}

/**
 * TicTacToe game properties
 */
export interface TicTacToeProps extends BaseGameProps {
  name: 'TicTacToe';
  bothTypeChosen: boolean;
  player1: GamePlayer;
  player2: GamePlayer;
  mySelectedType?: string;
  gameboard?: string;
}

/**
 * Chess game properties
 */
export interface ChessProps extends BaseGameProps {
  name: 'Chess';
  player1: GamePlayer;
  player2: GamePlayer;
  mySelectedType?: string;
  gameboard?: string;
}

/**
 * BattleShip hit type
 */
export type BattleShipHitType = 'miss' | 'hit' | 'sink';

/**
 * BattleShip board cell
 */
export interface BattleShipCell {
  x: number;
  y: number;
  type: BattleShipHitType;
}

/**
 * BattleShip game properties
 */
export interface BattleShipProps extends BaseGameProps {
  name: 'BattleShip';
  gameend: boolean;
  myTurnNum?: string;
  myturn?: boolean;
  shootstatus?: string;
  winner?: string;
  player1Data?: BattleShipCell[];
  player2Data?: BattleShipCell[];
}

/**
 * Poker card
 */
export type PokerCard = string;  // e.g., "h1" (hearts ace), "d10" (diamonds 10)

/**
 * Poker game properties
 */
export interface PokerProps extends BaseGameProps {
  name: 'Poker';
  changeDone?: string;
  amountChanged?: string;
  opponentList?: string[];
  myCards?: PokerCard[];
}

/**
 * Combined game props type
 */
export type GameProps = TicTacToeProps | ChessProps | BattleShipProps | PokerProps;

/**
 * Item message from server
 */
export interface ItemMessage {
  id: string;
  command: string;
  data: string;
}

/**
 * Games message IDs
 */
export const GamesMessages = {
  ITEM_MSG: 144,
  OPEN_GAMEBOARD: 145,
  CLOSE_GAMEBOARD: 146,
} as const;

/**
 * Games command IDs
 */
export const GamesCommands = {
  IIM: 117,  // Interactive item message
} as const;

/**
 * TicTacToe board size
 */
export const TICTACTOE_BOARD_SIZE = 25;
export const TICTACTOE_SQUARE_SIZE = 10;

/**
 * Chess board size
 */
export const CHESS_SQUARE_SIZE = 27;

/**
 * BattleShip board size
 */
export const BATTLESHIP_BOARD_WIDTH = 13;
export const BATTLESHIP_BOARD_HEIGHT = 13;
export const BATTLESHIP_SQUARE_SIZE = 19;

/**
 * Chess piece data
 * First char: color (w/b)
 * 2-3 chars: piece type (ki, qu, ro, bi, kn, pa)
 * 4-5 chars: position (a1-h8)
 */
export interface ChessPiece {
  color: 'w' | 'b';
  type: 'ki' | 'qu' | 'ro' | 'bi' | 'kn' | 'pa';
  position: string;  // e.g., "a1"
}

/**
 * Parse chess piece string
 */
export function parseChessPiece(pieceStr: string): ChessPiece | null {
  if (pieceStr.length !== 5) return null;

  return {
    color: pieceStr.charAt(0) as 'w' | 'b',
    type: pieceStr.substring(1, 3) as ChessPiece['type'],
    position: pieceStr.substring(3, 5),
  };
}

/**
 * Convert chess position to coordinates
 */
export function chessPositionToCoords(position: string): { x: number; y: number } {
  const x = position.charCodeAt(0) - 97;  // 'a' = 0
  const y = 8 - parseInt(position.charAt(1), 10);  // 8 = 0
  return { x, y };
}

/**
 * Convert coordinates to chess position
 */
export function coordsToChessPosition(x: number, y: number): string {
  return String.fromCharCode(97 + x) + (8 - y);
}
