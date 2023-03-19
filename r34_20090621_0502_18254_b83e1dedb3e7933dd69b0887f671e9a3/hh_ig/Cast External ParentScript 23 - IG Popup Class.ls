property pVisible, pTargetElementID

on construct me
  pVisible = 0
  registerMessage(#toggle_ig, me.getID(), #hide)
  return 1
end

on deconstruct me
  unregisterMessage(#toggle_ig, me.getID())
  return 1
end

on Init me, tTargetElementID
  pTargetElementID = tTargetElementID
end

on show me
  if pVisible then
    return 1
  end if
  tMainThread = getObject(#ig_component)
  if tMainThread = 0 then
    return me.hide()
  end if
  if tMainThread.getSystemState() <> #ready then
    return me.hide()
  end if
  if tMainThread.getInterface().getWindowVisible() then
    return 1
  end if
  tService = tMainThread.getIGComponent("Recommended")
  if tService = 0 then
    return 0
  end if
  tRenderObj = tService.getRenderer(1)
  if tRenderObj = 0 then
    return 0
  end if
  tService.renderUI()
  tRenderObj.setTarget(pTargetElementID)
  pVisible = 1
  return 1
end

on hide me
  if not pVisible then
    return 1
  end if
  pVisible = 0
  tService = getObject(#ig_component)
  if tService = 0 then
    return 0
  end if
  tService.removeIGComponent("Recommended")
  return 1
end
