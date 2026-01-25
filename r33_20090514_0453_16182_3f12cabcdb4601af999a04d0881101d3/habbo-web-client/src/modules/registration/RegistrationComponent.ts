/**
 * Registration Component Class - Registration state management
 *
 * Ported from: hh_registrat/Cast External ParentScript 3 - Registration Component Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import {
  RegistrationState,
  RegistrationProps,
  RegistrationFields,
  RegistrationMode,
} from './types';
import { RegistrationInterface } from './RegistrationInterface';

/**
 * Registration component - manages registration state and server communication
 */
export class RegistrationComponent extends BaseObject {
  private pState: RegistrationState = 'reset';
  private pFigurePartListLoadedFlag: boolean = false;
  private pAvailableSetListLoadedFlag: boolean = false;
  private pAgeCheckFlag: boolean | null = null;
  private pParentEmailNeededFlag: boolean | null = null;
  private pParentEmailAddress: string = '';
  private pUserIDFromRegistration: string = '';
  private pCheckingName: string | null = null;

  private iface: RegistrationInterface | null = null;

  construct(): void {
    super.construct();
    this.pFigurePartListLoadedFlag = false;
    this.pAvailableSetListLoadedFlag = false;
    this.pState = 'reset';
    this.pAgeCheckFlag = null;
    this.pParentEmailNeededFlag = null;
    this.pParentEmailAddress = '';

    // Would register for room events
    // registerMessage(#enterRoom, ...)
    // registerMessage(#changeRoom, ...)
    // registerMessage(#leaveRoom, ...)
    // registerMessage(#show_registration, ...)
    // registerMessage(#hide_registration, ...)
    // registerMessage(#figure_ready, ...)
  }

