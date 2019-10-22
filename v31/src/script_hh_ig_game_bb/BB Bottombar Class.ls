property pBottomBarId, pCarriedPowerupType, pCarriedPowerupId, pUpdateCounter, pCarriedPowerupTimeToLive

on construct me 
  pUpdateCounter = 0
  pCarriedPowerupId = 0
  pCarriedPowerupType = 0
  pCarriedPowerupTimeToLive = 0
  pBottomBarId = "RoomBarID"
  registerMessage(#roomReady, me.getID(), #replaceRoomBar)
  registerMessage(#updateInfostandAvatar, me.getID(), #updateRoomBarFigure)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#roomReady, me.getID())
  unregisterMessage(#updateInfostandAvatar, me.getID())
  removeWindow(pBottomBarId)
  return TRUE
end

on Refresh me, tTopic, tdata 
  if (tTopic = #bb_event_1) then
    if (pCarriedPowerupType = 0) then
      return TRUE
    end if
    if (tdata.getAt(#id) = pCarriedPowerupId) then
      return(me.clearBottomBarPowerup())
    end if
  else
    if (tTopic = #bb_event_3) then
      tGameSystem = me.getGameSystem()
      if (tGameSystem = 0) then
        return FALSE
      end if
      if tGameSystem.getSpectatorModeFlag() then
        return TRUE
      end if
      if tdata.getAt(#playerId) <> me.getOwnGameIndex() then
        return TRUE
      end if
      pCarriedPowerupId = tdata.getAt(#powerupid)
      pCarriedPowerupType = tdata.getAt(#powerupType)
      pCarriedPowerupTimeToLive = tGameSystem.getGameObjectProperty(pCarriedPowerupId, #timetolive)
      receiveUpdate(me.getID())
      me.setActivateButton(pCarriedPowerupType)
    else
      if (tTopic = #bb_event_5) then
        tGameSystem = me.getGameSystem()
        if (tGameSystem = 0) then
          return FALSE
        end if
        if me.getGameSystem().getSpectatorModeFlag() then
          return TRUE
        end if
        if tdata.getAt(#playerId) <> me.getOwnGameIndex() then
          return TRUE
        end if
        return(me.clearBottomBarPowerup())
      else
        if (tTopic = #gameend) then
          return(me.clearBottomBarPowerup())
        end if
      end if
    end if
  end if
  return TRUE
end

on update me 
  pUpdateCounter = (pUpdateCounter + 1)
  if pUpdateCounter < 2 then
    return TRUE
  end if
  pUpdateCounter = 0
  if pCarriedPowerupTimeToLive > 0 then
    me.animatePowerupTimer()
  end if
end

on animatePowerupTimer me 
  tObjectTimeToLive = me.getGameSystem().getGameObjectProperty(pCarriedPowerupId, #timetolive)
  if (tObjectTimeToLive = pCarriedPowerupTimeToLive) then
    return TRUE
  end if
  pCarriedPowerupTimeToLive = tObjectTimeToLive
  me.updatePowerupTimer(pCarriedPowerupTimeToLive)
end

on clearBottomBarPowerup me 
  removeUpdate(me.getID())
  pCarriedPowerupType = 0
  pCarriedPowerupTimeToLive = 0
  me.setActivateButton(0)
  me.updatePowerupTimer(-1)
  return TRUE
end

on activateButtonPressed me 
  if (pCarriedPowerupType = 0) then
    return TRUE
  end if
  tGameSystem = me.getGameSystem()
  if (tGameSystem = 0) then
    return FALSE
  end if
  tGameSystem.sendGameEventMessage([#integer:4, #integer:pCarriedPowerupId])
  return(me.clearBottomBarPowerup())
end

on setActivateButton me, tstate 
  if me.getGameSystem().getSpectatorModeFlag() then
    return TRUE
  end if
  tWndObj = getWindow(pBottomBarId)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("bb2_button_powerup")
  if (tElem = 0) then
    return FALSE
  end if
  tsprite = tElem.getProperty(#sprite)
  if (tstate = 6) then
    tTeamId = me.getGameSystem().getGameObjectProperty(me.getOwnGameIndex(), #teamId)
    tMemNum = getmemnum("bb2_button_pwrup_" & tstate & "_" & tTeamId)
  else
    tMemNum = getmemnum("bb2_button_pwrup_" & tstate)
  end if
  if tMemNum <= 0 then
    return(error(me, "Unable to locate image for powerup button:" && tstate, #setActivateButton))
  end if
  if tsprite.ilk <> #sprite then
    return(error(me, "Unable to locate sprite for powerup button", #setActivateButton))
  end if
  tElem.feedImage(member(tMemNum).image)
  if tstate > 0 then
    tsprite.setcursor("cursor.finger")
  else
    tsprite.setcursor(0)
  end if
  return TRUE
end

on updatePowerupTimer me, tstate 
  tWndObj = getWindow(pBottomBarId)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("bb2_image_powerup_timer")
  if (tElem = 0) then
    return FALSE
  end if
  tsprite = tElem.getProperty(#sprite)
  if tsprite.ilk <> #sprite then
    return(error(me, "Unable to locate sprite for powerup timer", #updatePowerupTimer))
  end if
  if tstate > 11 then
    tstate = 11
  end if
  if (tstate = 5) then
    me.sendGameSystemEvent(#soundeffect, "5sec-powerup-activation-v1")
  end if
  tMemNum = getmemnum("bb2_timer_pwrup_" & tstate)
  return(tsprite.setMember(member(tMemNum)))
end

on replaceRoomBar me 
  if me.getGameSystem().getSpectatorModeFlag() then
    return TRUE
  end if
  removeWindow(pBottomBarId)
  createWindow(pBottomBarId, "empty.window", 0, 483)
  tWndObj = getWindow(pBottomBarId)
  if (tWndObj = 0) then
    return FALSE
  end if
  tWndObj.lock(1)
  tWndObj.unmerge()
  tLayout = "bb2_ui.window"
  if not tWndObj.merge(tLayout) then
    return FALSE
  end if
  me.updateRoomBarFigure()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #keyDown)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseEnter)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseLeave)
  me.setActivateButton(0)
  me.updateSoundButton()
  tElem = tWndObj.getElement("chat_field")
  if (tElem = 0) then
    return FALSE
  end if
  updateStage()
  tElem.setEdit(1)
  return(tElem.setFocus(1))
  return TRUE
end

on updateSoundButton me 
  pBottomBarId = "RoomBarID"
  tWndObj = getWindow(pBottomBarId)
  if (tWndObj = 0) then
    return FALSE
  end if
  tstate = getSoundState()
  tElem = tWndObj.getElement("int_sound_image")
  if tElem <> 0 then
    if tstate then
      tMemNum = getmemnum("sounds_small_on_icon")
      if tMemNum > 0 then
        tElem.feedImage(member(tMemNum).image)
      end if
    else
      tMemNum = getmemnum("sounds_small_off_icon")
      if tMemNum > 0 then
        tElem.feedImage(member(tMemNum).image)
      end if
    end if
  end if
end

on eventProcRoomBar me, tEvent, tSprID, tParam 
  if (tSprID = "bb2_button_powerup") then
    if tEvent <> #mouseUp then
      return FALSE
    end if
    return(me.activateButtonPressed())
  else
    if (tSprID = "game_rules_image") then
      if (tSprID = #mouseUp) then
        return(executeMessage(#ig_show_game_rules))
      else
        if (tSprID = #mouseEnter) then
          return(executeMessage(#setRollOverInfo, getText("interface_icon_game_rules")))
        else
          if (tSprID = #mouseLeave) then
            return(executeMessage(#setRollOverInfo, ""))
          end if
        end if
      end if
    end if
  end if
  if (tEvent = #keyDown) then
    if (the key = "\t") or (the keyCode = 125) then
      return(me.activateButtonPressed())
    end if
  end if
  tRoomBarObj = getObject("RoomBarProgram")
  if (tRoomBarObj = 0) then
    return FALSE
  end if
  if (tEvent = #keyDown) and (tSprID = "chat_field") then
    tChatField = getWindow(tRoomBarObj.pBottomBarId).getElement(tSprID)
    if the commandDown and (the keyCode = 8) or (the keyCode = 9) then
      if not getObject(#session).GET("user_rights").getOne("fuse_debug_window") then
        tChatField.setText("")
        return TRUE
      end if
    end if
    tKeyCode = the keyCode
    if tSprID <> 36 then
      if (tSprID = 76) then
        if (tChatField.getText() = "") then
          return TRUE
        end if
        if tRoomBarObj.pFloodblocking then
          if the milliSeconds < tRoomBarObj.pFloodTimer then
            return FALSE
          else
            tRoomBarObj.pFloodEnterCount = void()
          end if
        end if
        if voidp(tRoomBarObj.pFloodEnterCount) then
          tRoomBarObj.pFloodEnterCount = 0
          tRoomBarObj.pFloodblocking = 0
          tRoomBarObj.pFloodTimer = the milliSeconds
        else
          tRoomBarObj.pFloodEnterCount = (tRoomBarObj.pFloodEnterCount + 1)
          tFloodCountLimit = 2
          tFloodTimerLimit = 3000
          tFloodTimeout = 30000
          if tRoomBarObj.pFloodEnterCount > tFloodCountLimit then
            if the milliSeconds < (tRoomBarObj.pFloodTimer + tFloodTimerLimit) then
              tChatField.setText("")
              createObject("FloodBlocking", "Flood Blocking Class")
              getObject("FloodBlocking").Init(tRoomBarObj.pBottomBarId, tSprID, tFloodTimeout)
              tRoomBarObj.pFloodblocking = 1
              tRoomBarObj.pFloodTimer = (the milliSeconds + tFloodTimeout)
            else
              tRoomBarObj.pFloodEnterCount = void()
            end if
          end if
        end if
        getConnection(#info).send("GAME_CHAT", [#string:tChatField.getText()])
      end if
      return(tRoomBarObj.eventProcRoomBar(tEvent, tSprID, tParam))
    end if
  end if
end

on getOwnGameIndex me 
  tSession = getObject(#session)
  if not tSession.exists("user_game_index") then
    return FALSE
  end if
  return(tSession.GET("user_game_index"))
end

on updateRoomBarFigure me 
  if objectExists("Figure_Preview") then
    getObject("Figure_Preview").createHumanPartPreview(pBottomBarId, "ownhabbo_icon_image", #head)
  end if
end
