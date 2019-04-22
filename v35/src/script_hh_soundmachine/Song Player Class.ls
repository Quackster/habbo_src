on construct(me)
  pUpdateTimeout = "song player loop update"
  pQueueTimeout = "song queue timeout"
  pPlayTimeout = "song play timeout"
  pPreviewChannel = 5
  pSongChannels = [1, 2, 3, 4]
  pSongChannelsInUse = []
  pSilentSampleName = "sound_machine_sample_0"
  pPlaylistStack = []
  exit
end

on deconstruct(me)
  if timeoutExists(pUpdateTimeout) then
    removeTimeout(pUpdateTimeout)
  end if
  if timeoutExists(pQueueTimeout) then
    removeTimeout(pQueueTimeout)
  end if
  if timeoutExists(pPlayTimeout) then
    removeTimeout(pPlayTimeout)
  end if
  exit
end

on startSong(me, tStackIndex, tSongData, tLoop)
  tSongLength = me.getSongLength(tSongData)
  tOffset = 0
  if not voidp(tSongData.getAt(#offset)) then
    tOffset = tSongData.getAt(#offset) / 100
  end if
  tID = 1
  if not me.initPlaylist(tStackIndex, [[#length:tSongLength, #id:tID]], tOffset, tLoop) then
    return(0)
  end if
  return(me.updatePlaylistSong(tID, tSongData))
  exit
end

on stopSong(me, tStackIndex, tResetPlaylist)
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
    repeat while me <= tResetPlaylist
      tChannel = getAt(tResetPlaylist, tStackIndex)
      if tChannel >= 1 and tChannel <= pSongChannels.count then
        stopSoundChannel(pSongChannels.getAt(tChannel))
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
  return(1)
  exit
end

on initPlaylist(me, tStackIndex, tSongList, tPlayTime, tLoop)
  if ilk(tSongList) <> #list then
    return(error(me, "Invalid data", #initPlaylist, #major))
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
  repeat while me <= tSongList
    tSong = getAt(tSongList, tStackIndex)
    if ilk(tSong) <> #propList then
      tPlaylistInstance.setAt(#songList, [])
      return(error(me, "Invalid data", #initPlaylist, #major))
    end if
    if voidp(tSong.getAt(#length)) or voidp(tSong.getAt(#id)) then
      tPlaylistInstance.setAt(#songList, [])
      return(error(me, "Invalid data", #initPlaylist, #major))
    end if
    if not tLoop then
      tSongLength = tSong.getAt(#length) / 100
      if tPlayTime >= tSongLength then
        tPlayTime = tPlayTime - tSongLength
        tSong = void()
      end if
    end if
    if not voidp(tSong) then
      tPlaylistItem = tSong.duplicate()
      tPlaylistInstance.getAt(#songList).add(tPlaylistItem)
    end if
  end repeat
  tPlaylistInstance.setAt(#loop, tLoop)
  tPlaylistInstance.setAt(#playTime, tPlayTime)
  tPlaylistInstance.setAt(#initialPlayTime, the milliSeconds)
  return(1)
  exit
end

on addPlaylistSong(me, tStackIndex, tID, tLength)
  if voidp(tID) or voidp(tLength) then
    return(error(me, "Invalid data", #addPlaylistSong, #major))
  end if
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance <> 0 then
    if tPlaylistInstance.getAt(#loop) then
      return(error(me, "Looping playlist", #addPlaylistSong, #major))
    end if
  else
    tPlaylistInstance = me.createPlaylistInstance(tStackIndex)
    tPlaylistInstance.setAt(#loop, 0)
  end if
  me.removePlayedSongs(tStackIndex)
  tPlaylistItem = [#length:tLength, #id:tID]
  tPlaylistInstance.getAt(#songList).add(tPlaylistItem)
  if tPlaylistInstance.getAt(#songList).count = 1 then
    tPlaylistInstance.setAt(#playTime, 0)
    tPlaylistInstance.setAt(#initialPlayTime, the milliSeconds)
  end if
  return(1)
  exit
end

on updatePlaylistSong(me, tID, tSongData)
  tUpdated = 0
  tIndex = 1
  repeat while tIndex <= me.getPlaylistInstanceCount()
    tPlaylistInstance = me.getPlaylistInstance(tIndex, 1)
    if tPlaylistInstance = 0 then
      return(0)
    end if
    tSongList = tPlaylistInstance.getAt(#songList)
    i = 1
    repeat while i <= tSongList.count
      if tSongList.getAt(i).getAt(#id) = tID then
        if voidp(tSongList.getAt(i).getAt(#songData)) then
          tUpdated = 1
          tSongDataDuplicate = tSongData.duplicate()
          tSongList.getAt(i).setAt(#songData, tSongDataDuplicate)
          tLength = me.getSongLength(tSongDataDuplicate)
          if tLength <> tSongList.getAt(i).getAt(#length) and tPlaylistInstance.getAt(#loop) then
            me.stopSong(tIndex, 0)
            tSongList.getAt(i).setAt(#length, tLength)
          end if
        end if
      end if
      i = 1 + i
    end repeat
    tIndex = 1 + tIndex
  end repeat
  if tUpdated then
    me.checkLoopData()
  end if
  return(1)
  exit
end

on getPlaylistInstance(me, tStackIndex, tAbsoluteIndex)
  if voidp(tAbsoluteIndex) then
    tAbsoluteIndex = 0
  end if
  if not tAbsoluteIndex then
    tPlaylistInstance = pPlaylistStack.getaProp(tStackIndex)
    if tPlaylistInstance = 0 then
      return(0)
    end if
    return(tPlaylistInstance)
  else
    if tStackIndex < 1 or tStackIndex > pPlaylistStack.count then
      return(0)
    end if
    return(pPlaylistStack.getAt(tStackIndex))
  end if
  exit
end

on getPlaylistTopInstance(me)
  if pPlaylistStack.count = 0 then
    return(0)
  end if
  return(pPlaylistStack.getAt(pPlaylistStack.count))
  exit
end

on getIsTopInstance(me, tStackIndex)
  if pPlaylistStack.findPos(tStackIndex) = pPlaylistStack.count and pPlaylistStack.count > 0 then
    return(1)
  end if
  return(0)
  exit
end

on getTopInstanceIndex(me)
  if pPlaylistStack.count = 0 then
    return(0)
  end if
  return(pPlaylistStack.getPropAt(pPlaylistStack.count))
  exit
end

on removePlaylistInstance(me, tStackIndex)
  tPos = pPlaylistStack.findPos(tStackIndex)
  if tPos > 0 then
    pPlaylistStack.deleteAt(tPos)
    return(1)
  end if
  return(0)
  exit
end

on createPlaylistInstance(me, tStackIndex)
  tPos = pPlaylistStack.findPos(tStackIndex)
  if tPos = 0 then
    tPlaylistInstance = [#songList:[], #listIndex:1, #playTime:0, #initialPlayTime:0, #playOffset:0, #loop:1]
    pPlaylistStack.addProp(tStackIndex, tPlaylistInstance)
    pPlaylistStack.sort()
    return(tPlaylistInstance)
  end if
  return(pPlaylistStack.getAt(tPos))
  exit
end

on getPlaylistInstanceCount(me)
  return(pPlaylistStack.count)
  exit
end

on getSongData(me, tStackIndex, tIndex)
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance = 0 then
    return(0)
  end if
  if voidp(tIndex) then
    tIndex = tPlaylistInstance.getAt(#listIndex)
  end if
  tSongList = tPlaylistInstance.getAt(#songList)
  if tIndex < 1 or tIndex > tSongList.count then
    return(0)
  end if
  if voidp(tSongList.getAt(tIndex).getAt(#songData)) then
    return(0)
  end if
  return(tSongList.getAt(tIndex).getAt(#songData))
  exit
end

on getSongChannelList(me, tStackIndex)
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance = 0 then
    return([])
  end if
  if tPlaylistInstance.getAt(#songList).count = 1 then
    tSongData = me.getSongData(tStackIndex, 1)
    if tSongData <> 0 then
      if not voidp(tSongData.getAt(#channelList)) then
        return(tSongData.getAt(#channelList).duplicate())
      end if
    end if
  end if
  tChannels = []
  i = 1
  repeat while i <= pSongChannels.count
    tChannels.add(i)
    i = 1 + i
  end repeat
  return(tChannels)
  exit
end

on getSongLength(me, tSongData)
  if voidp(tSongData) or tSongData = 0 then
    return(-1)
  end if
  if voidp(tSongData.sounds) then
    return(-1)
  end if
  if not voidp(tSongData.getAt(#songLength)) then
    return(tSongData.getAt(#songLength))
  end if
  tPlayLengthList = []
  i = 1
  repeat while i <= pSongChannels.count
    tPlayLengthList.add(0)
    i = 1 + i
  end repeat
  i = 1
  repeat while i <= tSongData.count(#sounds)
    tSound = tSongData.getProp(#sounds, i)
    j = 1
    repeat while j <= tSound.loops
      tChannel = tSound.channel
      if tChannel >= 1 and tChannel <= pSongChannels.count then
        tmember = getMember(tSound.name)
        if tmember <> 0 then
          if tmember.type = #sound then
            tLength = tmember.duration
            tPlayLengthList.setAt(tChannel, tPlayLengthList.getAt(tChannel) + tLength)
          end if
        end if
      end if
      j = 1 + j
    end repeat
    i = 1 + i
  end repeat
  tPlayLength = tPlayLengthList.getAt(1)
  i = 2
  repeat while i <= tPlayLengthList.count
    if tPlayLengthList.getAt(i) > tPlayLength then
      tPlayLength = tPlayLengthList.getAt(i)
    end if
    i = 1 + i
  end repeat
  tSongData.setAt(#songLength, tPlayLength)
  return(tPlayLength)
  exit
end

on getPlaylistSongLength(me, tStackIndex, tIndex)
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance = 0 then
    return(-1)
  end if
  tSongList = tPlaylistInstance.getAt(#songList)
  if tIndex < 1 or tIndex > tSongList.count then
    return(-1)
  end if
  tSongData = me.getSongData(tStackIndex, tIndex)
  tLength = me.getSongLength(tSongData)
  if tLength < 0 then
    tLength = tSongList.getAt(tIndex).getAt(#length)
  end if
  if tLength < 0 then
    return(2000)
  end if
  return(tLength)
  exit
end

on getPlaylistLength(me, tStackIndex)
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance = 0 then
    return(0)
  end if
  tSongList = tPlaylistInstance.getAt(#songList)
  tPlaylistLength = 0
  i = 1
  repeat while i <= tSongList.count
    tLength = me.getPlaylistSongLength(tStackIndex, i)
    tPlaylistLength = tPlaylistLength + tLength
    i = 1 + i
  end repeat
  return(tPlaylistLength)
  exit
end

on getPlayTime(me, tStackIndex)
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance = 0 then
    return(0)
  end if
  return(tPlaylistInstance.getAt(#playTime) + the milliSeconds - tPlaylistInstance.getAt(#initialPlayTime) / 100)
  exit
end

on initializePlaying(me)
  if timeoutExists(pQueueTimeout) or timeoutExists(pPlayTimeout) then
    return(1)
  end if
  tStackIndex = me.getTopInstanceIndex()
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance = 0 then
    return(0)
  end if
  tSongList = tPlaylistInstance.getAt(#songList)
  if not tPlaylistInstance.getAt(#loop) then
    me.removePlayedSongs(tStackIndex)
    if tSongList.count = 0 then
      me.removePlaylistInstance(tStackIndex)
      return(me.initializePlaying())
    end if
  end if
  tPlaylistLength = me.getPlaylistLength(tStackIndex) / 100
  tPlayTime = me.getPlayTime(tStackIndex)
  tSyncDelta = 2000 / 100
  tExtraOffset = tSyncDelta - tPlayTime mod tSyncDelta mod tSyncDelta * 100
  tPlayTime = tPlayTime + tExtraOffset / 100
  tPlaylistInstance.setAt(#playOffset, 0)
  tPlaylistInstance.setAt(#listIndex, 1)
  if tPlaylistLength >= 1 then
    if not tPlaylistInstance.getAt(#loop) and tPlayTime >= tPlaylistLength then
      return(0)
    end if
    tPos = 0
    tOffset = tPlayTime mod tPlaylistLength
    i = 1
    repeat while i <= tPlaylistInstance.getAt(#songList).count
      tLength = me.getPlaylistSongLength(tStackIndex, i) / 100
      tPos = tPos + tLength
      if tPos > tOffset then
        tPlaylistInstance.setAt(#listIndex, i)
        tPlaylistInstance.setAt(#playOffset, tOffset - tPos - tLength * 100)
      else
        i = 1 + i
      end if
    end repeat
  end if
  if me.getSongData(tStackIndex) <> 0 then
    me.solveSongChannels(tStackIndex)
    me.reserveSongChannels()
    createTimeout(pQueueTimeout, 50 + tExtraOffset, #queueChannels, me.getID(), void(), 1)
  end if
  return(1)
  exit
end

on solveSongChannels(me, tStackIndex)
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance = 0 then
    return(0)
  end if
  tSongList = tPlaylistInstance.getAt(#songList)
  j = 1
  repeat while j <= tSongList.count
    tSongData = me.getSongData(tStackIndex, j)
    if tSongData <> 0 then
      if voidp(tSongData.getAt(#channelList)) then
        tSounds = tSongData.getaProp(#sounds)
        if not voidp(tSounds) then
          tChannels = []
          i = 1
          repeat while i <= tSounds.count
            tSound = tSounds.getAt(i)
            tChannel = tSound.channel
            if not tChannels.findPos(tChannel) then
              tChannels.add(tChannel)
            end if
            i = 1 + i
          end repeat
          tChannels.sort()
          if tSongList.count > 1 or not tPlaylistInstance.getAt(#loop) then
            tChannels = []
            i = 1
            repeat while i <= pSongChannels.count
              tChannels.add(i)
              i = 1 + i
            end repeat
          end if
          i = tSounds.count
          repeat while i >= 1
            tSound = tSounds.getAt(i)
            tChannel = tSound.channel
            tSound.channel = tChannels.findPos(tChannel)
            if tSound.channel = 0 then
              tSounds.deleteAt(i)
              error(me, "Invalid sound channel" && tChannel, #solveSongChannels, #major)
            end if
            i = 255 + i
          end repeat
          tChannelsFinal = []
          i = 1
          repeat while i <= tChannels.count
            tChannelsFinal.add(i)
            i = 1 + i
          end repeat
          tSongData.setAt(#channelList, tChannelsFinal)
        else
          error(me, "Song with no sounds" && tChannel, #solveSongChannels, #major)
        end if
      end if
    end if
    j = 1 + j
  end repeat
  exit
end

on reserveSongChannels(me)
  tStackIndex = me.getTopInstanceIndex()
  tChannelList = me.getSongChannelList(tStackIndex)
  pSongChannelsInUse = []
  repeat while me <= undefined
    tChannel = getAt(undefined, undefined)
    if tChannel >= 1 and tChannel <= pSongChannels.count then
      queueSound(pSilentSampleName, pSongChannels.getAt(tChannel))
      startSoundChannel(pSongChannels.getAt(tChannel))
      pSongChannelsInUse.add(tChannel)
    end if
  end repeat
  exit
end

on queueChannels(me)
  repeat while me <= undefined
    tChannel = getAt(undefined, undefined)
    if tChannel >= 1 and tChannel <= pSongChannels.count then
      stopSoundChannel(pSongChannels.getAt(tChannel))
    end if
  end repeat
  tPlayRoundsOnQueue = 2
  i = 1
  repeat while i <= tPlayRoundsOnQueue
    me.addPlayRound()
    i = 1 + i
  end repeat
  if timeoutExists(pPlayTimeout) then
    removeTimeout(pPlayTimeout)
  end if
  createTimeout(pPlayTimeout, 50, #startChannels, me.getID(), void(), 1)
  exit
end

on startChannels(me)
  i = pSongChannelsInUse.count
  repeat while i >= 1
    tChannel = pSongChannelsInUse.getAt(i)
    if tChannel >= 1 and tChannel <= pSongChannels.count then
      startSoundChannel(pSongChannels.getAt(tChannel))
    end if
    i = 255 + i
  end repeat
  if not timeoutExists(pUpdateTimeout) then
    createTimeout(pUpdateTimeout, 1500, #checkLoopData, me.getID(), void(), 0)
  end if
  exit
end

on addPlayRound(me)
  tStackIndex = me.getTopInstanceIndex()
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance = 0 then
    return(0)
  end if
  tSongList = tPlaylistInstance.getAt(#songList)
  if not tPlaylistInstance.getAt(#loop) then
    if tPlaylistInstance.getAt(#listIndex) > tSongList.count then
      return(1)
    end if
  end if
  tSongData = me.getSongData(tStackIndex)
  if tSongData = 0 or tSongList.count = 0 then
    return(1)
  else
    if not tPlaylistInstance.getAt(#loop) then
      tPlaylistInstance.setAt(#listIndex, tPlaylistInstance.getAt(#listIndex) + 1)
    else
      tPlaylistInstance.setAt(#listIndex, 1 + tPlaylistInstance.getAt(#listIndex) mod tSongList.count)
    end if
  end if
  if tSongData.getaProp(#sounds) = void() then
    return(1)
  end if
  tOffset = tPlaylistInstance.getAt(#playOffset)
  tPlayLengthList = []
  tOffsetList = []
  i = 1
  repeat while i <= pSongChannels.count
    tOffsetList.add(tOffset)
    tPlayLengthList.add(0)
    i = 1 + i
  end repeat
  i = 1
  repeat while i <= tSongData.count(#sounds)
    tSound = tSongData.getProp(#sounds, i)
    j = 1
    repeat while j <= tSound.loops
      tChannel = tSound.channel
      if tChannel >= 1 and tChannel <= pSongChannels.count then
        tmember = getMember(tSound.name)
        if tmember <> 0 then
          if tmember.type = #sound then
            tLength = tmember.duration
            if tOffsetList.getAt(tChannel) > 0 then
              if tLength > tOffsetList.getAt(tChannel) then
                queueSound(tSound.name, pSongChannels.getAt(tChannel), [#startTime:tOffsetList.getAt(tChannel)])
                tPlayLengthList.setAt(tChannel, tPlayLengthList.getAt(tChannel) + tLength - tOffsetList.getAt(tChannel))
              end if
              tOffsetList.setAt(tChannel, max(0, tOffsetList.getAt(tChannel) - tLength))
            else
              queueSound(tSound.name, pSongChannels.getAt(tChannel))
              tPlayLengthList.setAt(tChannel, tPlayLengthList.getAt(tChannel) + tLength)
            end if
          end if
        end if
      end if
      j = 1 + j
    end repeat
    i = 1 + i
  end repeat
  tPlaylistInstance.setAt(#playOffset, 0)
  if tSongList.count < 2 and tPlaylistInstance.getAt(#loop) then
    return(1)
  end if
  tPlayLength = tPlayLengthList.getAt(1)
  i = 2
  repeat while i <= tPlayLengthList.count
    if tPlayLengthList.getAt(i) > tPlayLength then
      tPlayLength = tPlayLengthList.getAt(i)
    end if
    i = 1 + i
  end repeat
  tmember = getMember(pSilentSampleName)
  if tmember <> 0 then
    if tmember.type = #sound then
      tLength = tmember.duration
      if tLength > 0 then
        tChannel = 1
        repeat while tChannel <= tPlayLengthList.count
          tDelta = tPlayLength - tPlayLengthList.getAt(tChannel)
          repeat while tDelta > 0
            if tDelta >= tLength then
              queueSound(pSilentSampleName, pSongChannels.getAt(tChannel))
            else
              queueSound(pSilentSampleName, pSongChannels.getAt(tChannel), [#startTime:tLength - tDelta])
            end if
            tDelta = tDelta - tLength
          end repeat
          tChannel = 1 + tChannel
        end repeat
      end if
    end if
  end if
  return(1)
  exit
end

on getPlayBufferLength(me)
  tStackIndex = me.getTopInstanceIndex()
  tChannelList = me.getSongChannelList(tStackIndex)
  if tChannelList.count < 1 then
    return(-1)
  end if
  tChannel = tChannelList.getAt(1)
  if tChannel < 1 or tChannel > pSongChannels.count then
    return(-1)
  end if
  tSoundChannel = sound(pSongChannels.getAt(tChannel))
  if ilk(tSoundChannel) <> #instance then
    error(me, "Sound channel bug:" && pSongChannels.getAt(tChannel), #getPlayBufferLength, #major)
    return(-1)
  end if
  tLength = tSoundChannel.endTime - tSoundChannel.startTime
  tPlayList = tSoundChannel.getPlaylist()
  i = 1
  repeat while i <= tPlayList.count
    tLength = tLength + undefined.duration
    i = 1 + i
  end repeat
  return(tLength)
  exit
end

on checkLoopData(me)
  if timeoutExists(pQueueTimeout) or timeoutExists(pPlayTimeout) then
    return(1)
  end if
  tLength = me.getPlayBufferLength()
  if tLength <= 0 then
    return(me.initializePlaying())
  end if
  the getSoundSetListID = tLength.max
  if ERROR then
    me.addPlayRound()
  end if
  return(1)
  exit
end

on removePlayedSongs(me, tStackIndex)
  tPlaylistInstance = me.getPlaylistInstance(tStackIndex)
  if tPlaylistInstance <> 0 then
    tSongList = tPlaylistInstance.getAt(#songList)
    if not tPlaylistInstance.getAt(#loop) then
      tCount = min(tPlaylistInstance.getAt(#listIndex), tSongList.count)
      i = 1
      repeat while i <= tCount
        if me.getPlayTime(tStackIndex) < tSongList.getAt(1).getAt(#length) / 100 then
        else
          tPlaylistInstance.setAt(#playTime, tPlaylistInstance.getAt(#playTime) - tSongList.getAt(1).getAt(#length) / 100)
          tSongList.deleteAt(1)
          tPlaylistInstance.setAt(#listIndex, tPlaylistInstance.getAt(#listIndex) - 1)
          i = 1 + i
        end if
      end repeat
    end if
  end if
  exit
end

on startSamplePreview(me, tParams)
  tSuccess = playSoundInChannel(tParams.name, pPreviewChannel)
  if not tSuccess then
    return(error(me, "Sound could not be started", #startSamplePreview, #minor))
  end if
  return(1)
  exit
end

on stopSamplePreview(me)
  tSuccess = stopSoundChannel(pPreviewChannel)
  if not tSuccess then
    return(error(me, "Sound could not be stopped", #stopSamplePreview, #minor))
  end if
  return(1)
  exit
end