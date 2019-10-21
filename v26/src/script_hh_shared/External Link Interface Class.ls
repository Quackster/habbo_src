on construct(me)
  pWindowID = getUniqueID()
  pTimeOutID = getUniqueID()
  pActivateID = getUniqueID()
  registerMessage(#externalLinkClick, me.getID(), #notifyExternalLinkClick)
  return(1)
  exit
end

on deconstruct(me)
  me.removeTooltipWindow()
  me.removeWindowTimeout()
  me.removeActivateTimeout()
  unregisterMessage(#externalLinkClick)
  return(1)
  exit
end

on removeTooltipWindow(me)
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  exit
end

on removeWindowTimeout(me)
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  exit
end

on createWindowTimeout(me)
  me.removeWindowTimeout()
  tTimeoutTime = integer(getVariable("external_link_win_timeout", 2000))
  createTimeout(pTimeOutID, tTimeoutTime, #removeTooltipWindow, me.getID(), void(), 1)
  exit
end

on createActivateTimeout(me)
  me.removeActivateTimeout()
  tTimeoutTime = integer(getVariable("external_link_win_activate_timeout", 500))
  createTimeout(pActivateID, tTimeoutTime, #activateToolTip, me.getID(), void(), 1)
  exit
end

on removeActivateTimeout(me)
  if timeoutExists(pActivateID) then
    removeTimeout(pActivateID)
  end if
  exit
end

on activateToolTip(me)
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  activateWindowObj(pWindowID)
  exit
end

on createTooltipWindow(me)
  createWindow(pWindowID, "tooltip_external_link.window")
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
  exit
end

on notifyExternalLinkClick(me, tClickLocation)
  if voidp(tClickLocation) then
    return(0)
  end if
  if ilk(tClickLocation) <> #point then
    return(0)
  end if
  if not windowExists(pWindowID) then
    me.createTooltipWindow()
  end if
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tWndWidth = tWndObj.getProperty(#width)
  tWndHeight = tWndObj.getProperty(#height)
  tMarginH = getVariable("external_link_win_offset_h")
  tMarginV = getVariable("external_link_win_offset_v")
  tScreenWidth = the stageRight - the stageLeft
  tOpenLocH = tClickLocation.getAt(1) + tMarginH
  if tOpenLocH + tWndWidth > tScreenWidth then
    tOpenLocH = tClickLocation.getAt(1) - tMarginH - tWndWidth
  end if
  tOpenLocV = tClickLocation.getAt(2) - tMarginV - tWndHeight
  if tOpenLocV - tMarginV < 0 then
    tOpenLocV = tClickLocation.getAt(2) + tMarginV
  end if
  tWndObj.moveTo(tOpenLocH, tOpenLocV)
  me.createWindowTimeout()
  me.createActivateTimeout()
  exit
end

on eventProc(me, tEvent, tElemID, tParam)
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  if tEvent = #mouseUp then
    me.removeTooltipWindow()
  end if
  exit
end