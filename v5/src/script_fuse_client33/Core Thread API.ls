on constructThreadManager()
  return(createManager(#thread_manager, getClassVariable("thread.manager.class")))
  exit
end

on deconstructThreadManager()
  return(removeManager(#thread_manager))
  exit
end

on getThreadManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#thread_manager) then
    return(constructThreadManager())
  end if
  return(tMgr.getManager(#thread_manager))
  exit
end

on createThread(tid, tInitField)
  return(getThreadManager().create(tid, tInitField))
  exit
end

on removeThread(tid)
  return(getThreadManager().remove(tid))
  exit
end

on getThread(tid)
  return(getThreadManager().get(tid))
  exit
end

on threadExists(tid)
  return(getThreadManager().exists(tid))
  exit
end

on initThread(tCastNumOrMemName)
  return(getThreadManager().initThread(tCastNumOrMemName))
  exit
end

on initExistingThreads()
  return(getThreadManager().initAll())
  exit
end

on closeThread(tCastNumOrID)
  return(getThreadManager().closeThread(tCastNumOrID))
  exit
end

on closeExistingThreads()
  return(getThreadManager().closeAll())
  exit
end

on printThreads()
  return(getThreadManager().print())
  exit
end