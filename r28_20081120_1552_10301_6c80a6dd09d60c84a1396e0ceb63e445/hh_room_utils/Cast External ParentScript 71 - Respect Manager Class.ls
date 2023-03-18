on construct me
  me.regMsgList(1)
  registerMessage(#externalGiveRespect, me.getID(), #externalGiveRespect)
  return 1
end

on deconstruct me
  unregisterMessage(#externalGiveRespect, me.getID())
  me.regMsgList(0)
  return 1
end

on externalGiveRespect me, tWebID
  tWebID = integer(tWebID)
  if not integerp(tWebID) then
    return 0
  end if
  tConnection = getConnection(#Info)
  if tConnection = 0 then
    return 0
  end if
  me.substractRespectCount()
  return tConnection.send("RESPECT_USER", [#integer: tWebID])
end

on getRespectCount me
  tSession = getObject(#session)
  if tSession = 0 then
    return 0
  end if
  if not tSession.exists(#user_respect_ticket_count) then
    return -1
  end if
  return tSession.GET(#user_respect_ticket_count)
end

on substractRespectCount me
  tCount = me.getRespectCount()
  if tCount > 0 then
    tCount = tCount - 1
    getObject(#session).set(#user_respect_ticket_count, tCount)
    executeMessage(#updateInfoStandButtons)
  end if
  return 1
end

on regMsgList me, tBool
  tMsgs = [:]
  tCmds = [:]
  tCmds.setaProp("RESPECT_USER", 371)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return 1
end
