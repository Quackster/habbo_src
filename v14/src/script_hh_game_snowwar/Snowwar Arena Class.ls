property pFrameworkId

on construct me 
  pFrameworkId = getVariable("snowwar.gamesystem.id")
  executeMessage(#gamesystem_getfacade, getVariable("snowwar.gamesystem.id"))
  registerMessage(#create_user, me.getID(), #handleUserCreated)
  registerMessage(#game_started, me.getID(), #hideArrowHiliter)
  registerMessage(#spectatorMode_off, me.getID(), #handleSpectatorModeOff)
  executeMessage(#SetMinigameHandler, getClassVariable("snowwar.minigamehandler.class"))
  executeMessage(#pause_messeger_update)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#create_user, me.getID())
  unregisterMessage(#game_started, me.getID())
  executeMessage(#gamesystem_removefacade, getVariable("snowwar.gamesystem.id"))
  executeMessage(#resume_messeger_update)
  return TRUE
end

on prepare me 
  executeMessage(#hideInfoStand)
  tRoomInt = getObject(#room_interface)
  if tRoomInt <> 0 then
    if (getObject(pFrameworkId) = 0) then
      return FALSE
    end if
    if (getObject(pFrameworkId).getSpectatorModeFlag() = 0) then
      tRoomInt.hideRoomBar()
    end if
  end if
  getConnection(#info).send("G_OBJS")
  return TRUE
end

on handleSpectatorModeOff me 
  if (getObject(pFrameworkId) = 0) then
    return FALSE
  end if
  getObject(pFrameworkId).enterLounge()
  return TRUE
end

on handleUserCreated me, tName, tUserStrId 
  tRoomInt = getObject(#room_interface)
  if (tRoomInt = 0) then
    return FALSE
  end if
  if (tName = getObject(#session).GET(#userName)) then
    tRoomInt.showArrowHiliter(tUserStrId)
  end if
  return TRUE
end

on hideArrowHiliter me 
  tRoomInt = getObject(#room_interface)
  if (tRoomInt = 0) then
    return FALSE
  end if
  return(tRoomInt.hideArrowHiliter())
end
