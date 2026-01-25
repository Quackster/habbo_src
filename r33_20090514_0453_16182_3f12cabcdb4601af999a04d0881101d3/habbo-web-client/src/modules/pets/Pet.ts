/**
 * Pet Class - Main pet entity
 *
 * Ported from: hh_pets_common/Cast External ParentScript 1 - Pet Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { getVariable } from '../../core/VariableContainer';
import { getConnection } from '../../managers/ConnectionManager';
import { PetPart } from './PetPart';
import {
  PetData,
  PetInfo,
  PetAction,
  PetPartType,
  PetDefinition,
  OffsetList,
  ScreenLocation,
  FLIP_LIST,
  DEFAULT_CANVAS_SIZE,
  MOVE_TIME,
  ANIM_COUNTER_MOD,
} from './types';

/**
 * Geometry interface for coordinate conversion
 */
interface RoomGeometry {
  pXFactor: number;
  pYFactor: number;
  pHFactor: number;
  getScreenCoordinate(x: number, y: number, h: number): ScreenLocation;
}

/**
 * Pet entity class
 * Represents a pet in the room with rendering and animation
 */
export class Pet extends BaseObject {
  // Identification
  private name: string = '';
  private petClass: string = '';
  private custom: string = '';
  private idPrefix: string = '';
  private webID: string = '-1';
  private race: string = '';

  // Parts
  private partList: PetPart[] = [];
  private partIndex: Record<string, number> = {};
  pFlipList: number[] = FLIP_LIST;

  // Location
  private locX: number = 0;
  private locY: number = 0;
  private locH: number = 0;
  pLocFix: { x: number; y: number } = { x: 0, y: -8 };
  private screenLoc: ScreenLocation = [0, 0, 0];
  private startLScreen: ScreenLocation = [0, 0, 0];
  private destLScreen: ScreenLocation = [0, 0, 0];
  private restingHeight: number = 0.0;

  // Rendering
  pBuffer: CanvasRenderingContext2D | null = null;
  private canvas: HTMLCanvasElement | null = null;
  private canvasSize: [number, number, number, number] = [...DEFAULT_CANVAS_SIZE];
  pUpdateRect: { x: number; y: number; width: number; height: number } = {
    x: 0,
    y: 0,
    width: 0,
    height: 0,
  };
  private alphaColor: string = 'rgba(255, 255, 255, 0)';
  private shadowFix: number = 0;

  // Animation
  pAnimCounter: number = 0;
  private moveStart: number = 0;
  private moveTime: number = MOVE_TIME;
  private eyesClosed: boolean = false;
  private sync: boolean = true;
  private changes: boolean = true;

  // State
  pMainAction: PetAction = 'std';
  pDirection: number = 0;
  private waving: boolean = false;
  pMoving: boolean = false;
  private talking: boolean = false;
  private sniffing: boolean = false;
  private visible: boolean = true;
  private flipH: boolean = false;

  // Geometry
  private geometry: RoomGeometry | null = null;
  pXFactor: number = 32;
  private yFactor: number = 16;
  private hFactor: number = 8;
  private correctLocZ: boolean = true;

  // Configuration
  pMemberNamePrefix: string = 's_p_';
  pOffsetList: OffsetList = {};
  pOffsetListSmall: OffsetList = {};
  private petDefinitions: Record<string, PetDefinition> = {};

  // Info
  private infoStruct: PetInfo = {
    name: '',
    class: '',
    custom: '',
    image: null,
  };

  // Asset callbacks
  private getAsset:
    | ((
        name: string
      ) => { image: ImageData; regPoint: { x: number; y: number } } | null)
    | null = null;
  private applyPalette:
    | ((image: ImageData, palette: string, color: string) => ImageData | null)
    | null = null;

