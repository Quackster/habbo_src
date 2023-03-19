property pUpdateCounter, pCurrentIndex, pState

on deconstruct me
  if windowExists(me.getWindowId()) then
    removeWindow(me.getWindowId())
  end if
  return me.ancestor.deconstruct()
end

on addWindows me
  tTimeLeftSec = me.getTimeLeftSec()
  if (tTimeLeftSec <= 0) or (tTimeLeftSec > 5) then
    return 0
  end if
  if pState then
    return 0
  end if
  pState = 1
  me.pWindowID = "cd"
  tService = me.getIGComponent("PreGame")
  if tService = 0 then
    return 0
  end if
  tGameRef = tService.getJoinedGame()
  if tGameRef = 0 then
    return 0
  end if
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  createWindow(me.getWindowId(), "ig_pg_countdown.window")
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  tWndObj.moveTo(370, 200)
  return 1
end

on render me
  pUpdateCounter = pUpdateCounter + 1
  if (pState < 2) and (pUpdateCounter < 4) then
    return 1
  end if
  if (pState >= 2) and (pUpdateCounter < 2) then
    return 1
  end if
  pUpdateCounter = 0
  if not pState then
    if not me.addWindows() then
      return 1
    end if
  end if
  tTimeLeftSec = me.getTimeLeftSec()
  if tTimeLeftSec > 6 then
    return 1
  end if
  if tTimeLeftSec > 0 then
    tIndex = 5 - tTimeLeftSec
  else
    tIndex = pState + 4
    pState = pState + 1
  end if
  if tIndex = pCurrentIndex then
    return 1
  end if
  pCurrentIndex = tIndex
  if tTimeLeftSec = 4 then
    playSound("ig-countdown")
  end if
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  tElement = tWndObj.getElement("ig_countdown")
  if tElement = 0 then
    return 0
  end if
  tMemNum = getmemnum("ig_countdown_" & tIndex)
  if tMemNum = 0 then
    if windowExists(me.getWindowId()) then
      removeWindow(me.getWindowId())
    end if
    pUpdateCounter = -1000
    return 1
  end if
  tElement.setProperty(#member, member(tMemNum))
  return 1
end

on getTimeLeftSec me
  tService = me.getIGComponent("PreGame")
  if tService = 0 then
    return 0
  end if
  tGameRef = tService.getJoinedGame()
  if tGameRef = 0 then
    return 0
  end if
  tTimeLeftSec = integer((tService.getMsecAtNextState() - the milliSeconds) / 1000)
  if tTimeLeftSec < 0 then
    return 0
  end if
  return tTimeLeftSec
end
