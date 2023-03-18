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
  executeMessage(#hideInfoStand)
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
  tFramework.sendGameSystemEvent(#send_set_target, tloc)
end

on handleSpectatorModeOff me
  if getObject(pFrameworkId) = 0 then
    return 0
  end if
  getObject(pFrameworkId).enterLounge()
end
