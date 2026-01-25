/**
 * Hotel View Animations Module
 *
 * Ported from regional entry modules:
 * - hh_entry_uk/Cast External ParentScript 23 - Entry Cloud Class.ls
 * - hh_entry_uk/Cast External ParentScript 24 - Entry Car Class.ls
 * - hh_entry_it/Cast External ParentScript 8 - Entry Boat Class.ls
 * - hh_entry_jp/Cast External ParentScript 9 - Entry Train Class.ls
 * - hh_entry_no/Cast External ParentScript 9 - Entry Sailboat Class.ls
 * - hh_entry_no/Cast External ParentScript 11 - Entry Twinkle Class.ls
 * - hh_entry_jp/Cast External ParentScript 56 - Entry Bubbles Class.ls
 * - hh_entry_jp/Cast External ParentScript 10 - Entry Image Scroller Class.ls
 * - hh_entry_base/Cast External ParentScript 5 - Swap Animation Class.ls
 */

import { HotelViewAnimationType, SwapAnimationConfig } from '../types';

/**
 * Base interface for all hotel view animations
 */
export interface IHotelViewAnimation {
  /** Initialize the animation with a sprite element */
  define(sprite: HTMLElement | CanvasRenderingContext2D, index: number): void;
  /** Update the animation (called each frame) */
  update(): void;
  /** Clean up the animation */
  destroy(): void;
}

/**
 * Animation factory function type
 */
export type AnimationFactory = (config?: Record<string, unknown>) => IHotelViewAnimation;

/**
 * Registry of animation factories
 */
const animationFactories: Map<HotelViewAnimationType, AnimationFactory> = new Map();

/**
 * Register an animation factory
 */
export function registerAnimation(type: HotelViewAnimationType, factory: AnimationFactory): void {
  animationFactories.set(type, factory);
}

/**
 * Create an animation instance
 */
export function createAnimation(
  type: HotelViewAnimationType,
  config?: Record<string, unknown>
): IHotelViewAnimation | null {
  const factory = animationFactories.get(type);
  if (!factory) {
    console.warn(`Animation type not registered: ${type}`);
    return null;
  }
  return factory(config);
}

/**
 * Base class for hotel view animations
 */
export abstract class BaseHotelAnimation implements IHotelViewAnimation {
  protected sprite: HTMLElement | CanvasRenderingContext2D | null = null;
  protected index: number = 0;
  protected destroyed: boolean = false;

  define(sprite: HTMLElement | CanvasRenderingContext2D, index: number): void {
    this.sprite = sprite;
    this.index = index;
  }

  abstract update(): void;

  destroy(): void {
    this.destroyed = true;
    this.sprite = null;
  }
}

/**
 * Cloud animation - animated clouds moving across the hotel view
 *
 * Ported from: hh_entry_uk/Cast External ParentScript 23 - Entry Cloud Class.ls
 */
export class CloudAnimation extends BaseHotelAnimation {
  private x: number = 0;
  private y: number = 0;
  private vertDir: number = 1;
  private cloudDir: number = 1;
  private turnPoints: number[] = [330];
  private currentTurnPoint: number = 0;
  private turnPoint: number = 330;
  private stageWidth: number = 800;
  private stageHeight: number = 600;
  private cloudVariant: number = 0;

  define(sprite: HTMLElement | CanvasRenderingContext2D, index: number): void {
    super.define(sprite, index);

    // Random starting position and variant
    this.x = -40;
    this.y = 260 - Math.floor(Math.random() * 40);
    this.cloudVariant = Math.floor(Math.random() * 4);
    this.vertDir = -1;
    this.currentTurnPoint = 0;
    this.turnPoint = this.turnPoints[0];
    this.cloudDir = this.vertDir;
  }

