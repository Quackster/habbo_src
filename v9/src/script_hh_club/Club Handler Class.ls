on construct(me)
  return(me.regMsgList(1))
  exit
end

on deconstruct(me)
  return(me.regMsgList(0))
  exit
end

on handle_ok(me, tMsg)
  tMsg.getaProp(#connection).send("SCR_GET_USER_INFO", [#string:"club_habbo"])
  exit
end

on handle_scr_sinfo(me, tMsg)
  tProdName = connection.GetStrFrom()
  tDaysLeft = connection.GetIntFrom()
  tElapsedPeriods = connection.GetIntFrom()
  tPrepaidPeriods = connection.GetIntFrom()
  tResponseFlag = connection.GetIntFrom()
  tList = []
  tList.setAt(#productName, tProdName)
  tList.setAt(#daysLeft, tDaysLeft)
  tList.setAt(#ElapsedPeriods, tElapsedPeriods)
  tList.setAt(#PrepaidPeriods, tPrepaidPeriods)
  me.getComponent().setStatus(tList, tResponseFlag)
  exit
end

on regMsgList(me, tBool)
  tMsgs = []
  tMsgs.setaProp(3, #handle_ok)
  tMsgs.setaProp(7, #handle_scr_sinfo)
  tCmds = []
  tCmds.setaProp("SCR_GET_USER_INFO", 26)
  tCmds.setaProp("SCR_BUY", 190)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return(1)
  exit
end