on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handle_sound_data me, tMsg 
  tdata = []
  tStr = tMsg.connection.GetStrFrom()
  tPlayTime = tMsg.connection.GetIntFrom()
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
            tID = value(tSample.getProp(#item, 1))
            tCount = value(tSample.getProp(#item, 2))
            tdata.getAt(tChannelNumber).setAt((tdata.getAt(tChannelNumber).count + 1), [#id:tID, #length:tCount])
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
  me.getComponent().parseSongData(tdata, tPlayTime)
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
    tID = tMsg.connection.GetIntFrom()
    tSampleList = []
    tSampleCount = tMsg.connection.GetIntFrom()
    j = 1
    repeat while j <= tSampleCount
      tSampleID = tMsg.connection.GetIntFrom()
      tSampleList.add(tSampleID)
      j = (1 + j)
    end repeat
    me.getComponent().updateSoundSet(tSlotIndex, tID, tSampleList)
    i = (1 + i)
  end repeat
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
    tID = tMsg.connection.GetIntFrom()
    tList.append(tID)
    i = (1 + i)
  end repeat
  return(me.getComponent().updateSetList(tList))
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(300, #handle_sound_data)
  tMsgs.setaProp(301, #handle_machine_sound_packages)
  tMsgs.setaProp(302, #handle_user_sound_packages)
  tCmds = [:]
  tCmds.setaProp("GET_SOUND_MACHINE_CONFIGURATION", 217)
  tCmds.setaProp("SAVE_SOUND_MACHINE_CONFIGURATION", 218)
  tCmds.setaProp("INSERT_SOUND_PACKAGE", 219)
  tCmds.setaProp("EJECT_SOUND_PACKAGE", 220)
  tCmds.setaProp("GET_SOUND_DATA", 221)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return TRUE
end
