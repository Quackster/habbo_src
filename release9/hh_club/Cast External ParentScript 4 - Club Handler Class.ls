on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_ok me, tMsg
  tMsg.getaProp(#connection).send("SCR_GET_USER_INFO", [#string: "club_habbo"])
end

on handle_scr_sinfo me, tMsg
  tProdName = tMsg.connection.GetStrFrom()
  tDaysLeft = tMsg.connection.GetIntFrom()
  tElapsedPeriods = tMsg.connection.GetIntFrom()
  tPrepaidPeriods = tMsg.connection.GetIntFrom()
  tResponseFlag = tMsg.connection.GetIntFrom()
  tList = [:]
  tList[#productName] = tProdName
  tList[#daysLeft] = tDaysLeft
  tList[#ElapsedPeriods] = tElapsedPeriods
  tList[#PrepaidPeriods] = tPrepaidPeriods
  me.getComponent().setStatus(tList, tResponseFlag)
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(3, #handle_ok)
  tMsgs.setaProp(7, #handle_scr_sinfo)
  tCmds = [:]
  tCmds.setaProp("SCR_GET_USER_INFO", 26)
  tCmds.setaProp("SCR_BUY", 190)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return 1
end
