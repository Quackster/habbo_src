/**
 * Games Module - In-room mini-games
 *
 * Ported from: hh_games/*.ls
 *
 * This module provides:
 * - TicTacToe game with side selection
 * - Chess game with piece movement
 * - BattleShip game with ship placement and shooting
 * - Poker game with card selection
 * - Game board communication with server
 *
 * Usage:
 * ```typescript
 * import { createGamesModule } from './modules/games';
 *
 * const games = createGamesModule();
 * games.initialize();
 *
 * // Listen for events
 * games.interface.getEvents().on('openGameWindow', (data) => {
 *   console.log('Opening game:', data.windowName);
 * });
 *
 * // Handle UI events
 * games.interface.handleEvent('ttt_choose_x', 'choose_side_x');
 *
 * // Clean up
 * games.destroy();
 * ```
 */

// Types
export * from './types';

// Core Components
export { GamesComponent } from './GamesComponent';
export { GamesInterface } from './GamesInterface';
export { GamesHandler } from './GamesHandler';

// Imports for factory function
import { GamesComponent } from './GamesComponent';
import { GamesInterface } from './GamesInterface';
import { GamesHandler } from './GamesHandler';

/**
 * Games module instance
 */
export interface GamesModule {
  component: GamesComponent;
  interface: GamesInterface;
  handler: GamesHandler;

  initialize(): void;
  destroy(): void;
}

/**
 * Create games module
 */
export function createGamesModule(): GamesModule {
  const component = new GamesComponent();
  const iface = new GamesInterface();
  const handler = new GamesHandler();

  // Set up ICH relationships
  component.setInterface(iface);
  iface.setComponent(component);
  handler.setInterface(iface);
  handler.setComponent(component);

  return {
    component,
    interface: iface,
    handler,

    initialize(): void {
      component.construct();
      iface.construct();
      handler.construct();
    },

    destroy(): void {
      handler.deconstruct();
      iface.deconstruct();
      component.deconstruct();
    },
  };
}