  update(): void {
    if (this.destroyed) return;

    // Move cloud horizontally
    this.x += 1;

    // Check for turn point
    const right = this.x + 100; // Approximate cloud width
    if (right > this.turnPoint && this.x <= this.turnPoint) {
      this.turn();
      this.vertDir = 0;
    }

    if (this.x === this.turnPoint) {
      this.vertDir = this.cloudDir * -1;
      this.getNextTurnPoint();
    }

    // Move vertically every other frame
    if (this.x % 2 === 0) {
      this.y += this.vertDir;
    }

    // Reset when off screen
    if (this.x > this.stageWidth + 30) {
      this.initCloud();
    }
  }

  private initCloud(): void {
    this.vertDir = -1;
    this.x = -40;
    this.y = 260 - Math.floor(Math.random() * 40);
    this.cloudVariant = Math.floor(Math.random() * 4);
    this.currentTurnPoint = 0;
    this.turnPoint = this.turnPoints[0];
  }

  private getNextTurnPoint(): void {
    this.currentTurnPoint++;
    if (this.currentTurnPoint >= this.turnPoints.length) {
      this.currentTurnPoint = this.turnPoints.length - 1;
    }
    this.turnPoint = this.turnPoints[this.currentTurnPoint];
  }

  private turn(): void {
    if (this.vertDir !== 0) {
      this.cloudDir = this.vertDir;
    }
  }

  getPosition(): { x: number; y: number } {
    return { x: this.x, y: this.y };
  }

  getVariant(): number {
    return this.cloudVariant;
  }
}

/**
 * Car animation - animated cars driving across the hotel view
 *
 * Ported from: hh_entry_uk/Cast External ParentScript 24 - Entry Car Class.ls
 */
export class CarAnimation extends BaseHotelAnimation {
  private x: number = 0;
  private y: number = 0;
  private speed: number = 2;
  private direction: 'left' | 'right' = 'right';
  private carType: number = 0;
  private stageWidth: number = 800;

  define(sprite: HTMLElement | CanvasRenderingContext2D, index: number): void {
    super.define(sprite, index);

    // Random starting properties
    this.direction = Math.random() > 0.5 ? 'left' : 'right';
    this.x = this.direction === 'right' ? -100 : this.stageWidth + 100;
    this.y = 450 + Math.floor(Math.random() * 30);
    this.speed = 1 + Math.floor(Math.random() * 3);
    this.carType = Math.floor(Math.random() * 4);
  }

  update(): void {
    if (this.destroyed) return;

    // Move car
    if (this.direction === 'right') {
      this.x += this.speed;
      if (this.x > this.stageWidth + 100) {
        this.reset();
      }
    } else {
      this.x -= this.speed;
      if (this.x < -100) {
        this.reset();
      }
    }
  }

  private reset(): void {
    this.direction = Math.random() > 0.5 ? 'left' : 'right';
    this.x = this.direction === 'right' ? -100 : this.stageWidth + 100;
    this.y = 450 + Math.floor(Math.random() * 30);
    this.speed = 1 + Math.floor(Math.random() * 3);
    this.carType = Math.floor(Math.random() * 4);
  }

  getPosition(): { x: number; y: number } {
    return { x: this.x, y: this.y };
  }

  getDirection(): 'left' | 'right' {
    return this.direction;
  }

  getCarType(): number {
    return this.carType;
  }
}

/**
 * Boat animation - animated boats on water
 *
 * Ported from: hh_entry_it/Cast External ParentScript 8 - Entry Boat Class.ls
 */
export class BoatAnimation extends BaseHotelAnimation {
  private x: number = 0;
  private y: number = 0;
  private baseY: number = 0;
  private bobPhase: number = 0;
  private speed: number = 0.5;
  private direction: 'left' | 'right' = 'right';
  private stageWidth: number = 800;

  define(sprite: HTMLElement | CanvasRenderingContext2D, index: number): void {
    super.define(sprite, index);

    this.direction = Math.random() > 0.5 ? 'left' : 'right';
    this.x = this.direction === 'right' ? -80 : this.stageWidth + 80;
    this.baseY = 380 + Math.floor(Math.random() * 20);
    this.y = this.baseY;
    this.bobPhase = Math.random() * Math.PI * 2;
    this.speed = 0.3 + Math.random() * 0.4;
  }

