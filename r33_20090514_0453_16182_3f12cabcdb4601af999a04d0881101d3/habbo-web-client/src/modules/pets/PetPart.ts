/**
 * Pet Part Class - Individual pet part rendering
 *
 * Ported from: hh_pets_common/Cast External ParentScript 2 - Petpart Class.ls
 */

import {
  PetPartType,
  PetAction,
  DrawProps,
  OffsetList,
  FLIP_LIST,
} from './types';

/**
 * Pet part rendering class
 * Handles rendering of individual pet parts (head, body, tail)
 */
export class PetPart {
  // Part properties
  pPart: PetPartType;
  private model: string;
  private direction: number;
  private action: PetAction;

  // Drawing properties
  private drawProps: DrawProps;
  private memString: string = '';
  private cacheImage: ImageData | null = null;
  private cacheRectA: { x: number; y: number; width: number; height: number } = {
    x: 0,
    y: 0,
    width: 0,
    height: 0,
  };
  private cacheRectB: { x: number; y: number; width: number; height: number } = {
    x: 0,
    y: 0,
    width: 0,
    height: 0,
  };
  private cacheDir: number = -1;

  // Reference to parent pet
  private ancestor: {
    pAnimCounter: number;
    pDirection: number;
    pMainAction: PetAction;
    pXFactor: number;
    pBuffer: CanvasRenderingContext2D | null;
    pUpdateRect: { x: number; y: number; width: number; height: number };
    pLocFix: { x: number; y: number };
    pMemberNamePrefix: string;
    pOffsetList: OffsetList;
    pOffsetListSmall: OffsetList;
    pFlipList: number[];
  } | null = null;

  constructor() {
    this.pPart = 'bd';
    this.model = '001';
    this.direction = 0;
    this.action = 'std';
    this.drawProps = {
      maskImage: null,
      ink: 0,
      bgColor: '#FFFFFF',
      palette: '',
    };
  }

  /**
   * Define the pet part
   */
  define(
    part: PetPartType,
    model: string,
    palette: string,
    color: string,
    direction: number,
    action: PetAction,
    ancestor: PetPart['ancestor']
  ): boolean {
    this.ancestor = ancestor;
    this.pPart = part;
    this.model = model;
    this.drawProps = {
      maskImage: null,
      ink: 0,
      bgColor: '#FFFFFF',
      palette: palette,
    };
    this.cacheImage = null;
    this.cacheRectA = { x: 0, y: 0, width: 0, height: 0 };
    this.cacheRectB = { x: 0, y: 0, width: 0, height: 0 };

    this.defineInk();
    this.setColor(color);
    this.direction = direction;
    this.action = action;
    this.memString = '';
    this.cacheDir = -1;

    return true;
  }

