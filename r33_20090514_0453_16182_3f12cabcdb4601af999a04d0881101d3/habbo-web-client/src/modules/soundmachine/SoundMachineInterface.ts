/**
 * Sound Machine Interface Class - UI handling
 *
 * Ported from: hh_soundmachine/Cast External ParentScript 3 - SoundMachine Interface Class.ls
 */

import { BaseInterface } from '../../core/BaseInterface';
import { executeMessage } from '../../core/MessageBus';
import { ConfirmAction } from './types';
import { SoundMachineComponent } from './SoundMachineComponent';

export class SoundMachineInterface extends BaseInterface {
  private pSelectActionWindowId: string = 'soundmachine_select_window';
  private pSoundMachineWindowId: string = 'soundmachine_editor_window';
  private pPlaylistWindowId: string = 'soundmachine_playlist_window';
  private pSaveSongWindowId: string = 'soundmachine_save_window';
  private pJukeboxWindowId: string = 'soundmachine_jukebox_window';
  private pJukeboxDiskWindowId: string = 'soundmachine_disk_window';
  private pConfirmWindowId: string = 'soundmachine_confirm_window';

  // Window state tracking
  private pPlayHeadDrag: boolean = false;

  construct(): void {
    super.construct();

    this.registerMsg('show_select_disk', 'showSelectDisk');
    this.registerMsg('get_jukebox_song_info', 'getJukeboxNowPlayingText');
    this.registerMsg('s_machine', 'showJukebox');
  }

  deconstruct(): void {
    super.deconstruct();
  }

  /**
   * Show select action window
   *
   * Lingo: createWindow(pSelectActionWindowID, "soundmachine_select.window", VOID, VOID, #modal)
   */
  async showSelectAction(isOn: boolean): Promise<void> {
    await this.createModalWindow(this.pSelectActionWindowId, 'soundmachine_select.window');
    this.registerWindowProcedure(this.pSelectActionWindowId, 'selectActionEventProc');

    // Update state indicator
    if (this.elementExists(this.pSelectActionWindowId, 'state_indicator')) {
      this.setElementProperty(this.pSelectActionWindowId, 'state_indicator', 'on', isOn);
    }
  }

  /**
   * Hide select action window
   */
  hideSelectAction(): void {
    this.removeWindow(this.pSelectActionWindowId);
  }

  /**
   * Show playlist window
   *
   * Lingo: createWindow(pPlaylistWindowID, "soundmachine_playlist.window")
   */
  async showPlaylist(): Promise<void> {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.getPlaylistManager().getSongListData();
    }

    await this.createWindow(this.pPlaylistWindowId, 'soundmachine_playlist.window');
    this.registerWindowProcedure(this.pPlaylistWindowId, 'playlistEventProc');

