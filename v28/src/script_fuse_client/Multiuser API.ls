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

on createMultiuser(tID, tHost, tPort)
  return(getMultiuserManager().create(tID, tHost, tPort))
  exit
end

on removeMultiuser(tID)
  return(getMultiuserManager().Remove(tID))
  exit
end

on getMultiuser(tID)
  return(getMultiuserManager().GET(tID))
  exit
end

on multiuserExists(tID)
  return(getMultiuserManager().exists(tID))
  exit
end

on printMultiusers()
  return(getMultiuserManager().print())
  exit
end