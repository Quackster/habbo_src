on constructTimeoutManager()
  return(createManager(#timeout_manager, getClassVariable("timeout.manager.class")))
  exit
end

on deconstructTimeoutManager()
  return(removeManager(#timeout_manager))
  exit
end

on getTimeoutManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#timeout_manager) then
    return(constructTimeoutManager())
  end if
  return(tMgr.getManager(#timeout_manager))
  exit
end

on createTimeout(tID, tTime, tHandler, tClientID, tArguments, tIterations)
  return(getTimeoutManager().create(tID, tTime, tHandler, tClientID, tArguments, tIterations))
  exit
end

on removeTimeout(tID)
  return(getTimeoutManager().Remove(tID))
  exit
end

on getTimeout(tID)
  return(getTimeoutManager().GET(tID))
  exit
end

on timeoutExists(tID)
  return(getTimeoutManager().exists(tID))
  exit
end

on printTimeouts()
  return(getTimeoutManager().print())
  exit
end

on handlers()
  return([])
  exit
end