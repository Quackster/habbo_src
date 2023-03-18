on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_sound_data me, tMsg
  tdata = []
  tStr = tMsg.connection.GetStrFrom()
  tPlayTime = tMsg.connection.GetIntFrom()
  tDelim = the itemDelimiter
  the itemDelimiter = ":"
  repeat with i = 1 to tStr.item.count / 2
    tChannelNumber = tStr.item[1 + ((i - 1) * 2)]
    tChannelData = tStr.item[2 + ((i - 1) * 2)]
    if ilk(value(tChannelNumber)) = #integer then
      tChannelNumber = value(tChannelNumber)
      if tChannelNumber = (tdata.count + 1) then
        tdata[tChannelNumber] = []
        the itemDelimiter = ";"
        repeat with j = 1 to tChannelData.item.count
          tSample = tChannelData.item[j]
          the itemDelimiter = ","
          if tSample.item.count >= 2 then
            tid = value(tSample.item[1])
            tCount = value(tSample.item[2])
            tdata[tChannelNumber][tdata[tChannelNumber].count + 1] = [#id: tid, #length: tCount]
          end if
          the itemDelimiter = ";"
        end repeat
      end if
    end if
    the itemDelimiter = ":"
  end repeat
  the itemDelimiter = tDelim
  me.getComponent().parseSongData(tdata, tPlayTime)
end

on handle_machine_sound_packages me, tMsg
  if voidp(tMsg.connection) then
    return 0
  end if
  tSlotCount = tMsg.connection.GetIntFrom()
  tFilledSlots = tMsg.connection.GetIntFrom()
  me.getComponent().clearSoundSets()
  repeat with i = 1 to tFilledSlots
    tSlotIndex = tMsg.connection.GetIntFrom()
    tid = tMsg.connection.GetIntFrom()
    tSampleList = []
    tSampleCount = tMsg.connection.GetIntFrom()
    repeat with j = 1 to tSampleCount
      tSampleID = tMsg.connection.GetIntFrom()
      tSampleList.add(tSampleID)
    end repeat
    me.getComponent().updateSoundSet(tSlotIndex, tid, tSampleList)
  end repeat
  me.getComponent().removeSoundSetInsertLock()
  return 1
end

on handle_user_sound_packages me, tMsg
  if voidp(tMsg.connection) then
    return 0
  end if
  tCount = tMsg.connection.GetIntFrom()
  tList = []
  repeat with i = 1 to tCount
    tid = tMsg.connection.GetIntFrom()
    tList.append(tid)
  end repeat
  return me.getComponent().updateSetList(tList)
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
  return 1
end
