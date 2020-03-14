property pMaxOffset, pWindowID, pElemName, pDelay, pScrollOn, pDelayLeft, pOffset, pSpeed

on construct me 
  pScrollOn = 0
  pOffset = 0
  pSpeed = 1
  pDelay = 36
  return TRUE
end

on deconstruct me 
  return TRUE
end

on registerElement me, tWindowID, tElementName 
  tValidParams = me.checkWindowAndElemExistence(tWindowID, tElementName)
  if not tValidParams then
    return FALSE
  end if
  pWindowID = tWindowID
  pElemName = tElementName
  tElem = getWindow(tWindowID).getElement(tElementName)
  tImage = tElem.getProperty(#image)
  if tImage.ilk <> #image then
    return FALSE
  end if
  pMaxOffset = (tImage.width - tElem.getProperty(#width))
  if pMaxOffset < 0 then
    me.centerText()
  end if
  return TRUE
end

on centerText me 
  if not me.checkWindowAndElemExistence() then
    return FALSE
  end if
  tElem = getWindow(pWindowID).getElement(pElemName)
  tElem.adjustOffsetTo((pMaxOffset / 2), 0)
  return TRUE
end

on checkWindowAndElemExistence me, tWindowID, tElementName 
  if voidp(tWindowID) and voidp(tElementName) then
    tWindowID = pWindowID
    tElementName = pElemName
  end if
  if not windowExists(tWindowID) then
    return FALSE
  end if
  tWndObj = getWindow(tWindowID)
  if not tWndObj.elementExists(tElementName) then
    return FALSE
  end if
  return TRUE
end

on setScroll me, tScrollOn 
  if not me.checkWindowAndElemExistence(pWindowID, pElemName) then
    pScrollOn = 0
    return FALSE
  end if
  if tScrollOn then
    if pMaxOffset <= 0 then
      return FALSE
    end if
    pScrollOn = 1
    me.resetScroll()
    receiveUpdate(me.getID())
  else
    pScrollOn = 0
    removeUpdate(me.getID())
  end if
  return TRUE
end

on resetScroll me 
  pDelayLeft = pDelay
  pOffset = 0
  pSpeed = 1
end

on update me 
  if not pScrollOn then
    return FALSE
  end if
  if pMaxOffset < 0 then
    return FALSE
  end if
  if pDelayLeft > 0 then
    pDelayLeft = (pDelayLeft - 1)
    return TRUE
  end if
  if not me.checkWindowAndElemExistence() then
    return FALSE
  end if
  pOffset = (pOffset + pSpeed)
  if pOffset >= pMaxOffset or pOffset <= 0 then
    pSpeed = -pSpeed
    pDelayLeft = pDelay
  end if
  tElem = getWindow(pWindowID).getElement(pElemName)
  tElem.adjustOffsetTo(pOffset, 0)
  return TRUE
end
