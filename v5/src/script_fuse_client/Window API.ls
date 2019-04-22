on constructWindowManager()
  return(createManager(#window_manager, getClassVariable("window.manager.class")))
  exit
end

on deconstructWindowManager()
  return(removeManager(#window_manager))
  exit
end

on getWindowManager()
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#window_manager) then
    return(constructWindowManager())
  end if
  return(tObjMngr.getManager(#window_manager))
  exit
end

on createWindow(tid, tLayout, tLocX, tLocY, tSpecial)
  return(getWindowManager().create(tid, tLayout, tLocX, tLocY, tSpecial))
  exit
end

on removeWindow(tid)
  return(getWindowManager().remove(tid))
  exit
end

on getWindow(tid)
  return(getWindowManager().get(tid))
  exit
end

on windowExists(tid)
  return(getWindowManager().exists(tid))
  exit
end

on mergeWindow(tid, tLayout)
  if windowExists(tid) then
    return(getWindow(tid).merge(tLayout))
  else
    return(0)
  end if
  exit
end

on activateWindow(tid)
  return(getWindowManager().Activate(tid))
  exit
end

on deactivateWindow(tid)
  return(getWindowManager().deactivate(tid))
  exit
end

on registerClient(tid, tClientID)
  if windowExists(tid) then
    return(getWindow(tid).registerClient(tClientID))
  else
    return(0)
  end if
  exit
end

on registerProcedure(tid, tHandler, tClientID, tEvent)
  if windowExists(tid) then
    return(getWindow(tid).registerProcedure(tHandler, tClientID, tEvent))
  else
    return(0)
  end if
  exit
end

on showWindows()
  return(getWindowManager().showAll())
  exit
end

on hideWindows()
  return(getWindowManager().hideAll())
  exit
end

on lockWindowLayering()
  return(getWindowManager().lock())
  exit
end

on unlockWindowLayering()
  return(getWindowManager().unlock())
  exit
end

on printWindows()
  return(getWindowManager().print())
  exit
end