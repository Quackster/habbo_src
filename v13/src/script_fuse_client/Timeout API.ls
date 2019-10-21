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

on createTimeout(tid, tTime, tHandler, tClientID, tArguments, tIterations)
  return(getTimeoutManager().create(tid, tTime, tHandler, tClientID, tArguments, tIterations))
  exit
end

on removeTimeout(tid)
  return(getTimeoutManager().Remove(tid))
  exit
end

on getTimeout(tid)
  return(getTimeoutManager().get(tid))
  exit
end

on timeoutExists(tid)
  return(getTimeoutManager().exists(tid))
  exit
end

on printTimeouts()
  return(getTimeoutManager().print())
  exit
end