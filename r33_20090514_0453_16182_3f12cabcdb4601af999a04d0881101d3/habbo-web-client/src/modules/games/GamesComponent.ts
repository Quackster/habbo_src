/**
 * Games Component Class - Game logic
 *
 * Ported from: hh_games/Cast External ParentScript 3 - Games Component Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { getVariable } from '../../core/VariableContainer';
import { getConnection, connectionExists } from '../../managers/ConnectionManager';
import {
  GameType,
  GameProps,
  TicTacToeProps,
  ChessProps,
  BattleShipProps,
  PokerProps,
  ItemMessage,
  BattleShipCell,
} from './types';
import { GamesInterface } from './GamesInterface';

/**
 * Games component - manages game state
 */
export class GamesComponent extends BaseObject {
  pOpenGameProps: GameProps | null = null;

  construct(): void {
    super.construct();
    this.pOpenGameProps = null;
  }

  deconstruct(): void {
    this.pOpenGameProps = null;
    super.deconstruct();
  }

  /**
   * Send game open message
   */
  sendGameOpen(): boolean {
    if (!this.pOpenGameProps?.id) {
      return false;
    }

    const connId = getVariable('connection.room.id') as string;
    if (!connectionExists(connId)) {
      return false;
    }

    const conn = getConnection(connId);
    if (conn) {
      conn.send('IIM', `${this.pOpenGameProps.id} OPEN`);
    }
    return true;
  }

  /**
   * Send game close message
   */
  sendGameClose(): boolean {
    if (!this.pOpenGameProps?.id) {
      return false;
    }

    const connId = getVariable('connection.room.id') as string;
    if (!connectionExists(connId)) {
      return false;
    }

    const conn = getConnection(connId);
    if (conn) {
      conn.send('IIM', `${this.pOpenGameProps.id} CLOSE`);
    }
    this.pOpenGameProps = null;
    return true;
  }

  /**
   * Open game board
   */
  openGameBoard(props: GameProps): void {
    this.pOpenGameProps = props;

    const iface = this.getInterface() as GamesInterface | null;
    if (!iface) return;

    switch (props.name) {
      case 'TicTacToe':
        (this.pOpenGameProps as TicTacToeProps).bothTypeChosen = false;
        (this.pOpenGameProps as TicTacToeProps).player1 = { type: '', name: '' };
        (this.pOpenGameProps as TicTacToeProps).player2 = { type: '', name: '' };
        if (this.sendGameOpen()) {
          this.openTicTacToe(this.pOpenGameProps as TicTacToeProps);
        }
        break;

      case 'Chess':
        if (this.sendGameOpen()) {
          this.openChess(this.pOpenGameProps as ChessProps);
        }
        break;

      case 'BattleShip':
        (this.pOpenGameProps as BattleShipProps).gameend = false;
        if (this.sendGameOpen()) {
          this.openBattleShip(this.pOpenGameProps as BattleShipProps);
        }
        break;

      case 'Poker':
        if (this.sendGameOpen()) {
          this.openPoker(this.pOpenGameProps as PokerProps);
        }
        break;

      default:
        console.error('Unknown game:', props.name);
    }
  }

  /**
   * Close game board
   */
  closeGameBoard(props: { name: GameType }): void {
    const iface = this.getInterface() as GamesInterface | null;
    if (iface) {
      iface.closeGame();
    }
    this.sendGameClose();
  }

  /**
   * Process item message from server
   */
  processItemMessage(msg: ItemMessage): void {
    if (!this.pOpenGameProps) return;

    const iface = this.getInterface() as GamesInterface | null;
    if (!iface) return;

    switch (this.pOpenGameProps.name) {
      case 'TicTacToe':
        this.processTicTacToeMessage(msg);
        break;

      case 'Chess':
        this.processChessMessage(msg);
        break;

      case 'BattleShip':
        this.processBattleShipMessage(msg);
        break;

      case 'Poker':
        this.processPokerMessage(msg);
        break;
    }
  }

