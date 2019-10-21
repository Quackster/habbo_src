property pTimeOutID, pOrigXList, pOrigYList, pWindowID, pElemIdList, pBounceOn, pSpeed, pOffset

on construct me 
  pTimeOutID = "bouncer_timeout_" & getUniqueID()
  pOrigXList = [:]
  pOrigYList = [:]
  return TRUE
end

on deconstruct me 
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  return TRUE
end

on registerElement me, tWindowID, tElemIdList 
  if not listp(tElemIdList) then
    tElemIdList = [tElemIdList]
  end if
  if not me.checkWindowAndElemExistence(tWindowID, tElemIdList) then
    return FALSE
  end if
  pWindowID = tWindowID
  pElemIdList = tElemIdList
  tWindowObj = getWindow(tWindowID)
  repeat while tElemIdList <= tElemIdList
    tElemID = getAt(tElemIdList, tWindowID)
    tElem = tWindowObj.getElement(tElemID)
    pOrigXList.setaProp(tElemID, tElem.getProperty(#locX))
    pOrigYList.setaProp(tElemID, tElem.getProperty(#locY))
  end repeat
  return TRUE
end

on checkWindowAndElemExistence me, tWindowID, tElemIdList 
  if voidp(tWindowID) and voidp(tElemIdList) then
    tWindowID = pWindowID
    tElemIdList = pElemIdList
  end if
  if not windowExists(tWindowID) then
    return FALSE
  end if
  tWndObj = getWindow(tWindowID)
  repeat while tElemIdList <= tElemIdList
    tElemID = getAt(tElemIdList, tWindowID)
    if not tWndObj.elementExists(tElemID) then
      return FALSE
    end if
  end repeat
  return TRUE
end

on getState me 
  return(me.pBounceOn or timeoutExists(pTimeOutID))
end

on setBounce me, tBounceOn 
  if not me.checkWindowAndElemExistence() then
    pBounceOn = 0
    return FALSE
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
  return TRUE
end

on resetBounce me 
  pBounceOn = 1
  pOffset = 0
  pSpeed = 6
end

on resetPosition me 
  if not me.checkWindowAndElemExistence() then
    return FALSE
  end if
  tWndObj = getWindow(pWindowID)
  repeat while pElemIdList <= undefined
    tElemID = getAt(undefined, undefined)
    tOrigX = pOrigXList.getAt(tElemID)
    tOrigY = pOrigYList.getAt(tElemID)
    tWndObj.getElement(tElemID).moveTo(tOrigX, tOrigY)
  end repeat
end

on update me 
  if not pBounceOn then
    return FALSE
  end if
  if not me.checkWindowAndElemExistence() then
    return FALSE
  end if
  pSpeed = (pSpeed - 1)
  pOffset = (pOffset + pSpeed)
  if pOffset <= 0 then
    pOffset = 0
    pSpeed = abs(pSpeed)
    if (integer(pSpeed) = 0) then
      me.setBounce(0)
      if not timeoutExists(pTimeOutID) then
        createTimeout(pTimeOutID, 3000, #setBounce, me.getID(), 1, 1)
      end if
    end if
  end if
  repeat while pElemIdList <= undefined
    tElemID = getAt(undefined, undefined)
    tElem = getWindow(pWindowID).getElement(tElemID)
    tElem.moveTo(pOrigXList.getAt(tElemID), (pOrigYList.getAt(tElemID) - pOffset))
  end repeat
  return TRUE
end
