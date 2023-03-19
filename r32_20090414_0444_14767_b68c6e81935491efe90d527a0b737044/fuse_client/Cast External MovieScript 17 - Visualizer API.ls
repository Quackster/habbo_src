on constructVisualizerManager
  return createManager(#visualizer_manager, getClassVariable("visualizer.manager.class"))
end

on deconstructVisualizerManager
  return removeManager(#visualizer_manager)
end

on getVisualizerManager
  tMgr = getObjectManager()
  if not tMgr.managerExists(#visualizer_manager) then
    return constructVisualizerManager()
  end if
  return tMgr.getManager(#visualizer_manager)
end

on createVisualizer tID, tLayout, tLocX, tLocY
  return getVisualizerManager().create(tID, tLayout, tLocX, tLocY)
end

on removeVisualizer tID
  return getVisualizerManager().Remove(tID)
end

on getVisualizer tID
  return getVisualizerManager().GET(tID)
end

on visualizerExists tID
  return getVisualizerManager().exists(tID)
end

on printVisualizers
  return getVisualizerManager().print()
end

on handlers
  return []
end
