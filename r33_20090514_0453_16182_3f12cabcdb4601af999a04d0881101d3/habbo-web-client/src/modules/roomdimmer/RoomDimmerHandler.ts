/**
 * Room Dimmer Handler Class - Server message handlers
 *
 * Ported from: hh_roomdimmer/Cast External ParentScript 6 - Roomdimmer Handler Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { HabboMessage } from '../../types';
import { getVariable } from '../../core/VariableContainer';
import { registerListener, registerCommands, unregisterListener, unregisterCommands } from '../../managers/ConnectionManager';
import { HabboConnection } from '../../network/HabboConnection';
import { DimmerPreset, RoomDimmerMessages, RoomDimmerCommands, hexToRgb } from './types';
import { RoomDimmerComponent } from './RoomDimmerComponent';

export class RoomDimmerHandler extends BaseObject {
  construct(): void {
    super.construct();
    this.regMsgList(true);
  }

  deconstruct(): void {
    this.regMsgList(false);
    super.deconstruct();
  }

  /**
   * Handle dimmer presets message
   */
  handleDimmerPresets(msg: HabboMessage): Map<number, DimmerPreset> {
    const conn = msg.connection as HabboConnection;
    if (!conn) return new Map();

    const numOfPresets = conn.GetIntFrom(msg);
    const selectedPresetId = conn.GetIntFrom(msg);

    const presets = new Map<number, DimmerPreset>();

    for (let i = 0; i < numOfPresets; i++) {
      const presetId = conn.GetIntFrom(msg);
      const effectId = conn.GetIntFrom(msg);
      const colorStr = conn.GetStrFrom(msg);
      const lightness = conn.GetIntFrom(msg);

      presets.set(presetId, {
        presetID: presetId,
        effectID: effectId,
        color: hexToRgb(colorStr),
        lightness,
      });
    }

    const component = this.getComponent() as RoomDimmerComponent | null;
    if (component) {
      component.setPresets(presets);
    }

    return presets;
  }

  /**
   * Register/unregister message listeners and commands
   */
  private regMsgList(register: boolean): void {
    const connId = getVariable('connection.info.id', 'Info') as string;

    const messages: Record<number, string> = {
      [RoomDimmerMessages.DIMMER_PRESETS]: 'handleDimmerPresets',
    };

    const commands: Record<string, number> = {
      MSG_ROOMDIMMER_GET_PRESETS: RoomDimmerCommands.MSG_ROOMDIMMER_GET_PRESETS,
      MSG_ROOMDIMMER_SET_PRESET: RoomDimmerCommands.MSG_ROOMDIMMER_SET_PRESET,
      MSG_ROOMDIMMER_CHANGE_STATE: RoomDimmerCommands.MSG_ROOMDIMMER_CHANGE_STATE,
    };

    if (register) {
      registerListener(connId, this.id, messages);
      registerCommands(connId, commands);
    } else {
      unregisterListener(connId, this.id, messages);
      unregisterCommands(connId, this.id, commands);
    }
  }
}
