on constructWindowManager
  return createManager(#window_manager, getClassVariable("window.manager.class"))
end

on deconstructWindowManager
  return removeManager(#window_manager)
end

on getWindowManager
  tMgr = getObjectManager()
  if not tMgr.managerExists(#window_manager) then
    return constructWindowManager()
  end if
  return tMgr.getManager(#window_manager)
end

on createWindow tID, tLayout, tLocX, tLocY, tSpecial
  return getWindowManager().create(tID, tLayout, tLocX, tLocY, tSpecial)
end

on removeWindow tID
  return getWindowManager().Remove(tID)
end

on getWindow tID
  return getWindowManager().GET(tID)
end

on getWindowIDList
  return getWindowManager().getIDList()
end

on windowExists tID
  return getWindowManager().exists(tID)
end

on mergeWindow tID, tLayout
  if windowExists(tID) then
    return getWindow(tID).merge(tLayout)
  else
    return 0
  end if
end

on activateWindowObj tID
  if voidp(tID) then
    return 0
  end if
  return getWindowManager().Activate(tID)
end

on deactivateWindowObj tID
  if voidp(tID) then
    return 0
  end if
  return getWindowManager().deactivate(tID)
end

on registerClient tID, tClientID
  if windowExists(tID) then
    return getWindow(tID).registerClient(tClientID)
  else
    return 0
  end if
end

on registerProcedure tID, tHandler, tClientID, tEvent
  if windowExists(tID) then
    return getWindow(tID).registerProcedure(tHandler, tClientID, tEvent)
  else
    return 0
  end if
end

on showWindows
  return getWindowManager().showAll()
end

on hideWindows
  return getWindowManager().hideAll()
end

on lockWindowLayering
  return getWindowManager().lock()
end

on unlockWindowLayering
  return getWindowManager().unlock()
end

on printWindows
  return getWindowManager().print()
end
