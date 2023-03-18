on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_openuimakoppi me, tMsg
  me.getComponent().openUimakoppi()
end

on handle_closeuimakoppi me, tMsg
  me.getComponent().closeUimaKoppi()
end

on handle_jumpdata me, tMsg
  me.getComponent().jumpPlayPack([#index: tMsg.content.line[1], #jumpdata: tMsg.content.line[2]])
end

on handle_jumpliftdoor_open me, tMsg
  put "TODO:" && tMsg.getaProp(#subject)
end

on handle_jumpliftdoor_close me, tMsg
  put "TODO:" && tMsg.getaProp(#subject)
end

on handle_jumpingplace_ok me, tMsg
  me.getComponent().jumpingPlaceOk()
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(74, #handle_jumpdata)
  tMsgs.setaProp(96, #handle_openuimakoppi)
  tMsgs.setaProp(97, #handle_closeuimakoppi)
  tMsgs.setaProp(122, #handle_jumpliftdoor_open)
  tMsgs.setaProp(123, #handle_jumpliftdoor_close)
  tMsgs.setaProp(125, #handle_jumpingplace_ok)
  tCmds = [:]
  tCmds.setaProp("JUMPSTART", 103)
  tCmds.setaProp("SIGN", 104)
  tCmds.setaProp("JUMPPERF", 106)
  tCmds.setaProp("SPLASH_POSITION", 107)
  tCmds.setaProp("CLOSE_UIMAKOPPI", 108)
  tCmds.setaProp("SWIMSUIT", 116)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return 1
end
