/**
 * Habbo Web Client - Main Entry Point
 *
 * This is the browser equivalent of habbo.dcr which loads fuse_client
 * and then bootstraps all the module casts (hh_entry, hh_room, etc.)
 *
 * Architecture mirrors the original Director structure:
 *   habbo/ (entry) → fuse_client (core) → module casts (hh_*)
 */

import { loadWasmModules, isLoaded as wasmLoaded } from './wasm/wasmLoader';
import { objectManager } from './core/ObjectManager';
import { messageBus, executeMessage } from './core/MessageBus';
import { mainLoop } from './core/MainLoop';
import { session } from './core/Session';
import { setVariable, getVariable } from './core/VariableContainer';
import { threadManager } from './managers/ThreadManager';
import { connectionManager } from './managers/ConnectionManager';
import { resourceManager } from './managers/ResourceManager';

// Application state
let initialized = false;
let canvas: HTMLCanvasElement | null = null;
let ctx: CanvasRenderingContext2D | null = null;

/**
 * Initialize the Habbo client
 *
 * This mirrors the startMovie handler in habbo.dcr that calls
 * fuse_client's initialization routines
 */
export async function initHabbo(config: HabboConfig): Promise<boolean> {
  if (initialized) {
    console.warn('Habbo client already initialized');
    return true;
  }

  console.log('Habbo Web Client initializing...');

  try {
    // Phase 1: Load WASM modules (geometry, pathfinding)
    console.log('Loading WASM modules...');
    await loadWasmModules();

    // Phase 2: Initialize fuse_client core systems
    console.log('Initializing core systems...');
    initializeFuseClient(config);

    // Phase 3: Load external variables (equivalent to external_variables.txt)
    console.log('Loading configuration...');
    await loadExternalVariables(config.externalVariablesUrl);

    // Phase 4: Load texts (equivalent to external_texts.txt)
    if (config.externalTextsUrl) {
      console.log('Loading texts...');
      await loadExternalTexts(config.externalTextsUrl);
    }

    // Phase 5: Set up canvas/rendering
    console.log('Setting up rendering...');
    setupCanvas(config.containerId);

    // Phase 6: Load module casts (hh_entry, hh_room, etc.)
    console.log('Loading modules...');
    await loadModuleCasts(config);

    // Phase 7: Start the main loop
    console.log('Starting main loop...');
    mainLoop.start();

    // Phase 8: Initialize entry module (login flow)
    console.log('Initializing entry...');
    executeMessage('Initialize');

    initialized = true;
    console.log('Habbo Web Client initialized successfully');

    return true;
  } catch (error) {
    console.error('Failed to initialize Habbo client:', error);
    return false;
  }
}

/**
 * Initialize fuse_client core systems
 *
 * This sets up the Object Manager, Message Bus, Thread Manager,
 * Connection Manager, and Resource Manager
 */
function initializeFuseClient(config: HabboConfig): void {
  // Set core variables
  setVariable('client.version.id', config.clientVersion ?? 33);
  setVariable('connection.info.id', 'Info');
  setVariable('connection.host', config.serverHost ?? 'localhost');
  setVariable('connection.port', config.serverPort ?? 30000);

  // Set SSO ticket if provided
  if (config.ssoTicket) {
    session.set('sso.ticket', config.ssoTicket);
  }

  // Set user credentials if provided (for non-SSO login)
  if (config.username) {
    session.set('userName', config.username);
  }
  if (config.password) {
    session.set('Password', config.password);
  }

  // Register core message handlers
  messageBus.register('alert', 'system', 'handleAlert');
  messageBus.register('userloggedin', 'system', 'handleUserLoggedIn');

  console.log('Fuse client core initialized');
}

/**
 * Load external variables configuration
 */
async function loadExternalVariables(url?: string): Promise<void> {
  if (!url) {
    console.log('No external variables URL provided, using defaults');
    setDefaultVariables();
    return;
  }

  try {
    const response = await fetch(url);
    const text = await response.text();

    // Parse key=value pairs
    const lines = text.split('\n');
    for (const line of lines) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith('#') || trimmed.startsWith('//')) {
        continue;
      }

      const eqIndex = trimmed.indexOf('=');
      if (eqIndex > 0) {
        const key = trimmed.slice(0, eqIndex).trim();
        const value = trimmed.slice(eqIndex + 1).trim();
        setVariable(key, value);
      }
    }
  } catch (error) {
    console.warn('Failed to load external variables:', error);
    setDefaultVariables();
  }
}

/**
 * Set default variables when external config not available
 */
function setDefaultVariables(): void {
  setVariable('flash.client.url', '/habbo-imaging/');
  setVariable('furnidata.load.url', '/gamedata/furnidata.xml');
  setVariable('productdata.load.url', '/gamedata/productdata.txt');
  setVariable('figuredata.load.url', '/gamedata/figuredata.xml');
}

/**
 * Load external texts for localization
 */
async function loadExternalTexts(url: string): Promise<void> {
  try {
    const response = await fetch(url);
    const text = await response.text();

    // Parse key=value pairs (same format as variables)
    const lines = text.split('\n');
    for (const line of lines) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith('#')) continue;

      const eqIndex = trimmed.indexOf('=');
      if (eqIndex > 0) {
        const key = trimmed.slice(0, eqIndex).trim();
        const value = trimmed.slice(eqIndex + 1).trim();
        session.set(`text.${key}`, value);
      }
    }
  } catch (error) {
    console.warn('Failed to load external texts:', error);
  }
}

