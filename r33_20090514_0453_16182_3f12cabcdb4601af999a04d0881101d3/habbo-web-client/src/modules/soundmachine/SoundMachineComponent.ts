/**
 * Sound Machine Component Class - Main business logic
 *
 * Ported from: hh_soundmachine/Cast External ParentScript 4 - SoundMachine Component Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import {
  registerMessage,
  unregisterMessage,
  executeMessage,
} from '../../core/MessageBus';
import { getConnection } from '../../managers/ConnectionManager';
import { getVariable } from '../../core/VariableContainer';
import {
  SoundSet,
  SoundSample,
  Disk,
  TimelineSample,
  ConfirmAction,
  SOUND_SET_CONSTANTS,
  TIMELINE_CONSTANTS,
  formatTime,
  getSampleSetId,
} from './types';
import { SongTimeline } from './SongTimeline';
import { SongListManager } from './SongListManager';
import { JukeboxManager } from './JukeboxManager';
import { SoundMachineInterface } from './SoundMachineInterface';

export class SoundMachineComponent extends BaseObject {
  private connectionId: string = '';

  // Sound sets
  private soundSetList: (SoundSet | null)[] = [];
  private soundSetInventoryList: Array<{ id: number }> = [];
  private soundSetListPage: number = 1;
  private soundSetInsertLocked: boolean = false;
  private soundSetCount: number | null = null;

  // Selection state
  private selectedSoundSet: number = 0;
  private selectedSoundSetSample: number = 0;
  private hoveredSoundSet: number = 0;
  private hoveredSoundSetSample: number = 0;
  private hoveredSampleReady: boolean = true;
  private hoveredSoundSetTab: number = 0;

  // Timeline state
  private timelineCursorX: number = 0;
  private timelineCursorY: number = 0;
  private timelineScrollX: number = 0;
  private playHeadPosX: number = 0;

  // Editor state
  private editorOpen: boolean = false;
  private editFailure: boolean = false;
  private editorSongPlaying: boolean = false;
  private editorSongStartTime: number = 0;
  private editorSongLength: number = 0;
  private editorSongId: number = 0;

  // Confirm action
  private confirmedAction: ConfirmAction | '' = '';
  private confirmedActionParameter: string | number = '';

  // User disks
  private diskList: Disk[] = [];

  // Furni state
  private soundMachineFurniId: string = '';

  // Sub-managers
  private timeline: SongTimeline = new SongTimeline();
  private playlistManager: SongListManager = new SongListManager();
  private jukeboxManager: JukeboxManager = new JukeboxManager();

  construct(): void {
    super.construct();
    this.connectionId = getVariable('connection.info.id', 'Info') as string;

    this.timeline.construct();
    this.playlistManager.construct();
    this.jukeboxManager.construct();

    this.reset(true);

    registerMessage('sound_machine_selected', this.id, 'soundMachineSelected');
    registerMessage('jukebox_selected', this.id, 'jukeBoxSelected');
    registerMessage('sound_machine_set_state', this.id, 'soundMachineSetState');
    registerMessage('sound_machine_removed', this.id, 'soundMachineRemoved');
    registerMessage('sound_machine_created', this.id, 'soundMachineCreated');
    registerMessage('sound_machine_defined', this.id, 'soundMachineDefined');
    registerMessage('jukebox_defined', this.id, 'jukeBoxDefined');
    registerMessage('listen_song', this.id, 'listenSong');
    registerMessage('do_not_listen_song', this.id, 'stopListenSong');
    registerMessage('get_disk_data', this.id, 'getDiskData');
  }

  deconstruct(): void {
    this.timeline.deconstruct();
    this.playlistManager.deconstruct();
    this.jukeboxManager.deconstruct();

    unregisterMessage('sound_machine_selected', this.id);
    unregisterMessage('jukebox_selected', this.id);
    unregisterMessage('sound_machine_set_state', this.id);
    unregisterMessage('sound_machine_removed', this.id);
    unregisterMessage('sound_machine_created', this.id);
    unregisterMessage('sound_machine_defined', this.id);
    unregisterMessage('jukebox_defined', this.id);
    unregisterMessage('listen_song', this.id);
    unregisterMessage('do_not_listen_song', this.id);
    unregisterMessage('get_disk_data', this.id);

    super.deconstruct();
  }

  /**
   * Reset state
   */
  reset(initialReset: boolean): void {
    this.editFailure = false;
    this.closeEdit(initialReset);
  }

  /**
   * Reset jukebox
   */
  resetJukebox(): void {
    const conn = getConnection(this.connectionId);
    if (conn) {
      conn.send('RESET_JUKEBOX');
    }
  }

  /**
   * Initialize editor mode
   */
  initializeEdit(): void {
    this.timeline.clearTimeline();
    this.editorOpen = true;
    this.soundSetCount = null;
  }

  /**
   * Close editor mode
   */
  closeEdit(initialReset?: boolean): void {
    this.stopEditorSong();
    this.editorSongId = 0;
    this.editorOpen = false;
    this.hoveredSampleReady = true;
    this.selectedSoundSet = 0;
    this.selectedSoundSetSample = 0;
    this.hoveredSoundSet = 0;
    this.hoveredSoundSetSample = 0;
    this.hoveredSoundSetTab = 0;
    this.soundSetListPage = 1;
    this.timelineCursorX = 0;
    this.timelineCursorY = 0;
    this.timelineScrollX = 0;
    this.playHeadPosX = 0;
    this.confirmedAction = '';
    this.confirmedActionParameter = '';
    this.soundSetInsertLocked = false;
    this.editorSongLength = 0;

    this.timeline.clearTimeline();
    this.clearSoundSets();
    this.soundSetInventoryList = [];

    if (!initialReset && !this.editFailure) {
      const conn = getConnection(this.connectionId);
      if (conn) {
        conn.send('SONG_EDIT_CLOSE');
      }
    }
  }

  /**
   * Close select action
   */
  closeSelectAction(): void {
    this.soundMachineFurniId = '';
  }

  /**
   * Confirm an action
   */
  confirmAction(action: ConfirmAction, parameter: string | number): boolean {
    this.confirmedAction = action;
    this.confirmedActionParameter = parameter;

    switch (action) {
      case 'eject':
        if (this.checkSoundSetReferences(parameter as number)) {
          return true;
        }
        break;
      case 'close':
        if (this.timeline.getChanged()) {
          return true;
        }
        break;
      case 'clear':
        return true;
      case 'save':
        if (parameter === this.timeline.getSongName()) {
          return true;
        }
        break;
      case 'delete':
      case 'burn':
      case 'save_list':
        return true;
      case 'close_list':
        if (this.playlistManager.getPlaylistChanged()) {
          return true;
        }
        break;
    }

    this.actionConfirmed();
    return false;
  }

  /**
   * Execute confirmed action
   */
  actionConfirmed(): boolean {
    const iface = this.getInterface() as SoundMachineInterface | null;

    switch (this.confirmedAction) {
      case 'eject':
        if (this.checkSoundSetReferences(this.confirmedActionParameter as number)) {
          this.stopEditorSong();
        }
        const removed = this.removeSoundSet(this.confirmedActionParameter as number);
        if (removed && iface) {
          iface.renderTimeLine();
        }
        break;

      case 'close':
        if (iface) {
          iface.hideSoundMachine();
          iface.showPlaylist();
        }
        break;

      case 'clear':
        this.timeline.clearTimeline();
        this.stopEditorSong();
        if (iface) {
          iface.renderTimeLine();
        }
        break;

      case 'save':
        this.saveEditorSong(this.confirmedActionParameter as string);
        if (iface) {
          iface.hideSaveSong();
        }
        break;

      case 'delete':
        if (this.playlistManager.deleteSong() && iface) {
          iface.renderSongList();
        }
        break;

      case 'burn':
        this.playlistManager.burnSong();
        break;

      case 'save_list':
        this.playlistManager.savePlaylist();
        break;

      case 'close_list':
        if (iface) {
          iface.hidePlaylist();
        }
        this.closeSelectAction();
        break;
    }

    this.confirmedAction = '';
    this.confirmedActionParameter = '';
    return true;
  }

  // Getters
  getSoundSetLimit(): number {
    return SOUND_SET_CONSTANTS.LIMIT;
  }

  getSoundSetListPageSize(): number {
    return SOUND_SET_CONSTANTS.LIST_PAGE_SIZE;
  }

  getSoundSetId(index: number): number {
    if (index < 1 || index > this.soundSetList.length) return 0;
    return this.soundSetList[index - 1]?.id ?? 0;
  }

  getSoundSetListId(index: number): number {
    const realIndex = index + (this.soundSetListPage - 1) * SOUND_SET_CONSTANTS.LIST_PAGE_SIZE;
    if (realIndex < 1 || realIndex > this.soundSetInventoryList.length) return 0;
    return this.soundSetInventoryList[realIndex - 1].id;
  }

  getSoundSetHoveredTab(): number {
    return this.hoveredSoundSetTab;
  }

  getSoundListPage(): number {
    return this.soundSetListPage;
  }

  getSoundListPageCount(): number {
    return 1 + Math.floor((this.soundSetInventoryList.length - 1) / SOUND_SET_CONSTANTS.LIST_PAGE_SIZE);
  }

  getHoveredSampleReady(): boolean {
    return this.hoveredSampleReady;
  }

  getTimeLineSlotLength(): number {
    return this.timeline.getSlotDuration();
  }

  getTimeLineViewSlotCount(): number {
    return TIMELINE_CONSTANTS.VIEW_SLOT_COUNT;
  }

  getTimeString(seconds: number): string {
    return formatTime(seconds, true);
  }

  getTimeStringBasic(seconds: number): string {
    return formatTime(seconds, false);
  }

  getEditorSongName(): string {
    return this.timeline.getSongName();
  }

  getCanSaveSong(): boolean {
    return this.timeline.encodeTimelineData() !== '';
  }

  getCanInsertDisk(): boolean {
    return this.diskList.length > 0;
  }

  getEditorPlayTime(): number {
    if (!this.editorSongPlaying) return 0;
    const slotLength = this.getTimeLineSlotLength();
    const totalLength = slotLength * this.editorSongLength;
    return (Date.now() + 30 - this.editorSongStartTime) % totalLength || 1;
  }

  getPlayHeadPosition(): number {
    const playTime = this.getEditorPlayTime();
    const slotLength = this.getTimeLineSlotLength();
    const length = this.editorSongPlaying
      ? this.editorSongLength
      : this.timeline.getSlotCount();

    let pos = ((playTime / slotLength + this.playHeadPosX) % length) + 1 - this.timelineScrollX;

    if (pos < 1 || pos > TIMELINE_CONSTANTS.VIEW_SLOT_COUNT) {
      return -(pos + this.timelineScrollX);
    }
    return pos;
  }

  getFreeSoundSetCount(): number {
    return this.soundSetList.filter((s) => s === null).length;
  }

  getPlaylistManager(): SongListManager {
    return this.playlistManager;
  }

  getJukeBoxManager(): JukeboxManager {
    return this.jukeboxManager;
  }

  // Sound set methods
  clearSoundSets(): void {
    this.soundSetList = new Array(SOUND_SET_CONSTANTS.LIMIT).fill(null);
  }

  updateSoundSet(index: number, id: number, sampleList: number[]): void {
    if (index < 1 || index > SOUND_SET_CONSTANTS.LIMIT) return;

    const samples: SoundSample[] = sampleList.map((sampleId) => ({
      id: sampleId,
      length: 0,
    }));

    this.soundSetList[index - 1] = { id, samples };
  }

  updateSetList(list: number[]): void {
    this.soundSetInventoryList = list.map((id) => ({ id }));
    this.changeSetListPage(0);

    if (this.soundSetCount !== null) {
      this.soundSetCount += list.length;
    } else {
      this.soundSetCount = list.length;
    }
  }

  changeSetListPage(change: number): boolean {
    let index = this.soundSetListPage + change;
    const pageCount = this.getSoundListPageCount();

    if (index < 1) index = pageCount;
    else if (index > pageCount) index = 1;

    if (index === this.soundSetListPage) return false;
    this.soundSetListPage = index;
    return true;
  }

  loadSoundSet(index: number): boolean {
    const realIndex = index + (this.soundSetListPage - 1) * SOUND_SET_CONSTANTS.LIST_PAGE_SIZE;
    if (realIndex < 1 || realIndex > this.soundSetInventoryList.length) return false;
    if (this.soundSetInsertLocked) return false;

    const freeSlot = this.soundSetList.findIndex((s) => s === null);
    if (freeSlot === -1) return false;

    const soundSet = this.soundSetInventoryList[realIndex - 1];
    const conn = getConnection(this.connectionId);
    if (!conn) return false;

    this.soundSetInventoryList.splice(realIndex - 1, 1);
    this.soundSetInsertLocked = true;
    conn.send('INSERT_SOUND_PACKAGE', { values: [soundSet.id, freeSlot + 1] });
    return true;
  }

  removeSoundSet(index: number): boolean {
    const id = this.getSoundSetId(index);
    if (id === 0) return false;

    this.timeline.soundSetRemoved(id);

    if (this.selectedSoundSet === index) {
      this.selectedSoundSet = 0;
      this.selectedSoundSetSample = 0;
    }

    const conn = getConnection(this.connectionId);
    if (conn) {
      this.soundSetList[index - 1] = null;
      conn.send('EJECT_SOUND_PACKAGE', { integer: index });
    }

    return true;
  }

  removeSoundSetInsertLock(): void {
    this.soundSetInsertLocked = false;
  }

  checkSoundSetReferences(index: number): boolean {
    const id = this.getSoundSetId(index);
    if (id === 0) return false;
    return this.timeline.checkSoundSetReferences(id);
  }

  // Event handlers
  soundSetEvent(setId: number, x: number, y: number, event: string): boolean {
    const sampleIndex = x + (y - 1) * SOUND_SET_CONSTANTS.SAMPLE_HOR_COUNT;

    if (event === 'mouseDown') {
      if (this.selectedSoundSet === setId && this.selectedSoundSetSample === sampleIndex) {
        this.selectedSoundSet = 0;
        this.selectedSoundSetSample = 0;
      } else {
        this.selectedSoundSet = setId;
        this.selectedSoundSetSample = sampleIndex;
      }
    } else if (event === 'mouseWithin') {
      if (this.hoveredSoundSet === setId && this.hoveredSoundSetSample === sampleIndex) {
        return false;
      }
      this.hoveredSoundSet = setId;
      this.hoveredSoundSetSample = sampleIndex;
      // Check sample ready and play preview
    } else if (event === 'mouseLeave') {
      this.hoveredSoundSet = 0;
      this.hoveredSoundSetSample = 0;
      this.hoveredSampleReady = true;
    }

    return true;
  }

  soundSetTabEvent(setId: number, event: string): boolean {
    if (event === 'mouseDown') {
      const iface = this.getInterface() as SoundMachineInterface | null;
      return !iface?.confirmAction('eject', setId);
    } else if (event === 'mouseWithin') {
      if (setId === this.hoveredSoundSetTab) return false;
      this.hoveredSoundSetTab = setId;
    } else if (event === 'mouseLeave') {
      this.hoveredSoundSetTab = 0;
    }
    return true;
  }

  timeLineEvent(x: number, y: number, event: string): boolean {
    const slotX = x + this.timelineScrollX;

    if (event === 'mouseDown') {
      if (this.insertSample(slotX, y)) {
        this.timelineCursorX = 0;
        this.timelineCursorY = 0;
        return true;
      }
      return this.removeSample(slotX, y);
    } else if (event === 'mouseWithin') {
      if (slotX !== this.timelineCursorX || y !== this.timelineCursorY) {
        const sample = this.getSample(this.selectedSoundSetSample, this.selectedSoundSet);
        const canInsert = sample && this.timeline.canInsertSample(slotX, y - 1, sample.id);

        if (canInsert) {
          this.timelineCursorX = slotX;
          this.timelineCursorY = y;
          return true;
        } else if (this.timelineCursorX !== 0 || this.timelineCursorY !== 0) {
          this.timelineCursorX = 0;
          this.timelineCursorY = 0;
          return true;
        }
      }
    } else if (event === 'mouseLeave') {
      this.timelineCursorX = 0;
      this.timelineCursorY = 0;
      return true;
    }

    return false;
  }

  // Timeline methods
  scrollTimeLine(dx: number): boolean {
    const max = this.timeline.getSlotCount() - TIMELINE_CONSTANTS.VIEW_SLOT_COUNT;
    const newX = Math.max(0, Math.min(this.timelineScrollX + dx, max));

    if (newX !== this.timelineScrollX) {
      this.timelineScrollX = newX;
      return true;
    }
    return false;
  }

  scrollTimeLineTo(x: number): boolean {
    const max = this.timeline.getSlotCount() - TIMELINE_CONSTANTS.VIEW_SLOT_COUNT;
    const newX = Math.max(0, Math.min(x, max));

    if (newX !== this.timelineScrollX) {
      this.timelineScrollX = newX;
      return true;
    }
    return false;
  }

  getScrollPossible(dx: number): boolean {
    if (dx < 0) return this.timelineScrollX > 0;
    if (dx > 0) {
      return this.timelineScrollX < this.timeline.getSlotCount() - TIMELINE_CONSTANTS.VIEW_SLOT_COUNT;
    }
    return false;
  }

  movePlayHead(x: number): boolean {
    if (this.editorSongPlaying) return false;

    const pos = x - 1;
    if (pos !== this.playHeadPosX - this.timelineScrollX) {
      if (pos >= 0 && pos < TIMELINE_CONSTANTS.VIEW_SLOT_COUNT) {
        this.playHeadPosX = pos + this.timelineScrollX;
        return true;
      }
    }
    return false;
  }

  // Sample methods
  getSample(sampleIndex: number, sampleSet: number): SoundSample | null {
    if (sampleSet < 1 || sampleSet > this.soundSetList.length) return null;
    const set = this.soundSetList[sampleSet - 1];
    if (!set || sampleIndex < 1 || sampleIndex > set.samples.length) return null;
    return set.samples[sampleIndex - 1];
  }

  insertSample(slot: number, channel: number): boolean {
    const sample = this.getSample(this.selectedSoundSetSample, this.selectedSoundSet);
    if (!sample) return false;

    if (this.timeline.insertSample(slot, channel - 1, sample.id)) {
      this.stopEditorSong();
      return true;
    }
    return false;
  }

  removeSample(slot: number, channel: number): boolean {
    if (this.timeline.removeSample(slot, channel - 1)) {
      this.stopEditorSong();
      return true;
    }
    return false;
  }

  // Editor methods
  playEditorSong(): boolean {
    if (!this.editorOpen || this.editorSongPlaying) return false;

    this.editorSongLength = this.timeline.resolveSongLength();
    if (this.editorSongLength === 0) return false;

    if (this.playHeadPosX > this.editorSongLength) {
      this.playHeadPosX = 0;
    }

    const songData = this.timeline.getSongData();
    if (!songData) return false;

    this.editorSongPlaying = true;
    this.editorSongStartTime = Date.now();
    executeMessage('playSong', songData);

    const iface = this.getInterface() as SoundMachineInterface | null;
    if (iface) {
      iface.updatePlayButton();
    }

    return true;
  }

  stopEditorSong(): void {
    if (this.editorSongPlaying) {
      const playTime = this.getEditorPlayTime();
      const slotLength = this.getTimeLineSlotLength();
      this.playHeadPosX = ((playTime / slotLength + this.playHeadPosX) % this.editorSongLength) | 0;

      this.editorSongPlaying = false;
      this.editorSongLength = 0;
      this.editorSongStartTime = 0;

      executeMessage('stopSong');

      const iface = this.getInterface() as SoundMachineInterface | null;
      if (iface) {
        iface.updatePlayHead();
        iface.updatePlayButton();
      }
    }
  }

  openEditorSong(): boolean {
    if (this.playlistManager.editSong()) {
      this.editorSongId = this.playlistManager.getEditorSongId();
      this.timeline.reset(true);
      return true;
    }
    return false;
  }

  newEditorSong(): boolean {
    if (this.playlistManager.newSong()) {
      this.timeline.reset(false);
      return true;
    }
    return false;
  }

  saveEditorSong(name: string): boolean {
    const encoded = this.timeline.encodeTimelineData();
    if (!encoded) return false;

    const conn = getConnection(this.connectionId);
    if (!conn) return false;

    const id = this.timeline.getSongId();
    if (id === 0) {
      conn.send('SAVE_SONG_NEW', { values: [name, encoded] });
    } else {
      conn.send('SAVE_SONG_EDIT', { values: [id, name, encoded] });
    }

    return true;
  }

  updateEditorSong(id?: number, name?: string): void {
    if (id !== undefined) {
      this.timeline.updateSongId(id);
    }
    if (name !== undefined) {
      this.timeline.updateSongName(name);
    }

    this.timeline.resetChanged();

    const iface = this.getInterface() as SoundMachineInterface | null;
    if (iface) {
      iface.showSongSaved(this.timeline.getSongName());
    }
  }

  // User disks
  getUserDisks(): void {
    this.diskList = [];
    const conn = getConnection(this.connectionId);
    if (conn) {
      conn.send('GET_USER_SONG_DISCS');
    }
  }

  parseUserDisks(disks: Array<{ id: number; name: string }>): void {
    this.diskList = disks;
  }

  insertJukeboxDisk(): void {
    const index = this.playlistManager.getSelectedDiskIndex();
    if (index < 1 || index > this.diskList.length) return;

    const diskId = this.diskList[index - 1].id;
    this.diskList.splice(index - 1, 1);
    this.jukeboxManager.insertDisk(diskId);
  }

  // Sound machine selection
  soundMachineSelected(data: { id: string; furniOn: boolean }): void {
    this.soundMachineFurniId = data.id;
    const iface = this.getInterface() as SoundMachineInterface | null;
    if (iface) {
      iface.soundMachineSelected(data.furniOn);
    }
  }

  jukeBoxSelected(data: { id: string; owner: boolean }): void {
    this.soundMachineFurniId = data.id;
    this.jukeboxManager.setOwner(data.owner);
    const iface = this.getInterface() as SoundMachineInterface | null;
    if (iface) {
      iface.showJukebox();
    }
  }

  // Song data parsing
  parseSongData(
    data: TimelineSample[][],
    songId: number,
    songName: string
  ): void {
    if (this.editorSongId === songId) {
      this.timeline.parseSongData(data, songId, songName);
      this.processEditorSongData();
    }
  }

  processEditorSongData(): void {
    const ready = this.timeline.processSongData();

    if (!ready) {
      setTimeout(() => this.processEditorSongData(), 500);
    }

    if (this.editorOpen) {
      const iface = this.getInterface() as SoundMachineInterface | null;
      if (iface) {
        iface.renderTimeLine();
      }
    }
  }

  // Error handlers
  handleMissingPackages(list: number[]): void {
    this.editFailure = true;
    const iface = this.getInterface() as SoundMachineInterface | null;
    if (iface) {
      iface.hideSoundMachine();
      iface.showAlert('missing_packages');
    }
    this.editFailure = false;
  }

  handleListFull(count: number, listType: string): void {
    const iface = this.getInterface() as SoundMachineInterface | null;
    if (!iface) return;

    if (listType === 'songlist') {
      const id = this.timeline.getSongId();
      if (id === 0) {
        this.editFailure = true;
        iface.hideSoundMachine();
        this.editFailure = false;
      }
      iface.showAlertWithCount('no_more_songs', count);
    } else if (listType === 'playlist') {
      iface.showAlertWithCount('playlist_full', count);
    }
  }

  handleInvalidSongName(): void {
    const iface = this.getInterface() as SoundMachineInterface | null;
    if (iface) {
      iface.showAlert('invalid_song_name');
    }
  }

  handleSongLocked(): void {
    const iface = this.getInterface() as SoundMachineInterface | null;
    if (iface) {
      iface.showAlert('song_locked');
    }
  }

  handleJukeBoxPlaylistFull(): void {
    const iface = this.getInterface() as SoundMachineInterface | null;
    if (iface) {
      iface.showAlert('jukebox_list_full');
    }
  }

  handleInvalidSongLength(): void {
    const iface = this.getInterface() as SoundMachineInterface | null;
    if (iface) {
      iface.showAlert('invalid_song_length');
    }
  }

  // State getters
  getTimelineData(): (number | null)[][] {
    return this.timeline.getTimelineData();
  }

  getTimelineCursor(): { x: number; y: number } {
    return { x: this.timelineCursorX, y: this.timelineCursorY };
  }

  getTimelineScrollX(): number {
    return this.timelineScrollX;
  }

  getSoundSetList(): (SoundSet | null)[] {
    return this.soundSetList;
  }

  getSelectedSoundSet(): number {
    return this.selectedSoundSet;
  }

  getSelectedSoundSetSample(): number {
    return this.selectedSoundSetSample;
  }

  getHoveredSoundSet(): number {
    return this.hoveredSoundSet;
  }

  getHoveredSoundSetSample(): number {
    return this.hoveredSoundSetSample;
  }

  isEditorOpen(): boolean {
    return this.editorOpen;
  }
}
