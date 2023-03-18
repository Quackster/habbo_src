property pWndObj, pTargetRect, pPreferSide

on construct me
  pWndObj = VOID
  return 1
end

on deconstruct me
  me.destroy()
  return 1
end

on createWithContent me, tWindow, tTargetRect, tPreferSide
  if not stringp(tWindow) then
    return error(me, "Invalid window content!", #createWithContent, #minor)
  end if
  if not (ilk(tTargetRect) = #rect) then
    return error(me, "Invalid target rect!", #createWithContent, #minor)
  end if
  if voidp(tPreferSide) then
    tPreferSide = #right
  end if
  if not ((tPreferSide = #right) or (tPreferSide = #left)) then
    error(me, "Invalid side, must be #left or #right", #createWithContent, #minor)
  end if
  pTargetRect = tTargetRect
  pPreferSide = tPreferSide
  tWindowName = "Details bubble" && getUniqueID()
  if not createWindow(tWindowName, "details_generic.window") then
    return error(me, "Could not create window", #createWithContent, #minor)
  end if
  pWndObj = getWindow(tWindowName)
  if pWndObj = 0 then
    return 0
  end if
  pWndObj.merge(tWindow)
  me.shapeAndPosition(tTargetRect, tPreferSide)
end

on updateBubble me
  me.shapeAndPosition(pTargetRect, pPreferSide)
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
  return pWndObj
end

on shapeAndPosition me, atargetRect, aPreferSide
  if pWndObj = 0 then
    return 0
  end if
  tWidth = pWndObj.getProperty(#width)
  tHeight = pWndObj.getProperty(#height)
  tLockPos = me.getLockPos(atargetRect, aPreferSide)
  case aPreferSide of
    #left:
      if (tLockPos.locH - tWidth) < 0 then
        aPreferSide = #right
        tLockPos = me.getLockPos(atargetRect, aPreferSide)
      end if
    #right:
      if ((the stage).image.width - tLockPos.locH) < tWidth then
        aPreferSide = #left
        tLockPos = me.getLockPos(atargetRect, aPreferSide)
      end if
  end case
  if aPreferSide = #left then
    tLockPos.locH = tLockPos.locH - tWidth
  end if
  tVerticalPos = tLockPos.locV - 12
  if tVerticalPos < 0 then
    tVerticalPos = 0
  end if
  if (tVerticalPos + tHeight) > (the stage).image.height then
    tVerticalPos = (the stage).image.height - tHeight
  end if
  case aPreferSide of
    #left:
      pWndObj.getElement("details.info.arrow.left").hide()
      pWndObj.getElement("details.info.arrow.right").show()
      tArrowElement = pWndObj.getElement("details.info.arrow.right")
    #right:
      pWndObj.getElement("details.info.arrow.left").show()
      pWndObj.getElement("details.info.arrow.right").hide()
      tArrowElement = pWndObj.getElement("details.info.arrow.left")
  end case
  tArrowPos = tLockPos.locV - (tArrowElement.getProperty(#height) / 2) - tVerticalPos
  if tArrowPos < 3 then
    tArrowPos = 3
  end if
  if tArrowPos > (tHeight - 14) then
    tArrowPos = tHeight - 14
  end if
  tArrowElement.setProperty(#locY, tArrowPos)
  pWndObj.moveTo(tLockPos.locH, tVerticalPos)
end

on getLockPos me, atargetRect, aPreferSide
  case aPreferSide of
    #left:
      tLockPos = point(atargetRect.left, (atargetRect.top + atargetRect.bottom) / 2)
    otherwise:
      tLockPos = point(atargetRect.right, (atargetRect.top + atargetRect.bottom) / 2)
  end case
  return tLockPos
end
