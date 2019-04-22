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

on createVisualizer(tid, tLayout)
  return(getVisualizerManager().create(tid, tLayout))
  exit
end

on removeVisualizer(tid)
  return(getVisualizerManager().Remove(tid))
  exit
end

on getVisualizer(tid)
  return(getVisualizerManager().GET(tid))
  exit
end

on visualizerExists(tid)
  return(getVisualizerManager().exists(tid))
  exit
end

on printVisualizers()
  return(getVisualizerManager().print())
  exit
end