on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handle_ok me, tMsg 
  tMsg.getaProp(#connection).send("SCR_GINFO", [#string:"club_habbo"])
end

on handle_scr_sinfo me, tMsg 
  tDelim = the itemDelimiter
  the itemDelimiter = "\t"
  tList = [:]
  tList.setAt(#command, "SCR_SINF")
  #productName.setAt(tMsg, content.getProp(#item, 1))
  #status.setAt(tMsg, content.getProp(#item, 2))
  if content.getProp(#item, 3) = "-" then
    tList.setAt(#daysLeft, getText("club_member"))
  else
    #daysLeft.setAt(tMsg, value(content.getProp(#item, 3)))
  end if
  the itemDelimiter = tDelim
  me.getComponent().setStatus(tList)
end

on handle_scr_nosub me, tMsg 
  tList = [:]
  tList.setAt(#command, "SCR_NOSUB")
  tList.setAt(#status, "inactive")
  tList.setAt(#productName, tMsg.getaProp(#content))
  me.getComponent().setStatus(tList)
end

on handle_scr_sok me, tMsg 
  me.getInterface().subscriptionOkConfirmed()
end

on handle_scr_asu me, tMsg 
  put(">>>>", tMsg)
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(3, #handle_ok)
  tMsgs.setaProp(7, #handle_scr_sinfo)
  tMsgs.setaProp(23, #handle_scr_sok)
  tMsgs.setaProp(22, #handle_scr_nosub)
  tMsgs.setaProp(21, #handle_scr_asu)
  tCmds = [:]
  tCmds.setaProp("SCR_GINFO", 26)
  tCmds.setaProp("SCR_SUBSCRIBE", 50)
  tCmds.setaProp("SCR_EXTSCR", 51)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return(1)
end