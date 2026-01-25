/**
 * Registration Interface Class - UI handling for registration flow
 *
 * Ported from: hh_registrat/Cast External ParentScript 2 - Registration Interface Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { RegistrationComponent } from './RegistrationComponent';
import {
  RegistrationMode,
  RegistrationWindow,
  RegistrationProps,
  FigurePartData,
  BodyPartType,
  EDITABLE_PARTS,
  ALL_BODY_PARTS,
  PartChangeButtonState,
  UpdateAccountProps,
  DEFAULT_PERMITTED_NAME_CHARS,
  DEFAULT_PERMITTED_PASSWORD_CHARS,
  DEFAULT_DENIED_NAME_CHARS,
  PasswordValidationResult,
  AccountUpdateStatus,
} from './types';

/**
 * Body part object for figure preview
 */
interface BodyPartObject {
  part: BodyPartType;
  model: string;
  color: string;
  direction: number;
  action: string;

  setModel(model: string): void;
  setColor(color: string): void;
  copyPicture(targetImage: HTMLCanvasElement): void;
}

/**
 * Window element interface
 */
interface WindowElement {
  setText(text: string): void;
  getText(): string;
  setFocus(focus: boolean): void;
  setProperty(prop: string, value: unknown): void;
  getProperty(prop: string): unknown;
  feedImage(image: ImageData | HTMLImageElement | HTMLCanvasElement): void;
  show(): void;
  hide(): void;
  setEdit(editable: boolean): void;
  deactivate(): void;
  setOrdering(order: number): void;
  getSelection(): string;
  setSelection(value: number, flag: number): void;
  getScrollOffset(): number;
  moveBy(x: number, y: number): void;
}

/**
 * Window object interface
 */
interface WindowObject {
  elementExists(id: string): boolean;
  getElement(id: string): WindowElement | null;
  merge(windowType: string): void;
  unmerge(): void;
  center(): void;
  moveBy(x: number, y: number): void;
  setProperty(prop: string, value: unknown): void;
  registerProcedure(proc: string, id: string, eventType: string): void;
  registerClient(id: string): void;
}

/**
 * Registration interface - manages UI and user interaction
 */
export class RegistrationInterface extends BaseObject {
  private pTempPassword: Record<string, string> = {};
  private pOpenWindow: RegistrationWindow | '' = '';
  private pWindowTitle: string = 'Your own Habbo';
  private pMode: RegistrationMode = 'registration';
  private pOldFigure: Record<string, FigurePartData> | null = null;
  private pOldSex: 'M' | 'F' | null = null;
  private pPartChangeButtons: PartChangeButtonState = { partmodel: {}, partcolor: {} };
  private pBodyPartObjects: Record<string, BodyPartObject> | null = null;
  private pPeopleSize: string = 'h';
  private pFlipList: number[] = [0, 1, 2, 3, 2, 1, 0, 7];
  private pNameChecked: boolean = false;
  private pEmailChecked: boolean = false;
  private pLastNameCheck: string = '';
  private pPropsToServer: RegistrationProps = {};
  private pErrorMsg: string = '';
  private pRegProcess: string[] = [];
  private pRegProcessLocation: number = 1;
  private pVerifyChangeWndID: string = 'VerifyingChangeWindow';
  private pLastWindow: string = '';
  private pPwdEmailUpdateForced: boolean = false;
  private pPasswordErrors: string = '';
  private pUpdatingPassword: boolean = false;
  private pPasswordChecked: boolean = false;
  private pUpdatePropsToServer: UpdateAccountProps = {};

  private component: RegistrationComponent | null = null;
  private canvas: HTMLCanvasElement | null = null;
  private ctx: CanvasRenderingContext2D | null = null;

  construct(): void {
    super.construct();

    this.pTempPassword = {};
    this.pPropsToServer = {};
    this.pPartChangeButtons = { partmodel: {}, partcolor: {} };
    this.pLastNameCheck = '';
    this.pWindowTitle = 'Your own Habbo'; // Would use getText('win_figurecreator', 'Your own Habbo')
    this.pOpenWindow = '';
    this.pRegProcessLocation = 1;
    this.pVerifyChangeWndID = 'VerifyingChangeWindow';
    this.pLastWindow = '';
    this.pPwdEmailUpdateForced = false;
    this.pPasswordErrors = '';

    // Create canvas for rendering
    this.canvas = document.createElement('canvas');
    this.ctx = this.canvas.getContext('2d');

    // Would load registration.props variable field
    // Would set permitted chars variables if not set
  }

