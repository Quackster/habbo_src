on constructResourceManager()
  return(createManager(#resource_manager, getClassVariable("resource.manager.class")))
  exit
end

on deconstructResourceManager()
  return(removeManager(#resource_manager))
  exit
end

on getResourceManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#resource_manager) then
    return(constructResourceManager())
  end if
  return(tMgr.getManager(#resource_manager))
  exit
end

on createMember(tMemName, ttype, tForcedDuplicate)
  return(getResourceManager().createMember(tMemName, ttype, tForcedDuplicate))
  exit
end

on removeMember(tMemName)
  return(getResourceManager().removeMember(tMemName))
  exit
end

on getMember(tMemName)
  return(getResourceManager().getMember(tMemName))
  exit
end

on updateMember(tMemName)
  return(getResourceManager().updateMember(tMemName))
  exit
end

on registerMember(tMemName, tOptionalMemNum)
  return(getResourceManager().registerMember(tMemName, tOptionalMemNum))
  exit
end

on unregisterMember(tMemName)
  return(getResourceManager().unregisterMember(tMemName))
  exit
end

on replaceMember(tExistingMemName, tReplacingMemName)
  return(getResourceManager().replaceMember(tExistingMemName, tReplacingMemName))
  exit
end

on memberExists(tMemName)
  return(getResourceManager().exists(tMemName))
  exit
end

on getmemnum(tMemName)
  return(getResourceManager().getmemnum(tMemName))
  exit
end

on printMembers()
  return(getResourceManager().print())
  exit
end