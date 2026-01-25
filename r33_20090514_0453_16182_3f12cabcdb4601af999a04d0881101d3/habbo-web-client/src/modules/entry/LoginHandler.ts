/**
 * Login Handler - Server message parsing for login flow
 *
 * Ported from: hh_entry/Cast External ParentScript 8 - Login Handler Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { HabboMessage } from '../../types';
import { session } from '../../core/Session';
import { executeMessage } from '../../core/MessageBus';
import { getConnection, registerListener, registerCommands, unregisterListener, unregisterCommands } from '../../managers/ConnectionManager';
import { getVariable } from '../../core/VariableContainer';
import { RC4Cipher } from '../../network/RC4Cipher';
import { HabboConnection } from '../../network/HabboConnection';

export class LoginHandler extends BaseObject {
  private cryptoParams: { ClientToServer: boolean; ServerToClient: boolean } = {
    ClientToServer: false,
    ServerToClient: false,
  };
  private publicKey: string = '';

  construct(): void {
    super.construct();
    this.registerMsg('hideLogin', 'hideLogin');
    this.regMsgList(true);
  }

  deconstruct(): void {
    unregisterMessage('hideLogin', this.id);
    this.regMsgList(false);
    super.deconstruct();
  }

  /**
   * Register/unregister message listeners and commands
   */
  private regMsgList(register: boolean): void {
    const connId = getVariable('connection.info.id', 'Info') as string;

    // Incoming message handlers
    const messages: Record<number, string> = {
      [-1]: 'handleDisconnect',
      [0]: 'handleHello',
      [1]: 'handleSecretKey',
      [2]: 'handleRights',
      [3]: 'handleLoginOK',
      [5]: 'handleUserObj',
      [33]: 'handleErr',
      [35]: 'handleUserBanned',
      [50]: 'handlePing',
      [52]: 'handleEPSnotify',
      [139]: 'handleSystemBroadcast',
      [141]: 'handleCheckSum',
      [161]: 'handleModAlert',
      [229]: 'handleAvailableBadges',
      [257]: 'handleSessionParameters',
      [277]: 'handleCryptoParameters',
      [278]: 'handleEndCrypto',
      [287]: 'handleHotelLogout',
      [308]: 'handleSoundSetting',
    };

    // Outgoing command IDs
    const commands: Record<string, number> = {
      TRY_LOGIN: 4,
      VERSIONCHECK: 5,
      UNIQUEID: 6,
      GET_INFO: 7,
      GET_CREDITS: 8,
      GET_PASSWORD: 47,
      LANGCHECK: 58,
      BTCKS: 105,
      GETAVAILABLEBADGES: 157,
      GET_SESSION_PARAMETERS: 181,
      PONG: 196,
      GENERATEKEY: 202,
      SSO: 204,
      INIT_CRYPTO: 206,
      SECRETKEY: 207,
      GET_SOUND_SETTING: 228,
      SET_SOUND_SETTING: 229,
    };

    if (register) {
      registerListener(connId, this.id, messages);
      registerCommands(connId, commands);
    } else {
      unregisterListener(connId, this.id, messages);
      unregisterCommands(connId, this.id, commands);
    }
  }

  // === Message Handlers ===

  handleDisconnect(msg: HabboMessage): void {
    console.log('LoginHandler: Connection disconnected');
    const iface = this.getInterface();
    if (iface && typeof (iface as Record<string, unknown>)['showDisconnect'] === 'function') {
      (iface as { showDisconnect: () => void }).showDisconnect();
    }
  }

  handleHello(msg: HabboMessage): void {
    console.log('LoginHandler: Hello received, starting crypto');
    (msg.connection as HabboConnection).send('INIT_CRYPTO');
  }

  handleCryptoParameters(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    const serverToClient = conn.GetIntFrom(msg) !== 0;

    this.cryptoParams = {
      ClientToServer: true,
      ServerToClient: serverToClient,
    };

    if (this.cryptoParams.ClientToServer) {
      this.responseWithPublicKey();
    } else if (serverToClient) {
      console.error('LoginHandler: Server to client encryption only is not supported');
      conn.disconnect(true);
    } else {
      this.startSession();
    }
  }

  private responseWithPublicKey(): void {
    const conn = getConnection(getVariable('connection.info.id', 'Info') as string);
    if (!conn) return;

    // Generate random public key
    const hexChars = '0123456789ABCDEF';
    let publicKey = '';
    for (let i = 0; i < 60; i++) {
      publicKey += hexChars[Math.floor(Math.random() * 16)];
    }

    this.publicKey = publicKey;

    // In a real implementation, this would do Diffie-Hellman
    // For now, just send the key
    conn.send('GENERATEKEY', { string: publicKey });
  }

  handleSecretKey(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    const serverPublicKey = msg.content;

    // Create shared key (simplified - real implementation uses DH)
    const sharedKey = this.deriveSharedKey(serverPublicKey);

    // Set up encryption
    const decoder = new RC4Cipher();
    decoder.setKey(sharedKey);
    conn.setDecoder(decoder);

    const encoder = new RC4Cipher();
    encoder.setKey(sharedKey);
    conn.setEncoder(encoder);

    conn.setEncryption(true);

    if (this.cryptoParams.ServerToClient) {
      this.makeServerToClientKey();
    } else {
      this.startSession();
    }
  }

  private deriveSharedKey(serverPublicKey: string): string {
    // Simplified key derivation - real implementation would use BigInt DH
    let key = '';
    for (let i = 0; i < serverPublicKey.length; i += 2) {
      const hex = serverPublicKey.slice(i, i + 2);
      key += String.fromCharCode(parseInt(hex, 16) || 0);
    }
    return key.slice(0, 16); // Use first 16 bytes
  }

  private makeServerToClientKey(): void {
    const conn = getConnection(getVariable('connection.info.id', 'Info') as string);
    if (!conn) return;

    const decoder = new RC4Cipher();
    const publicKey = decoder.createKey();

    conn.send('SECRETKEY', { string: publicKey });

    // Set up deciphering
    conn.setDecoder(decoder);
    decoder.setKey(publicKey.slice(0, 16));

    // Pre-mix the cipher
    const premixChars = 'eb11nmhdwbn733c2xjv1qln3ukpe0hvce0ylr02s12sv96rus2ohexr9cp8rufbmb1mdb732j1l3kehc0l0s2v6u2hx9prfmu';
    decoder.preMixEncodeSbox(premixChars, 17);

    conn.setProperty('deciphering', true);
  }

  handleEndCrypto(msg: HabboMessage): void {
    this.startSession();
  }

  private startSession(): void {
    const conn = getConnection(getVariable('connection.info.id', 'Info') as string);
    if (!conn) return;

    const clientVersion = getVariable('client.version.id', 0) as number;
    const clientURL = ''; // Would be set in real implementation
    const extVarsURL = '';

    conn.send('VERSIONCHECK', {
      integer: clientVersion,
      string: clientURL,
      string2: extVarsURL,
    });

    conn.send('UNIQUEID', { string: this.getMachineId() });
    conn.send('GET_SESSION_PARAMETERS');
  }

  private getMachineId(): string {
    // Generate a pseudo-unique machine ID
    let id = localStorage.getItem('habbo_machine_id');
    if (!id) {
      id = 'WEB' + Date.now().toString(36) + Math.random().toString(36).slice(2);
      localStorage.setItem('habbo_machine_id', id);
    }
    return id;
  }

  handleSessionParameters(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    const pairsCount = conn.GetIntFrom(msg);

    for (let i = 0; i < pairsCount; i++) {
      const id = conn.GetIntFrom(msg);

      switch (id) {
        case 0: // COPPA
          const coppa = conn.GetIntFrom(msg);
          session.set('conf_coppa', coppa > 0);
          session.set('conf_strong_coppa_required', coppa > 1);
          break;
        case 1: // Voucher
          session.set('conf_voucher', conn.GetIntFrom(msg) > 0);
          break;
        case 2: // Parent email request
          session.set('conf_parent_email_request', conn.GetIntFrom(msg) > 0);
          break;
        case 5: // Date format
          const dateFormat = conn.GetStrFrom(msg);
          session.set('date_format', dateFormat);
          break;
        case 9: // Tutorial
          session.set('tutorial_enabled', conn.GetIntFrom(msg));
          break;
      }
    }

    // Send login
    const component = this.getComponent();
    if (component && typeof (component as Record<string, unknown>)['sendLogin'] === 'function') {
      (component as { sendLogin: (conn: HabboConnection) => void }).sendLogin(conn);
    }
  }

  handlePing(msg: HabboMessage): void {
    (msg.connection as HabboConnection).send('PONG');
  }

  handleLoginOK(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;

    conn.send('GET_INFO');
    conn.send('GET_CREDITS');
    conn.send('GETAVAILABLEBADGES');
    conn.send('GET_SOUND_SETTING');

    session.set('userLoggedIn', true);
    executeMessage('userloggedin');
  }

  handleUserObj(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;

    const user = {
      user_id: conn.GetStrFrom(msg),
      name: conn.GetStrFrom(msg),
      figure: conn.GetStrFrom(msg),
      sex: conn.GetStrFrom(msg),
      customData: conn.GetStrFrom(msg),
      ph_tickets: conn.GetIntFrom(msg),
      ph_figure: conn.GetStrFrom(msg),
      photo_film: conn.GetIntFrom(msg),
      directMail: conn.GetIntFrom(msg),
    };

    // Normalize sex
    if (user.sex.toLowerCase().includes('f')) {
      user.sex = 'F';
    } else {
      user.sex = 'M';
    }

    // Store in session
    for (const [key, value] of Object.entries(user)) {
      session.set(`user_${key}`, value);
    }
    session.set('userName', user.name);

    executeMessage('updateFigureData');
    executeMessage('userlogin', 'userLogin');

    console.log('LoginHandler: User logged in:', user.name);
  }

  handleRights(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    const rights: string[] = [];

    while (true) {
      const privilege = conn.GetStrFrom(msg);
      if (!privilege) break;
      rights.push(privilege);
    }

    session.set('user_rights', rights);
  }

  handleErr(msg: HabboMessage): void {
    console.error('LoginHandler: Server error:', msg.content);

    if (msg.content.includes('login incorrect')) {
      executeMessage('alert', { Msg: 'Alert_WrongNameOrPassword' });
    } else if (msg.content.includes('Version not correct')) {
      executeMessage('alert', { Msg: 'alert_old_client' });
    } else if (msg.content.includes('Duplicate session')) {
      executeMessage('alert', { Msg: 'alert_duplicatesession' });
    }
  }

  handleUserBanned(msg: HabboMessage): void {
    executeMessage('openGeneralDialog', 'ban', {
      id: 'BannWarning',
      title: 'Alert_YouAreBanned_T',
      Msg: 'You are banned: ' + msg.content,
      modal: true,
    });
  }

  handleSystemBroadcast(msg: HabboMessage): void {
    const text = msg.content.replace(/\\r/g, '\n').replace(/<br>/g, '\n');
    executeMessage('alert', { Msg: text });
  }

  handleCheckSum(msg: HabboMessage): void {
    session.set('user_checksum', msg.content);
  }

  handleAvailableBadges(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    const badges: string[] = [];
    const count = conn.GetIntFrom(msg);

    for (let i = 0; i < count; i++) {
      badges.push(conn.GetStrFrom(msg));
    }

    const chosenIndex = conn.GetIntFrom(msg) + 1;
    const visible = conn.GetIntFrom(msg);

    session.set('available_badges', badges);
    session.set('chosen_badge_index', Math.max(1, chosenIndex));
    session.set('badge_visible', visible);
  }

  handleModAlert(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    const messageText = conn.GetStrFrom(msg);
    const url = conn.GetStrFrom(msg) || undefined;

    executeMessage('alert', {
      title: 'alert_warning',
      Msg: messageText,
      modal: true,
      url,
    });
  }

  handleEPSnotify(msg: HabboMessage): void {
    // External param notification - used for various notifications
    executeMessage('notify', msg.content);
  }

  handleHotelLogout(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    const logoutId = conn.GetIntFrom(msg);

    switch (logoutId) {
      case -1:
        // Normal disconnect
        const iface = this.getInterface();
        if (iface && typeof (iface as Record<string, unknown>)['showDisconnect'] === 'function') {
          (iface as { showDisconnect: () => void }).showDisconnect();
        }
        break;
      case 1:
        // Logged out
        window.location.href = '/logout';
        break;
      case 2:
        // Concurrent login
        window.location.href = '/logout?reason=concurrent';
        break;
      case 3:
        // Timeout
        window.location.href = '/logout?reason=timeout';
        break;
    }
  }

  handleSoundSetting(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    const soundState = conn.GetIntFrom(msg);
    session.set('sound_enabled', soundState > 0);
    executeMessage('soundSettingChanged', soundState);
  }

  hideLogin(): void {
    const iface = this.getInterface();
    if (iface && typeof (iface as Record<string, unknown>)['hideLogin'] === 'function') {
      (iface as { hideLogin: () => void }).hideLogin();
    }
  }
}

// Helper to unregister message
function unregisterMessage(type: string, id: string): void {
  // Implementation in MessageBus
}
