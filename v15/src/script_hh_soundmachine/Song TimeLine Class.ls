property pSongData, pTimeLineData, pReady, pDataReady, pSongID, pSongName, pSongLength, pChanged, pSongControllerID, pChannelCount, pSlotCount, pSlotDuration, pSampleNameBase

on construct me
  pReady = 0
  pChanged = 0
  pChannelCount = 4
  pSlotCount = 150
  pSlotDuration = 2000
  pSampleNameBase = "sound_machine_sample_"
  pSongControllerID = "song controller"
  me.clearTimeLine()
  return 1
end

on deconstruct me
  return 1
end

on resetChanged me
  pChanged = 0
end

on reset me, tWaitForData
  pDataReady = not tWaitForData
  pSongID = 0
  pSongName = EMPTY
  pSongLength = 0
  me.clearTimeLine()
end

on updateSongID me, tNewID
  pSongID = tNewID
end

on updateSongName me, tNewName
  pSongName = tNewName
end

on soundSetRemoved me, tid
  repeat with tChannel in pTimeLineData
    repeat with tSlot = 1 to tChannel.count
      if not voidp(tChannel[tSlot]) then
        tSampleID = tChannel[tSlot]
        if (tSampleID < 0) then
          tSampleID = -tSampleID
        end if
        if (me.getSampleSetID(tSampleID) = tid) then
          pChanged = 1
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
        if (me.getSampleSetID(tSampleID) = tid) then
          pChanged = 1
          tChannel[tSlot] = VOID
        end if
      end if
    end repeat
  end repeat
end

