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

on startCastLoad tCastlibs, tPermanentOrNot, tAddFlag
  return getCastLoadManager().startCastLoad(tCastlibs, tPermanentOrNot, tAddFlag)
end

on registerCastloadCallback tid, tMethod, tClientObj, tArgument
  return getCastLoadManager().registerCallback(tid, tMethod, tClientObj, tArgument)
end

on resetCastLibs tClean, tForced
  return getCastLoadManager().resetCastLibs(tClean, tForced)
end

on getCastLoadPercent tid
  return getCastLoadManager().getLoadPercent(tid)
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
