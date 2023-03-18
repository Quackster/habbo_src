on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_partnerregistration me, tMsg
  me.getComponent().handlePartnerRegistration(tMsg)
  return 1
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(281, #handle_partnerregistration)
  tCmds = [:]
  if tBool then
    registerListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
  end if
  return 1
end
