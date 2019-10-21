on constructMultiuserManager()
  return(createManager(#multiuser_manager, getClassVariable("multiuser.manager.class")))
  exit
end

on deconstructMultiuserManager()
  return(removeManager(#multiuser_manager))
  exit
end

on getMultiuserManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#multiuser_manager) then
    return(constructMultiuserManager())
  end if
  return(tMgr.getManager(#multiuser_manager))
  exit
end

on createMultiuser(tid, tHost, tPort)
  return(getMultiuserManager().create(tid, tHost, tPort))
  exit
end

on removeMultiuser(tid)
  return(getMultiuserManager().remove(tid))
  exit
end

on getMultiuser(tid)
  return(getMultiuserManager().get(tid))
  exit
end

on multiuserExists(tid)
  return(getMultiuserManager().exists(tid))
  exit
end

on printMultiusers()
  return(getMultiuserManager().print())
  exit
end