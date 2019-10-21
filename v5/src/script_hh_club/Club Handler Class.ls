on construct(me)
  return(me.regMsgList(1))
  exit
end

on deconstruct(me)
  return(me.regMsgList(0))
  exit
end

on handle_ok(me, tMsg)
  getConnection(tMsg.getaProp(#connection)).send(#info, "SCR_GINFO club_habbo")
  exit
end

on handle_scr_sinfo(me, tMsg)
  tDelim = the itemDelimiter
  the itemDelimiter = "\t"
  tList = []
  tList.setAt(#command, "SCR_SINF")
  #productName.setAt(tMsg, content.getProp(#item, 1))
  #status.setAt(tMsg, content.getProp(#item, 2))
  #daysLeft.setAt(tMsg, value(content.getProp(#item, 3)))
  the itemDelimiter = tDelim
  me.getComponent().setStatus(tList)
  exit
end

on handle_scr_nosub(me, tMsg)
  tList = []
  tList.setAt(#command, "SCR_NOSUB")
  tList.setAt(#status, "inactive")
  tList.setAt(#productName, tMsg.getaProp(#content))
  me.getComponent().setStatus(tList)
  exit
end

on handle_scr_sok(me, tMsg)
  me.getInterface().subscriptionOkConfirmed()
  exit
end

on regMsgList(me, tBool)
  tList = []
  tList.setAt("OK", #handle_ok)
  tList.setAt("SCR_SINF", #handle_scr_sinfo)
  tList.setAt("SCR_NOSUB", #handle_scr_nosub)
  tList.setAt("SCR_SOK", #handle_scr_sok)
  if tBool then
    return(registerListener(getVariable("connection.info.id"), me.getID(), tList))
  else
    return(unregisterListener(getVariable("connection.info.id"), me.getID(), tList))
  end if
  exit
end