  update(): void {
    if (this.destroyed) return;

    // Move boat
    if (this.direction === 'right') {
      this.x += this.speed;
      if (this.x > this.stageWidth + 80) {
        this.reset();
      }
    } else {
      this.x -= this.speed;
      if (this.x < -80) {
        this.reset();
      }
    }

    // Bob up and down
    this.bobPhase += 0.05;
    this.y = this.baseY + Math.sin(this.bobPhase) * 3;
  }

  private reset(): void {
    this.direction = Math.random() > 0.5 ? 'left' : 'right';
    this.x = this.direction === 'right' ? -80 : this.stageWidth + 80;
    this.baseY = 380 + Math.floor(Math.random() * 20);
    this.speed = 0.3 + Math.random() * 0.4;
  }

  getPosition(): { x: number; y: number } {
    return { x: this.x, y: this.y };
  }
}

/**
 * Train animation - animated train on tracks
 *
 * Ported from: hh_entry_jp/Cast External ParentScript 9 - Entry Train Class.ls
 */
export class TrainAnimation extends BaseHotelAnimation {
  private x: number = 0;
  private y: number = 420;
  private speed: number = 3;
  private stageWidth: number = 800;

  define(sprite: HTMLElement | CanvasRenderingContext2D, index: number): void {
    super.define(sprite, index);
    this.x = -200;
    this.y = 420;
    this.speed = 2 + Math.random();
  }

  update(): void {
    if (this.destroyed) return;

    this.x += this.speed;
    if (this.x > this.stageWidth + 200) {
      this.x = -200;
      this.speed = 2 + Math.random();
    }
  }

  getPosition(): { x: number; y: number } {
    return { x: this.x, y: this.y };
  }
}

/**
 * Sailboat animation - animated sailboat with wind effect
 *
 * Ported from: hh_entry_no/Cast External ParentScript 9 - Entry Sailboat Class.ls
 */
export class SailboatAnimation extends BaseHotelAnimation {
  private x: number = 0;
  private y: number = 0;
  private baseY: number = 0;
  private tiltAngle: number = 0;
  private bobPhase: number = 0;
  private speed: number = 0.3;
  private direction: 'left' | 'right' = 'right';
  private stageWidth: number = 800;

  define(sprite: HTMLElement | CanvasRenderingContext2D, index: number): void {
    super.define(sprite, index);

    this.direction = Math.random() > 0.5 ? 'left' : 'right';
    this.x = this.direction === 'right' ? -60 : this.stageWidth + 60;
    this.baseY = 360 + Math.floor(Math.random() * 30);
    this.y = this.baseY;
    this.bobPhase = Math.random() * Math.PI * 2;
    this.speed = 0.2 + Math.random() * 0.3;
  }

  update(): void {
    if (this.destroyed) return;

    // Move sailboat
    if (this.direction === 'right') {
      this.x += this.speed;
      if (this.x > this.stageWidth + 60) {
        this.reset();
      }
    } else {
      this.x -= this.speed;
      if (this.x < -60) {
        this.reset();
      }
    }

    // Bob and tilt
    this.bobPhase += 0.03;
    this.y = this.baseY + Math.sin(this.bobPhase) * 4;
    this.tiltAngle = Math.sin(this.bobPhase * 0.7) * 5;
  }

  private reset(): void {
    this.direction = Math.random() > 0.5 ? 'left' : 'right';
    this.x = this.direction === 'right' ? -60 : this.stageWidth + 60;
    this.baseY = 360 + Math.floor(Math.random() * 30);
    this.speed = 0.2 + Math.random() * 0.3;
  }

  getPosition(): { x: number; y: number } {
    return { x: this.x, y: this.y };
  }

  getTiltAngle(): number {
    return this.tiltAngle;
  }
}

