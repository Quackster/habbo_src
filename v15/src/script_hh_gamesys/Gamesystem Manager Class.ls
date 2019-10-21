property pSystemThread, pSystemId, pModules

on construct me 
  pSystemId = "gamesystem"
  pModules = ["baselogic", "messagesender", "messagehandler", "procmanager", "turnmanager", "world", "component"]
  dumpVariableField("gamesystem.variable.index")
  registerMessage(#gamesystem_getfacade, me.getID(), #getFacade)
  registerMessage(#gamesystem_removefacade, me.getID(), #removeFacade)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#gamesystem_getfacade, me.getID())
  unregisterMessage(#gamesystem_removefacade, me.getID())
  me.removeGamesystem()
  return TRUE
end

on getFacade me, tid 
  if not objectp(pSystemThread) then
    me.createGamesystem(tid)
  end if
  if (getObject(tid) = 0) then
    createObject(tid, getClassVariable("gamesystem.facade.class"))
    if (getObject(tid) = 0) then
      return FALSE
    end if
    getObject(tid).defineClient(pSystemThread)
  end if
  return(getObject(tid))
end

on removeFacade me, tid 
  if (getObject(tid) = 0) then
    return FALSE
  else
    if (removeObject(tid) = 0) then
      return FALSE
    end if
  end if
  me.removeGamesystem()
  return TRUE
end

on createGamesystem me, tSystemId 
  pSystemThread = createObject(#temp, getClassVariable(pSystemId & ".subsystem.superclass"))
  pSystemThread.setaProp(#systemid, tSystemId)
  repeat while pModules <= undefined
    tModule = getAt(undefined, tSystemId)
    tObjID = symbol(pSystemId & "_" & tModule)
    tClassVarName = pSystemId & "." & tModule & ".class"
    tClass = getClassVariable(tClassVarName)
    if not getmemnum(tClass) then
      return(error(me, "Game system class not found!:" && tClassVarName, #createGamesystem))
    end if
    createObject(tObjID, tClass)
    tObj = getObject(tObjID)
    tObj.setAt(#ancestor, pSystemThread)
    pSystemThread.setaProp(symbol(tModule), tObj)
  end repeat
  tModuleObj = createObject(symbol(pSystemId & "_variablemanager"), getClassVariable("variable.manager.class"))
  pSystemThread.setaProp(#variablemanager, tModuleObj)
  executeMessage(#gamesystem_constructed)
  return TRUE
end

on removeGamesystem me 
  repeat while pModules <= undefined
    tModule = getAt(undefined, undefined)
    tObjID = symbol(pSystemId & "_" & tModule)
    removeObject(tObjID)
  end repeat
  removeObject(symbol(pSystemId & "_variablemanager"))
  pSystemThread = void()
  executeMessage(#gamesystem_deconstructed)
  return TRUE
end
