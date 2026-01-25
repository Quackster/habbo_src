/**
 * Login Interface Class - UI layer for login forms
 *
 * Ported from: hh_entry/Cast External ParentScript 6 - Login Interface Class.ls
 *              hh_entry_init/Cast External ParentScript 6 - Login Interface Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { session } from '../../core/Session';
import { executeMessage } from '../../core/MessageBus';
import { EventEmitter } from '../../core/events';
import { EntryConfig, EntryType } from './types';

export interface LoginFormState {
  username: string;
  password: string;
  isConnecting: boolean;
  loginFailed: boolean;
  failureReason?: string;
}

export class LoginInterface extends BaseObject {
  private config: EntryConfig | null = null;
  private tempPassword: string = '';
  private loginFormVisible: boolean = false;
  private registrationFormVisible: boolean = false;
  private disconnectDialogVisible: boolean = false;
  private blinkTimerId: number | null = null;
  private events: EventEmitter = new EventEmitter();

  /**
   * Configure the login interface
   */
  configure(config: EntryConfig): void {
    this.config = config;
  }

  construct(): void {
    super.construct();
  }

  deconstruct(): void {
    this.hideLogin();
    super.deconstruct();
  }

  /**
   * Show the login UI based on entry type configuration
   */
  showLogin(): boolean {
    // Clear previous session data
    session.set('userName', '');
    session.set('Password', '');
    this.tempPassword = '';

    const entryType = this.config?.entryType ?? 'auto';
    const registrationDisabled = this.config?.registrationDisabled ?? false;

    switch (entryType) {
      case 'sso':
        // SSO login - check for ticket
        const ssoTicket = this.config?.ssoTicket ?? session.GET<string>('sso.ticket');
        if (ssoTicket && ssoTicket.length > 1) {
          session.set('SSO_ticket', ssoTicket);
          // Proceed directly to connection
          this.events.emit('startSSOLogin', ssoTicket);
          return true;
        } else {
          // No valid SSO ticket, show error
          executeMessage('alert', { Msg: 'Alert_generic_login_error' });
          return false;
        }

      case 'quickLogin':
        // Quick login for development
        if (this.config?.quickLogin) {
          session.set('userName', this.config.quickLogin.username);
          session.set('Password', this.config.quickLogin.password);
          this.events.emit('startQuickLogin', this.config.quickLogin);
          return true;
        }
        // Fall through to credentials if no quick login config
        break;

      case 'credentials':
      case 'auto':
      default:
        // Show login form
        this.loginFormVisible = true;
        this.events.emit('showLoginForm', {
          registrationDisabled,
          username: '',
        });
        break;
    }

    return true;
  }

  /**
   * Hide the login UI
   */
  hideLogin(): boolean {
    if (this.blinkTimerId !== null) {
      clearInterval(this.blinkTimerId);
      this.blinkTimerId = null;
    }

    this.loginFormVisible = false;
    this.registrationFormVisible = false;

    this.events.emit('hideLoginForm');

    return true;
  }

  /**
   * Show disconnect dialog
   */
  showDisconnect(): void {
    // Check if hotel is closed
    const hotelClosedDisconnectResult: { retval?: number } = {};
    executeMessage('getHotelClosedDisconnectStatus', hotelClosedDisconnectResult);
    if (hotelClosedDisconnectResult.retval === 1) {
      return;
    }

    this.disconnectDialogVisible = true;
    this.events.emit('showDisconnectDialog', {
      title: 'Alert_ConnectionFailure',
      message: 'Alert_ConnectionDisconnected',
    });
  }

  /**
   * Hide disconnect dialog
   */
  hideDisconnect(): void {
    this.disconnectDialogVisible = false;
    this.events.emit('hideDisconnectDialog');
  }

  /**
   * Attempt to login with current form data
   */
  tryLogin(username?: string, password?: string): boolean {
    const actualUsername = username ?? this.getFormUsername();
    const actualPassword = password ?? this.tempPassword;

    if (!actualUsername || !actualPassword) {
      return false;
    }

    session.set('userName', actualUsername);
    session.set('Password', actualPassword);

    // Update UI to show connecting state
    this.events.emit('loginConnecting');
    this.startBlinkConnection();

    // Notify component to start connection
    const component = this.getComponent();
    if (component) {
      (component as { setOkToLogin: (v: boolean) => void }).setOkToLogin(true);
      (component as { connect: () => boolean }).connect();
    }

    return true;
  }

  /**
   * Start blinking the "connecting" indicator
   */
  private startBlinkConnection(): void {
    if (this.blinkTimerId !== null) {
      return;
    }

    let visible = true;
    this.blinkTimerId = setInterval(() => {
      visible = !visible;
      this.events.emit('connectingBlink', visible);
    }, 500) as unknown as number;
  }

  /**
   * Stop blinking the "connecting" indicator
   */
  private stopBlinkConnection(): void {
    if (this.blinkTimerId !== null) {
      clearInterval(this.blinkTimerId);
      this.blinkTimerId = null;
    }
  }

  /**
   * Show the "user found" welcome screen
   */
  showUserFound(): boolean {
    this.stopBlinkConnection();

    const userName = session.GET<string>('user_name') ?? '';

    this.events.emit('showUserFound', {
      userName,
    });

    // Trigger animations then hide after delay
    setTimeout(() => {
      this.events.emit('userWaveAnimation');
    }, 800);

    setTimeout(() => {
      this.events.emit('userSmileAnimation');
    }, 2000);

    setTimeout(() => {
      this.hideLogin();
    }, 2400);

    return true;
  }

  /**
   * Handle password input (masking with asterisks)
   */
  updatePasswordAsterisks(displayedText: string): void {
    // Update the stored password based on what changed
    for (let i = 0; i < displayedText.length; i++) {
      const char = displayedText[i];
      if (char !== '*' && char !== ' ') {
        // Character was added/changed
        this.tempPassword =
          this.tempPassword.slice(0, i) + char + this.tempPassword.slice(i + 1);
      }
    }

    // Handle deletion
    if (displayedText.length < this.tempPassword.length) {
      this.tempPassword = this.tempPassword.slice(0, displayedText.length);
    }

    // Emit masked version for display
    const masked = '*'.repeat(this.tempPassword.length);
    this.events.emit('passwordMasked', masked);
  }

  /**
   * Handle password backspace
   */
  handlePasswordBackspace(): void {
    if (this.tempPassword.length > 0) {
      this.tempPassword = this.tempPassword.slice(0, -1);
      const masked = '*'.repeat(this.tempPassword.length);
      this.events.emit('passwordMasked', masked);
    }
  }

  /**
   * Handle password delete all
   */
  handlePasswordClear(): void {
    this.tempPassword = '';
    this.events.emit('passwordMasked', '');
  }

  /**
   * Get the username from the form (to be implemented by UI layer)
   */
  private getFormUsername(): string {
    // This would be provided by the UI layer
    return session.GET<string>('formUsername') ?? '';
  }

  /**
   * Handle login form events
   */
  handleLoginEvent(event: string, elementId: string, param?: unknown): void {
    switch (event) {
      case 'mouseUp':
        switch (elementId) {
          case 'login_ok':
            this.tryLogin();
            break;
          case 'login_createUser':
            if (!this.config?.registrationDisabled) {
              this.hideLogin();
              executeMessage('show_registration');
            } else {
              executeMessage('alert', { Msg: 'registration_disabled_text', modal: true });
            }
            break;
          case 'login_forgotten':
            // Open forgot password URL
            this.events.emit('openForgotPassword');
            break;
        }
        break;

      case 'keyDown':
        const keyCode = param as number;
        if (keyCode === 13) {
          // Enter key
          this.tryLogin();
        }
        break;
    }
  }

  /**
   * Handle disconnect dialog events
   */
  handleDisconnectEvent(event: string, elementId: string): void {
    if (event === 'mouseUp' && elementId === 'error_close') {
      this.hideDisconnect();
      executeMessage('resetClient');
    }
  }

  /**
   * Login failed handler
   */
  loginFailed(reason?: string): void {
    this.stopBlinkConnection();

    this.events.emit('loginFailed', {
      reason: reason ?? 'Unknown error',
    });

    // Re-enable form
    this.events.emit('loginFormEnabled');
  }

  /**
   * Get events emitter for UI binding
   */
  getEvents(): EventEmitter {
    return this.events;
  }

  /**
   * Check if login form is visible
   */
  isLoginFormVisible(): boolean {
    return this.loginFormVisible;
  }

  /**
   * Check if disconnect dialog is visible
   */
  isDisconnectDialogVisible(): boolean {
    return this.disconnectDialogVisible;
  }
}