  deconstruct(): void {
    this.pBodyPartObjects = null;

    // Would remove windows
    // if (windowExists(pWindowTitle)) removeWindow(pWindowTitle)
    // if (objectExists(#temp_humanobj_figurecreator)) removeObject(...)

    this.canvas = null;
    this.ctx = null;

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
   * Show/hide figure creator
   */
  showHideFigureCreator(newOrUpdate: string, forceOpen?: boolean): boolean {
    // Would check if window exists and toggle
    // For now, just open
    return this.openFigureCreator(newOrUpdate as RegistrationMode);
  }

  /**
   * Open figure creator
   */
  openFigureCreator(mode?: RegistrationMode): boolean {
    if (mode) {
      this.defineModes(mode);
    }

    // Get registration process pages from variable
    const regPages = this.getRegProcessPages(this.pMode);

    let windowType: RegistrationWindow = 'reg_namepage.window';

    if (Array.isArray(regPages) && regPages.length > 0) {
      this.pRegProcessLocation = 1;
      windowType = `${regPages[0]}.window` as RegistrationWindow;
    }

    return this.enterPage(windowType);
  }

  /**
   * Close figure creator
   */
  closeFigureCreator(): boolean {
    this.pPropsToServer = {};
    this.pBodyPartObjects = null;

    // Would remove window
    // if (windowExists(pWindowTitle)) removeWindow(pWindowTitle)

    // Would clear session flag
    // session.set('creatingCharacter', 0)

    this.emit('figurecreator_closed');
    return true;
  }

  /**
   * Show loading window
   */
  showLoadingWindow(mode?: RegistrationMode): boolean {
    if (mode) {
      this.pMode = mode;
    }
    this.changeWindowView('reg_loading.window');
    this.blinkLoading();
    return true;
  }

  /**
   * Finish registration after age check
   */
  finishRegistration(ageOk: boolean): void {
    if (ageOk) {
      this.changePage(1);
    } else {
      this.component?.getRealtime();
    }
  }

  /**
   * Username approved
   */
  userNameOk(): void {
    if (this.pOpenWindow === 'reg_loading.window') {
      this.changePage(1);
    }
  }

  /**
   * Username unacceptable
   */
  userNameUnacceptable(): void {
    if (this.pOpenWindow === 'reg_loading.window') {
      this.changePage('reg_namepage.window');
    }

    this.emit('alert', { msg: 'Alert_unacceptableName', id: 'namenogood', modal: true });
    this.clearUserNameField();
  }

  /**
   * Username too long
   */
  userNameTooLong(): void {
    if (this.pOpenWindow === 'reg_loading.window') {
      this.changePage('reg_namepage.window');
    }

    this.emit('alert', { msg: 'Alert_NameTooLong', id: 'nametoolong', modal: true });
  }

  /**
   * Username already reserved
   */
  userNameAlreadyReserved(): void {
    if (this.pOpenWindow === 'reg_loading.window') {
      this.changePage('reg_namepage.window');
    }

    this.emit('alert', { msg: 'Alert_NameAlreadyUse', id: 'namereserved', modal: true });
    this.clearUserNameField();
  }

  /**
   * Email approved
   */
  userEmailOk(): boolean {
    this.pEmailChecked = true;
    this.changePage(1);
    return true;
  }

  /**
   * Email unacceptable
   */
  userEmailUnacceptable(): boolean {
    this.pEmailChecked = false;

    if (this.pOpenWindow === 'reg_info_update.window') {
      // Would remove verify window
      // removeWindow(pVerifyChangeWndID)
    }

    this.emit('alert', { msg: 'reg_verification_invalidEmail', id: 'emailnogood', modal: true });
    return true;
  }

  /**
   * Password validation result
   */
  userPasswordResult(result: number): boolean {
    switch (result) {
      case PasswordValidationResult.OK:
        this.pPasswordChecked = true;
        this.pPasswordErrors = '';
        break;
      case PasswordValidationResult.TOO_SHORT:
        this.pPasswordChecked = false;
        this.pPasswordErrors = 'Your password is too short\n';
        break;
      case PasswordValidationResult.TOO_LONG:
        this.pPasswordChecked = false;
        this.pPasswordErrors = 'Your password is too long\n';
        break;
      case PasswordValidationResult.INVALID_CHARS:
        this.pPasswordChecked = false;
        this.pPasswordErrors = `Use allowed characters: ${DEFAULT_PERMITTED_PASSWORD_CHARS}\n`;
        break;
      case PasswordValidationResult.NO_NUMBER:
        this.pPasswordChecked = false;
        this.pPasswordErrors = 'Password must contain a number\n';
        break;
      case PasswordValidationResult.TOO_SIMILAR_TO_NAME:
        this.pPasswordChecked = false;
        this.pPasswordErrors = 'Password too similar to name\n';
        break;
    }

    if (this.pUpdatingPassword) {
      if (result === PasswordValidationResult.OK) {
        // Build birthday and send update
        const { day, month, year, currPwd, newPwd } = this.pUpdatePropsToServer;
        const dayStr = String(day).padStart(2, '0');
        const monthStr = String(month).padStart(2, '0');
        const dob = `${dayStr}.${monthStr}.${year}`;

        const props = {
          oldpassword: currPwd,
          birthday: dob,
          password: newPwd,
        };

        this.component?.sendUpdateAccountMsg(props);
      } else {
        // Show error in window
        this.emit('password_update_error', this.pPasswordErrors);
      }
    } else {
      this.changePage(1);
    }

    return true;
  }

  /**
   * Parent email query status
   */
  parentEmailQueryStatus(flag: boolean): void {
    if (this.pMode === 'parent_email' || this.pMode === 'parent_email_strong_coppa') {
      if (!flag) {
        if (this.pOpenWindow === 'reg_loading.window') {
          this.changePage(1);
        }
      } else {
        this.parentEmailNotNeeded();
        this.changePage(1);
      }
    } else {
      if (flag) {
        this.parentEmailNotNeeded();
      }
    }
  }

  /**
   * Parent email OK
   */
  parentEmailOk(): void {
    if (!Array.isArray(this.pRegProcess)) return;

    if (this.pMode === 'parent_email' || this.pMode === 'parent_email_strong_coppa') {
      const pos = this.pRegProcess.indexOf('reg_parent_email');
      if (pos >= 0 && pos < this.pRegProcess.length - 1) {
        const nextPage = this.pRegProcess[pos + 1];
        this.changePage(`${nextPage}.window`);
      }
    } else {
      if (this.pRegProcessLocation === this.pRegProcess.length) {
        // Would set session user_figure
        // session.set('user_figure', pPropsToServer.figure.duplicate())
        this.component?.sendFigureUpdateToServer(this.pPropsToServer);
        this.component?.updateState('start');
        this.closeFigureCreator();
      } else {
        const pos = this.pRegProcess.indexOf('reg_parent_email');
        if (pos >= 0 && pos < this.pRegProcess.length - 1) {
          const nextPage = this.pRegProcess[pos + 1];
          this.changePage(`${nextPage}.window`);
        }
      }
    }
  }

  /**
   * Parent email incorrect
   */
  parentEmailIncorrect(): boolean {
    if (this.pOpenWindow !== 'reg_parent_email.window') {
      this.changePage('reg_parent_email.window');
    }

    this.emit('alert', { msg: 'alert_reg_parent_email', id: 'parentemailincorrect', modal: true });
    return false;
  }

  /**
   * Open password update dialog
   */
  openPasswordUpdate(forced?: boolean, msg?: string): void {
    this.openPwdEmailUpdate('password', forced, msg);
  }

  /**
   * Open email update dialog
   */
  openEmailUpdate(forced?: boolean, msg?: string): void {
    this.openPwdEmailUpdate('email', forced, msg);
  }

  /**
   * Open password/email update dialog
   */
  openPwdEmailUpdate(type: 'password' | 'email', forced?: boolean, msg?: string): void {
    if (forced) {
      this.pPwdEmailUpdateForced = true;
    }

    const windowTitleStr = type === 'password' ? 'Change Password' : 'Change Email';
    const wndType: RegistrationWindow = type === 'password'
      ? 'reg_update_password.window'
      : 'reg_update_email.window';

    this.pTempPassword = {};
    this.pLastWindow = wndType;

    // Would create modal window
    // createWindow(pVerifyChangeWndID, VOID, 0, 0, #modal)
    // window.setProperty(#title, windowTitleStr)
    // window.merge('habbo_simple.window')
    // window.merge(wndType)
    // window.center()

    this.emit('open_update_dialog', {
      type,
      windowId: this.pVerifyChangeWndID,
      title: windowTitleStr,
      windowType: wndType,
      forced: this.pPwdEmailUpdateForced,
      message: msg,
    });
  }

  /**
   * Blink loading indicator
   */
  blinkLoading(): void {
    // Would toggle visibility of loading element
    this.emit('loading_blink');

    // Would set timeout to call again
    // delay(500, #blinkLoading)
  }

  /**
   * Define registration modes
   */
  defineModes(mode: RegistrationMode): void {
    this.pPropsToServer = {};
    this.pTempPassword = {};
    this.pPartChangeButtons = { partmodel: {}, partcolor: {} };
    this.pLastNameCheck = '';
    this.pMode = mode;
    this.pRegProcess = this.getRegProcessPages(mode);

    this.newFigureInformation();

    if (mode === 'registration' || mode === 'parent_email' || mode === 'parent_email_strong_coppa') {
      this.pNameChecked = false;
    } else {
      this.pNameChecked = true;
      this.getMyInformation();
    }
  }

  /**
   * Get registration process pages for a mode
   */
  private getRegProcessPages(mode: RegistrationMode): string[] {
    // These would come from variables
    const processes: Record<RegistrationMode, string[]> = {
      'registration': ['reg_welcome', 'reg_legal', 'reg_namepage', 'reg_infopage', 'reg_confirm', 'reg_done'],
      'update': ['reg_namepage_mission', 'reg_info_update'],
      'forced': ['reg_welcome', 'reg_namepage_mission', 'reg_info_update'],
      'parent_email': ['reg_welcome', 'reg_legal', 'reg_namepage', 'reg_infopage', 'reg_parent_email', 'reg_confirm', 'reg_done'],
      'parent_email_strong_coppa': ['reg_welcome', 'reg_legal', 'reg_age_check', 'reg_namepage', 'reg_infopage', 'reg_parent_email', 'reg_confirm', 'reg_done'],
      'parent_email_forced': ['reg_welcome', 'reg_namepage_mission', 'reg_parent_email', 'reg_info_update'],
      'parent_email_coppa_forced': ['reg_coppa_forced', 'reg_namepage_mission', 'reg_parent_email', 'reg_info_update'],
      'coppa_forced': ['reg_coppa_forced', 'reg_namepage_mission', 'reg_info_update'],
    };

    return processes[mode] || processes['registration'];
  }

  /**
   * Initialize new figure information
   */
  newFigureInformation(): void {
    this.pPropsToServer = {
      name: '',
      figure: {},
      sex: 'M',
      customData: '',
      email: '',
      birthday: '',
      has_read_agreement: '0',
      parentagree: 1,
      directMail: '0', // Would check session for conf_allow_direct_mail
    };
  }

  /**
   * Change window view
   */
  changeWindowView(windowName: RegistrationWindow): void {
    // Would create or update window
    // if (!windowExists(pWindowTitle)) {
    //   if (pMode === 'forced') {
    //     createWindow(pWindowTitle, 'habbo_simple.window', 0, 0, #modal)
    //   } else {
    //     createWindow(pWindowTitle, 'habbo_basic.window', 381, 73)
    //   }
    //   window.registerClient(me.getID())
    //   window.registerProcedure(#eventProcFigurecreator, ...)
    // } else {
    //   window.unmerge()
    // }
    // window.merge(windowName)

    this.pOpenWindow = windowName;
    this.emit('window_changed', { window: windowName, mode: this.pMode });
  }

  /**
   * Get my information from session
   */
  getMyInformation(): void {
    this.pPropsToServer = {};

    const props = ['name', 'password', 'figure', 'sex', 'customData', 'email', 'birthday', 'directMail'];

    // Would get from session
    // for (const prop of props) {
    //   if (session.exists('user_' + prop)) {
    //     const data = session.get('user_' + prop);
    //     this.pPropsToServer[prop] = data;
    //   } else {
    //     this.pPropsToServer[prop] = '';
    //   }
    // }

    // Remove arm items from figure
    if (typeof this.pPropsToServer.figure === 'object') {
      delete (this.pPropsToServer.figure as Record<string, unknown>)['li'];
      delete (this.pPropsToServer.figure as Record<string, unknown>)['ri'];
    }

    if (typeof this.pPropsToServer.figure === 'object') {
      this.pOldFigure = { ...(this.pPropsToServer.figure as Record<string, FigurePartData>) };
    }

    // Normalize sex
    const sex = String(this.pPropsToServer.sex || 'M')[0].toUpperCase();
    this.pPropsToServer.sex = sex === 'F' ? 'F' : 'M';
    this.pOldSex = this.pPropsToServer.sex;
  }

  /**
   * Set my data to form fields
   */
  setMyDataToFields(): void {
    // Would populate form fields based on current window
    this.emit('fields_updated', {
      window: this.pOpenWindow,
      mode: this.pMode,
      props: this.pPropsToServer,
      regProcessLocation: this.pRegProcessLocation,
      regProcessCount: this.pRegProcess.length,
    });
  }

  /**
   * Get my data from form fields
   */
  getMyDataFromFields(): boolean {
    // Would read form fields based on current window
    this.emit('fields_read_request', { window: this.pOpenWindow });
    return true;
  }

  /**
   * Update sex radio buttons
   */
  updateSexRadioButtons(): void {
    if (!this.pPropsToServer.sex) {
      this.pPropsToServer.sex = 'M';
    }

    this.emit('sex_buttons_updated', { sex: this.pPropsToServer.sex });
  }

  /**
   * Update checkbox button
   */
  updateCheckButton(element: string, prop: string, changeMode?: boolean): void {
    if (this.pPropsToServer[prop as keyof RegistrationProps] === undefined) {
      (this.pPropsToServer as Record<string, string>)[prop] = '0';
    }

    if (changeMode) {
      const current = (this.pPropsToServer as Record<string, string>)[prop];
      (this.pPropsToServer as Record<string, string>)[prop] = current === '1' ? '0' : '1';
    }

    this.emit('checkbox_updated', {
      element,
      prop,
      value: (this.pPropsToServer as Record<string, string>)[prop],
    });
  }

  /**
   * Create default figure
   */
  createDefaultFigure(random?: boolean): void {
    // Would use Figure_System to create default figure
    this.pPropsToServer.figure = {};

    if (this.pOldFigure && this.pOldSex === this.pPropsToServer.sex) {
      this.pPropsToServer.figure = { ...this.pOldFigure };

      for (const part of ALL_BODY_PARTS) {
        const partData = (this.pPropsToServer.figure as Record<string, FigurePartData>)[part];
        if (partData) {
          this.setPartModel(part, partData.model);
          this.setPartColor(part, partData.color);
        }
      }

      this.updateFigurePreview();
      this.updateAllPreviewIcons();
      return;
    }

    // Create random or default parts
    for (const part of EDITABLE_PARTS) {
      // Would get part from Figure_System
      const model = '001';
      const color = '#ffffff';
      const setId = 1;
      const colorId = 1;

      this.setPartModel(part, model);
      this.setPartColor(part, color);

      (this.pPropsToServer.figure as Record<string, FigurePartData>)[part] = {
        model,
        color,
        setid: setId,
        colorid: colorId,
      };

      this.setIndexNumOfPartOrColor('partcolor', part, 0);
    }

    this.updateFigurePreview();
    this.updateAllPreviewIcons();
  }

  /**
   * Create template human for preview
   */
  createTemplateHuman(): void {
    if (this.pBodyPartObjects) {
      return;
    }

    this.pPeopleSize = 'h';
    this.pFlipList = [0, 1, 2, 3, 2, 1, 0, 7];
    this.pBodyPartObjects = {};

    for (const part of ALL_BODY_PARTS) {
      const partData = (this.pPropsToServer.figure as Record<string, FigurePartData>)?.[part];
      const model = partData?.model || '001';
      const color = partData?.color || '#ffffff';

      // Would create body part object
      // const partObj = createObject(#temp, 'Bodypart Template Class')
      // partObj.define(part, model, color, 1, 'std', this)
      // this.pBodyPartObjects[part] = partObj
    }

    this.emit('template_human_created', this.pBodyPartObjects);
  }

  /**
   * Get set ID for a part
   */
  getSetId(part: BodyPartType): number {
    const figure = this.pPropsToServer.figure as Record<string, FigurePartData>;
    if (!figure?.[part]?.setid) {
      console.error(`Part setid missing: ${part}`);
      return 0;
    }
    return figure[part].setid!;
  }

  /**
   * Update figure preview
   */
  updateFigurePreview(): void {
    if (!this.pBodyPartObjects) return;

    // Would render human to preview image
    this.emit('figure_preview_updated', {
      parts: ALL_BODY_PARTS,
      size: this.pPeopleSize,
    });
  }

  /**
   * Update all preview icons
   */
  updateAllPreviewIcons(): void {
    for (const part of EDITABLE_PARTS) {
      this.setIndexNumOfPartOrColor('partcolor', part, 0);
      this.setIndexNumOfPartOrColor('partmodel', part, 0);

      const figure = this.pPropsToServer.figure as Record<string, FigurePartData>;
      if (figure?.[part]?.color) {
        this.updatePartColorPreview(part, figure[part].color);

        // Get preview parts based on type
        let temp: Record<string, string> = {};
        switch (part) {
          case 'hd':
            temp = {
              hd: figure['hd']?.model || '',
              ey: figure['ey']?.model || '',
              fc: figure['fc']?.model || '',
            };
            break;
          case 'ch':
            temp = {
              ls: figure['ls']?.model || '',
              ch: figure['ch']?.model || '',
              rs: figure['rs']?.model || '',
            };
            break;
          default:
            temp[part] = figure[part]?.model || '';
        }

        this.updatePartPreview(part, temp);
      }
    }
  }

  /**
   * Update part preview
   */
  updatePartPreview(part: BodyPartType, changingPartPropList: Record<string, string>): void {
    this.emit('part_preview_updated', { part, parts: changingPartPropList });
  }

  /**
   * Update part color preview
   */
  updatePartColorPreview(part: BodyPartType, color?: string): void {
    this.emit('part_color_preview_updated', { part, color: color || '#ffffff' });
  }

  /**
   * Set part color
   */
  setPartColor(part: BodyPartType, color: string): void {
    if (this.pBodyPartObjects?.[part]) {
      this.pBodyPartObjects[part].setColor(color);
    }
  }

  /**
   * Set part model
   */
  setPartModel(part: BodyPartType, model: string): void {
    if (this.pBodyPartObjects?.[part]) {
      this.pBodyPartObjects[part].setModel(model);
    }
  }

  /**
   * Set index number for part or color
   */
  setIndexNumOfPartOrColor(
    change: 'partmodel' | 'partcolor',
    part: BodyPartType,
    orderNum: number,
    maxValue?: number
  ): number {
    if (!this.pPartChangeButtons[change]) {
      this.pPartChangeButtons[change] = {};
    }

    if (!this.pPartChangeButtons[change][part]) {
      this.pPartChangeButtons[change][part] = 1;
    }

    if (orderNum === 0) {
      this.pPartChangeButtons[change][part] = 1;
    } else {
      const current = this.pPartChangeButtons[change][part];
      const newValue = current + orderNum;

      if (maxValue !== undefined) {
        if (newValue > maxValue) {
          this.pPartChangeButtons[change][part] = 1;
        } else if (newValue < 1) {
          this.pPartChangeButtons[change][part] = maxValue;
        } else {
          this.pPartChangeButtons[change][part] = newValue;
        }
      } else {
        this.pPartChangeButtons[change][part] = newValue;
      }
    }

    return this.pPartChangeButtons[change][part];
  }

  /**
   * Change part
   */
  changePart(part: BodyPartType, buttonDir: number): void {
    // Would get part info from Figure_System
    // const setId = this.getSetId(part);
    // const maxValue = figureSystem.getCountOfPart(part, this.pPropsToServer.sex);
    // const partIndexNum = this.setIndexNumOfPartOrColor('partmodel', part, buttonDir, maxValue);
    // const partProps = figureSystem.getModelOfPartByOrderNum(part, partIndexNum, this.pPropsToServer.sex);

    this.updateFigurePreview();
    this.emit('part_changed', { part, direction: buttonDir });
  }

  /**
   * Change part color
   */
  changePartColor(part: BodyPartType, buttonDir: number): void {
    // Would get color info from Figure_System
    // const setId = this.getSetId(part);
    // const maxValue = figureSystem.getCountOfPartColors(part, setId, this.pPropsToServer.sex);
    // const colorIndexNum = this.setIndexNumOfPartOrColor('partcolor', part, buttonDir, maxValue);
    // const partProps = figureSystem.getColorOfPartByOrderNum(part, colorIndexNum, setId, this.pPropsToServer.sex);

    this.updateFigurePreview();
    this.emit('part_color_changed', { part, direction: buttonDir });
  }

  /**
   * Check name validity
   */
  checkName(): boolean {
    if (this.pMode === 'registration' || this.pMode === 'parent_email' || this.pMode === 'parent_email_strong_coppa') {
      const name = (this.pPropsToServer.name || '').trim().split(/\s+/)[0] || '';
      this.pPropsToServer.name = name;

      if (name.length === 0) {
        this.emit('alert', { msg: 'Alert_NoNameSet', id: 'nonameset', modal: true });
        return false;
      }

      const minLength = 3; // Would get from variable name.length.min
      if (name.length < minLength) {
        this.emit('alert', { msg: 'Alert_YourNameIstooShort', id: 'name2short', modal: true });
        return false;
      }

      // Check if name changed
      if (this.pLastNameCheck !== name) {
        if (!this.component?.checkUserName(name)) {
          return false;
        }
      }
    }

    // Would set session userName
    // session.set(#userName, name)
    this.pNameChecked = true;
    return true;
  }

  /**
   * Check passwords match
   */
  checkPasswords(pwd1?: string, pwd2?: string): boolean {
    if (!pwd1 || !pwd2) {
      this.pErrorMsg += 'Wrong password\n';
      return false;
    }

    if (pwd1.length < 1 || pwd2.length < 1 || pwd1 !== pwd2) {
      this.pErrorMsg += 'Wrong password\n';
      return false;
    }

    return true;
  }

  /**
   * Validate birthday
   */
  validateBirthday(year: number, month: number, day: number): boolean {
    if (!day || day < 1 || day > 31) return false;
    if (!month || month < 1 || month > 12) return false;
    if (!year || year < 1900 || year > 2100) return false;

    // Would also check against server date
    return true;
  }

  /**
   * Validate email
   */
  validateEmail(email: string): boolean {
    if (email.length <= 6 || !email.includes('@')) {
      return false;
    }

    const atPos = email.indexOf('@');
    let hasDotAfterAt = false;

    for (let i = atPos + 1; i < email.length; i++) {
      if (email[i] === '.') {
        hasDotAfterAt = true;
      }
      if (email[i] === '@') {
        return false;
      }
    }

    return hasDotAfterAt;
  }

  /**
   * Check agree to terms
   */
  checkAgreeTerms(): boolean {
    // Would check if terms scrolled to bottom
    if (this.pPropsToServer.has_read_agreement !== '1') {
      this.pErrorMsg += 'You must agree to the terms\n';
      return false;
    }
    return true;
  }

  /**
   * Parent email not needed
   */
  parentEmailNotNeeded(): void {
    const pos = this.pRegProcess.indexOf('reg_parent_email');
    if (pos >= 0) {
      this.pRegProcess.splice(pos, 1);
    }
  }

  /**
   * Clear username field
   */
  clearUserNameField(): void {
    this.pNameChecked = false;
    this.emit('clear_username_field');
  }

  /**
   * Clear password fields
   */
  clearPasswordFields(): void {
    this.pTempPassword['char_pw_field'] = '';
    this.pTempPassword['char_pwagain_field'] = '';
    this.emit('clear_password_fields');
  }

  /**
   * Registration ready - send data
   */
  registrationReady(): void {
    // Would set session data
    // session.set(#userName, pPropsToServer.name)
    // session.set(#Password, pPropsToServer.password)
    // session.set('user_figure', pPropsToServer.figure.duplicate())

    if (this.pMode === 'registration' || this.pMode === 'parent_email' || this.pMode === 'parent_email_strong_coppa') {
      // Would create figure preview
      this.component?.sendNewFigureDataToServer(this.pPropsToServer);
    } else {
      this.component?.sendFigureUpdateToServer(this.pPropsToServer);
    }
  }

  /**
   * Change page
   */
  changePage(param: number | string): void {
    if (!this.pRegProcess || this.pRegProcess.length === 0) {
      console.error('Registration process not found');
      return;
    }

    if (typeof param === 'string') {
      this.getMyDataFromFields();
      this.enterPage(param as RegistrationWindow);
    } else {
      if (param > 0) {
        if (!this.leavePage(this.pOpenWindow)) {
          return;
        }
      } else {
        this.getMyDataFromFields();
      }

      this.pRegProcessLocation += param;

      if (this.pRegProcessLocation < 1) {
        this.pRegProcessLocation = 1;
      }
      if (this.pRegProcessLocation > this.pRegProcess.length) {
        this.pRegProcessLocation = this.pRegProcess.length;
      }

      const nextWindow = this.pRegProcess[this.pRegProcessLocation - 1];
      this.enterPage(`${nextWindow}.window` as RegistrationWindow);
    }
  }

  /**
   * Leave current page - validate and process
   */
  leavePage(currentWindow: RegistrationWindow | ''): boolean {
    switch (currentWindow) {
      case 'reg_legal.window':
        this.pErrorMsg = '';
        if (!this.checkAgreeTerms()) {
          this.emit('alert', { title: 'alert_reg_t', msg: this.pErrorMsg, id: 'problems', modal: true });
          return false;
        }
        this.getMyDataFromFields();
        break;

      case 'reg_namepage.window':
        this.getMyDataFromFields();
        if (!this.pNameChecked) {
          if (this.checkName()) {
            this.changeWindowView('reg_loading.window');
          }
          return false;
        }
        break;

      case 'reg_namepage_mission.window':
        this.getMyDataFromFields();
        break;

      case 'reg_infopage.window':
      case 'reg_infopage_no_age.window':
        this.pErrorMsg = '';
        let proceed = true;

        // Would validate password, birthday, email
        if (!this.checkPasswords(
          this.pTempPassword['char_pw_field'],
          this.pTempPassword['char_pwagain_field']
        )) {
          proceed = false;
        }

        if (this.pPasswordErrors) {
          proceed = false;
          this.pErrorMsg += this.pPasswordErrors + '\n';
          this.pPasswordErrors = '';
        }

        if (!proceed) {
          this.emit('alert', { title: 'alert_reg_t', msg: this.pErrorMsg, id: 'problems', modal: true });
          return false;
        }

        this.pPropsToServer.password = this.pTempPassword['char_pw_field'];
        this.getMyDataFromFields();

        if (!this.pPasswordChecked) {
          this.pPasswordErrors = '';
          this.pErrorMsg = '';
          this.component?.sendValidatePassword(this.pPropsToServer.password || '');
          return false;
        }

        if (!this.pEmailChecked) {
          this.component?.checkEmailAddress(this.pPropsToServer.email || '');
          return false;
        }
        break;

      case 'reg_confirm.window':
        // Would check COPPA
        // if (session.get('conf_coppa')) {
        //   this.component?.checkAge(birthday);
        //   this.changeWindowView('reg_loading.window');
        //   return false;
        // }
        break;

      case 'reg_parent_email.window':
        // Would validate parent email and send
        break;

      case 'reg_age_check.window':
        // Would validate age and send check
        break;
    }

    return true;
  }

  /**
   * Enter a page
   */
  enterPage(windowName: RegistrationWindow): boolean {
    this.changeWindowView(windowName);

    switch (windowName) {
      case 'reg_legal.window':
        this.setMyDataToFields();
        this.updateCheckButton('char_terms_checkbox', 'has_read_agreement');
        break;

      case 'reg_namepage.window':
        this.setMyDataToFields();
        if (this.pMode === 'registration' || this.pMode === 'parent_email' || this.pMode === 'parent_email_strong_coppa') {
          this.pNameChecked = false;
        } else {
          this.pNameChecked = true;
        }

        if (Object.keys(this.pPropsToServer.figure || {}).length === 0) {
          this.createDefaultFigure();
        }
        this.createTemplateHuman();
        this.updateSexRadioButtons();
        this.updateFigurePreview();
        this.updateAllPreviewIcons();
        break;

      case 'reg_namepage_mission.window':
        this.setMyDataToFields();
        if (Object.keys(this.pPropsToServer.figure || {}).length === 0) {
          this.createDefaultFigure();
        }
        this.createTemplateHuman();
        this.updateSexRadioButtons();
        this.updateFigurePreview();
        this.updateAllPreviewIcons();
        break;

      case 'reg_infopage.window':
        this.pPasswordChecked = false;
        this.setMyDataToFields();
        if (this.pMode === 'update') {
          this.emit('alert', { title: 'reg_note_title', msg: 'reg_note_text', id: 'pwnote', modal: true });
        }
        break;

      case 'reg_infopage_no_age.window':
        this.pPasswordChecked = false;
        this.setMyDataToFields();
        this.updateCheckButton('char_spam_checkbox', 'directMail');
        break;

      case 'reg_info_update.window':
        this.setMyDataToFields();
        this.updateCheckButton('char_spam_checkbox', 'directMail');
        break;

      case 'reg_confirm.window':
        this.updateCheckButton('char_spam_checkbox', 'directMail');
        this.setMyDataToFields();
        break;

      case 'reg_done.window':
        this.registrationReady();
        // Would render final preview
        break;

      case 'reg_welcome.window':
        this.setMyDataToFields();
        break;

      case 'reg_age_check.window':
        this.setMyDataToFields();
        break;

      default:
        this.setMyDataToFields();
    }

    return true;
  }

  /**
   * Flip image horizontally
   */
  flipImage(img: HTMLCanvasElement | ImageData): HTMLCanvasElement | null {
    if (!this.canvas || !this.ctx) return null;

    const width = img instanceof HTMLCanvasElement ? img.width : img.width;
    const height = img instanceof HTMLCanvasElement ? img.height : img.height;

    this.canvas.width = width;
    this.canvas.height = height;

    this.ctx.translate(width, 0);
    this.ctx.scale(-1, 1);

    if (img instanceof HTMLCanvasElement) {
      this.ctx.drawImage(img, 0, 0);
    } else {
      this.ctx.putImageData(img, 0, 0);
    }

    this.ctx.setTransform(1, 0, 0, 1, 0, 0);

    return this.canvas;
  }

  /**
   * Response to account update
   */
  responseToAccountUpdate(status: string): void {
    switch (status) {
      case AccountUpdateStatus.SUCCESS:
        this.emit('account_update_success');
        break;
      case AccountUpdateStatus.INCORRECT_PASSWORD:
        this.emit('account_update_error', 'Incorrect password');
        break;
      case AccountUpdateStatus.INCORRECT_BIRTHDAY:
        this.emit('account_update_error', 'Incorrect birthday');
        break;
      default:
        console.warn('Invalid parameter in ACCOUNT_UPDATE_STATUS');
    }

    if (this.pPwdEmailUpdateForced) {
      // Would deactivate cancel button
    }
  }

  /**
   * Handle UI event from figure creator
   */
  handleFigureCreatorEvent(event: string, spriteId: string, param?: unknown): void {
    if (event === 'mouseUp') {
      switch (spriteId) {
        case 'close':
        case 'reg_cancel_button':
        case 'reg_exit_button':
          if (this.pMode === 'registration' || this.pMode === 'parent_email' || this.pMode === 'parent_email_strong_coppa') {
            if (this.pRegProcessLocation === this.pRegProcess.length) {
              this.registrationReady();
            }
          }
          this.component?.closeFigureCreator();
          this.component?.updateState('start');
          break;

        case 'reg_underage_button':
          // Would check COPPA
          this.pPropsToServer.parentagree = 1;
          this.changePage(1);
          break;

        case 'reg_olderage_button':
          this.pPropsToServer.parentagree = 0;
          this.changePage(1);
          break;

        case 'reg_next_button':
          this.changePage(1);
          break;

        case 'reg_prev_button':
          this.changePage(-1);
          break;

        case 'reg_done_button':
          if (this.leavePage(this.pOpenWindow)) {
            // Would set session user_figure
            this.component?.sendFigureUpdateToServer(this.pPropsToServer);
            this.component?.updateState('start');
            this.closeFigureCreator();
          }
          break;

        case 'reg_ready':
          this.closeFigureCreator();
          this.component?.updateState('start');
          this.component?.tryLoginAfterRegistration();
          break;

        case 'char_sex_m':
          this.pPropsToServer.sex = 'M';
          this.createDefaultFigure(true);
          this.updateSexRadioButtons();
          break;

        case 'char_sex_f':
          this.pPropsToServer.sex = 'F';
          this.createDefaultFigure(true);
          this.updateSexRadioButtons();
          break;

        case 'char_spam_checkbox':
          this.updateCheckButton('char_spam_checkbox', 'directMail', true);
          break;

        case 'char_terms_checkbox':
          this.updateCheckButton('char_terms_checkbox', 'has_read_agreement', true);
          break;

        case 'char_name_field':
          if (this.pNameChecked) {
            if (this.pMode === 'registration' || this.pMode === 'parent_email' || this.pMode === 'parent_email_strong_coppa') {
              this.pNameChecked = false;
            }
          }
          break;

        case 'char_email_field':
          this.pEmailChecked = false;
          break;

        default:
          // Handle part change buttons
          if (spriteId.includes('change') && spriteId.includes('button')) {
            const parts = spriteId.split('.');
            const part = parts[1] as BodyPartType;
            const buttonType = spriteId.includes('left') ? -1 : 1;

            if (!spriteId.includes('color')) {
              this.changePart(part, buttonType);
            } else {
              this.changePartColor(part, buttonType);
            }
          }
      }
    } else if (event === 'keyDown') {
      this.handleKeyDown(spriteId, param as string);
    }
  }

  /**
   * Handle key down in form fields
   */
  handleKeyDown(fieldId: string, key: string): void {
    const validNameChars = DEFAULT_PERMITTED_NAME_CHARS;
    const validPasswordChars = DEFAULT_PERMITTED_PASSWORD_CHARS;
    const deniedNameChars = DEFAULT_DENIED_NAME_CHARS;

    switch (fieldId) {
      case 'char_name_field':
        if (!validNameChars.includes(key.toLowerCase())) {
          this.emit('key_rejected', { field: fieldId, key, validChars: validNameChars });
        }
        break;

      case 'char_pw_field':
      case 'char_pwagain_field':
        if (!this.pNameChecked) {
          if (!this.checkName()) {
            return;
          }
        }

        if (!this.pTempPassword[fieldId]) {
          this.pTempPassword[fieldId] = '';
        }

        if (!validPasswordChars.includes(key.toLowerCase())) {
          this.emit('key_rejected', { field: fieldId, key, validChars: validPasswordChars });
          return;
        }

        // Would handle backspace, delete, etc
        this.pPasswordChecked = false;
        break;
    }
  }

  /**
   * Update password asterisks (mask password)
   */
  updatePasswordAsterisks(windowId: string, elementId: string): void {
    // Would read text from element and update pTempPassword
    // Then replace text with asterisks
    this.emit('password_masked', { windowId, elementId });
  }

  /**
   * Get current mode
   */
  getMode(): RegistrationMode {
    return this.pMode;
  }

  /**
   * Get current open window
   */
  getOpenWindow(): RegistrationWindow | '' {
    return this.pOpenWindow;
  }

  /**
   * Get props to server
   */
  getPropsToServer(): RegistrationProps {
    return this.pPropsToServer;
  }

  /**
   * Set props from external source
   */
  setPropsToServer(props: Partial<RegistrationProps>): void {
    this.pPropsToServer = { ...this.pPropsToServer, ...props };
  }

  /**
   * Set temp password
   */
  setTempPassword(field: string, value: string): void {
    this.pTempPassword[field] = value;
  }

  /**
   * Get temp password
   */
  getTempPassword(field: string): string {
    return this.pTempPassword[field] || '';
  }
}
