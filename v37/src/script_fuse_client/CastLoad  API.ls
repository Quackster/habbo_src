on constructCastLoader
  return createManager(#castload_manager, getClassVariable("castlib.manager.class"))
end

on deconstructCastLoader
  return removeManager(#castload_manager)
end

on getCastLoadManager
  tMgr = getObjectManager()
  if not tMgr.managerExists(#castload_manager) then
    return constructCastLoader()
  end if
  return tMgr.getManager(#castload_manager)
end

on startCastLoad tCastlibs, tPermanentOrNot, tAddFlag, tDoIndexing, tDoTracking
  return getCastLoadManager().startCastLoad(tCastlibs, tPermanentOrNot, tAddFlag, tDoIndexing, tDoTracking)
end

on registerCastloadCallback tID, tMethod, tClientObj, tArgument
  return getCastLoadManager().registerCallback(tID, tMethod, tClientObj, tArgument)
end

on resetCastLibs tClean, tForced
  return getCastLoadManager().resetCastLibs(tClean, tForced)
end

on getCastLoadPercent tID
  return getCastLoadManager().getLoadPercent(tID)
end

on FindCastNumber tCastName
  return getCastLoadManager().FindCastNumber(tCastName)
end

on castExists tCastName
  return getCastLoadManager().exists(tCastName)
end

on printCasts
  return getCastLoadManager().print()
end

on handlers
  return []
end
