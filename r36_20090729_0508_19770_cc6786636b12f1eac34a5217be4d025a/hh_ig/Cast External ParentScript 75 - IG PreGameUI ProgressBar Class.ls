property pBarHeight, pBarMaxWidth, pBarOrigX, pBarOrigY, pUpdateCounter, pCacheProgress

on addWindows me
  me.pWindowID = "pb"
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  tWrapObjRef.moveTo(10, 10)
  tWrapObjRef.addOneWindow(me.getWindowId(), "ig_pg_loadbar.window", me.pWindowSetId)
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("ig_loadbar")
  if tElem = 0 then
    return 0
  end if
  pBarOrigX = tElem.getProperty(#locX)
  pBarOrigY = tElem.getProperty(#locY)
  pBarMaxWidth = tElem.getProperty(#width)
  pBarHeight = tElem.getProperty(#height)
  return 1
end

on render me, tProgress
  if voidp(tProgress) then
    tProgress = 0
  end if
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("ig_loadmask")
  if tElem = 0 then
    return 0
  end if
  pCacheProgress = tProgress
  tNewWidth = integer(pBarMaxWidth * ((100 - tProgress) / 100.0))
  tElem.resizeTo(tNewWidth, tElem.getProperty(#height))
  tElem.moveTo(pBarOrigX + (pBarMaxWidth - tNewWidth), pBarOrigY)
  return 1
end

on update me
  pUpdateCounter = pUpdateCounter + 1
  if (pUpdateCounter mod 5) > 0 then
    return 1
  end if
  if pUpdateCounter >= 25 then
    pUpdateCounter = 0
  end if
  tPhase = pUpdateCounter / 5
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("ig_loadbar")
  if tElem = 0 then
    return 0
  end if
  tMemNum = getmemnum("ig_icon_loadbar_" & tPhase)
  if tMemNum = 0 then
    return 0
  end if
  tElem.setProperty(#member, member(tMemNum))
  me.render(pCacheProgress)
  return 1
end
