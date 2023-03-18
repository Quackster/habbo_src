on constructTimeoutManager
  return createManager(#timeout_manager, getClassVariable("timeout.manager.class"))
end

on deconstructTimeoutManager
  return removeManager(#timeout_manager)
end

on getTimeoutManager
  tMgr = getObjectManager()
  if not tMgr.managerExists(#timeout_manager) then
    return constructTimeoutManager()
  end if
  return tMgr.getManager(#timeout_manager)
end

on createTimeout tID, tTime, tHandler, tClientID, tArguments, tIterations
  return getTimeoutManager().create(tID, tTime, tHandler, tClientID, tArguments, tIterations)
end

on removeTimeout tID
  return getTimeoutManager().Remove(tID)
end

on getTimeout tID
  return getTimeoutManager().GET(tID)
end

on timeoutExists tID
  return getTimeoutManager().exists(tID)
end

on printTimeouts
  return getTimeoutManager().print()
end
