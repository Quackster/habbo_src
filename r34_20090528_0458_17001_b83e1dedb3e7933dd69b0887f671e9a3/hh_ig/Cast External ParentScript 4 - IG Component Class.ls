property pSystemState, pActiveMode, pIGComponentProps, pIGComponents

on construct me
  pSystemState = 0
  pIGComponents = [:]
  registerMessage(#userloggedin, me.getID(), #Initialize)
  registerMessage(#leaveRoom, me.getID(), #leaveRoom)
  registerMessage(#changeRoom, me.getID(), #leaveRoom)
  registerMessage(#roomReady, me.getID(), #enterRoom)
  pIGComponentProps = ["GameList": [#always_on], "LevelList": [#always_on], "GameData": [#always_on]]
  return 1
end

on deconstruct me
  pSystemState = 0
  unregisterMessage(#userloggedin, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#roomReady, me.getID())
  repeat with tObject in pIGComponents
    tObject = VOID
  end repeat
  pIGComponents = VOID
  return 1
end

on setActiveIGComponent me, tID, tHoldUpdates
  tService = me.getComponent().getActiveIGComponent()
  if (tService <> 0) and (tID <> pActiveMode) then
    tService.setActiveFlag(0)
    tProps = pIGComponentProps.getaProp(pActiveMode)
    if listp(tProps) then
      if not tProps.findPos(#always_on) then
        removeIGComponent(pActiveMode)
      end if
    end if
  end if
  tService = me.getIGComponent(tID)
  if tService = 0 then
    return 0
  end if
  if tHoldUpdates = #hold_updates then
    tService.setActiveFlag(0)
  else
    tService.setActiveFlag(1)
  end if
  pActiveMode = tID
  return 1
end

on getActiveIGComponent me
  if pActiveMode = VOID then
    return 0
  end if
  return me.pIGComponents.getaProp(pActiveMode)
end

on getActiveIGComponentId me
  return pActiveMode
end

on Initialize me
  if pSystemState = 0 then
    me.getHandler().send_CHECK_DIRECTORY_STATUS()
  end if
end

on getInitialData me
  if pSystemState <> 0 then
    return 1
  end if
  repeat with i = 1 to pIGComponentProps.count
    tID = pIGComponentProps.getPropAt(i)
    if pIGComponentProps[i].findPos(#always_on) then
      tService = me.getIGComponent(tID)
    end if
  end repeat
  repeat with i = 1 to pIGComponents.count
    pIGComponents[i].Initialize()
  end repeat
  pActiveMode = "GameList"
  me.setSystemState(#ready)
  return 1
end

on leaveRoom me
  me.removeIGComponent("BottomBar")
  me.removeIGComponent("AfterGame")
  me.removeIGComponent("PreGame")
  case me.getSystemState() of
    #enter_arena:
      nothing()
    #pre_game, #in_game, #after_game:
      tService = me.getIGComponent("GameList")
      if tService = 0 then
        return 0
      end if
      tService.leaveJoinedGame(0)
      me.getHandler().send_EXIT_GAME(0)
      me.setSystemState(#ready)
      me.getInterface().resetToDefaultAndHide()
    otherwise:
      tService = me.getIGComponent("GameList")
      if tService = 0 then
        return 0
      end if
      if tService.getJoinedGameId() = -1 then
        me.getInterface().resetToDefaultAndHide()
      end if
  end case
  return 1
end

on enterRoom me
  if me.getSystemState() = #pre_game then
    return 1
  end if
  tService = me.getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  tJoinedGame = tService.getJoinedGame()
  if objectp(tJoinedGame) then
    me.getHandler().send_ROOM_GAME_STATUS(1, tJoinedGame.getProperty(#id), tJoinedGame.getProperty(#game_type))
  end if
end

on setSystemState me, tstate
  pSystemState = tstate
  return 1
end

on getSystemState me
  return pSystemState
end

on displayIGComponentEvent me, tID, tEventType, tEventData, tCreateIfMissing
  if tCreateIfMissing = 1 then
    tService = me.getIGComponent(tID)
  else
    tService = me.pIGComponents.getaProp(tID)
  end if
  if tService = 0 then
    return 0
  end if
  return tService.displayEvent(tEventType, tEventData)
end

on getIGComponent me, tID
  if tID = VOID then
    return error(me, "IGComponent" && tID && "not found!", #getIGComponent)
  end if
  if pIGComponents.findPos(tID) = 0 then
    if not me.createIGComponent(tID) then
      return error(me, "IGComponent" && tID && " could not be created!!", #Initialize)
    end if
  end if
  return pIGComponents.getaProp(tID)
end

on IGComponentExists me, tID
  return pIGComponents.findPos(tID) <> 0
end

on createIGComponent me, tID
  if tID = VOID then
    return 0
  end if
  tServiceId = "ig_" & tID
  if objectExists(tServiceId) then
    return 1
  end if
  tVarId = "ig.service." & tID & ".class"
  if variableExists(tVarId) then
    tObject = createObject(tServiceId, getClassVariable(tVarId))
  else
    tClass = ["IGComponent Base Class"]
    if memberExists("IG" && tID && "Class") then
      tClass.append("IG" && tID && "Class")
    end if
    tObject = createObject(tServiceId, tClass)
  end if
  if not objectp(tObject) then
    return error(me, "Unable to create" && tID && "component.", #construct)
  end if
  tObject.pMainThreadId = me.getID()
  tObject.pIGComponentId = tID
  tObject.Initialize()
  pIGComponents.setaProp(tID, tObject)
  return 1
end

on removeIGComponent me, tID
  tService = pIGComponents.getaProp(tID)
  if not objectp(tService) then
    return 1
  end if
  tService.setActiveFlag(0)
  tService.deconstruct()
  removeObject("ig_" & tID)
  pIGComponents.deleteProp(tID)
  return 1
end