  /**
   * Process TicTacToe messages
   */
  private processTicTacToeMessage(msg: ItemMessage): void {
    const props = this.pOpenGameProps as TicTacToeProps;
    const iface = this.getInterface() as GamesInterface | null;
    if (!iface) return;

    if (msg.command.includes('BOARDDATA')) {
      const lines = msg.data.split('\n');
      props.player1 = this.parsePlayerLine(lines[0]);
      props.player2 = this.parsePlayerLine(lines[1]);
      props.gameboard = lines.slice(2).join('\n');

      if (props.bothTypeChosen) {
        iface.updateTicTacToe(props);
      } else {
        iface.selectedTypeTicTacToe(props.player1, props);
        iface.selectedTypeTicTacToe(props.player2, props);
        iface.updateTicTacToe(props);
      }
    } else if (msg.command.includes('SELECTTYPE')) {
      props.mySelectedType = msg.command.split(' ')[1];
      iface.startTicTacToe(props);
    } else if (msg.command.includes('OPPONENTS')) {
      this.restartTicTacToe();
      const lines = msg.data.split('\n');
      props.player1 = this.parsePlayerLine(lines[0]);
      props.player2 = this.parsePlayerLine(lines[1]);
      iface.selectedTypeTicTacToe(props.player1, props);
      iface.selectedTypeTicTacToe(props.player2, props);
      props.bothTypeChosen = lines[0].length > 3 && lines[1].length > 3;
    } else if (msg.command.includes('TYPERESERVED')) {
      // Beep - type already taken
    }
  }

  /**
   * Process Chess messages
   */
  private processChessMessage(msg: ItemMessage): void {
    const props = this.pOpenGameProps as ChessProps;
    const iface = this.getInterface() as GamesInterface | null;
    if (!iface) return;

    if (msg.command.includes('SELECTTYPE')) {
      props.mySelectedType = msg.command.split(' ')[1];
      iface.startChess(props);
    } else if (msg.command.includes('PIECEDATA')) {
      if (!props.mySelectedType) return;

      const lines = msg.data.split('\n');
      props.player1 = this.parsePlayerLine(lines[0]);
      props.player2 = this.parsePlayerLine(lines[1]);
      props.gameboard = lines.slice(2).join(' ');
      iface.updateChess(props);
    } else if (msg.command.includes('TYPERESERVED')) {
      // Beep - type already taken
    }
  }

  /**
   * Process BattleShip messages
   */
  private processBattleShipMessage(msg: ItemMessage): void {
    const props = this.pOpenGameProps as BattleShipProps;
    const iface = this.getInterface() as GamesInterface | null;
    if (!iface) return;

    // Check for game end
    if (props.gameend) {
      const text = `WON! ${props.winner}`;
      iface.battleShipGameEnd(text);
      return;
    }

    if (msg.command.includes('TURN')) {
      if (!props.myTurnNum || props.gameend) return;
      if (props.shootstatus === 'HIT') return;

      if (msg.data.charAt(0) === props.myTurnNum) {
        props.myturn = true;
        iface.battleShipMyTurn();
        if (props.player1Data) {
          iface.updateBattleShipBoard(props.player1Data);
        }
      } else {
        props.myturn = false;
        iface.battleShipOtherPlayersTurn();
        if (props.player2Data) {
          iface.updateBattleShipBoard(props.player2Data);
        }
      }
    } else if (msg.command.includes('OPPONENTS')) {
      const lines = msg.data.split('\n');
      for (const line of lines) {
        const words = line.split(' ');
        // Would check against current user name
        props.myTurnNum = words[0];
      }
    } else if (msg.command.includes('BOTHCHOSEN')) {
      this.sendGameClose();
      iface.closeGame();
    } else if (msg.command.includes('HIT') || msg.command.includes('SINK')) {
      if (props.myturn) {
        props.shootstatus = 'HIT';
      }
      const text = props.shootstatus === 'HIT' ? 'A Hit!!!' : 'Toast!!!';
      iface.battleShipShowStatusText(text);
    } else if (msg.command.includes('HITTWICE')) {
      if (props.myturn) {
        props.shootstatus = msg.command;
      }
    } else if (msg.command.includes('MISS')) {
      if (props.myturn) {
        props.shootstatus = msg.command;
        iface.battleShipShowTurnText(false);
      }
      iface.battleShipShowStatusText('Miss !!!');
    } else if (msg.command.includes('GAMEEND')) {
      props.winner = msg.data.split(' ')[0];
      props.gameend = true;
    } else if (msg.command.includes('SITUATION')) {
      this.parseBattleShipSituation(msg.data);
    }
  }

