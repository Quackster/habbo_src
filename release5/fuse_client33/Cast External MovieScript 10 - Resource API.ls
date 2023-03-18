on constructResourceManager
  return createManager(#resource_manager, getClassVariable("resource.manager.class"))
end

on deconstructResourceManager
  return removeManager(#resource_manager)
end

on getResourceManager
  tMgr = getObjectManager()
  if not tMgr.managerExists(#resource_manager) then
    return constructResourceManager()
  end if
  return tMgr.getManager(#resource_manager)
end

on createMember tMemName, ttype
  return getResourceManager().createMember(tMemName, ttype)
end

on removeMember tMemName
  return getResourceManager().removeMember(tMemName)
end

on getMember tMemName
  return getResourceManager().getMember(tMemName)
end

on updateMember tMemName
  return getResourceManager().updateMember(tMemName)
end

on registerMember tMemName, tOptionalMemNum
  return getResourceManager().registerMember(tMemName, tOptionalMemNum)
end

on unregisterMember tMemName
  return getResourceManager().unregisterMember(tMemName)
end

on replaceMember tExistingMemName, tReplacingMemName
  return getResourceManager().replaceMember(tExistingMemName, tReplacingMemName)
end

on memberExists tMemName
  return getResourceManager().exists(tMemName)
end

on getmemnum tMemName
  return getResourceManager().getmemnum(tMemName)
end

on printMembers
  return getResourceManager().print()
end
