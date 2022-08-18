on construct me
  return me.regMsgList(1)
end

on deconsturct me
  return me.regMsgList(0)
end

on handle_open_uimakoppi me, tMsg
  me.getInterface().openPukukoppi()
end

on handle_close_uimakoppi me, tMsg
  me.getInterface().closePukukoppi()
end

on handle_md_exit me, tMsg
  me.getInterface().doTheDew(tMsg.content)
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(96, #handle_open_uimakoppi)
  tMsgs.setaProp(97, #handle_close_uimakoppi)
  tMsgs.setaProp(121, #handle_md_exit)
  tCmds = [:]
  tCmds.setaProp("CLOSE_UIMAKOPPI", 108)
  tCmds.setaProp("CHANGESHRT", 109)
  tCmds.setaProp("REFRESHFIGURE", 110)
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