on checkSoundSetReferences me, tid
  repeat with tChannel in pTimeLineData
    repeat with tSlot = 1 to tChannel.count
      if not voidp(tChannel[tSlot]) then
        tSampleID = tChannel[tSlot]
        if (tSampleID < 0) then
          tSampleID = -tSampleID
        end if
        if (me.getSampleSetID(tSampleID) = tid) then
          return 1
        end if
      end if
    end repeat
  end repeat
  repeat with tChannel in pSongData
    repeat with tSample in tChannel
      if not voidp(tSample) then
        tSampleID = tSample[#id]
        if (me.getSampleSetID(tSampleID) = tid) then
          return 1
        end if
      end if
    end repeat
  end repeat
  return 0
end

on getSongID me
  return pSongID
end

on getSongName me
  return pSongName
end

on getChannelCount me
  return pChannelCount
end

on getSlotCount me
  return pSlotCount
end

on getChanged me
  return pChanged
end

on getReady me
  return pReady
end

on getDataReady me
  return pDataReady
end

on getSlotDuration me
  return pSlotDuration
end

on getTimeLineData me
  return pTimeLineData
end

on clearTimeLine me, tSongLength
  pTimeLineData = []
  pSongData = []
  if voidp(tSongLength) then
    tSongLength = pSlotCount
  end if
  repeat with i = 1 to pChannelCount
    tChannel = []
    repeat with j = 1 to pSlotCount
      tChannel[j] = VOID
    end repeat
    tChannelSong = []
    repeat with j = 1 to tSongLength
      tChannelSong[j] = VOID
    end repeat
    pTimeLineData[i] = tChannel
    pSongData[i] = tChannelSong
  end repeat
  pReady = 1
  pPlayHeadPosX = 0
  pChanged = 1
end

on parseSongData me, tdata, tSongID, tSongName
  pSongID = tSongID
  pSongName = tSongName
  tSongLength = 0
  repeat with i = 1 to tdata.count
    tChannel = tdata[i]
    tSlot = 1
    repeat with tSample in tChannel
      tLength = tSample[#length]
      tSlot = (tSlot + tLength)
    end repeat
    if ((tSlot - 1) > tSongLength) then
      tSongLength = (tSlot - 1)
    end if
  end repeat
  me.clearTimeLine(tSongLength)
  pChanged = 0
  repeat with i = 1 to tdata.count
    tChannel = tdata[i]
    if (i <= pSongData.count) then
      tSongChannel = pSongData[i]
      tSlot = 1
      repeat with tSample in tChannel
        tid = tSample[#id]
        tLength = tSample[#length]
        if (tSlot <= tSongChannel.count) then
          pSongData[i][tSlot] = tSample.duplicate()
        end if
        tSlot = (tSlot + tLength)
      end repeat
    end if
  end repeat
  pReady = 0
  pDataReady = 1
  return 1
end

on processSongData me
  if pReady then
    return 1
  end if
  if not pDataReady then
    return 0
  end if
  repeat with i = min(pSongData.count, pTimeLineData.count) down to 1
    repeat with j = min(pTimeLineData[i].count, pSongData[i].count) down to 1
      if (pTimeLineData[i][j] < 0) then
        pTimeLineData[i][j] = VOID
      end if
    end repeat
  end repeat
  tReady = 1
  tLengthCache = [:]
  repeat with i = 1 to min(pSongData.count, pTimeLineData.count)
    tSongChannel = pSongData[i]
    tTimeLineChannel = pTimeLineData[i]
    repeat with j = 1 to tSongChannel.count
      tSample = tSongChannel[j]
      if not voidp(tSample) then
        tid = tSample[#id]
        tLength = tSample[#length]
        if (tLengthCache.findPos(tid) > 0) then
          tSampleLength = tLengthCache.getProp(tid)
        else
          tSampleLength = me.getSampleLength(tid)
          tLengthCache.addProp(tid, tSampleLength)
        end if
        tWasReady = 1
        if (tSampleLength = 0) then
          tSampleLength = 1
          tid = -tid
          tReady = 0
          tWasReady = 0
        end if
        if (tid <> 0) then
          tIsFree = 1
          if not me.getIsFreeBlock(j, i, tLength) then
            tIsFree = 0
          end if
          tRepeats = (tLength / tSampleLength)
          repeat with k = 1 to tRepeats
            if tIsFree then
              tCanInsert = 1
            else
              tCanInsert = me.getCanInsertSample((j + ((k - 1) * tSampleLength)), i, tid)
            end if
            if tCanInsert then
              tTimeLineChannel[(j + ((k - 1) * tSampleLength))] = tid
            end if
          end repeat
        end if
        if tWasReady then
          tSongChannel[j] = VOID
        end if
      end if
    end repeat
  end repeat
  pReady = tReady
  return tReady
end

on resolveSongLength me
  tLength = 0
  repeat with tChannel = 1 to pTimeLineData.count
    tChannelData = pTimeLineData[tChannel]
    tSlot = 1
    repeat while (tSlot <= tChannelData.count)
      if not voidp(tChannelData[tSlot]) then
        tSampleID = tChannelData[tSlot]
        tSampleLength = me.getSampleLength(tSampleID)
        if ((tSampleLength <> 0) and (tSampleID >= 0)) then
          repeat while (tChannelData[tSlot] = tSampleID)
            tSlot = (tSlot + tSampleLength)
            if ((tSlot - 1) > tLength) then
              tLength = (tSlot - 1)
            end if
            if (tSlot > tChannelData.count) then
              exit repeat
            end if
          end repeat
        else
          tSlot = (tSlot + 1)
          if (tSampleID < 0) then
            if ((tSlot - 1) > tLength) then
              tLength = (tSlot - 1)
            end if
          end if
        end if
        next repeat
      end if
      repeat while voidp(tChannelData[tSlot])
        tSlot = (tSlot + 1)
        if (tSlot > tChannelData.count) then
          exit repeat
        end if
      end repeat
    end repeat
  end repeat
  return tLength
end

on getCanInsertSample me, tX, tY, tid
  tLength = me.getSampleLength(tid)
  return me.getIsFreeBlock(tX, tY, tLength)
end

on getIsFreeBlock me, tX, tY, tLength
  if (tLength <> 0) then
    if ((((tX >= 1) and ((tX + (tLength - 1)) <= pSlotCount)) and (tY >= 1)) and (tY <= pTimeLineData.count)) then
      tChannel = pTimeLineData[tY]
      repeat with i = tX to ((tX + tLength) - 1)
        if not voidp(tChannel[i]) then
          return 0
        end if
      end repeat
      repeat with i = (tX - 1) down to 1
        if not voidp(tChannel[i]) then
          tNumber = tChannel[i]
          if ((i + (me.getSampleLength(tNumber) - 1)) >= tX) then
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

on getSongData me
  pSongLength = me.resolveSongLength()
  if (pSongLength = 0) then
    return 0
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
      repeat while (tSlot <= pSongLength)
        if not voidp(tChannelData[tSlot]) then
          tSampleID = tChannelData[tSlot]
          tSampleLength = me.getSampleLength(tSampleID)
          if ((tSampleLength <> 0) and (tSampleID >= 0)) then
            tCount = 0
            repeat while (tChannelData[tSlot] = tSampleID)
              tCount = (tCount + 1)
              tSlot = (tSlot + tSampleLength)
              if (tSlot > pSongLength) then
                exit repeat
              end if
            end repeat
            tSampleName = me.getSampleName(tSampleID)
            tSampleData = [#name: tSampleName, #loops: tCount, #channel: tChannel]
            tSongData[#sounds][(tSongData[#sounds].count + 1)] = tSampleData
          else
            tSampleName = me.getSampleName(0)
            tSampleData = [#name: tSampleName, #loops: 1, #channel: tChannel]
            tSongData[#sounds][(tSongData[#sounds].count + 1)] = tSampleData
            tSlot = (tSlot + 1)
          end if
          next repeat
        end if
        tCount = 0
        repeat while voidp(tChannelData[tSlot])
          tCount = (tCount + 1)
          tSlot = (tSlot + 1)
          if (tSlot > pSongLength) then
            exit repeat
          end if
        end repeat
        tSampleName = me.getSampleName(0)
        tSampleData = [#name: tSampleName, #loops: tCount, #channel: tChannel]
        tSongData[#sounds][(tSongData[#sounds].count + 1)] = tSampleData
      end repeat
    end if
  end repeat
  return tSongData
end

on insertSample me, tSlot, tChannel, tid
  tInsert = me.getCanInsertSample(tSlot, tChannel, tid)
  if tInsert then
    pChanged = 1
    pTimeLineData[tChannel][tSlot] = tid
    return 1
  end if
  return 0
end

on removeSample me, tSlot, tChannel
  if ((tChannel >= 1) and (tChannel <= pTimeLineData.count)) then
    if ((tSlot >= 1) and (tSlot <= pTimeLineData[tChannel].count)) then
      if not voidp(pTimeLineData[tChannel][tSlot]) then
        if (pTimeLineData[tChannel][tSlot] < 0) then
          return 0
        end if
      else
        repeat with i = (tSlot - 1) down to 1
          if not voidp(pTimeLineData[tChannel][i]) then
            tSampleID = pTimeLineData[tChannel][i]
            if (tSampleID >= 0) then
              tSampleLength = me.getSampleLength(tSampleID)
              if (tSampleLength <> 0) then
                if ((i + (tSampleLength - 1)) >= tSlot) then
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
      pChanged = 1
      pTimeLineData[tChannel][tSlot] = VOID
      return 1
    end if
  end if
  return 0
end

on encodeTimeLineData me
  if (not pReady or not pDataReady) then
    return 0
  end if
  tStr = EMPTY
  tSongLength = me.resolveSongLength()
  if (tSongLength > 0) then
    repeat with i = 1 to pTimeLineData.count
      tChannel = pTimeLineData[i]
      tStr = ((tStr & i) & ":")
      j = 1
      tChannelData = []
      repeat while (j <= tSongLength)
        if voidp(tChannel[j]) then
          tSample = [#id: 0, #length: 1]
          j = (j + 1)
        else
          tSampleID = tChannel[j]
          tSampleLength = me.getSampleLength(tSampleID)
          if (tSampleID < 0) then
            tSampleID = -tSampleID
          end if
          if (tSampleLength = 0) then
            tSample = [#id: 0, #length: 1]
          else
            tSample = [#id: tSampleID, #length: tSampleLength]
          end if
          j = (j + tSample[#length])
        end if
        tChannelData[(tChannelData.count + 1)] = tSample
      end repeat
      j = 1
      repeat while (j < tChannelData.count)
        if (tChannelData[j][#id] = tChannelData[(j + 1)][#id]) then
          tChannelData[j][#length] = (tChannelData[j][#length] + tChannelData[(j + 1)][#length])
          tChannelData.deleteAt((j + 1))
          next repeat
        end if
        j = (j + 1)
      end repeat
      tChannelStr = EMPTY
      repeat with tSample in tChannelData
        if (tChannelStr <> EMPTY) then
          tChannelStr = (tChannelStr & ";")
        end if
        tChannelStr = (((tChannelStr & tSample[#id]) & ",") & tSample[#length])
      end repeat
      tStr = ((tStr & tChannelStr) & ":")
    end repeat
  end if
  return tStr
end

on getSampleLength me, tSampleID
  if (tSampleID < 0) then
    return 1
  end if
  tLength = 0
  tSampleName = me.getSampleName(tSampleID)
  tSongController = getObject(pSongControllerID)
  if (tSongController <> 0) then
    tReady = tSongController.getSampleLoadingStatus(tSampleName)
    if not tReady then
      tDelim = the itemDelimiter
      the itemDelimiter = "_"
      tSampleno = (tSampleName.item[4] - 1)
      tSamplesPerSEt = 9
      tParentNo = integer(((tSampleno / tSamplesPerSEt) + 1))
      tParentId = ("sound_set_" & tParentNo)
      the itemDelimiter = tDelim
      tSongController.preloadSounds([[#sound: tSampleName, #parent: tParentId]])
    else
      tLength = tSongController.getSampleLength(tSampleName)
      tLength = ((tLength + (pSlotDuration - 1)) / pSlotDuration)
    end if
  end if
  return tLength
end

on getSampleName me, tSampleID
  tName = (pSampleNameBase & tSampleID)
  return tName
end

on getSampleSetID me, tSampleID
  return (1 + ((tSampleID - 1) / 9))
end
