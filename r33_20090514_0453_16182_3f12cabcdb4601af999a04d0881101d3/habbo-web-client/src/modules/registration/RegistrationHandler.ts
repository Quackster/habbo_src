/**
 * Registration Handler Class - Server message handling
 *
 * Ported from: hh_registrat/Cast External ParentScript 4 - Registration Handler Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { RegistrationComponent } from './RegistrationComponent';
import { RegistrationInterface } from './RegistrationInterface';
import {
  RegistrationMessages,
  NameApprovalResult,
  PasswordValidationResult,
  AccountUpdateStatus,
} from './types';

/**
 * Message data from server
 */
interface MessageData {
  connection?: {
    GetIntFrom: () => number;
    GetStrFrom: () => string;
  };
  content?: string;
}

/**
 * Registration handler - processes server messages
 */
export class RegistrationHandler extends BaseObject {
  private component: RegistrationComponent | null = null;
  private iface: RegistrationInterface | null = null;

  construct(): void {
    super.construct();
    this.registerMessages(true);
  }

  deconstruct(): void {
    this.registerMessages(false);
    super.deconstruct();
  }

  /**
   * Set component reference
   */
  setComponent(component: RegistrationComponent): void {
    this.component = component;
  }

  /**
   * Get component
   */
  getComponent(): RegistrationComponent | null {
    return this.component;
  }

  /**
   * Set interface reference
   */
  setInterface(iface: RegistrationInterface): void {
    this.iface = iface;
  }

  /**
   * Get interface
   */
  getInterface(): RegistrationInterface | null {
    return this.iface;
  }

  /**
   * Handle OK message (message 1)
   */
  handleOk(_msg: MessageData): void {
    if (this.component?.getState() === 'openFigureCreator') {
      this.component.updateState('openFigureCreator');
    }
  }

  /**
   * Handle login OK message (message 3)
   */
  handleLoginOk(_msg: MessageData): void {
    // Would check session for parent email request flag
    // if (session.exists('conf_parent_email_request') && session.get('conf_parent_email_request')) {
    //   this.component?.sendParentEmail();
    // }
  }

  /**
   * Handle registration OK message (message 51)
   */
  handleRegOk(msg: MessageData): void {
    const userId = msg.connection?.GetStrFrom() || '';
    if (this.component) {
      this.component.userIDFromRegistration = userId;
    }
  }

  /**
   * Handle update OK message (message 211)
   */
  handleUpdateOk(_msg: MessageData): void {
    this.component?.figureUpdateReady();
  }

  /**
   * Handle approve name reply message (message 36)
   */
  handleApproveNameReply(msg: MessageData): boolean {
    if (this.component?.checkingName === null) {
      return true;
    }

    this.component.checkingName = null;
    const result = msg.connection?.GetIntFrom() ?? 0;

    switch (result) {
      case NameApprovalResult.OK:
        this.iface?.userNameOk();
        break;
      case NameApprovalResult.TOO_LONG:
        this.iface?.userNameTooLong();
        break;
      case NameApprovalResult.UNACCEPTABLE:
      case NameApprovalResult.UNACCEPTABLE_CHARS:
        this.iface?.userNameUnacceptable();
        break;
      case NameApprovalResult.ALREADY_RESERVED:
        this.iface?.userNameAlreadyReserved();
        break;
    }

    return true;
  }

  /**
   * Handle name unacceptable message (message 37)
   */
  handleNameUnacceptable(msg: MessageData): void {
    const result = msg.connection?.GetIntFrom() ?? 0;
    if (result === 0) {
      this.iface?.userNameUnacceptable();
    }
  }

  /**
   * Handle available sets message (message 8)
   */
  handleAvailableSets(msg: MessageData): void {
    let sets: unknown[] = [];

    try {
      if (msg.content) {
        sets = JSON.parse(msg.content);
      }
    } catch {
      sets = [];
    }

    if (!Array.isArray(sets) || sets.length < 2) {
      sets = [];
    }

    // Would pass to Figure_System
    // if (objectExists('Figure_System')) {
    //   getObject('Figure_System').setAvailableSetList(sets);
    // }
    this.component?.setAvailableSetList(sets);
  }

  /**
   * Handle age check result message (message 164)
   */
  handleAgeCheckResult(msg: MessageData): void {
    const result = msg.content === '1' || msg.content === 'true';
    this.component?.setAgeCheckResult(result);
  }

  /**
   * Handle re-registration required message (message 167)
   */
  handleReRegistrationRequired(_msg: MessageData): void {
    this.component?.reRegistrationRequired();
  }

  /**
   * Handle COPPA check time message (message 214)
   */
  handleCoppaCheckTime(msg: MessageData): boolean {
    const result = msg.connection?.GetIntFrom() ?? 0;

    if (result) {
      this.component?.resetBlockTime();
    } else {
      this.component?.continueBlocking();
    }

    return true;
  }

