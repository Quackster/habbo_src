on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on parseActiveObject me, tConn 
  if not tConn then
    return(0)
  end if
  tObj = [:]
  tObj.setAt(#id, tConn.GetStrFrom())
  tObj.setAt(#class, tConn.GetStrFrom())
  tObj.setAt(#x, tConn.GetIntFrom())
  tObj.setAt(#y, tConn.GetIntFrom())
  tWidth = tConn.GetIntFrom()
  tHeight = tConn.GetIntFrom()
  tDirection = tConn.GetIntFrom() mod 8
  tObj.setAt(#direction, [tDirection, tDirection, tDirection])
  tObj.setAt(#dimensions, [tWidth, tHeight])
  tObj.setAt(#altitude, getLocalFloat(tConn.GetStrFrom()))
  tObj.setAt(#colors, tConn.GetStrFrom())
  tExtra = tConn.GetIntFrom()
  tStuffData = tConn.GetStrFrom()
  tExpireTime = tConn.GetIntFrom()
  if tObj.getAt(#colors) = "" then
    tObj.setAt(#colors, "0")
  end if
  tObj.setAt(#props, [#runtimedata:"", #extra:tExtra, #stuffdata:tStuffData])
  return(tObj)
end

on handle_stuffdataupdate me, tMsg 
  tConn = tMsg.connection
  if not tConn then
    return(0)
  end if
  tMsgTemp = [:]
  tIndex = 1
  repeat while tIndex <= tMsg.count
    tProp = tMsg.getPropAt(tIndex)
    tValue = tMsg.getAt(tIndex)
    tMsgTemp.setAt(tProp, tValue)
    tIndex = 1 + tIndex
  end repeat
  tTargetID = tConn.GetStrFrom()
  return(me.getComponent().bufferMessage(tMsgTemp, tTargetID, "active"))
end

on handle_activeobject_remove me, tMsg 
  return(tMsg.removeObject(content.getProp(#word, 1), "active"))
end

on handle_activeobject_update me, tMsg 
  if ilk(tMsg) <> #propList then
    return(0)
  end if
  tConn = tMsg.connection
  if not tConn then
    return(0)
  end if
  tMsgTemp = [:]
  tIndex = 1
  repeat while tIndex <= tMsg.count
    tProp = tMsg.getPropAt(tIndex)
    tValue = tMsg.getAt(tIndex)
    tMsgTemp.setAt(tProp, tValue)
    tIndex = 1 + tIndex
  end repeat
  tObj = me.parseActiveObject(tConn)
  if not listp(tObj) then
    return(0)
  end if
  tID = tObj.getAt(#id)
  return(me.getComponent().bufferMessage(tMsgTemp, tID, "active"))
end

on handle_removeitem me, tMsg 
  return(tMsg.removeObject(content.getProp(#word, 1), "item"))
end

on handle_updateitem me, tMsg 
  tID = content.getProp(#word, 1)
  return(me.getComponent().bufferMessage(tMsg, tID, "item"))
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
  return(1)
end
