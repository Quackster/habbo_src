on construct(me)
  pWindowList = []
  exit
end

on deconstruct(me)
  repeat while me <= undefined
    tWindowID = getAt(undefined, undefined)
    removeWindow(tWindowID)
  end repeat
  pWindowList = []
  return(me.deconstruct())
  exit
end

on toggle(me, tGameType)
  if pWindowList.count = 0 then
    return(me.addWindows(tGameType))
  else
    return(me.Remove())
  end if
  exit
end

on addWindows(me, tGameType)
  me.pWindowID = "ru"
  tStageWidth = the stageRight - the stageLeft
  tLocY = 10
  tWinChar = "a"
  tLayoutList = []
  i = charToNum("a")
  repeat while i <= charToNum("z")
    tLayoutID = "ig_pg_rules_" & numToChar(i) & "_" & tGameType & ".window"
    if memberExists(tLayoutID) then
      tLayoutList.append(tLayoutID)
    end if
    i = 1 + i
  end repeat
  i = 1
  repeat while i <= tLayoutList.count
    tWindowID = me.getWindowId(i)
    pWindowList.append(tWindowID)
    createWindow(tWindowID, tLayoutList.getAt(i))
    tWndObj = getWindow(tWindowID)
    if tWndObj <> 0 then
      tLocX = tStageWidth - tWndObj.getProperty(#width) - 10
      tWndObj.moveTo(tLocX, tLocY)
      tLocY = tLocY + tWndObj.getProperty(#height) + 2
      tWndObj.registerProcedure(#eventProcMouseDown, me.getID(), #mouseDown)
    end if
    i = 1 + i
  end repeat
  return(1)
  exit
end

on getWindowId(me, tIndex)
  return(me.pWindowID & tIndex)
  exit
end

on eventProcMouseDown(me, tEvent, tSprID, tParam, tWndID)
  if tSprID <> "ig_close" then
    return(1)
  end if
  removeWindow(tWndID)
  pWindowList.deleteOne(tWndID)
  if pWindowList.count = 0 then
    me.Remove()
  end if
  return(1)
  exit
end