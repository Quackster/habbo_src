/**
 * Games Interface Class - UI handling
 *
 * Ported from: hh_games/Cast External ParentScript 2 - Games Interface Class.ls
 */

import { BaseInterface } from '../../core/BaseInterface';
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
export class GamesInterface extends BaseInterface {
  private pWindowTitle: string = 'GAME';
  private pOpenWindow: string = '';
  private pChessPieces: Record<string, string> = {};
  private pChessWait: boolean = false;
  private pBattleShipMyBoardImg: ImageData | null = null;
  private pPokerChangeCards: number[] = [];
  private pMyName: string = '';
  private pPokerOpponentChange: number[][] = [[], [], []];

  construct(): void {
    super.construct();
    this.pWindowTitle = 'GAME';
  }

  deconstruct(): void {
    this.closeGame();
    super.deconstruct();
  }

  /**
   * Close game window
   *
   * Lingo: closeGame()
   */
  closeGame(): void {
    // Remove placer objects if exist
    // Would call: removeObject("battleShipPlacer"), removeObject("chessPlacer")

    if (this.windowExists(this.pWindowTitle)) {
      const component = this.getComponent() as GamesComponent | null;
      if (component) {
        component.sendGameClose();
      }
      this.removeWindow(this.pWindowTitle);
    }
  }

  /**
   * Open game window
   *
   * Lingo: openGameWindow(tWindowName, tProps)
   */
  async openGameWindow(windowName: GameType, props: GameProps): Promise<void> {
    switch (windowName) {
      case 'TicTacToe':
        this.pWindowTitle = 'TicTacToe';
        await this.changeWindowView(this.pWindowTitle, 'habbo_ttt_choose_side.window', 'eventProcTicTacToe');
        this.chooseSideTicTacToe();
        break;

      case 'Chess':
        this.pWindowTitle = 'Chess';
        await this.changeWindowView(this.pWindowTitle, 'habbo_chess_choose_side.window', 'eventProcChess');
        this.pChessWait = false;
        break;

      case 'BattleShip':
        this.pWindowTitle = 'BattleShip';
        await this.changeWindowView(this.pWindowTitle, 'habbo_battleships_start.window', 'eventProcBattleShip');
        break;

      case 'Poker':
        this.pWindowTitle = 'Poker';
        if (!this.windowExists(this.pWindowTitle)) {
          await this.changeWindowView(this.pWindowTitle, 'poker.window', 'eventProcPoker');
        } else {
          await this.changePokerWindow('poker.window');
        }
        break;
    }
  }

  /**
   * Change window view
   *
   * Lingo: ChangeWindowView(tWindowTitle, tWindowName, tEventProc, tX, tY)
   */
  private async changeWindowView(
    title: string,
    windowName: string,
    eventHandler: string,
    x?: number,
    y?: number
  ): Promise<void> {
    await this.createWindow(title, 'habbo_basic.window');

    if (this.windowExists(title)) {
      await this.mergeWindow(title, windowName);
      this.registerClientForWindow(title);
      this.registerWindowProcedure(title, eventHandler, 'mouseUp');
      this.registerWindowProcedure(title, eventHandler, 'keyDown');

      this.pWindowTitle = title;
      this.pOpenWindow = windowName;

      if (x !== undefined && y !== undefined) {
        this.moveWindow(title, x, y);
      } else {
        this.centerWindow(title);
      }
    }
  }

  // TicTacToe methods

  /**
   * Lingo: chooseSideTicTacToe()
   */
  chooseSideTicTacToe(): void {
    this.drawGameBoardTicTacToe();
    if (this.elementExists(this.pWindowTitle, 'choose_side_x')) {
      this.setText(this.pWindowTitle, 'choose_side_x', 'x');
    }
    if (this.elementExists(this.pWindowTitle, 'choose_side_o')) {
      this.setText(this.pWindowTitle, 'choose_side_o', 'o');
    }
  }

  /**
   * Lingo: StartTicTacToe(tGameProps)
   */
  async startTicTacToe(gameProps: TicTacToeProps): Promise<void> {
    if (!this.windowExists(this.pWindowTitle)) return;

    await this.changeWindowView(this.pWindowTitle, 'habbo_ttt.window', 'eventProcTicTacToe');
    this.drawGameBoardTicTacToe();

    const text = `${gameProps.player1.type} ${gameProps.player1.name}\n${gameProps.player2.type} ${gameProps.player2.name}`;
    if (this.elementExists(this.pWindowTitle, 'game_text1')) {
      this.setText(this.pWindowTitle, 'game_text1', text);
    }
  }

