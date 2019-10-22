property pBlend, pUpdateCounter, pStateCounter

on deconstruct me 
  if windowExists(me.getWindowId()) then
    removeWindow(me.getWindowId())
  end if
  return(me.ancestor.deconstruct())
end

on addWindows me 
  me.pWindowID = "go"
  pBlend = 100
  if windowExists(me.getWindowId()) then
    return TRUE
  end if
  createWindow(me.getWindowId(), "ig_ag_gameover.window")
  tWndObj = getWindow(me.getWindowId())
  if (tWndObj = 0) then
    return FALSE
  end if
  tWndObj.moveTo(270, 200)
  tWndObj.lock()
  pStateCounter = 30
  return TRUE
end

on update me 
  if pBlend <= 0 then
    return TRUE
  end if
  pUpdateCounter = (pUpdateCounter + 1)
  if pUpdateCounter < 2 then
    return TRUE
  end if
  pUpdateCounter = 0
  if pStateCounter > 0 then
    pStateCounter = (pStateCounter - 1)
    return TRUE
  end if
  tWndObj = getWindow(me.getWindowId())
  if (tWndObj = 0) then
    return FALSE
  end if
  pBlend = (pBlend - 15)
  tElem = tWndObj.getElement("ig_gameover")
  tElem.setProperty(#blend, pBlend)
  if pBlend < 10 then
    if windowExists(me.getWindowId()) then
      removeWindow(me.getWindowId())
    end if
  end if
  return TRUE
end
