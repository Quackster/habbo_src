property pUpdateTimeout, pSongData, pQueueTimeout, pPlayTimeout, pPreviewChannel, pSongChannels

on construct me
  pSongData = [:]
  pUpdateTimeout = "song player loop update"
  pQueueTimeout = "song queue timeout"
  pPlayTimeout = "song play timeout"
  pPreviewChannel = 5
  pSongChannels = [1, 2, 3, 4]
end

on deconstruct me
  if timeoutExists(pUpdateTimeout) then
    removeTimeout(pUpdateTimeout)
  end if
end

on startSong me, tSongData
  me.stopSong()
  pSongData = tSongData.duplicate()
  me.processSongData()
  me.reserveSongChannels()
  createTimeout(pQueueTimeout, 50, #queueChannels, me.getID(), VOID, 1)
  if not timeoutExists(pUpdateTimeout) then
    createTimeout(pUpdateTimeout, 1500, #checkLoopData, me.getID(), VOID, 0)
  end if
  return 1
end

on stopSong me
  if timeoutExists(pQueueTimeout) then
    removeTimeout(pQueueTimeout)
  end if
  if timeoutExists(pPlayTimeout) then
    removeTimeout(pPlayTimeout)
  end if
  if voidp(pSongData) then
    return 1
  end if
  tChannelList = pSongData[#channelList]
  if voidp(tChannelList) then
    return 1
  end if
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

on processSongData me
  if voidp(pSongData.getaProp(#sounds)) then
    return 1
  end if
  tSounds = pSongData.getaProp(#sounds)
  tChannels = []
  repeat with i = 1 to tSounds.count
    tSound = tSounds[i]
    tChannel = tSound.channel
    if not tChannels.findPos(tChannel) then
      tChannels.add(tChannel)
    end if
  end repeat
  tChannels.sort()
  repeat with i = 1 to tSounds.count
    tSound = tSounds[i]
    tChannel = tSound.channel
    tSound.channel = tChannels.findPos(tChannel)
  end repeat
  tChannelsFinal = []
  repeat with i = 1 to tChannels.count
    tChannelsFinal.add(i)
  end repeat
  pSongData[#channelList] = tChannelsFinal
end

on reserveSongChannels me
  if voidp(pSongData) then
    return 1
  end if
  tChannelList = pSongData[#channelList]
  if voidp(tChannelList) then
    return 1
  end if
  repeat with tChannel in tChannelList
    if (tChannel >= 1) and (tChannel <= pSongChannels.count) then
      queueSound("sound_machine_sample_0", pSongChannels[tChannel])
      startSoundChannel(pSongChannels[tChannel])
    end if
  end repeat
end

on queueChannels me
  if voidp(pSongData) then
    return 1
  end if
  tChannelList = pSongData[#channelList]
  if voidp(tChannelList) then
    return 1
  end if
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
  if voidp(pSongData) then
    return 1
  end if
  tChannelList = pSongData[#channelList]
  if voidp(tChannelList) then
    return 1
  end if
  repeat with i = tChannelList.count down to 1
    tChannel = tChannelList[i]
    if (tChannel >= 1) and (tChannel <= pSongChannels.count) then
      startSoundChannel(pSongChannels[tChannel])
    end if
  end repeat
end

on addPlayRound me
  if pSongData.getaProp(#sounds) = VOID then
    return 1
  end if
  tOffset = 0
  if not voidp(pSongData[#offset]) then
    tOffset = pSongData[#offset]
  end if
  tOffsetList = []
  repeat with i = 1 to pSongChannels.count
    tOffsetList.add(tOffset)
  end repeat
  repeat with i = 1 to pSongData.sounds.count
    tSound = pSongData.sounds[i]
    repeat with j = 1 to tSound.loops
      tChannel = tSound.channel
      if (tChannel >= 1) and (tChannel <= pSongChannels.count) then
        if getMember(tSound.name) <> VOID then
          if getMember(tSound.name).type = #sound then
            if tOffsetList[tChannel] > 0 then
              tLength = getMember(tSound.name).duration
              if tLength > tOffsetList[tChannel] then
                queueSound(tSound.name, pSongChannels[tChannel], [#startTime: tOffsetList[tChannel]])
              end if
              tOffsetList[tChannel] = max(0, tOffsetList[tChannel] - tLength)
              next repeat
            end if
            queueSound(tSound.name, pSongChannels[tChannel])
          end if
        end if
      end if
    end repeat
  end repeat
  if not voidp(pSongData[#offset]) then
    tOffset = tOffsetList[1]
    repeat with i = 2 to tOffsetList.count
      if tOffsetList[i] < tOffset then
        tOffset = tOffsetList[i]
      end if
    end repeat
    pSongData[#offset] = tOffset
  end if
  return 1
end

on checkLoopData me
  if voidp(pSongData) then
    return 1
  end if
  tChannelList = pSongData[#channelList]
  if voidp(tChannelList) then
    return 1
  end if
  if tChannelList.count = 0 then
    return 1
  end if
  tChannel = tChannelList[1]
  if (tChannel < 1) or (tChannel > pSongChannels.count) then
    return 1
  end if
  tPlayList = sound(pSongChannels[tChannel]).getPlaylist()
  tLength = 0
  repeat with i = 1 to tPlayList.count
    tLength = tLength + tPlayList[i].member.duration
  end repeat
  if tLength < 60000 then
    me.addPlayRound()
  end if
  return 1
end

on startSamplePreview me, tParams
  tSuccess = playSoundInChannel(tParams.name, pPreviewChannel)
  if not tSuccess then
    return error(me, "Sound could not be started", #startSamplePreview)
  end if
  return 1
end

on stopSamplePreview me
  tSuccess = stopSoundChannel(pPreviewChannel)
  if not tSuccess then
    return error(me, "Sound could not be stopped", #stopSamplePreview)
  end if
  return 1
end
