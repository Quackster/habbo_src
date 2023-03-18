property pSoundMachineWindowID, pPlaylistWindowID, pSoundMachineConfirmWindowID, pSaveSongWindowID, pJukeboxWindowID, pJukeboxDiskWindowID, pSoundSetSlotWd, pSoundSetSlotHt, pSoundSetSlotMarginWd, pSoundSetSlotMarginHt, pSoundSetSampleMemberList, pSoundSetSampleMemberName, pTimeLineSlotWd, pTimeLineSlotHt, pTimeLineSlotMarginWd, pTimeLineSlotMarginHt, pTimeLineScrollStep, pSoundSetIconUpdateTimer, pPlayHeadUpdateTimer, pJukeboxListUpdateTimer, pPlayHeadEventAgentID, pPlayHeadDrag

on construct me
  pSoundSetIconUpdateTimer = "sound_machine_icon_timer"
  pPlayHeadUpdateTimer = "sound_machine_playhead_timer"
  pJukeboxListUpdateTimer = "jukebox_list_timer"
  pSoundMachineWindowID = getText("sound_machine_window")
  pPlaylistWindowID = getText("sound_machine_playlist_window")
  pSoundMachineConfirmWindowID = getText("sound_machine_confirm_window")
  pSaveSongWindowID = getText("sound_machine_save_window")
  pJukeboxWindowID = getText("sound_machine_jukebox_window")
  pJukeboxDiskWindowID = getText("sound_machine_jukebox_disk_window")
  registerMessage(#show_select_disk, me.getID(), #showSelectDisk)
  registerMessage(#s_machine, me.getID(), #showJukebox)
  pSoundSetSlotWd = 25
  pSoundSetSlotHt = 25
  pSoundSetSlotMarginWd = -1
  pSoundSetSlotMarginHt = -1
  pTimeLineScrollStep = 10
  pSoundSetSampleMemberList = ["sound_system_ui_sample_g_", "sound_system_ui_sample_y_", "sound_system_ui_sample_p_", "sound_system_ui_sample_b_"]
  pSoundSetSampleMemberName = "sound_system_ui_sample_"
  pTimeLineSlotWd = 23
  pTimeLineSlotHt = 25
  pTimeLineSlotMarginWd = -1
  pTimeLineSlotMarginHt = 1
  pPlayHeadEventAgentID = me.getID() && the milliSeconds
  createObject(pPlayHeadEventAgentID, getClassVariable("event.agent.class"))
  return 1
end

on deconstruct me
  unregisterMessage(#show_select_disk, me.getID())
  unregisterMessage(#s_machine, me.getID())
  if timeoutExists(pSoundSetIconUpdateTimer) then
    removeTimeout(pSoundSetIconUpdateTimer)
  end if
  if timeoutExists(pPlayHeadUpdateTimer) then
    removeTimeout(pPlayHeadUpdateTimer)
  end if
  if timeoutExists(pJukeboxListUpdateTimer) then
    removeTimeout(pJukeboxListUpdateTimer)
  end if
  removeObject(pPlayHeadEventAgentID)
  return 1
end

on showSelectAction me, tIsOn
  if not windowExists(pSoundMachineWindowID) then
    if not createWindow(pSoundMachineWindowID, "habbo_full.window") then
      return error(me, "Failed to open Sound Machine window!!!", #showSoundMachine, #major)
    else
      tWndObj = getWindow(pSoundMachineWindowID)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcSelectAction, me.getID(), #mouseUp)
      if not tWndObj.merge("sound_machine_action.window") then
        return tWndObj.close()
      end if
      tElem = tWndObj.getElement("sound_machine_onoff")
      if tElem <> 0 then
        if tIsOn then
          tText = getText("sound_machine_turn_off")
        else
          tText = getText("sound_machine_turn_on")
        end if
        tElem.setText(tText)
      end if
      tWndObj.center()
      tWndObj.moveBy(0, -30)
    end if
  else
    tWndObj = getWindow(pSoundMachineWindowID)
    tElem = tWndObj.getElement("sound_machine_onoff")
    if tElem <> 0 then
      if tIsOn then
        tText = getText("sound_machine_turn_off")
      else
        tText = getText("sound_machine_turn_on")
      end if
      tElem.setText(tText)
    end if
  end if
  return 1
end

on showPlaylist me
  if not windowExists(pPlaylistWindowID) then
    if not createWindow(pPlaylistWindowID, "sound_machine_window.window", VOID, VOID, #modal) then
      return error(me, "Failed to open Sound Machine window!!!", #showPlaylist, #major)
    else
      tWndObj = getWindow(pPlaylistWindowID)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcPlaylist, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProcPlaylist, me.getID(), #mouseWithin)
      tWndObj.registerProcedure(#eventProcPlaylist, me.getID(), #mouseLeave)
      if not tWndObj.merge("sound_machine_playlist.window") then
        return tWndObj.close()
      end if
      tElemList = ["sound_machine_edit_text", "sound_machine_new_text", "sound_machine_list_save_text", "sound_machine_burn_text"]
      repeat with tElemName in tElemList
        tElem = tWndObj.getElement(tElemName)
        if tElem <> 0 then
          tsprite = tElem.getProperty(#sprite)
          if ilk(tsprite) = #sprite then
            removeEventBroker(tsprite.spriteNum)
          end if
        end if
      end repeat
      tWndObj.center()
      tWndObj.moveBy(0, -30)
      tPlaylistManager = me.getComponent().getPlaylistManager()
      if tPlaylistManager <> 0 then
        tPlaylistManager.getSongListData()
      end if
      me.updatePlaylists()
    end if
  end if
  return 1
end

on showSoundMachine me
  if not windowExists(pSoundMachineWindowID) then
    if not createWindow(pSoundMachineWindowID, "sound_machine_window.window", VOID, VOID, #modal) then
      return error(me, "Failed to open Sound Machine window!!!", #showSoundMachine, #major)
    else
      tWndObj = getWindow(pSoundMachineWindowID)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcSoundMachine, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProcSoundMachine, me.getID(), #mouseDown)
      tWndObj.registerProcedure(#eventProcSoundMachine, me.getID(), #mouseEnter)
      tWndObj.registerProcedure(#eventProcSoundMachine, me.getID(), #mouseWithin)
      tWndObj.registerProcedure(#eventProcSoundMachine, me.getID(), #mouseLeave)
      if not tWndObj.merge("sound_machine_ui.window") then
        return tWndObj.close()
      end if
      me.getComponent().clearTimeLine()
      me.updateSoundSetVisualizations()
      me.renderTimeLine()
      me.updatePlayHead()
      me.updatePlayButton()
      me.getComponent().stopSong()
      tElem = tWndObj.getElement("sound_timeline_playhead")
      if tElem <> 0 then
        tsprite = tElem.getProperty(#sprite)
        if ilk(tsprite) = #sprite then
          removeEventBroker(tsprite.spriteNum)
        end if
      end if
      pPlayHeadDrag = 0
      tWndObj.center()
      tWndObj.moveBy(0, -30)
      me.getComponent().roomActivityUpdate(1)
      me.getComponent().editOpened()
    end if
  end if
  return 1
end

on showSaveSong me
  if not windowExists(pSaveSongWindowID) then
    if not me.getComponent().getCanSaveSong() then
      me.ShowAlert("song_not_ready")
      return 1
    end if
    if not createWindow(pSaveSongWindowID, "sound_machine_window.window", VOID, VOID, #modal) then
      return error(me, "Failed to open song save window!!!", #showPlaylist, #major)
    else
      tWndObj = getWindow(pSaveSongWindowID)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcSaveSong, me.getID(), #mouseUp)
      if not tWndObj.merge("sound_machine_save.window") then
        return tWndObj.close()
      end if
      tElemList = ["sound_machine_edit_text", "sound_machine_song_save_text", "sound_machine_save_cancel_text"]
      repeat with tElemName in tElemList
        tElem = tWndObj.getElement(tElemName)
        if tElem <> 0 then
          tsprite = tElem.getProperty(#sprite)
          if ilk(tsprite) = #sprite then
            removeEventBroker(tsprite.spriteNum)
          end if
        end if
      end repeat
      tElem = tWndObj.getElement("sound_machine_song_name")
      if tElem <> 0 then
        tSongName = me.getComponent().getEditorSongName()
        if tSongName <> EMPTY then
          tElem.setText(tSongName)
        else
          tElem.setText(getText("sound_machine_song_name"))
        end if
      end if
      tWndObj.center()
      tWndObj.moveBy(0, -30)
      me.updatePlaylists()
    end if
  end if
  return 1
end

on showJukebox me
  if not windowExists(pJukeboxWindowID) then
    if not createWindow(pJukeboxWindowID, "sound_machine_jukebox.window", VOID, VOID, #modal) then
      return error(me, "Failed to open jukebox window!!!", #showJukebox, #major)
    else
      me.renderJukebox()
      tWndObj = getWindow(pJukeboxWindowID)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcJukebox, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProcJukebox, me.getID(), #mouseEnter)
      tWndObj.registerProcedure(#eventProcJukebox, me.getID(), #mouseWithin)
      tWndObj.registerProcedure(#eventProcJukebox, me.getID(), #mouseLeave)
      if not timeoutExists(pJukeboxListUpdateTimer) then
        createTimeout(pJukeboxListUpdateTimer, 500, #renderJukeboxPlaylist, me.getID(), VOID, 0)
      end if
      me.getComponent().getUserDisks()
    end if
  end if
  return 1
end

on showSelectDisk me
  if not windowExists(pJukeboxDiskWindowID) then
    if not me.getComponent().getCanInsertDisk() then
      me.ShowAlert("no_disks")
      return 1
    end if
    if not createWindow(pJukeboxDiskWindowID, "sound_machine_jukebox_disklist.window", VOID, VOID, #modal) then
      return error(me, "Failed to open select disk window!!!", #showSelectDisk, #major)
    else
      me.renderUserDiskList(1)
      tWndObj = getWindow(pJukeboxDiskWindowID)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcJukeboxDisk, me.getID(), #mouseUp)
      tElemList = ["jukebox_disk_add_text", "jukebox_disk_cancel_text"]
      repeat with tElemName in tElemList
        tElem = tWndObj.getElement(tElemName)
        if tElem <> 0 then
          tsprite = tElem.getProperty(#sprite)
          if ilk(tsprite) = #sprite then
            removeEventBroker(tsprite.spriteNum)
          end if
        end if
      end repeat
    end if
  end if
  return 1
end

on hideSelectAction me
  if windowExists(pSoundMachineWindowID) then
    return removeWindow(pSoundMachineWindowID)
  else
    return 0
  end if
end

on hidePlaylist me
  if windowExists(pPlaylistWindowID) then
    return removeWindow(pPlaylistWindowID)
  else
    return 0
  end if
end

on hideSoundMachine me
  if windowExists(pSoundMachineWindowID) then
    me.getComponent().closeEdit()
    return removeWindow(pSoundMachineWindowID)
  else
    return 0
  end if
end

on hideSaveSong me
  if windowExists(pSaveSongWindowID) then
    return removeWindow(pSaveSongWindowID)
  else
    return 0
  end if
end

on hideJukebox me
  if timeoutExists(pJukeboxListUpdateTimer) then
    removeTimeout(pJukeboxListUpdateTimer)
  end if
  if windowExists(pJukeboxWindowID) then
    return removeWindow(pJukeboxWindowID)
  else
    return 0
  end if
end

on hideJukeboxDisk me
  if windowExists(pJukeboxDiskWindowID) then
    return removeWindow(pJukeboxDiskWindowID)
  else
    return 0
  end if
end

on confirmAction me, tAction, tParameter
  tResult = me.getComponent().confirmAction(tAction, tParameter)
  if tResult then
    if not windowExists(pSoundMachineConfirmWindowID) then
      if not createWindow(pSoundMachineConfirmWindowID, "habbo_full.window", VOID, VOID, #modal) then
        return error(me, "Failed to open Sound Machine confirm window!!!", #confirmAction, #major)
      else
        tWndObj = getWindow(pSoundMachineConfirmWindowID)
        tWndObj.registerClient(me.getID())
        tWndObj.registerProcedure(#eventProcConfirm, me.getID(), #mouseUp)
        if not tWndObj.merge("habbo_decision_dialog.window") then
          return tWndObj.close()
        end if
        tElem = tWndObj.getElement("habbo_decision_text_a")
        if tElem <> 0 then
          tText = getText("sound_machine_confirm_" & tAction)
          tElem.setText(tText)
        end if
        tElem = tWndObj.getElement("habbo_decision_text_b")
        if tElem <> 0 then
          tText = getText("sound_machine_confirm_" & tAction & "_long")
          tElem.setText(tText)
        end if
        tWndObj.center()
        tWndObj.moveBy(0, -30)
      end if
    end if
  end if
  return tResult
end

on hideConfirm me
  if windowExists(pSoundMachineConfirmWindowID) then
    return removeWindow(pSoundMachineConfirmWindowID)
  else
    return 0
  end if
end

on ShowAlert me, ttype, tExtra
  if voidp(tExtra) then
    tExtra = EMPTY
  end if
  tText = getText("sound_machine_alert_" & ttype)
  executeMessage(#alert, [#Msg: tText & tExtra, #modal: 1])
end

on showAlertWithCount me, ttype, tCount
  tText = getText("sound_machine_alert_" & ttype)
  tText = replaceChunks(tText, "%count%", tCount)
  executeMessage(#alert, [#Msg: tText, #modal: 1])
end

on renderSoundSets me
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return 0
  end if
  repeat with tIndex = me.getComponent().getSoundSetLimit() down to 1
    if pSoundSetSampleMemberList.count >= tIndex then
      tNameBase = pSoundSetSampleMemberList[tIndex]
    else
      tNameBase = pSoundSetSampleMemberList[1]
    end if
    tElem = tWndObj.getElement("sound_set_samples_" & tIndex)
    if tElem <> 0 then
      tImg = me.getComponent().renderSoundSet(tIndex, pSoundSetSlotWd, pSoundSetSlotHt, pSoundSetSlotMarginWd, pSoundSetSlotMarginHt, tNameBase, pSoundSetSampleMemberName)
      if tImg <> 0 then
        tElem.feedImage(tImg)
        next repeat
      end if
      tElem.feedImage(image(0, 0, 32))
    end if
  end repeat
  return 1
end

on renderSongList me
  tWndObj = getWindow(pPlaylistWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tPlaylistManager = me.getComponent().getPlaylistManager()
  if tPlaylistManager <> 0 then
    tElem = tWndObj.getElement("song_list")
    if tElem <> 0 then
      tImg = tPlaylistManager.renderSongList()
      if tImg <> 0 then
        tElem.feedImage(tImg)
      end if
    end if
    tElem = tWndObj.getElement("song_name_text")
    if tElem <> 0 then
      tElem.setText(tPlaylistManager.getSongName())
    end if
    tElem = tWndObj.getElement("song_length_text")
    if tElem <> 0 then
      tLength = tPlaylistManager.getSongLength()
      tLength = tLength * me.getComponent().getTimeLineSlotLength() / 1000
      tStr = me.getComponent().getTimeString(tLength)
      tElem.setText(string(tStr))
    end if
  end if
  tElem = tWndObj.getElement("song_date_text")
  if tElem <> 0 then
  end if
end

on renderPlaylist me
  tWndObj = getWindow(pPlaylistWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tPlaylistManager = me.getComponent().getPlaylistManager()
  if tPlaylistManager <> 0 then
    tElem = tWndObj.getElement("playlist")
    if tElem <> 0 then
      tImg = tPlaylistManager.renderPlaylist()
      if tImg <> 0 then
        tElem.feedImage(tImg)
      end if
    end if
    tElem = tWndObj.getElement("playlist_arrows")
    if tElem <> 0 then
      tImg = tPlaylistManager.renderPlaylistArrows()
      if tImg <> 0 then
        tElem.feedImage(tImg)
      end if
    end if
  end if
end

on renderJukebox me
  me.renderJukeboxDiskList()
  me.renderJukeboxPlaylist()
end

on renderJukeboxPlaylist me
  tWndObj = getWindow(pJukeboxWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tPlaylistManager = me.getComponent().getPlaylistManager()
  tJukeBoxManager = me.getComponent().getJukeBoxManager()
  if (tPlaylistManager <> 0) and (tJukeBoxManager <> 0) then
    tElem = tWndObj.getElement("now_playing_panel")
    if tElem <> 0 then
      tSongName = tPlaylistManager.getPlaylistSongName(1)
      tAuthor = EMPTY
      tImg = tJukeBoxManager.renderNowPlaying(tSongName, tAuthor)
      if tImg <> 0 then
        tElem.feedImage(tImg)
      end if
    end if
    tElem = tWndObj.getElement("next_up_panel")
    if tElem <> 0 then
      tSongList = []
      repeat with i = 2 to tPlaylistManager.getPlaylistCount()
        tSongName = tPlaylistManager.getPlaylistSongName(i)
        tSongList.add(tSongName)
      end repeat
      tImg = tJukeBoxManager.renderPlaylist(tSongList)
      if tImg <> 0 then
        tElem.feedImage(tImg)
      end if
    end if
  end if
  return 1
end

on renderJukeboxDiskList me
  tWndObj = getWindow(pJukeboxWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tJukeBoxManager = me.getComponent().getJukeBoxManager()
  if tJukeBoxManager <> 0 then
    tElem = tWndObj.getElement("disk_list")
    if tElem <> 0 then
      tImg = tJukeBoxManager.renderDiskList()
      if tImg <> 0 then
        tElem.feedImage(tImg)
      end if
    end if
  end if
  return 1
end

on renderUserDiskList me, tInitialRender
  tWndObj = getWindow(pJukeboxDiskWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("disk_list")
  if tElem <> 0 then
    tImg = me.getComponent().renderUserDiskList(tInitialRender)
    if tImg <> 0 then
      tElem.feedImage(tImg)
    end if
  end if
  return 1
end

on renderTimeLine me
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("sound_timeline")
  if tElem <> 0 then
    tImg = me.getComponent().renderTimeLine(pTimeLineSlotWd, pTimeLineSlotHt, pTimeLineSlotMarginWd, pTimeLineSlotMarginHt, pSoundSetSampleMemberList, pSoundSetSampleMemberName, "sound_system_ui_timeline_bg2")
    if tImg <> 0 then
      tElem.feedImage(tImg)
    else
      tElem.feedImage(image(0, 0, 32))
    end if
  end if
  tElem = tWndObj.getElement("sound_timeline_stamps")
  if tElem <> 0 then
    tBarHt = 15
    tImg = me.getComponent().renderTimeLineBar(pTimeLineSlotWd, tBarHt, pTimeLineSlotMarginWd, pSoundSetSampleMemberList, pSoundSetSampleMemberName, "sound_system_ui_timeline_bg2")
    if tImg <> 0 then
      tElem.feedImage(tImg)
    else
      tElem.feedImage(image(0, 0, 32))
    end if
  end if
  me.updatePlayHead(1)
  tElem = tWndObj.getElement("sound_left_button")
  if tElem <> 0 then
    tVisible = me.getComponent().getScrollPossible(-1)
    tElem.setProperty(#visible, tVisible)
  end if
  tElem = tWndObj.getElement("sound_right_button")
  if tElem <> 0 then
    tVisible = me.getComponent().getScrollPossible(1)
    tElem.setProperty(#visible, tVisible)
  end if
  return 1
end

on updateSoundSetTabs me
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tHooveredTab = me.getComponent().getSoundSetHooveredTab()
  repeat with tIndex = me.getComponent().getSoundSetLimit() down to 1
    tVisible = 1
    tid = me.getComponent().getSoundSetID(tIndex)
    if tid <> 0 then
      tElem = tWndObj.getElement("sound_set_tab_text_" & tIndex)
      if tElem <> 0 then
        tElem.setProperty(#visible, 1)
        if tIndex <> tHooveredTab then
          tText = me.getComponent().getSoundSetName(tid)
        else
          tText = getText("sound_machine_eject")
        end if
        tElem.setText(tText)
      end if
    else
      tVisible = 0
    end if
    tElemList = ["sound_set_tab_" & tIndex, "sound_set_tab_text_" & tIndex]
    repeat with tElemName in tElemList
      tElem = tWndObj.getElement(tElemName)
      if tElem <> 0 then
        tElem.setProperty(#visible, tVisible)
      end if
    end repeat
  end repeat
  return 1
end

on updateSoundSetSlots me
  me.updateSoundSetTabs()
  me.renderSoundSets()
  me.renderTimeLine()
end

on updateSoundSetList me
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tSetsReady = 1
  repeat with tIndex = me.getComponent().getSoundSetListPageSize() down to 1
    tid = me.getComponent().getSoundSetListID(tIndex)
    if tid <> 0 then
      tElem = tWndObj.getElement("set_list_text_" & tIndex)
      if tElem <> 0 then
        tText = me.getComponent().getSoundSetName(tid)
        tElem.setText(tText)
      end if
      tElem = tWndObj.getElement("set_list_icon_" & tIndex)
      if tElem <> 0 then
        if objectExists("Preview_renderer") then
          tSoundSetName = "sound_set_" & tid
          tdata = [#class: tSoundSetName, #type: #Active]
          executeMessage(#downloadObject, tdata)
          if tdata[#ready] = 0 then
            tSetsReady = 0
          end if
          tIcon = getObject("Preview_renderer").renderPreviewImage(VOID, VOID, VOID, tSoundSetName)
          tIcon = tIcon.trimWhiteSpace()
        else
          tIcon = image(0, 0, 32)
        end if
        tWd = tElem.getProperty(#width)
        tHt = tElem.getProperty(#height)
        tCenteredImage = image(tWd, tHt, 32)
        tMatte = tIcon.createMatte()
        tXchange = (tCenteredImage.width - tIcon.width) / 2
        tYchange = (tCenteredImage.height - tIcon.height) / 2
        tRect1 = tIcon.rect + rect(tXchange, tYchange, tXchange, tYchange)
        tCenteredImage.copyPixels(tIcon, tRect1, tIcon.rect, [#maskImage: tMatte, #ink: 41])
        tElem.feedImage(tCenteredImage)
      end if
    else
      tElem = tWndObj.getElement("set_list_text_" & tIndex)
      if tElem <> 0 then
        tElem.setText(EMPTY)
      end if
      tElem = tWndObj.getElement("set_list_icon_" & tIndex)
      if tElem <> 0 then
        tIcon = image(0, 0, 32)
        tElem.feedImage(tIcon)
      end if
    end if
    tElem = tWndObj.getElement("set_list_text2_" & tIndex)
    if tElem <> 0 then
      tElem.setText(EMPTY)
    end if
  end repeat
  tElem = tWndObj.getElement("set_list_index")
  if tElem <> 0 then
    tText = me.getComponent().getSoundListPage() & "/" & me.getComponent().getSoundListPageCount()
    tElem.setText(tText)
  end if
  if not tSetsReady then
    if not timeoutExists(pSoundSetIconUpdateTimer) then
      createTimeout(pSoundSetIconUpdateTimer, 500, #updateSoundSetList, me.getID(), VOID, 1)
    end if
  end if
  if me.getComponent().getSoundListPageCount() = 1 then
    tVisible = 0
  else
    tVisible = 1
  end if
  tElemList = ["set_list_left", "set_list_right"]
  repeat with tName in tElemList
    tElem = tWndObj.getElement(tName)
    if tElem <> 0 then
      tElem.setProperty(#visible, tVisible)
    end if
  end repeat
end

on updateSoundSetVisualizations me
  me.updateSoundSetList()
  me.updateSoundSetSlots()
end

on scrollTimeLine me, tDX
  if me.getComponent().scrollTimeLine(tDX) then
    me.renderTimeLine()
  end if
end

on scrollTimeLineTo me, tX
  if me.getComponent().scrollTimeLineTo(tX) then
    me.renderTimeLine()
  end if
end

on updatePlaylists me
  me.renderSongList()
  me.renderPlaylist()
end

on soundSetEvent me, tSetID, tPos, tEvent
  if tEvent <> #mouseLeave then
    if (tPos.locH < 0) or (tPos.locV < 0) then
      return 0
    end if
    tX = 1 + (tPos.locH / (pSoundSetSlotWd + pSoundSetSlotMarginWd))
    tY = 1 + (tPos.locV / (pSoundSetSlotHt + pSoundSetSlotMarginHt))
  else
    tX = 1
    tY = 1
  end if
  if me.getComponent().soundSetEvent(tSetID, tX, tY, tEvent) then
    me.renderSoundSets()
    return 1
  end if
  return 0
end

on soundSetTabEvent me, tSetID, tEvent
  if me.getComponent().soundSetTabEvent(tSetID, tEvent) then
    me.updateSoundSetVisualizations()
  end if
  return 1
end

on timeLineEvent me, tPos, tRect, tEvent
  if pPlayHeadDrag then
    return 1
  end if
  tX = 1 + (tPos.locH / (pTimeLineSlotWd + pTimeLineSlotMarginWd))
  tY = 1 + (tPos.locV / (pTimeLineSlotHt + pTimeLineSlotMarginHt))
  if (tEvent = #mouseLeave) or (tEvent = #mouseWithin) then
    if tEvent = #mouseLeave then
      tX = -1
      tY = -1
    end if
    if (tPos.locH < 0) or (tPos.locV < 0) or (tPos.locH > (tRect[3] - tRect[1])) or (tPos.locV > (tRect[4] - tRect[2])) then
      tX = -1
      tY = -1
      tEvent = #mouseLeave
    end if
  end if
  if me.getComponent().timeLineEvent(tX, tY, tEvent) then
    me.renderTimeLine()
  end if
  return 1
end

on updatePlayHead me, tManualUpdate
  if voidp(tManualUpdate) then
    tManualUpdate = 0
  end if
  tPlayTime = me.getComponent().getEditorPlayTime()
  tSlotLength = me.getComponent().getTimeLineSlotLength()
  tBehind = tPlayTime mod tSlotLength
  if tPlayTime then
    if not timeoutExists(pPlayHeadUpdateTimer) then
      createTimeout(pPlayHeadUpdateTimer, tSlotLength - tBehind, #updatePlayHead, me.getID(), VOID, 1)
    end if
  end if
  tPos = me.getComponent().getPlayHeadPosition()
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return 0
  end if
  if tPos > 0 then
    tPos = tPos - 1
    tElem = tWndObj.getElement("sound_timeline")
    if tElem <> 0 then
      tLocX = tElem.getProperty(#locX)
      tNameList = ["sound_timeline_playhead", "sound_timeline_playhead_drag"]
      repeat with tName in tNameList
        tElem = tWndObj.getElement(tName)
        if tElem <> 0 then
          tElem.setProperty(#visible, 1)
          tWd = tElem.getProperty(#width)
          tElem.setProperty(#locX, tLocX + ((pTimeLineSlotWd - tWd) / 2) + (pTimeLineSlotWd * tPos) + (pTimeLineSlotMarginWd * tPos))
        end if
      end repeat
    end if
    return 1
  else
    tWndObj = getWindow(pSoundMachineWindowID)
    if tWndObj = 0 then
      return 0
    end if
    tNameList = ["sound_timeline_playhead", "sound_timeline_playhead_drag"]
    repeat with tName in tNameList
      tElem = tWndObj.getElement(tName)
      if tElem <> 0 then
        tElem.setProperty(#visible, 0)
      end if
    end repeat
    if not tManualUpdate then
      me.scrollTimeLineTo(-tPos - 1)
    end if
  end if
  return 0
end

on initPlayHeadEventAgent me, tBoolean
  tAgent = getObject(pPlayHeadEventAgentID)
  if tBoolean then
    tAgent.registerEvent(me, #mouseUp, #playHeadMouseUp)
    tAgent.registerEvent(me, #mouseWithin, #playHeadMouseWithin)
  else
    tAgent.unregisterEvent(#mouseUp)
    tAgent.unregisterEvent(#mouseWithin)
  end if
  pPlayHeadDrag = tBoolean
end

on playHeadMouseUp me
  me.initPlayHeadEventAgent(0)
end

on playHeadMouseWithin me
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("sound_timeline")
  if tElem <> 0 then
    tRect = tElem.getProperty(#rect)
    tPos = point(the mouseH - tRect[1], the mouseV - tRect[2])
    tX = 1 + (tPos.locH / (pTimeLineSlotWd + pTimeLineSlotMarginWd))
    if tPos < 0 then
      tX = 0
    end if
    if me.getComponent().movePlayHead(tX) then
      me.renderTimeLine()
    end if
  end if
end

on soundMachineSelected me, tIsOn
  if windowExists(pSoundMachineWindowID) then
    tWndObj = getWindow(pSoundMachineWindowID)
    tElem = tWndObj.getElement("sound_machine_onoff")
    if tElem = 0 then
      return 0
    end if
  end if
  return me.showSelectAction(tIsOn)
end

on updatePlayButton me
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return 0
  end if
  if me.getComponent().getEditorPlayTime() = 0 then
    tElem = tWndObj.getElement("sound_play_button")
    if tElem <> 0 then
      tElem.setProperty(#visible, 1)
    end if
    tElem = tWndObj.getElement("sound_stop_button")
    if tElem <> 0 then
      tElem.setProperty(#visible, 0)
    end if
  else
    tElem = tWndObj.getElement("sound_play_button")
    if tElem <> 0 then
      tElem.setProperty(#visible, 0)
    end if
    tElem = tWndObj.getElement("sound_stop_button")
    if tElem <> 0 then
      tElem.setProperty(#visible, 1)
    end if
  end if
end

on getEditorWindowExists me
  if windowExists(pSoundMachineWindowID) then
    tWndObj = getWindow(pSoundMachineWindowID)
    tElem = tWndObj.getElement("sound_machine_onoff")
    if tElem = 0 then
      return 1
    end if
  end if
  return 0
end

on eventProcSoundMachine me, tEvent, tSprID, tParam, tWndID
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return 0
  end if
  if offset("sound_set_samples_", tSprID) = 1 then
    tSoundSetID = value(tSprID.char["sound_set_samples_".length + 1..tSprID.length])
    tElem = tWndObj.getElement(tSprID)
    tRect = tElem.getProperty(#rect)
    me.soundSetEvent(tSoundSetID, point(the mouseH - tRect[1], the mouseV - tRect[2]), tEvent)
    if not me.getComponent().getHooveredSampleReady() then
      tElem.setProperty(#cursor, 4)
    else
      tElem.setProperty(#cursor, "cursor.finger")
    end if
  else
    if offset("sound_set_tab_text_", tSprID) = 1 then
      tSoundSetID = value(tSprID.char["sound_set_tab_text_".length + 1..tSprID.length])
      me.soundSetTabEvent(tSoundSetID, tEvent)
    else
      if (tSprID = "sound_timeline") or (tSprID = "sound_timeline_bg") then
        tElem = tWndObj.getElement("sound_timeline")
        if tElem <> 0 then
          tRect = tElem.getProperty(#rect)
          me.timeLineEvent(point(the mouseH - tRect[1], the mouseV - tRect[2]), tRect, tEvent)
        end if
      end if
    end if
  end if
  if offset("set_list_icon_", tSprID) = 1 then
    if tEvent = #mouseEnter then
      tIndex = value(tSprID.char["set_list_icon_".length + 1..tSprID.length])
      tElem = tWndObj.getElement("set_list_text2_" & tIndex)
      if tElem <> 0 then
        tText = getText("sound_machine_insert")
        tElem.setText(tText)
      end if
    else
      if tEvent = #mouseLeave then
        me.updateSoundSetVisualizations()
      end if
    end if
  end if
  if tEvent = #mouseDown then
    if tSprID = "sound_timeline_playhead_drag" then
      me.initPlayHeadEventAgent(1)
    end if
  end if
  if tEvent = #mouseUp then
    if tSprID = "set_list_left" then
      if me.getComponent().changeSetListPage(-1) then
        me.updateSoundSetList()
      end if
    else
      if tSprID = "set_list_right" then
        if me.getComponent().changeSetListPage(1) then
          me.updateSoundSetList()
        end if
      else
        if offset("set_list_icon_", tSprID) = 1 then
          if me.getComponent().getFreeSoundSetCount() > 0 then
            tIndex = value(tSprID.char["set_list_icon_".length + 1..tSprID.length])
            if me.getComponent().loadSoundSet(tIndex) then
              me.updateSoundSetVisualizations()
            end if
          else
            me.ShowAlert("machine_full")
          end if
        else
          if tSprID = "sound_play_button" then
            me.getComponent().playSong()
            me.updatePlayHead()
          else
            if tSprID = "sound_stop_button" then
              me.getComponent().stopSong()
            else
              if tSprID = "sound_save_button" then
                me.showSaveSong()
              else
                if tSprID = "sound_trash_button" then
                  me.confirmAction("clear", EMPTY)
                else
                  if tSprID = "sound_left_button" then
                    me.scrollTimeLine(-pTimeLineScrollStep)
                  else
                    if tSprID = "sound_right_button" then
                      me.scrollTimeLine(pTimeLineScrollStep)
                    else
                      if tSprID = "close" then
                        me.confirmAction("close", EMPTY)
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return 1
end

on eventProcSelectAction me, tEvent, tSprID, tParam, tWndID
  if tEvent = #mouseUp then
    case tSprID of
      "close":
        me.hideSelectAction()
        me.getComponent().closeSelectAction()
      "sound_machine_edit":
        me.hideSelectAction()
        me.showPlaylist()
      "sound_machine_onoff":
        me.getComponent().changeFurniState()
        me.hideSelectAction()
    end case
  end if
  return 1
end

on eventProcPlaylist me, tEvent, tSprID, tParam, tWndID
  if tEvent = #mouseUp then
    case tSprID of
      "close":
        me.confirmAction("close_list")
      "song_list":
        tX = tParam.locH
        tY = tParam.locV
        tPlaylistManager = me.getComponent().getPlaylistManager()
        if tPlaylistManager <> 0 then
          if tPlaylistManager.songListMouseClick(tX, tY) then
            me.renderSongList()
          end if
        end if
      "playlist":
        tX = tParam.locH
        tY = tParam.locV
        tPlaylistManager = me.getComponent().getPlaylistManager()
        if tPlaylistManager <> 0 then
          if tPlaylistManager.playlistMouseClick(tX, tY) then
            me.renderPlaylist()
          end if
        end if
      "playlist_arrows":
        tX = tParam.locH
        tY = tParam.locV
        tPlaylistManager = me.getComponent().getPlaylistManager()
        if tPlaylistManager <> 0 then
          if tPlaylistManager.playlistArrowMouseClick(tX, tY) then
            me.renderPlaylist()
          end if
        end if
      "sound_machine_add_button":
        tPlaylistManager = me.getComponent().getPlaylistManager()
        if tPlaylistManager <> 0 then
          if tPlaylistManager.addPlaylistSong() then
            me.renderPlaylist()
          end if
        end if
      "sound_machine_edit_button":
        if me.getComponent().openEditorSong() then
          me.showSoundMachine()
        end if
      "sound_machine_new_button":
        if me.getComponent().newEditorSong() then
          me.showSoundMachine()
        end if
      "sound_machine_burn_button":
        me.confirmAction("burn", EMPTY)
      "sound_machine_delete_button":
        me.confirmAction("delete", EMPTY)
      "sound_machine_list_save_button":
        me.confirmAction("save_list", EMPTY)
    end case
  else
    if tEvent = #mouseWithin then
      case tSprID of
        "playlist":
          tX = tParam.locH
          tY = tParam.locV
          tPlaylistManager = me.getComponent().getPlaylistManager()
          if tPlaylistManager <> 0 then
            if tPlaylistManager.playlistMouseOver(tX, tY) then
              me.renderPlaylist()
            end if
          end if
      end case
    else
      if tEvent = #mouseLeave then
        case tSprID of
          "playlist":
            tPlaylistManager = me.getComponent().getPlaylistManager()
            if tPlaylistManager <> 0 then
              if tPlaylistManager.playlistMouseOver(1, -1000) then
                me.renderPlaylist()
              end if
            end if
        end case
      end if
    end if
  end if
  return 1
end

on eventProcJukebox me, tEvent, tSprID, tParam, tWndID
  if tEvent = #mouseUp then
    case tSprID of
      "close":
        me.hideJukebox()
      "disk_list":
        tJukeBoxManager = me.getComponent().getJukeBoxManager()
        if tJukeBoxManager <> 0 then
          tX = tParam.locH
          tY = tParam.locV
          if tJukeBoxManager.diskListMouseClick(tX, tY) then
            me.renderJukeboxDiskList()
          end if
        end if
    end case
  else
    if tEvent = #mouseWithin then
      if tSprID = "disk_list" then
        tJukeBoxManager = me.getComponent().getJukeBoxManager()
        if tJukeBoxManager <> 0 then
          tX = tParam.locH
          tY = tParam.locV
          if tJukeBoxManager.diskListMouseOver(tX, tY) then
            me.renderJukeboxDiskList()
          end if
        end if
      end if
    else
      if tEvent = #mouseLeave then
        if tSprID = "disk_list" then
          tJukeBoxManager = me.getComponent().getJukeBoxManager()
          if tJukeBoxManager <> 0 then
            if tJukeBoxManager.diskListMouseOver(-1, -1000) then
              me.renderJukeboxDiskList()
            end if
          end if
        end if
      end if
    end if
  end if
  return 1
end

on eventProcJukeboxDisk me, tEvent, tSprID, tParam, tWndID
  if tEvent = #mouseUp then
    case tSprID of
      "close", "jukebox_disk_cancel_button":
        me.hideJukeboxDisk()
      "disk_list":
        tX = tParam.locH
        tY = tParam.locV
        tPlaylistManager = me.getComponent().getPlaylistManager()
        if tPlaylistManager <> 0 then
          if tPlaylistManager.diskListMouseClick(tX, tY) then
            me.renderUserDiskList(0)
          end if
        end if
      "jukebox_disk_add_button":
        me.getComponent().insertJukeboxDisk()
        me.hideJukeboxDisk()
    end case
  end if
  return 1
end

on eventProcSaveSong me, tEvent, tSprID, tParam, tWndID
  tWndObj = getWindow(pSaveSongWindowID)
  if tWndObj = 0 then
    return 0
  end if
  if tEvent = #mouseUp then
    case tSprID of
      "close":
        me.hideSaveSong()
      "sound_machine_song_save_button":
        tElem = tWndObj.getElement("sound_machine_song_name")
        if tElem <> 0 then
          tSongName = tElem.getText()
          if tSongName = EMPTY then
            me.ShowAlert("song_name_missing")
            return 0
          end if
        end if
        me.confirmAction("save", tSongName)
      "sound_machine_song_cancel_button":
        me.hideSaveSong()
    end case
  end if
  return 1
end

on eventProcConfirm me, tEvent, tSprID, tParam, tWndID
  if tEvent = #mouseUp then
    case tSprID of
      "close", "habbo_decision_cancel":
        me.hideConfirm()
      "habbo_decision_ok":
        me.getComponent().actionConfirmed()
        me.hideConfirm()
    end case
  end if
  return 1
end
