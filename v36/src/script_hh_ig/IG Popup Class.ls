property pVisible, pTargetElementID

on construct me 
  pVisible = 0
  registerMessage(#toggle_ig, me.getID(), #hide)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#toggle_ig, me.getID())
  return TRUE
end

on Init me, tTargetElementID 
  pTargetElementID = tTargetElementID
end

on show me 
  if pVisible then
    return TRUE
  end if
  tMainThread = getObject(#ig_component)
  if (tMainThread = 0) then
    return(me.hide())
  end if
  if tMainThread.getSystemState() <> #ready then
    return(me.hide())
  end if
  if tMainThread.getInterface().getWindowVisible() then
    return TRUE
  end if
  tService = tMainThread.getIGComponent("Recommended")
  if (tService = 0) then
    return FALSE
  end if
  tRenderObj = tService.getRenderer(1)
  if (tRenderObj = 0) then
    return FALSE
  end if
  tService.renderUI()
  tRenderObj.setTarget(pTargetElementID)
  pVisible = 1
  return TRUE
end

on hide me 
  if not pVisible then
    return TRUE
  end if
  pVisible = 0
  tService = getObject(#ig_component)
  if (tService = 0) then
    return FALSE
  end if
  tService.removeIGComponent("Recommended")
  return TRUE
end
