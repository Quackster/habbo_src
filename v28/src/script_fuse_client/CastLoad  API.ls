on constructCastLoader()
  return(createManager(#castload_manager, getClassVariable("castlib.manager.class")))
  exit
end

on deconstructCastLoader()
  return(removeManager(#castload_manager))
  exit
end

on getCastLoadManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#castload_manager) then
    return(constructCastLoader())
  end if
  return(tMgr.getManager(#castload_manager))
  exit
end

on startCastLoad(tCastlibs, tPermanentOrNot, tAddFlag, tDoIndexing, tDoTracking)
  return(getCastLoadManager().startCastLoad(tCastlibs, tPermanentOrNot, tAddFlag, tDoIndexing, tDoTracking))
  exit
end

on registerCastloadCallback(tID, tMethod, tClientObj, tArgument)
  return(getCastLoadManager().registerCallback(tID, tMethod, tClientObj, tArgument))
  exit
end

on resetCastLibs(tClean, tForced)
  return(getCastLoadManager().resetCastLibs(tClean, tForced))
  exit
end

on getCastLoadPercent(tID)
  return(getCastLoadManager().getLoadPercent(tID))
  exit
end

on FindCastNumber(tCastName)
  return(getCastLoadManager().FindCastNumber(tCastName))
  exit
end

on castExists(tCastName)
  return(getCastLoadManager().exists(tCastName))
  exit
end

on printCasts()
  return(getCastLoadManager().print())
  exit
end