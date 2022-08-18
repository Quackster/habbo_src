property pPersistentFurniData

on construct me
  pPersistentFurniData = VOID
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_recycler_status me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tstate = tConn.GetIntFrom()
  case tstate of
    1:
      tstate = #open
    2:
      tstate = #closed
    3:
      tstate = #timeout
      tTimeout = tConn.GetIntFrom()
  end case
  me.getComponent().setState(tstate, tTimeout)
end

on handle_recycler_finished me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tSuccess = tConn.GetIntFrom()
  tPrizeID = tConn.GetIntFrom()
  me.getComponent().recyclingFinished(tSuccess)
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(507, #handle_recycler_status)
  tMsgs.setaProp(508, #handle_recycler_finished)
  tCmds = [:]
  tCmds.setaProp("GET_RECYCLER_STATUS", 413)
  tCmds.setaProp("RECYCLE_ITEMS", 414)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return 1
end