/**
 * Set up the rendering canvas
 */
function setupCanvas(containerId: string): void {
  const container = document.getElementById(containerId);
  if (!container) {
    throw new Error(`Container element '${containerId}' not found`);
  }

  // Create canvas
  canvas = document.createElement('canvas');
  canvas.id = 'habbo-canvas';
  canvas.width = 800;
  canvas.height = 600;
  canvas.style.display = 'block';

  container.appendChild(canvas);

  ctx = canvas.getContext('2d');
  if (!ctx) {
    throw new Error('Failed to get 2D context');
  }

  // Set up input handlers
  setupInputHandlers(canvas);

  // Store canvas reference
  session.set('canvas', canvas);
  session.set('context', ctx);
}

/**
 * Set up mouse and keyboard input handlers
 */
function setupInputHandlers(canvas: HTMLCanvasElement): void {
  // Mouse events
  canvas.addEventListener('mousedown', (e) => {
    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    executeMessage('mouseDown', { x, y, button: e.button });
  });

  canvas.addEventListener('mouseup', (e) => {
    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    executeMessage('mouseUp', { x, y, button: e.button });
  });

  canvas.addEventListener('mousemove', (e) => {
    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    executeMessage('mouseMove', { x, y });
  });

  canvas.addEventListener('click', (e) => {
    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    executeMessage('mouseClick', { x, y });
  });

  // Keyboard events
  document.addEventListener('keydown', (e) => {
    executeMessage('keyDown', { key: e.key, code: e.code, keyCode: e.keyCode });
  });

  document.addEventListener('keyup', (e) => {
    executeMessage('keyUp', { key: e.key, code: e.code, keyCode: e.keyCode });
  });

  // Focus handling
  canvas.tabIndex = 0;
  canvas.focus();
}

/**
 * Load module casts (equivalent to loading hh_entry, hh_room, etc.)
 */
async function loadModuleCasts(config: HabboConfig): Promise<void> {
  // Load entry module first (handles login)
  await threadManager.loadThread('entry', {
    Interface: (await import('./modules/entry')).EntryComponent,
    Component: (await import('./modules/entry')).EntryComponent,
    Handler: (await import('./modules/entry')).LoginHandler,
  });

  // Additional modules would be loaded here as they're ported:
  // await threadManager.loadThread('room', ...);
  // await threadManager.loadThread('navigator', ...);
  // await threadManager.loadThread('catalog', ...);
  // await threadManager.loadThread('messenger', ...);

  console.log('Module casts loaded');
}

/**
 * Connect to the Habbo server
 */
export function connect(): void {
  const host = getVariable('connection.host', 'localhost') as string;
  const port = getVariable('connection.port', 30000) as number;

  console.log(`Connecting to ${host}:${port}...`);

  const connId = getVariable('connection.info.id', 'Info') as string;
  connectionManager.create(connId, host, port);

  // Get the entry component and initialize connection
  const entryThread = threadManager.getThread('entry');
  if (entryThread?.component) {
    (entryThread.component as { initConnection: (h: string, p: number) => boolean }).initConnection(host, port);
  }
}

/**
 * Disconnect from the server
 */
export function disconnect(): void {
  const connId = getVariable('connection.info.id', 'Info') as string;
  const conn = connectionManager.get(connId);
  if (conn) {
    conn.disconnect(true);
  }
}

/**
 * Shutdown the client
 */
export function shutdown(): void {
  console.log('Shutting down Habbo client...');

  // Stop main loop
  mainLoop.stop();

  // Disconnect
  disconnect();

  // Clean up threads
  threadManager.unloadAll();

  // Clear canvas
  if (ctx && canvas) {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
  }

  initialized = false;
  console.log('Habbo client shut down');
}

/**
 * Configuration interface
 */
export interface HabboConfig {
  // Container element ID
  containerId: string;

  // Server connection
  serverHost?: string;
  serverPort?: number;

  // Authentication
  ssoTicket?: string;
  username?: string;
  password?: string;

  // Client version
  clientVersion?: number;

  // External configuration URLs
  externalVariablesUrl?: string;
  externalTextsUrl?: string;

  // Asset URLs
  assetBaseUrl?: string;
}

// Export core systems for module access
export { objectManager, messageBus, mainLoop, session, threadManager, connectionManager, resourceManager };
export { setVariable, getVariable } from './core/VariableContainer';
export { executeMessage, registerMessage, unregisterMessage } from './core/MessageBus';

// Auto-initialize if config is in global scope
declare global {
  interface Window {
    habboConfig?: HabboConfig;
    initHabbo?: typeof initHabbo;
    habbo?: {
      connect: typeof connect;
      disconnect: typeof disconnect;
      shutdown: typeof shutdown;
    };
  }
}

// Expose to window for script-based initialization
if (typeof window !== 'undefined') {
  window.initHabbo = initHabbo;
  window.habbo = {
    connect,
    disconnect,
    shutdown,
  };

  // Auto-init if config provided
  if (window.habboConfig) {
    initHabbo(window.habboConfig).then((success) => {
      if (success && window.habboConfig?.ssoTicket) {
        connect();
      }
    });
  }
}
