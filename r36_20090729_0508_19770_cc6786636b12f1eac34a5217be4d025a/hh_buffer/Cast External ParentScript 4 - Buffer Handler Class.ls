on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on parseActiveObject me, tConn
  if not tConn then
    return 0
  end if
  tObj = [:]
  tObj[#id] = tConn.GetStrFrom()
  tObj[#class] = tConn.GetStrFrom()
  tObj[#x] = tConn.GetIntFrom()
  tObj[#y] = tConn.GetIntFrom()
  tWidth = tConn.GetIntFrom()
  tHeight = tConn.GetIntFrom()
  tDirection = tConn.GetIntFrom() mod 8
  tObj[#direction] = [tDirection, tDirection, tDirection]
  tObj[#dimensions] = [tWidth, tHeight]
  tObj[#altitude] = getLocalFloat(tConn.GetStrFrom())
  tObj[#colors] = tConn.GetStrFrom()
  tExtra = tConn.GetIntFrom()
  tStuffData = tConn.GetStrFrom()
  tExpireTime = tConn.GetIntFrom()
  if tObj[#colors] = EMPTY then
    tObj[#colors] = "0"
  end if
  tObj[#props] = [#runtimedata: EMPTY, #extra: tExtra, #stuffdata: tStuffData]
  return tObj
end

on handle_stuffdataupdate me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tMsgTemp = [:]
  repeat with tIndex = 1 to tMsg.count
    tProp = tMsg.getPropAt(tIndex)
    tValue = tMsg[tIndex]
    tMsgTemp[tProp] = tValue
  end repeat
  tTargetID = tConn.GetStrFrom()
  return me.getComponent().bufferMessage(tMsgTemp, tTargetID, "active")
end

on handle_activeobject_remove me, tMsg
  return me.getComponent().removeObject(tMsg.content.word[1], "active")
end

on handle_activeobject_update me, tMsg
  if ilk(tMsg) <> #propList then
    return 0
  end if
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tMsgTemp = [:]
  repeat with tIndex = 1 to tMsg.count
    tProp = tMsg.getPropAt(tIndex)
    tValue = tMsg[tIndex]
    tMsgTemp[tProp] = tValue
  end repeat
  tObj = me.parseActiveObject(tConn)
  if not listp(tObj) then
    return 0
  end if
  tID = tObj[#id]
  return me.getComponent().bufferMessage(tMsgTemp, tID, "active")
end

on handle_removeitem me, tMsg
  return me.getComponent().removeObject(tMsg.content.word[1], "item")
end

on handle_updateitem me, tMsg
  tID = tMsg.content.word[1]
  return me.getComponent().bufferMessage(tMsg, tID, "item")
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(88, #handle_stuffdataupdate)
  tMsgs.setaProp(94, #handle_activeobject_remove)
  tMsgs.setaProp(95, #handle_activeobject_update)
  tMsgs.setaProp(84, #handle_removeitem)
  tMsgs.setaProp(85, #handle_updateitem)
  tCmds = [:]
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return 1
end
