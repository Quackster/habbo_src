property pWindowID, pTimeOutID, pEndTime, pDuration, pCountdownMember

on construct me 
  pWindowID = getText("gs_title_countdown")
  pTimeOutID = "game_countdown_timeout"
  return TRUE
end

on deconstruct me 
  return(me.removeGameCountdown())
end

on Refresh me, tTopic, tdata 
  if (tTopic = #gamereset) then
    return(me.startGameCountdown(tdata.getAt(#time_until_game_start), 0))
  else
    if (tTopic = #fullgamestatus_time) then
      if (tdata.getAt(#state) = #started) then
        return(me.removeGameCountdown())
      end if
      return(me.startGameCountdown(tdata.getAt(#time_to_next_state), (tdata.getAt(#state_duration) - tdata.getAt(#time_to_next_state))))
    else
      if (tTopic = #gamestart) then
        playSound("LS-C64-draw-1", void(), [#volume:170])
        return(me.removeGameCountdown())
      end if
    end if
  end if
  return TRUE
end

on startGameCountdown me, tSecondsLeft, tSecondsNowElapsed 
  tMSecLeft = (tSecondsLeft * 1000)
  tDuration = ((tSecondsLeft + tSecondsNowElapsed) * 1000)
  if tMSecLeft <= 0 then
    return FALSE
  end if
  pDuration = tDuration
  pEndTime = (the milliSeconds + tMSecLeft)
  if createWindow(pWindowID, "sw_cdown.window") then
    tWndObj = getWindow(pWindowID)
    if me.getGameSystem().getSpectatorModeFlag() then
      tWndObj.getElement("gs_button_leavegame").hide()
    else
    end if
    tWndObj.center()
    if me.getGameSystem().getTournamentFlag() then
      if tWndObj.elementExists("sw_gameprice") then
        tWndObj.getElement("sw_gameprice").hide()
      end if
    end if
    tElem = tWndObj.getElement("gs_bar_cntDwn")
    tElem.setProperty(#member, member(getmemnum("sw_scrbar_4")))
    tElem.resizeTo(159, 13)
    me.setBar(0)
    tWndObj.lock()
    tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
    if timeoutExists(pTimeOutID) then
      removeTimeout(pTimeOutID)
    end if
    createTimeout(pTimeOutID, 300, #setBar, me.getID())
    tElem = tWndObj.getElement("gs_numtickets")
    if (tElem = 0) then
      return FALSE
    end if
    if (me.getGameSystem() = 0) then
      return FALSE
    end if
    tNumTickets = string(me.getGameSystem().getNumTickets())
    if (tNumTickets.length = 1) then
      tNumTickets = "00" & tNumTickets
    end if
    if (tNumTickets.length = 2) then
      tNumTickets = "0" & tNumTickets
    end if
    tElem.setText(tNumTickets)
    return TRUE
  else
    return FALSE
  end if
end

on setBar me 
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return(me.removeGameCountdown())
  end if
  tElem = tWndObj.getElement("gs_bar_cntDwn")
  if the milliSeconds >= pEndTime then
    return(me.removeGameCountdown())
  end if
  tProc = ((pEndTime - the milliSeconds) / float(pDuration))
  tNextWidth = (159 * tProc)
  tCurrWidth = tElem.getProperty(#width)
  if tNextWidth < 80 then
    if tNextWidth < 39 then
      tmember = "sw_scrbar_1"
    else
      tmember = "sw_scrbar_3"
    end if
  else
    tmember = "sw_scrbar_4"
  end if
  tSpr = tElem.getProperty(#sprite)
  if pCountdownMember <> tmember then
    pCountdownMember = tmember
    tElem.setProperty(#member, member(getmemnum(tmember)))
  end if
  tElem.resizeBy((integer(tNextWidth) - tCurrWidth), 0)
  return TRUE
end

on removeGameCountdown me 
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  return TRUE
end

on eventProc me, tEvent, tSprID, tParam 
  if (tSprID = "gs_button_leavegame") then
    if (me.getGameSystem() = 0) then
      return FALSE
    end if
    me.removeGameCountdown()
    return(me.getGameSystem().enterLounge())
  end if
end