  deconstruct(): void {
    // Would unregister messages
    this.updateState('reset');
    super.deconstruct();
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
   * Set block time for COPPA
   */
  setBlockTime(data: string): void {
    // Would set preference
    // setPref("blocktime", data)
    this.closeFigureCreator();
    // Would show alert and disconnect
  }

  /**
   * Continue blocking (for underage users)
   */
  continueBlocking(): void {
    this.closeFigureCreator();
    // Would show alert and disconnect
  }

  /**
   * Get real time from server for COPPA
   */
  getRealtime(): void {
    // Would send COPPA_REG_GETREALTIME command
  }

  /**
   * Check block time for COPPA
   */
  checkBlockTime(): void {
    // Would send COPPA_REG_CHECKTIME command
  }

  /**
   * Reset block time
   */
  resetBlockTime(): void {
    // setPref("blocktime", "0")
    this.updateState('openFigureCreator');
  }

  /**
   * Open figure creator
   */
  openFigureCreator(): void {
    this.updateState('openFigureCreator');
  }

  /**
   * Open figure update
   */
  openFigureUpdate(): void {
    this.updateState('openFigureUpdate');
  }

  /**
   * Close figure creator
   */
  closeFigureCreator(): void {
    this.iface?.closeFigureCreator();
  }

  /**
   * Re-registration required
   */
  reRegistrationRequired(): void {
    this.updateState('openForcedUpdate');
  }

  /**
   * Figure system ready callback
   */
  figureSystemReady(): void {
    this.updateState(this.pState);
  }

  /**
   * Check username with server
   */
  checkUserName(nameStr: string): boolean {
    // Would validate string locally first
    // Then send APPROVENAME command
    this.pCheckingName = nameStr;
    return true;
  }

  /**
   * Send new figure data to server
   */
  sendNewFigureDataToServer(propList: RegistrationProps): boolean {
    const props = { ...propList };

    // Would convert figure to server format
    // if (props.figure) {
    //   props.figure = figureSystem.GenerateFigureDataToServerMode(props.figure, props.sex);
    // }

    // Build message
    const msg: Array<{ type: string; value: unknown }> = [];

    for (const [key, value] of Object.entries(props)) {
      if (value === undefined) continue;

      const fieldDef = RegistrationFields[key];
      if (!fieldDef) continue;

      msg.push({ type: 'short', value: fieldDef.id });

      let convertedValue = value;
      if (fieldDef.type === 'boolean') {
        convertedValue = value ? 1 : 0;
      } else if (fieldDef.type === 'string') {
        convertedValue = String(value);
      }

      msg.push({ type: fieldDef.type, value: convertedValue });
    }

    // Would send REGISTER command
    return true;
  }

  /**
   * Send figure update to server
   */
  sendFigureUpdateToServer(propList: RegistrationProps): boolean {
    const props = { ...propList };

    // Would convert figure to server format
    // Build message for changed fields only
    const fieldsToCheck = ['figure', 'sex', 'customData', 'directMail', 'has_read_agreement', 'parentagree'];
    const msg: Array<{ type: string; value: unknown }> = [];

    for (const field of fieldsToCheck) {
      const value = props[field as keyof RegistrationProps];
      if (value === undefined) continue;

      const fieldDef = RegistrationFields[field];
      if (!fieldDef) continue;

      msg.push({ type: 'short', value: fieldDef.id });

      let convertedValue = value;
      if (fieldDef.type === 'boolean') {
        convertedValue = value ? 1 : 0;
      }

      msg.push({ type: fieldDef.type, value: convertedValue });
    }

    // Would send UPDATE command
    return true;
  }

  /**
   * New figure ready callback
   */
  newFigureReady(): boolean {
    this.closeFigureCreator();
    this.updateState('start');
    return true;
  }

  /**
   * Figure update ready callback
   */
  figureUpdateReady(): boolean {
    // Would send INFORETRIEVE and parent email if needed
    this.closeFigureCreator();
    this.updateState('start');
    return true;
  }

  /**
   * Set available set list
   */
  setAvailableSetList(list: unknown[]): void {
    if (this.pFigurePartListLoadedFlag && list) {
      // Would initialize selectable part list
      this.pAvailableSetListLoadedFlag = true;

      if (this.pState === 'openFigureCreator') {
        this.updateState('openFigureCreator');
      } else if (this.pState === 'openFigureUpdate') {
        this.updateState('openFigureUpdate');
      }
    }
  }

  /**
   * Get available set list
   */
  getAvailableSetList(): void {
    if (this.pFigurePartListLoadedFlag && !this.pAvailableSetListLoadedFlag) {
      // Would send GETAVAILABLESETS command
    }
  }

  /**
   * Check age with server
   */
  checkAge(age: string): boolean {
    // Would send AC command
    return true;
  }

  /**
   * Check email address
   */
  checkEmailAddress(email: string): boolean {
    // Would send APPROVEEMAIL command
    return true;
  }

  /**
   * Parent email need query
   */
  parentEmailNeedQuery(birthday: string, habboId: string): boolean {
    // Would send PARENT_EMAIL_REQUIRED command
    return true;
  }

  /**
   * Send parent email
   */
  sendParentEmail(): boolean {
    if (this.pParentEmailAddress) {
      // Would send SEND_PARENT_EMAIL command
    }
    return true;
  }

  /**
   * Validate parent email
   */
  validateParentEmail(userEmail: string, parentEmail: string): boolean {
    // Would send VALIDATE_PARENT_EMAIL command
    this.pParentEmailAddress = parentEmail;
    return true;
  }

  /**
   * Set age check result
   */
  setAgeCheckResult(flag: boolean): void {
    this.pAgeCheckFlag = flag;
    this.iface?.finishRegistration(flag);
  }

  /**
   * Get age check result
   */
  getAgeCheckResult(): boolean | null {
    return this.pAgeCheckFlag;
  }

  /**
   * Parent email need query result
   */
  parentEmailNeedQueryResult(flag: boolean): void {
    this.pParentEmailNeededFlag = flag;
    this.iface?.parentEmailQueryStatus(flag);
  }

  /**
   * Parent email validated
   */
  parentEmailValidated(flag: boolean): void {
    if (flag) {
      this.iface?.parentEmailOk();
    } else {
      this.pParentEmailAddress = '';
      this.iface?.parentEmailIncorrect();
    }
  }

  /**
   * Get parent email needed flag
   */
  getParentEmailNeededFlag(): boolean | null {
    return this.pParentEmailNeededFlag;
  }

  /**
   * Send update account message
   */
  sendUpdateAccountMsg(propList: Record<string, string>): boolean {
    if (!propList.oldpassword || !propList.birthday) {
      return false;
    }

    if (!propList.password && !propList.email) {
      return false;
    }

    // Build and send UPDATE_ACCOUNT command
    return true;
  }

  /**
   * Send validate password
   */
  sendValidatePassword(password: string): boolean {
    // Would send APPROVE_PASSWORD command
    return true;
  }

  /**
   * Get current state
   */
  getState(): RegistrationState {
    return this.pState;
  }

  /**
   * Update state machine
   */
  updateState(state: RegistrationState, props?: unknown): boolean {
    switch (state) {
      case 'reset':
        this.pState = state;
        this.construct();
        return false;

      case 'initialize':
        this.pState = state;
        // Would load figure part list
        this.pFigurePartListLoadedFlag = true;
        return this.updateState('start');

      case 'start':
        this.pState = state;
        return true;

      case 'openFigureCreator':
        this.pState = state;
        // Determine registration process mode
        let registrationMode: RegistrationMode = 'registration';
        // Would check session for parent email requirements

        // Would check COPPA block time

        // Check if figure system is ready
        // if (!figureSystem.isFigureSystemReady()) {
        //   this.iface?.showLoadingWindow();
        //   return false;
        // }

        this.iface?.openFigureCreator(registrationMode);
        return true;

      case 'openFigureUpdate':
        this.pState = state;
        // Check figure system ready
        // Would validate and show figure creator
        this.iface?.showHideFigureCreator('update');
        return true;

      case 'openForcedUpdate':
        this.pState = state;
        // Would validate figure and show forced update
        // Determine update mode based on COPPA and parent email flags
        return true;

      default:
        console.warn(`Unknown registration state: ${state}`);
        return false;
    }
  }

  /**
   * Try login after registration
   */
  tryLoginAfterRegistration(): void {
    // Would trigger login process
  }

  /**
   * Set checking name (for handler)
   */
  set checkingName(name: string | null) {
    this.pCheckingName = name;
  }

  get checkingName(): string | null {
    return this.pCheckingName;
  }

  /**
   * Set user ID from registration
   */
  set userIDFromRegistration(id: string) {
    this.pUserIDFromRegistration = id;
  }
}
