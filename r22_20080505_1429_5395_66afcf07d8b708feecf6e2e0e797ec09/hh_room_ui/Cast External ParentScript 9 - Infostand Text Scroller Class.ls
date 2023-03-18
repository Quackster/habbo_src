property pWindowID, pElemName, pScrollOn, pMaxOffset, pOffset, pSpeed, pDelayLeft, pDelay

on construct me
  pScrollOn = 0
  pOffset = 0
  pSpeed = 1
  pDelay = 36
  return 1
end

on deconstruct me
  return 1
end

on registerElement me, tWindowID, tElementName
  tValidParams = me.checkWindowAndElemExistence(tWindowID, tElementName)
  if not tValidParams then
    return 0
  end if
  pWindowID = tWindowID
  pElemName = tElementName
  tElem = getWindow(tWindowID).getElement(tElementName)
  tImage = tElem.getProperty(#image)
  if tImage.ilk <> #image then
    return 0
  end if
  pMaxOffset = tImage.width - tElem.getProperty(#width)
  if pMaxOffset < 0 then
    me.centerText()
  end if
  return 1
end

on centerText me
  if not me.checkWindowAndElemExistence() then
    return 0
  end if
  tElem = getWindow(pWindowID).getElement(pElemName)
  tElem.adjustOffsetTo(pMaxOffset / 2, 0)
  return 1
end

on checkWindowAndElemExistence me, tWindowID, tElementName
  if voidp(tWindowID) and voidp(tElementName) then
    tWindowID = pWindowID
    tElementName = pElemName
  end if
  if not windowExists(tWindowID) then
    return 0
  end if
  tWndObj = getWindow(tWindowID)
  if not tWndObj.elementExists(tElementName) then
    return 0
  end if
  return 1
end

on setScroll me, tScrollOn
  if not me.checkWindowAndElemExistence(pWindowID, pElemName) then
    pScrollOn = 0
    return 0
  end if
  if tScrollOn then
    if pMaxOffset <= 0 then
      return 0
    end if
    pScrollOn = 1
    me.resetScroll()
    receiveUpdate(me.getID())
  else
    pScrollOn = 0
    removeUpdate(me.getID())
  end if
  return 1
end

on resetScroll me
  pDelayLeft = pDelay
  pOffset = 0
  pSpeed = 1
end

on update me
  if not pScrollOn then
    return 0
  end if
  if pMaxOffset < 0 then
    return 0
  end if
  if pDelayLeft > 0 then
    pDelayLeft = pDelayLeft - 1
    return 1
  end if
  if not me.checkWindowAndElemExistence() then
    return 0
  end if
  pOffset = pOffset + pSpeed
  if (pOffset >= pMaxOffset) or (pOffset <= 0) then
    pSpeed = -pSpeed
    pDelayLeft = pDelay
  end if
  tElem = getWindow(pWindowID).getElement(pElemName)
  tElem.adjustOffsetTo(pOffset, 0)
  return 1
end
