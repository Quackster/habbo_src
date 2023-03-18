on constructTimeoutManager
  return createManager(#timeout_manager, getClassVariable("timeout.manager.class"))
end

on deconstructTimeoutManager
  return removeManager(#timeout_manager)
end

on getTimeoutManager
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#timeout_manager) then
    return constructTimeoutManager()
  end if
  return tObjMngr.getManager(#timeout_manager)
end

on createTimeout tid, tTime, tHandler, tClientID, tArguments, tIterations
  return getTimeoutManager().create(tid, tTime, tHandler, tClientID, tArguments, tIterations)
end

on removeTimeout tid
  return getTimeoutManager().remove(tid)
end

on getTimeout tid
  return getTimeoutManager().get(tid)
end

on timeoutExists tid
  return getTimeoutManager().exists(tid)
end

on printTimeouts
  return getTimeoutManager().print()
end
