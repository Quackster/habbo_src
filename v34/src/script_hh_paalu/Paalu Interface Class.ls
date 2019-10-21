on construct(me)
  pWndID = "PaaluWindow"
  pActive = 0
  pKeyList = getVariableValue("paalu.key.list")
  if pKeyList.ilk <> #propList then
    error(me, "Couldn't retrieve keymap for Wobble Squabble! Using default keys.", #construct)
    pKeyList = [#bal1:"Q", #bal2:"E", #push1:"A", #push2:"D", #move1:"N", #move2:"M", #stabilise:"SPACE"]
  end if
  pKeyResList = getVariableValue("paalu.key.res.list", [])
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
  tWndObj.moveZ(1000)
  tWndObj.lock()
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
  me.localizeKeys()
  return(1)
  exit
end

on start(me)
  pActive = 1
  the keyboardFocusSprite = 0
  receiveUpdate(me.getID())
  me.resetDialog()
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
    i = 1
    repeat while i <= pKeyList.count
      if pKeyList.getAt(i) = tKey then
        tKeyNr = i
      else
        i = 1 + i
      end if
    end repeat
    if tKeyNr > 0 then
      if pKeyResList.getAt(tKeyNr) <> pCurrAct then
        pCurrAct = pKeyResList.getAt(tKeyNr)
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

on localizeKeys(me)
  tWndObj = getWindow(pWndID)
  if not tWndObj then
    return()
  end if
  i = 1
  repeat while i <= pKeyResList.count - 1
    tKey = pKeyList.getAt(i)
    tWndObj.getElement("paalu_btext_" & i).setText(tKey)
    i = 1 + i
  end repeat
  exit
end

on resetDialog(me)
  tWndObj = getWindow(pWndID)
  if not tWndObj then
    return(0)
  end if
  i = 1
  repeat while i <= pKeyResList.count - 1
    tmember = member(getmemnum("paaluUI_button_inactive"))
    if tmember.number > 0 then
      tWndObj.getElement("paalu_image_" & i).getProperty(#sprite).member = tmember
    end if
    i = 1 + i
  end repeat
  tmember = member(getmemnum("paaluUI_butt_SPACE_1"))
  if tmember.number > 0 then
    tWndObj.getElement("paalu_image_7").getProperty(#sprite).member = tmember
  end if
  return(1)
  exit
end

on sendAction(me)
  if pActive then
    me.getHandler().sendAction(pCurrAct)
  end if
  exit
end

on selectKey(me, tAction)
  tButtonNum = pKeyResList.getPos(tAction)
  if tButtonNum = 7 then
    tmember = member(getmemnum("paaluUI_butt_SPACE_2"))
  else
    tmember = member(getmemnum("paaluUI_button_active"))
  end if
  if tmember.number > 0 then
    getWindow(pWndID).getElement("paalu_image_" & tButtonNum).getProperty(#sprite).member = tmember
  end if
  exit
end

on highLightKey(me, tAction)
  tButtonNum = pKeyResList.getPos(tAction)
  if tButtonNum = 7 then
    tmember = member(getmemnum("paaluUI_butt_SPACE_2"))
  else
    tmember = member(getmemnum("paaluUI_button_active"))
  end if
  if tmember.number > 0 then
    getWindow(pWndID).getElement("paalu_image_" & tButtonNum).getProperty(#sprite).member = tmember
  end if
  exit
end

on eventProcPaalu(me, tEvent, tSprID, tParam)
  if tSprID contains "button" or tSprID = "paalu_image_7" then
    tActionNum = integer(tSprID.getProp(#char, tSprID.length))
    if tActionNum < 1 or tActionNum > pKeyResList.count then
      return(0)
    end if
    tAction = pKeyResList.getAt(tActionNum)
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