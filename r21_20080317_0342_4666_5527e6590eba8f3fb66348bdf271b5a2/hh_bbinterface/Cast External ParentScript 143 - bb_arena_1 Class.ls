property pFrameworkId, pRoomGeometry, pLastGameClickCoordinate, pConnection

on construct me
  pFrameworkId = getVariable("bb.gamesystem.id")
  executeMessage(#gamesystem_getfacade, getVariable("bb.gamesystem.id"))
  registerMessage(#spectatorMode_off, me.getID(), #handleSpectatorModeOff)
  me.registerEventProc(1)
  return 1
end

on deconstruct me
  pConnection = VOID
  me.registerEventProc(0)
  executeMessage(#gamesystem_removefacade, getVariable("bb.gamesystem.id"))
  return 1
end

on prepare me
  if getObject(#room_interface) <> 0 then
    getObject(#room_interface).hideInfoStand()
  end if
  return 1
end

on registerEventProc me, tBoolean
  tRoomThread = getThread(#room)
  if tRoomThread = 0 then
    return 0
  end if
  tRoomInt = tRoomThread.getInterface()
  if tRoomInt = 0 then
    return 0
  end if
  pRoomGeometry = tRoomInt.getGeometry()
  if pRoomGeometry = 0 then
    return 0
  end if
  tVisObj = tRoomInt.getRoomVisualizer()
  if tVisObj = 0 then
    return 0
  end if
  tSprList = tVisObj.getProperty(#spriteList)
  if tBoolean then
    call(#registerProcedure, tSprList, #eventProcRoom, me.getID(), #mouseDown)
    call(#registerProcedure, tSprList, #eventProcRoom, me.getID(), #mouseUp)
  else
    if listp(tSprList) then
      call(#removeProcedure, tSprList, #mouseDown)
      call(#removeProcedure, tSprList, #mouseUp)
    end if
  end if
end

on eventProcRoom me, tEvent, tSprID, tParam
  if tEvent = #mouseDown then
    if tSprID = "floor" then
      tloc = pRoomGeometry.getWorldCoordinate(the mouseH, the mouseV)
      if listp(tloc) then
        return me.sendMoveGoal(tloc)
      end if
    end if
  end if
end

on sendMoveGoal me, tloc
  tFramework = getObject(pFrameworkId)
  if tFramework = 0 then
    return 0
  end if
  tStatus = tFramework.getGamestatus()
  if pLastGameClickCoordinate = [tloc, tStatus] then
    return 1
  end if
  pLastGameClickCoordinate = [tloc, tStatus]
  tConnection = me.getRoomConnection()
  if not objectp(tConnection) then
    return error(me, "Info connection has disappeared!", #sendMoveGoal)
  end if
  if tStatus = #game_started then
    return tConnection.send("GAMEEVENT", [#integer: tloc[1], #integer: tloc[2]])
  else
    return tConnection.send("MOVE", [#short: tloc[1], #short: tloc[2]])
  end if
end

on handleSpectatorModeOff me
  if getObject(pFrameworkId) = 0 then
    return 0
  end if
  getObject(pFrameworkId).enterLounge()
end

on getRoomConnection me
  if pConnection = 0 then
    pConnection = getConnection(getVariable("connection.info.id"))
  end if
  return pConnection
end
