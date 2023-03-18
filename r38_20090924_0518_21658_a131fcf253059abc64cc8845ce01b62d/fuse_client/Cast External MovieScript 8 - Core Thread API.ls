on constructThreadManager
  return createManager(#thread_manager, getClassVariable("thread.manager.class"))
end

on deconstructThreadManager
  return removeManager(#thread_manager)
end

on getThreadManager
  tMgr = getObjectManager()
  if not tMgr.managerExists(#thread_manager) then
    return constructThreadManager()
  end if
  return tMgr.getManager(#thread_manager)
end

on createThread tID, tInitField
  return getThreadManager().create(tID, tInitField)
end

on removeThread tID
  return getThreadManager().Remove(tID)
end

on getThread tID
  return getThreadManager().GET(tID)
end

on threadExists tID
  return getThreadManager().exists(tID)
end

on initThread tCastNumOrMemName
  return getThreadManager().initThread(tCastNumOrMemName)
end

on initExistingThreads
  return getThreadManager().initAll()
end

on closeThread tCastNumOrID
  return getThreadManager().closeThread(tCastNumOrID)
end

on closeExistingThreads
  return getThreadManager().closeAll()
end

on printThreads
  return getThreadManager().print()
end

on handlers
  return []
end
