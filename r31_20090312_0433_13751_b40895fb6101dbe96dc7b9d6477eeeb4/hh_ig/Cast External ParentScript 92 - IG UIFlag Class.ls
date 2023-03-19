property pWindowID, pWindowList, pCloseTimer, pLocX, pLocY, pLocZ, pMaxModeZOffset, pFinalLocX, pLocStep, pmode, pcolor, pFlagType, pData

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
  return 1
end

on toggle me
  pCloseTimer = 0
  if pData = VOID then
    return error(me, "This flag has no data to display!", #toggle)
  end if
  pmode = not pmode
  me.createWindows()
  return 1
end

on open me
  pCloseTimer = 0
  if pmode then
    return 1
  end if
  return me.toggle()
end

on close me
  if not pmode then
    return 1
  end if
  return me.toggle()
end

on dumpLocZ me, tWndID
  tWndObj = getWindow(tWndID)
  if tWndObj = 0 then
    return 0
  end if
  put tWndID && tWndObj.getProperty(#locZ)
  repeat with i = 1 to tWndObj.pSpriteList.count
    put "---" && tWndObj.pSpriteList.getPropAt(i) && tWndObj.pSpriteList[i] && tWndObj.pSpriteList[i].locZ
  end repeat
end

on update me
  if pLocX <> pFinalLocX then
    tDiff = pFinalLocX - pLocX
    if tDiff < 2 then
      pLocX = pFinalLocX
    else
      pLocX = pLocX + (tDiff / 2)
    end if
    me.moveTo(pLocX, pLocY)
    tResult = 1
  end if
  return tResult
end

on getState me
  return pmode
end

on removeWindows me
  if pWindowList = VOID then
    pWindowList = []
  end if
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  repeat with tID in pWindowList
    tWrapObjRef.removeOneWindow(tID)
  end repeat
  pWindowList = []
end

on createWindows me
  me = getObject(me.getID())
  tSetID = me.getSetId()
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  if not tWrapObjRef.existsSet(tSetID) then
    tWrapObjRef.createSet(tSetID, 2)
  end if
  me.removeWindows()
  if pWindowList = VOID then
    pWindowList = []
  end if
  tLocY = pLocY
  tLayoutList = me.getLayout(pmode)
  if not listp(tLayoutList) then
    return 0
  end if
  repeat with i = 1 to tLayoutList.count
    tWindowID = me.getBasicId() & "_" & i
    if i = 1 then
      tWrapObjRef.addOneWindow(tWindowID, tLayoutList[i], tSetID, [#locX: pLocX, #locY: tLocY])
    else
      tWrapObjRef.addOneWindow(tWindowID, tLayoutList[i], tSetID, [#locX: pLocX + 10, #locY: tLocY])
    end if
    tWndObj = getWindow(tWindowID)
    if tWndObj = 0 then
      return 0
    end if
    tLocY = tLocY + tWndObj.getProperty(#height)
    me.setTitleField(tWindowID)
    me.setBackgroundColoring(tWindowID)
    pWindowList.append(tWindowID)
  end repeat
  me.alignZ()
  me.showInfo(pWindowList, pData, pmode)
  return 1
end

on moveTo me, tLocX, tLocY
  pLocX = tLocX
  pLocY = tLocY
  repeat with tID in pWindowList
    tWndObj = getWindow(tID)
    if tWndObj = 0 then
      exit repeat
    end if
    tWndObj.moveTo(tLocX, tLocY)
    tLocY = tLocY + tWndObj.getProperty(#height)
  end repeat
  return 1
end

on alignZ me, tlocz
  if tlocz <> VOID then
    pLocZ = tlocz
  end if
  repeat with i = 1 to pWindowList.count
    tWndObj = getWindow(pWindowList[i])
    if tWndObj = 0 then
      exit repeat
    end if
    tWndObj.moveZ(pLocZ + (pmode * pMaxModeZOffset))
  end repeat
  return 1
end

on getSetId me
  return "ig_fg_" & me.getBasicId()
end

on getBasicId me
  return pWindowID
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
    return 0
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
  return 1
end

on setBackgroundColoring me, tWindowID
  tWndObj = getWindow(tWindowID)
  if tWndObj = 0 then
    return 0
  end if
  if me.pcolor = VOID then
    return 1
  end if
  if not listp(me.pcolor) then
    tElem = tWndObj.getElement("ig_title_bg")
    if tElem <> 0 then
      tElem.setProperty(#bgColor, me.pcolor)
    end if
    return 1
  end if
  repeat with i = 1 to me.pcolor.count
    tElemID = "ig_title_bg_" & me.pcolor.getPropAt(i)
    tColor = me.pcolor[i]
    tElem = tWndObj.getElement(tElemID)
    if tElem <> 0 then
      tElem.setProperty(#bgColor, tColor)
    end if
  end repeat
  return 1
end

on dumpElements me
  put "** UIFlag windows and elements:"
  if pWindowList = VOID then
    pWindowList = []
  end if
  repeat with tID in pWindowList
    tWndObj = getWindow(tID)
    put tID && "-->" && tWndObj.pElemList
  end repeat
end

on getWindowWrapper me
  return getObject(#ig_window_wrapper)
end
