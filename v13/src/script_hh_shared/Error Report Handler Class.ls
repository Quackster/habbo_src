on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handle_error_report me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tErrorList = [:]
  tErrorList.setAt(#errorId, tConn.GetIntFrom())
  tErrorList.setAt(#errorMsgId, tConn.GetIntFrom())
  tErrorList.setAt(#time, tConn.GetStrFrom())
  tErrorList.setAt(#errorId, "SERVER-" & tErrorList.getAt(#errorId))
  me.getComponent().storeErrorReport(tErrorList)
  me.getInterface().showErrors()
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(299, #handle_error_report)
  tCmds = [:]
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return(1)
end
