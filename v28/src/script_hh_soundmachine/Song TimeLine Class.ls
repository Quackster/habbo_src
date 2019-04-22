property pTimeLineData, pSongData, pSongID, pSongName, pChannelCount, pSlotCount, pChanged, pReady, pDataReady, pSlotDuration, pSongLength, pSongControllerID, pSampleNameBase

on construct me 
  pReady = 0
  pChanged = 0
  pChannelCount = 4
  pSlotCount = 150
  pSlotDuration = 2000
  pSampleNameBase = "sound_machine_sample_"
  pSongControllerID = "song controller"
  me.clearTimeLine()
  return(1)
end

on deconstruct me 
  return(1)
end

on resetChanged me 
  pChanged = 0
end

on reset me, tWaitForData 
  pDataReady = not tWaitForData
  pSongID = 0
  pSongName = ""
  pSongLength = 0
  me.clearTimeLine()
end

on updateSongID me, tNewID 
  pSongID = tNewID
end

on updateSongName me, tNewName 
  pSongName = tNewName
end

on soundSetRemoved me, tID 
  repeat while pTimeLineData <= undefined
    tChannel = getAt(undefined, tID)
    tSlot = 1
    repeat while tSlot <= tChannel.count
      if not voidp(tChannel.getAt(tSlot)) then
        tSampleID = tChannel.getAt(tSlot)
        if tSampleID < 0 then
          tSampleID = -tSampleID
        end if
        if me.getSampleSetID(tSampleID) = tID then
          pChanged = 1
          tChannel.setAt(tSlot, void())
        end if
      end if
      tSlot = 1 + tSlot
    end repeat
  end repeat
  repeat while pTimeLineData <= undefined
    tChannel = getAt(undefined, tID)
    tSlot = 1
    repeat while tSlot <= tChannel.count
      tSample = tChannel.getAt(tSlot)
      if not voidp(tSample) then
        tSampleID = tSample.getAt(#id)
        if me.getSampleSetID(tSampleID) = tID then
          pChanged = 1
          tChannel.setAt(tSlot, void())
        end if
      end if
      tSlot = 1 + tSlot
    end repeat
  end repeat
end

on checkSoundSetReferences me, tID 
  repeat while pTimeLineData <= undefined
    tChannel = getAt(undefined, tID)
    tSlot = 1
    repeat while tSlot <= tChannel.count
      if not voidp(tChannel.getAt(tSlot)) then
        tSampleID = tChannel.getAt(tSlot)
        if tSampleID < 0 then
          tSampleID = -tSampleID
        end if
        if me.getSampleSetID(tSampleID) = tID then
          return(1)
        end if
      end if
      tSlot = 1 + tSlot
    end repeat
  end repeat
  repeat while pTimeLineData <= undefined
    tChannel = getAt(undefined, tID)
    repeat while pTimeLineData <= undefined
      tSample = getAt(undefined, tID)
      if not voidp(tSample) then
        tSampleID = tSample.getAt(#id)
        if me.getSampleSetID(tSampleID) = tID then
          return(1)
        end if
      end if
    end repeat
  end repeat
  return(0)
end

on getSongID me 
  return(pSongID)
end

on getSongName me 
  return(pSongName)
end

on getChannelCount me 
  return(pChannelCount)
end

on getSlotCount me 
  return(pSlotCount)
end

on getChanged me 
  return(pChanged)
end

on getReady me 
  return(pReady)
end

on getDataReady me 
  return(pDataReady)
end

on getSlotDuration me 
  return(pSlotDuration)
end

on getTimeLineData me 
  return(pTimeLineData)
end

on clearTimeLine me, tSongLength 
  pTimeLineData = []
  pSongData = []
  if voidp(tSongLength) then
    tSongLength = pSlotCount
  end if
  i = 1
  repeat while i <= pChannelCount
    tChannel = []
    j = 1
    repeat while j <= pSlotCount
      tChannel.setAt(j, void())
      j = 1 + j
    end repeat
    tChannelSong = []
    j = 1
    repeat while j <= tSongLength
      tChannelSong.setAt(j, void())
      j = 1 + j
    end repeat
    pTimeLineData.setAt(i, tChannel)
    pSongData.setAt(i, tChannelSong)
    i = 1 + i
  end repeat
  pReady = 1
  pPlayHeadPosX = 0
  pChanged = 1
end

on parseSongData me, tdata, tSongID, tSongName 
  pSongID = tSongID
  pSongName = tSongName
  tSongLength = 0
  i = 1
  repeat while i <= tdata.count
    tChannel = tdata.getAt(i)
    tSlot = 1
    repeat while tChannel <= tSongID
      tSample = getAt(tSongID, tdata)
      tLength = tSample.getAt(#length)
      tSlot = tSlot + tLength
    end repeat
    if tSlot - 1 > tSongLength then
      tSongLength = tSlot - 1
    end if
    i = 1 + i
  end repeat
  me.clearTimeLine(tSongLength)
  pChanged = 0
  i = 1
  repeat while i <= tdata.count
    tChannel = tdata.getAt(i)
    if i <= pSongData.count then
      tSongChannel = pSongData.getAt(i)
      tSlot = 1
      repeat while tChannel <= tSongID
        tSample = getAt(tSongID, tdata)
        tID = tSample.getAt(#id)
        tLength = tSample.getAt(#length)
        if tSlot <= tSongChannel.count then
          pSongData.getAt(i).setAt(tSlot, tSample.duplicate())
        end if
        tSlot = tSlot + tLength
      end repeat
    end if
    i = 1 + i
  end repeat
  pReady = 0
  pDataReady = 1
  return(1)
end

on processSongData me 
  if pReady then
    return(1)
  end if
  if not pDataReady then
    return(0)
  end if
  i = min(pSongData.count, pTimeLineData.count)
  repeat while i >= 1
    j = min(pTimeLineData.getAt(i).count, pSongData.getAt(i).count)
    repeat while j >= 1
      if pTimeLineData.getAt(i).getAt(j) < 0 then
        pTimeLineData.getAt(i).setAt(j, void())
      end if
      j = 255 + j
    end repeat
    i = 255 + i
  end repeat
  tReady = 1
  tLengthCache = [:]
  i = 1
  repeat while i <= min(pSongData.count, pTimeLineData.count)
    tSongChannel = pSongData.getAt(i)
    tTimeLineChannel = pTimeLineData.getAt(i)
    j = 1
    repeat while j <= tSongChannel.count
      tSample = tSongChannel.getAt(j)
      if not voidp(tSample) then
        tID = tSample.getAt(#id)
        tLength = tSample.getAt(#length)
        if tLengthCache.findPos(tID) > 0 then
          tSampleLength = tLengthCache.getProp(tID)
        else
          tSampleLength = me.getSampleLength(tID)
          tLengthCache.addProp(tID, tSampleLength)
        end if
        tWasReady = 1
        if tSampleLength = 0 then
          tSampleLength = 1
          tID = -tID
          tReady = 0
          tWasReady = 0
        end if
        if tID <> 0 then
          tIsFree = 1
          if not me.getIsFreeBlock(j, i, tLength) then
            tIsFree = 0
          end if
          tRepeats = tLength / tSampleLength
          k = 1
          repeat while k <= tRepeats
            if tIsFree then
              tCanInsert = 1
            else
              tCanInsert = me.getCanInsertSample(j + k - 1 * tSampleLength, i, tID)
            end if
            if tCanInsert then
              tTimeLineChannel.setAt(j + k - 1 * tSampleLength, tID)
            end if
            k = 1 + k
          end repeat
        end if
        if tWasReady then
          tSongChannel.setAt(j, void())
        end if
      end if
      j = 1 + j
    end repeat
    i = 1 + i
  end repeat
  pReady = tReady
  return(tReady)
end

on resolveSongLength me 
  tLength = 0
  tChannel = 1
  repeat while tChannel <= pTimeLineData.count
    tChannelData = pTimeLineData.getAt(tChannel)
    tSlot = 1
    repeat while tSlot <= tChannelData.count
      if not voidp(tChannelData.getAt(tSlot)) then
        tSampleID = tChannelData.getAt(tSlot)
        tSampleLength = me.getSampleLength(tSampleID)
        if tSampleLength <> 0 and tSampleID >= 0 then
          repeat while tChannelData.getAt(tSlot) = tSampleID
            tSlot = tSlot + tSampleLength
            if tSlot - 1 > tLength then
              tLength = tSlot - 1
            end if
            if tSlot > tChannelData.count then
            else
            end if
          end repeat
          exit repeat
        end if
        tSlot = tSlot + 1
        if tSampleID < 0 then
          if tSlot - 1 > tLength then
            tLength = tSlot - 1
          end if
        end if
        next repeat
      end if
      repeat while voidp(tChannelData.getAt(tSlot))
        tSlot = tSlot + 1
        if tSlot > tChannelData.count then
          next repeat
        end if
      end repeat
    end repeat
    tChannel = 1 + tChannel
  end repeat
  return(tLength)
end

on getCanInsertSample me, tX, tY, tID 
  tLength = me.getSampleLength(tID)
  return(me.getIsFreeBlock(tX, tY, tLength))
end

on getIsFreeBlock me, tX, tY, tLength 
  if tLength <> 0 then
    if tX >= 1 and tX + tLength - 1 <= pSlotCount and tY >= 1 and tY <= pTimeLineData.count then
      tChannel = pTimeLineData.getAt(tY)
      i = tX
      repeat while i <= tX + tLength - 1
        if not voidp(tChannel.getAt(i)) then
          return(0)
        end if
        i = 1 + i
      end repeat
      i = tX - 1
      repeat while i >= 1
        if not voidp(tChannel.getAt(i)) then
          tNumber = tChannel.getAt(i)
          if i + me.getSampleLength(tNumber) - 1 >= tX then
            return(0)
          else
            return(1)
          end if
        end if
        i = 255 + i
      end repeat
      return(1)
    end if
  end if
  return(0)
end

on getSongData me 
  pSongLength = me.resolveSongLength()
  if pSongLength = 0 then
    return(0)
  end if
  tSongData = [#offset:0, #sounds:[]]
  tChannel = 1
  repeat while tChannel <= pTimeLineData.count
    tChannelData = pTimeLineData.getAt(tChannel)
    tEmpty = 1
    i = 1
    repeat while i <= pSongLength
      if not voidp(tChannelData.getAt(i)) then
        tEmpty = 0
      else
        i = 1 + i
      end if
    end repeat
    if not tEmpty then
      tSlot = 1
      repeat while tSlot <= pSongLength
        if not voidp(tChannelData.getAt(tSlot)) then
          tSampleID = tChannelData.getAt(tSlot)
          tSampleLength = me.getSampleLength(tSampleID)
          if tSampleLength <> 0 and tSampleID >= 0 then
            tCount = 0
            repeat while tChannelData.getAt(tSlot) = tSampleID
              tCount = tCount + 1
              tSlot = tSlot + tSampleLength
              if tSlot > pSongLength then
              else
              end if
            end repeat
            tSampleName = me.getSampleName(tSampleID)
            tSampleData = [#name:tSampleName, #loops:tCount, #channel:tChannel]
            tSongData.getAt(#sounds).setAt(tSongData.getAt(#sounds).count + 1, tSampleData)
          else
            tSampleName = me.getSampleName(0)
            tSampleData = [#name:tSampleName, #loops:1, #channel:tChannel]
            tSongData.getAt(#sounds).setAt(tSongData.getAt(#sounds).count + 1, tSampleData)
            tSlot = tSlot + 1
          end if
          next repeat
        end if
        tCount = 0
        repeat while voidp(tChannelData.getAt(tSlot))
          tCount = tCount + 1
          tSlot = tSlot + 1
          if tSlot > pSongLength then
          else
          end if
        end repeat
        tSampleName = me.getSampleName(0)
        tSampleData = [#name:tSampleName, #loops:tCount, #channel:tChannel]
        tSongData.getAt(#sounds).setAt(tSongData.getAt(#sounds).count + 1, tSampleData)
      end repeat
    end if
    tChannel = 1 + tChannel
  end repeat
  return(tSongData)
end

on getSilentSongData me 
  return([#offset:0, #sounds:[[#name:"sound_machine_sample_0", #loops:10, #channel:1]]])
end

on insertSample me, tSlot, tChannel, tID 
  tInsert = me.getCanInsertSample(tSlot, tChannel, tID)
  if tInsert then
    pChanged = 1
    pTimeLineData.getAt(tChannel).setAt(tSlot, tID)
    return(1)
  end if
  return(0)
end

on removeSample me, tSlot, tChannel 
  if tChannel >= 1 and tChannel <= pTimeLineData.count then
    if tSlot >= 1 and tSlot <= pTimeLineData.getAt(tChannel).count then
      if not voidp(pTimeLineData.getAt(tChannel).getAt(tSlot)) then
        if pTimeLineData.getAt(tChannel).getAt(tSlot) < 0 then
          return(0)
        end if
      else
        i = tSlot - 1
        repeat while i >= 1
          if not voidp(pTimeLineData.getAt(tChannel).getAt(i)) then
            tSampleID = pTimeLineData.getAt(tChannel).getAt(i)
            if tSampleID >= 0 then
              tSampleLength = me.getSampleLength(tSampleID)
              if tSampleLength <> 0 then
                if i + tSampleLength - 1 >= tSlot then
                  tSlot = i
                else
                  return(0)
                end if
              end if
            end if
          end if
          i = 255 + i
        end repeat
      end if
      pChanged = 1
      pTimeLineData.getAt(tChannel).setAt(tSlot, void())
      return(1)
    end if
  end if
  return(0)
end

on encodeTimeLineData me 
  if not pReady or not pDataReady then
    return(0)
  end if
  tStr = ""
  tSongLength = me.resolveSongLength()
  if tSongLength > 0 then
    i = 1
    repeat while i <= pTimeLineData.count
      tChannel = pTimeLineData.getAt(i)
      tStr = tStr & i & ":"
      j = 1
      tChannelData = []
      repeat while j <= tSongLength
        if voidp(tChannel.getAt(j)) then
          tSample = [#id:0, #length:1]
          j = j + 1
        else
          tSampleID = tChannel.getAt(j)
          tSampleLength = me.getSampleLength(tSampleID)
          if tSampleID < 0 then
            tSampleID = -tSampleID
          end if
          if tSampleLength = 0 then
            tSample = [#id:0, #length:1]
          else
            tSample = [#id:tSampleID, #length:tSampleLength]
          end if
          j = j + tSample.getAt(#length)
        end if
        tChannelData.setAt(tChannelData.count + 1, tSample)
      end repeat
      j = 1
      repeat while j < tChannelData.count
        if tChannelData.getAt(j).getAt(#id) = tChannelData.getAt(j + 1).getAt(#id) then
          tChannelData.getAt(j).setAt(#length, tChannelData.getAt(j).getAt(#length) + tChannelData.getAt(j + 1).getAt(#length))
          tChannelData.deleteAt(j + 1)
          next repeat
        end if
        j = j + 1
      end repeat
      tChannelStr = ""
      repeat while tChannelData <= undefined
        tSample = getAt(undefined, undefined)
        if tChannelStr <> "" then
          tChannelStr = tChannelStr & ";"
        end if
        tChannelStr = tChannelStr & tSample.getAt(#id) & "," & tSample.getAt(#length)
      end repeat
      tStr = tStr & tChannelStr & ":"
      i = 1 + i
    end repeat
  end if
  return(tStr)
end

on getSampleLength me, tSampleID 
  if tSampleID < 0 then
    return(1)
  end if
  tLength = 0
  tSampleName = me.getSampleName(tSampleID)
  tSongController = getObject(pSongControllerID)
  if tSongController <> 0 then
    tReady = tSongController.getSampleLoadingStatus(tSampleName)
    if not tReady then
      tDelim = the itemDelimiter
      the itemDelimiter = "_"
      tSampleno = tSampleName.getProp(#item, 4) - 1
      tSamplesPerSEt = 9
      tParentNo = integer(tSampleno) / tSamplesPerSEt + 1
      tParentId = "sound_set_" & tParentNo
      the itemDelimiter = tDelim
      tSongController.preloadSounds([[#sound:tSampleName, #parent:tParentId]])
    else
      tLength = tSongController.getSampleLength(tSampleName)
      tLength = tLength + pSlotDuration - 1 / pSlotDuration
    end if
  end if
  return(tLength)
end

on getSampleName me, tSampleID 
  tName = pSampleNameBase & tSampleID
  return(tName)
end

on getSampleSetID me, tSampleID 
  return(1 + tSampleID - 1 / 9)
end