/**
 * Twinkle animation - twinkling stars/lights
 *
 * Ported from: hh_entry_no/Cast External ParentScript 11 - Entry Twinkle Class.ls
 */
export class TwinkleAnimation extends BaseHotelAnimation {
  private stars: Array<{ x: number; y: number; phase: number; speed: number; brightness: number }> = [];
  private starCount: number = 20;

  define(sprite: HTMLElement | CanvasRenderingContext2D, index: number): void {
    super.define(sprite, index);

    // Initialize stars
    this.stars = [];
    for (let i = 0; i < this.starCount; i++) {
      this.stars.push({
        x: Math.random() * 800,
        y: Math.random() * 200,
        phase: Math.random() * Math.PI * 2,
        speed: 0.02 + Math.random() * 0.05,
        brightness: Math.random(),
      });
    }
  }

  update(): void {
    if (this.destroyed) return;

    // Update star brightness
    for (const star of this.stars) {
      star.phase += star.speed;
      star.brightness = (Math.sin(star.phase) + 1) / 2;
    }
  }

  getStars(): Array<{ x: number; y: number; brightness: number }> {
    return this.stars.map((s) => ({ x: s.x, y: s.y, brightness: s.brightness }));
  }
}

/**
 * Bubbles animation - floating bubbles
 *
 * Ported from: hh_entry_jp/Cast External ParentScript 56 - Entry Bubbles Class.ls
 */
export class BubblesAnimation extends BaseHotelAnimation {
  private bubbles: Array<{ x: number; y: number; size: number; speed: number; wobblePhase: number }> = [];
  private bubbleCount: number = 15;
  private stageHeight: number = 600;

  define(sprite: HTMLElement | CanvasRenderingContext2D, index: number): void {
    super.define(sprite, index);

    // Initialize bubbles
    this.bubbles = [];
    for (let i = 0; i < this.bubbleCount; i++) {
      this.bubbles.push({
        x: Math.random() * 800,
        y: this.stageHeight + Math.random() * 100,
        size: 5 + Math.random() * 15,
        speed: 0.5 + Math.random() * 1.5,
        wobblePhase: Math.random() * Math.PI * 2,
      });
    }
  }

  update(): void {
    if (this.destroyed) return;

    for (const bubble of this.bubbles) {
      // Move up
      bubble.y -= bubble.speed;
      bubble.wobblePhase += 0.05;
      bubble.x += Math.sin(bubble.wobblePhase) * 0.5;

      // Reset when off screen
      if (bubble.y < -30) {
        bubble.y = this.stageHeight + 30;
        bubble.x = Math.random() * 800;
        bubble.size = 5 + Math.random() * 15;
      }
    }
  }

  getBubbles(): Array<{ x: number; y: number; size: number }> {
    return this.bubbles.map((b) => ({ x: b.x, y: b.y, size: b.size }));
  }
}

/**
 * Image scroller animation - scrolling promotional images
 *
 * Ported from: hh_entry_jp/Cast External ParentScript 10 - Entry Image Scroller Class.ls
 */
export class ImageScrollerAnimation extends BaseHotelAnimation {
  private scrollX: number = 0;
  private scrollSpeed: number = 1;
  private imageWidth: number = 800;
  private pauseTime: number = 0;
  private isPaused: boolean = false;

  define(sprite: HTMLElement | CanvasRenderingContext2D, index: number): void {
    super.define(sprite, index);
    this.scrollX = 0;
    this.scrollSpeed = 1;
  }

  update(): void {
    if (this.destroyed) return;

    if (this.isPaused) {
      this.pauseTime--;
      if (this.pauseTime <= 0) {
        this.isPaused = false;
      }
      return;
    }

    this.scrollX += this.scrollSpeed;

    // Pause at each image
    if (this.scrollX >= this.imageWidth) {
      this.scrollX = 0;
      this.isPaused = true;
      this.pauseTime = 180; // 3 seconds at 60fps
    }
  }

