on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_pt_prepare me, tMsg
  tLn1 = tMsg.content.line[1]
  tLn2 = tMsg.content.line[2]
  tPl0 = tLn1.char[3..length(tLn1)]
  tPl1 = tLn2.char[3..length(tLn2)]
  me.getComponent().prepareGame(tPl0, tPl1)
end

on handle_pt_start me, tMsg
  tLn1 = tMsg.content.line[1]
  tLn2 = tMsg.content.line[2]
  tPl1 = tLn1.char[3..length(tLn1)]
  tPl2 = tLn2.char[3..length(tLn2)]
  me.getComponent().startGame(tPl1, tPl2)
end

on handle_pt_status me, tMsg
  tLn1 = tMsg.content.line[1]
  tLn2 = tMsg.content.line[2]
  tPl1 = [#loc: value(tLn1.word[1]), #bal: value(tLn1.word[2]), #act: tLn1.word[3], #hit: tLn1.word[4] = "h"]
  tPl2 = [#loc: value(tLn2.word[1]), #bal: value(tLn2.word[2]), #act: tLn2.word[3], #hit: tLn2.word[4] = "h"]
  me.getComponent().updateGame(tPl1, tPl2)
end

on handle_pt_win me, tMsg
  me.getComponent().endGame(not value(tMsg.content.line[1]))
end

on handle_pt_bothlose me, tMsg
  me.getComponent().endGame(#both)
end

on handle_pt_timeout me, tMsg
  me.getComponent().timeout(tMsg.content.line[1])
end

on handle_pt_end me, tMsg
  me.getComponent().resetGame()
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(114, #handle_pt_start)
  tMsgs.setaProp(115, #handle_pt_prepare)
  tMsgs.setaProp(116, #handle_pt_end)
  tMsgs.setaProp(117, #handle_pt_timeout)
  tMsgs.setaProp(118, #handle_pt_status)
  tMsgs.setaProp(119, #handle_pt_win)
  tMsgs.setaProp(120, #handle_pt_bothlose)
  tCmds = [:]
  tCmds.setaProp("PTM", 114)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return 1
end
