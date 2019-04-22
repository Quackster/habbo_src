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

on createThread(tID, tInitField)
  return(getThreadManager().create(tID, tInitField))
  exit
end

on removeThread(tID)
  return(getThreadManager().Remove(tID))
  exit
end

on getThread(tID)
  return(getThreadManager().GET(tID))
  exit
end

on threadExists(tID)
  return(getThreadManager().exists(tID))
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

on handlers()
  return([])
  exit
end