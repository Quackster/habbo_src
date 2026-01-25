/**
 * Login Component Class - Business logic for login/connection
 *
 * Ported from: hh_entry/Cast External ParentScript 7 - Login Component Class.ls
 *              hh_entry_init/Cast External ParentScript 7 - Login Component Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { registerMessage, unregisterMessage, executeMessage } from '../../core/MessageBus';
import { session } from '../../core/Session';
import { getConnection, createConnection, removeConnection } from '../../managers/ConnectionManager';
import { getVariable, setVariable, variableExists } from '../../core/VariableContainer';
import { HabboConnection } from '../../network/HabboConnection';
import { EntryConfig, EntryType } from './types';

export class LoginComponent extends BaseObject {
  private config: EntryConfig | null = null;
  private okToLogin: boolean = false;

  /**
   * Configure the login component
   */
  configure(config: EntryConfig): void {
    this.config = config;

    // Apply connection config to variables
    setVariable('connection.info.host', config.connection.host);
    setVariable('connection.info.port', config.connection.port);
    setVariable('connection.info.id', config.connection.id ?? 'Info');

    if (config.clientVersion) {
      setVariable('client.version.id', config.clientVersion);
    }
  }

  construct(): void {
    super.construct();

    // Create helper objects
    if (variableExists('stats.tracking.javascript')) {
      // createObject('statsBrokerJs', 'Statistics Broker Javascript Class');
    }
    if (variableExists('stats.tracking.url')) {
      // createObject('statsBroker', 'Statistics Broker Class');
    }

    // Initialize session user rights
    session.set('user_rights', []);

    // Set quick login variable
    if (!variableExists('quickLogin')) {
      setVariable('quickLogin', 0);
    }

    // Register for messages
    registerMessage('Initialize', this.id, 'initA');
    registerMessage('openConnection', this.id, 'openConnection');
    registerMessage('closeConnection', this.id, 'disconnect');
    registerMessage('performLogin', this.id, 'sendLogin');
    registerMessage('loginIsOk', this.id, 'setLoginOk');
  }

  deconstruct(): void {
    this.okToLogin = false;

    unregisterMessage('openConnection', this.id);
    unregisterMessage('closeConnection', this.id);

    const connId = getVariable('connection.info.id', 'Info') as string;
    if (getConnection(connId)) {
      this.disconnect();
    }

    super.deconstruct();
  }

  /**
   * Initialization phase A - wait for figure data
   */
  initA(): void {
    const figurePartListLoaded = getVariable('figurepartlist.loaded', 1) as number;
    if (figurePartListLoaded === 0) {
      setTimeout(() => this.initA(), 250);
      return;
    }
    setTimeout(() => this.initB(), 1000);
  }

  /**
   * Initialization phase B - check login type and proceed
   */
  initB(): void {
    const entryType = this.config?.entryType ?? 'auto';

    // Check for SSO
    if (entryType === 'sso' || entryType === 'auto') {
      const useSSO = variableExists('use.sso.ticket') && getVariable('use.sso.ticket');
      if (useSSO) {
        const ssoTicket = this.config?.ssoTicket ?? getVariable('sso.ticket') as string;
        if (ssoTicket && ssoTicket.length > 1) {
          session.set('SSO_ticket', ssoTicket);
          this.openConnection();
          return;
        }
      }

      if (entryType === 'sso') {
        executeMessage('alert', { Msg: 'Alert_generic_login_error' });
        return;
      }
    }

    // Check for quick login (development)
    if (entryType === 'quickLogin' || this.config?.quickLogin) {
      if (this.config?.quickLogin) {
        session.set('userName', this.config.quickLogin.username);
        session.set('Password', this.config.quickLogin.password);
        this.okToLogin = true;
        this.connect();
        return;
      }
    }

    // Show login interface
    const loginInterface = this.getInterface();
    if (loginInterface && typeof (loginInterface as Record<string, unknown>)['showLogin'] === 'function') {
      (loginInterface as { showLogin: () => boolean }).showLogin();
    }
  }

  /**
   * Send login credentials to server
   */
  sendLogin(connection?: HabboConnection): void {
    const conn = connection ?? getConnection(getVariable('connection.info.id', 'Info') as string);
    if (!conn) return;

    if (!this.okToLogin) {
      return;
    }

    // Check for SSO ticket
    const ssoTicket = session.GET<string>('SSO_ticket');
    if (ssoTicket) {
      // SSO login
      conn.send('SSO', { string: ssoTicket });
    } else {
      // Credentials login
      const userName = session.GET<string>('userName');
      const password = session.GET<string>('Password');

      if (!userName || !password) {
        removeConnection(conn.getID());
        return;
      }

      conn.send('TRY_LOGIN', { string: userName, string2: password });
    }
  }

  /**
   * Open connection (used for SSO)
   */
  openConnection(): void {
    this.okToLogin = true;
    this.connect();
  }

  /**
   * Create connection to server
   */
  connect(): boolean {
    const host = this.config?.connection.host ?? getVariable('connection.info.host') as string;
    const port = this.config?.connection.port ?? getVariable('connection.info.port') as number;
    const connId = this.config?.connection.id ?? getVariable('connection.info.id', 'Info') as string;

    if (!host || !port) {
      console.error('LoginComponent: Server host/port data not found!');
      return false;
    }

    const connection = createConnection(connId, host, port);
    if (!connection) {
      console.error('LoginComponent: Failed to create connection!');
      return false;
    }

    return true;
  }

  /**
   * Disconnect from server
   */
  disconnect(): boolean {
    const connId = getVariable('connection.info.id', 'Info') as string;
    if (getConnection(connId)) {
      removeConnection(connId);
      return true;
    }
    console.warn('LoginComponent: Connection not found for disconnect');
    return false;
  }

  /**
   * Set allow login flag
   */
  setAllowLogin(): void {
    this.okToLogin = true;
  }

  /**
   * Set OK to login flag
   */
  setOkToLogin(value: boolean): void {
    this.okToLogin = value;
  }

  /**
   * Check if OK to login
   */
  isOkToLogin(): boolean {
    return this.okToLogin;
  }

  /**
   * Get the current configuration
   */
  getConfig(): EntryConfig | null {
    return this.config;
  }

  /**
   * Get entry type
   */
  getEntryType(): EntryType {
    return this.config?.entryType ?? 'auto';
  }
}
