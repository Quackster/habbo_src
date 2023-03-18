property pWindowID, pTimeOutID, pCountdownMember, pDuration, pEndTime

on construct me
  pWindowID = getText("gs_title_countdown")
  pTimeOutID = "game_countdown_timeout"
  return 1
end

on deconstruct me
  return me.removeGameCountdown()
end

on Refresh me, tTopic, tdata
  case tTopic of
    #gamereset:
      return me.startGameCountdown(tdata[#time_until_game_start], 0)
    #fullgamestatus_time:
      if tdata[#state] = #started then
        return me.removeGameCountdown()
      end if
      return me.startGameCountdown(tdata[#time_to_next_state], tdata[#state_duration] - tdata[#time_to_next_state])
    #gamestart:
      playSound("LS-C64-draw-1", VOID, [#volume: 170])
      return me.removeGameCountdown()
  end case
  return 1
end

on startGameCountdown me, tSecondsLeft, tSecondsNowElapsed
  tMSecLeft = tSecondsLeft * 1000
  tDuration = (tSecondsLeft + tSecondsNowElapsed) * 1000
  if tMSecLeft <= 0 then
    return 0
  end if
  pDuration = tDuration
  pEndTime = the milliSeconds + tMSecLeft
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
    if tElem = 0 then
      return 0
    end if
    if me.getGameSystem() = 0 then
      return 0
    end if
    tNumTickets = string(me.getGameSystem().getNumTickets())
    if tNumTickets.length = 1 then
      tNumTickets = "00" & tNumTickets
    end if
    if tNumTickets.length = 2 then
      tNumTickets = "0" & tNumTickets
    end if
    tElem.setText(tNumTickets)
    return 1
  else
    return 0
  end if
end

on setBar me
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return me.removeGameCountdown()
  end if
  tElem = tWndObj.getElement("gs_bar_cntDwn")
  if the milliSeconds >= pEndTime then
    return me.removeGameCountdown()
  end if
  tProc = (pEndTime - the milliSeconds) / float(pDuration)
  tNextWidth = 159 * tProc
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
  tElem.resizeBy(integer(tNextWidth) - tCurrWidth, 0)
  return 1
end

on removeGameCountdown me
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  return 1
end

on eventProc me, tEvent, tSprID, tParam
  case tSprID of
    "gs_button_leavegame":
      if me.getGameSystem() = 0 then
        return 0
      end if
      me.removeGameCountdown()
      return me.getGameSystem().enterLounge()
  end case
end
