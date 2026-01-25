/**
 * Sound Machine Handler Class - Server message handlers
 *
 * Ported from: hh_soundmachine/Cast External ParentScript 5 - SoundMachine Handler Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { HabboMessage } from '../../types';
import { getVariable } from '../../core/VariableContainer';
import {
  registerListener,
  registerCommands,
  unregisterListener,
  unregisterCommands,
} from '../../managers/ConnectionManager';
import { HabboConnection } from '../../network/HabboConnection';
import { SoundMachineMessages, SoundMachineCommands, TimelineSample } from './types';
import { SoundMachineComponent } from './SoundMachineComponent';

export class SoundMachineHandler extends BaseObject {
  construct(): void {
    super.construct();
    this.regMsgList(true);
  }

  deconstruct(): void {
    this.regMsgList(false);
    super.deconstruct();
  }

  /**
   * Handle song info message
   */
  handleSongInfo(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const songId = conn.GetIntFrom(msg);
    const name = conn.GetStrFrom(msg);
    const dataStr = conn.GetStrFrom(msg);

    // Parse channel data
    const data: TimelineSample[][] = [];
    const parts = dataStr.split(':');

    for (let i = 0; i < parts.length - 1; i += 2) {
      const channelNumber = parseInt(parts[i], 10);
      const channelData = parts[i + 1];

      if (isNaN(channelNumber)) continue;

      const samples: TimelineSample[] = [];
      const sampleParts = channelData.split(';');

      for (const samplePart of sampleParts) {
        if (!samplePart) continue;
        const sampleData = samplePart.split(',');
        if (sampleData.length >= 2) {
          const id = parseInt(sampleData[0], 10);
          const count = parseInt(sampleData[1], 10);
          if (!isNaN(id) && !isNaN(count)) {
            samples.push({ id, length: count });
          }
        }
      }

      data[channelNumber - 1] = samples;
    }

    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.parseSongData(data, songId, name);
    }
  }

  /**
   * Handle machine sound packages message
   */
  handleMachineSoundPackages(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const slotCount = conn.GetIntFrom(msg);
    const filledSlots = conn.GetIntFrom(msg);

    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    component.clearSoundSets();

    for (let i = 0; i < filledSlots; i++) {
      const slotIndex = conn.GetIntFrom(msg);
      const id = conn.GetIntFrom(msg);
      const sampleCount = conn.GetIntFrom(msg);

      const sampleList: number[] = [];
      for (let j = 0; j < sampleCount; j++) {
        sampleList.push(conn.GetIntFrom(msg));
      }

      component.updateSoundSet(slotIndex, id, sampleList);
    }

    component.removeSoundSetInsertLock();
  }

  /**
   * Handle user sound packages message
   */
  handleUserSoundPackages(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const count = conn.GetIntFrom(msg);
    const list: number[] = [];

    for (let i = 0; i < count; i++) {
      list.push(conn.GetIntFrom(msg));
    }

    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.updateSetList(list);
    }
  }

  /**
   * Handle invalid song name message
   */
  handleInvalidSongName(msg: HabboMessage): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.handleInvalidSongName();
    }
  }

  /**
   * Handle song list message
   */
  handleSongList(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const count = conn.GetIntFrom(msg);
    const songs: Array<{ id: number; length: number; name: string; locked: boolean }> = [];

    for (let i = 0; i < count; i++) {
      const id = conn.GetIntFrom(msg);
      const length = conn.GetIntFrom(msg);
      const name = conn.GetStrFrom(msg);
      const locked = conn.GetIntFrom(msg) !== 0;
      songs.push({ id, length, name, locked });
    }

    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.getPlaylistManager().parseSongList(songs);
    }
  }

  /**
   * Handle playlist message
   */
  handlePlayList(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const playTime = conn.GetIntFrom(msg);
    const count = conn.GetIntFrom(msg);
    const songs: Array<{ id: number; length: number; name: string; author: string }> = [];

    for (let i = 0; i < count; i++) {
      const id = conn.GetIntFrom(msg);
      const length = conn.GetIntFrom(msg);
      const name = conn.GetStrFrom(msg);
      const author = conn.GetStrFrom(msg);
      songs.push({ id, length, name, author });
    }

    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.getPlaylistManager().parsePlaylist(playTime, songs);
    }
  }

  /**
   * Handle song missing packages message
   */
  handleSongMissingPackages(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const count = conn.GetIntFrom(msg);
    const list: number[] = [];

    for (let i = 0; i < count; i++) {
      list.push(conn.GetIntFrom(msg));
    }

    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.handleMissingPackages(list);
    }
  }

  /**
   * Handle playlist invalid message
   */
  handlePlayListInvalid(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const count = conn.GetIntFrom(msg);

    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.handleListFull(count, 'playlist');
    }
  }

  /**
   * Handle song list full message
   */
  handleSongListFull(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const count = conn.GetIntFrom(msg);

    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.handleListFull(count, 'songlist');
    }
  }

  /**
   * Handle new song message
   */
  handleNewSong(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const id = conn.GetIntFrom(msg);
    const name = conn.GetStrFrom(msg);

    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.updateEditorSong(id, name);
    }
  }

  /**
   * Handle user song disks message
   */
  handleUserSongDisks(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const count = conn.GetIntFrom(msg);
    const disks: Array<{ id: number; name: string }> = [];

    for (let i = 0; i < count; i++) {
      const id = conn.GetIntFrom(msg);
      const name = conn.GetStrFrom(msg);
      disks.push({ id, name });
    }

    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.parseUserDisks(disks);
    }
  }

  /**
   * Handle jukebox disks message
   */
  handleJukeboxDisks(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const count = conn.GetIntFrom(msg);
    const disks: Array<{ id: number; name: string }> = [];

    for (let i = 0; i < count; i++) {
      const id = conn.GetIntFrom(msg);
      const name = conn.GetStrFrom(msg);
      disks.push({ id, name });
    }

    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.getJukeBoxManager().parseDiskList(disks);
    }
  }

  /**
   * Handle jukebox song added message
   */
  handleJukeboxSongAdded(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const id = conn.GetIntFrom(msg);
    const length = conn.GetIntFrom(msg);
    const name = conn.GetStrFrom(msg);
    const author = conn.GetStrFrom(msg);

    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.getPlaylistManager().insertPlaylistSong(id, length, name, author);
    }
  }

  /**
   * Handle song locked message
   */
  handleSongLocked(msg: HabboMessage): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.handleSongLocked();
    }
  }

  /**
   * Handle jukebox playlist full message
   */
  handleJukeboxPlaylistFull(msg: HabboMessage): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.handleJukeBoxPlaylistFull();
    }
  }

  /**
   * Handle invalid song length message
   */
  handleInvalidSongLength(msg: HabboMessage): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.handleInvalidSongLength();
    }
  }

  /**
   * Handle song saved message
   */
  handleSongSaved(msg: HabboMessage): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.updateEditorSong();
    }
  }

  /**
   * Register/unregister message listeners
   */
  private regMsgList(register: boolean): void {
    const connId = getVariable('connection.info.id', 'Info') as string;

    const messages: Record<number, string> = {
      [SoundMachineMessages.SONG_INFO]: 'handleSongInfo',
      [SoundMachineMessages.MACHINE_SOUND_PACKAGES]: 'handleMachineSoundPackages',
      [SoundMachineMessages.USER_SOUND_PACKAGES]: 'handleUserSoundPackages',
      [SoundMachineMessages.INVALID_SONG_NAME]: 'handleInvalidSongName',
      [SoundMachineMessages.SONG_LIST]: 'handleSongList',
      [SoundMachineMessages.PLAY_LIST]: 'handlePlayList',
      [SoundMachineMessages.SONG_MISSING_PACKAGES]: 'handleSongMissingPackages',
      [SoundMachineMessages.PLAY_LIST_INVALID]: 'handlePlayListInvalid',
      [SoundMachineMessages.SONG_LIST_FULL]: 'handleSongListFull',
      [SoundMachineMessages.NEW_SONG]: 'handleNewSong',
      [SoundMachineMessages.USER_SONG_DISKS]: 'handleUserSongDisks',
      [SoundMachineMessages.JUKEBOX_DISKS]: 'handleJukeboxDisks',
      [SoundMachineMessages.JUKEBOX_SONG_ADDED]: 'handleJukeboxSongAdded',
      [SoundMachineMessages.SONG_LOCKED]: 'handleSongLocked',
      [SoundMachineMessages.JUKEBOX_PLAYLIST_FULL]: 'handleJukeboxPlaylistFull',
      [SoundMachineMessages.INVALID_SONG_LENGTH]: 'handleInvalidSongLength',
      [SoundMachineMessages.SONG_SAVED]: 'handleSongSaved',
    };

    const commands: Record<string, number> = {
      INSERT_SOUND_PACKAGE: SoundMachineCommands.INSERT_SOUND_PACKAGE,
      EJECT_SOUND_PACKAGE: SoundMachineCommands.EJECT_SOUND_PACKAGE,
      GET_SONG_INFO: SoundMachineCommands.GET_SONG_INFO,
      NEW_SONG: SoundMachineCommands.NEW_SONG,
      SAVE_SONG_NEW: SoundMachineCommands.SAVE_SONG_NEW,
      EDIT_SONG: SoundMachineCommands.EDIT_SONG,
      SAVE_SONG_EDIT: SoundMachineCommands.SAVE_SONG_EDIT,
      BURN_SONG: SoundMachineCommands.BURN_SONG,
      SONG_EDIT_CLOSE: SoundMachineCommands.SONG_EDIT_CLOSE,
      UPDATE_PLAY_LIST: SoundMachineCommands.UPDATE_PLAY_LIST,
      GET_SONG_LIST: SoundMachineCommands.GET_SONG_LIST,
      GET_PLAY_LIST: SoundMachineCommands.GET_PLAY_LIST,
      DELETE_SONG: SoundMachineCommands.DELETE_SONG,
      ADD_JUKEBOX_DISC: SoundMachineCommands.ADD_JUKEBOX_DISC,
      REMOVE_JUKEBOX_DISC: SoundMachineCommands.REMOVE_JUKEBOX_DISC,
      JUKEBOX_PLAYLIST_ADD: SoundMachineCommands.JUKEBOX_PLAYLIST_ADD,
      GET_JUKEBOX_DISCS: SoundMachineCommands.GET_JUKEBOX_DISCS,
      GET_USER_SONG_DISCS: SoundMachineCommands.GET_USER_SONG_DISCS,
      RESET_JUKEBOX: SoundMachineCommands.RESET_JUKEBOX,
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