  /**
   * Update the part (called each frame)
   */
  update(
    getAsset: (name: string) => {
      image: ImageData;
      regPoint: { x: number; y: number };
    } | null,
    applyPalette: (
      image: ImageData,
      palette: string,
      color: string
    ) => ImageData | null
  ): void {
    if (!this.ancestor) return;

    let animCntr = 0;
    const action = this.action;
    const part = this.pPart;
    const dir = FLIP_LIST[this.direction];
    let needsUpdate = false;

    // Calculate body direction for offset lookup (1-5 index)
    let bodyDir = FLIP_LIST[this.ancestor.pDirection] + 1;
    if (bodyDir > 4) {
      bodyDir = 5;
    }

    // Get offset list based on scale
    const offsetList =
      this.ancestor.pXFactor > 33
        ? this.ancestor.pOffsetList
        : this.ancestor.pOffsetListSmall;

    let xFix = 0;
    let yFix = 0;

    switch (part) {
      case 'bd':
        // Body animation
        switch (action) {
          case 'wlk':
          case 'jmp':
          case 'bnd':
            animCntr = this.ancestor.pAnimCounter;
            break;
          case 'pla':
          case 'scr':
            animCntr = 1 % this.ancestor.pAnimCounter;
            break;
        }
        if (this.direction !== this.cacheDir) {
          needsUpdate = true;
        }
        break;

      case 'hd':
        // Head offset based on main action
        {
          const mainAction = this.ancestor.pMainAction;
          const offsetKey =
            mainAction === 'jmp' ||
            mainAction === 'scr' ||
            mainAction === 'bnd'
              ? `hd_${mainAction}_${this.ancestor.pAnimCounter}`
              : `hd_${mainAction}`;

          if (offsetList[offsetKey] && offsetList[offsetKey][bodyDir - 1]) {
            xFix = offsetList[offsetKey][bodyDir - 1][0];
            yFix = offsetList[offsetKey][bodyDir - 1][1];
          }
        }

        // Head animation
        if (action === 'snf' || action === 'eat' || action === 'spk') {
          animCntr = this.ancestor.pAnimCounter % 2;
        }
        needsUpdate = true;
        break;

      case 'tl':
        // Tail offset based on main action
        {
          const mainAction = this.ancestor.pMainAction;
          const offsetKey =
            mainAction === 'jmp' ||
            mainAction === 'scr' ||
            mainAction === 'bnd'
              ? `tl_${mainAction}_${this.ancestor.pAnimCounter}`
              : `tl_${mainAction}`;

          if (offsetList[offsetKey] && offsetList[offsetKey][bodyDir - 1]) {
            xFix = offsetList[offsetKey][bodyDir - 1][0];
            yFix = offsetList[offsetKey][bodyDir - 1][1];
          }
        }

        // Tail animation
        if (action === 'wav') {
          animCntr = this.ancestor.pAnimCounter % 2;
        }
        needsUpdate = true;
        break;
    }

    // Apply small scale adjustment
    const anDir = this.ancestor.pDirection;
    if (anDir > 3 && anDir < 7 && this.ancestor.pXFactor <= 33) {
      xFix = xFix + this.ancestor.pXFactor - 7;
    }

    // Build member name string
    const memString = `${this.ancestor.pMemberNamePrefix}${action}_${part}_${this.model}_${dir}_${animCntr}`;

    if (this.memString !== memString || needsUpdate) {
      const asset = getAsset(memString);
      if (asset) {
        this.memString = memString;
        const regPnt = asset.regPoint;
        const bufferHeight = this.ancestor.pBuffer
          ? 62 // Default buffer height
          : 62;

        const x = -regPnt.x + xFix + this.ancestor.pLocFix.x;
        const y = bufferHeight - regPnt.y - 10 + yFix + this.ancestor.pLocFix.y;

        // Update dirty rect
        this.unionRect(this.ancestor.pUpdateRect, this.cacheRectA);

        // Apply palette/color tinting
        this.cacheImage = applyPalette(
          asset.image,
          this.drawProps.palette,
          this.drawProps.bgColor
        );

        const imgWidth = this.cacheImage?.width || asset.image.width;
        const imgHeight = this.cacheImage?.height || asset.image.height;

        this.cacheRectA = {
          x,
          y,
          width: imgWidth,
          height: imgHeight,
        };
        this.cacheRectB = {
          x: 0,
          y: 0,
          width: imgWidth,
          height: imgHeight,
        };

        this.unionRect(this.ancestor.pUpdateRect, this.cacheRectA);
        this.cacheDir = this.direction;
      } else {
        // Asset not found, clear cache
        if (this.cacheRectA.width > 0) {
          this.unionRect(this.ancestor.pUpdateRect, this.cacheRectA);
          this.cacheRectA = { x: 0, y: 0, width: 0, height: 0 };
        }
      }
    }
  }

  /**
   * Render the part to buffer
   */
  render(ctx: CanvasRenderingContext2D): void {
    if (this.cacheImage && this.memString) {
      ctx.putImageData(
        this.cacheImage,
        this.cacheRectA.x,
        this.cacheRectA.y
      );
    }
  }

  /**
   * Define direction
   */
  defineDir(dir: number, targetPart?: PetPartType): void {
    if (!targetPart || targetPart === this.pPart) {
      this.direction = dir;
    }
  }

  /**
   * Define direction for multiple parts
   */
  defineDirMultiple(dir: number, targetPartList: PetPartType[]): void {
    if (targetPartList.includes(this.pPart)) {
      this.direction = dir;
    }
  }

