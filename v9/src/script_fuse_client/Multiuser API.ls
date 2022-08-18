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

on createMultiuser tid, tHost, tPort
  return getMultiuserManager().create(tid, tHost, tPort)
end

on removeMultiuser tid
  return getMultiuserManager().Remove(tid)
end

on getMultiuser tid
  return getMultiuserManager().get(tid)
end

on multiuserExists tid
  return getMultiuserManager().exists(tid)
end

on printMultiusers
  return getMultiuserManager().print()
end
