property pWindowID, pAlertSpr, pAlertTimer, pCurrCryID, pCurrCryNum, pCurrCryData

on construct me
  pWindowID = getText("hobba_alert", "Hobba Alert")
  pAlertSpr = VOID
  pAlertTimer = 0
  pCurrCryID = EMPTY
  pCurrCryNum = 0
  pCurrCryData = [:]
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  if pAlertSpr.ilk = #sprite then
    releaseSprite(pAlertSpr.spriteNum)
  end if
  pCurrCryID = EMPTY
  pCurrCryNum = 0
  pCurrCryData = [:]
  return 1
end

on ShowAlert me
  if pAlertSpr.ilk <> #sprite then
    pAlertSpr = sprite(reserveSprite(me.getID()))
    pAlertSpr.memberNum = getmemnum("hobba_alert_0")
    pAlertSpr.ink = 8
    pAlertSpr.loc = point(5, 5)
    pAlertSpr.locZ = 200000000
    setEventBroker(pAlertSpr.spriteNum, me.getID() & "_alert_spr")
    pAlertSpr.registerProcedure(#eventProcAlert, me.getID(), #mouseUp)
    pAlertSpr.setCursor("cursor.finger")
    pAlertTimer = 0
  end if
  return receiveUpdate(me.getID())
end

on hideAlert me
  if ilk(pAlertSpr, #sprite) then
    pAlertSpr.memberNum = getmemnum("hobba_alert_0")
  end if
  return removeUpdate(me.getID())
end

on showCryWnd me
  if windowExists(pWindowID) then
    tWndObj = getWindow(pWindowID)
  else
    createWindow(pWindowID, "habbo_basic.window")
    tWndObj = getWindow(pWindowID)
    tWndObj.merge("habbo_hobba_alert.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcCryWnd, me.getID(), #mouseUp)
  end if
  tCryDB = me.getComponent().getCryDataBase()
  if tCryDB.count = 0 then
    return 1
  end if
  tCryID = tCryDB.getPropAt(tCryDB.count)
  return me.fillCryData(tCryID)
end

on hideCryWnd me
  pCurrCryID = EMPTY
  pCurrCryNum = 0
  pCurrCryData = [:]
  me.hideAlert()
  if windowExists(pWindowID) then
    return removeWindow(pWindowID)
  else
    return 0
  end if
end

on updateCryWnd me
  return me.fillCryData(pCurrCryID)
end

on update me
  pAlertTimer = (pAlertTimer + 1) mod 4
  if pAlertTimer <> 0 then
    return 
  end if
  if pAlertSpr.ilk <> #sprite then
    return removeUpdate(me.getID())
  end if
  tName = pAlertSpr.member.name
  tNum = integer(tName.char[length(tName)])
  tName = tName.char[1..length(tName) - 1] & not tNum
  pAlertSpr.memberNum = getmemnum(tName)
end

on fillCryData me, tCryNumOrID
  if not windowExists(pWindowID) then
    return 0
  end if
  tCryDB = me.getComponent().getCryDataBase()
  tCryCount = tCryDB.count
  if tCryCount = 0 then
    return error(me, "Hobba alerts not found!", #fillCryData)
  end if
  if stringp(tCryNumOrID) then
    tCryID = tCryNumOrID
    pCurrCryData = tCryDB[tCryID]
    repeat with i = 1 to tCryCount
      if tCryDB.getPropAt(i) = tCryID then
        pCurrCryNum = i
        exit repeat
      end if
    end repeat
  else
    if integerp(tCryNumOrID) then
      if (tCryNumOrID < 1) or (tCryNumOrID > tCryCount) then
        return 0
      end if
      tCryID = tCryDB.getPropAt(tCryNumOrID)
      pCurrCryData = tCryDB[tCryID]
      pCurrCryNum = tCryNumOrID
    else
      return error(me, "String or integer expected:" && tCryNumOrID, #fillCryData)
    end if
  end if
  if voidp(pCurrCryData) then
    tNewID = tCryDB.getPropAt(count(tCryDB))
    return me.fillCryData(tNewID)
  else
    pCurrCryID = tCryID
  end if
  tName = pCurrCryData[#sender]
  tPlace = pCurrCryData[#name]
  tMsg = pCurrCryData[#msg]
  tWndObj = getWindow(pWindowID)
  tWndObj.getElement("hobba_cry_text").setText(tName & RETURN & tPlace & RETURN & RETURN & tMsg)
  tWndObj.getElement("page_num").setText(pCurrCryNum & "/" & tCryCount)
  tWndObj.getElement("hobba_pickedby").setText(getText("hobba_pickedby") && pCurrCryData.picker)
  return 1
end

on eventProcCryWnd me, tEvent, tElemID, tParam
  case tElemID of
    "close":
      return me.hideCryWnd()
    "hobba_prev":
      return me.fillCryData(pCurrCryNum - 1)
    "hobba_next":
      return me.fillCryData(pCurrCryNum + 1)
    "hobba_seelog":
      return openNetPage(pCurrCryData[#url])
    "hobba_pickup":
      tCryID = pCurrCryID
      me.hideCryWnd()
      return me.getComponent().send_cryPick(tCryID, 0)
    "hobba_pickup_go":
      tCryID = pCurrCryID
      me.hideCryWnd()
      return me.getComponent().send_cryPick(tCryID, 1)
    otherwise:
      return 0
  end case
end

on eventProcAlert me, tEvent, tElemID, tParam
  me.showCryWnd()
  return 1
end