  /**
   * Lingo: updateTicTacToe(tGameProps)
   */
  updateTicTacToe(gameProps: TicTacToeProps): void {
    if (!this.windowExists(this.pWindowTitle)) return;

    if (!this.elementExists(this.pWindowTitle, 'game_text1')) return;

    const text = `${gameProps.player1.type} ${gameProps.player1.name}\n${gameProps.player2.type} ${gameProps.player2.name}`;
    this.setText(this.pWindowTitle, 'game_text1', text);
    this.drawGameBoardTicTacToe(gameProps);
  }

  /**
   * Lingo: drawGameBoardTicTacToe(tGameProps)
   */
  drawGameBoardTicTacToe(gameProps?: TicTacToeProps): void {
    if (!this.windowExists(this.pWindowTitle)) return;

    const elem = this.getElement(this.pWindowTitle, 'game_area');
    if (!elem) return;

    // Would feed board image: game_TicTacToe.board.real
    // Then draw pieces on top

    if (gameProps?.gameboard) {
      const tW = 25;
      for (let i = 0; i < gameProps.gameboard.length; i++) {
        const char = gameProps.gameboard.charAt(i);
        if (char.charCodeAt(0) !== 32) {
          // Not a space
          const x = (i % tW) - 1;
          const y = Math.floor(i / tW);
          this.drawTicTacToe(x, y, char);
        }
      }
    }
  }

  /**
   * Draw a TicTacToe piece
   */
  private drawTicTacToe(x: number, y: number, char: string): void {
    // Would draw game_TicTacToe.<char> at position
    // Using member image copy to buffer
  }

  /**
   * Lingo: selectedTypeTicTacToe(tPlayerProps, tGameProps)
   */
  selectedTypeTicTacToe(
    playerProps: { type: string; name: string },
    gameProps: TicTacToeProps
  ): void {
    if (!this.windowExists(this.pWindowTitle)) return;

    const elemId = playerProps.type === 'x' ? 'x_player' : 'o_player';
    if (this.elementExists(this.pWindowTitle, elemId)) {
      this.setText(this.pWindowTitle, elemId, playerProps.name);
    }
    if (this.elementExists(this.pWindowTitle, 'game_text1')) {
      const text = `${gameProps.player1.type} ${gameProps.player1.name}\n${gameProps.player2.type} ${gameProps.player2.name}`;
      this.setText(this.pWindowTitle, 'game_text1', text);
    }
  }

  /**
   * Lingo: getTicTacToeSector(tpoint)
   */
  getTicTacToeSector(point: { x: number; y: number }): { x: number; y: number } {
    return {
      x: Math.floor(point.x / TICTACTOE_SQUARE_SIZE),
      y: Math.floor(point.y / TICTACTOE_SQUARE_SIZE),
    };
  }

  // Chess methods

  /**
   * Lingo: startChess(tGameProps)
   */
  async startChess(gameProps: ChessProps): Promise<void> {
    if (!this.windowExists(this.pWindowTitle)) return;

    await this.changeWindowView(this.pWindowTitle, 'habbo_chess.window', 'eventProcChess');
  }

  /**
   * Lingo: updateChess(tGameProps)
   */
  updateChess(gameProps: ChessProps): void {
    if (!this.windowExists(this.pWindowTitle)) return;

    const elem = this.getElement(this.pWindowTitle, 'game_area');
    if (!elem) return;

    // Clear image and buffer
    this.clearImage(this.pWindowTitle, 'game_area');

    this.setupChessPieces(gameProps);

    if (this.elementExists(this.pWindowTitle, 'game_players')) {
      const text = `${gameProps.player1.type} ${gameProps.player1.name}\n${gameProps.player2.type} ${gameProps.player2.name}`;
      this.setText(this.pWindowTitle, 'game_players', text);
    }
  }

