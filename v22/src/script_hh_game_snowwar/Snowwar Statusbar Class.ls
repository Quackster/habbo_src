property pBottomBarId, pMaxHealth, pMaxHealthBarHeight, pOrigHealthBarLoc, pLastHealth, pLastBallcount, pMaxBallcount, pBallCountAnimTimer, pBallCreateAnimTimer

on construct me
  pBallCountAnimTimer = 0
  pBallCreateAnimTimer = 0
  pBottomBarId = "RoomBarID"
  registerMessage(#roomReady, me.getID(), #replaceRoomBar)
  registerMessage(#updateInfostandAvatar, me.getID(), #updateRoomBarFigure)
  pMaxHealth = getIntVariable("snowwar.health.maximum")
  pMaxBallcount = getIntVariable("snowwar.snowball.maximum")
  pLastHealth = pMaxHealth
  return 1
end

on deconstruct me
  unregisterMessage(#roomReady, me.getID())
  unregisterMessage(#updateInfostandAvatar, me.getID())
  removeWindow(pBottomBarId)
  return 1
end

on Refresh me, tTopic, tdata
  case tTopic of
    #gamestart:
      return me.updateBallCount(pLastBallcount)
    #gameend:
      return me.setCreateButtonState("_off")
    #update_game_visuals:
      return me.updateGameVisuals()
    #statusbar_health_update:
      return me.updateHealth(tdata)
    #statusbar_ballcount_update:
      return me.updateBallCount(tdata)
    #statusbar_createball_started:
      return me.animateBallCreateStarted()
    #statusbar_createball_stopped:
      return me.updateBallCount(pLastBallcount)
    #statusbar_disable_buttons:
      return me.setCreateButtonState("_off")
  end case
  return 1
end

on update me
  if (pBallCountAnimTimer > 0) then
    me.animateBallCountFlashing()
  end if
  if (pBallCreateAnimTimer > 0) then
    me.animateBallCreateStarted()
  end if
end

on updateGameVisuals me
  if not getObject(#session).exists("user_game_index") then
    return 0
  end if
  tObjectID = getObject(#session).GET("user_game_index")
  tHealth = me.getGameSystem().getGameObjectProperty(tObjectID, #hit_points)
  tBallCount = me.getGameSystem().getGameObjectProperty(tObjectID, #snowball_count)
  me.updateHealth(tHealth)
  me.updateBallCount(tBallCount)
  return 1
end

on updateHealth me, tValue
  if (pMaxHealth = VOID) then
    return 0
  end if
  pLastHealth = tValue
  tWndObj = getWindow(pBottomBarId)
  if (tWndObj = 0) then
    return 0
  end if
  tElem = tWndObj.getElement("snowwar_bar_hit_points")
  if (tElem = 0) then
    return 0
  end if
  if (pOrigHealthBarLoc = VOID) then
    pOrigHealthBarLoc = point(tElem.getProperty(#locH), tElem.getProperty(#locV))
  end if
  tPercent = ((tValue * 1.0) / pMaxHealth)
  if (tPercent > 0.69999999999999996) then
    tmember = "ui_healthbar_green"
  else
    if (tPercent > 0.29999999999999999) then
      tmember = "ui_healthbar_yellow"
    else
      tmember = "ui_healthbar_red"
    end if
  end if
  if (tElem.getProperty(#member) <> tmember) then
    tElem.setProperty(#member, member(getmemnum(tmember)))
  end if
  tElemHeight = tElem.getProperty(#height)
  tElemLocV = tElem.getProperty(#locV)
  if (tValue = pMaxHealth) then
    pMaxHealthBarHeight = tElemHeight
  end if
  tHeightAdjust = integer(((tPercent * pMaxHealthBarHeight) - tElemHeight))
  tTotalAdjust = (pMaxHealthBarHeight - (tElemHeight + tHeightAdjust))
  tElem.resizeBy(0, tHeightAdjust)
  tElem.moveTo(pOrigHealthBarLoc.locH, (pOrigHealthBarLoc.locV + tTotalAdjust))
  return 1
end

on updateBallCount me, tValue
  if (pMaxBallcount = VOID) then
    return 0
  end if
  pLastBallcount = tValue
  tWndObj = getWindow(pBottomBarId)
  if (tWndObj = 0) then
    return 0
  end if
  repeat with tBallNum = 1 to pMaxBallcount
    tElem = tWndObj.getElement(("snowball_" & tBallNum))
    if (tElem <> 0) then
      tElem.setProperty(#visible, (tBallNum <= tValue))
    end if
  end repeat
  case tValue of
    pMaxBallcount:
      return me.setCreateButtonState("_off")
    0:
      if (pLastHealth = 0) then
        return 1
      end if
      return me.animateBallCountFlashing()
  end case
  return me.setCreateButtonState(EMPTY)
end

on animateBallCountFlashing me
  if (pBallCountAnimTimer = 0) then
    pBallCountAnimTimer = 1
    receiveUpdate(me.getID())
  else
    if (pBallCountAnimTimer >= 50) then
      removeUpdate(me.getID())
      pBallCountAnimTimer = 0
    else
      pBallCountAnimTimer = (pBallCountAnimTimer + 1)
    end if
  end if
  tWndObj = getWindow(pBottomBarId)
  if (tWndObj = 0) then
    return 0
  end if
  tMemNum = (1 + ((pBallCountAnimTimer / 4) mod 2))
  tMemName = ["ui_snowball_slots", "ui_snowball_slots_hilite"][tMemNum]
  tElem = tWndObj.getElement("int_alapalkki_balls_bg")
  if (tElem = 0) then
    return 0
  end if
  if (tElem.getProperty(#member).name = tMemName) then
    return 1
  end if
  tElem.setProperty(#member, member(getmemnum(tMemName)))
  tMemName = [EMPTY, "_hilite"][tMemNum]
  me.setCreateButtonState(tMemName)
  return 1
end

on animateBallCreateStarted me
  if (pBallCreateAnimTimer = 0) then
    pBallCreateAnimTimer = 1
    me.setCreateButtonState("_pressed")
    receiveUpdate(me.getID())
  else
    if (pBallCreateAnimTimer >= 3) then
      removeUpdate(me.getID())
      me.setCreateButtonState("_off")
      pBallCreateAnimTimer = 0
    else
      pBallCreateAnimTimer = (pBallCreateAnimTimer + 1)
    end if
  end if
end

on setCreateButtonState me, tstate
  tWndObj = getWindow(pBottomBarId)
  if (tWndObj = 0) then
    return 0
  end if
  tElem = tWndObj.getElement("snowwar_button_create")
  if (tElem = 0) then
    return 0
  end if
  tMemName = ("ui_makesnowballgreen" & tstate)
  if (tElem.getProperty(#member).name = tMemName) then
    return 1
  end if
  tMemNum = getmemnum(tMemName)
  if (tMemNum = 0) then
    return 0
  end if
  tsprite = tElem.getProperty(#sprite)
  if (tsprite <> 0) then
    if (tstate = "_off") then
      tsprite.setcursor(0)
    else
      tsprite.setcursor("cursor.finger")
    end if
  end if
  tElem.setProperty(#member, member(tMemNum))
  return 1
end

on updateSoundIcon me
  tWndObj = getWindow(pBottomBarId)
  if (tWndObj = 0) then
    return 0
  end if
  tElem = tWndObj.getElement("gs_int_sound_image")
  if (tElem = 0) then
    return 0
  end if
  if getSoundState() then
    tMemName = "sw_soundon"
  else
    tMemName = "sw_soundoff"
  end if
  tmember = member(getmemnum(tMemName))
  if (tmember.type = #bitmap) then
    tElem.feedImage(tmember.image)
  end if
  return 1
end

on replaceRoomBar me
  tSpectator = me.getGameSystem().getSpectatorModeFlag()
  if tSpectator then
    return 1
  end if
  removeWindow(pBottomBarId)
  createWindow(pBottomBarId, "empty.window", 0, 471)
  tWndObj = getWindow(pBottomBarId)
  if (tWndObj = 0) then
    return 0
  end if
  tWndObj.lock(1)
  tWndObj.unmerge()
  tLayout = "sw_ui.window"
  if not tWndObj.merge(tLayout) then
    return 0
  end if
  me.updateRoomBarFigure()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #keyDown)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseEnter)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseLeave)
  me.updateSoundIcon()
  me.setCreateButtonState("_off")
  return 1
end

on updateRoomBarFigure me
  tSpectator = me.getGameSystem().getSpectatorModeFlag()
  if (not tSpectator and objectExists("Figure_Preview")) then
    getObject("Figure_Preview").createHumanPartPreview(pBottomBarId, "snowwar_avatar_face", #head)
  end if
end

on eventProcRoomBar me, tEvent, tSprID, tParam
  if (tEvent = #mouseUp) then
    case tSprID of
      "snowwar_button_create":
        if not getObject(#session).exists("user_game_index") then
          return 0
        end if
        return me.getGameSystem().executeGameObjectEvent(getObject(#session).GET("user_game_index"), #send_create_snowball)
      "gs_int_sound_image":
        setSoundState(not getSoundState())
        return me.updateSoundIcon()
    end case
  end if
  tRoomInt = getObject("RoomBarProgram")
  if (tRoomInt = 0) then
    return 0
  end if
  return tRoomInt.eventProcRoomBar(tEvent, tSprID, tParam)
end