  construct(): void {
    super.construct();

    this.name = '';
    this.idPrefix = '';
    this.partList = [];
    this.partIndex = {};
    this.pFlipList = [...FLIP_LIST];
    this.pLocFix = { x: 0, y: -8 };
    this.pUpdateRect = { x: 0, y: 0, width: 0, height: 0 };
    this.screenLoc = [0, 0, 0];
    this.startLScreen = [0, 0, 0];
    this.destLScreen = [0, 0, 0];
    this.restingHeight = 0.0;
    this.pAnimCounter = 0;
    this.moveStart = 0;
    this.moveTime = MOVE_TIME;
    this.eyesClosed = false;
    this.sync = true;
    this.changes = true;
    this.pMainAction = 'std';
    this.waving = false;
    this.pMoving = false;
    this.sniffing = false;
    this.talking = false;
    this.alphaColor = 'rgba(255, 255, 255, 0)';
    this.infoStruct = { name: '', class: '', custom: '', image: null };
    this.webID = '-1';
  }

  deconstruct(): void {
    this.geometry = null;
    this.partList = [];
    this.infoStruct = { name: '', class: '', custom: '', image: null };
    this.canvas = null;
    this.pBuffer = null;
    super.deconstruct();
  }

  /**
   * Set geometry reference
   */
  setGeometry(geometry: RoomGeometry): void {
    this.geometry = geometry;
    this.pXFactor = geometry.pXFactor;
    this.yFactor = geometry.pYFactor;
    this.hFactor = geometry.pHFactor;

    if (this.pXFactor === 32) {
      this.pMemberNamePrefix = 's_p_';
      this.correctLocZ = true;
    } else {
      this.pMemberNamePrefix = 'p_';
      this.correctLocZ = true;
    }
  }

  /**
   * Set pet definitions
   */
  setPetDefinitions(definitions: Record<string, PetDefinition>): void {
    this.petDefinitions = definitions;
  }

  /**
   * Set asset callbacks
   */
  setAssetCallbacks(
    getAsset: (
      name: string
    ) => { image: ImageData; regPoint: { x: number; y: number } } | null,
    applyPalette: (
      image: ImageData,
      palette: string,
      color: string
    ) => ImageData | null
  ): void {
    this.getAsset = getAsset;
    this.applyPalette = applyPalette;
  }

  /**
   * Define pet from data
   */
  define(data: PetData): boolean {
    this.setup(data);

    // Create canvas
    this.canvas = document.createElement('canvas');
    this.canvas.width = this.canvasSize[0];
    this.canvas.height = this.canvasSize[1];
    this.pBuffer = this.canvas.getContext('2d');

    return true;
  }

  /**
   * Setup pet from data
   */
  private setup(data: PetData): void {
    this.name = data.name;
    this.petClass = data.class;
    this.pDirection = data.direction[0];
    this.locX = data.x;
    this.locY = data.y;
    this.locH = data.h;

    if (data.webID) {
      this.webID = data.webID;
    }

    // Parse figure
    const figureParts = data.figure.split(' ');
    this.race = figureParts[0] || '0';

    // Get offsets for this race
    this.pOffsetList = this.getOffsetList('large');
    this.pOffsetListSmall = this.getOffsetList('small');

    // Get custom text
    this.custom = this.race + '_' + (figureParts[1] || '0');

    // Handle ID prefix in name
    const delimPos = this.name.indexOf('\x04');
    if (delimPos !== -1) {
      this.idPrefix = this.name.substring(0, delimPos + 1);
      this.name = this.name.substring(delimPos + 1);
    }

    this.canvasSize = [...DEFAULT_CANVAS_SIZE];

    // Create part lists
    if (!this.setPartLists(data.figure)) {
      console.error("Couldn't create part lists!");
      return;
    }

    this.resetValues(this.locX, this.locY, this.locH, this.pDirection, this.pDirection);
    this.refresh(this.locX, this.locY, this.locH);
    this.sync = false;

    // Update info struct
    this.infoStruct = {
      name: this.name,
      class: this.petClass,
      custom: this.custom,
      image: null,
    };
  }

  /**
   * Update pet (called each frame)
   */
  update(): void {
    this.sync = !this.sync;
    if (this.sync) {
      this.prepare();
    } else {
      this.render();
    }
  }

  /**
   * Get web ID
   */
  getWebID(): string {
    return this.webID;
  }

