/**
 * Room Dimmer Interface Class - UI for room dimmer
 *
 * Ported from: hh_roomdimmer/Cast External ParentScript 4 - Roomdimmer Interface Class.ls
 */

import { BaseInterface } from '../../core/BaseInterface';
import { RoomDimmerComponent } from './RoomDimmerComponent';
import { DimmerPreset } from './types';

export class RoomDimmerInterface extends BaseInterface {
  private pWindowId: string = 'roomdimmer_window';

  construct(): void {
    super.construct();
  }

  deconstruct(): void {
    super.deconstruct();
  }

  /**
   * Show control panel
   *
   * Lingo: createWindow(pWindowID, "roomdimmer.window")
   */
  async showControlPanel(): Promise<void> {
    const component = this.getComponent() as RoomDimmerComponent | null;
    if (!component) return;

    await this.createWindow(this.pWindowId, 'roomdimmer.window');
    this.registerWindowProcedure(this.pWindowId, 'eventProc');

    // Position near furniture
    this.centerWindow(this.pWindowId);

    this.updateInterface();
  }

  /**
   * Hide control panel
   *
   * Lingo: removeWindow(pWindowID)
   */
  hide(): void {
    this.removeWindow(this.pWindowId);
  }

  /**
   * Update interface
   *
   * Lingo: updateInterface()
   */
  updateInterface(): void {
    if (!this.windowExists(this.pWindowId)) return;

    const component = this.getComponent() as RoomDimmerComponent | null;
    if (!component) return;

    const state = component.getState();
    const activePreset = component.getActivePreset();
    const selectedPreset = component.getSelectedPreset();

    // Update power button state
    if (this.elementExists(this.pWindowId, 'power_button')) {
      this.setElementProperty(this.pWindowId, 'power_button', 'active', state === 1);
    }

    // Update preset buttons
    for (let i = 1; i <= 3; i++) {
      const presetId = `preset_${i}`;
      if (this.elementExists(this.pWindowId, presetId)) {
        this.setElementProperty(this.pWindowId, presetId, 'selected', selectedPreset === i);
        this.setElementProperty(this.pWindowId, presetId, 'active', activePreset === i && state === 1);
      }
    }

    // Update color/intensity controls for selected preset
    const preset = component.getPreset(selectedPreset);
    if (preset) {
      this.updatePresetControls(preset);
    }
  }

  /**
   * Update preset controls
   */
  private updatePresetControls(preset: DimmerPreset): void {
    if (!this.windowExists(this.pWindowId)) return;

    // Update color selector
    if (this.elementExists(this.pWindowId, 'color_selector')) {
      this.setElementProperty(this.pWindowId, 'color_selector', 'color', preset.color);
    }

    // Update intensity slider
    if (this.elementExists(this.pWindowId, 'intensity_slider')) {
      this.setElementProperty(this.pWindowId, 'intensity_slider', 'value', preset.intensity);
    }

    // Update background only checkbox
    if (this.elementExists(this.pWindowId, 'bg_only_checkbox')) {
      this.setElementProperty(this.pWindowId, 'bg_only_checkbox', 'checked', preset.bgOnly);
    }
  }

  /**
   * Main window event procedure
   *
   * Lingo: eventProc(tEvent, tSpriteID, tParam, tWindowID)
   */
  override eventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    const component = this.getComponent() as RoomDimmerComponent | null;
    if (!component) return;

    switch (spriteId) {
      case 'close':
        this.hide();
        break;

      case 'power_button':
        component.togglePower();
        this.updateInterface();
        break;

      case 'preset_1':
        component.selectPreset(1);
        this.updateInterface();
        break;

      case 'preset_2':
        component.selectPreset(2);
        this.updateInterface();
        break;

      case 'preset_3':
        component.selectPreset(3);
        this.updateInterface();
        break;

      case 'apply_button':
        component.applyPreset();
        this.updateInterface();
        break;

      case 'color_selector':
        if (typeof param === 'string') {
          component.setPresetColor(param);
          this.updateInterface();
        }
        break;

      case 'intensity_slider':
        if (typeof param === 'number') {
          component.setPresetIntensity(param);
          this.updateInterface();
        }
        break;

      case 'bg_only_checkbox':
        const currentBgOnly = component.getPreset(component.getSelectedPreset())?.bgOnly ?? false;
        component.setPresetBgOnly(!currentBgOnly);
        this.updateInterface();
        break;
    }
  }

  /**
   * Get window ID
   */
  getWindowId(): string {
    return this.pWindowId;
  }
}