  /**
   * Parse BattleShip situation data
   */
  private parseBattleShipSituation(data: string): void {
    const props = this.pOpenGameProps as BattleShipProps;
    const iface = this.getInterface() as GamesInterface | null;
    if (!iface) return;

    const lines = data.split('\n');
    const opponent1Data = lines[1] || '';
    const opponent2Data = lines[3] || '';

    props.player1Data = [];
    props.player2Data = [];

    for (let j = 0; j < 2; j++) {
      const s = j === 0 ? opponent1Data : opponent2Data;
      for (let i = 0; i < s.length; i++) {
        const y = Math.floor(i / 13);
        const x = i % 13;
        const char = s.charAt(i);

        const targetData = j !== parseInt(props.myTurnNum || '0', 10)
          ? props.player1Data
          : props.player2Data;

        switch (char) {
          case 'O':
            targetData.push({ x, y, type: 'miss' });
            break;
          case 'X':
            targetData.push({ x, y, type: 'hit' });
            break;
          case 'S':
            targetData.push({ x, y, type: 'sink' });
            break;
        }
      }
    }

    if (props.myturn) {
      iface.updateBattleShipBoard(props.player1Data);
    } else {
      iface.updateBattleShipBoard(props.player2Data);
    }
  }

  /**
   * Process Poker messages
   */
  private processPokerMessage(msg: ItemMessage): void {
    const iface = this.getInterface() as GamesInterface | null;
    if (!iface) return;

    if (msg.command.includes('YOURCARDS')) {
      iface.pokerListMyCards(msg.command);
    } else if (msg.command.includes('OPPONENTS')) {
      iface.pokerHandleOpponents(msg.data);
    } else if (msg.command.includes('CHANGED')) {
      iface.pokerChangeCards(msg.data);
    } else if (msg.command.includes('REVEALCARDS')) {
      iface.pokerRevealCards(msg.data);
    } else if (msg.command.includes('OPPONENT_LOGOUT')) {
      iface.pokerOpponentLeaves(msg.data.split(',')[0]);
    }
  }

  /**
   * Parse player line
   */
  private parsePlayerLine(line: string): { type: string; name: string } {
    const words = line.split(' ');
    return {
      type: words[0] || '',
      name: words[1] || '',
    };
  }

  // TicTacToe methods

  openTicTacToe(props: TicTacToeProps): void {
    const iface = this.getInterface() as GamesInterface | null;
    if (iface) {
      iface.openGameWindow('TicTacToe', props);
    }
  }

  chooseSideTicTacToe(side: string): boolean {
    if (!this.pOpenGameProps?.id || !side) return false;

    const connId = getVariable('connection.room.id') as string;
    if (!connectionExists(connId)) return false;

    const conn = getConnection(connId);
    if (conn) {
      conn.send('IIM', `${this.pOpenGameProps.id} CHOOSETYPE ${side}`);
    }
    return true;
  }

  makeMoveTicTacToe(x: number, y: number): boolean {
    const props = this.pOpenGameProps as TicTacToeProps;
    if (!props?.id || !props.mySelectedType) return false;

    const connId = getVariable('connection.room.id') as string;
    if (!connectionExists(connId)) return false;

    const conn = getConnection(connId);
    if (conn) {
      conn.send('IIM', `${props.id} SETSECTOR ${props.mySelectedType} ${x} ${y}`);
    }
    return true;
  }

  restartTicTacToe(): boolean {
    if (!this.pOpenGameProps?.id) return false;

    const connId = getVariable('connection.room.id') as string;
    if (!connectionExists(connId)) return false;

    const conn = getConnection(connId);
    if (conn) {
      conn.send('IIM', `${this.pOpenGameProps.id} RESTART`);
    }
    return true;
  }

  // Chess methods

  openChess(props: ChessProps): void {
    const iface = this.getInterface() as GamesInterface | null;
    if (iface) {
      iface.openGameWindow('Chess', props);
    }
  }