  /**
   * Reset pet values
   */
  resetValues(
    x: number,
    y: number,
    h: number,
    dirHead: number,
    dirBody: number
  ): void {
    this.waving = false;
    this.pMoving = false;
    this.sniffing = false;

    // Reset all parts
    for (const part of this.partList) {
      part.reset();
    }

    if (this.geometry) {
      if (this.correctLocZ) {
        this.screenLoc = this.geometry.getScreenCoordinate(
          x,
          y,
          h + this.restingHeight
        );
      } else {
        this.screenLoc = this.geometry.getScreenCoordinate(x, y, h);
      }
    }

    this.pMainAction = 'std';
    this.locX = x;
    this.locY = y;
    this.locH = h;
    this.restingHeight = 0.0;

    // Set body direction for all parts
    for (const part of this.partList) {
      part.defineDir(dirBody);
    }

    // Handle head direction when flipped
    if (dirBody !== FLIP_LIST[dirBody]) {
      if (dirBody !== dirHead) {
        switch (dirHead) {
          case 4:
            dirHead = 2;
            break;
          case 5:
            dirHead = 1;
            break;
          case 6:
            dirHead = 4;
            break;
          case 7:
            dirHead = 5;
            break;
        }
      }
    }

    // Set head direction
    const headIndex = this.partIndex['hd'];
    if (headIndex !== undefined) {
      this.partList[headIndex].defineDir(dirHead);
    }

    this.pDirection = dirBody;
  }

  /**
   * Refresh pet
   */
  refresh(x: number, y: number, h: number): void {
    this.arrangeParts();
    this.changes = true;
  }