  getScrollX(): number {
    return this.scrollX;
  }
}

/**
 * Swap animation - frame-based sprite animation
 *
 * Ported from: hh_entry_base/Cast External ParentScript 5 - Swap Animation Class.ls
 */
export class SwapAnimation implements IHotelViewAnimation {
  private config: SwapAnimationConfig | null = null;
  private currentFrame: number = 0;
  private frameList: number[] = [];
  private initDelayCounter: number = 0;
  private animDelayCounter: number = 0;
  private animLoopCounter: number = 1;
  private stopped: boolean = true;
  private sprite: HTMLElement | null = null;

  define(sprite: HTMLElement | CanvasRenderingContext2D, index: number): void {
    if (sprite instanceof HTMLElement) {
      this.sprite = sprite;
    }
  }

  configure(config: SwapAnimationConfig): void {
    this.config = config;

    // Build frame list
    if (config.frameList && config.frameList.length > 0) {
      this.frameList = [...config.frameList];
    } else {
      // Auto-detect frames (in real impl would check for existing assets)
      this.frameList = [1, 2, 3, 4];
    }

    this.setInitDelay();
    this.setAnimDelay();
    this.stopped = false;
  }

  private setInitDelay(): void {
    if (!this.config) return;

    if (this.config.initDelayType === 'random') {
      this.initDelayCounter = Math.floor(Math.random() * this.config.initDelay);
    } else {
      this.initDelayCounter = this.config.initDelay;
    }
  }

  private setAnimDelay(): void {
    if (!this.config) return;

    if (this.config.animDelayType === 'random') {
      this.animDelayCounter = Math.floor(Math.random() * this.config.animDelay);
    } else {
      this.animDelayCounter = this.config.animDelay;
    }
  }

  update(): void {
    if (this.stopped || !this.config) return;

    this.initDelayCounter--;
    if (this.initDelayCounter < 0) {
      this.animDelayCounter--;
      if (this.animDelayCounter < 0) {
        this.advanceFrame();
        this.setAnimDelay();
      }
    }
  }

  private advanceFrame(): void {
    if (this.stopped || !this.config) return;

    this.currentFrame++;
    if (this.currentFrame >= this.frameList.length) {
      if (this.config.animLoopCount > 0) {
        this.animLoopCounter++;
        if (this.animLoopCounter > this.config.animLoopCount) {
          this.stopped = true;
          return;
        }
      }
      this.setInitDelay();
      if (this.initDelayCounter > 0) {
        this.currentFrame = -1;
        return;
      } else {
        this.currentFrame = 0;
      }
    }
  }

  getCurrentFrame(): number {
    if (this.currentFrame < 0 || this.currentFrame >= this.frameList.length) {
      return 0;
    }
    return this.frameList[this.currentFrame];
  }

  destroy(): void {
    this.stopped = true;
    this.sprite = null;
  }
}

// Register default animation factories
registerAnimation('cloud', () => new CloudAnimation());
registerAnimation('car', () => new CarAnimation());
registerAnimation('boat', () => new BoatAnimation());
registerAnimation('train', () => new TrainAnimation());
registerAnimation('sailboat', () => new SailboatAnimation());
registerAnimation('twinkle', () => new TwinkleAnimation());
registerAnimation('bubbles', () => new BubblesAnimation());
registerAnimation('imageScroller', () => new ImageScrollerAnimation());
registerAnimation('swap', () => new SwapAnimation());

// Export all animation classes
export {
  CloudAnimation as EntryCloudAnimation,
  CarAnimation as EntryCarAnimation,
  BoatAnimation as EntryBoatAnimation,
  TrainAnimation as EntryTrainAnimation,
  SailboatAnimation as EntrySailboatAnimation,
  TwinkleAnimation as EntryTwinkleAnimation,
  BubblesAnimation as EntryBubblesAnimation,
  ImageScrollerAnimation as EntryImageScrollerAnimation,
  SwapAnimation as EntrySwapAnimation,
};