  makeMoveChess(move: string): boolean {
    if (!this.pOpenGameProps?.id) return false;

    const connId = getVariable('connection.room.id') as string;
    if (!connectionExists(connId)) return false;

    const conn = getConnection(connId);
    if (conn) {
      conn.send('IIM', `${this.pOpenGameProps.id} MOVEPIECE ${move}`);
    }
    return true;
  }

  sendChessByEmail(): boolean {
    if (!this.pOpenGameProps?.id) return false;

    const connId = getVariable('connection.room.id') as string;
    if (!connectionExists(connId)) return false;

    const conn = getConnection(connId);
    if (conn) {
      conn.send('IIM', `${this.pOpenGameProps.id} SENDHISTORY`);
    }
    return true;
  }

  restartChess(): boolean {
    if (!this.pOpenGameProps?.id) return false;

    const connId = getVariable('connection.room.id') as string;
    if (!connectionExists(connId)) return false;

    const iface = this.getInterface() as GamesInterface | null;
    if (iface) {
      iface.startChess(this.pOpenGameProps as ChessProps);
    }

    const conn = getConnection(connId);
    if (conn) {
      conn.send('IIM', `${this.pOpenGameProps.id} RESTART`);
    }
    return true;
  }

  notRestartChess(): void {
    const iface = this.getInterface() as GamesInterface | null;
    if (iface && this.pOpenGameProps) {
      iface.startChess(this.pOpenGameProps as ChessProps);
      iface.updateChess(this.pOpenGameProps as ChessProps);
    }
  }

  getMySideChess(): string | null {
    const props = this.pOpenGameProps as ChessProps;
    return props?.mySelectedType || null;
  }

  // BattleShip methods

  openBattleShip(props: BattleShipProps): void {
    const iface = this.getInterface() as GamesInterface | null;
    if (iface) {
      iface.openGameWindow('BattleShip', props);
    }
  }

  sendBattleShipPlaceShip(move: string): boolean {
    if (!this.pOpenGameProps?.id) return false;

    const connId = getVariable('connection.room.id') as string;
    if (!connectionExists(connId)) return false;

    const conn = getConnection(connId);
    if (conn) {
      conn.send('IIM', `${this.pOpenGameProps.id} PLACESHIP ${move}`);
    }
    return true;
  }

  restartBattleShip(): void {
    if (!this.pOpenGameProps) return;

    const tempProps: BattleShipProps = {
      id: this.pOpenGameProps.id,
      name: 'BattleShip',
      gameend: false,
    };

    this.sendGameClose();
    this.openGameBoard(tempProps);
  }

  sendBattleShipShoot(x: number, y: number): boolean {
    const props = this.pOpenGameProps as BattleShipProps;
    if (!props?.myturn || props.gameend) return false;
    if (!props.id) return false;

    const connId = getVariable('connection.room.id') as string;
    if (!connectionExists(connId)) return false;

    const conn = getConnection(connId);
    if (conn) {
      conn.send('IIM', `${props.id} SHOOT ${x} ${y}`);
    }
    return true;
  }

  // Poker methods

  openPoker(props: PokerProps): void {
    const iface = this.getInterface() as GamesInterface | null;
    if (iface) {
      iface.openGameWindow('Poker', props);
    }
  }

  startPoker(): boolean {
    if (!this.pOpenGameProps?.id) return false;

    const connId = getVariable('connection.room.id') as string;
    if (!connectionExists(connId)) return false;

    const conn = getConnection(connId);
    if (conn) {
      conn.send('IIM', `${this.pOpenGameProps.id} STARTOVER`);
    }
    return true;
  }

  restartPoker(): void {
    if (!this.pOpenGameProps) return;

    const tempProps: PokerProps = {
      id: this.pOpenGameProps.id,
      name: 'Poker',
    };

    this.sendGameClose();
    this.openGameBoard(tempProps);
  }

  pokerChangeCards(cards: string): boolean {
    if (!this.pOpenGameProps?.id) return false;

    const connId = getVariable('connection.room.id') as string;
    if (!connectionExists(connId)) return false;

    const conn = getConnection(connId);
    if (conn) {
      conn.send('IIM', `${this.pOpenGameProps.id} CHANGE ${cards}`);
    }
    return true;
  }
}
