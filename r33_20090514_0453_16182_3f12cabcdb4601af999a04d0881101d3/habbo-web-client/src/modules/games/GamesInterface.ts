/**
 * Games Interface Class - UI handling
 *
 * Ported from: hh_games/Cast External ParentScript 2 - Games Interface Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { EventEmitter } from '../../core/events';
import {
  GameType,
  GameProps,
  TicTacToeProps,
  ChessProps,
  BattleShipProps,
  PokerProps,
  BattleShipCell,
  TICTACTOE_SQUARE_SIZE,
  CHESS_SQUARE_SIZE,
  BATTLESHIP_SQUARE_SIZE,
  parseChessPiece,
  chessPositionToCoords,
  coordsToChessPosition,
} from './types';
import { GamesComponent } from './GamesComponent';

/**
 * Games interface - handles game UI
 */
export class GamesInterface extends BaseObject {
  private events: EventEmitter = new EventEmitter();
  private windowTitle: string = 'GAME';
  private openWindow: string = '';
  private chessPieces: Record<string, string> = {};
  private chessWait: boolean = false;
  private battleShipMyBoardImg: ImageData | null = null;
  private pokerChangeCards: number[] = [];
  private myName: string = '';
  private pokerOpponentChange: number[][] = [[], [], []];

  construct(): void {
    super.construct();
    this.windowTitle = 'GAME';
  }

  deconstruct(): void {
    this.closeGame();
    super.deconstruct();
  }

  /**
   * Close game window
   */
  closeGame(): void {
    const component = this.getComponent() as GamesComponent | null;
    if (component) {
      component.sendGameClose();
    }
    this.events.emit('closeGame');
  }

  /**
   * Open game window
   */
  openGameWindow(windowName: GameType, props: GameProps): void {
    switch (windowName) {
      case 'TicTacToe':
        this.windowTitle = 'TicTacToe';
        this.openWindow = 'habbo_ttt_choose_side.window';
        this.chooseSideTicTacToe();
        break;

      case 'Chess':
        this.windowTitle = 'Chess';
        this.openWindow = 'habbo_chess_choose_side.window';
        this.chessWait = false;
        break;

      case 'BattleShip':
        this.windowTitle = 'BattleShip';
        this.openWindow = 'habbo_battleships_start.window';
        break;

      case 'Poker':
        this.windowTitle = 'Poker';
        this.openWindow = 'poker.window';
        break;
    }

    this.events.emit('openGameWindow', {
      windowName,
      windowTitle: this.windowTitle,
      view: this.openWindow,
      props,
    });
  }

  /**
   * Change window view
   */
  private changeWindowView(
    title: string,
    windowName: string,
    eventHandler: string
  ): void {
    this.windowTitle = title;
    this.openWindow = windowName;

    this.events.emit('changeWindowView', {
      title,
      windowName,
      eventHandler,
    });
  }

  // TicTacToe methods

  chooseSideTicTacToe(): void {
    this.drawGameBoardTicTacToe();
    this.events.emit('ticTacToeChooseSide');
  }

  startTicTacToe(gameProps: TicTacToeProps): void {
    this.changeWindowView(this.windowTitle, 'habbo_ttt.window', 'eventProcTicTacToe');
    this.drawGameBoardTicTacToe();

    const text = `${gameProps.player1.type} ${gameProps.player1.name}\n${gameProps.player2.type} ${gameProps.player2.name}`;
    this.events.emit('ticTacToeStart', { players: text });
  }

  updateTicTacToe(gameProps: TicTacToeProps): void {
    const text = `${gameProps.player1.type} ${gameProps.player1.name}\n${gameProps.player2.type} ${gameProps.player2.name}`;
    this.drawGameBoardTicTacToe(gameProps);
    this.events.emit('ticTacToeUpdate', { players: text });
  }

  drawGameBoardTicTacToe(gameProps?: TicTacToeProps): void {
    const board: Array<{ x: number; y: number; char: string }> = [];

    if (gameProps?.gameboard) {
      for (let i = 0; i < gameProps.gameboard.length; i++) {
        const char = gameProps.gameboard.charAt(i);
        if (char !== ' ') {
          const x = (i % 25) - 1;
          const y = Math.floor(i / 25);
          board.push({ x, y, char });
        }
      }
    }

    this.events.emit('ticTacToeDraw', { board });
  }

  selectedTypeTicTacToe(
    playerProps: { type: string; name: string },
    gameProps: TicTacToeProps
  ): void {
    const elemId = playerProps.type === 'x' ? 'x_player' : 'o_player';
    this.events.emit('ticTacToeSelectedType', {
      elemId,
      playerName: playerProps.name,
      players: `${gameProps.player1.type} ${gameProps.player1.name}\n${gameProps.player2.type} ${gameProps.player2.name}`,
    });
  }

  getTicTacToeSector(point: { x: number; y: number }): { x: number; y: number } {
    return {
      x: Math.floor(point.x / TICTACTOE_SQUARE_SIZE),
      y: Math.floor(point.y / TICTACTOE_SQUARE_SIZE),
    };
  }

