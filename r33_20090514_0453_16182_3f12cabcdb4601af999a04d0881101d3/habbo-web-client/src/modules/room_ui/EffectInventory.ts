/**
 * Effect Inventory Class - Avatar effects management
 *
 * Ported from: hh_room_ui/Cast External ParentScript 52 - Effect Inventory Class.ls
 */

import { BaseObject } from '../../core/BaseObject';

/**
 * Effect data
 */
export interface EffectData {
  id: number;
  name: string;
  duration: number;
  quantity: number;
  activationTimestamp?: number;
  secondsLeft?: number;
  permanent?: boolean;
}

/**
 * Effect inventory - manages avatar effects
 */
export class EffectInventory extends BaseObject {
  private pEffects: Map<number, EffectData> = new Map();
  private pActiveEffect: number = -1;
  private pWindowVisible: boolean = false;

  construct(): void {
    super.construct();

    this.pEffects = new Map();
    this.pActiveEffect = -1;
    this.pWindowVisible = false;

    // Would register for effect messages
  }

  deconstruct(): void {
    this.hideWindow();
    this.pEffects.clear();
    super.deconstruct();
  }

  /**
   * Add effect to inventory
   */
  addEffect(effect: EffectData): void {
    this.pEffects.set(effect.id, effect);
    this.emit('effect_added', effect);
  }

  /**
   * Remove effect from inventory
   */
  removeEffect(effectId: number): void {
    this.pEffects.delete(effectId);
    this.emit('effect_removed', { id: effectId });
  }

  /**
   * Get effect by ID
   */
  getEffect(effectId: number): EffectData | undefined {
    return this.pEffects.get(effectId);
  }

  /**
   * Get all effects
   */
  getEffects(): EffectData[] {
    return Array.from(this.pEffects.values());
  }

  /**
   * Set active effect
   */
  setActiveEffect(effectId: number): void {
    this.pActiveEffect = effectId;
    this.emit('active_effect_changed', { id: effectId });
  }

  /**
   * Get active effect
   */
  getActiveEffect(): number {
    return this.pActiveEffect;
  }

  /**
   * Use an effect
   */
  useEffect(effectId: number): void {
    if (effectId === -1) {
      // Stop current effect
      this.emit('stop_effect');
    } else {
      const effect = this.pEffects.get(effectId);
      if (effect) {
        this.emit('use_effect', { id: effectId, effect });
      }
    }
  }

  /**
   * Update effect remaining time
   */
  updateEffectTime(effectId: number, secondsLeft: number): void {
    const effect = this.pEffects.get(effectId);
    if (effect) {
      effect.secondsLeft = secondsLeft;
      this.emit('effect_time_updated', { id: effectId, secondsLeft });
    }
  }

  /**
   * Show effect inventory window
   */
  showWindow(): void {
    this.pWindowVisible = true;
    this.emit('window_shown', { effects: this.getEffects() });
  }

  /**
   * Hide effect inventory window
   */
  hideWindow(): void {
    this.pWindowVisible = false;
    this.emit('window_hidden');
  }

  /**
   * Toggle effect inventory window
   */
  toggleWindow(): void {
    if (this.pWindowVisible) {
      this.hideWindow();
    } else {
      this.showWindow();
    }
  }

  /**
   * Check if window is visible
   */
  isWindowVisible(): boolean {
    return this.pWindowVisible;
  }

  /**
   * Handle UI event
   */
  handleEvent(event: string, spriteId: string, param?: unknown): void {
    if (event !== 'mouseUp') return;

    if (spriteId === 'fx_close') {
      this.hideWindow();
    } else if (spriteId.startsWith('fx_item_')) {
      const effectId = parseInt(spriteId.replace('fx_item_', ''), 10);
      if (!isNaN(effectId)) {
        this.useEffect(effectId);
      }
    } else if (spriteId === 'fx_stop') {
      this.useEffect(-1);
    }
  }

  /**
   * Get effect count
   */
  getEffectCount(): number {
    return this.pEffects.size;
  }

  /**
   * Check if has effect
   */
  hasEffect(effectId: number): boolean {
    return this.pEffects.has(effectId);
  }
}
