property pWindowID, pWindowList

on construct me
  pWindowList = []
end

on deconstruct me
  repeat with tWindowID in pWindowList
    removeWindow(tWindowID)
  end repeat
  pWindowList = []
  return me.ancestor.deconstruct()
end

on toggle me, tGameType
  if pWindowList.count = 0 then
    return me.addWindows(tGameType)
  else
    return me.Remove()
  end if
end

on addWindows me, tGameType
  me.pWindowID = "ru"
  tStageWidth = the stageRight - the stageLeft
  tLocY = 10
  tWinChar = "a"
  tLayoutList = []
  repeat with i = charToNum("a") to charToNum("z")
    tLayoutID = "ig_pg_rules_" & numToChar(i) & "_" & tGameType & ".window"
    if memberExists(tLayoutID) then
      tLayoutList.append(tLayoutID)
    end if
  end repeat
  repeat with i = 1 to tLayoutList.count
    tWindowID = me.getWindowId(i)
    pWindowList.append(tWindowID)
    createWindow(tWindowID, tLayoutList[i])
    tWndObj = getWindow(tWindowID)
    if tWndObj <> 0 then
      tLocX = tStageWidth - tWndObj.getProperty(#width) - 10
      tWndObj.moveTo(tLocX, tLocY)
      tLocY = tLocY + tWndObj.getProperty(#height) + 2
      tWndObj.registerProcedure(#eventProcMouseDown, me.getID(), #mouseDown)
    end if
  end repeat
  return 1
end

on getWindowId me, tIndex
  return me.pWindowID & tIndex
end

on eventProcMouseDown me, tEvent, tSprID, tParam, tWndID
  if tSprID <> "ig_close" then
    return 1
  end if
  removeWindow(tWndID)
  pWindowList.deleteOne(tWndID)
  if pWindowList.count = 0 then
    me.Remove()
  end if
  return 1
end
