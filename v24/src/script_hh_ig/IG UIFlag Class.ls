property pData, pmode, pLocX, pFinalLocX, pLocY, pWindowList, pLocZ, pMaxModeZOffset, pWindowID

on deconstruct me 
  me.removeWindows()
end

on define me, tID, tLocY, tlocz, tColor, tFlagType, tdata 
  pLocY = tLocY
  pWindowID = tID
  pcolor = tColor
  pFlagType = tFlagType
  pData = tdata
  pLocZ = tlocz
  pLocX = 10
  pMaxModeZOffset = 1000
  pFinalLocX = 199
  pLocStep = 1
  pmode = 0
  pWindowList = []
  return(1)
end

on toggle me 
  pCloseTimer = 0
  if pData = void() then
    return(error(me, "This flag has no data to display!", #toggle))
  end if
  pmode = not pmode
  me.createWindows()
  return(1)
end

on open me 
  pCloseTimer = 0
  if pmode then
    return(1)
  end if
  return(me.toggle())
end

on close me 
  if not pmode then
    return(1)
  end if
  return(me.toggle())
end

on dumpLocZ me, tWndID 
  tWndObj = getWindow(tWndID)
  if tWndObj = 0 then
    return(0)
  end if
  put(tWndID && tWndObj.getProperty(#locZ))
  i = 1
  repeat while i <= tWndObj.count(#pSpriteList)
    put("---" && tWndObj.getPropAt(i) && tWndObj.getProp(#pSpriteList, i) && tWndObj.getPropRef(#pSpriteList, i).locZ)
    i = 1 + i
  end repeat
end

on update me 
  if pLocX <> pFinalLocX then
    tDiff = pFinalLocX - pLocX
    if tDiff < 2 then
      pLocX = pFinalLocX
    else
      pLocX = pLocX + tDiff / 2
    end if
    me.moveTo(pLocX, pLocY)
    tResult = 1
  end if
  return(tResult)
end

on getState me 
  return(pmode)
end

on removeWindows me 
  if pWindowList = void() then
    pWindowList = []
  end if
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return(0)
  end if
  repeat while pWindowList <= undefined
    tID = getAt(undefined, undefined)
    tWrapObjRef.removeOneWindow(tID)
  end repeat
  pWindowList = []
end

on createWindows me 
  me = getObject(me.getID())
  tSetID = me.getSetId()
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return(0)
  end if
  if not tWrapObjRef.existsSet(tSetID) then
    tWrapObjRef.createSet(tSetID, 2)
  end if
  me.removeWindows()
  if pWindowList = void() then
    pWindowList = []
  end if
  tLocY = pLocY
  tLayoutList = me.getLayout(pmode)
  if not listp(tLayoutList) then
    return(0)
  end if
  i = 1
  repeat while i <= tLayoutList.count
    tWindowID = me.getBasicId() & "_" & i
    if i = 1 then
      tWrapObjRef.addOneWindow(tWindowID, tLayoutList.getAt(i), tSetID, [#locX:pLocX, #locY:tLocY])
    else
      tWrapObjRef.addOneWindow(tWindowID, tLayoutList.getAt(i), tSetID, [#locX:pLocX + 10, #locY:tLocY])
    end if
    tWndObj = getWindow(tWindowID)
    if tWndObj = 0 then
      return(0)
    end if
    tLocY = tLocY + tWndObj.getProperty(#height)
    me.setTitleField(tWindowID)
    me.setBackgroundColoring(tWindowID)
    pWindowList.append(tWindowID)
    i = 1 + i
  end repeat
  me.alignZ()
  me.showInfo(pWindowList, pData, pmode)
  return(1)
end

on moveTo me, tLocX, tLocY 
  pLocX = tLocX
  pLocY = tLocY
  repeat while pWindowList <= tLocY
    tID = getAt(tLocY, tLocX)
    tWndObj = getWindow(tID)
    if tWndObj = 0 then
    else
      tWndObj.moveTo(tLocX, tLocY)
      tLocY = tLocY + tWndObj.getProperty(#height)
    end if
  end repeat
  return(1)
end

on alignZ me, tlocz 
  if tlocz <> void() then
    pLocZ = tlocz
  end if
  i = 1
  repeat while i <= pWindowList.count
    tWndObj = getWindow(pWindowList.getAt(i))
    if tWndObj = 0 then
    else
      tWndObj.moveZ(pLocZ + pmode * pMaxModeZOffset)
      i = 1 + i
    end if
  end repeat
  return(1)
end

on getSetId me 
  return("ig_fg_" & me.getBasicId())
end

on getBasicId me 
  return(pWindowID)
end

on getLayout me, tMode 
end

on showInfo me, tWindowList, tdata, tMode 
end

on getTitleText me 
end

on setTitleField me, tWindowID 
  tWndObj = getWindow(tWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("ig_tip_title")
  tTitleText = getObject(me.getID()).getTitleText()
  if pmode = 0 then
    tWidth = 19 + 6 + integer(tTitleText.length * 8)
    tWndObj.resizeTo(tWidth, tWndObj.getProperty(#height))
  end if
  if tElem <> 0 then
    tElem.setText(tTitleText)
  end if
  return(1)
end

on setBackgroundColoring me, tWindowID 
  tWndObj = getWindow(tWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  if me.pcolor = void() then
    return(1)
  end if
  if not listp(me.pcolor) then
    tElem = tWndObj.getElement("ig_title_bg")
    if tElem <> 0 then
      tElem.setProperty(#bgColor, me.pcolor)
    end if
    return(1)
  end if
  i = 1
  repeat while i <= me.count(#pcolor)
    tElemID = "ig_title_bg_" & me.getPropAt(i)
    tColor = me.getProp(#pcolor, i)
    tElem = tWndObj.getElement(tElemID)
    if tElem <> 0 then
      tElem.setProperty(#bgColor, tColor)
    end if
    i = 1 + i
  end repeat
  return(1)
end

on dumpElements me 
  put("** UIFlag windows and elements:")
  if pWindowList = void() then
    pWindowList = []
  end if
  repeat while pWindowList <= undefined
    tID = getAt(undefined, undefined)
    tWndObj = getWindow(tID)
    put(tID && "-->" && tWndObj.pElemList)
  end repeat
end

on getWindowWrapper me 
  return(getObject(#ig_window_wrapper))
end
