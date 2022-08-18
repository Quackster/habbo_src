on constructProfileManager
  return createManager(#profile_manager, ["Profile Manager Class"])
end

on deconstructProfileManager
  return removeManager(#profile_manager)
end

on getProfileManager
  tMgr = getObjectManager()
  if not tMgr.managerExists(#profile_manager) then
    return constructProfileManager()
  end if
  return tMgr.getManager(#profile_manager)
end

on createProfileTask tTask
  return getProfileManager().create(tTask)
end

on removeProfileTask tTask
  return getProfileManager().Remove(tTask)
end

on getProfileTask tTask
  return getProfileManager().GET(tTask)
end

on profileTaskExists tTask
  return getProfileManager().exists(tTask)
end

on startProfilingTask tTask
  if not getObjectManager().managerExists(#profile_manager) then
    return 
  end if
  return getProfileManager().start(tTask)
end

on finishProfilingTask tTask
  if not getObjectManager().managerExists(#profile_manager) then
    return 
  end if
  return getProfileManager().finish(tTask)
end

on resetProfiler
  return getProfileManager().reset()
end

on printProfileTasks
  return getProfileManager().print()
end

on showProfileWindow
  return getProfileManager().printToDialog()
end

on handlers
  return []
end
