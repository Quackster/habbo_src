property pUpdateTimeout, pQueueTimeout, pPlayTimeout, pPreviewChannel, pSongChannels, pSongChannelsInUse, pPlaylistStack, pSilentSampleName

on construct me
  pUpdateTimeout = "song player loop update"
  pQueueTimeout = "song queue timeout"
  pPlayTimeout = "song play timeout"
  pPreviewChannel = 5
  pSongChannels = [1, 2, 3, 4]
  pSongChannelsInUse = []
  pSilentSampleName = "sound_machine_sample_0"
  pPlaylistStack = [:]
end

on deconstruct me
  if timeoutExists(pUpdateTimeout) then
    removeTimeout(pUpdateTimeout)
  end if
  if timeoutExists(pQueueTimeout) then
    removeTimeout(pQueueTimeout)
  end if
  if timeoutExists(pPlayTimeout) then
    removeTimeout(pPlayTimeout)
  end if
end

on startSong me, tStackIndex, tSongData, tLoop
  tSongLength = me.getSongLength(tSongData)
  tOffset = 0
  if not voidp(tSongData[#offset]) then
    tOffset = tSongData[#offset] / 100
  end if
  tid = 1
  if not me.initPlaylist(tStackIndex, [[#length: tSongLength, #id: tid]], tOffset, tLoop) then
    return 0
  end if
  return me.updatePlaylistSong(tid, tSongData)
end

on stopSong me, tStackIndex, tResetPlaylist
  if me.getIsTopInstance(tStackIndex) then
    if timeoutExists(pQueueTimeout) then
      removeTimeout(pQueueTimeout)
    end if
    if timeoutExists(pPlayTimeout) then
      removeTimeout(pPlayTimeout)
    end if
    if timeoutExists(pUpdateTimeout) then
      removeTimeout(pUpdateTimeout)
    end if
    repeat with tChannel in pSongChannelsInUse
      if (tChannel >= 1) and (tChannel <= pSongChannels.count) then
        stopSoundChannel(pSongChannels[tChannel])
      end if
    end repeat
    pSongChannelsInUse = []
    if tResetPlaylist then
      me.removePlaylistInstance(tStackIndex)
      me.checkLoopData()
    end if
  else
    if tResetPlaylist then
      me.removePlaylistInstance(tStackIndex)
    end if
  end if
  return 1
end

on initPlaylist me, tStackIndex, tSongList, tPlayTime, tLoop
  if ilk(tSongList) <> #list then
    return error(me, "Invalid data", #initPlaylist, #major)
  end if
  tTopIndex = me.getTopInstanceIndex()
  if tTopIndex <= tStackIndex then
    me.stopSong(tTopIndex, 0)
  end if
  if voidp(tLoop) then
    tLoop = 1
  end if
  me.removePlaylistInstance(tStackIndex)
  tPlaylistInstance = me.createPlaylistInstance(tStackIndex)
  repeat with tSong in tSongList
    if ilk(tSong) <> #propList then
      tPlaylistInstance[#songList] = []
      return error(me, "Invalid data", #initPlaylist, #major)
    end if
    if voidp(tSong[#length]) or voidp(tSong[#id]) then
      tPlaylistInstance[#songList] = []
      return error(me, "Invalid data", #initPlaylist, #major)
    end if
    if not tLoop then
      tSongLength = tSong[#length] / 100
      if tPlayTime >= tSongLength then
        tPlayTime = tPlayTime - tSongLength
        tSong = VOID
      end if
    end if
    if not voidp(tSong) then
      tPlaylistItem = tSong.duplicate()
      tPlaylistInstance[#songList].add(tPlaylistItem)
    end if
  end repeat
  tPlaylistInstance[#loop] = tLoop
  tPlaylistInstance[#playTime] = tPlayTime
  tPlaylistInstance[#initialPlayTime] = the milliSeconds
  return 1
end

on addPlaylistSong me, tStackIndex, tid, tLength
  if voidp(tid) or voidp(tLength) then
    return error(me, "Invalid data", #addPlaylistSong, #major)
  end if
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance <> 0 then
    if tPlaylistInstance[#loop] then
      return error(me, "Looping playlist", #addPlaylistSong, #major)
    end if
  else
    tPlaylistInstance = me.createPlaylistInstance(tStackIndex)
    tPlaylistInstance[#loop] = 0
  end if
  me.removePlayedSongs(tStackIndex)
  tPlaylistItem = [#length: tLength, #id: tid]
  tPlaylistInstance[#songList].add(tPlaylistItem)
  if tPlaylistInstance[#songList].count = 1 then
    tPlaylistInstance[#playTime] = 0
    tPlaylistInstance[#initialPlayTime] = the milliSeconds
  end if
  return 1
end

on updatePlaylistSong me, tid, tSongData
  tUpdated = 0
  repeat with tIndex = 1 to me.getPlaylistInstanceCount()
    tPlaylistInstance = me.getPlaylistInstance(tIndex, 1)
    if tPlaylistInstance = 0 then
      return 0
    end if
    tSongList = tPlaylistInstance[#songList]
    repeat with i = 1 to tSongList.count
      if tSongList[i][#id] = tid then
        if voidp(tSongList[i][#songData]) then
          tUpdated = 1
          tSongDataDuplicate = tSongData.duplicate()
          tSongList[i][#songData] = tSongDataDuplicate
          tLength = me.getSongLength(tSongDataDuplicate)
          if (tLength <> tSongList[i][#length]) and tPlaylistInstance[#loop] then
            me.stopSong(tIndex, 0)
            tSongList[i][#length] = tLength
          end if
        end if
      end if
    end repeat
  end repeat
  if tUpdated then
    me.checkLoopData()
  end if
  return 1
end

on getPlaylistInstance me, tStackIndex, tAbsoluteIndex
  if voidp(tAbsoluteIndex) then
    tAbsoluteIndex = 0
  end if
  if not tAbsoluteIndex then
    tPlaylistInstance = pPlaylistStack.getaProp(tStackIndex)
    if tPlaylistInstance = 0 then
      return 0
    end if
    return tPlaylistInstance
  else
    if (tStackIndex < 1) or (tStackIndex > pPlaylistStack.count) then
      return 0
    end if
    return pPlaylistStack[tStackIndex]
  end if
end

on getPlaylistTopInstance me
  if pPlaylistStack.count = 0 then
    return 0
  end if
  return pPlaylistStack[pPlaylistStack.count]
end

on getIsTopInstance me, tStackIndex
  if (pPlaylistStack.findPos(tStackIndex) = pPlaylistStack.count) and (pPlaylistStack.count > 0) then
    return 1
  end if
  return 0
end

on getTopInstanceIndex me
  if pPlaylistStack.count = 0 then
    return 0
  end if
  return pPlaylistStack.getPropAt(pPlaylistStack.count)
end

on removePlaylistInstance me, tStackIndex
  tPos = pPlaylistStack.findPos(tStackIndex)
  if tPos > 0 then
    pPlaylistStack.deleteAt(tPos)
    return 1
  end if
  return 0
end

on createPlaylistInstance me, tStackIndex
  tPos = pPlaylistStack.findPos(tStackIndex)
  if tPos = 0 then
    tPlaylistInstance = [#songList: [], #listIndex: 1, #playTime: 0, #initialPlayTime: 0, #playOffset: 0, #loop: 1]
    pPlaylistStack.addProp(tStackIndex, tPlaylistInstance)
    pPlaylistStack.sort()
    return tPlaylistInstance
  end if
  return pPlaylistStack[tPos]
end

on getPlaylistInstanceCount me
  return pPlaylistStack.count
end

on getSongData me, tStackIndex, tIndex
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance = 0 then
    return 0
  end if
  if voidp(tIndex) then
    tIndex = tPlaylistInstance[#listIndex]
  end if
  tSongList = tPlaylistInstance[#songList]
  if (tIndex < 1) or (tIndex > tSongList.count) then
    return 0
  end if
  if voidp(tSongList[tIndex][#songData]) then
    return 0
  end if
  return tSongList[tIndex][#songData]
end

on getSongChannelList me, tStackIndex
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance = 0 then
    return []
  end if
  if tPlaylistInstance[#songList].count = 1 then
    tSongData = me.getSongData(tStackIndex, 1)
    if tSongData <> 0 then
      if not voidp(tSongData[#channelList]) then
        return tSongData[#channelList].duplicate()
      end if
    end if
  end if
  tChannels = []
  repeat with i = 1 to pSongChannels.count
    tChannels.add(i)
  end repeat
  return tChannels
end

on getSongLength me, tSongData
  if voidp(tSongData) or (tSongData = 0) then
    return -1
  end if
  if voidp(tSongData.sounds) then
    return -1
  end if
  if not voidp(tSongData[#songLength]) then
    return tSongData[#songLength]
  end if
  tPlayLengthList = []
  repeat with i = 1 to pSongChannels.count
    tPlayLengthList.add(0)
  end repeat
  repeat with i = 1 to tSongData.sounds.count
    tSound = tSongData.sounds[i]
    repeat with j = 1 to tSound.loops
      tChannel = tSound.channel
      if (tChannel >= 1) and (tChannel <= pSongChannels.count) then
        tmember = getMember(tSound.name)
        if tmember <> 0 then
          if tmember.type = #sound then
            tLength = tmember.duration
            tPlayLengthList[tChannel] = tPlayLengthList[tChannel] + tLength
          end if
        end if
      end if
    end repeat
  end repeat
  tPlayLength = tPlayLengthList[1]
  repeat with i = 2 to tPlayLengthList.count
    if tPlayLengthList[i] > tPlayLength then
      tPlayLength = tPlayLengthList[i]
    end if
  end repeat
  tSongData[#songLength] = tPlayLength
  return tPlayLength
end

on getPlaylistSongLength me, tStackIndex, tIndex
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance = 0 then
    return -1
  end if
  tSongList = tPlaylistInstance[#songList]
  if (tIndex < 1) or (tIndex > tSongList.count) then
    return -1
  end if
  tSongData = me.getSongData(tStackIndex, tIndex)
  tLength = me.getSongLength(tSongData)
  if tLength < 0 then
    tLength = tSongList[tIndex][#length]
  end if
  if tLength < 0 then
    return 2000
  end if
  return tLength
end

on getPlaylistLength me, tStackIndex
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance = 0 then
    return 0
  end if
  tSongList = tPlaylistInstance[#songList]
  tPlaylistLength = 0
  repeat with i = 1 to tSongList.count
    tLength = me.getPlaylistSongLength(tStackIndex, i)
    tPlaylistLength = tPlaylistLength + tLength
  end repeat
  return tPlaylistLength
end

on getPlayTime me, tStackIndex
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance = 0 then
    return 0
  end if
  return tPlaylistInstance[#playTime] + ((the milliSeconds - tPlaylistInstance[#initialPlayTime]) / 100)
end

on initializePlaying me
  if timeoutExists(pQueueTimeout) or timeoutExists(pPlayTimeout) then
    return 1
  end if
  tStackIndex = me.getTopInstanceIndex()
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance = 0 then
    return 0
  end if
  tSongList = tPlaylistInstance[#songList]
  if not tPlaylistInstance[#loop] then
    me.removePlayedSongs(tStackIndex)
    if tSongList.count = 0 then
      me.removePlaylistInstance(tStackIndex)
      return me.initializePlaying()
    end if
  end if
  tPlaylistLength = me.getPlaylistLength(tStackIndex) / 100
  tPlayTime = me.getPlayTime(tStackIndex)
  tSyncDelta = 2000 / 100
  tExtraOffset = (tSyncDelta - (tPlayTime mod tSyncDelta)) mod tSyncDelta * 100
  tPlayTime = tPlayTime + (tExtraOffset / 100)
  tPlaylistInstance[#playOffset] = 0
  tPlaylistInstance[#listIndex] = 1
  if tPlaylistLength >= 1 then
    if not tPlaylistInstance[#loop] and (tPlayTime >= tPlaylistLength) then
      return 0
    end if
    tPos = 0
    tOffset = tPlayTime mod tPlaylistLength
    repeat with i = 1 to tPlaylistInstance[#songList].count
      tLength = me.getPlaylistSongLength(tStackIndex, i) / 100
      tPos = tPos + tLength
      if tPos > tOffset then
        tPlaylistInstance[#listIndex] = i
        tPlaylistInstance[#playOffset] = (tOffset - (tPos - tLength)) * 100
        exit repeat
      end if
    end repeat
  end if
  if me.getSongData(tStackIndex) <> 0 then
    me.solveSongChannels(tStackIndex)
    me.reserveSongChannels()
    createTimeout(pQueueTimeout, 50 + tExtraOffset, #queueChannels, me.getID(), VOID, 1)
  end if
  return 1
end

on solveSongChannels me, tStackIndex
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance = 0 then
    return 0
  end if
  tSongList = tPlaylistInstance[#songList]
  repeat with j = 1 to tSongList.count
    tSongData = me.getSongData(tStackIndex, j)
    if tSongData <> 0 then
      if voidp(tSongData[#channelList]) then
        tSounds = tSongData.getaProp(#sounds)
        if not voidp(tSounds) then
          tChannels = []
          repeat with i = 1 to tSounds.count
            tSound = tSounds[i]
            tChannel = tSound.channel
            if not tChannels.findPos(tChannel) then
              tChannels.add(tChannel)
            end if
          end repeat
          tChannels.sort()
          if (tSongList.count > 1) or not tPlaylistInstance[#loop] then
            tChannels = []
            repeat with i = 1 to pSongChannels.count
              tChannels.add(i)
            end repeat
          end if
          repeat with i = tSounds.count down to 1
            tSound = tSounds[i]
            tChannel = tSound.channel
            tSound.channel = tChannels.findPos(tChannel)
            if tSound.channel = 0 then
              tSounds.deleteAt(i)
              error(me, "Invalid sound channel" && tChannel, #solveSongChannels, #major)
            end if
          end repeat
          tChannelsFinal = []
          repeat with i = 1 to tChannels.count
            tChannelsFinal.add(i)
          end repeat
          tSongData[#channelList] = tChannelsFinal
          next repeat
        end if
        error(me, "Song with no sounds" && tChannel, #solveSongChannels, #major)
      end if
    end if
  end repeat
end

on reserveSongChannels me
  tStackIndex = me.getTopInstanceIndex()
  tChannelList = me.getSongChannelList(tStackIndex)
  pSongChannelsInUse = []
  repeat with tChannel in tChannelList
    if (tChannel >= 1) and (tChannel <= pSongChannels.count) then
      queueSound(pSilentSampleName, pSongChannels[tChannel])
      startSoundChannel(pSongChannels[tChannel])
      pSongChannelsInUse.add(tChannel)
    end if
  end repeat
end

on queueChannels me
  repeat with tChannel in pSongChannelsInUse
    if (tChannel >= 1) and (tChannel <= pSongChannels.count) then
      stopSoundChannel(pSongChannels[tChannel])
    end if
  end repeat
  tPlayRoundsOnQueue = 2
  repeat with i = 1 to tPlayRoundsOnQueue
    me.addPlayRound()
  end repeat
  if timeoutExists(pPlayTimeout) then
    removeTimeout(pPlayTimeout)
  end if
  createTimeout(pPlayTimeout, 50, #startChannels, me.getID(), VOID, 1)
end

on startChannels me
  repeat with i = pSongChannelsInUse.count down to 1
    tChannel = pSongChannelsInUse[i]
    if (tChannel >= 1) and (tChannel <= pSongChannels.count) then
      startSoundChannel(pSongChannels[tChannel])
    end if
  end repeat
  if not timeoutExists(pUpdateTimeout) then
    createTimeout(pUpdateTimeout, 1500, #checkLoopData, me.getID(), VOID, 0)
  end if
end

on addPlayRound me
  tStackIndex = me.getTopInstanceIndex()
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance = 0 then
    return 0
  end if
  tSongList = tPlaylistInstance[#songList]
  if not tPlaylistInstance[#loop] then
    if tPlaylistInstance[#listIndex] > tSongList.count then
      return 1
    end if
  end if
  tSongData = me.getSongData(tStackIndex)
  if (tSongData = 0) or (tSongList.count = 0) then
    return 1
  else
    if not tPlaylistInstance[#loop] then
      tPlaylistInstance[#listIndex] = tPlaylistInstance[#listIndex] + 1
    else
      tPlaylistInstance[#listIndex] = 1 + (tPlaylistInstance[#listIndex] mod tSongList.count)
    end if
  end if
  if tSongData.getaProp(#sounds) = VOID then
    return 1
  end if
  tOffset = tPlaylistInstance[#playOffset]
  tPlayLengthList = []
  tOffsetList = []
  repeat with i = 1 to pSongChannels.count
    tOffsetList.add(tOffset)
    tPlayLengthList.add(0)
  end repeat
  repeat with i = 1 to tSongData.sounds.count
    tSound = tSongData.sounds[i]
    repeat with j = 1 to tSound.loops
      tChannel = tSound.channel
      if (tChannel >= 1) and (tChannel <= pSongChannels.count) then
        tmember = getMember(tSound.name)
        if tmember <> 0 then
          if tmember.type = #sound then
            tLength = tmember.duration
            if tOffsetList[tChannel] > 0 then
              if tLength > tOffsetList[tChannel] then
                queueSound(tSound.name, pSongChannels[tChannel], [#startTime: tOffsetList[tChannel]])
                tPlayLengthList[tChannel] = tPlayLengthList[tChannel] + (tLength - tOffsetList[tChannel])
              end if
              tOffsetList[tChannel] = max(0, tOffsetList[tChannel] - tLength)
              next repeat
            end if
            queueSound(tSound.name, pSongChannels[tChannel])
            tPlayLengthList[tChannel] = tPlayLengthList[tChannel] + tLength
          end if
        end if
      end if
    end repeat
  end repeat
  tPlaylistInstance[#playOffset] = 0
  if (tSongList.count < 2) and tPlaylistInstance[#loop] then
    return 1
  end if
  tPlayLength = tPlayLengthList[1]
  repeat with i = 2 to tPlayLengthList.count
    if tPlayLengthList[i] > tPlayLength then
      tPlayLength = tPlayLengthList[i]
    end if
  end repeat
  tmember = getMember(pSilentSampleName)
  if tmember <> 0 then
    if tmember.type = #sound then
      tLength = tmember.duration
      if tLength > 0 then
        repeat with tChannel = 1 to tPlayLengthList.count
          tDelta = tPlayLength - tPlayLengthList[tChannel]
          repeat while tDelta > 0
            if tDelta >= tLength then
              queueSound(pSilentSampleName, pSongChannels[tChannel])
            else
              queueSound(pSilentSampleName, pSongChannels[tChannel], [#startTime: tLength - tDelta])
            end if
            tDelta = tDelta - tLength
          end repeat
        end repeat
      end if
    end if
  end if
  return 1
end

on getPlayBufferLength me
  tStackIndex = me.getTopInstanceIndex()
  tChannelList = me.getSongChannelList(tStackIndex)
  if tChannelList.count < 1 then
    return -1
  end if
  tChannel = tChannelList[1]
  if (tChannel < 1) or (tChannel > pSongChannels.count) then
    return -1
  end if
  tSoundChannel = sound(pSongChannels[tChannel])
  if ilk(tSoundChannel) <> #instance then
    error(me, "Sound channel bug:" && pSongChannels[tChannel], #getPlayBufferLength, #major)
    return -1
  end if
  tLength = tSoundChannel.endTime - tSoundChannel.startTime
  tPlayList = tSoundChannel.getPlaylist()
  repeat with i = 1 to tPlayList.count
    tLength = tLength + tPlayList[i].member.duration
  end repeat
  return tLength
end

on checkLoopData me
  if timeoutExists(pQueueTimeout) or timeoutExists(pPlayTimeout) then
    return 1
  end if
  tLength = me.getPlayBufferLength()
  if tLength <= 0 then
    return me.initializePlaying()
  end if
  if tLength < 60000 then
    me.addPlayRound()
  end if
  return 1
end

on removePlayedSongs me, tStackIndex
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance <> 0 then
    tSongList = tPlaylistInstance[#songList]
    if not tPlaylistInstance[#loop] then
      tCount = min(tPlaylistInstance[#listIndex], tSongList.count)
      repeat with i = 1 to tCount
        if me.getPlayTime(tStackIndex) < (tSongList[1][#length] / 100) then
          exit repeat
        end if
        tPlaylistInstance[#playTime] = tPlaylistInstance[#playTime] - (tSongList[1][#length] / 100)
        tSongList.deleteAt(1)
        tPlaylistInstance[#listIndex] = tPlaylistInstance[#listIndex] - 1
      end repeat
    end if
  end if
end

on startSamplePreview me, tParams
  tSuccess = playSoundInChannel(tParams.name, pPreviewChannel)
  if not tSuccess then
    return error(me, "Sound could not be started", #startSamplePreview, #minor)
  end if
  return 1
end

on stopSamplePreview me
  tSuccess = stopSoundChannel(pPreviewChannel)
  if not tSuccess then
    return error(me, "Sound could not be stopped", #stopSamplePreview, #minor)
  end if
  return 1
end
