on constructCastLoader()
  return(createManager(#castload_manager, getClassVariable("castlib.manager.class")))
  exit
end

on deconstructCastLoader()
  return(removeManager(#castload_manager))
  exit
end

on getCastLoadManager()
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#castload_manager) then
    return(constructCastLoader())
  end if
  return(tObjMngr.getManager(#castload_manager))
  exit
end

on startCastLoad(tCastlibs, tPermanentOrNot, tAddFlag)
  return(getCastLoadManager().startCastLoad(tCastlibs, tPermanentOrNot, tAddFlag))
  exit
end

on registerCastloadCallback(tid, tMethod, tClientObj, tArgument)
  return(getCastLoadManager().registerCallback(tid, tMethod, tClientObj, tArgument))
  exit
end

on resetCastLibs(tClean, tForced)
  return(getCastLoadManager().resetCastLibs(tClean, tForced))
  exit
end

on getCastLoadPercent(tid)
  return(getCastLoadManager().getLoadPercent(tid))
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