  /**
   * Select pet (double-click handler)
   */
  select(): boolean {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send('GETPETSTAT', { integer: parseInt(this.webID, 10), string: this.name });
    }
    return true;
  }

  /**
   * Get class
   */
  getClass(): string {
    return 'pet';
  }

  /**
   * Get name
   */
  getName(): string {
    return this.name;
  }

  /**
   * Set part model
   */
  setPartModel(part: string, model: string): void {
    const index = this.partIndex[part];
    if (index !== undefined) {
      this.partList[index].setModel(model);
    }
  }

  /**
   * Set part color
   */
  setPartColor(part: string, color: string): void {
    const index = this.partIndex[part];
    if (index !== undefined) {
      this.partList[index].setColor(color);
    }
  }

  /**
   * Get property
   */
  getProperty(propId: string): unknown {
    switch (propId) {
      case 'loc':
        return [this.locX, this.locY, this.locH];
      case 'moving':
        return this.pMoving;
      default:
        return 0;
    }
  }

  /**
   * Get custom text
   */
  getCustom(): string {
    return this.custom;
  }

  /**
   * Get location
   */
  getLocation(): [number, number, number] {
    return [this.locX, this.locY, this.locH];
  }

  /**
   * Get screen location
   */
  getScrLocation(): ScreenLocation {
    return this.screenLoc;
  }

  /**
   * Get tile center
   */
  getTileCenter(): { x: number; y: number } {
    return {
      x: this.screenLoc[0] + this.pXFactor / 2,
      y: this.screenLoc[1],
    };
  }

  /**
   * Get part location
   */
  getPartLocation(part: string): { x: number; y: number } {
    return this.getTileCenter();
  }

  /**
   * Get direction
   */
  getDirection(): number {
    return this.pDirection;
  }

  /**
   * Get part member
   */
  getPartMember(part: string): string | null {
    const index = this.partIndex[part];
    if (index !== undefined) {
      return this.partList[index].getCurrentMember();
    }
    return null;
  }

  /**
   * Get part color
   */
  getPartColor(part: string): string {
    const index = this.partIndex[part];
    if (index !== undefined) {
      return this.partList[index].getColor();
    }
    return '#FFC7C7';
  }

  /**
   * Get picture
   */
  getPicture(canvas?: HTMLCanvasElement): HTMLCanvasElement {
    const targetCanvas = canvas || document.createElement('canvas');
    if (!canvas) {
      targetCanvas.width = this.canvasSize[0];
      targetCanvas.height = this.canvasSize[1];
    }

    const ctx = targetCanvas.getContext('2d');
    if (!ctx) return targetCanvas;

    if (!this.infoStruct.image) {
      // Render parts in order: tail, body, head
      const partOrder: PetPartType[] = ['tl', 'bd', 'hd'];
      for (const partSymbol of partOrder) {
        const index = this.partIndex[partSymbol];
        if (index !== undefined && this.getAsset && this.applyPalette) {
          this.partList[index].copyPicture(
            ctx,
            this.getAsset,
            this.applyPalette,
            '2',
            'p',
            'std',
            '0',
            this.pOffsetList,
            this.pOffsetListSmall
          );
        }
      }
    }

    return this.flipImage(targetCanvas);
  }

  /**
   * Get info
   */
  getInfo(): PetInfo {
    return this.infoStruct;
  }

  /**
   * Close eyes
   */
  closeEyes(): void {
    const headIndex = this.partIndex['hd'];
    if (headIndex !== undefined) {
      this.partList[headIndex].defineAct('eyb');
    }
    this.eyesClosed = true;
    this.changes = true;
  }

  /**
   * Open eyes
   */
  openEyes(): void {
    const headIndex = this.partIndex['hd'];
    if (headIndex !== undefined) {
      this.partList[headIndex].defineAct('std');
    }
    this.eyesClosed = false;
    this.changes = true;
  }

  /**
   * Show pet
   */
  show(): void {
    this.visible = true;
  }

  /**
   * Hide pet
   */
  hide(): void {
    this.visible = false;
  }

  /**
   * Is visible
   */
  isVisible(): boolean {
    return this.visible;
  }

  /**
   * Prepare frame (first half of update)
   */
  private prepare(): void {
    this.pAnimCounter = (this.pAnimCounter + 1) % ANIM_COUNTER_MOD;

    // Eye blinking
    if (this.eyesClosed) {
      this.openEyes();
    } else if (Math.random() < 0.033) {
      this.closeEyes();
    }

    // Talking animation
    if (this.talking && Math.random() > 0.33) {
      const headIndex = this.partIndex['hd'];
      if (headIndex !== undefined) {
        this.partList[headIndex].defineAct('spk');
      }
      this.changes = true;
    }

    // Tail waving
    if (this.waving) {
      const tailIndex = this.partIndex['tl'];
      if (tailIndex !== undefined) {
        this.partList[tailIndex].defineAct('wav');
      }
      this.changes = true;
    }

    // Sniffing
    if (this.sniffing) {
      const headIndex = this.partIndex['hd'];
      if (headIndex !== undefined) {
        this.partList[headIndex].defineAct('snf');
      }
      this.changes = true;
    }

    // Action animations
    const bodyIndex = this.partIndex['bd'];
    if (bodyIndex !== undefined) {
      switch (this.pMainAction) {
        case 'scr':
          this.partList[bodyIndex].defineAct('scr');
          this.changes = true;
          break;
        case 'bnd':
          this.partList[bodyIndex].defineAct('bnd');
          this.changes = true;
          break;
        case 'jmp':
          this.partList[bodyIndex].defineAct('jmp');
          this.changes = true;
          break;
        case 'pla':
          this.partList[bodyIndex].defineAct('pla');
          this.changes = true;
          break;
      }
    }

    // Movement interpolation
    if (this.pMoving) {
      const factor = Math.min(1.0, (Date.now() - this.moveStart) / this.moveTime);
      this.screenLoc = [
        (this.destLScreen[0] - this.startLScreen[0]) * factor + this.startLScreen[0],
        (this.destLScreen[1] - this.startLScreen[1]) * factor + this.startLScreen[1],
        (this.destLScreen[2] - this.startLScreen[2]) * factor + this.startLScreen[2],
      ];
      this.changes = true;
    }
  }

  /**
   * Render frame (second half of update)
   */
  private render(): void {
    if (!this.changes || !this.pBuffer) {
      return;
    }
    this.changes = false;

    // Resize buffer if needed
    if (
      this.canvas &&
      (this.canvas.width !== this.canvasSize[0] ||
        this.canvas.height !== this.canvasSize[1])
    ) {
      this.canvas.width = this.canvasSize[0];
      this.canvas.height = this.canvasSize[1];
    }

    // Determine if flipping is needed
    let flip = FLIP_LIST[this.pDirection] !== this.pDirection;
    const headIndex = this.partIndex['hd'];
    if (headIndex !== undefined) {
      const headDir = this.partList[headIndex].getDirection();
      flip = flip || (this.pDirection === 3 && headDir === 4);
      flip = flip || (this.pDirection === 7 && headDir === 6);
    }

    if (flip) {
      this.shadowFix = this.pXFactor;
      this.flipH = true;
    } else {
      this.shadowFix = 0;
      this.flipH = false;
    }

    // Clear buffer
    this.pBuffer.clearRect(0, 0, this.canvasSize[0], this.canvasSize[1]);
    this.pUpdateRect = { x: 0, y: 0, width: 0, height: 0 };

    // Update and render all parts
    if (this.getAsset && this.applyPalette) {
      for (const part of this.partList) {
        part.update(this.getAsset, this.applyPalette);
        part.render(this.pBuffer);
      }
    }
  }

  /**
   * Re-draw pet
   */
  reDraw(): void {
    if (!this.pBuffer) return;

    this.pBuffer.clearRect(0, 0, this.canvasSize[0], this.canvasSize[1]);

    for (const part of this.partList) {
      part.render(this.pBuffer);
    }
  }

  /**
   * Set up part lists from figure
   */
  private setPartLists(figure: string): boolean {
    const action = this.pMainAction;
    this.partList = [];

    const partDefinition: PetPartType[] = ['tl', 'bd', 'hd'];

    // Parse figure
    const words = figure.split(' ');
    if (words.length < 3) {
      // Default figure
      words[0] = '0';
      words[1] = '4';
      words[2] = 'AA98EF';
    }

    const raceNum = words[0];
    let palette = words[1];

    // Pad palette to 3 digits
    palette = palette.padStart(3, '0');
    const paletteType = this.petDefinitions[this.race]?.paletteid || '0';
    const paletteStr = `Palette ${paletteType} ${palette}`;

    const color = `#${words[2]}`;

    // Create parts
    for (const partSymbol of partDefinition) {
      const partObj = new PetPart();
      const model = this.petDefinitions[this.race]?.parts?.[partSymbol] || '001';
      partObj.define(partSymbol, model, paletteStr, color, this.pDirection, action, this);
      this.partList.push(partObj);
    }

    // Build part index
    this.partIndex = {};
    for (let i = 0; i < this.partList.length; i++) {
      this.partIndex[this.partList[i].pPart] = i;
    }

    return true;
  }

  /**
   * Arrange parts based on direction
   */
  private arrangeParts(): void {
    const tailInd = this.partIndex['tl'];
    const headInd = this.partIndex['hd'];
    const bodyInd = this.partIndex['bd'];

    if (
      tailInd === undefined ||
      headInd === undefined ||
      bodyInd === undefined
    ) {
      return;
    }

    const tail = this.partList[tailInd];
    const head = this.partList[headInd];
    const body = this.partList[bodyInd];

    const headDir = head.getDirection();

    if (headDir === 7) {
      this.partList = [head, body, tail];
      this.partIndex = { hd: 0, bd: 1, tl: 2 };
    } else if (
      this.pDirection === 6 ||
      this.pDirection === 7 ||
      this.pDirection === 0
    ) {
      this.partList = [body, head, tail];
      this.partIndex = { bd: 0, hd: 1, tl: 2 };
    } else {
      this.partList = [tail, body, head];
      this.partIndex = { tl: 0, bd: 1, hd: 2 };
    }
  }

  /**
   * Flip image horizontally
   */
  private flipImage(canvas: HTMLCanvasElement): HTMLCanvasElement {
    const flipped = document.createElement('canvas');
    flipped.width = canvas.width;
    flipped.height = canvas.height;

    const ctx = flipped.getContext('2d');
    if (ctx) {
      ctx.translate(canvas.width, 0);
      ctx.scale(-1, 1);
      ctx.drawImage(canvas, 0, 0);
    }

    return flipped;
  }

  /**
   * Get offset list for race
   */
  private getOffsetList(size: 'large' | 'small'): OffsetList {
    // Offsets would be loaded from configuration files
    // For now, return empty - would be populated from pet.definitions
    return {};
  }

  /**
   * Get canvas for rendering
   */
  getCanvas(): HTMLCanvasElement | null {
    return this.canvas;
  }

  /**
   * Get rendering data
   */
  getRenderData(): {
    x: number;
    y: number;
    z: number;
    flipH: boolean;
    shadowX: number;
    visible: boolean;
  } {
    const offZ = this.correctLocZ
      ? (this.locH + this.restingHeight) * 1000 + 2
      : 2;

    return {
      x: this.screenLoc[0],
      y: this.screenLoc[1],
      z: this.screenLoc[2] + offZ,
      flipH: this.flipH,
      shadowX: this.screenLoc[0] + this.shadowFix,
      visible: this.visible,
    };
  }

  // Action handlers

  /**
   * Move action
   */
  action_mv(props: string): void {
    this.pMainAction = 'wlk';
    this.pMoving = true;

    const parts = props.split(' ');
    const loc = parts[1]?.split(',') || ['0', '0', '0'];
    const locX = parseInt(loc[0], 10) || 0;
    const locY = parseInt(loc[1], 10) || 0;
    const locH = parseFloat(loc[2]) || 0;

    if (this.geometry) {
      this.startLScreen = this.geometry.getScreenCoordinate(
        this.locX,
        this.locY,
        this.locH
      );
      this.destLScreen = this.geometry.getScreenCoordinate(locX, locY, locH);
    }

    this.moveStart = Date.now();

    const bodyIndex = this.partIndex['bd'];
    if (bodyIndex !== undefined) {
      this.partList[bodyIndex].defineAct('wlk');
    }
  }

  /**
   * Slide action
   */
  action_sld(props: string): void {
    this.pMoving = true;

    const parts = props.split(' ');
    const loc = parts[1]?.split(',') || ['0', '0', '0'];
    const locX = parseInt(loc[0], 10) || 0;
    const locY = parseInt(loc[1], 10) || 0;
    const locH = parseFloat(loc[2]) || 0;

    if (this.geometry) {
      this.startLScreen = this.geometry.getScreenCoordinate(
        this.locX,
        this.locY,
        this.locH + this.restingHeight
      );
      this.destLScreen = this.geometry.getScreenCoordinate(locX, locY, locH);
    }

    this.moveStart = Date.now();
  }

  /**
   * Sit action
   */
  action_sit(props: string): void {
    this.pMainAction = 'sit';

    const bodyIndex = this.partIndex['bd'];
    if (bodyIndex !== undefined) {
      this.partList[bodyIndex].defineAct('sit');
    }

    const parts = props.split(' ');
    const heightVal = parseFloat(parts[1] || '0');

    if (this.correctLocZ) {
      this.restingHeight = heightVal - this.locH;
      if (this.geometry) {
        this.screenLoc = this.geometry.getScreenCoordinate(
          this.locX,
          this.locY,
          this.locH + this.restingHeight
        );
      }
    } else {
      this.restingHeight = heightVal;
      if (this.geometry) {
        this.screenLoc = this.geometry.getScreenCoordinate(
          this.locX,
          this.locY,
          this.restingHeight
        );
      }
    }
  }

  /**
   * Sniff action
   */
  action_snf(): void {
    this.sniffing = true;
    const headIndex = this.partIndex['hd'];
    if (headIndex !== undefined) {
      this.partList[headIndex].defineAct('snf');
    }
  }

  /**
   * Scratch action
   */
  action_scr(): void {
    this.pMainAction = 'scr';
    const bodyIndex = this.partIndex['bd'];
    if (bodyIndex !== undefined) {
      this.partList[bodyIndex].defineAct('scr');
    }
  }

  /**
   * Bend action
   */
  action_bnd(): void {
    this.pMainAction = 'bnd';
    const bodyIndex = this.partIndex['bd'];
    if (bodyIndex !== undefined) {
      this.partList[bodyIndex].defineAct('bnd');
    }
  }

  /**
   * Lay action
   */
  action_lay(props: string): void {
    this.pMainAction = 'lay';

    const bodyIndex = this.partIndex['bd'];
    if (bodyIndex !== undefined) {
      this.partList[bodyIndex].defineAct('lay');
    }

    const parts = props.split(' ');
    const heightVal = parseFloat(parts[1] || '0');

    if (this.correctLocZ) {
      this.restingHeight = heightVal - this.locH;
      if (this.geometry) {
        this.screenLoc = this.geometry.getScreenCoordinate(
          this.locX,
          this.locY,
          this.locH + this.restingHeight
        );
      }
    } else {
      this.restingHeight = heightVal;
      if (this.geometry) {
        this.screenLoc = this.geometry.getScreenCoordinate(
          this.locX,
          this.locY,
          this.restingHeight
        );
      }
    }
  }

  /**
   * Sleep action
   */
  action_slp(props: string): void {
    this.action_lay(props);
    this.pMainAction = 'slp';

    const headIndex = this.partIndex['hd'];
    if (headIndex !== undefined) {
      this.partList[headIndex].defineAct('slp');
    }
  }

  /**
   * Jump action
   */
  action_jmp(props: string): void {
    this.pMainAction = 'jmp';
    const bodyIndex = this.partIndex['bd'];
    if (bodyIndex !== undefined) {
      this.partList[bodyIndex].defineAct('jmp');
    }
  }

  /**
   * Dead action
   */
  action_ded(props: string): void {
    this.pMainAction = 'ded';

    for (const partType of ['hd', 'bd', 'tl']) {
      const index = this.partIndex[partType];
      if (index !== undefined) {
        this.partList[index].defineAct('ded');
      }
    }
  }

  /**
   * Eat action
   */
  action_eat(props: string): void {
    const headIndex = this.partIndex['hd'];
    if (headIndex !== undefined) {
      this.partList[headIndex].defineAct('eat');
    }
  }

  /**
   * Beg action
   */
  action_beg(props: string): void {
    this.pMainAction = 'beg';

    const bodyIndex = this.partIndex['bd'];
    if (bodyIndex !== undefined) {
      this.partList[bodyIndex].defineAct('beg');
    }

    const headIndex = this.partIndex['hd'];
    if (headIndex !== undefined) {
      this.partList[headIndex].defineAct('beg');
    }
  }

  /**
   * Play action
   */
  action_pla(props: string): void {
    this.pMainAction = 'pla';
    const bodyIndex = this.partIndex['bd'];
    if (bodyIndex !== undefined) {
      this.partList[bodyIndex].defineAct('pla');
    }
  }

  /**
   * Ready action
   */
  action_rdy(props: string): void {
    this.pMainAction = 'rdy';
    const bodyIndex = this.partIndex['bd'];
    if (bodyIndex !== undefined) {
      this.partList[bodyIndex].defineAct('rdy');
    }
  }

  /**
   * Talk action
   */
  action_talk(props: string): void {
    this.talking = true;
  }

  /**
   * Stop talk action
   */
  stop_action_talk(props: string): void {
    this.talking = false;
  }

  /**
   * Wave action
   */
  action_wav(props: string): void {
    this.waving = true;
    const tailIndex = this.partIndex['tl'];
    if (tailIndex !== undefined) {
      this.partList[tailIndex].defineAct('wav');
    }
  }

  /**
   * Gesture action
   */
  action_gst(props: string): void {
    const parts = props.split(' ');
    const gesture = (parts[1] || 'std') as PetAction;

    const headIndex = this.partIndex['hd'];
    if (headIndex !== undefined) {
      this.partList[headIndex].defineAct(gesture);
    }

    // Some gestures affect tail too
    if (['sml', 'agr', 'sad', 'puz'].includes(gesture)) {
      const tailIndex = this.partIndex['tl'];
      if (tailIndex !== undefined) {
        this.partList[tailIndex].defineAct(gesture);
      }
    }
  }
}
