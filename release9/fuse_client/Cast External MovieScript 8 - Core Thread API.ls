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

on createThread tid, tInitField
  return getThreadManager().create(tid, tInitField)
end

on removeThread tid
  return getThreadManager().Remove(tid)
end

on getThread tid
  return getThreadManager().get(tid)
end

on threadExists tid
  return getThreadManager().exists(tid)
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
