property pUpdateTimeout, pQueueTimeout, pPlayTimeout, pPreviewChannel, pSongChannels, pPlaylist, pPlaylistIndex, pSilentSampleName, pPlayTime, pInitialPlaylistTime, pPlayOffset, pLoop

on construct me
  pUpdateTimeout = "song player loop update"
  pQueueTimeout = "song queue timeout"
  pPlayTimeout = "song play timeout"
  pPreviewChannel = 5
  pSongChannels = [1, 2, 3, 4]
  pPlaylist = []
  pPlaylistIndex = 1
  pSilentSampleName = "sound_machine_sample_0"
  pPlayTime = 0
  pInitialPlaylistTime = 0
  pPlayOffset = 0
  pLoop = 1
end

on deconstruct me
  if timeoutExists(pUpdateTimeout) then
    removeTimeout(pUpdateTimeout)
  end if
end

on startSong me, tSongData, tLoop
  tSongLength = me.getSongLength(tSongData)
  tOffset = 0
  if not voidp(tSongData[#offset]) then
    tOffset = tSongData[#offset] / 100
  end if
  pPlaylist = []
  tid = 1
  if not me.initPlaylist([[#length: tSongLength, #id: tid]], tOffset, tLoop) then
    return 0
  end if
  return me.updatePlaylistSong(tid, tSongData)
end

on stopSong me
  if timeoutExists(pQueueTimeout) then
    removeTimeout(pQueueTimeout)
  end if
  if timeoutExists(pPlayTimeout) then
    removeTimeout(pPlayTimeout)
  end if
  tChannelList = me.getSongChannelList()
  repeat with tChannel in tChannelList
    if (tChannel >= 1) and (tChannel <= pSongChannels.count) then
      stopSoundChannel(pSongChannels[tChannel])
    end if
  end repeat
  if timeoutExists(pUpdateTimeout) then
    removeTimeout(pUpdateTimeout)
  end if
  return 1
end

on initPlaylist me, tSongList, tPlayTime, tLoop
  if ilk(tSongList) <> #list then
    return error(me, "Invalid data", #initPlaylist, #major)
  end if
  me.stopSong()
  pPlaylist = []
  pPlaylistIndex = 1
  if voidp(tLoop) then
    tLoop = 1
  end if
  repeat with tSong in tSongList
    if ilk(tSong) <> #propList then
      pPlaylist = []
      return error(me, "Invalid data", #initPlaylist, #major)
    end if
    if voidp(tSong[#length]) or voidp(tSong[#id]) then
      pPlaylist = []
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
      pPlaylist.add(tPlaylistItem)
    end if
  end repeat
  pLoop = tLoop
  pPlayTime = tPlayTime
  pInitialPlaylistTime = the milliSeconds
  return 1
end

on addPlaylistSong me, tid, tLength
  if voidp(tid) or voidp(tLength) then
    return error(me, "Invalid data", #addPlaylistSong, #major)
  end if
  if pLoop then
    return error(me, "Looping playlist", #addPlaylistSong, #major)
  end if
  tPlaylistItem = [#length: tLength, #id: tid]
  pPlaylist.add(tPlaylistItem)
  return 1
end

on updatePlaylistSong me, tid, tSongData
  repeat with i = 1 to pPlaylist.count
    if pPlaylist[i][#id] = tid then
      if voidp(pPlaylist[i][#songData]) then
        tSongDataDuplicate = tSongData.duplicate()
        pPlaylist[i][#songData] = tSongDataDuplicate
        tLength = me.getSongLength(tSongDataDuplicate)
        if tLength <> pPlaylist[i][#length] then
          me.stopSong()
          pPlaylist[i][#length] = tLength
        end if
      end if
    end if
  end repeat
  me.checkLoopData()
  return 1
end

on getSongData me, tIndex
  if voidp(tIndex) then
    tIndex = pPlaylistIndex
  end if
  if (tIndex < 1) or (tIndex > pPlaylist.count) then
    return 0
  end if
  if voidp(pPlaylist[tIndex][#songData]) then
    return 0
  end if
  return pPlaylist[tIndex][#songData]
end

on getSongChannelList me
  if pPlaylist.count = 1 then
    tSongData = me.getSongData(1)
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

on getPlaylistSongLength me, tIndex
  if (tIndex < 1) or (tIndex > pPlaylist.count) then
    return -1
  end if
  tSongData = me.getSongData(tIndex)
  tLength = me.getSongLength(tSongData)
  if tLength < 0 then
    tLength = pPlaylist[tIndex][#length]
  end if
  if tLength < 0 then
    return 2000
  end if
  return tLength
end

on getPlaylistLength me
  tPlaylistLength = 0
  repeat with i = 1 to pPlaylist.count
    tLength = me.getPlaylistSongLength(i)
    tPlaylistLength = tPlaylistLength + tLength
  end repeat
  return tPlaylistLength
end

on getPlayTime me
  return pPlayTime + ((the milliSeconds - pInitialPlaylistTime) / 100)
end

on initializePlaying me
  tPlaylistLength = me.getPlaylistLength() / 100
  tPlayTime = me.getPlayTime()
  pPlayOffset = 0
  pPlaylistIndex = 1
  if tPlaylistLength >= 1 then
    if not pLoop and (tPlayTime >= tPlaylistLength) then
      return 0
    end if
    tPos = 0
    tOffset = tPlayTime mod tPlaylistLength
    repeat with i = 1 to pPlaylist.count
      tLength = me.getPlaylistSongLength(i) / 100
      tPos = tPos + tLength
      if tPos > tOffset then
        pPlaylistIndex = i
        pPlayOffset = (tOffset - (tPos - tLength)) * 100
        exit repeat
      end if
    end repeat
  end if
  if not timeoutExists(pQueueTimeout) then
    if me.getSongData() <> 0 then
      me.processSongData()
      me.reserveSongChannels()
      createTimeout(pQueueTimeout, 50, #queueChannels, me.getID(), VOID, 1)
    end if
  end if
  if not timeoutExists(pUpdateTimeout) then
    createTimeout(pUpdateTimeout, 1500, #checkLoopData, me.getID(), VOID, 0)
  end if
  return 1
end

on processSongData me
  repeat with j = 1 to pPlaylist.count
    tSongData = me.getSongData(j)
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
          if (pPlaylist.count > 1) or not pLoop then
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
              error(me, "Invalid sound channel" && tChannel, #processSongData, #major)
            end if
          end repeat
          tChannelsFinal = []
          repeat with i = 1 to tChannels.count
            tChannelsFinal.add(i)
          end repeat
          tSongData[#channelList] = tChannelsFinal
          next repeat
        end if
        error(me, "Song with no sounds" && tChannel, #processSongData, #major)
      end if
    end if
  end repeat
end

on reserveSongChannels me
  tChannelList = me.getSongChannelList()
  repeat with tChannel in tChannelList
    if (tChannel >= 1) and (tChannel <= pSongChannels.count) then
      queueSound(pSilentSampleName, pSongChannels[tChannel])
      startSoundChannel(pSongChannels[tChannel])
    end if
  end repeat
end

on queueChannels me
  tChannelList = me.getSongChannelList()
  repeat with tChannel in tChannelList
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
  tChannelList = me.getSongChannelList()
  repeat with i = tChannelList.count down to 1
    tChannel = tChannelList[i]
    if (tChannel >= 1) and (tChannel <= pSongChannels.count) then
      startSoundChannel(pSongChannels[tChannel])
    end if
  end repeat
end

on addPlayRound me
  tSongData = me.getSongData()
  if tSongData = 0 then
    return 1
  else
    if not pLoop then
      if pPlaylistIndex > pPlaylist.count then
        return 1
      end if
      tCount = pPlaylistIndex
      repeat with i = 1 to tCount
        pPlayTime = pPlayTime - (pPlaylist[1][#length] / 100)
        pPlaylist.deleteAt(1)
      end repeat
    else
      pPlaylistIndex = 1 + (pPlaylistIndex mod pPlaylist.count)
    end if
  end if
  if tSongData.getaProp(#sounds) = VOID then
    return 1
  end if
  tOffset = pPlayOffset
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
  pPlayOffset = 0
  if (pPlaylist.count < 2) and pLoop then
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
  tChannelList = me.getSongChannelList()
  if tChannelList.count < 1 then
    return -1
  end if
  tChannel = tChannelList[1]
  if (tChannel < 1) or (tChannel > pSongChannels.count) then
    return -1
  end if
  tSoundChannel = sound(pSongChannels[tChannel])
  if ilk(tSoundChannel) <> #instance then
    error(me, "Sound channel bug:" && pSongChannels[tChannel], #checkLoopData, #major)
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
  if me.getPlayBufferLength() <= 0 then
    return me.initializePlaying()
  end if
  if timeoutExists(pQueueTimeout) then
    return 1
  end if
  tLength = me.getPlayBufferLength()
  if tLength < 60000 then
    me.addPlayRound()
  end if
  return 1
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
