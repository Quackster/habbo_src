property pSystemId, pSystemThread, pModules

on construct me
  pSystemId = "gamesystem"
  pModules = ["baselogic", "messagesender", "messagehandler", "procmanager", "turnmanager", "world", "component"]
  dumpVariableField("gamesystem.variable.index")
  registerMessage(#gamesystem_getfacade, me.getID(), #getFacade)
  registerMessage(#gamesystem_removefacade, me.getID(), #removeFacade)
  return 1
end

on deconstruct me
  unregisterMessage(#gamesystem_getfacade, me.getID())
  unregisterMessage(#gamesystem_removefacade, me.getID())
  me.removeGamesystem()
  return 1
end

on getFacade me, tID
  if not objectp(pSystemThread) then
    me.createGamesystem(tID)
  end if
  if getObject(tID) = 0 then
    createObject(tID, getClassVariable("gamesystem.facade.class"))
    if getObject(tID) = 0 then
      return 0
    end if
    getObject(tID).defineClient(pSystemThread)
  end if
  return getObject(tID)
end

on removeFacade me, tID
  if getObject(tID) = 0 then
    return 0
  else
    if removeObject(tID) = 0 then
      return 0
    end if
  end if
  me.removeGamesystem()
  return 1
end

on createGamesystem me, tSystemId
  pSystemThread = createObject(#temp, getClassVariable(pSystemId & ".subsystem.superclass"))
  pSystemThread.setaProp(#systemid, tSystemId)
  repeat with tModule in pModules
    tObjID = symbol(pSystemId & "_" & tModule)
    tClassVarName = pSystemId & "." & tModule & ".class"
    tClass = getClassVariable(tClassVarName)
    if not getmemnum(tClass) then
      return error(me, "Game system class not found!:" && tClassVarName, #createGamesystem)
    end if
    createObject(tObjID, tClass)
    tObj = getObject(tObjID)
    tObj[#ancestor] = pSystemThread
    pSystemThread.setaProp(symbol(tModule), tObj)
  end repeat
  tModuleObj = createObject(symbol(pSystemId & "_variablemanager"), getClassVariable("variable.manager.class"))
  pSystemThread.setaProp(#variablemanager, tModuleObj)
  executeMessage(#gamesystem_constructed)
  return 1
end

on removeGamesystem me
  repeat with tModule in pModules
    tObjID = symbol(pSystemId & "_" & tModule)
    removeObject(tObjID)
  end repeat
  removeObject(symbol(pSystemId & "_variablemanager"))
  pSystemThread = VOID
  executeMessage(#gamesystem_deconstructed)
  return 1
end
