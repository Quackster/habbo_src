/**
 * Room Dimmer Component Class - Business logic for room dimmer
 *
 * Ported from: hh_roomdimmer/Cast External ParentScript 5 - Roomdimmer Component Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { registerMessage, unregisterMessage, executeMessage } from '../../core/MessageBus';
import { getConnection } from '../../managers/ConnectionManager';
import { getVariable } from '../../core/VariableContainer';
import { RGBColor, DimmerPreset, DimmerState, DimmerEffect, rgbToHsl, hslToRgb } from './types';
import { RoomDimmerInterface } from './RoomDimmerInterface';

export class RoomDimmerComponent extends BaseObject {
  private effectId: number = 1;
  private color: RGBColor = { red: 255, green: 255, blue: 255 };
  private lightness: number = 1;
  private presets: Map<number, DimmerPreset> = new Map();
  private isOn: boolean = false;
  private presetId: number = 0;
  private furniId: string = '';

  // Applied state
  private appliedEffectId: number = 0;
  private appliedColor: RGBColor = { red: 255, green: 255, blue: 255 };
  private appliedLightness: number = 255;

  // Transition
  private transitionTime: number = 1500;
  private applyTime: number = 0;
  private targetColor: RGBColor = { red: 255, green: 255, blue: 255 };
  private targetLightness: number = 255;
  private targetTime: number = 0;
  private updateInterval: ReturnType<typeof setInterval> | null = null;

  // Effect mappings
  private effects: Map<number, string> = new Map([
    [DimmerEffect.SET_DIMMER_COLOR, 'setDimmerColor'],
    [DimmerEffect.COLORIZE_ROOM, 'colorizeRoom'],
  ]);

  construct(): void {
    super.construct();

    registerMessage('roomdimmer_defined', this.id, 'roomdimmerDefined');
    registerMessage('roomdimmer_selected', this.id, 'select');
    registerMessage('roomdimmer_removed', this.id, 'remove');
    registerMessage('roomdimmer_set_state', this.id, 'setState');
  }

  deconstruct(): void {
    if (this.updateInterval) {
      clearInterval(this.updateInterval);
      this.updateInterval = null;
    }

    unregisterMessage('roomdimmer_selected', this.id);
    unregisterMessage('roomdimmer_removed', this.id);

    super.deconstruct();
  }

  /**
   * Turn off dimmer
   */
  turnOff(): void {
    if (this.appliedEffectId > 0) {
      this.removeEffect(this.appliedEffectId);
    }
    this.appliedColor = { red: 255, green: 255, blue: 255 };
    this.appliedLightness = 255;
  }

  /**
   * Handle dimmer defined in room
   */
  roomdimmerDefined(furniId: string): void {
    this.furniId = furniId;

    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send('MSG_ROOMDIMMER_GET_PRESETS');
    }
  }

  /**
   * Select/open dimmer control panel
   */
  select(): void {
    if (this.presets.size === 0) {
      return;
    }

    const iface = this.getInterface() as RoomDimmerInterface | null;
    if (iface) {
      iface.showControlPanel();
    }
  }

  /**
   * Remove dimmer from room
   */
  remove(id: string): void {
    if (id !== this.furniId) {
      return;
    }

    const iface = this.getInterface() as RoomDimmerInterface | null;
    if (iface) {
      iface.hide();
    }

    if (this.appliedEffectId !== 0) {
      this.removeEffect(this.appliedEffectId);
    }
  }

  /**
   * Apply current preset
   */
  applyPreset(): void {
    this.savePreset({
      presetID: this.presetId,
      effectID: this.effectId,
      color: this.color,
      lightness: this.lightness,
      apply: true,
    });
  }

  /**
   * Save preset to server
   */
  savePreset(preset: DimmerPreset): void {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (!conn) return;

    let colorStr: string;
    if (typeof preset.color === 'string') {
      colorStr = preset.color;
    } else {
      const r = Math.round(preset.color.red).toString(16).padStart(2, '0');
      const g = Math.round(preset.color.green).toString(16).padStart(2, '0');
      const b = Math.round(preset.color.blue).toString(16).padStart(2, '0');
      colorStr = `#${r}${g}${b}`;
    }

    conn.send('MSG_ROOMDIMMER_SET_PRESET', {
      values: [
        preset.presetID,
        preset.effectID,
        colorStr,
        preset.lightness,
        preset.apply ?? false,
      ],
    });

    this.presets.set(preset.presetID, preset);
  }

  /**
   * Get current preset ID
   */
  getCurrentPreset(): number {
    return this.presetId;
  }

  /**
   * Set dimmer state
   */
  setState(stateData: DimmerState): void {
    this.isOn = stateData.isOn;
    this.presetId = stateData.presetID;
    this.effectId = stateData.effectID;
    this.targetColor = stateData.color;
    this.targetLightness = stateData.lightness;
    this.targetTime = Date.now() + this.transitionTime;

    if (this.isOn) {
      this.applyTime = Date.now();
      this.startUpdate();
    } else {
      this.stopUpdate();
      this.turnOff();
    }

    const iface = this.getInterface() as RoomDimmerInterface | null;
    if (iface) {
      iface.updateInterface();
    }
  }

  /**
   * Start update loop
   */
  private startUpdate(): void {
    if (this.updateInterval) return;
    this.updateInterval = setInterval(() => this.update(), 50);
  }

  /**
   * Stop update loop
   */
  private stopUpdate(): void {
    if (this.updateInterval) {
      clearInterval(this.updateInterval);
      this.updateInterval = null;
    }
  }

  /**
   * Update transition
   */
  private update(): void {
    const diffR = this.targetColor.red - this.appliedColor.red;
    const diffG = this.targetColor.green - this.appliedColor.green;
    const diffB = this.targetColor.blue - this.appliedColor.blue;
    const diffL = this.targetLightness - this.appliedLightness;

    const currentTime = Date.now();
    let newColor: RGBColor;
    let newLightness: number;

    if (currentTime >= this.targetTime) {
      this.stopUpdate();
      newColor = this.targetColor;
      newLightness = this.targetLightness;
    } else {
      const ratio = (currentTime - this.applyTime) / (this.targetTime - this.applyTime);
      newColor = {
        red: this.appliedColor.red + ratio * diffR,
        green: this.appliedColor.green + ratio * diffG,
        blue: this.appliedColor.blue + ratio * diffB,
      };
      newLightness = this.appliedLightness + ratio * diffL;
    }

    this.applyEffect(this.effectId, newColor, newLightness);
  }

  /**
   * Get preset by ID
   */
  getPreset(presetId: number): DimmerPreset | null {
    return this.presets.get(presetId) ?? null;
  }

  /**
   * Get current preset ID
   */
  getPresetId(): number {
    return this.presetId;
  }

  /**
   * Set presets from server
   */
  setPresets(presets: Map<number, DimmerPreset>): void {
    this.presets = presets;
  }

  /**
   * Remove applied effect
   */
  private removeEffect(effectId: number): void {
    const effect = this.effects.get(this.appliedEffectId);
    if (!effect) return;

    executeMessage(effect, { red: 255, green: 255, blue: 255 });
    this.appliedEffectId = 0;
  }

  /**
   * Apply effect
   */
  private applyEffect(effectId: number, color: RGBColor, lightness: number): void {
    if (this.appliedEffectId !== effectId && this.appliedEffectId !== 0) {
      this.removeEffect(this.appliedEffectId);
    }

    const effect = this.effects.get(effectId);
    if (!effect) return;

    // Adjust color with lightness
    const hsl = rgbToHsl(color);
    hsl.lightness = lightness;
    const adjustedColor = hslToRgb(hsl);

    executeMessage(effect, adjustedColor);

    this.appliedEffectId = effectId;
    this.appliedColor = color;
    this.appliedLightness = lightness;
    this.applyTime = Date.now();
  }

  /**
   * Toggle dimmer on/off
   */
  toggleOnOff(): boolean {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (!conn) return false;

    conn.send('MSG_ROOMDIMMER_CHANGE_STATE');
    return true;
  }

  /**
   * Check if dimmer is on
   */
  isDimmerOn(): boolean {
    return this.isOn;
  }

  /**
   * Get all presets
   */
  getPresets(): Map<number, DimmerPreset> {
    return new Map(this.presets);
  }
}
