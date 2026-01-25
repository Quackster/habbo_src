/**
 * MainLoop - Frame update loop
 *
 * Replicates Director's frame-based execution model.
 * Original Habbo ran at approximately 15 FPS (puppetTempo 15).
 *
 * Director events mapped:
 * - prepareFrame -> called before rendering each frame
 * - enterFrame -> called when frame is entered (we combine with prepareFrame)
 */

import { objectManager } from './ObjectManager';
import { timeoutManager } from './TimeoutManager';

export class MainLoop {
  private running: boolean = false;
  private targetFps: number = 15; // Original Habbo frame rate
  private frameInterval: number;
  private lastFrameTime: number = 0;
  private frameCount: number = 0;
  private animationFrameId: number = 0;

  // Performance tracking
  private fpsUpdateInterval: number = 1000;
  private lastFpsUpdate: number = 0;
  private framesThisSecond: number = 0;
  private currentFps: number = 0;

  // Callbacks
  private onFrameCallbacks: Array<() => void> = [];

  constructor(targetFps: number = 15) {
    this.targetFps = targetFps;
    this.frameInterval = 1000 / targetFps;
  }

  /**
   * Start the main loop
   */
  start(): void {
    if (this.running) return;

    this.running = true;
    this.lastFrameTime = performance.now();
    this.lastFpsUpdate = this.lastFrameTime;
    this.tick(this.lastFrameTime);

    console.log(`MainLoop started at ${this.targetFps} FPS target`);
  }

  /**
   * Stop the main loop
   */
  stop(): void {
    this.running = false;
    if (this.animationFrameId) {
      cancelAnimationFrame(this.animationFrameId);
      this.animationFrameId = 0;
    }
    console.log('MainLoop stopped');
  }

  /**
   * Main tick function
   */
  private tick = (currentTime: number): void => {
    if (!this.running) return;

    this.animationFrameId = requestAnimationFrame(this.tick);

    // Calculate time since last frame
    const elapsed = currentTime - this.lastFrameTime;

    // Only process frame if enough time has passed (frame rate limiting)
    if (elapsed >= this.frameInterval) {
      // Adjust for drift
      this.lastFrameTime = currentTime - (elapsed % this.frameInterval);
      this.frameCount++;

      // Run frame
      this.processFrame();

      // Update FPS counter
      this.framesThisSecond++;
      if (currentTime - this.lastFpsUpdate >= this.fpsUpdateInterval) {
        this.currentFps = this.framesThisSecond;
        this.framesThisSecond = 0;
        this.lastFpsUpdate = currentTime;
      }
    }
  };

  /**
   * Process a single frame
   *
   * This is equivalent to Director's prepareFrame event
   */
  private processFrame(): void {
    try {
      // Process timeouts first
      timeoutManager.update();

      // Call ObjectManager's frame processing
      // This triggers prepare() and update() on all registered objects
      objectManager.prepareFrame();

      // Call any additional frame callbacks
      for (const callback of this.onFrameCallbacks) {
        try {
          callback();
        } catch (error) {
          console.error('MainLoop: Error in frame callback:', error);
        }
      }
    } catch (error) {
      console.error('MainLoop: Error in frame processing:', error);
    }
  }

  /**
   * Add a callback to be called each frame
   */
  onFrame(callback: () => void): void {
    this.onFrameCallbacks.push(callback);
  }

  /**
   * Remove a frame callback
   */
  offFrame(callback: () => void): void {
    const index = this.onFrameCallbacks.indexOf(callback);
    if (index !== -1) {
      this.onFrameCallbacks.splice(index, 1);
    }
  }

  /**
   * Get current FPS
   */
  getFps(): number {
    return this.currentFps;
  }

  /**
   * Get total frame count
   */
  getFrameCount(): number {
    return this.frameCount;
  }

  /**
   * Set target FPS
   */
  setTargetFps(fps: number): void {
    this.targetFps = fps;
    this.frameInterval = 1000 / fps;
  }

  /**
   * Get target FPS
   */
  getTargetFps(): number {
    return this.targetFps;
  }

  /**
   * Check if loop is running
   */
  isRunning(): boolean {
    return this.running;
  }

  /**
   * Get current time in milliseconds
   *
   * Lingo equivalent: the milliSeconds
   */
  getMilliseconds(): number {
    return performance.now();
  }
}

// Global singleton
export const mainLoop = new MainLoop(15);

// Convenience function matching Lingo
export function getMilliseconds(): number {
  return performance.now();
}
