on construct me 
  me.regMessageListener(1)
end

on deconstruct me 
  me.regMessageListener(0)
end

on changeStatus me, tMsg 
  tConnection = tMsg.getaProp(#connection)
  if voidp(tConnection) then
    return FALSE
  end if
  tID = tConnection.GetIntFrom()
  tStatus = tConnection.GetIntFrom()
  if not threadExists(#room) then
    error(me, "Room thread not found.", #changeStatus, #critical)
    return FALSE
  end if
  tComponent = getThread(#room).getComponent()
  if voidp(tComponent) then
    error(me, "Room component not found.", #changeStatus, #critical)
    return FALSE
  end if
  tActiveObject = tComponent.getActiveObject(tID)
  if voidp(tActiveObject) then
    error(me, "One way door object" && tID && "not found.", #changeStatus, #major)
    return FALSE
  end if
  if tActiveObject.handler(#setDoor) then
    tActiveObject.setDoor(tStatus)
  end if
  return TRUE
end

on regMessageListener me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(312, #changeStatus)
  tCmds = [:]
  tCmds.setaProp("ENTER_ONEWAY_DOOR", 232)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return TRUE
end
