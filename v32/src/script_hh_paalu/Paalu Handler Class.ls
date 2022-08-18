on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on sendAction me, tActionStr
  tConn = getConnection(#Info)
  if (tConn = 0) then
    return 0
  end if
  tConn.send("PTM", [#integer: me.getIntActionFromString(tActionStr)])
end

on handle_pt_prepare me, tMsg
  tConn = tMsg.connection
  tPl1 = string(tConn.GetIntFrom())
  tPl2 = string(tConn.GetIntFrom())
  me.getComponent().prepareGame(tPl1, tPl2)
end

on handle_pt_start me, tMsg
  tConn = tMsg.connection
  tPl1 = string(tConn.GetIntFrom())
  tPl2 = string(tConn.GetIntFrom())
  me.getComponent().startGame(tPl1, tPl2)
end

on handle_pt_status me, tMsg
  tConn = tMsg.connection
  tPl1 = [#loc: tConn.GetIntFrom(), #bal: tConn.GetIntFrom(), #act: me.getStringActionFromInt(tConn.GetIntFrom()), #hit: tConn.GetBoolFrom()]
  tPl2 = [#loc: tConn.GetIntFrom(), #bal: tConn.GetIntFrom(), #act: me.getStringActionFromInt(tConn.GetIntFrom()), #hit: tConn.GetBoolFrom()]
  me.getComponent().updateGame(tPl1, tPl2)
end

on handle_pt_win me, tMsg
  tConn = tMsg.connection
  tResult = tConn.GetIntFrom()
  case tResult of
    1:
      me.getComponent().endGame(0)
    0:
      me.getComponent().endGame(#both)
    -1:
      me.getComponent().endGame(1)
  end case
  return 0
end

on handle_pt_timeout me, tMsg
  tConn = tMsg.connection
  me.getComponent().timeout(tConn.GetIntFrom())
end

on handle_pt_end me, tMsg
  me.getComponent().resetGame()
end

on getStringActionFromInt me, tInt
  case tInt of
    0:
      return "-"
    1:
      return "A"
    2:
      return "D"
    3:
      return "W"
    4:
      return "E"
    5:
      return "X"
    6:
      return "S"
    7:
      return "0"
    8:
      return "Q"
  end case
  return "-"
end

on getIntActionFromString me, tStr
  case tStr of
    "-":
      return 0
    "A":
      return 1
    "D":
      return 2
    "W":
      return 3
    "E":
      return 4
    "X":
      return 5
    "S":
      return 6
    "0":
      return 7
    "Q":
      return 8
  end case
  return 0
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(114, #handle_pt_start)
  tMsgs.setaProp(115, #handle_pt_prepare)
  tMsgs.setaProp(116, #handle_pt_end)
  tMsgs.setaProp(117, #handle_pt_timeout)
  tMsgs.setaProp(118, #handle_pt_status)
  tMsgs.setaProp(119, #handle_pt_win)
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
