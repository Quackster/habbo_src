on constructProfileManager()
  return(createManager(#profile_manager, ["Profile Manager Class"]))
  exit
end

on deconstructProfileManager()
  return(removeManager(#profile_manager))
  exit
end

on getProfileManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#profile_manager) then
    return(constructProfileManager())
  end if
  return(tMgr.getManager(#profile_manager))
  exit
end

on createProfileTask(tTask)
  return(getProfileManager().create(tTask))
  exit
end

on removeProfileTask(tTask)
  return(getProfileManager().Remove(tTask))
  exit
end

on getProfileTask(tTask)
  return(getProfileManager().GET(tTask))
  exit
end

on profileTaskExists(tTask)
  return(getProfileManager().exists(tTask))
  exit
end

on startProfilingTask(tTask)
  if not getObjectManager().managerExists(#profile_manager) then
    return()
  end if
  return(getProfileManager().start(tTask))
  exit
end

on finishProfilingTask(tTask)
  if not getObjectManager().managerExists(#profile_manager) then
    return()
  end if
  return(getProfileManager().finish(tTask))
  exit
end

on resetProfiler()
  return(getProfileManager().reset())
  exit
end

on printProfileTasks()
  return(getProfileManager().print())
  exit
end

on showProfileWindow()
  return(getProfileManager().printToDialog())
  exit
end

on handlers()
  return([])
  exit
end