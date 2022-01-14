property pHubuWndID, pTimerStart, pTimerBarHeight, pTimerBarLocY

on construct me 
  pHubuWndID = getText("hubu_win", "Hubu")
  return TRUE
end

on deconstruct me 
  removeUpdate(me.getID())
  if windowExists(pHubuWndID) then
    removeWindow(pHubuWndID)
  end if
  return TRUE
end

on showBusClosed me, tMsg 
  if windowExists(pHubuWndID) then
    removeWindow(pHubuWndID)
  end if
  createWindow(pHubuWndID, "habbo_basic.window")
  tWndObj = getWindow(pHubuWndID)
  tWndObj.merge("hubu_bus_notopen.window")
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcHubu, me.getID(), #mouseUp)
  tWndObj.getElement("hubunote_txt").setText(tMsg)
  if not getText("hubu_info_url_1") starts "http://" then
    tWndObj.getElement("hubu_info_link1").setProperty(#visible, 0)
  end if
  if not getText("hubu_info_url_2") starts "http://" then
    tWndObj.getElement("hubu_info_link2").setProperty(#visible, 0)
  end if
  return TRUE
end

on showVoteQuestion me, tQuestion, tChoiceList 
  if windowExists(pHubuWndID) then
    removeWindow(pHubuWndID)
  end if
  createWindow(pHubuWndID, "hubu_poll.window")
  tWndObj = getWindow(pHubuWndID)
  tWndObj.moveTo(6, 306)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcHubu, me.getID(), #mouseUp)
  tWndObj.getElement("hubu_q").setText(tQuestion)
  i = 1
  repeat while i <= tChoiceList.count
    tWndObj.getElement("hubu_a" & i).setText(tChoiceList.getAt(i))
    tWndObj.getElement("button_" & i).setProperty(#blend, 100)
    i = (1 + i)
  end repeat
  pTimerStart = the milliSeconds
  pTimerBarHeight = tWndObj.getElement("time_bar").getProperty(#height)
  pTimerBarLocY = tWndObj.getElement("time_bar").getProperty(#locY)
  receiveUpdate(me.getID())
  return TRUE
end

on showVoteWait me 
  tWndObj = getWindow(pHubuWndID)
  i = 1
  repeat while i <= 6
    tWndObj.getElement("button_" & i).setProperty(#blend, 50)
    i = (1 + i)
  end repeat
  return TRUE
end

on showVoteResults me, tTotalVotes, tVoteResults 
  removeUpdate(me.getID())
  if not windowExists(pHubuWndID) then
    return(error(me, "Vote window is closed!", #showVoteResults))
  end if
  tBarMultiplier = tTotalVotes
  if (tBarMultiplier = 0) then
    tBarMultiplier = 1
  end if
  tWndObj = getWindow(pHubuWndID)
  tWndObj.getElement("time_bar_bg").hide()
  tWndObj.getElement("time_bar").hide()
  tWndObj.getElement("hubu_time").hide()
  tWndObj.getElement("hubu_statusbar").setText("")
  i = 1
  repeat while i <= tVoteResults.count
    tWndObj.getElement("hubu_res_" & i).setProperty(#blend, 100)
    tWndObj.getElement("hubu_res_" & i).setText(tVoteResults.getAt(i) & "/" & tTotalVotes && getText("hubu_answ_count", "kpl"))
    tW = tWndObj.getElement("hubu_answ_" & i).getProperty(#width)
    tWndObj.getElement("hubu_answ_" & i).setProperty(#width, ((tW / tBarMultiplier) * tVoteResults.getAt(i)))
    tWndObj.getElement("hubu_answ_" & i).setProperty(#blend, 100)
    i = (1 + i)
  end repeat
  return TRUE
end

on update me 
  tWndObj = getWindow(pHubuWndID)
  if (tWndObj = 0) then
    return(removeUpdate(me.getID()))
  end if
  tTime = (float((the milliSeconds - pTimerStart)) / 30000)
  if tTime > 1 then
    tTime = 1
  end if
  tSecsLeft = integer((30 - (float((the milliSeconds - pTimerStart)) * 0.001)))
  if tSecsLeft < 0 then
    tSecsLeft = 0
  end if
  tNewHeight = integer(((1 - tTime) * pTimerBarHeight))
  if tNewHeight < 0 then
    tNewHeight = 0
  end if
  tWndObj.getElement("hubu_time").setText(tSecsLeft && "s.")
  tWndObj.getElement("time_bar").setProperty(#height, tNewHeight)
  tWndObj.getElement("time_bar").setProperty(#locY, ((pTimerBarLocY + pTimerBarHeight) - tNewHeight))
end

on eventProcHubu me, tEvent, tSprID, tParam 
  if tEvent <> #mouseUp then
    return FALSE
  end if
  if (tSprID = "close") then
    return(removeWindow(pHubuWndID))
  else
    if (tSprID = "hubu_info_link1") then
      openNetPage(getText("hubu_info_url_1"))
    else
      if (tSprID = "hubu_info_link2") then
        openNetPage(getText("hubu_info_url_2"))
      else
        if tSprID contains "button_" then
          if (getWindow(pHubuWndID).getElement(tSprID).getProperty(#blend) = 100) then
            me.showVoteWait()
            getThread(#room).getComponent().getRoomConnection().send("VOTE", tSprID.getProp(#char, length(tSprID)))
          end if
        end if
      end if
    end if
  end if
end