  /**
   * Lingo: setupChessPieces(tGameProps)
   */
  setupChessPieces(gameProps: ChessProps): void {
    if (!gameProps?.gameboard) return;

    this.pChessPieces = {};

    const words = gameProps.gameboard.split(' ');
    for (const word of words) {
      if (word.length === 5) {
        const pieceData = parseChessPiece(word);
        if (pieceData) {
          const coords = chessPositionToCoords(pieceData.position);
          const key = `${coords.x}${coords.y}`;
          this.pChessPieces[key] = word;
          this.drawChessPieces(coords.x, coords.y, `game_${word.substring(0, 3)}`);
        }
      }
    }
  }

  /**
   * Draw chess pieces
   */
  private drawChessPieces(x: number, y: number, memberName: string): void {
    // Would draw member image at board position
    // Using 27px square size
  }

  /**
   * Lingo: getChessSector(tpoint)
   */
  getChessSector(point: { x: number; y: number }): string {
    const x = Math.floor(point.x / CHESS_SQUARE_SIZE);
    const y = Math.floor(point.y / CHESS_SQUARE_SIZE);
    return `${x}${y}`;
  }

  /**
   * Lingo: makeChessSectorEmpty(tX, tY)
   */
  makeChessSectorEmpty(x: number, y: number): void {
    if (!this.windowExists(this.pWindowTitle)) return;

    const elem = this.getElement(this.pWindowTitle, 'game_area');
    if (!elem) return;

    // Would fill rect with white at position
    // tSquareSize = 27
  }

