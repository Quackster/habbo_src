on constructMultiuserManager
  return createManager(#multiuser_manager, getClassVariable("multiuser.manager.class"))
end

on deconstructMultiuserManager
  return removeManager(#multiuser_manager)
end

on getMultiuserManager
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#multiuser_manager) then
    return constructMultiuserManager()
  end if
  return tObjMngr.getManager(#multiuser_manager)
end

on createMultiuser tid, tHost, tPort
  return getMultiuserManager().create(tid, tHost, tPort)
end

on removeMultiuser tid
  return getMultiuserManager().remove(tid)
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