  /**
   * Define action
   */
  defineAct(action: PetAction): void {
    if (this.action === 'std') {
      this.action = action;
    }
  }

  /**
   * Define action for multiple parts
   */
  defineActMultiple(action: PetAction, targetPartList: PetPartType[]): void {
    if (targetPartList.includes(this.pPart)) {
      if (this.action === 'std') {
        this.action = action;
      }
      if (action === 'std') {
        this.action = 'std';
      }
    }
  }

  /**
   * Define ink mode
   */
  defineInk(ink?: number): boolean {
    if (ink === undefined) {
      // Default ink based on part
      ink = this.pPart === 'sd' ? 32 : 41;
    }
    this.drawProps.ink = ink;
    return true;
  }

  /**
   * Set model
   */
  setModel(model: string): void {
    this.model = model;
  }

  /**
   * Set color
   */
  setColor(color: string | null): boolean {
    if (!color) {
      return false;
    }
    if (this.drawProps.ink !== 36) {
      this.drawProps.bgColor = color;
    } else {
      this.drawProps.bgColor = '#FFFFFF';
    }
    return true;
  }

  /**
   * Lay down action
   */
  layDown(): void {
    this.action = 'lay';
  }

  /**
   * Get current member string
   */
  getCurrentMember(): string {
    return this.memString;
  }

  /**
   * Get color
   */
  getColor(): string {
    return this.drawProps.bgColor;
  }

  /**
   * Get direction
   */
  getDirection(): number {
    return this.direction;
  }

  /**
   * Reset action to standard
   */
  reset(): void {
    this.action = 'std';
  }

  /**
   * Copy picture for icon rendering
   */
  copyPicture(
    canvas: CanvasRenderingContext2D,
    getAsset: (name: string) => {
      image: ImageData;
      regPoint: { x: number; y: number };
    } | null,
    applyPalette: (
      image: ImageData,
      palette: string,
      color: string
    ) => ImageData | null,
    dir: string = '2',
    humanSize: string = 'p',
    action: string = 'std',
    animFrame: string = '0',
    offsetList: OffsetList = {},
    offsetListSmall: OffsetList = {}
  ): boolean {
    let offX = 0;
    let offY = 0;

    const offsets = humanSize === 'p' ? offsetList : offsetListSmall;
    const prefix = humanSize === 'p' ? 'p_' : 's_p_';

    if (this.pPart !== 'bd') {
      const offsetKey = `${this.pPart}_${action}`;
      const dirIndex = parseInt(dir, 10);
      if (offsets[offsetKey] && offsets[offsetKey][dirIndex]) {
        offX = offsets[offsetKey][dirIndex][0];
        offY = offsets[offsetKey][dirIndex][1];
      }
    }

    const memName = `${prefix}${action}_${this.pPart}_${this.model}_${dir}_${animFrame}`;
    const asset = getAsset(memName);

    if (asset) {
      const image = applyPalette(
        asset.image,
        this.drawProps.palette,
        this.drawProps.bgColor
      );
      if (image) {
        const regPnt = asset.regPoint;
        const canvasHeight = canvas.canvas.height;
        const x = -regPnt.x + offX;
        const y = canvasHeight - regPnt.y - 10 + offY;

        canvas.putImageData(image, x, y);
        return true;
      }
    }

    return false;
  }

  /**
   * Union two rectangles
   */
  private unionRect(
    target: { x: number; y: number; width: number; height: number },
    source: { x: number; y: number; width: number; height: number }
  ): void {
    if (source.width === 0 || source.height === 0) {
      return;
    }

    if (target.width === 0 || target.height === 0) {
      target.x = source.x;
      target.y = source.y;
      target.width = source.width;
      target.height = source.height;
      return;
    }

    const minX = Math.min(target.x, source.x);
    const minY = Math.min(target.y, source.y);
    const maxX = Math.max(target.x + target.width, source.x + source.width);
    const maxY = Math.max(target.y + target.height, source.y + source.height);

    target.x = minX;
    target.y = minY;
    target.width = maxX - minX;
    target.height = maxY - minY;
  }
}
