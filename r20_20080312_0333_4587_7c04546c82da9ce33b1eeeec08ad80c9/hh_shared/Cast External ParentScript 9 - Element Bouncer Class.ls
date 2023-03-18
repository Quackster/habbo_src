property pWindowID, pElemIdList, pBounceOn, pOrigXList, pOrigYList, pOffset, pSpeed, pTimeOutID

on construct me
  pTimeOutID = "bouncer_timeout_" & getUniqueID()
  pOrigXList = [:]
  pOrigYList = [:]
  return 1
end

on deconstruct me
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  return 1
end

on registerElement me, tWindowID, tElemIdList
  if not listp(tElemIdList) then
    tElemIdList = [tElemIdList]
  end if
  if not me.checkWindowAndElemExistence(tWindowID, tElemIdList) then
    return 0
  end if
  pWindowID = tWindowID
  pElemIdList = tElemIdList
  tWindowObj = getWindow(tWindowID)
  repeat with tElemID in tElemIdList
    tElem = tWindowObj.getElement(tElemID)
    pOrigXList.setaProp(tElemID, tElem.getProperty(#locX))
    pOrigYList.setaProp(tElemID, tElem.getProperty(#locY))
  end repeat
  return 1
end

on checkWindowAndElemExistence me, tWindowID, tElemIdList
  if voidp(tWindowID) and voidp(tElemIdList) then
    tWindowID = pWindowID
    tElemIdList = pElemIdList
  end if
  if not windowExists(tWindowID) then
    return 0
  end if
  tWndObj = getWindow(tWindowID)
  repeat with tElemID in tElemIdList
    if not tWndObj.elementExists(tElemID) then
      return 0
    end if
  end repeat
  return 1
end

on getState me
  return me.pBounceOn or timeoutExists(pTimeOutID)
end

on setBounce me, tBounceOn
  if not me.checkWindowAndElemExistence() then
    pBounceOn = 0
    return 0
  end if
  if tBounceOn then
    pBounceOn = 1
    me.resetBounce()
    receiveUpdate(me.getID())
  else
    if timeoutExists(pTimeOutID) then
      removeTimeout(pTimeOutID)
    end if
    pBounceOn = 0
    me.resetPosition()
    removeUpdate(me.getID())
  end if
  return 1
end

on resetBounce me
  pBounceOn = 1
  pOffset = 0
  pSpeed = 6
end

on resetPosition me
  if not me.checkWindowAndElemExistence() then
    return 0
  end if
  tWndObj = getWindow(pWindowID)
  repeat with tElemID in pElemIdList
    tOrigX = pOrigXList[tElemID]
    tOrigY = pOrigYList[tElemID]
    tWndObj.getElement(tElemID).moveTo(tOrigX, tOrigY)
  end repeat
end

on update me
  if not pBounceOn then
    return 0
  end if
  if not me.checkWindowAndElemExistence() then
    return 0
  end if
  pSpeed = pSpeed - 1
  pOffset = pOffset + pSpeed
  if pOffset <= 0 then
    pOffset = 0
    pSpeed = abs(pSpeed)
    if integer(pSpeed) = 0 then
      me.setBounce(0)
      if not timeoutExists(pTimeOutID) then
        createTimeout(pTimeOutID, 3000, #setBounce, me.getID(), 1, 1)
      end if
    end if
  end if
  repeat with tElemID in pElemIdList
    tElem = getWindow(pWindowID).getElement(tElemID)
    tElem.moveTo(pOrigXList[tElemID], pOrigYList[tElemID] - pOffset)
  end repeat
  return 1
end