  /**
   * Lingo: makeMoveChess(tpoint, tPieceData)
   */
  makeMoveChess(point: { x: number; y: number }, pieceData: string): boolean {
    const clickArea = this.getChessSector(point);
    const component = this.getComponent() as GamesComponent | null;

    if (this.pChessPieces[clickArea]) {
      const mySide = component?.getMySideChess();
      if (
        mySide === this.pChessPieces[clickArea].charAt(0) &&
        pieceData !== this.pChessPieces[clickArea]
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

    // Draw piece at new position
    const memberName = `game_${pieceData.substring(0, 3)}`;
    this.drawChessPieces(x, y, memberName);

    this.pChessWait = true;
    this.createTimeout('chessWait', 500, 'waitMoveChess');

    return true;
  }

  /**
   * Lingo: waitMoveChess()
   */
  private waitMoveChess(): void {
    this.pChessWait = false;
  }

  // BattleShip methods

  /**
   * Lingo: showShipInfo(tText)
   */
  showShipInfo(text: string): void {
    if (!this.windowExists(this.pWindowTitle)) return;

    if (this.elementExists(this.pWindowTitle, 'game_battleships_text1')) {
      this.setText(this.pWindowTitle, 'game_battleships_text1', text);
    }
  }

  /**
   * Lingo: placeShip(tmember, tdestrect)
   */
  placeShip(
    member: string,
    destRect: { x: number; y: number; width: number; height: number }
  ): void {
    if (!this.windowExists(this.pWindowTitle)) return;

    const elem = this.getElement(this.pWindowTitle, 'game_area');
    if (!elem) return;

    // Would copy member image to buffer at destRect
  }

  /**
   * Lingo: getBattleShipSector(tpoint)
   */
  getBattleShipSector(point: { x: number; y: number }): { x: number; y: number } {
    return {
      x: Math.floor(point.x / BATTLESHIP_SQUARE_SIZE),
      y: Math.floor(point.y / BATTLESHIP_SQUARE_SIZE),
    };
  }

  /**
   * Lingo: battleShipWaitOtherPlayer()
   */
  async battleShipWaitOtherPlayer(): Promise<void> {
    // Save current board image
    const elem = this.getElement(this.pWindowTitle, 'game_area');
    if (elem) {
      // Would duplicate: pBattleShipMyBoardImg = elem.image.duplicate()
    }

    await this.changeWindowView(
      this.pWindowTitle,
      'habbo_battleships_wait.window',
      'eventProcBattleShip'
    );
  }

  /**
   * Lingo: battleShipMyTurn()
   */
  async battleShipMyTurn(): Promise<void> {
    if (this.pOpenWindow !== 'habbo_battleships.window') {
      await this.changeWindowView(
        this.pWindowTitle,
        'habbo_battleships.window',
        'eventProcBattleShip'
      );
    }

    if (!this.windowExists(this.pWindowTitle)) return;

    const elem = this.getElement(this.pWindowTitle, 'game_area');
    if (elem) {
      // Would clear buffer and image
      this.clearImage(this.pWindowTitle, 'game_area');
    }

    this.battleShipShowTurnText(true);
  }

  /**
   * Lingo: battleShipOtherPlayersTurn()
   */
  async battleShipOtherPlayersTurn(): Promise<void> {
    if (this.pOpenWindow !== 'habbo_battleships.window') {
      await this.changeWindowView(
        this.pWindowTitle,
        'habbo_battleships.window',
        'eventProcBattleShip'
      );
    }

    if (!this.windowExists(this.pWindowTitle)) return;

    const elem = this.getElement(this.pWindowTitle, 'game_area');
    if (elem) {
      // Would clear and copy saved board image
      this.clearImage(this.pWindowTitle, 'game_area');
      // Would copy pBattleShipMyBoardImg to buffer
    }

    this.battleShipShowTurnText(false);
  }

  /**
   * Lingo: battleShipShowTurnText(tMyTurn)
   */
  battleShipShowTurnText(myTurn: boolean): void {
    if (!this.windowExists(this.pWindowTitle)) return;

    if (!this.elementExists(this.pWindowTitle, 'game_battleships_text1')) return;
    if (!this.elementExists(this.pWindowTitle, 'game_battleships_text2')) return;

    const text = myTurn ? 'Your turn!' : "The enemy's turn";
    this.setText(this.pWindowTitle, 'game_battleships_text1', text);
    this.setText(this.pWindowTitle, 'game_battleships_text2', '');
  }

  /**
   * Lingo: battleShipShowStatusText(tText)
   */
  battleShipShowStatusText(text: string): void {
    if (!this.windowExists(this.pWindowTitle)) return;

    if (this.elementExists(this.pWindowTitle, 'game_battleships_text2')) {
      this.setText(this.pWindowTitle, 'game_battleships_text2', text);
    }
  }

  /**
   * Lingo: battleShipGameEnd(tText)
   */
  async battleShipGameEnd(text: string): Promise<void> {
    if (!this.windowExists(this.pWindowTitle)) return;

    await this.changeWindowView(
      this.pWindowTitle,
      'habbo_battleships_end.window',
      'eventProcBattleShip'
    );

    if (this.elementExists(this.pWindowTitle, 'game_winner')) {
      this.setText(this.pWindowTitle, 'game_winner', text);
    }
  }

  /**
   * Lingo: updateBattleShipBoard(tBoardData)
   */
  updateBattleShipBoard(boardData: BattleShipCell[]): void {
    if (!boardData) return;
    if (!this.windowExists(this.pWindowTitle)) return;

    const elem = this.getElement(this.pWindowTitle, 'game_area');
    if (!elem) return;

    const tSquareSize = 19;

    for (const shoot of boardData) {
      const { x, y, type } = shoot;
      // Would draw game_bs_<type> at position
      // Different positioning for miss vs hit
    }
  }

  // Poker methods

  /**
   * Lingo: PokerShowStatusText(tText, tElement)
   */
  pokerShowStatusText(text: string, element: string): void {
    if (!this.windowExists(this.pWindowTitle)) return;

    if (this.elementExists(this.pWindowTitle, element)) {
      this.setText(this.pWindowTitle, element, text);
    }
  }

  /**
   * Lingo: drawPokerCard(tElem, tMemName)
   */
  drawPokerCard(elemId: string, memberName: string): void {
    if (!this.windowExists(this.pWindowTitle)) return;

    if (this.elementExists(this.pWindowTitle, elemId)) {
      // Would feed member image to element
      // tImg = member(memberName).image.duplicate()
      // elem.feedImage(tImg)
    }
  }

  /**
   * Lingo: pokerMarkCards()
   */
  pokerMarkCards(): void {
    if (this.pOpenWindow !== 'poker_cards.window') return;
    if (!this.windowExists(this.pWindowTitle)) return;

    const component = this.getComponent() as GamesComponent | null;
    const oppCount = (component?.pOpenGameProps as PokerProps)?.opponentList?.length || 0;
    const tList = this.pPokerOpponentChange;
    const cardBack = 'game_small_back_0';

    for (let i = 0; i < oppCount; i++) {
      for (let e = 1; e <= 5; e++) {
        const elemId = `player_${i + 1}_${e}`;
        if (tList[i] && tList[i].includes(e)) {
          this.fitOpponentCards(elemId, 'game_small_back_1');
        } else {
          this.fitOpponentCards(elemId, cardBack);
        }
      }
    }
  }

  /**
   * Lingo: fitOpponentCards(tElemID, tImage)
   */
  private fitOpponentCards(elemId: string, imageName: string): void {
    if (!this.windowExists(this.pWindowTitle)) return;

    if (this.elementExists(this.pWindowTitle, elemId)) {
      // Would copy and scale image to element
    }
  }

  /**
   * Lingo: hideChangeCards()
   */
  hideChangeCards(): void {
    if (this.pOpenWindow !== 'poker_cards.window') return;
    if (!this.windowExists(this.pWindowTitle)) return;

    if (this.elementExists(this.pWindowTitle, 'poker_ready')) {
      this.setElementProperty(this.pWindowTitle, 'poker_ready', 'visible', false);
    }
  }

  /**
   * Lingo: changePokerWindow(tView)
   */
  async changePokerWindow(view: string): Promise<void> {
    if (!this.windowExists(this.pWindowTitle)) return;

    const posX = this.getWindowProperty(this.pWindowTitle, 'locX') as number;
    const posY = this.getWindowProperty(this.pWindowTitle, 'locY') as number;

    await this.changeWindowView(this.pWindowTitle, view, 'eventProcPoker', posX, posY);
  }

  /**
   * Lingo: PokerListMyCards(tMsg)
   */
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

    for (let i = 2; i <= 6; i++) {
      const card = parts[i];
      if (card) {
        if (component?.pOpenGameProps) {
          (component.pOpenGameProps as any)[`my_${i - 1}`] = card;
        }
        this.drawPokerCard(`my_${i - 1}`, `game_${card}`);
      }
    }

    this.pokerMarkCards();
  }

  /**
   * Lingo: PokerHandleOpponents(tMsg)
   */
  pokerHandleOpponents(msg: string): void {
    // Would parse opponent data and update UI
  }

  /**
   * Lingo: pokerChangeCards(tMsg)
   */
  pokerChangeCardsMsg(msg: string): void {
    // Would parse card change data
  }

  /**
   * Lingo: PokerRevealCards(tMsg)
   */
  async pokerRevealCards(msg: string): Promise<void> {
    this.pPokerOpponentChange = [[], [], []];
    await this.changePokerWindow('poker_end.window');
    // Would parse and display revealed cards
  }

  /**
   * Lingo: PokerOpponentLeaves(tName)
   */
  pokerOpponentLeaves(name: string): void {
    const component = this.getComponent() as GamesComponent | null;
    const oppList = (component?.pOpenGameProps as PokerProps)?.opponentList || [];
    const playerNum = oppList.indexOf(name);

    if (playerNum >= 0) {
      this.removeOpponentCards(playerNum + 1);
      const text = `${name}\nLeft the game`;
      this.pokerShowStatusText(text, `poker_player_${playerNum + 1}`);
    }
  }

  /**
   * Lingo: RemoveOpponentCards(tOpponentNum)
   */
  private removeOpponentCards(opponentNum: number): void {
    if (this.pOpenWindow !== 'poker_cards.window') return;
    if (!this.windowExists(this.pWindowTitle)) return;

    for (let i = 1; i <= 5; i++) {
      const elemId = `player_${opponentNum}_${i}`;
      if (this.elementExists(this.pWindowTitle, elemId)) {
        this.clearImage(this.pWindowTitle, elemId);
      }
    }
  }

  /**
   * TicTacToe event procedure
   *
   * Lingo: eventProcTicTacToe(tEvent, tElemID, tParam)
   */
  eventProcTicTacToe(event: string, elemId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    const component = this.getComponent() as GamesComponent | null;
    if (!component) return;

    switch (elemId) {
      case 'close':
        this.closeGame();
        break;
      case 'choose_side_x':
        component.chooseSideTicTacToe('X');
        break;
      case 'choose_side_o':
        component.chooseSideTicTacToe('O');
        break;
      case 'game_newgame':
        component.restartTicTacToe();
        break;
      case 'game_area':
        const sector = this.getTicTacToeSector(param as { x: number; y: number });
        component.makeMoveTicTacToe(sector.x, sector.y);
        break;
    }
  }

  /**
   * Chess event procedure
   *
   * Lingo: eventProcChess(tEvent, tElemID, tParam)
   */
  eventProcChess(event: string, elemId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    const component = this.getComponent() as GamesComponent | null;
    if (!component) return;

    switch (elemId) {
      case 'close':
        // Would remove chessPlacer object
        this.closeGame();
        break;
      case 'chess_white':
        component.chooseSideTicTacToe('w');
        break;
      case 'chess_black':
        component.chooseSideTicTacToe('b');
        break;
      case 'game_area':
        if (this.pChessWait) return;
        const clickArea = this.getChessSector(param as { x: number; y: number });
        if (!this.pChessPieces[clickArea]) return;
        // Would create chessPlacer for drag
        break;
      case 'game_chess_newgame':
        if (!this.windowExists(this.pWindowTitle)) return;
        // Would remove chessPlacer object
        this.changeWindowView(this.pWindowTitle, 'habbo_chess_reset.window', 'eventProcChess');
        break;
      case 'game_restart_yes':
        component.restartChess();
        break;
      case 'game_restart_cancel':
        component.notRestartChess();
        break;
      case 'game_chess_email':
        component.sendChessByEmail();
        break;
    }
  }

  /**
   * BattleShip event procedure
   *
   * Lingo: eventProcBattleShip(tEvent, tElemID, tParam)
   */
  eventProcBattleShip(event: string, elemId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    const component = this.getComponent() as GamesComponent | null;
    if (!component) return;

    switch (elemId) {
      case 'close':
      case 'game_close':
        // Would remove battleShipPlacer object
        this.closeGame();
        break;
      case 'setships_ok':
        this.changeWindowView(
          this.pWindowTitle,
          'habbo_battleships_place.window',
          'eventProcBattleShip'
        );
        // Would create battleShipPlacer object
        break;
      case 'game_battleships_turn':
        // Would call battleShipPlacer.turnShip()
        break;
      case 'game_area':
        const sector = this.getBattleShipSector(param as { x: number; y: number });
        component.sendBattleShipShoot(sector.x, sector.y);
        break;
      case 'game_newgame':
        component.restartBattleShip();
        break;
    }
  }

  /**
   * Poker event procedure
   *
   * Lingo: eventProcPoker(tEvent, tElemID, tParam)
   */
  eventProcPoker(event: string, elemId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    const component = this.getComponent() as GamesComponent | null;
    if (!component) return;

    switch (elemId) {
      case 'close':
        this.closeGame();
        break;
      case 'game_newgame':
        this.pPokerChangeCards = [];
        this.changePokerWindow('poker_cards.window');
        component.startPoker();
        this.pokerShowStatusText('POKER', 'poker_text1');
        this.pokerShowStatusText('Start a new game', 'poker_start');
        break;
      case 'my_1':
      case 'my_2':
      case 'my_3':
      case 'my_4':
      case 'my_5':
        const changeDone = (component.pOpenGameProps as PokerProps)?.changeDone;
        if (changeDone === '0') {
          const myCard = parseInt(elemId.charAt(elemId.length - 1), 10) - 1;
          const cardSearch = this.pPokerChangeCards.indexOf(myCard);
          if (cardSearch !== -1) {
            this.pPokerChangeCards.splice(cardSearch, 1);
            const cardName = (component.pOpenGameProps as any)[elemId];
            this.drawPokerCard(elemId, `game_${cardName}`);
          } else {
            this.pPokerChangeCards.push(myCard);
            this.drawPokerCard(elemId, 'game_BACKSIDE');
          }
        }
        break;
      case 'poker_ready':
        const changeDoneReady = (component.pOpenGameProps as PokerProps)?.changeDone;
        if (changeDoneReady === '0') {
          this.hideChangeCards();
          const cardList = this.pPokerChangeCards.join(' ');
          component.pokerChangeCards(cardList);
          this.pPokerChangeCards = [];

          const oppList = (component.pOpenGameProps as PokerProps)?.opponentList || [];
          if (oppList.length > 0) {
            this.pokerShowStatusText('Waiting for opponents', 'poker_message');
          } else {
            this.pokerShowStatusText('Cards changed', 'poker_message');
          }
        }
        break;
    }
  }
}
