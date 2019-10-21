on construct(me)
  tProps = [#bgColor:the stage.bgColor, #color:rgb(128, 128, 128), #width:128, #height:16]
  tProps = getVariableValue("loading.bar.props", tProps)
  pTaskId = ""
  pBuffer = the stage.image
  pwidth = tProps.getAt(#width)
  pheight = tProps.getAt(#height)
  pBgColor = tProps.getAt(#bgColor)
  pcolor = tProps.getAt(#color)
  pTaskType = #cast
  pDrawPoint = 0
  pWindowID = ""
  pReadyFlag = 0
  return(1)
  exit
end

on deconstruct(me)
  pTaskId = void()
  removePrepare(me.getID())
  if pWindowID <> "" then
    removeWindow(pWindowID)
    pWindowID = ""
  end if
  return(1)
  exit
end

on define(me, tLoadID, tProps)
  if not stringp(tLoadID) and not symbolp(tLoadID) then
    return(error(me, "Invalid castload task ID:" && tLoadID, #define, #major))
  end if
  pTaskId = tLoadID
  pPercent = 0
  pDrawPoint = 0
  pReadyFlag = 0
  if ilk(tProps, #propList) then
    if ilk(tProps.getAt(#buffer)) = #image then
      pBuffer = tProps.getAt(#buffer)
    end if
    if ilk(tProps.getAt(#width), #integer) then
      pwidth = tProps.getAt(#width)
    end if
    if ilk(tProps.getAt(#height), #integer) then
      pheight = tProps.getAt(#height)
    end if
    if ilk(tProps.getAt(#bgColor), #color) then
      pBgColor = tProps.getAt(#bgColor)
    end if
    if ilk(tProps.getAt(#color), #color) then
      pcolor = tProps.getAt(#color)
    end if
    if ilk(tProps.getAt(#type), #symbol) then
      pTaskType = tProps.getAt(#type)
    end if
    if tProps.getAt(#buffer) = #window then
      if pWindowID <> "" then
        removeWindow(pWindowID)
      end if
      pWindowID = me.getID() && the milliSeconds
      createWindow(pWindowID, "system.window")
      tWndObj = getWindow(pWindowID)
      tWndObj.resizeTo(pwidth, pheight)
      tWndObj.center()
      pBuffer = tWndObj.getElement("drag").getProperty(#buffer).image
    end if
  end if
  if not voidp(tProps.getAt(#locY)) then
    tWndObj.moveTo(tWndObj.getProperty(#locX), tProps.getAt(#locY))
  end if
  if not voidp(tProps.getAt(#locX)) then
    tWndObj.moveTo(tProps.getAt(#locX), tWndObj.getProperty(#locY))
  end if
  tRect = pBuffer.rect
  if pwidth > tRect.width then
    pwidth = tRect.width
  end if
  if pheight > tRect.height then
    pheight = tRect.height
  end if
  pBarRect = rect(tRect.width / 2 - pwidth / 2, tRect.height / 2 - pheight / 2, tRect.width / 2 + pwidth / 2, tRect.height / 2 + pheight / 2)
  pOffRect = rect(pBarRect.getAt(1) + 2, pBarRect.getAt(2) + 2, pBarRect.getAt(3) - 2, pBarRect.getAt(4) - 2)
  pBuffer.fill(pBarRect, pBgColor)
  pBuffer.draw(pBarRect, [#color:pcolor, #shapeType:#rect])
  return(receivePrepare(me.getID()))
  exit
end

on prepare(me)
  if voidp(pTaskId) or pReadyFlag then
    return(removeObject(me.getID()))
  end if
  if me = #cast then
    tPercent = getCastLoadManager().getLoadPercent(pTaskId)
  else
    if me = #file then
      tPercent = getDownloadManager().getLoadPercent(pTaskId)
    end if
  end if
  pDrawPoint = pDrawPoint + 1
  if pDrawPoint <= pPercent * pOffRect.width then
    tRect = rect(pOffRect.getAt(1) + pDrawPoint - 1, pOffRect.getAt(2), pOffRect.getAt(1) + pDrawPoint, pOffRect.getAt(4))
    pBuffer.fill(tRect, pcolor)
  end if
  if pPercent = tPercent then
    return()
  end if
  pBuffer.fill(pBarRect, pBgColor)
  pBuffer.draw(pBarRect, [#color:pcolor, #shapeType:#rect])
  tRect = rect(pOffRect.getAt(1), pOffRect.getAt(2), pPercent * pOffRect.width + pOffRect.getAt(1), pOffRect.getAt(4))
  pBuffer.fill(tRect, pcolor)
  pDrawPoint = pPercent * pOffRect.width
  pPercent = tPercent
  if pPercent >= 0 then
    pBuffer.fill(pOffRect, pcolor)
    pReadyFlag = 1
  end if
  exit
end