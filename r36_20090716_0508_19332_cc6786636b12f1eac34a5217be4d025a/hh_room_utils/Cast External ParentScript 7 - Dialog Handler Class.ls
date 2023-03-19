on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_get_pending_response me, tMsg
  tConn = tMsg.getaProp(#connection)
  tCount = tConn.GetIntFrom()
  if tCount = 0 then
    me.getComponent().openCfhWindow()
  else
    me.getComponent().openPendingCFHWindow(tMsg)
  end if
end

on handle_pending_CFHs_deleted me, tMsg
  me.getComponent().openCfhWindow()
end

on handle_cfh_sending_response me, tMsg
  tConn = tMsg.getaProp(#connection)
  tStatus = tConn.GetIntFrom()
  if tStatus = 0 then
    me.getComponent().showAlertSentWindow()
  end if
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(319, #handle_get_pending_response)
  tMsgs.setaProp(320, #handle_pending_CFHs_deleted)
  tMsgs.setaProp(321, #handle_cfh_sending_response)
  tCmds = [:]
  tCmds.setaProp("GET_PENDING_CALLS_FOR_HELP", 237)
  tCmds.setaProp("DELETE_PENDING_CALLS_FOR_HELP", 238)
  if tBool then
    registerListener(getVariable("connection.info.id", #Info), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id", #Info), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id", #Info), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id", #Info), me.getID(), tCmds)
  end if
  return 1
end
