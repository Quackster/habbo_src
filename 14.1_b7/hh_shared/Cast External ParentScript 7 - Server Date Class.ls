on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on getDate me
  if connectionExists(getVariable("connection.info.id")) then
    return getConnection(getVariable("connection.info.id")).send("GDATE")
  else
    return 0
  end if
end

on handle_date me, tMsg
  if stringp(tMsg.content) then
    tMsg = tMsg.content
    tDelim = the itemDelimiter
    the itemDelimiter = "-"
    if tMsg.item.count = 3 then
      tMsg = tMsg.item[1] & "." & tMsg.item[2] & "." & tMsg.item[3]
      getObject(#session).set("server_date", tMsg)
      the itemDelimiter = tDelim
      return executeMessage(#serverDate, tMsg)
    end if
    the itemDelimiter = tDelim
  end if
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(163, #handle_date)
  tCmds = [:]
  tCmds.setaProp("GDATE", 49)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return 1
end
