property pWindowID, pElementID, pBlockTime, pUpdateTimer

on Init me, tWindowID, tElementId, tBlockTime
  pWindowID = tWindowID
  pElementID = tElementId
  pBlockTime = the milliSeconds + tBlockTime
  pUpdateTimer = the milliSeconds - 999
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return removeObject(me.getID())
  end if
  tElem = tWndObj.getElement(pElementID)
  if tElem = 0 then
    return removeObject(me.getID())
  end if
  tElem.setEdit(0)
  receiveUpdate(me.getID())
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  return 1
end

on update me
  if pUpdateTimer > the milliSeconds then
    return 
  else
    pUpdateTimer = the milliSeconds + 1000
  end if
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return removeObject(me.getID())
  end if
  tElem = tWndObj.getElement(pElementID)
  if tElem = 0 then
    return removeObject(me.getID())
  end if
  if the milliSeconds < pBlockTime then
    tText = getText("floodblocking", "YOU TYPE TOO FAST! YOU MUST WAIT A MOMENT")
    tElem.setText(tText && (pBlockTime - the milliSeconds) / 1000)
  else
    tElem.setText(EMPTY)
    tElem.setEdit(1)
    removeObject(me.getID())
  end if
end
