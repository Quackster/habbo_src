on constructVisualizerManager()
  return(createManager(#visualizer_manager, getClassVariable("visualizer.manager.class")))
  exit
end

on deconstructVisualizerManager()
  return(removeManager(#visualizer_manager))
  exit
end

on getVisualizerManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#visualizer_manager) then
    return(constructVisualizerManager())
  end if
  return(tMgr.getManager(#visualizer_manager))
  exit
end

on createVisualizer(tID, tLayout)
  return(getVisualizerManager().create(tID, tLayout))
  exit
end

on removeVisualizer(tID)
  return(getVisualizerManager().Remove(tID))
  exit
end

on getVisualizer(tID)
  return(getVisualizerManager().GET(tID))
  exit
end

on visualizerExists(tID)
  return(getVisualizerManager().exists(tID))
  exit
end

on printVisualizers()
  return(getVisualizerManager().print())
  exit
end