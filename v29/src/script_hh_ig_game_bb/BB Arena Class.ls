property pRoomGeometry, pFrameworkId

on construct me 
  pFrameworkId = getVariable("bb.gamesystem.id")
  executeMessage(#gamesystem_getfacade, getVariable("bb.gamesystem.id"))
  me.registerEventProc(1)
  return TRUE
end

on deconstruct me 
  pConnection = void()
  me.registerEventProc(0)
  executeMessage(#gamesystem_removefacade, getVariable("bb.gamesystem.id"))
  return TRUE
end

on prepare me 
  executeMessage(#hideInfoStand)
  return TRUE
end

on registerEventProc me, tBoolean 
  tRoomThread = getThread(#room)
  if (tRoomThread = 0) then
    return FALSE
  end if
  tRoomInt = tRoomThread.getInterface()
  if (tRoomInt = 0) then
    return FALSE
  end if
  pRoomGeometry = tRoomInt.getGeometry()
  if (pRoomGeometry = 0) then
    return FALSE
  end if
  tVisObj = tRoomInt.getRoomVisualizer()
  if (tVisObj = 0) then
    return FALSE
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
  if (tEvent = #mouseDown) then
    if (tSprID = "floor") then
      tloc = pRoomGeometry.getWorldCoordinate(the mouseH, the mouseV)
      if listp(tloc) then
        return(me.sendMoveGoal(tloc))
      end if
    end if
  end if
end

on sendMoveGoal me, tloc 
  tFramework = getObject(pFrameworkId)
  if (tFramework = 0) then
    return FALSE
  end if
  tFramework.sendGameSystemEvent(#send_set_target, tloc)
end
