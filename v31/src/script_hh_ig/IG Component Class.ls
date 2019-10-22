property pIGComponents, pActiveMode, pIGComponentProps, pSystemState

on construct me 
  pSystemState = 0
  pIGComponents = [:]
  registerMessage(#userloggedin, me.getID(), #Initialize)
  registerMessage(#leaveRoom, me.getID(), #leaveRoom)
  registerMessage(#changeRoom, me.getID(), #leaveRoom)
  registerMessage(#roomReady, me.getID(), #enterRoom)
  pIGComponentProps = ["GameList":[#always_on], "LevelList":[#always_on], "GameData":[#always_on]]
  return TRUE
end

on deconstruct me 
  pSystemState = 0
  unregisterMessage(#userloggedin, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#roomReady, me.getID())
  repeat while pIGComponents <= undefined
    tObject = getAt(undefined, undefined)
    tObject = void()
  end repeat
  pIGComponents = void()
  return TRUE
end

on setActiveIGComponent me, tID, tHoldUpdates 
  tService = me.getComponent().getActiveIGComponent()
  if tService <> 0 and tID <> pActiveMode then
    tService.setActiveFlag(0)
    tProps = pIGComponentProps.getaProp(pActiveMode)
    if listp(tProps) then
      if not tProps.findPos(#always_on) then
        removeIGComponent(pActiveMode)
      end if
    end if
  end if
  tService = me.getIGComponent(tID)
  if (tService = 0) then
    return FALSE
  end if
  if (tHoldUpdates = #hold_updates) then
    tService.setActiveFlag(0)
  else
    tService.setActiveFlag(1)
  end if
  pActiveMode = tID
  return TRUE
end

on getActiveIGComponent me 
  if (pActiveMode = void()) then
    return FALSE
  end if
  return(me.pIGComponents.getaProp(pActiveMode))
end

on getActiveIGComponentId me 
  return(pActiveMode)
end

on Initialize me 
  if (pSystemState = 0) then
    me.getHandler().send_CHECK_DIRECTORY_STATUS()
  end if
end

on getInitialData me 
  if pSystemState <> 0 then
    return TRUE
  end if
  i = 1
  repeat while i <= pIGComponentProps.count
    tID = pIGComponentProps.getPropAt(i)
    if pIGComponentProps.getAt(i).findPos(#always_on) then
      tService = me.getIGComponent(tID)
    end if
    i = (1 + i)
  end repeat
  i = 1
  repeat while i <= pIGComponents.count
    pIGComponents.getAt(i).Initialize()
    i = (1 + i)
  end repeat
  pActiveMode = "GameList"
  me.setSystemState(#ready)
  return TRUE
end

on leaveRoom me 
  me.removeIGComponent("BottomBar")
  me.removeIGComponent("AfterGame")
  me.removeIGComponent("PreGame")
  if (me.getSystemState() = #enter_arena) then
    nothing()
  else
    if me.getSystemState() <> #pre_game then
      if me.getSystemState() <> #in_game then
        if (me.getSystemState() = #after_game) then
          tService = me.getIGComponent("GameList")
          if (tService = 0) then
            return FALSE
          end if
          tService.leaveJoinedGame(0)
          me.getHandler().send_EXIT_GAME(0)
          me.setSystemState(#ready)
          me.getInterface().resetToDefaultAndHide()
        else
          tService = me.getIGComponent("GameList")
          if (tService = 0) then
            return FALSE
          end if
          if (tService.getJoinedGameId() = -1) then
            me.getInterface().resetToDefaultAndHide()
          end if
        end if
        return TRUE
      end if
    end if
  end if
end

on enterRoom me 
  if (me.getSystemState() = #pre_game) then
    return TRUE
  end if
  tService = me.getIGComponent("GameList")
  if (tService = 0) then
    return FALSE
  end if
  tJoinedGame = tService.getJoinedGame()
  if objectp(tJoinedGame) then
    me.getHandler().send_ROOM_GAME_STATUS(1, tJoinedGame.getProperty(#id), tJoinedGame.getProperty(#game_type))
  end if
end

on setSystemState me, tstate 
  pSystemState = tstate
  return TRUE
end

on getSystemState me 
  return(pSystemState)
end

on displayIGComponentEvent me, tID, tEventType, tEventData, tCreateIfMissing 
  if (tCreateIfMissing = 1) then
    tService = me.getIGComponent(tID)
  else
    tService = me.pIGComponents.getaProp(tID)
  end if
  if (tService = 0) then
    return FALSE
  end if
  return(tService.displayEvent(tEventType, tEventData))
end

on getIGComponent me, tID 
  if (tID = void()) then
    return(error(me, "IGComponent" && tID && "not found!", #getIGComponent))
  end if
  if (pIGComponents.findPos(tID) = 0) then
    if not me.createIGComponent(tID) then
      return(error(me, "IGComponent" && tID && " could not be created!!", #Initialize))
    end if
  end if
  return(pIGComponents.getaProp(tID))
end

on IGComponentExists me, tID 
  return(pIGComponents.findPos(tID) <> 0)
end

on createIGComponent me, tID 
  if (tID = void()) then
    return FALSE
  end if
  tServiceId = "ig_" & tID
  if objectExists(tServiceId) then
    return TRUE
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
    return(error(me, "Unable to create" && tID && "component.", #construct))
  end if
  tObject.pMainThreadId = me.getID()
  tObject.pIGComponentId = tID
  tObject.Initialize()
  pIGComponents.setaProp(tID, tObject)
  return TRUE
end

on removeIGComponent me, tID 
  tService = pIGComponents.getaProp(tID)
  if not objectp(tService) then
    return TRUE
  end if
  tService.setActiveFlag(0)
  tService.deconstruct()
  removeObject("ig_" & tID)
  pIGComponents.deleteProp(tID)
  return TRUE
end
