property pSpectatorMode, pVisualizerId

on construct me
  pSpectatorMode = 0
  pVisualizerId = "passive_tv_screen"
  registerMessage(#leaveRoom, me.getID(), #hideSpectatorView)
  registerMessage(#changeRoom, me.getID(), #hideSpectatorView)
  return 1
end

on deconstruct me
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  return 1
end

on getSpectatorMode me
  return pSpectatorMode
end

on setSpectatorMode me, tstate, tSpaceType
  if tstate = 1 then
    pSpectatorMode = 1
    me.showSpectatorView()
    executeMessage(#spectatorMode_on)
  else
    pSpectatorMode = 0
    case tSpaceType of
      #public:
        if getConnection(#Info) <> 0 then
          getConnection(#Info).send("QUIT")
        end if
        executeMessage(#leaveRoom)
        executeMessage(#spectatorMode_off)
      #private:
      #game:
        executeMessage(#spectatorMode_off)
    end case
  end if
  return 1
end

on showSpectatorView me
  tRoomInt = getObject(#room_interface)
  if objectp(tRoomInt) then
    tRoomInt.hideInterface(#Remove)
    tRoomInt.hideObjectInfo()
    tRoomInt.hideInfoStand()
    tRoomInt.showRoomBar()
    if tRoomInt.getHiliter() <> 0 then
      removeUpdate(tRoomInt.getHiliter().getID())
      removeObject(tRoomInt.getHiliter().getID())
    end if
  end if
  if visualizerExists(pVisualizerId) then
    return 1
  end if
  createVisualizer(pVisualizerId, "habbo_tv.visual")
  tVisObj = getVisualizer(pVisualizerId)
  tRoomVis = tRoomInt.getRoomVisualizer()
  if tRoomVis = 0 then
    return 0
  end if
  tVisObj.moveZ(tRoomVis.getProperty(#locZ) + 1)
  return 1
end

on hideSpectatorView me
  pSpectatorMode = 0
  if visualizerExists(pVisualizerId) then
    removeVisualizer(pVisualizerId)
  end if
  return 1
end
