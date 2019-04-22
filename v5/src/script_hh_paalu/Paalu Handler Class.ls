on construct(me)
  return(me.regMsgList(1))
  exit
end

on deconstruct(me)
  return(me.regMsgList(0))
  exit
end

on handle_pt_prepare(me, tMsg)
  tLn1 = tMsg.getProp(#line, 1)
  tLn2 = tMsg.getProp(#line, 2)
  tPl0 = tLn1.getProp(#char, 3, length(tLn1))
  tPl1 = tLn2.getProp(#char, 3, length(tLn2))
  me.getComponent().prepareGame(tPl0, tPl1)
  exit
end

on handle_pt_start(me, tMsg)
  tLn1 = tMsg.getProp(#line, 1)
  tLn2 = tMsg.getProp(#line, 2)
  tPl1 = tLn1.getProp(#char, 3, length(tLn1))
  tPl2 = tLn2.getProp(#char, 3, length(tLn2))
  me.getComponent().startGame(tPl1, tPl2)
  exit
end

on handle_pt_status(me, tMsg)
  tLn1 = tMsg.getProp(#line, 1)
  tLn2 = tMsg.getProp(#line, 2)
  tPl1 = [#loc:value(tLn1.getProp(#word, 1)), #bal:value(tLn1.getProp(#word, 2)), #act:tLn1.getProp(#word, 3), #hit:tLn1.getProp(#word, 4) = "h"]
  tPl2 = [#loc:value(tLn2.getProp(#word, 1)), #bal:value(tLn2.getProp(#word, 2)), #act:tLn2.getProp(#word, 3), #hit:tLn2.getProp(#word, 4) = "h"]
  me.getComponent().updateGame(tPl1, tPl2)
  exit
end

on handle_pt_win(me, tMsg)
  me.getComponent().endGame(not value(tMsg.getProp(#line, 1)))
  exit
end

on handle_pt_bothlose(me, tMsg)
  me.getComponent().endGame(#both)
  exit
end

on handle_pt_timeout(me, tMsg)
  me.getComponent().timeout(tMsg.getProp(#line, 1))
  exit
end

on handle_pt_end(me, tMsg)
  me.getComponent().resetGame()
  exit
end

on regMsgList(me, tBool)
  tList = []
  tList.setAt("PT_PR", #handle_pt_prepare)
  tList.setAt("PT_ST", #handle_pt_start)
  tList.setAt("PT_SI", #handle_pt_status)
  tList.setAt("PT_WIN", #handle_pt_win)
  tList.setAt("PT_BOTHLOSE", #handle_pt_bothlose)
  tList.setAt("PT_TIMEOUT", #handle_pt_timeout)
  tList.setAt("PT_EN", #handle_pt_end)
  if tBool then
    return(registerListener(getVariable("connection.room.id"), me.getID(), tList))
  else
    return(unregisterListener(getVariable("connection.room.id"), me.getID(), tList))
  end if
  exit
end