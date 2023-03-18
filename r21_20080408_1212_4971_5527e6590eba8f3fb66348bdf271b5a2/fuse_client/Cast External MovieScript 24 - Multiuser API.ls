on constructMultiuserManager
  return createManager(#multiuser_manager, getClassVariable("multiuser.manager.class"))
end

on deconstructMultiuserManager
  return removeManager(#multiuser_manager)
end

on getMultiuserManager
  tMgr = getObjectManager()
  if not tMgr.managerExists(#multiuser_manager) then
    return constructMultiuserManager()
  end if
  return tMgr.getManager(#multiuser_manager)
end

on createMultiuser tID, tHost, tPort
  return getMultiuserManager().create(tID, tHost, tPort)
end

on removeMultiuser tID
  return getMultiuserManager().Remove(tID)
end

on getMultiuser tID
  return getMultiuserManager().GET(tID)
end

on multiuserExists tID
  return getMultiuserManager().exists(tID)
end

on printMultiusers
  return getMultiuserManager().print()
end
