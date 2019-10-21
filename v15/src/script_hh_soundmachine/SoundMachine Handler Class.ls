on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handle_song_info me, tMsg 
  tSongID = tMsg.connection.GetIntFrom()
  tName = tMsg.connection.GetStrFrom()
  tName = convertSpecialChars(tName, 0)
  tdata = []
  tStr = tMsg.connection.GetStrFrom()
  tDelim = the itemDelimiter
  the itemDelimiter = ":"
  i = 1
  repeat while i <= (tStr.count(#item) / 2)
    tChannelNumber = tStr.getProp(#item, (1 + ((i - 1) * 2)))
    tChannelData = tStr.getProp(#item, (2 + ((i - 1) * 2)))
    if (ilk(value(tChannelNumber)) = #integer) then
      tChannelNumber = value(tChannelNumber)
      if (tChannelNumber = (tdata.count + 1)) then
        tdata.setAt(tChannelNumber, [])
        the itemDelimiter = ";"
        j = 1
        repeat while j <= tChannelData.count(#item)
          tSample = tChannelData.getProp(#item, j)
          the itemDelimiter = ","
          if tSample.count(#item) >= 2 then
            tid = value(tSample.getProp(#item, 1))
            tCount = value(tSample.getProp(#item, 2))
            tdata.getAt(tChannelNumber).setAt((tdata.getAt(tChannelNumber).count + 1), [#id:tid, #length:tCount])
          end if
          the itemDelimiter = ";"
          j = (1 + j)
        end repeat
      end if
    end if
    the itemDelimiter = ":"
    i = (1 + i)
  end repeat
  the itemDelimiter = tDelim
  me.getComponent().parseSongData(tdata, tSongID, tName)
end

on handle_machine_sound_packages me, tMsg 
  if voidp(tMsg.connection) then
    return FALSE
  end if
  tSlotCount = tMsg.connection.GetIntFrom()
  tFilledSlots = tMsg.connection.GetIntFrom()
  me.getComponent().clearSoundSets()
  i = 1
  repeat while i <= tFilledSlots
    tSlotIndex = tMsg.connection.GetIntFrom()
    tid = tMsg.connection.GetIntFrom()
    tSampleList = []
    tSampleCount = tMsg.connection.GetIntFrom()
    j = 1
    repeat while j <= tSampleCount
      tSampleID = tMsg.connection.GetIntFrom()
      tSampleList.add(tSampleID)
      j = (1 + j)
    end repeat
    me.getComponent().updateSoundSet(tSlotIndex, tid, tSampleList)
    i = (1 + i)
  end repeat
  me.getComponent().setSoundSetCount(tFilledSlots)
  me.getComponent().removeSoundSetInsertLock()
  return TRUE
end

on handle_user_sound_packages me, tMsg 
  if voidp(tMsg.connection) then
    return FALSE
  end if
  tCount = tMsg.connection.GetIntFrom()
  tList = []
  i = 1
  repeat while i <= tCount
    tid = tMsg.connection.GetIntFrom()
    tList.append(tid)
    i = (1 + i)
  end repeat
  return(me.getComponent().updateSetList(tList))
end

on handle_invalid_song_name me, tMsg 
  return(me.getComponent().handleInvalidSongName())
end

on handle_song_list me, tMsg 
  return(me.getComponent().parseSongList(tMsg))
end

on handle_play_list me, tMsg 
  return(me.getComponent().parsePlaylist(tMsg))
end

on handle_song_missing_packages me, tMsg 
  tCount = tMsg.connection.GetIntFrom()
  tList = []
  i = 1
  repeat while i <= tCount
    tid = tMsg.connection.GetIntFrom()
    tList.append(tid)
    i = (1 + i)
  end repeat
  return(me.getComponent().handleMissingPackages(tList))
end

on handle_play_list_invalid me, tMsg 
  tCount = tMsg.connection.GetIntFrom()
  return(me.getComponent().handleListFull(tCount, "playlist"))
end

on handle_song_list_full me, tMsg 
  tCount = tMsg.connection.GetIntFrom()
  return(me.getComponent().handleListFull(tCount, "songlist"))
end

on handle_new_song me, tMsg 
  tid = tMsg.connection.GetIntFrom()
  tName = tMsg.connection.GetStrFrom()
  tName = convertSpecialChars(tName, 0)
  return(me.getComponent().updateEditorSong(tid, tName))
end

on handle_user_song_disks me, tMsg 
  return(me.getComponent().parseUserDisks(tMsg))
end

on handle_jukebox_disks me, tMsg 
  return(me.getComponent().parseJukeboxDisks(tMsg))
end

on handle_jukebox_song_added me, tMsg 
  tid = tMsg.connection.GetIntFrom()
  tLength = tMsg.connection.GetIntFrom()
  tName = tMsg.connection.GetStrFrom()
  tAuthor = tMsg.connection.GetStrFrom()
  tName = convertSpecialChars(tName, 0)
  tAuthor = convertSpecialChars(tAuthor, 0)
  return(me.getComponent().insertPlaylistSong(tid, tLength, tName, tAuthor))
end

on handle_song_locked me, tMsg 
  return(me.getComponent().handleSongLocked())
end

on handle_jukebox_playlist_full me, tMsg 
  return(me.getComponent().handleJukeBoxPlaylistFull())
end

on handle_invalid_song_length me, tMsg 
  return(me.getComponent().handleInvalidSongLength())
end

on handle_song_saved me, tMsg 
  return(me.getComponent().updateEditorSong(void(), void()))
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(300, #handle_song_info)
  tMsgs.setaProp(301, #handle_machine_sound_packages)
  tMsgs.setaProp(302, #handle_user_sound_packages)
  tMsgs.setaProp(332, #handle_invalid_song_name)
  tMsgs.setaProp(322, #handle_song_list)
  tMsgs.setaProp(323, #handle_play_list)
  tMsgs.setaProp(324, #handle_song_missing_packages)
  tMsgs.setaProp(325, #handle_play_list_invalid)
  tMsgs.setaProp(326, #handle_song_list_full)
  tMsgs.setaProp(331, #handle_new_song)
  tMsgs.setaProp(333, #handle_user_song_disks)
  tMsgs.setaProp(334, #handle_jukebox_disks)
  tMsgs.setaProp(335, #handle_jukebox_song_added)
  tMsgs.setaProp(336, #handle_song_locked)
  tMsgs.setaProp(337, #handle_jukebox_playlist_full)
  tMsgs.setaProp(338, #handle_invalid_song_length)
  tMsgs.setaProp(339, #handle_song_saved)
  tCmds = [:]
  tCmds.setaProp("INSERT_SOUND_PACKAGE", 219)
  tCmds.setaProp("EJECT_SOUND_PACKAGE", 220)
  tCmds.setaProp("GET_SONG_INFO", 221)
  tCmds.setaProp("NEW_SONG", 239)
  tCmds.setaProp("SAVE_SONG_NEW", 240)
  tCmds.setaProp("EDIT_SONG", 241)
  tCmds.setaProp("SAVE_SONG_EDIT", 242)
  tCmds.setaProp("BURN_SONG", 254)
  tCmds.setaProp("SONG_EDIT_CLOSE", 246)
  tCmds.setaProp("UPDATE_PLAY_LIST", 243)
  tCmds.setaProp("GET_SONG_LIST", 244)
  tCmds.setaProp("GET_PLAY_LIST", 245)
  tCmds.setaProp("DELETE_SONG", 248)
  tCmds.setaProp("ADD_JUKEBOX_DISC", 255)
  tCmds.setaProp("REMOVE_JUKEBOX_DISC", 256)
  tCmds.setaProp("JUKEBOX_PLAYLIST_ADD", 257)
  tCmds.setaProp("GET_JUKEBOX_DISCS", 258)
  tCmds.setaProp("GET_USER_SONG_DISCS", 259)
  tCmds.setaProp("RESET_JUKEBOX", 260)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return TRUE
end
