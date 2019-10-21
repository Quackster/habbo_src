on construct(me)
  pWndID = "PaaluWindow"
  pActive = 0
  pKeyList = getVariableValue("paalu.key.list", [])
  pCycleTime = getIntVariable("paalu.cycle.time", 100)
  pCurrAct = "-"
  pArrowSpr = void()
  pOwnPlayer = void()
  pCurrBal = 0
  return(1)
  exit
end

on deconstruct(me)
  pActive = 0
  pArrowSpr = void()
  pOwnPlayer = void()
  if windowExists(pWndID) then
    removeWindow(pWndID)
  end if
  removeUpdate(me.getID())
  return(1)
  exit
end

on prepare(me, tOwnPlayerObj)
  if windowExists(pWndID) then
    return(0)
  end if
  createWindow(pWndID, "paaluUI.window", 10, 10, #modal)
  tWndObj = getWindow(pWndID)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcPaalu, me.getID(), #mouseUp)
  tWndObj.moveTo(12, 288)
  if windowExists(#modal) then
    getWindow(#modal).getElement("modal").setProperty(#blend, 0)
  else
    error(me, "Where's the modal window?", #prepare)
  end if
  pArrowSpr = tWndObj.getElement("needle").getProperty(#sprite)
  member.width / 2.regPoint = point(pArrowSpr, member.height - 3)
  tBallSpr = tWndObj.getElement("needle_ball").getProperty(#sprite)
  member.width / 2.regPoint = point(tBallSpr, member.height / 2)
  pOwnPlayer = tOwnPlayerObj
  pCurrAct = "-"
  pCurrTime = the milliSeconds
  pCurrBal = 0
  pActive = 0
  return(1)
  exit
end

on start(me)
  pActive = 1
  the keyboardFocusSprite = 0
  receiveUpdate(me.getID())
  startTimer()
  return(1)
  exit
end

on stop(me)
  pActive = 0
  pArrowSpr = void()
  pOwnPlayer = void()
  removeWindow(pWndID)
  removeUpdate(me.getID())
  the keyboardFocusSprite = -1
  return(1)
  exit
end

on update(me)
  the keyboardFocusSprite = 0
  tTime = the milliSeconds - pCurrTime
  tKey = the key
  if the lastKey < the timer then
    if tKey = space() then
      tKey = "SPACE"
    end if
    if tKey <> pCurrAct then
      if not voidp(pKeyList.getAt(tKey)) then
        pCurrAct = tKey
        me.sendAction()
        me.resetDialog()
        me.selectKey(pCurrAct)
        pCurrAct = "-"
      end if
    end if
    startTimer()
  end if
  tTimerOff = tTime / 100
  if tTimerOff = 9 then
    if pCurrAct <> "-" then
      me.highLightKey(pCurrAct)
    end if
  end if
  if tTime >= pCycleTime then
    pCurrTime = the milliSeconds
  end if
  tBalance = pOwnPlayer.getBalance()
  tBalOff = tBalance - pCurrBal
  pCurrBal = pCurrBal + tBalOff / 0
  pArrowSpr.rotation = pCurrBal
  exit
end

on resetDialog(me)
  tWndObj = getWindow(pWndID)
  if not tWndObj then
    return()
  end if
  i = 1
  repeat while i <= pKeyList.count
    tKey = pKeyList.getPropAt(i)
    tmember = member(getmemnum("paaluUI_butt_" & tKey & "_0"))
    if tmember.number > 0 then
      tWndObj.getElement("button" && tKey).getProperty(#sprite).member = tmember
    end if
    i = 1 + i
  end repeat
  exit
end

on sendAction(me)
  if pActive then
    getThread(#room).getComponent().getRoomConnection().send(#room, "PTM" && pKeyList.getAt(pCurrAct))
  end if
  exit
end

on selectKey(me, tAction)
  tmember = member(getmemnum("paaluUI_butt_" & tAction & "_1"))
  if tmember.number > 0 then
    getWindow(pWndID).getElement("button" && tAction).getProperty(#sprite).member = tmember
  end if
  exit
end

on highLightKey(me, tAction)
  tmember = member(getmemnum("paaluUI_butt_" & tAction & "_2"))
  if tmember.number > 0 then
    getWindow(pWndID).getElement("button" && tAction).getProperty(#sprite).member = tmember
  end if
  exit
end

on eventProcPaalu(me, tEvent, tSprID, tParam)
  if tSprID.getProp(#word, 1) = "button" then
    tAction = tSprID.getProp(#word, 2)
    if pCurrAct <> tAction then
      pCurrAct = tAction
      me.sendAction()
      me.resetDialog()
      me.highLightKey(pCurrAct)
      pCurrAct = "-"
    end if
  end if
  exit
end