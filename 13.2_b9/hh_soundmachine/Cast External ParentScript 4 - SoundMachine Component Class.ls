property pSelectedSoundSet, pSelectedSoundSetSample, pHooveredSoundSet, pHooveredSoundSetSample, pHooveredSampleReady, pHooveredSoundSetTab, pSoundSetLimit, pSoundSetList, pSampleHorCount, pSampleVerCount, pSoundSetListPageSize, pSoundSetInventoryList, pSoundSetListPage, pTimeLineChannelCount, pTimeLineSlotCount, pTimeLineViewSlotCount, pTimeLineSlotLength, pTimeLineCursorX, pTimeLineCursorY, pTimeLineScrollX, pPlayHeadPosX, pSampleNameBase, pTimeLineUpdateTimer, pSongController, pSoundMachineFurniID, pConnectionId, pConfirmedAction, pConfirmedActionParameter, pSoundSetInsertLocked, pSongChanged, pWriterID, pRoomActivityUpdateTimer, pTimeLineData, pTimeLineReady, pSoundMachineFurniOn, pSongStartTime, pSongPlaying, pPlayTime, pInitialProcessTime, pSongLength, pSongData

on construct me
  pWriterID = getUniqueID()
  tBold = getStructVariable("struct.font.plain")
  tMetrics = [#font: tBold.getaProp(#font), #fontStyle: tBold.getaProp(#fontStyle), #color: rgb("#B6DCDF")]
  createWriter(pWriterID, tMetrics)
  pTimeLineUpdateTimer = "sound_machine_timeline_timer"
  pRoomActivityUpdateTimer = "sound_machine_room_activity_timer"
  pSampleNameBase = "sound_machine_sample_"
  pConnectionId = getVariableValue("connection.info.id", #info)
  pSampleHorCount = 3
  pSampleVerCount = 3
  pSoundSetLimit = 4
  pSoundSetListPageSize = 3
  pTimeLineChannelCount = 4
  pTimeLineSlotCount = 150
  pTimeLineSlotLength = 2000
  pTimeLineScrollX = 0
  pTimeLineViewSlotCount = 24
  pSongController = "song controller"
  createObject(pSongController, "Song Controller Class")
  me.reset(1)
  registerMessage(#sound_machine_selected, me.getID(), #soundMachineSelected)
  registerMessage(#sound_machine_set_state, me.getID(), #soundMachineSetState)
  registerMessage(#sound_machine_removed, me.getID(), #soundMachineRemoved)
  registerMessage(#sound_machine_created, me.getID(), #soundMachineCreated)
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
  unregisterMessage(#sound_machine_selected, me.getID())
  unregisterMessage(#sound_machine_set_state, me.getID())
  unregisterMessage(#sound_machine_removed, me.getID())
  unregisterMessage(#sound_machine_created, me.getID())
  return 1
end

on reset me, tInitialReset
  pSoundMachineFurniOn = 0
  me.closeEdit(tInitialReset)
  me.clearSoundSets()
  pSoundSetInventoryList = []
end

on closeEdit me, tInitialReset
  pSoundMachineFurniID = 0
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
  pSongChanged = 0
  pPlayTime = 0
  pInitialProcessTime = 0
  pSongLength = 0
  me.clearTimeLine()
  if not tInitialReset then
    if getConnection(pConnectionId) <> 0 then
      return getConnection(pConnectionId).send("GET_SOUND_DATA")
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
      if pSongChanged then
        return 1
      end if
    "clear":
      return 1
    "save":
      return 1
  end case
  me.actionConfirmed()
  return 0
end

on actionConfirmed me
  case pConfirmedAction of
    "eject":
      tRetVal = me.removeSoundSet(pConfirmedActionParameter)
      if tRetVal then
        me.getInterface().renderTimeLine()
      end if
    "close":
      me.getInterface().hideSoundMachine()
    "clear":
      me.clearTimeLine()
      me.getInterface().renderTimeLine()
    "save":
      me.saveSong()
  end case
  pConfirmedAction = EMPTY
  pConfirmedActionParameter = EMPTY
  return 1
end

on getConfigurationData me
  me.stopSong()
  if getConnection(pConnectionId) <> 0 then
    tRetVal = getConnection(pConnectionId).send("GET_SOUND_MACHINE_CONFIGURATION")
    if tRetVal then
      return getConnection(pConnectionId).send("GET_SOUND_DATA")
    end if
  end if
  return 0
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

on getPlayTime me
  if not pSongPlaying then
    return 0
  end if
  tTime = (the milliSeconds + 30 - pSongStartTime) mod (pTimeLineSlotLength * pSongLength)
  if tTime = 0 then
    tTime = 1
  end if
  return tTime
end

on getTimeLineSlotLength me
  return pTimeLineSlotLength
end

on getTimeLineViewSlotCount me
  return pTimeLineViewSlotCount
end

on getPlayHeadPosition me
  tPlayTime = me.getComponent().getPlayTime()
  tSlotLength = me.getComponent().getTimeLineSlotLength()
  if pSongPlaying then
    tPos = ((tPlayTime / tSlotLength) + pPlayHeadPosX) mod pSongLength
  else
    tPos = ((tPlayTime / tSlotLength) + pPlayHeadPosX) mod pTimeLineSlotCount
  end if
  tPos = 1 + tPos - pTimeLineScrollX
  if (tPos < 1) or (tPos > pTimeLineViewSlotCount) then
    return -(tPos + pTimeLineScrollX)
  end if
  return tPos
end

on movePlayHead me, tPos
  if pSongPlaying then
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
  tScrollX = max(0, min(pTimeLineScrollX + tDX, pTimeLineSlotCount - pTimeLineViewSlotCount))
  if tScrollX <> pTimeLineScrollX then
    pTimeLineScrollX = tScrollX
    return 1
  end if
  return 0
end

on scrollTimeLineTo me, tX
  tScrollX = max(0, min(tX, pTimeLineSlotCount - pTimeLineViewSlotCount))
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
    if pTimeLineScrollX < (pTimeLineSlotCount - pTimeLineViewSlotCount) then
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
    pSoundMachineFurniOn = tFurniOn
  end if
end

on soundMachineSetState me, tdata
  tFurniID = tdata[#id]
  tFurniOn = tdata[#furniOn]
  tIsEditing = 0
  if pSoundMachineFurniID = tFurniID then
    tIsEditing = 1
  end if
  pSoundMachineFurniOn = tFurniOn
  pPlayTime = 0
  if tIsEditing then
    me.soundMachineSelected([#id: tFurniID, #furniOn: pSoundMachineFurniOn])
  else
    if tFurniOn then
      if not pSongPlaying then
        if pTimeLineReady then
          me.playSong(0)
        else
          me.processSongData(0)
        end if
      end if
    else
      me.stopSong()
    end if
  end if
end

on soundMachineRemoved me, tFurniID
  me.clearTimeLine()
  pSoundMachineFurniID = 0
  pSoundMachineFurniOn = 0
  me.stopSong()
  me.getInterface().hideSoundMachine()
end

on soundMachineCreated me, tFurniID
  me.clearTimeLine()
  if getConnection(pConnectionId) <> 0 then
    return getConnection(pConnectionId).send("GET_SOUND_DATA")
  end if
  return 0
end

on changeFurniState me
  tNewState = not pSoundMachineFurniOn
  tObj = getThread(#room).getComponent().getActiveObject(pSoundMachineFurniID)
  if tObj <> 0 then
    call(#changeState, [tObj], tNewState)
  end if
  pSoundMachineFurniID = 0
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

on removeSoundSetInsertLock me
  pSoundSetInsertLocked = 0
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

on checkSoundSetReferences me, tIndex
  if tIndex < 1 then
    return 0
  end if
  if voidp(pSoundSetList[tIndex]) then
    return 0
  end if
  repeat with tChannel in pTimeLineData
    repeat with tSlot = 1 to tChannel.count
      if not voidp(tChannel[tSlot]) then
        tSampleID = tChannel[tSlot]
        if tSampleID < 0 then
          tSampleID = -tSampleID
        end if
        if me.getSampleSetNumber(tSampleID) = tIndex then
          return 1
        end if
      end if
    end repeat
  end repeat
  repeat with tChannel in pSongData
    repeat with tSample in tChannel
      if not voidp(tSample) then
        tSampleID = tSample[#id]
        if me.getSampleSetNumber(tSampleID) = tIndex then
          return 1
        end if
      end if
    end repeat
  end repeat
  return 0
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
  if tIndex < 1 then
    return 0
  end if
  if voidp(pSoundSetList[tIndex]) then
    return 0
  end if
  repeat with tChannel in pTimeLineData
    repeat with tSlot = 1 to tChannel.count
      if not voidp(tChannel[tSlot]) then
        tSampleID = tChannel[tSlot]
        if tSampleID < 0 then
          tSampleID = -tSampleID
        end if
        if me.getSampleSetNumber(tSampleID) = tIndex then
          pSongChanged = 1
          tChannel[tSlot] = VOID
        end if
      end if
    end repeat
  end repeat
  repeat with tChannel in pSongData
    repeat with tSlot = 1 to tChannel.count
      tSample = tChannel[tSlot]
      if not voidp(tSample) then
        tSampleID = tSample[#id]
        if me.getSampleSetNumber(tSampleID) = tIndex then
          pSongChanged = 1
          tChannel[tSlot] = VOID
        end if
      end if
    end repeat
  end repeat
  if pSelectedSoundSet = tIndex then
    pSelectedSoundSet = 0
    pSelectedSoundSetSample = 0
  end if
  tNewSong = me.encodeTimeLineData()
  if tNewSong <> 0 then
    if getConnection(pConnectionId) <> 0 then
      pSoundSetList[tIndex] = VOID
      return getConnection(pConnectionId).send("EJECT_SOUND_PACKAGE", [#integer: tIndex, #string: tNewSong])
    else
      return 1
    end if
  else
    return 0
  end if
end

on clearSoundSets me
  pSoundSetList = []
  repeat with i = 1 to pSoundSetLimit
    pSoundSetList[i] = VOID
  end repeat
  me.getInterface().updateSoundSetSlots()
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
        if (tX < 1) or (tX > pTimeLineSlotCount) or (tY < 1) or (tY > pTimeLineChannelCount) then
          pTimeLineCursorX = 0
          pTimeLineCursorY = 0
          return 1
        end if
      end if
    end if
  end if
  return 0
end

on clearTimeLine me
  me.stopSong()
  pTimeLineData = []
  pSongData = []
  repeat with i = 1 to pTimeLineChannelCount
    tChannel = []
    repeat with j = 1 to pTimeLineSlotCount
      tChannel[j] = VOID
    end repeat
    pTimeLineData[i] = tChannel
    pSongData[i] = tChannel.duplicate()
  end repeat
  pTimeLineReady = 1
  pPlayHeadPosX = 0
  pSongChanged = 1
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
  tImg = image((pTimeLineViewSlotCount * tWd) + (tMarginWd * (pTimeLineViewSlotCount - 1)), (pTimeLineChannelCount * tHt) + (tMarginHt * (pTimeLineChannelCount - 1)), 32)
  tmember = getMember(tBgImage)
  if tmember <> 0 then
    tImg.copyPixels(tmember.image, tImg.rect, tmember.image.rect)
  end if
  repeat with tChannel = 1 to pTimeLineData.count
    tChannelData = pTimeLineData[tChannel]
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
  tLength = me.getSampleLength(tSampleNumber)
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
      repeat with tPos = tstart to tEnd
        tRect = tRectOrig.duplicate()
        tRect[1] = tRect[1] + ((tPos - 1) * (tWd + tMarginWd)) + ((tWd - tImgWd) / 2)
        tRect[3] = tRect[3] + ((tPos - 1) * (tWd + tMarginWd)) + ((tWd - tImgWd) / 2)
        tProps = [#ink: 8, #maskImage: tSourceImg.createMatte(), #blend: tBlend]
        tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, tProps)
      end repeat
    end if
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
  tEnd = min(pTimeLineScrollX + pTimeLineViewSlotCount - 1, pTimeLineSlotCount)
  repeat with tSlot = tstart to tEnd
    if (tSlot * pTimeLineSlotLength mod 10000) = 0 then
      tOffset = rect((tWd + tMarginWd) * (tSlot - pTimeLineScrollX), 0, (tWd + tMarginWd) * (tSlot - pTimeLineScrollX), 0)
      tSeconds = tSlot * pTimeLineSlotLength / 1000
      if tSeconds < 60 then
        tStr = getText("sound_machine_time_1")
      else
        tStr = getText("sound_machine_time_2")
      end if
      tMinStr = string(tSeconds / 60)
      if (tSeconds mod 60) <> 0 then
        tSecStr = string(tSeconds mod 60)
      else
        tSecStr = "00"
      end if
      tStr = replaceChunks(tStr, "%min%", tMinStr)
      tStr = replaceChunks(tStr, "%sec%", tSecStr)
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

on playSample me, tSampleIndex, tSoundSet
  if pSongPlaying then
    return 1
  end if
  tSample = me.getSample(tSampleIndex, tSoundSet)
  if tSample <> 0 then
    tReady = 1
    tSampleName = me.getSampleName(tSample[#id])
    if objectExists(pSongController) then
      tReady = getObject(pSongController).startSamplePreview(tSampleName)
    end if
    return tReady
  end if
  return 0
end

on stopSample me
  if objectExists(pSongController) then
    return getObject(pSongController).stopSamplePreview()
  end if
  return 0
end

on getSampleReady me, tSampleIndex, tSoundSet
  tSample = me.getSample(tSampleIndex, tSoundSet)
  if tSample <> 0 then
    if tSample[#length] = 0 then
      tReady = 0
      tLength = me.getSampleLength(tSample[#id])
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

on getSampleLength me, tSampleID
  if tSampleID < 0 then
    return 1
  end if
  tLength = 0
  tSampleName = me.getSampleName(tSampleID)
  if objectExists(pSongController) then
    tSongController = getObject(pSongController)
    tReady = tSongController.getSampleLoadingStatus(tSampleName)
    if not tReady then
      tSongController.preloadSounds([tSampleName])
    else
      tLength = tSongController.getSampleLength(tSampleName)
      tLength = (tLength + (pTimeLineSlotLength - 1)) / pTimeLineSlotLength
    end if
  end if
  return tLength
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

on getSampleName me, tSampleID
  tName = pSampleNameBase & tSampleID
  return tName
end

on insertSample me, tSlot, tChannel
  tid = 0
  tSample = me.getSample(pSelectedSoundSetSample, pSelectedSoundSet)
  if tSample <> 0 then
    tid = tSample[#id]
  else
    return 0
  end if
  tInsert = me.getCanInsertSample(tSlot, tChannel, tid)
  if tInsert then
    pSongChanged = 1
    pTimeLineData[tChannel][tSlot] = tid
    me.stopSong()
    return 1
  end if
  return 0
end

on removeSample me, tSlot, tChannel
  if (tChannel >= 1) and (tChannel <= pTimeLineData.count) then
    if (tSlot >= 1) and (tSlot <= pTimeLineData[tChannel].count) then
      if not voidp(pTimeLineData[tChannel][tSlot]) then
        if pTimeLineData[tChannel][tSlot] < 0 then
          return 0
        end if
      else
        repeat with i = tSlot - 1 down to 1
          if not voidp(pTimeLineData[tChannel][i]) then
            tSampleID = pTimeLineData[tChannel][i]
            if tSampleID >= 0 then
              tSampleLength = me.getSampleLength(tSampleID)
              if tSampleLength <> 0 then
                if (i + (tSampleLength - 1)) >= tSlot then
                  tSlot = i
                  exit repeat
                  next repeat
                end if
                return 0
              end if
            end if
          end if
        end repeat
      end if
      pSongChanged = 1
      me.stopSong()
      pTimeLineData[tChannel][tSlot] = VOID
      return 1
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

on getCanInsertSample me, tX, tY, tid
  tLength = me.getSampleLength(tid)
  if tLength <> 0 then
    if (tX >= 1) and ((tX + (tLength - 1)) <= pTimeLineSlotCount) and (tY >= 1) and (tY <= pTimeLineData.count) then
      tChannel = pTimeLineData[tY]
      repeat with i = tX to tX + tLength - 1
        if not voidp(tChannel[i]) then
          return 0
        end if
      end repeat
      repeat with i = tX - 1 down to 1
        if not voidp(tChannel[i]) then
          tNumber = tChannel[i]
          if (i + (me.getSampleLength(tNumber) - 1)) >= tX then
            return 0
            next repeat
          end if
          return 1
        end if
      end repeat
      return 1
    end if
  end if
  return 0
end

on playSong me, tEditor
  if pSongPlaying then
    return 1
  end if
  pSongLength = me.resolveSongLength()
  if pSongLength = 0 then
    return 0
  end if
  if tEditor then
    if pPlayHeadPosX > pSongLength then
      pPlayHeadPosX = 0
      me.getInterface().updatePlayHead()
    end if
    tPosition = pTimeLineSlotLength * pPlayHeadPosX
  else
    tPosition = pPlayTime
  end if
  tSongData = [#offset: 0, #sounds: []]
  repeat with tChannel = 1 to pTimeLineData.count
    tChannelData = pTimeLineData[tChannel]
    tEmpty = 1
    repeat with i = 1 to pSongLength
      if not voidp(tChannelData[i]) then
        tEmpty = 0
        exit repeat
      end if
    end repeat
    if not tEmpty then
      tSlot = 1
      repeat while tSlot <= pSongLength
        if not voidp(tChannelData[tSlot]) then
          tSampleID = tChannelData[tSlot]
          tSampleLength = me.getSampleLength(tSampleID)
          if (tSampleLength <> 0) and (tSampleID >= 0) then
            tCount = 0
            repeat while tChannelData[tSlot] = tSampleID
              tCount = tCount + 1
              tSlot = tSlot + tSampleLength
              if tSlot > pSongLength then
                exit repeat
              end if
            end repeat
            tSampleName = me.getSampleName(tSampleID)
            tSampleData = [#name: tSampleName, #loops: tCount, #channel: tChannel]
            tSongData[#sounds][tSongData[#sounds].count + 1] = tSampleData
          else
            tSampleName = me.getSampleName(0)
            tSampleData = [#name: tSampleName, #loops: 1, #channel: tChannel]
            tSongData[#sounds][tSongData[#sounds].count + 1] = tSampleData
            tSlot = tSlot + 1
          end if
          next repeat
        end if
        tCount = 0
        repeat while voidp(tChannelData[tSlot])
          tCount = tCount + 1
          tSlot = tSlot + 1
          if tSlot > pSongLength then
            exit repeat
          end if
        end repeat
        tSampleName = me.getSampleName(0)
        tSampleData = [#name: tSampleName, #loops: tCount, #channel: tChannel]
        tSongData[#sounds][tSongData[#sounds].count + 1] = tSampleData
      end repeat
    end if
  end repeat
  tReady = 0
  if objectExists(pSongController) then
    tSongData[#offset] = tPosition
    tReady = getObject(pSongController).playSong(tSongData)
    if tReady then
      pSongPlaying = 1
      pSongStartTime = the milliSeconds
      me.getInterface().updatePlayButton()
    end if
  end if
  return tReady
end

on stopSong me
  if pSongPlaying then
    tPlayTime = me.getComponent().getPlayTime()
    tSlotLength = me.getComponent().getTimeLineSlotLength()
    tPos = ((tPlayTime / tSlotLength) + pPlayHeadPosX) mod pSongLength
    pPlayHeadPosX = tPos
    pSongPlaying = 0
    pSongLength = 0
    me.getInterface().updatePlayHead()
    me.getInterface().updatePlayButton()
  end if
  pSongStartTime = 0
  if objectExists(pSongController) then
    getObject(pSongController).stopSong()
  end if
  return 1
end

on saveSong me, tdata
  tNewSong = me.encodeTimeLineData()
  if tNewSong <> 0 then
    if getConnection(pConnectionId) <> 0 then
      return getConnection(pConnectionId).send("SAVE_SOUND_MACHINE_CONFIGURATION", [#string: tNewSong])
    else
      return 1
    end if
  else
    return 0
  end if
end

on parseSongData me, tdata, tPlayTime
  me.clearTimeLine()
  pSongChanged = 0
  repeat with i = 1 to tdata.count
    tChannel = tdata[i]
    if i <= pSongData.count then
      tSongChannel = pSongData[i]
      tSlot = 1
      repeat with tSample in tChannel
        tid = tSample[#id]
        tLength = tSample[#length]
        if tSlot <= tSongChannel.count then
          pSongData[i][tSlot] = tSample.duplicate()
        end if
        tSlot = tSlot + tLength
      end repeat
    end if
  end repeat
  me.processSongData(tPlayTime)
  return 1
end

on processSongData me, tPlayTime
  repeat with i = 1 to pTimeLineData.count
    repeat with j = 1 to pTimeLineData[i].count
      if pTimeLineData[i][j] < 0 then
        pTimeLineData[i][j] = VOID
      end if
    end repeat
  end repeat
  tReady = 1
  repeat with i = 1 to min(pSongData.count, pTimeLineData.count)
    tSongChannel = pSongData[i]
    tTimeLineChannel = pTimeLineData[i]
    repeat with j = 1 to tSongChannel.count
      tSample = tSongChannel[j]
      if not voidp(tSample) then
        tid = tSample[#id]
        tLength = tSample[#length]
        tSampleLength = me.getSampleLength(tid)
        tWasReady = 1
        if tSampleLength = 0 then
          tSampleLength = 1
          tid = -tid
          tReady = 0
          tWasReady = 0
        end if
        if tid <> 0 then
          tRepeats = tLength / tSampleLength
          repeat with k = 1 to tRepeats
            if me.getCanInsertSample(j + ((k - 1) * tSampleLength), i, tid) then
              tTimeLineChannel[j + ((k - 1) * tSampleLength)] = tid
            end if
          end repeat
        end if
        if tWasReady then
          tSongChannel[j] = VOID
        end if
      end if
    end repeat
  end repeat
  pTimeLineReady = tReady
  if not pTimeLineReady then
    if not timeoutExists(pTimeLineUpdateTimer) then
      createTimeout(pTimeLineUpdateTimer, 500, #processSongData, me.getID(), VOID, 1)
    end if
  end if
  me.getInterface().renderTimeLine()
  tSongLength = me.resolveSongLength()
  if not voidp(tPlayTime) then
    if tSongLength then
      pPlayTime = tPlayTime mod (tSongLength * pTimeLineSlotLength / 100)
      pPlayTime = pPlayTime * 100
    else
      pPlayTime = 0
    end if
    pInitialProcessTime = the milliSeconds
  end if
  if pTimeLineReady then
    tIsEditing = 0
    if pSoundMachineFurniID <> 0 then
      tIsEditing = 1
    end if
    pPlayTime = (pPlayTime + (the milliSeconds - pInitialProcessTime)) mod (tSongLength * pTimeLineSlotLength)
    pInitialProcessTime = 0
    if not tIsEditing and pSoundMachineFurniOn then
      pSongPlaying = 0
      me.playSong(0)
    end if
  end if
  return tReady
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

on encodeTimeLineData me
  tStr = EMPTY
  tSongLength = me.resolveSongLength()
  if tSongLength > 0 then
    repeat with i = 1 to pTimeLineData.count
      tChannel = pTimeLineData[i]
      tStr = tStr & i & ":"
      j = 1
      tChannelData = []
      repeat while j <= tSongLength
        if voidp(tChannel[j]) then
          tSample = [#id: 0, #length: 1]
          j = j + 1
        else
          tSampleID = tChannel[j]
          tSampleLength = me.getSampleLength(tSampleID)
          if tSampleID < 0 then
            tSampleID = -tSampleID
          end if
          if tSampleLength = 0 then
            tSample = [#id: 0, #length: 1]
          else
            tSample = [#id: tSampleID, #length: tSampleLength]
          end if
          j = j + tSample[#length]
        end if
        tChannelData[tChannelData.count + 1] = tSample
      end repeat
      j = 1
      repeat while j < tChannelData.count
        if tChannelData[j][#id] = tChannelData[j + 1][#id] then
          tChannelData[j][#length] = tChannelData[j][#length] + tChannelData[j + 1][#length]
          tChannelData.deleteAt(j + 1)
          next repeat
        end if
        j = j + 1
      end repeat
      tChannelStr = EMPTY
      repeat with tSample in tChannelData
        if tChannelStr <> EMPTY then
          tChannelStr = tChannelStr & ";"
        end if
        tChannelStr = tChannelStr & tSample[#id] & "," & tSample[#length]
      end repeat
      tStr = tStr & tChannelStr & ":"
    end repeat
  end if
  return tStr
end

on resolveSongLength me
  tLength = 0
  repeat with tChannel = 1 to pTimeLineData.count
    tChannelData = pTimeLineData[tChannel]
    tSlot = 1
    repeat while tSlot <= tChannelData.count
      if not voidp(tChannelData[tSlot]) then
        tSampleID = tChannelData[tSlot]
        tSampleLength = me.getSampleLength(tSampleID)
        if (tSampleLength <> 0) and (tSampleID >= 0) then
          repeat while tChannelData[tSlot] = tSampleID
            tSlot = tSlot + tSampleLength
            if (tSlot - 1) > tLength then
              tLength = tSlot - 1
            end if
            if tSlot > tChannelData.count then
              exit repeat
            end if
          end repeat
        else
          tSlot = tSlot + 1
          if tSampleID < 0 then
            if (tSlot - 1) > tLength then
              tLength = tSlot - 1
            end if
          end if
        end if
        next repeat
      end if
      repeat while voidp(tChannelData[tSlot])
        tSlot = tSlot + 1
        if tSlot > tChannelData.count then
          exit repeat
        end if
      end repeat
    end repeat
  end repeat
  return tLength
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