  // Chess methods

  startChess(gameProps: ChessProps): void {
    this.changeWindowView(this.windowTitle, 'habbo_chess.window', 'eventProcChess');
    this.events.emit('chessStart');
  }

  updateChess(gameProps: ChessProps): void {
    this.setupChessPieces(gameProps);

    const text = `${gameProps.player1.type} ${gameProps.player1.name}\n${gameProps.player2.type} ${gameProps.player2.name}`;
    this.events.emit('chessUpdate', { players: text });
  }

  setupChessPieces(gameProps: ChessProps): void {
    if (!gameProps?.gameboard) return;

    this.chessPieces = {};
    const pieces: Array<{
      x: number;
      y: number;
      piece: string;
      color: string;
    }> = [];

    const words = gameProps.gameboard.split(' ');
    for (const word of words) {
      if (word.length === 5) {
        const pieceData = parseChessPiece(word);
        if (pieceData) {
          const coords = chessPositionToCoords(pieceData.position);
          const key = `${coords.x}${coords.y}`;
          this.chessPieces[key] = word;
          pieces.push({
            x: coords.x,
            y: coords.y,
            piece: pieceData.type,
            color: pieceData.color,
          });
        }
      }
    }

    this.events.emit('chessSetupPieces', { pieces });
  }

  getChessSector(point: { x: number; y: number }): string {
    const x = Math.floor(point.x / CHESS_SQUARE_SIZE);
    const y = Math.floor(point.y / CHESS_SQUARE_SIZE);
    return `${x}${y}`;
  }

  makeChessSectorEmpty(x: number, y: number): void {
    this.events.emit('chessClearSector', { x, y });
  }

  makeMoveChess(point: { x: number; y: number }, pieceData: string): boolean {
    const clickArea = this.getChessSector(point);
    const component = this.getComponent() as GamesComponent | null;

    if (this.chessPieces[clickArea]) {
      const mySide = component?.getMySideChess();
      if (
        mySide === this.chessPieces[clickArea].charAt(0) &&
        pieceData !== this.chessPieces[clickArea]
      ) {
        return false;
      }
    }

    const x = parseInt(clickArea.charAt(0), 10);
    const y = parseInt(clickArea.charAt(1), 10);
    const targetPos = coordsToChessPosition(x, y);
    const fromPos = pieceData.substring(3, 5);
    const move = `${fromPos} ${targetPos}`;

    if (component) {
      component.makeMoveChess(move);
    }

    this.chessWait = true;
    setTimeout(() => {
      this.chessWait = false;
    }, 500);

    return true;
  }

  // BattleShip methods

  showShipInfo(text: string): void {
    this.events.emit('battleShipShowInfo', { text });
  }

  placeShip(
    member: string,
    destRect: { x: number; y: number; width: number; height: number }
  ): void {
    this.events.emit('battleShipPlaceShip', { member, destRect });
  }

  getBattleShipSector(point: { x: number; y: number }): { x: number; y: number } {
    return {
      x: Math.floor(point.x / BATTLESHIP_SQUARE_SIZE),
      y: Math.floor(point.y / BATTLESHIP_SQUARE_SIZE),
    };
  }

  battleShipWaitOtherPlayer(): void {
    this.changeWindowView(
      this.windowTitle,
      'habbo_battleships_wait.window',
      'eventProcBattleShip'
    );
    this.events.emit('battleShipWait');
  }

  battleShipMyTurn(): void {
    if (this.openWindow !== 'habbo_battleships.window') {
      this.changeWindowView(
        this.windowTitle,
        'habbo_battleships.window',
        'eventProcBattleShip'
      );
    }
    this.battleShipShowTurnText(true);
    this.events.emit('battleShipMyTurn');
  }

  battleShipOtherPlayersTurn(): void {
    if (this.openWindow !== 'habbo_battleships.window') {
      this.changeWindowView(
        this.windowTitle,
        'habbo_battleships.window',
        'eventProcBattleShip'
      );
    }
    this.battleShipShowTurnText(false);
    this.events.emit('battleShipOtherTurn');
  }

  battleShipShowTurnText(myTurn: boolean): void {
    const text = myTurn ? 'Your turn!' : "The enemy's turn";
    this.events.emit('battleShipShowTurn', { text, myTurn });
  }

  battleShipShowStatusText(text: string): void {
    this.events.emit('battleShipShowStatus', { text });
  }

  battleShipGameEnd(text: string): void {
    this.changeWindowView(
      this.windowTitle,
      'habbo_battleships_end.window',
      'eventProcBattleShip'
    );
    this.events.emit('battleShipGameEnd', { text });
  }

  updateBattleShipBoard(boardData: BattleShipCell[]): void {
    this.events.emit('battleShipUpdateBoard', { boardData });
  }

  // Poker methods

