property pFrameworkId

on construct me
  pFrameworkId = getVariable("snowwar.gamesystem.id")
  executeMessage(#gamesystem_getfacade, getVariable("snowwar.gamesystem.id"))
  registerMessage(#create_user, me.getID(), #handleUserCreated)
  registerMessage(#game_started, me.getID(), #hideArrowHiliter)
  registerMessage(#spectatorMode_off, me.getID(), #handleSpectatorModeOff)
  executeMessage(#SetMinigameHandler, getClassVariable("snowwar.minigamehandler.class"))
  executeMessage(#pause_messeger_update)
  return 1
end

on deconstruct me
  unregisterMessage(#create_user, me.getID())
  unregisterMessage(#game_started, me.getID())
  executeMessage(#gamesystem_removefacade, getVariable("snowwar.gamesystem.id"))
  executeMessage(#resume_messeger_update)
  return 1
end

on prepare me
  executeMessage(#hideInfoStand)
  tRoomInt = getObject(#room_interface)
  if (tRoomInt <> 0) then
    if (getObject(pFrameworkId) = 0) then
      return 0
    end if
    if (getObject(pFrameworkId).getSpectatorModeFlag() = 0) then
      tRoomInt.hideRoomBar()
    end if
  end if
  getConnection(#Info).send("G_OBJS")
  return 1
end

on handleSpectatorModeOff me
  if (getObject(pFrameworkId) = 0) then
    return 0
  end if
  getObject(pFrameworkId).enterLounge()
  return 1
end

on handleUserCreated me, tName, tUserStrId
  tRoomInt = getObject(#room_interface)
  if (tRoomInt = 0) then
    return 0
  end if
  if (tName = getObject(#session).GET(#userName)) then
    tRoomInt.showArrowHiliter(tUserStrId)
  end if
  return 1
end

on hideArrowHiliter me
  tRoomInt = getObject(#room_interface)
  if (tRoomInt = 0) then
    return 0
  end if
  return tRoomInt.hideArrowHiliter()
end
