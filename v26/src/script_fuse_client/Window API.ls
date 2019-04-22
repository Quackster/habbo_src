on constructWindowManager()
  return(createManager(#window_manager, getClassVariable("window.manager.class")))
  exit
end

on deconstructWindowManager()
  return(removeManager(#window_manager))
  exit
end

on getWindowManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#window_manager) then
    return(constructWindowManager())
  end if
  return(tMgr.getManager(#window_manager))
  exit
end

on createWindow(tID, tLayout, tLocX, tLocY, tSpecial)
  return(getWindowManager().create(tID, tLayout, tLocX, tLocY, tSpecial))
  exit
end

on removeWindow(tID)
  return(getWindowManager().Remove(tID))
  exit
end

on getWindow(tID)
  return(getWindowManager().GET(tID))
  exit
end

on getWindowIDList()
  return(getWindowManager().getIDList())
  exit
end

on windowExists(tID)
  return(getWindowManager().exists(tID))
  exit
end

on mergeWindow(tID, tLayout)
  if windowExists(tID) then
    return(getWindow(tID).merge(tLayout))
  else
    return(0)
  end if
  exit
end

on activateWindowObj(tID)
  if voidp(tID) then
    return(0)
  end if
  return(getWindowManager().Activate(tID))
  exit
end

on deactivateWindowObj(tID)
  if voidp(tID) then
    return(0)
  end if
  return(getWindowManager().deactivate(tID))
  exit
end

on registerClient(tID, tClientID)
  if windowExists(tID) then
    return(getWindow(tID).registerClient(tClientID))
  else
    return(0)
  end if
  exit
end

on registerProcedure(tID, tHandler, tClientID, tEvent)
  if windowExists(tID) then
    return(getWindow(tID).registerProcedure(tHandler, tClientID, tEvent))
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