  pokerShowStatusText(text: string, element: string): void {
    this.events.emit('pokerShowStatus', { text, element });
  }

  drawPokerCard(elemId: string, memberName: string): void {
    this.events.emit('pokerDrawCard', { elemId, memberName });
  }

  pokerMarkCards(): void {
    if (this.openWindow !== 'poker_cards.window') return;

    this.events.emit('pokerMarkCards', {
      opponentChange: this.pokerOpponentChange,
    });
  }

  hideChangeCards(): void {
    if (this.openWindow !== 'poker_cards.window') return;
    this.events.emit('pokerHideChangeCards');
  }

  changePokerWindow(view: string): void {
    this.changeWindowView(this.windowTitle, view, 'eventProcPoker');
  }

  pokerListMyCards(msg: string): void {
    const parts = msg.split('/');
    const props = parts[1]?.split(',') || [];

    const component = this.getComponent() as GamesComponent | null;
    if (component?.pOpenGameProps) {
      (component.pOpenGameProps as PokerProps).changeDone = props[0];
      (component.pOpenGameProps as PokerProps).amountChanged = props[1];
    }

    if (props[0] === '0') {
      this.pokerShowStatusText('Choose cards to change', 'poker_message');
    }

    const cards: string[] = [];
    for (let i = 2; i <= 6; i++) {
      const card = parts[i];
      if (card) {
        cards.push(card);
        this.drawPokerCard(`my_${i - 1}`, `game_${card}`);
      }
    }

    this.pokerMarkCards();
    this.events.emit('pokerMyCards', { cards });
  }

  pokerHandleOpponents(msg: string): void {
    // Would parse opponent data
    this.events.emit('pokerOpponents', { data: msg });
  }

  pokerChangeCards(msg: string): void {
    // Would parse card change data
    this.events.emit('pokerCardsChanged', { data: msg });
  }

  pokerRevealCards(msg: string): void {
    this.pokerOpponentChange = [[], [], []];
    this.changePokerWindow('poker_end.window');
    this.events.emit('pokerRevealCards', { data: msg });
  }

  pokerOpponentLeaves(name: string): void {
    this.events.emit('pokerOpponentLeaves', { name });
  }

  /**
   * Get events emitter
   */
  getEvents(): EventEmitter {
    return this.events;
  }

  /**
   * Handle UI events
   */
  handleEvent(event: string, elemId: string, param?: unknown): void {
    const component = this.getComponent() as GamesComponent | null;
    if (!component) return;

    switch (event) {
      // TicTacToe events
      case 'ttt_close':
        this.closeGame();
        break;
      case 'ttt_choose_x':
        component.chooseSideTicTacToe('X');
        break;
      case 'ttt_choose_o':
        component.chooseSideTicTacToe('O');
        break;
      case 'ttt_newgame':
        component.restartTicTacToe();
        break;
      case 'ttt_click':
        const tttSector = this.getTicTacToeSector(param as { x: number; y: number });
        component.makeMoveTicTacToe(tttSector.x, tttSector.y);
        break;

      // Chess events
      case 'chess_close':
        this.closeGame();
        break;
      case 'chess_white':
        component.chooseSideTicTacToe('w');
        break;
      case 'chess_black':
        component.chooseSideTicTacToe('b');
        break;
      case 'chess_newgame':
        this.changeWindowView(
          this.windowTitle,
          'habbo_chess_reset.window',
          'eventProcChess'
        );
        break;
      case 'chess_restart_yes':
        component.restartChess();
        break;
      case 'chess_restart_cancel':
        component.notRestartChess();
        break;
      case 'chess_email':
        component.sendChessByEmail();
        break;

      // BattleShip events
      case 'bs_close':
        this.closeGame();
        break;
      case 'bs_start':
        this.changeWindowView(
          this.windowTitle,
          'habbo_battleships_place.window',
          'eventProcBattleShip'
        );
        this.events.emit('battleShipStartPlacement');
        break;
      case 'bs_shoot':
        const bsSector = this.getBattleShipSector(param as { x: number; y: number });
        component.sendBattleShipShoot(bsSector.x, bsSector.y);
        break;
      case 'bs_newgame':
        component.restartBattleShip();
        break;

      // Poker events
      case 'poker_close':
        this.closeGame();
        break;
      case 'poker_newgame':
        this.pokerChangeCards = [];
        this.changePokerWindow('poker_cards.window');
        component.startPoker();
        break;
      case 'poker_card_click':
        const cardIndex = (param as { index: number }).index;
        const cardIdx = this.pokerChangeCards.indexOf(cardIndex);
        if (cardIdx !== -1) {
          this.pokerChangeCards.splice(cardIdx, 1);
          // Show card
        } else {
          this.pokerChangeCards.push(cardIndex);
          // Show back
        }
        break;
      case 'poker_ready':
        this.hideChangeCards();
        const cardList = this.pokerChangeCards.join(' ');
        component.pokerChangeCards(cardList);
        this.pokerChangeCards = [];
        break;
    }
  }
}
