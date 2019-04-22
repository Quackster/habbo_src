property pMaxHealth, pBottomBarId, pLastBallcount, pBallCountAnimTimer, pBallCreateAnimTimer, pOrigHealthBarLoc, pMaxHealthBarHeight, pMaxBallcount, pLastHealth

on construct me 
  pBallCountAnimTimer = 0
  pBallCreateAnimTimer = 0
  tRoomInt = getObject(#room_interface)
  if tRoomInt = 0 then
    return(0)
  end if
  pBottomBarId = tRoomInt.pBottomBarId
  registerMessage(#roomReady, me.getID(), #replaceRoomBar)
  pMaxHealth = getIntVariable("snowwar.health.maximum")
  pMaxBallcount = getIntVariable("snowwar.snowball.maximum")
  pLastHealth = pMaxHealth
  return(1)
end

on deconstruct me 
  unregisterMessage(#roomReady, me.getID())
  removeWindow(pBottomBarId)
  return(1)
end

on Refresh me, tTopic, tdata 
  if tTopic = #gamestart then
    return(me.updateBallCount(pLastBallcount))
  else
    if tTopic = #gameend then
      return(me.setCreateButtonState("_off"))
    else
      if tTopic = #update_game_visuals then
        return(me.updateGameVisuals())
      else
        if tTopic = #statusbar_health_update then
          return(me.updateHealth(tdata))
        else
          if tTopic = #statusbar_ballcount_update then
            return(me.updateBallCount(tdata))
          else
            if tTopic = #statusbar_createball_started then
              return(me.animateBallCreateStarted())
            else
              if tTopic = #statusbar_createball_stopped then
                return(me.updateBallCount(pLastBallcount))
              else
                if tTopic = #statusbar_disable_buttons then
                  return(me.setCreateButtonState("_off"))
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return(1)
end

on update me 
  if pBallCountAnimTimer > 0 then
    me.animateBallCountFlashing()
  end if
  if pBallCreateAnimTimer > 0 then
    me.animateBallCreateStarted()
  end if
end

on updateGameVisuals me 
  if not getObject(#session).exists("user_game_index") then
    return(0)
  end if
  tObjectID = getObject(#session).get("user_game_index")
  tHealth = me.getGameSystem().getGameObjectProperty(tObjectID, #hit_points)
  tBallCount = me.getGameSystem().getGameObjectProperty(tObjectID, #snowball_count)
  me.updateHealth(tHealth)
  me.updateBallCount(tBallCount)
  return(1)
end

on updateHealth me, tValue 
  if pMaxHealth = void() then
    return(0)
  end if
  pLastHealth = tValue
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("snowwar_bar_hit_points")
  if tElem = 0 then
    return(0)
  end if
  if pOrigHealthBarLoc = void() then
    pOrigHealthBarLoc = point(tElem.getProperty(#locH), tElem.getProperty(#locV))
  end if
  tPercent = tValue * 1 / pMaxHealth
  if tPercent > 0.7 then
    tmember = "ui_healthbar_green"
  else
    if tPercent > 0.3 then
      tmember = "ui_healthbar_yellow"
    else
      tmember = "ui_healthbar_red"
    end if
  end if
  if tElem.getProperty(#member) <> tmember then
    tElem.setProperty(#member, member(getmemnum(tmember)))
  end if
  tElemHeight = tElem.getProperty(#height)
  tElemLocV = tElem.getProperty(#locV)
  if tValue = pMaxHealth then
    pMaxHealthBarHeight = tElemHeight
  end if
  tHeightAdjust = integer(tPercent * pMaxHealthBarHeight - tElemHeight)
  tTotalAdjust = pMaxHealthBarHeight - tElemHeight + tHeightAdjust
  tElem.resizeBy(0, tHeightAdjust)
  tElem.moveTo(pOrigHealthBarLoc.locH, pOrigHealthBarLoc.locV + tTotalAdjust)
  return(1)
end

on updateBallCount me, tValue 
  if pMaxBallcount = void() then
    return(0)
  end if
  pLastBallcount = tValue
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return(0)
  end if
  tBallNum = 1
  repeat while tBallNum <= pMaxBallcount
    tElem = tWndObj.getElement("snowball_" & tBallNum)
    if tElem <> 0 then
      tElem.setProperty(#visible, tBallNum <= tValue)
    end if
    tBallNum = 1 + tBallNum
  end repeat
  if tValue = pMaxBallcount then
    return(me.setCreateButtonState("_off"))
  else
    if tValue = 0 then
      if pLastHealth = 0 then
        return(1)
      end if
      return(me.animateBallCountFlashing())
    else
      return(me.setCreateButtonState(""))
    end if
  end if
end

on animateBallCountFlashing me 
  if pBallCountAnimTimer = 0 then
    pBallCountAnimTimer = 1
    receiveUpdate(me.getID())
  else
    if pBallCountAnimTimer >= 50 then
      removeUpdate(me.getID())
      pBallCountAnimTimer = 0
    else
      pBallCountAnimTimer = pBallCountAnimTimer + 1
    end if
  end if
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return(0)
  end if
  tMemNum = 1 + pBallCountAnimTimer / 4 mod 2
  tMemName = ["ui_snowball_slots", "ui_snowball_slots_hilite"].getAt(tMemNum)
  tElem = tWndObj.getElement("int_alapalkki_balls_bg")
  if tElem = 0 then
    return(0)
  end if
  if tElem.getProperty(#member).name = tMemName then
    return(1)
  end if
  tElem.setProperty(#member, member(getmemnum(tMemName)))
  tMemName = ["", "_hilite"].getAt(tMemNum)
  me.setCreateButtonState(tMemName)
  return(1)
end

on animateBallCreateStarted me 
  if pBallCreateAnimTimer = 0 then
    pBallCreateAnimTimer = 1
    me.setCreateButtonState("_pressed")
    receiveUpdate(me.getID())
  else
    if pBallCreateAnimTimer >= 3 then
      removeUpdate(me.getID())
      me.setCreateButtonState("_off")
      pBallCreateAnimTimer = 0
    else
      pBallCreateAnimTimer = pBallCreateAnimTimer + 1
    end if
  end if
end

on setCreateButtonState me, tstate 
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("snowwar_button_create")
  if tElem = 0 then
    return(0)
  end if
  tMemName = "ui_makesnowballgreen" & tstate
  if tElem.getProperty(#member).name = tMemName then
    return(1)
  end if
  tMemNum = getmemnum(tMemName)
  if tMemNum = 0 then
    return(0)
  end if
  tsprite = tElem.getProperty(#sprite)
  if tsprite <> 0 then
    if tstate = "_off" then
      tsprite.setcursor(0)
    else
      tsprite.setcursor("cursor.finger")
    end if
  end if
  tElem.setProperty(#member, member(tMemNum))
  return(1)
end

on updateSoundIcon me 
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("gs_int_sound_image")
  if tElem = 0 then
    return(0)
  end if
  if getSoundState() then
    tMemName = "sw_soundon"
  else
    tMemName = "sw_soundoff"
  end if
  tmember = member(getmemnum(tMemName))
  if tmember.type = #bitmap then
    tElem.feedImage(tmember.image)
  end if
  return(1)
end

on replaceRoomBar me 
  tSpectator = me.getGameSystem().getSpectatorModeFlag()
  if tSpectator then
    return(1)
  end if
  removeWindow(pBottomBarId)
  createWindow(pBottomBarId, "empty.window", 0, 471)
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return(0)
  end if
  tWndObj.lock(1)
  tWndObj.unmerge()
  tLayout = "sw_ui.window"
  if not tWndObj.merge(tLayout) then
    return(0)
  end if
  if not tSpectator and objectExists("Figure_Preview") then
    getObject("Figure_Preview").createHumanPartPreview(pBottomBarId, "snowwar_avatar_face", ["hd", "fc", "ey", "hr"])
  end if
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #keyDown)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseEnter)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseLeave)
  me.updateSoundIcon()
  me.setCreateButtonState("_off")
  return(1)
end

on eventProcRoomBar me, tEvent, tSprID, tParam 
  if tEvent = #mouseUp then
    if tSprID = "snowwar_button_create" then
      if not getObject(#session).exists("user_game_index") then
        return(0)
      end if
      return(me.getGameSystem().executeGameObjectEvent(getObject(#session).get("user_game_index"), #send_create_snowball))
    else
      if tSprID = "gs_int_sound_image" then
        setSoundState(not getSoundState())
        return(me.updateSoundIcon())
      end if
    end if
  end if
  tRoomInt = getObject(#room_interface)
  if tRoomInt = 0 then
    return(0)
  end if
  return(tRoomInt.eventProcRoomBar(tEvent, tSprID, tParam))
end