  /**
   * Handle COPPA get real time message (message 215)
   */
  handleCoppaGetRealTime(msg: MessageData): boolean {
    const data = msg.content;

    if (data !== undefined && data !== null) {
      this.component?.setBlockTime(data);
    }

    return true;
  }

  /**
   * Handle parent email required message (message 217)
   */
  handleParentEmailRequired(msg: MessageData): boolean {
    const flag = (msg.connection?.GetIntFrom() ?? 0) === 1;
    this.component?.parentEmailNeedQueryResult(flag);
    return true;
  }

  /**
   * Handle parent email validated message (message 218)
   */
  handleParentEmailValidated(msg: MessageData): boolean {
    const flag = (msg.connection?.GetIntFrom() ?? 0) === 1;
    this.component?.parentEmailValidated(flag);
    return true;
  }

  /**
   * Handle update account message (message 169)
   */
  handleUpdateAccount(msg: MessageData): boolean {
    const status = String(msg.connection?.GetIntFrom() ?? 0);
    this.iface?.responseToAccountUpdate(status as keyof typeof AccountUpdateStatus);
    return true;
  }

  /**
   * Handle email approved message (message 271)
   */
  handleEmailApproved(_msg: MessageData): boolean {
    this.iface?.userEmailOk();
    return true;
  }

  /**
   * Handle email rejected message (message 272)
   */
  handleEmailRejected(_msg: MessageData): boolean {
    this.iface?.userEmailUnacceptable();
    return true;
  }

  /**
   * Handle update request message (message 275)
   */
  handleUpdateRequest(msg: MessageData): void {
    const connection = msg.connection;
    if (!connection) return;

    const updateFlag = connection.GetIntFrom();
    const forceFlag = connection.GetIntFrom() === 1;

    switch (updateFlag) {
      case 0:
        // Email update suggested
        this.iface?.openEmailUpdate(forceFlag, 'update_email_suggest');
        break;
      case 1:
        // Password update suggested
        this.iface?.openPasswordUpdate(forceFlag, 'update_password_suggest');
        break;
    }
  }

  /**
   * Handle password approved message (message 282)
   */
  handlePasswordApproved(msg: MessageData): boolean {
    const connection = msg.connection;
    if (!connection) return false;

    const result = connection.GetIntFrom() as keyof typeof PasswordValidationResult;
    this.iface?.userPasswordResult(result);
    return true;
  }

  /**
   * Register/unregister message handlers
   */
  private registerMessages(register: boolean): void {
    // Message handlers map
    const messageHandlers: Record<number, (msg: MessageData) => void> = {
      [RegistrationMessages.OK]: (msg) => this.handleOk(msg),
      [RegistrationMessages.LOGIN_OK]: (msg) => this.handleLoginOk(msg),
      [RegistrationMessages.AVAILABLE_SETS]: (msg) => this.handleAvailableSets(msg),
      [RegistrationMessages.APPROVE_NAME_REPLY]: (msg) => this.handleApproveNameReply(msg),
      [RegistrationMessages.NAME_UNACCEPTABLE]: (msg) => this.handleNameUnacceptable(msg),
      [RegistrationMessages.REG_OK]: (msg) => this.handleRegOk(msg),
      [RegistrationMessages.AGE_CHECK_RESULT]: (msg) => this.handleAgeCheckResult(msg),
      [RegistrationMessages.UPDATE_OK]: (msg) => this.handleUpdateOk(msg),
      [RegistrationMessages.RE_REGISTRATION_REQUIRED]: (msg) => this.handleReRegistrationRequired(msg),
      [RegistrationMessages.COPPA_CHECKTIME]: (msg) => this.handleCoppaCheckTime(msg),
      [RegistrationMessages.COPPA_GETREALTIME]: (msg) => this.handleCoppaGetRealTime(msg),
      [RegistrationMessages.PARENT_EMAIL_REQUIRED]: (msg) => this.handleParentEmailRequired(msg),
      [RegistrationMessages.PARENT_EMAIL_VALIDATED]: (msg) => this.handleParentEmailValidated(msg),
      [RegistrationMessages.UPDATE_ACCOUNT]: (msg) => this.handleUpdateAccount(msg),
      [RegistrationMessages.EMAIL_APPROVED]: (msg) => this.handleEmailApproved(msg),
      [RegistrationMessages.EMAIL_REJECTED]: (msg) => this.handleEmailRejected(msg),
      [RegistrationMessages.UPDATE_REQUEST]: (msg) => this.handleUpdateRequest(msg),
      [RegistrationMessages.PASSWORD_APPROVED]: (msg) => this.handlePasswordApproved(msg),
    };

    if (register) {
      // Would register with connection system
      // registerListener(connectionId, this.id, messageHandlers);
      this.emit('handlers_registered', messageHandlers);
    } else {
      // Would unregister from connection system
      // unregisterListener(connectionId, this.id, messageHandlers);
      this.emit('handlers_unregistered');
    }
  }
}