    this.updatePlaylists();
  }

  /**
   * Hide playlist window
   */
  hidePlaylist(): void {
    this.removeWindow(this.pPlaylistWindowId);
  }

  /**
   * Show sound machine editor
   *
   * Lingo: createWindow(pSoundMachineWindowID, "soundmachine_editor.window")
   */
  async showSoundMachine(): Promise<void> {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.initializeEdit();
    }

    await this.createWindow(this.pSoundMachineWindowId, 'soundmachine_editor.window');
    this.registerWindowProcedure(this.pSoundMachineWindowId, 'editorEventProc');

    this.updateSoundSetVisualizations();
    this.renderTimeLine();
    this.updatePlayHead();
    this.updatePlayButton();
    this.pPlayHeadDrag = false;
  }

  /**
   * Hide sound machine editor
   */
  hideSoundMachine(): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.closeEdit();
    }

    this.removeWindow(this.pSoundMachineWindowId);
  }

  /**
   * Show save song window
   *
   * Lingo: createWindow(pSaveSongWindowID, "soundmachine_save.window", VOID, VOID, #modal)
   */
  async showSaveSong(): Promise<void> {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component?.getCanSaveSong()) {
      this.showAlert('song_not_ready');
      return;
    }

    await this.createModalWindow(this.pSaveSongWindowId, 'soundmachine_save.window');
    this.registerWindowProcedure(this.pSaveSongWindowId, 'saveEventProc');

    // Set current song name
    if (this.elementExists(this.pSaveSongWindowId, 'song_name_input')) {
      this.setText(this.pSaveSongWindowId, 'song_name_input', component.getEditorSongName());
    }
  }

  /**
   * Hide save song window
   */
  hideSaveSong(): void {
    this.removeWindow(this.pSaveSongWindowId);
  }

  /**
   * Show jukebox window
   *
   * Lingo: createWindow(pJukeboxWindowID, "soundmachine_jukebox.window")
   */
  async showJukebox(): Promise<void> {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.getUserDisks();
    }

    await this.createWindow(this.pJukeboxWindowId, 'soundmachine_jukebox.window');
    this.registerWindowProcedure(this.pJukeboxWindowId, 'jukeboxEventProc');

    this.renderJukebox();
  }

  /**
   * Hide jukebox window
   */
  hideJukebox(): void {
    this.removeWindow(this.pJukeboxWindowId);
  }

  /**
   * Show select disk window
   *
   * Lingo: createWindow(pJukeboxDiskWindowID, "soundmachine_disk.window", VOID, VOID, #modal)
   */
  async showSelectDisk(): Promise<void> {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component?.getCanInsertDisk()) {
      this.showAlert('no_disks');
      return;
    }

    await this.createModalWindow(this.pJukeboxDiskWindowId, 'soundmachine_disk.window');
    this.registerWindowProcedure(this.pJukeboxDiskWindowId, 'diskEventProc');

    this.renderUserDiskList(true);
  }

  /**
   * Hide select disk window
   */
  hideJukeboxDisk(): void {
    this.removeWindow(this.pJukeboxDiskWindowId);
  }

  /**
   * Confirm action dialog
   *
   * Lingo: confirmAction(action, parameter)
   */
  async confirmAction(action: ConfirmAction, parameter?: string | number): Promise<boolean> {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return false;

    const needsConfirm = component.confirmAction(action, parameter ?? '');
    if (needsConfirm) {
      await this.createModalWindow(this.pConfirmWindowId, 'soundmachine_confirm.window');
      this.registerWindowProcedure(this.pConfirmWindowId, 'confirmEventProc');

      // Store action for confirmation
      if (this.elementExists(this.pConfirmWindowId, 'action_type')) {
        this.setElementProperty(this.pConfirmWindowId, 'action_type', 'value', action);
      }
    }
    return needsConfirm;
  }

  /**
   * Hide confirm window
   */
  hideConfirm(): void {
    this.removeWindow(this.pConfirmWindowId);
  }

  /**
   * Hide all windows
   */
  hideWindows(): void {
    this.hideSelectAction();
    this.hidePlaylist();
    this.hideSoundMachine();
    this.hideSaveSong();
    this.hideJukebox();
    this.hideJukeboxDisk();
    this.hideConfirm();
  }

  /**
   * Show alert message
   */
  showAlert(type: string, extra?: string): void {
    executeMessage('alert', {
      Msg: `sound_machine_alert_${type}${extra ? ': ' + extra : ''}`,
      modal: true,
    });
  }

  /**
   * Show alert with count
   */
  showAlertWithCount(type: string, count: number): void {
    executeMessage('alert', {
      Msg: `sound_machine_alert_${type}`.replace('%count%', count.toString()),
      modal: true,
    });
  }

  /**
   * Show song saved alert
   */
  showSongSaved(name: string): void {
    executeMessage('alert', {
      Msg: `Song "${name}" saved successfully`,
      modal: true,
    });
  }

  /**
   * Get jukebox now playing text
   */
  getJukeboxNowPlayingText(): { songName: string; author: string } | null {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return null;

    const manager = component.getPlaylistManager();
    if (manager.getPlaylistCount() === 0) return null;

    return {
      songName: manager.getPlaylistSongName(1),
      author: manager.getPlaylistSongAuthor(1),
    };
  }

  /**
   * Render sound sets
   */
  renderSoundSets(): void {
    if (!this.windowExists(this.pSoundMachineWindowId)) return;

    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const soundSets = component.getSoundSetList();
    const selected = component.getSelectedSoundSet();
    const hovered = component.getHoveredSoundSet();

    // Update sound set elements
    for (let i = 0; i < soundSets.length; i++) {
      const elemId = `soundset_${i}`;
      if (this.elementExists(this.pSoundMachineWindowId, elemId)) {
        this.setElementProperty(this.pSoundMachineWindowId, elemId, 'data', soundSets[i]);
        this.setElementProperty(this.pSoundMachineWindowId, elemId, 'selected', selected === i);
        this.setElementProperty(this.pSoundMachineWindowId, elemId, 'hovered', hovered === i);
      }
    }
  }

  /**
   * Render song list
   */
  renderSongList(): void {
    if (!this.windowExists(this.pPlaylistWindowId)) return;

    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const manager = component.getPlaylistManager();

    // Update song list element
    if (this.elementExists(this.pPlaylistWindowId, 'song_list')) {
      this.setElementProperty(this.pPlaylistWindowId, 'song_list', 'songs', manager.getSongList());
      this.setElementProperty(this.pPlaylistWindowId, 'song_list', 'selected', manager.getSelectedSong());
    }
  }

  /**
   * Render playlist
   */
  renderPlaylist(): void {
    if (!this.windowExists(this.pPlaylistWindowId)) return;

    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const manager = component.getPlaylistManager();

    // Update playlist element
    if (this.elementExists(this.pPlaylistWindowId, 'playlist')) {
      this.setElementProperty(this.pPlaylistWindowId, 'playlist', 'songs', manager.getPlaylist());
      this.setElementProperty(this.pPlaylistWindowId, 'playlist', 'selected', manager.getSelectedPlaylistSong());
    }
  }

  /**
   * Render jukebox
   */
  renderJukebox(): void {
    this.renderJukeboxDiskList();
    this.renderJukeboxPlaylist();
  }

  /**
   * Render jukebox playlist
   */
  renderJukeboxPlaylist(): void {
    if (!this.windowExists(this.pJukeboxWindowId)) return;

    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const manager = component.getPlaylistManager();

    // Update now playing
    if (this.elementExists(this.pJukeboxWindowId, 'now_playing')) {
      this.setText(this.pJukeboxWindowId, 'now_playing', manager.getPlaylistSongName(1));
    }
    if (this.elementExists(this.pJukeboxWindowId, 'now_playing_author')) {
      this.setText(this.pJukeboxWindowId, 'now_playing_author', manager.getPlaylistSongAuthor(1));
    }
  }

  /**
   * Render jukebox disk list
   */
  renderJukeboxDiskList(): void {
    if (!this.windowExists(this.pJukeboxWindowId)) return;

    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const jukeboxManager = component.getJukeBoxManager();

    // Update disk list element
    if (this.elementExists(this.pJukeboxWindowId, 'disk_list')) {
      this.setElementProperty(this.pJukeboxWindowId, 'disk_list', 'disks', jukeboxManager.getDiskList());
      this.setElementProperty(this.pJukeboxWindowId, 'disk_list', 'selected', jukeboxManager.getSelectedDisk());
    }
  }

  /**
   * Render user disk list
   */
  renderUserDiskList(initialRender: boolean): void {
    if (!this.windowExists(this.pJukeboxDiskWindowId)) return;

    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const manager = component.getPlaylistManager();

    // Update user disk list element
    if (this.elementExists(this.pJukeboxDiskWindowId, 'user_disk_list')) {
      this.setElementProperty(this.pJukeboxDiskWindowId, 'user_disk_list', 'disks', manager.getDiskList());
      this.setElementProperty(this.pJukeboxDiskWindowId, 'user_disk_list', 'selected', manager.getSelectedDiskIndex());
    }
  }

  /**
   * Render timeline
   */
  renderTimeLine(): void {
    if (!this.windowExists(this.pSoundMachineWindowId)) return;

    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    // Update timeline element
    if (this.elementExists(this.pSoundMachineWindowId, 'timeline')) {
      this.setElementProperty(this.pSoundMachineWindowId, 'timeline', 'data', component.getTimelineData());
      this.setElementProperty(this.pSoundMachineWindowId, 'timeline', 'scrollX', component.getTimelineScrollX());
      this.setElementProperty(this.pSoundMachineWindowId, 'timeline', 'cursor', component.getTimelineCursor());
    }

    // Update scroll buttons
    if (this.elementExists(this.pSoundMachineWindowId, 'scroll_left')) {
      this.setElementProperty(this.pSoundMachineWindowId, 'scroll_left', 'enabled', component.getScrollPossible(-1));
    }
    if (this.elementExists(this.pSoundMachineWindowId, 'scroll_right')) {
      this.setElementProperty(this.pSoundMachineWindowId, 'scroll_right', 'enabled', component.getScrollPossible(1));
    }

    this.updatePlayHead(true);
  }

  /**
   * Update sound set tabs
   */
  updateSoundSetTabs(): void {
    if (!this.windowExists(this.pSoundMachineWindowId)) return;

    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const soundSets = component.getSoundSetList();
    const hoveredTab = component.getSoundSetHoveredTab();

    // Update tab elements
    for (let i = 0; i < soundSets.length; i++) {
      const tabId = `tab_${i}`;
      if (this.elementExists(this.pSoundMachineWindowId, tabId)) {
        this.setElementProperty(this.pSoundMachineWindowId, tabId, 'hovered', hoveredTab === i);
      }
    }
  }

  /**
   * Update sound set slots
   */
  updateSoundSetSlots(): void {
    this.updateSoundSetTabs();
    this.renderSoundSets();
    this.renderTimeLine();
  }

  /**
   * Update sound set list
   */
  updateSoundSetList(): void {
    if (!this.windowExists(this.pSoundMachineWindowId)) return;

    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    // Update page indicator
    if (this.elementExists(this.pSoundMachineWindowId, 'page_indicator')) {
      const page = component.getSoundListPage();
      const pageCount = component.getSoundListPageCount();
      this.setText(this.pSoundMachineWindowId, 'page_indicator', `${page + 1}/${pageCount}`);
    }
  }

  /**
   * Update sound set visualizations
   */
  updateSoundSetVisualizations(): void {
    this.updateSoundSetList();
    this.updateSoundSetSlots();
  }

  /**
   * Scroll timeline
   */
  scrollTimeLine(dx: number): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (component?.scrollTimeLine(dx)) {
      this.renderTimeLine();
    }
  }

  /**
   * Scroll timeline to position
   */
  scrollTimeLineTo(x: number): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (component?.scrollTimeLineTo(x)) {
      this.renderTimeLine();
    }
  }

  /**
   * Update playlists
   */
  updatePlaylists(): void {
    this.renderSongList();
    this.renderPlaylist();
  }

  /**
   * Update playhead
   */
  updatePlayHead(manualUpdate: boolean = false): void {
    if (!this.windowExists(this.pSoundMachineWindowId)) return;

    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const pos = component.getPlayHeadPosition();

    if (this.elementExists(this.pSoundMachineWindowId, 'playhead')) {
      this.setElementProperty(this.pSoundMachineWindowId, 'playhead', 'position', pos);
      this.setElementProperty(this.pSoundMachineWindowId, 'playhead', 'visible', pos > 0);
    }

    if (pos <= 0 && !manualUpdate) {
      this.scrollTimeLineTo(-pos - 1);
    }
  }

  /**
   * Update play button
   */
  updatePlayButton(): void {
    if (!this.windowExists(this.pSoundMachineWindowId)) return;

    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const isPlaying = component.getEditorPlayTime() > 0;

    if (this.elementExists(this.pSoundMachineWindowId, 'play_button')) {
      this.setElementProperty(this.pSoundMachineWindowId, 'play_button', 'playing', isPlaying);
    }
  }

  /**
   * Sound machine selected callback
   */
  soundMachineSelected(isOn: boolean): void {
    this.showSelectAction(isOn);
  }

  /**
   * Get editor window exists
   */
  getEditorWindowExists(): boolean {
    return this.windowExists(this.pSoundMachineWindowId);
  }

  // Event procedures

  selectActionEventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    switch (spriteId) {
      case 'button_editor':
        this.hideSelectAction();
        this.showSoundMachine();
        break;
      case 'button_playlist':
        this.hideSelectAction();
        this.showPlaylist();
        break;
      case 'close':
        this.hideSelectAction();
        break;
    }
  }

  editorEventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    if (event === 'mouseUp') {
      switch (spriteId) {
        case 'close':
          this.hideSoundMachine();
          break;
        case 'play_button':
          if (component.getEditorPlayTime() > 0) {
            component.stopEditorSong();
          } else {
            component.playEditorSong();
          }
          this.updatePlayButton();
          break;
        case 'save_button':
          this.showSaveSong();
          break;
        case 'clear_button':
          this.confirmAction('clear');
          break;
        case 'scroll_left':
          this.scrollTimeLine(-10);
          break;
        case 'scroll_right':
          this.scrollTimeLine(10);
          break;
      }
    }
  }

  playlistEventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    switch (spriteId) {
      case 'close':
        this.hidePlaylist();
        break;
    }
  }

  saveEventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    const component = this.getComponent() as SoundMachineComponent | null;

    switch (spriteId) {
      case 'button_save':
        if (component) {
          const name = this.getText(this.pSaveSongWindowId, 'song_name_input');
          component.saveSong(name);
        }
        this.hideSaveSong();
        break;
      case 'button_cancel':
      case 'close':
        this.hideSaveSong();
        break;
    }
  }

  jukeboxEventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    switch (spriteId) {
      case 'close':
        this.hideJukebox();
        break;
      case 'button_add_disk':
        this.showSelectDisk();
        break;
    }
  }

  diskEventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    const component = this.getComponent() as SoundMachineComponent | null;

    switch (spriteId) {
      case 'button_insert':
        if (component) {
          component.insertSelectedDisk();
        }
        this.hideJukeboxDisk();
        break;
      case 'button_cancel':
      case 'close':
        this.hideJukeboxDisk();
        break;
    }
  }

  confirmEventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    const component = this.getComponent() as SoundMachineComponent | null;

    switch (spriteId) {
      case 'button_ok':
        if (component) {
          component.actionConfirmed();
        }
        this.hideConfirm();
        break;
      case 'button_cancel':
      case 'close':
        this.hideConfirm();
        break;
    }
  }

  /**
   * Get window IDs
   */
  getSoundMachineWindowId(): string {
    return this.pSoundMachineWindowId;
  }

  getPlaylistWindowId(): string {
    return this.pPlaylistWindowId;
  }

  getJukeboxWindowId(): string {
    return this.pJukeboxWindowId;
  }
}
