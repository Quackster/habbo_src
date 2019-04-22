property pWndObj

on construct me 
  pWndObj = void()
  return(1)
end

on deconstruct me 
  me.destroy()
  return(1)
end

on createWithContent me, aWindow, atargetRect, aPreferSide 
  if not stringp(aWindow) then
    return(error(me, "Invalid window content!", #createWithContent, #minor))
  end if
  if not ilk(atargetRect) = #rect then
    return(error(me, "Invalid target rect!", #createWithContent, #minor))
  end if
  if voidp(aPreferSide) then
    aPreferSide = #right
  end if
  if not aPreferSide = #right or aPreferSide = #left then
    error(me, "Invalid side, must be #left or #right", #createWithContent, #minor)
  end if
  tWindowName = "Details bubble" && getUniqueID()
  if not createWindow(tWindowName, "details_generic.window") then
    return(error(me, "Could not create window", #createWithContent, #minor))
  end if
  pWndObj = getWindow(tWindowName)
  pWndObj.merge(aWindow)
  me.shapeAndPosition(atargetRect, aPreferSide)
end

on destroy me 
  if objectp(pWndObj) then
    tWindowName = pWndObj.getID()
    if windowExists(tWindowName) then
      removeWindow(tWindowName)
    end if
  end if
end

on getWindowObj me 
  return(pWndObj)
end

on shapeAndPosition me, atargetRect, aPreferSide 
  tWidth = pWndObj.getProperty(#width)
  tHeight = pWndObj.getProperty(#height)
  tLockPos = me.getLockPos(atargetRect, aPreferSide)
  if aPreferSide = #left then
    if tLockPos.locH - tWidth < 0 then
      aPreferSide = #right
      tLockPos = me.getLockPos(atargetRect, aPreferSide)
    end if
  else
    if aPreferSide = #right then
      if image.width - tLockPos.locH < tWidth then
        aPreferSide = #left
        tLockPos = me.getLockPos(atargetRect, aPreferSide)
      end if
    end if
  end if
  if aPreferSide = #left then
    tLockPos.locH = tLockPos.locH - tWidth
  end if
  tVerticalPos = tLockPos.locV - 12
  if tVerticalPos < 0 then
    tVerticalPos = 0
  end if
  if the stage > image.height then
    tVerticalPos = image.height - tHeight
  end if
  if aPreferSide = #left then
    pWndObj.getElement("details.info.arrow.left").hide()
    pWndObj.getElement("details.info.arrow.right").show()
    tArrowElement = pWndObj.getElement("details.info.arrow.right")
  else
    if aPreferSide = #right then
      pWndObj.getElement("details.info.arrow.left").show()
      pWndObj.getElement("details.info.arrow.right").hide()
      tArrowElement = pWndObj.getElement("details.info.arrow.left")
    end if
  end if
  tArrowPos = tLockPos.locV - tArrowElement.getProperty(#height) / 2 - tVerticalPos
  if tArrowPos < 3 then
    tArrowPos = 3
  end if
  if tArrowPos > tHeight - 14 then
    tArrowPos = tHeight - 14
  end if
  tArrowElement.setProperty(#locY, tArrowPos)
  pWndObj.moveTo(tLockPos.locH, tVerticalPos)
end

on getLockPos me, atargetRect, aPreferSide 
  if aPreferSide = #left then
    tLockPos = point(atargetRect.left, atargetRect.top + atargetRect.bottom / 2)
  else
    if aPreferSide = #right then
      tLockPos = point(atargetRect.right, atargetRect.top + atargetRect.bottom / 2)
    end if
  end if
  return(tLockPos)
end
