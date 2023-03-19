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

on createVisualizer tid, tLayout
  return getVisualizerManager().create(tid, tLayout)
end

on removeVisualizer tid
  return getVisualizerManager().Remove(tid)
end

on getVisualizer tid
  return getVisualizerManager().get(tid)
end

on visualizerExists tid
  return getVisualizerManager().exists(tid)
end

on printVisualizers
  return getVisualizerManager().print()
end
