property pSoundMachineInstanceList, pTimelineInstance, pJukeboxManager, pSongControllerID, pSelectedSoundSet, pSelectedSoundSetSample, pHooveredSoundSet, pHooveredSoundSetSample, pHooveredSampleReady, pHooveredSoundSetTab, pSampleHorCount, pSampleVerCount, pSoundSetListPage, pSoundSetLimit, pSoundSetList, pSoundSetListPageSize, pSoundSetInventoryList, pTimeLineViewSlotCount, pTimeLineCursorX, pTimeLineCursorY, pTimeLineScrollX, pPlayHeadPosX, pDiskList, pSoundSetInsertLocked, pEditorOpen, pEditFailure, pEditorSongStartTime, pEditorSongPlaying, pEditorSongLength, pEditorSongID, pTimeLineUpdateTimer, pRoomActivityUpdateTimer, pSoundMachineFurniID, pConfirmedAction, pConfirmedActionParameter, pWriterID, pConnectionId

on construct me
  pSoundMachineInstanceList = [:]
  pTimelineInstance = createObject("timeline instance", getClassVariable("soundmachine.song.timeline"))
  unregisterObject("timeline instance")
  pJukeboxManager = createObject("jukebox manager", getClassVariable("soundmachine.jukebox.manager"))
  unregisterObject("jukebox manager")
  pWriterID = getUniqueID()
  tBold = getStructVariable("struct.font.plain")
  tMetrics = [#font: tBold.getaProp(#font), #fontStyle: tBold.getaProp(#fontStyle), #color: rgb("#B6DCDF")]
  createWriter(pWriterID, tMetrics)
  pTimeLineUpdateTimer = "sound_machine_timeline_timer"
  pRoomActivityUpdateTimer = "sound_machine_room_activity_timer"
  pDiskList = []
  pConnectionId = getVariableValue("connection.info.id", #Info)
  pSampleHorCount = 3
  pSampleVerCount = 3
  pSoundSetLimit = 4
  pSoundSetListPageSize = 3
  pTimeLineViewSlotCount = 24
  pSongControllerID = "song controller"
  createObject(pSongControllerID, "Song Controller Class")
  me.reset(1)
  registerMessage(#sound_machine_selected, me.getID(), #soundMachineSelected)
  registerMessage(#jukebox_selected, me.getID(), #jukeBoxSelected)
  registerMessage(#sound_machine_set_state, me.getID(), #soundMachineSetState)
  registerMessage(#sound_machine_removed, me.getID(), #soundMachineRemoved)
  registerMessage(#sound_machine_created, me.getID(), #soundMachineCreated)
  registerMessage(#sound_machine_defined, me.getID(), #soundMachineDefined)
  registerMessage(#jukebox_defined, me.getID(), #jukeBoxDefined)
  registerMessage(#insert_song, me.getID(), #insertPlaylistSong)
  return 1
end

on deconstruct me
  if writerExists(pWriterID) then
    removeWriter(pWriterID)
  end if
  if timeoutExists(pTimeLineUpdateTimer) then
    removeTimeout(pTimeLineUpdateTimer)
  end if
  if timeoutExists(pRoomActivityUpdateTimer) then
    removeTimeout(pRoomActivityUpdateTimer)
  end if
  pTimelineInstance.deconstruct()
  pJukeboxManager.deconstruct()
  unregisterMessage(#sound_machine_selected, me.getID())
  unregisterMessage(#jukebox_selected, me.getID())
  unregisterMessage(#sound_machine_set_state, me.getID())
  unregisterMessage(#sound_machine_removed, me.getID())
  unregisterMessage(#sound_machine_created, me.getID())
  unregisterMessage(#sound_machine_defined, me.getID())
  unregisterMessage(#jukebox_defined, me.getID())
  unregisterMessage(#insert_song, me.getID())
  return 1
end

on reset me, tInitialReset
  pEditFailure = 0
  me.closeEdit(tInitialReset)
end

on editOpened me
  pEditorOpen = 1
end

on closeEdit me, tInitialReset
  pEditorSongID = 0
  pEditorOpen = 0
  pHooveredSampleReady = 1
  pSelectedSoundSet = 0
  pSelectedSoundSetSample = 0
  pHooveredSoundSet = 0
  pHooveredSoundSetSample = 0
  pHooveredSoundSetTab = 0
  pSoundSetListPage = 1
  pTimeLineCursorX = 0
  pTimeLineCursorY = 0
  pTimeLineScrollX = 0
  pPlayHeadPosX = 0
  pConfirmedAction = EMPTY
  pConfirmedActionParameter = EMPTY
  pSoundSetInsertLocked = 0
  pEditorSongLength = 0
  me.clearTimeLine()
  me.stopSong()
  me.clearSoundSets()
  pSoundSetInventoryList = []
  me.playSong()
  if not tInitialReset and not pEditFailure then
    if getConnection(pConnectionId) <> 0 then
      return getConnection(pConnectionId).send("SONG_EDIT_CLOSE")
    end if
  end if
  return 1
end

on closeSelectAction me
  pSoundMachineFurniID = 0
end

on confirmAction me, tAction, tParameter
  pConfirmedAction = tAction
  pConfirmedActionParameter = tParameter
  case tAction of
    "eject":
      tReferences = me.checkSoundSetReferences(tParameter)
      if tReferences then
        return 1
      end if
    "close":
      if pTimelineInstance.getChanged() then
        return 1
      end if
    "clear":
      return 1
    "save":
      if tParameter = pTimelineInstance.getSongName() then
        return 1
      end if
    "delete":
      return 1
    "burn":
      return 1
    "save_list":
      return 1
    "close_list":
      tPlaylistManager = me.getPlaylistManager(pSoundMachineFurniID)
      if tPlaylistManager = 0 then
        return 0
      end if
      if tPlaylistManager.getPlaylistChanged() then
        return 1
      end if
  end case
  me.actionConfirmed()
  return 0
end

on actionConfirmed me
  tRetVal = 0
  case pConfirmedAction of
    "eject":
      tRetVal = me.removeSoundSet(pConfirmedActionParameter)
      if tRetVal then
        me.getInterface().renderTimeLine()
      end if
    "close":
      if me.getInterface().hideSoundMachine() then
        me.getInterface().showPlaylist()
      end if
    "clear":
      me.clearTimeLine()
      me.stopSong()
      me.getInterface().renderTimeLine()
    "save":
      me.saveEditorSong(pConfirmedActionParameter)
      me.getInterface().hideSaveSong()
    "delete":
      tPlaylistManager = me.getPlaylistManager(pSoundMachineFurniID)
      if tPlaylistManager = 0 then
        tRetVal = 0
      else
        if tPlaylistManager.deleteSong() then
          me.getInterface().renderSongList()
        end if
      end if
    "burn":
      tPlaylistManager = me.getPlaylistManager(pSoundMachineFurniID)
      if tPlaylistManager = 0 then
        tRetVal = 0
      else
        tPlaylistManager.burnSong()
      end if
    "save_list":
      tPlaylistManager = me.getPlaylistManager(pSoundMachineFurniID)
      if tPlaylistManager = 0 then
        tRetVal = 0
      else
        tPlaylistManager.savePlaylist()
      end if
    "close_list":
      me.getInterface().hidePlaylist()
      me.closeSelectAction()
  end case
  pConfirmedAction = EMPTY
  pConfirmedActionParameter = EMPTY
  return tRetVal
end

on getSoundSetLimit me
  return pSoundSetLimit
end

on getSoundSetListPageSize me
  return pSoundSetListPageSize
end

on getSoundSetID me, tIndex
  if (tIndex < 1) or (tIndex > pSoundSetList.count) then
    return 0
  end if
  if voidp(pSoundSetList[tIndex]) then
    return 0
  end if
  return pSoundSetList[tIndex][#id]
end

on getSoundSetListID me, tIndex
  tIndex = tIndex + ((pSoundSetListPage - 1) * pSoundSetListPageSize)
  if (tIndex < 1) or (tIndex > pSoundSetInventoryList.count) then
    return 0
  end if
  return pSoundSetInventoryList[tIndex][#id]
end

on getSoundSetHooveredTab me
  return pHooveredSoundSetTab
end

on getSoundListPage me
  return pSoundSetListPage
end

on getSoundListPageCount me
  return 1 + ((pSoundSetInventoryList.count() - 1) / pSoundSetListPageSize)
end

on getHooveredSampleReady me
  return pHooveredSampleReady
end

on getTimeLineSlotLength me
  return pTimelineInstance.getSlotDuration()
end

on getTimeLineViewSlotCount me
  return pTimeLineViewSlotCount
end

on getTimeString me, tSeconds
  if tSeconds < 60 then
    tStr = getText("sound_machine_time_1")
  else
    tStr = getText("sound_machine_time_2")
  end if
  tMinStr = string(tSeconds / 60)
  if (tSeconds mod 60) <> 0 then
    tSecStr = string(tSeconds mod 60)
    if tSecStr.length = 1 then
      tSecStr = "0" & tSecStr
    end if
  else
    tSecStr = "00"
  end if
  tStr = replaceChunks(tStr, "%min%", tMinStr)
  tStr = replaceChunks(tStr, "%sec%", tSecStr)
  return tStr
end

on getSoundSetName me, tid
  return getText("furni_sound_set_" & tid & "_name")
end

on getEditorSongName me
  return pTimelineInstance.getSongName()
end

on getCanSaveSong me
  if pTimelineInstance.encodeTimeLineData() <> 0 then
    return 1
  end if
  return 0
end

on getCanInsertDisk me
  if pDiskList.count > 0 then
    return 1
  end if
  return 0
end

on getEditorPlayTime me
  if not pEditorSongPlaying then
    return 0
  end if
  tTime = (the milliSeconds + 30 - pEditorSongStartTime) mod (me.getTimeLineSlotLength() * pEditorSongLength)
  if tTime = 0 then
    tTime = 1
  end if
  return tTime
end

on getPlayHeadPosition me
  tPlayTime = me.getEditorPlayTime()
  tSlotLength = me.getTimeLineSlotLength()
  if pEditorSongPlaying then
    tPos = ((tPlayTime / tSlotLength) + pPlayHeadPosX) mod pEditorSongLength
  else
    tPos = ((tPlayTime / tSlotLength) + pPlayHeadPosX) mod pTimelineInstance.getSlotCount()
  end if
  tPos = 1 + tPos - pTimeLineScrollX
  if (tPos < 1) or (tPos > pTimeLineViewSlotCount) then
    return -(tPos + pTimeLineScrollX)
  end if
  return tPos
end

on movePlayHead me, tPos
  if pEditorSongPlaying then
    return 0
  end if
  tPos = tPos - 1
  if tPos <> (pPlayHeadPosX - pTimeLineScrollX) then
    if (tPos >= 0) and (tPos < pTimeLineViewSlotCount) then
      pPlayHeadPosX = tPos + pTimeLineScrollX
      return 1
    else
      if tPos < 0 then
        me.scrollTimeLine(-1)
        if pPlayHeadPosX <> pTimeLineScrollX then
          pPlayHeadPosX = pTimeLineScrollX
          return 1
        end if
      else
        me.scrollTimeLine(1)
        if pPlayHeadPosX <> (pTimeLineScrollX + pTimeLineViewSlotCount - 1) then
          pPlayHeadPosX = pTimeLineScrollX + pTimeLineViewSlotCount - 1
          return 1
        end if
      end if
    end if
  end if
  return 0
end

on scrollTimeLine me, tDX
  tScrollX = max(0, min(pTimeLineScrollX + tDX, pTimelineInstance.getSlotCount() - pTimeLineViewSlotCount))
  if tScrollX <> pTimeLineScrollX then
    pTimeLineScrollX = tScrollX
    return 1
  end if
  return 0
end

on scrollTimeLineTo me, tX
  tScrollX = max(0, min(tX, pTimelineInstance.getSlotCount() - pTimeLineViewSlotCount))
  if tScrollX <> pTimeLineScrollX then
    pTimeLineScrollX = tScrollX
    return 1
  end if
  return 0
end

on getScrollPossible me, tDX
  if tDX < 0 then
    if pTimeLineScrollX > 0 then
      return 1
    end if
  end if
  if tDX > 0 then
    if pTimeLineScrollX < (pTimelineInstance.getSlotCount() - pTimeLineViewSlotCount) then
      return 1
    end if
  end if
  return 0
end

on soundMachineSelected me, tdata
  tFurniID = tdata[#id]
  tFurniOn = tdata[#furniOn]
  tResult = me.getInterface().soundMachineSelected(tFurniOn)
  if tResult then
    pSoundMachineFurniID = tFurniID
  end if
end

on jukeBoxSelected me, tdata
  tFurniID = tdata[#id]
  tOwner = tdata[#owner]
  tJukeBoxManager = me.getJukeBoxManager(tFurniID)
  if tJukeBoxManager <> 0 then
    tJukeBoxManager.setOwner(tOwner)
  end if
  tResult = me.getInterface().showJukebox()
  if tResult then
    pSoundMachineFurniID = tFurniID
  end if
end

on soundMachineSetState me, tdata
  tFurniID = tdata[#id]
  tFurniOn = tdata[#furniOn]
  if pEditorOpen then
    me.soundMachineSelected([#id: tFurniID, #furniOn: tFurniOn])
  else
    tSoundMachine = me.getSoundMachine(tFurniID)
    if tSoundMachine = 0 then
      return error(me, "Instance not found", #soundMachineSetState, #major)
    end if
    tSoundMachine.setState(tFurniOn)
  end if
  return 1
end

on soundMachineRemoved me, tFurniID
  tSoundMachine = pSoundMachineInstanceList.getaProp(tFurniID)
  if not voidp(tSoundMachine) then
    me.stopSong()
    removeObject("sound machine" && tFurniID)
    pSoundMachineInstanceList.deleteProp(tFurniID)
    pSoundMachineFurniID = 0
    me.getInterface().hideSoundMachine()
    me.getInterface().hidePlaylist()
  end if
end

on soundMachineCreated me, tFurniID, tLooping
  if pSoundMachineInstanceList.count > 0 then
    return 0
  end if
  tSoundMachine = me.getSoundMachine(tFurniID)
  if tSoundMachine = 0 then
    tSoundMachine = createObject("sound machine" && tFurniID, getClassVariable("soundmachine.instance"))
    if tSoundMachine = 0 then
      return 0
    end if
    tSoundMachine.setLooping(tLooping)
    pSoundMachineInstanceList.addProp(tFurniID, tSoundMachine)
  end if
  return 1
end

on soundMachineDefined me, tFurniID
  tSoundMachine = me.getSoundMachine(tFurniID)
  if tSoundMachine = 0 then
    return error(me, "Instance not found", #soundMachineDefined, #major)
  end if
  if not tSoundMachine.Initialize() then
    return 0
  end if
  tPlaylistManager = tSoundMachine.getPlaylistManager()
  if tPlaylistManager = 0 then
    return 0
  end if
  return tPlaylistManager.getPlaylistData()
end

on jukeBoxDefined me, tFurniID
  tSoundMachine = me.getSoundMachine(tFurniID)
  if tSoundMachine = 0 then
    return error(me, "Instance not found", #soundMachineDefined, #major)
  end if
  if not tSoundMachine.Initialize() then
    return 0
  end if
  tPlaylistManager = tSoundMachine.getPlaylistManager()
  tJukeBoxManager = me.getJukeBoxManager()
  if (tPlaylistManager = 0) or (tJukeBoxManager = 0) then
    return 0
  end if
  tPlaylistManager.getPlaylistData()
  tJukeBoxManager.getJukeboxDisks()
end

on changeFurniState me
  tSoundMachine = me.getSoundMachine(pSoundMachineFurniID)
  if tSoundMachine = 0 then
    return 0
  end if
  tNewState = not tSoundMachine.getState()
  tObj = getThread(#room).getComponent().getActiveObject(pSoundMachineFurniID)
  if tObj <> 0 then
    call(#changeState, [tObj], tNewState)
  end if
  pSoundMachineFurniID = 0
end

on getSoundMachine me, tFurniID
  if pSoundMachineInstanceList.count = 0 then
    return 0
  end if
  return pSoundMachineInstanceList[1]
end

on getPlaylistManager me, tFurniID
  tSoundMachine = me.getSoundMachine(tFurniID)
  if tSoundMachine = 0 then
    return 0
  end if
  return tSoundMachine.getPlaylistManager()
end

on getJukeBoxManager me, tFurniID
  return pJukeboxManager
end

on soundSetEvent me, tSetID, tX, tY, tEvent
  if (tX >= 1) and (tX <= pSampleHorCount) and (tY >= 1) and (tY <= pSampleVerCount) and (tSetID >= 1) and (tSetID <= pSoundSetLimit) then
    if tEvent = #mouseDown then
      tSampleIndex = tX + ((tY - 1) * pSampleHorCount)
      if not me.getSampleReady(tSampleIndex, tSetID) then
        return 0
      end if
      if (pSelectedSoundSet = tSetID) and (pSelectedSoundSetSample = tSampleIndex) then
        pSelectedSoundSet = 0
        pSelectedSoundSetSample = 0
      else
        pSelectedSoundSet = tSetID
        pSelectedSoundSetSample = tSampleIndex
      end if
    else
      if tEvent = #mouseWithin then
        tSample = tX + ((tY - 1) * pSampleHorCount)
        if (pHooveredSoundSet = tSetID) and (pHooveredSoundSetSample = tSample) then
          return 0
        end if
        pHooveredSoundSet = tSetID
        pHooveredSoundSetSample = tX + ((tY - 1) * pSampleHorCount)
        pHooveredSampleReady = me.getSampleReady(pHooveredSoundSetSample, pHooveredSoundSet)
        if pHooveredSampleReady then
          me.playSample(pHooveredSoundSetSample, pHooveredSoundSet)
        end if
      else
        if tEvent = #mouseLeave then
          pHooveredSoundSet = 0
          pHooveredSoundSetSample = 0
          pHooveredSampleReady = 1
          me.stopSample()
        end if
      end if
    end if
    return 1
  end if
  return 0
end

on soundSetTabEvent me, tSetID, tEvent
  if (tSetID >= 1) and (tSetID <= pSoundSetLimit) then
    if tEvent = #mouseDown then
      tConfirm = me.getInterface().confirmAction("eject", tSetID)
      return not tConfirm
    else
      if tEvent = #mouseWithin then
        if tSetID = pHooveredSoundSetTab then
          return 0
        end if
        pHooveredSoundSetTab = tSetID
      else
        if tEvent = #mouseLeave then
          pHooveredSoundSetTab = 0
        end if
      end if
    end if
    return 1
  end if
  return 0
end

on timeLineEvent me, tX, tY, tEvent
  tX = tX + pTimeLineScrollX
  if tEvent = #mouseDown then
    tInsert = me.insertSample(tX, tY)
    if tInsert then
      pTimeLineCursorX = 0
      pTimeLineCursorY = 0
      return 1
    else
      return me.removeSample(tX, tY)
    end if
  else
    if tEvent = #mouseWithin then
      if (tX <> pTimeLineCursorX) or (tY <> pTimeLineCursorY) then
        tid = 0
        tSample = me.getSample(pSelectedSoundSetSample, pSelectedSoundSet)
        if tSample <> 0 then
          tid = tSample[#id]
        end if
        tInsert = me.getCanInsertSample(tX, tY, tid)
        if tInsert and ((pTimeLineCursorX <> tX) or (pTimeLineCursorY <> tY)) then
          pTimeLineCursorX = tX
          pTimeLineCursorY = tY
          return 1
        else
          if (pTimeLineCursorX <> 0) and (pTimeLineCursorY <> 0) then
            pTimeLineCursorX = 0
            pTimeLineCursorY = 0
            return 1
          end if
        end if
      end if
    else
      if tEvent = #mouseLeave then
        if (tX < 1) or (tX > pTimelineInstance.getSlotCount()) or (tY < 1) or (tY > pTimelineInstance.getChannelCount()) then
          pTimeLineCursorX = 0
          pTimeLineCursorY = 0
          return 1
        end if
      end if
    end if
  end if
  return 0
end

on renderUserDiskList me, tInitialRender
  tPlaylistManager = me.getPlaylistManager()
  if tPlaylistManager <> 0 then
    if tInitialRender then
      tPlaylistManager.setDiskList(pDiskList.duplicate())
    end if
    return tPlaylistManager.renderDiskList()
  end if
  return 0
end

on renderSoundSet me, tIndex, tWd, tHt, tMarginWd, tMarginHt, tNameBase, tSampleNameBase
  if (tIndex < 0) or (tIndex > pSoundSetList.count) then
    return 0
  end if
  if voidp(pSoundSetList[tIndex]) then
    return 0
  end if
  tImg = image((pSampleHorCount * tWd) + (tMarginWd * (pSampleHorCount - 1)), (pSampleVerCount * tHt) + (tMarginHt * (pSampleVerCount - 1)), 32)
  tSampleList = pSoundSetList[tIndex][#samples]
  if voidp(tSampleList) then
    return 0
  end if
  repeat with tSample = 1 to tSampleList.count
    tX = 1 + ((tSample - 1) mod pSampleHorCount)
    tY = 1 + ((tSample - 1) / pSampleVerCount)
    if tY > pSampleVerCount then
      exit repeat
    end if
    ttype = 1
    if (tIndex = pSelectedSoundSet) and (tSample = pSelectedSoundSetSample) then
      ttype = 3
    else
      if (tIndex = pHooveredSoundSet) and (tSample = pHooveredSoundSetSample) then
        ttype = 2
      end if
    end if
    tName = [tNameBase & ttype, tSampleNameBase & tSample]
    repeat with tPart = 1 to tName.count
      tmember = getMember(tName[tPart])
      if tmember <> 0 then
        tSourceImg = tmember.image
        tRect = tSourceImg.rect
        tImgWd = tRect[3] - tRect[1]
        tImgHt = tRect[4] - tRect[2]
        tRect[1] = tRect[1] + ((tX - 1) * (tWd + tMarginWd)) + ((tWd - tImgWd) / 2)
        tRect[2] = tRect[2] + ((tY - 1) * (tHt + tMarginHt)) + ((tHt - tImgHt) / 2)
        tRect[3] = tRect[3] + ((tX - 1) * (tWd + tMarginWd)) + ((tWd - tImgWd) / 2)
        tRect[4] = tRect[4] + ((tY - 1) * (tHt + tMarginHt)) + ((tHt - tImgHt) / 2)
        tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, [#ink: 8, #maskImage: tSourceImg.createMatte()])
      end if
    end repeat
  end repeat
  return tImg
end

on renderTimeLine me, tWd, tHt, tMarginWd, tMarginHt, tNameBaseList, tSampleNameBase, tBgImage
  tImg = image((pTimeLineViewSlotCount * tWd) + (tMarginWd * (pTimeLineViewSlotCount - 1)), (pTimelineInstance.getChannelCount() * (tHt + tMarginHt)) - tMarginHt, 32)
  tmember = getMember(tBgImage)
  if tmember <> 0 then
    tImg.copyPixels(tmember.image, tImg.rect, tmember.image.rect)
  end if
  tTimeLineData = pTimelineInstance.getTimeLineData()
  repeat with tChannel = 1 to tTimeLineData.count
    tChannelData = tTimeLineData[tChannel]
    repeat with tSlot = max(1, pTimeLineScrollX - 10) to min(pTimeLineScrollX + pTimeLineViewSlotCount, tChannelData.count)
      if not voidp(tChannelData[tSlot]) then
        tSampleNumber = tChannelData[tSlot]
        if not me.renderSample(tSampleNumber, tSlot - pTimeLineScrollX, tChannel, tWd, tHt, tMarginWd, tMarginHt, tNameBaseList, tSampleNameBase, tImg) then
        end if
      end if
    end repeat
  end repeat
  if (pTimeLineCursorX <> 0) and (pTimeLineCursorY <> 0) then
    tSample = me.getSample(pSelectedSoundSetSample, pSelectedSoundSet)
    if tSample <> 0 then
      tCursorX = pTimeLineCursorX - pTimeLineScrollX
      tCursorY = pTimeLineCursorY
      if not me.renderSample(tSample[#id], tCursorX, tCursorY, tWd, tHt, tMarginWd, tMarginHt, tNameBaseList, tSampleNameBase, tImg, 50) then
      end if
    end if
  end if
  return tImg
end

on renderSample me, tSampleNumber, tSlot, tChannel, tWd, tHt, tMarginWd, tMarginHt, tNameBaseList, tSampleNameBase, tImg, tBlend
  tLength = pTimelineInstance.getSampleLength(tSampleNumber)
  if tSampleNumber < 0 then
    tBlend = 20
    tSampleNumber = -tSampleNumber
  end if
  tSampleSet = me.getSampleSetNumber(tSampleNumber)
  tSampleIndex = me.getSampleIndex(tSampleNumber)
  tSample = me.getSample(tSampleIndex, tSampleSet)
  if tSample = 0 then
    return 0
  end if
  if voidp(tBlend) then
    tBlend = 100
  end if
  if (tSampleSet < 1) or (tSampleSet > tNameBaseList.count) then
    return 0
  end if
  tNameBase = tNameBaseList[tSampleSet]
  tName = [tNameBase & "1", tSampleNameBase & tSampleIndex]
  tstart = max(1, tSlot)
  tEnd = min(pTimeLineViewSlotCount, tSlot + tLength - 1)
  repeat with tPart = 1 to tName.count
    tmember = getMember(tName[tPart])
    if tmember <> 0 then
      tSourceImg = tmember.image
      tRectOrig = tSourceImg.rect
      tImgWd = tRectOrig[3] - tRectOrig[1]
      tImgHt = tRectOrig[4] - tRectOrig[2]
      tRectOrig[2] = tRectOrig[2] + ((tChannel - 1) * (tHt + tMarginHt)) + ((tHt - tImgHt) / 2)
      tRectOrig[4] = tRectOrig[4] + ((tChannel - 1) * (tHt + tMarginHt)) + ((tHt - tImgHt) / 2)
      tProps = [#ink: 8, #maskImage: tSourceImg.createMatte(), #blend: tBlend]
      repeat with tPos = tstart to tEnd
        tRect = tRectOrig.duplicate()
        tRect[1] = tRect[1] + ((tPos - 1) * (tWd + tMarginWd)) + ((tWd - tImgWd) / 2)
        tRect[3] = tRect[3] + ((tPos - 1) * (tWd + tMarginWd)) + ((tWd - tImgWd) / 2)
        tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, tProps)
      end repeat
      next repeat
    end if
    return 0
  end repeat
  tName = tNameBase & "sp"
  tmember = getMember(tName)
  if tmember <> 0 then
    tSourceImg = tmember.image
    tRectOrig = tSourceImg.rect
    tImgWd = tRectOrig[3] - tRectOrig[1]
    tImgHt = tRectOrig[4] - tRectOrig[2]
    tRectOrig[2] = tRectOrig[2] + ((tChannel - 1) * (tHt + tMarginHt)) + ((tHt - tImgHt) / 2)
    tRectOrig[4] = tRectOrig[4] + ((tChannel - 1) * (tHt + tMarginHt)) + ((tHt - tImgHt) / 2)
    tProps = [#ink: 8, #maskImage: tSourceImg.createMatte(), #blend: tBlend]
    repeat with tPos = max(0, tSlot) to min(pTimeLineViewSlotCount, tSlot + tLength - 2)
      tRect = tRectOrig.duplicate()
      tRect[1] = tRect[1] + (tPos * (tWd + tMarginWd)) - (tImgWd / 2)
      tRect[3] = tRect[3] + (tPos * (tWd + tMarginWd)) - (tImgWd / 2)
      tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, tProps)
    end repeat
  else
    return 0
  end if
  return 1
end

on renderTimeLineBar me, tWd, tHt, tMarginWd, tNameBaseList, tSampleNameBase, tBgImage
  tImg = image((pTimeLineViewSlotCount * tWd) + (tMarginWd * (pTimeLineViewSlotCount - 1)), tHt, 32)
  tImgHt = tImg.rect[4] - tImg.rect[2]
  tWriterObj = getWriter(pWriterID)
  if tWriterObj = 0 then
    return tImg
  end if
  tstart = max(0, pTimeLineScrollX + 1)
  tEnd = min(pTimeLineScrollX + pTimeLineViewSlotCount - 1, pTimelineInstance.getSlotCount())
  tTimeLineSlotLength = me.getTimeLineSlotLength()
  repeat with tSlot = tstart to tEnd
    if (tSlot * tTimeLineSlotLength mod 10000) = 0 then
      tOffset = rect((tWd + tMarginWd) * (tSlot - pTimeLineScrollX), 0, (tWd + tMarginWd) * (tSlot - pTimeLineScrollX), 0)
      tSeconds = tSlot * tTimeLineSlotLength / 1000
      tStr = me.getTimeString(tSeconds)
      tStampImg = tWriterObj.render(tStr).duplicate()
      tStampImgTrimmed = image(tStampImg.rect[3], tStampImg.rect[4], 32)
      tStampImgTrimmed.copyPixels(tStampImg, tStampImg.rect, tStampImg.rect, [#ink: 8, #maskImage: tStampImg.createMatte()])
      tStampImg = tStampImgTrimmed.trimWhiteSpace()
      tOffset[1] = tOffset[1] - ((tStampImg.rect[3] - tStampImg.rect[1]) / 2)
      tOffset[3] = tOffset[1]
      tOffset[2] = (tImgHt - (tStampImg.rect[4] - tStampImg.rect[2])) / 2
      tOffset[4] = tOffset[2]
      tImg.copyPixels(tStampImg, tStampImg.rect + tOffset, tStampImg.rect, [#ink: 8, #maskImage: tStampImg.createMatte()])
    end if
  end repeat
  return tImg
end

on parseSongList me, tMsg
  tid = 1
  tPlaylistManager = me.getPlaylistManager(tid)
  if tPlaylistManager = 0 then
    return 0
  end if
  tRetVal = tPlaylistManager.parseSongList(tMsg)
  me.getInterface().updatePlaylists()
  return tRetVal
end

on parsePlaylist me, tMsg
  me.stopSong()
  tid = 1
  tSoundMachine = me.getSoundMachine(tid)
  if tSoundMachine = 0 then
    return 0
  end if
  tRetVal = tSoundMachine.parsePlaylist(tMsg)
  me.getInterface().updatePlaylists()
  return tRetVal
end

on getUserDisks me
  pDiskList = []
  if getConnection(pConnectionId) <> 0 then
    return getConnection(pConnectionId).send("GET_USER_SONG_DISCS")
  end if
  return 0
end

on parseUserDisks me, tMsg
  pDiskList = []
  tCount = tMsg.connection.GetIntFrom()
  repeat with i = 1 to tCount
    tid = tMsg.connection.GetIntFrom()
    tName = tMsg.connection.GetStrFrom()
    tDisk = [#id: tid, #name: tName]
    pDiskList.add(tDisk)
  end repeat
  return 1
end

on parseJukeboxDisks me, tMsg
  tid = 1
  tJukeBoxManager = me.getJukeBoxManager(tid)
  if tJukeBoxManager = 0 then
    return 0
  end if
  tRetVal = tJukeBoxManager.parseDiskList(tMsg)
  me.getInterface().renderJukeboxDiskList()
  return tRetVal
end

on insertPlaylistSong me, tSongID, tLength, tName, tAuthor
  tid = 1
  tSoundMachine = me.getSoundMachine(tid)
  if tSoundMachine = 0 then
    return 0
  end if
  return tSoundMachine.insertPlaylistSong(tSongID, tLength, tName, tAuthor)
end

on insertJukeboxDisk me
  tPlaylistManager = me.getPlaylistManager(pSoundMachineFurniID)
  if tPlaylistManager = 0 then
    return 0
  end if
  tIndex = tPlaylistManager.getSelectedDiskIndex()
  if (tIndex < 1) or (tIndex > pDiskList.count) then
    return 0
  end if
  tDiskID = pDiskList[tIndex][#id]
  pDiskList.deleteAt(tIndex)
  tid = 1
  tJukeBoxManager = me.getJukeBoxManager(tid)
  if tJukeBoxManager = 0 then
    return 0
  end if
  return tJukeBoxManager.insertDisk(tDiskID)
end

on handleMissingPackages me, tList
  pEditFailure = 1
  me.getInterface().hideSoundMachine()
  pEditFailure = 0
  tStr = RETURN
  repeat with i = 1 to tList.count
    tStr = tStr & RETURN && me.getSoundSetName(tList[i])
  end repeat
  me.getInterface().ShowAlert("missing_packages", tStr)
end

on handleListFull me, tCount, tListType
  if tListType = "songlist" then
    tid = pTimelineInstance.getSongID()
    if tid = 0 then
      pEditFailure = 1
      me.getInterface().hideSoundMachine()
      pEditFailure = 0
    end if
    me.getInterface().showAlertWithCount("no_more_songs", tCount)
  else
    if tListType = "playlist" then
      me.getInterface().showAlertWithCount("playlist_full", tCount)
    end if
  end if
end

on handleInvalidSongName me
  me.getInterface().ShowAlert("invalid_song_name")
end

on handleSongLocked me
  me.getInterface().ShowAlert("song_locked")
end

on handleJukeBoxPlaylistFull me
  me.getInterface().ShowAlert("jukebox_list_full")
end

on updateSetList me, tList
  pSoundSetInventoryList = []
  repeat with tid in tList
    tItem = [#id: tid]
    pSoundSetInventoryList.add(tItem)
  end repeat
  me.changeSetListPage(0)
  me.getInterface().updateSoundSetList()
end

on changeSetListPage me, tChange
  tIndex = pSoundSetListPage + tChange
  if tIndex < 1 then
    tIndex = me.getSoundListPageCount()
  else
    if tIndex > me.getSoundListPageCount() then
      tIndex = 1
    end if
  end if
  if tIndex = pSoundSetListPage then
    return 0
  end if
  pSoundSetListPage = tIndex
  return 1
end

on loadSoundSet me, tIndex
  tIndex = tIndex + ((pSoundSetListPage - 1) * pSoundSetListPageSize)
  if (tIndex < 1) or (tIndex > pSoundSetInventoryList.count) then
    return 0
  end if
  if pSoundSetInsertLocked then
    return 0
  end if
  tFreeSlot = 0
  repeat with i = 1 to pSoundSetList.count
    if pSoundSetList[i] = VOID then
      tFreeSlot = i
      exit repeat
    end if
  end repeat
  if tFreeSlot = 0 then
    return 0
  end if
  tSoundSet = pSoundSetInventoryList[tIndex]
  tSetID = tSoundSet[#id]
  if getConnection(pConnectionId) <> 0 then
    pSoundSetInventoryList.deleteAt(tIndex)
    pSoundSetInsertLocked = 1
    return getConnection(pConnectionId).send("INSERT_SOUND_PACKAGE", [#integer: tSetID, #integer: tFreeSlot])
  else
    return 0
  end if
end

on removeSoundSet me, tIndex
  tid = me.getSoundSetID(tIndex)
  if tid = 0 then
    return 0
  end if
  pTimelineInstance.soundSetRemoved(tid)
  if pSelectedSoundSet = tIndex then
    pSelectedSoundSet = 0
    pSelectedSoundSetSample = 0
  end if
  if getConnection(pConnectionId) <> 0 then
    pSoundSetList[tIndex] = VOID
    return getConnection(pConnectionId).send("EJECT_SOUND_PACKAGE", [#integer: tIndex])
  else
    return 1
  end if
end

on updateSoundSet me, tIndex, tid, tSampleList
  if (tIndex >= 1) and (tIndex <= pSoundSetLimit) then
    tSoundSet = [#id: tid]
    tMachineSampleList = []
    repeat with tSampleID in tSampleList
      tMachineSampleList.add([#id: tSampleID, #length: 0])
    end repeat
    tSoundSet[#samples] = tMachineSampleList
    pSoundSetList[tIndex] = tSoundSet
    repeat with tSampleIndex = 1 to tMachineSampleList.count
      me.getSampleReady(tSampleIndex, tIndex)
    end repeat
    me.getInterface().updateSoundSetSlots()
  end if
end

on clearSoundSets me
  pSoundSetList = []
  repeat with i = 1 to pSoundSetLimit
    pSoundSetList[i] = VOID
  end repeat
  me.getInterface().updateSoundSetSlots()
end

on getFreeSoundSetCount me
  tCount = 0
  repeat with i = 1 to pSoundSetList.count
    if pSoundSetList[i] = VOID then
      tCount = tCount + 1
    end if
  end repeat
  return tCount
end

on removeSoundSetInsertLock me
  pSoundSetInsertLocked = 0
end

on resolveSamplePosition me, tSampleID
  repeat with i = 1 to pSoundSetList.count
    tSoundSet = pSoundSetList[i]
    if not voidp(tSoundSet) then
      tSampleList = tSoundSet[#samples]
      repeat with j = 1 to tSampleList.count
        tSample = tSampleList[j]
        if tSample[#id] = tSampleID then
          return [#sample: j, #soundset: i]
        end if
      end repeat
    end if
  end repeat
  return 0
end

on insertSample me, tSlot, tChannel
  tid = 0
  tSample = me.getSample(pSelectedSoundSetSample, pSelectedSoundSet)
  if tSample <> 0 then
    tid = tSample[#id]
  else
    return 0
  end if
  if pTimelineInstance.insertSample(tSlot, tChannel, tid) then
    me.stopSong()
    return 1
  end if
  return 0
end

on removeSample me, tSlot, tChannel
  if pTimelineInstance.removeSample(tSlot, tChannel) then
    me.stopSong()
  end if
end

on checkSoundSetReferences me, tIndex
  tid = me.getSoundSetID(tIndex)
  if tid = 0 then
    return 0
  end if
  tid = pSoundSetList[tIndex][#id]
  return pTimelineInstance.checkSoundSetReferences(tid)
end

on getCanInsertSample me, tX, tY, tid
  return pTimelineInstance.getCanInsertSample(tX, tY, tid)
end

on clearTimeLine me
  pTimelineInstance.clearTimeLine()
  pPlayHeadPosX = 0
end

on updateEditorSong me, tid, tName
  pTimelineInstance.updateSongID(tid)
  pTimelineInstance.updateSongName(tName)
end

on playSample me, tSampleIndex, tSoundSet
  if pEditorSongPlaying then
    return 1
  end if
  tSample = me.getSample(tSampleIndex, tSoundSet)
  if tSample <> 0 then
    tReady = 1
    tSampleName = pTimelineInstance.getSampleName(tSample[#id])
    tSongController = getObject(pSongControllerID)
    if tSongController <> 0 then
      tReady = tSongController.startSamplePreview(tSampleName)
    end if
    return tReady
  end if
  return 0
end

on stopSample me
  tSongController = getObject(pSongControllerID)
  if tSongController <> 0 then
    return tSongController.stopSamplePreview()
  end if
  return 0
end

on getSampleReady me, tSampleIndex, tSoundSet
  tSample = me.getSample(tSampleIndex, tSoundSet)
  if tSample <> 0 then
    if tSample[#length] = 0 then
      tReady = 0
      tLength = pTimelineInstance.getSampleLength(tSample[#id])
      if tLength then
        tSample[#length] = tLength
        tReady = 1
      end if
      return tReady
    else
      return 1
    end if
  end if
  return 0
end

on getSample me, tSampleIndex, tSampleSet
  if (tSampleSet >= 1) and (tSampleSet <= pSoundSetLimit) then
    if not voidp(pSoundSetList[tSampleSet]) then
      if pSoundSetList[tSampleSet][#samples].count >= tSampleIndex then
        return pSoundSetList[tSampleSet][#samples][tSampleIndex]
      end if
    end if
  end if
  return 0
end

on getSampleSetNumber me, tSampleID
  tSamplePos = me.resolveSamplePosition(tSampleID)
  if tSamplePos <> 0 then
    return tSamplePos[#soundset]
  end if
  return 0
end

on getSampleIndex me, tSampleID
  tSamplePos = me.resolveSamplePosition(tSampleID)
  if tSamplePos <> 0 then
    return tSamplePos[#sample]
  end if
  return 0
end

on playSong me
  if pEditorOpen then
    if pEditorSongPlaying then
      return 1
    end if
    pEditorSongLength = pTimelineInstance.resolveSongLength()
    if pEditorSongLength = 0 then
      return 0
    end if
    if pPlayHeadPosX > pEditorSongLength then
      pPlayHeadPosX = 0
      me.getInterface().updatePlayHead()
    end if
    tPosition = me.getTimeLineSlotLength() * pPlayHeadPosX
    tSongData = pTimelineInstance.getSongData()
    if tSongData = 0 then
      return 0
    end if
    tReady = 0
    tSongController = getObject(pSongControllerID)
    if tSongController <> 0 then
      tSongData[#offset] = tPosition
      tReady = tSongController.playSong(tSongData)
      if tReady then
        pEditorSongPlaying = 1
        pEditorSongStartTime = the milliSeconds
        me.getInterface().updatePlayButton()
      end if
    end if
    return tReady
  else
    tid = 1
    tSoundMachine = me.getSoundMachine(tid)
    if tSoundMachine = 0 then
      return 0
    end if
    tSoundMachine.playSong()
  end if
end

on stopSong me
  if pEditorSongPlaying then
    tPlayTime = me.getEditorPlayTime()
    tSlotLength = me.getTimeLineSlotLength()
    tPos = ((tPlayTime / tSlotLength) + pPlayHeadPosX) mod pEditorSongLength
    pPlayHeadPosX = tPos
    pEditorSongPlaying = 0
    pEditorSongLength = 0
    me.getInterface().updatePlayHead()
    me.getInterface().updatePlayButton()
    pEditorSongStartTime = 0
    tSongController = getObject(pSongControllerID)
    if tSongController <> 0 then
      tSongController.stopSong(1)
    end if
  else
    tid = 1
    tSoundMachine = me.getSoundMachine(tid)
    if tSoundMachine = 0 then
      return 0
    end if
    tSoundMachine.stopSong()
  end if
  return 1
end

on parseSongData me, tdata, tSongID, tSongName
  tid = 1
  tSoundMachine = me.getSoundMachine(tid)
  if tSoundMachine = 0 then
    return 0
  end if
  tSoundMachine.parseSongData(tdata, tSongID, tSongName)
  tSoundMachine.processSongData()
  if pEditorSongID = tSongID then
    pTimelineInstance.parseSongData(tdata, tSongID, tSongName)
    me.processEditorSongData()
  end if
end

on openEditorSong me
  tPlaylistManager = me.getPlaylistManager(pSoundMachineFurniID)
  if tPlaylistManager = 0 then
    return 0
  end if
  tRetVal = tPlaylistManager.editSong()
  if tRetVal then
    pEditorSongID = tPlaylistManager.getEditorSongID()
    pTimelineInstance.reset(1)
  end if
  return tRetVal
end

on newEditorSong me
  tPlaylistManager = me.getPlaylistManager(pSoundMachineFurniID)
  if tPlaylistManager = 0 then
    return 0
  end if
  tRetVal = tPlaylistManager.newSong()
  if tRetVal then
    pTimelineInstance.reset(0)
  end if
  return tRetVal
end

on saveEditorSong me, tNewName
  tNewSong = pTimelineInstance.encodeTimeLineData()
  if tNewSong <> 0 then
    if getConnection(pConnectionId) <> 0 then
      tid = pTimelineInstance.getSongID()
      tName = tNewName
      pTimelineInstance.resetChanged()
      if tid = 0 then
        return getConnection(pConnectionId).send("SAVE_SONG_NEW", [#string: tName, #string: tNewSong])
      else
        return getConnection(pConnectionId).send("SAVE_SONG_EDIT", [#integer: tid, #string: tName, #string: tNewSong])
      end if
    else
      return 1
    end if
  else
    return 0
  end if
end

on processEditorSongData me
  tReady = 1
  if not pTimelineInstance.processSongData() then
    tReady = 0
  end if
  if not tReady then
    if not timeoutExists(pTimeLineUpdateTimer) then
      createTimeout(pTimeLineUpdateTimer, 500, #processEditorSongData, me.getID(), VOID, 1)
    end if
  end if
  if pEditorOpen then
    me.getInterface().renderTimeLine()
  end if
end

on roomActivityUpdate me, tInitialUpdate
  tUpdate = me.getInterface().getEditorWindowExists()
  if tUpdate then
    if not tInitialUpdate then
      getConnection(pConnectionId).send("MOVE", [#short: 1000, #short: 1000])
    end if
    if not timeoutExists(pRoomActivityUpdateTimer) then
      createTimeout(pRoomActivityUpdateTimer, 30 * 1000, #roomActivityUpdate, me.getID(), VOID, 1)
    end if
  end if
end
