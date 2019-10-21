on constructVisualizerManager()
  return(createManager(#visualizer_manager, getClassVariable("visualizer.manager.class")))
  exit
end

on deconstructVisualizerManager()
  return(removeManager(#visualizer_manager))
  exit
end

on getVisualizerManager()
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#visualizer_manager) then
    return(constructVisualizerManager())
  end if
  return(tObjMngr.getManager(#visualizer_manager))
  exit
end

on createVisualizer(tid, tLayout)
  return(getVisualizerManager().create(tid, tLayout))
  exit
end

on removeVisualizer(tid)
  return(getVisualizerManager().remove(tid))
  exit
end

on getVisualizer(tid)
  return(getVisualizerManager().get(tid))
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