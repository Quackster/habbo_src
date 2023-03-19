global gCore

on constructObjectManager me
  if objectp(gCore) then
    return gCore
  end if
  tClass = value(convertToPropList(field("System Props"), RETURN)["object.manager.class"])[1]
  gCore = script(tClass).new()
  gCore.construct()
  return gCore
end

on deconstructObjectManager
  if voidp(gCore) then
    return 0
  end if
  gCore.deconstruct()
  gCore = VOID
  return 1
end

on getObjectManager
  if voidp(gCore) then
    return constructObjectManager()
  end if
  return gCore
end

on createObject tid
  tClassList = []
  repeat with i = 2 to the paramCount
    tParam = param(i)
    if listp(tParam) then
      repeat with tClass in tParam
        tClassList.add(tClass)
      end repeat
      next repeat
    end if
    tClassList.add(tParam)
  end repeat
  return getObjectManager().create(tid, tClassList)
end

on removeObject tid
  return getObjectManager().Remove(tid)
end

on getObject tid
  return getObjectManager().get(tid)
end

on objectExists tid
  return getObjectManager().exists(tid)
end

on printObjects
  return getObjectManager().print()
end

on registerObject tid, tObject
  return getObjectManager().registerObject(tid, tObject)
end

on unregisterObject tid
  return getObjectManager().unregisterObject(tid)
end

on createManager tid
  tClassList = []
  repeat with i = 2 to the paramCount
    tParam = param(i)
    if listp(tParam) then
      repeat with tClass in tParam
        tClassList.add(tClass)
      end repeat
      next repeat
    end if
    tClassList.add(tParam)
  end repeat
  tObjMngr = getObjectManager()
  tObjInst = tObjMngr.create(tid, tClassList)
  tObjMngr.registerManager(tid)
  tObjMngr.setaProp(tid, tObjInst)
  return tObjInst
end

on removeManager tid
  return getObjectManager().Remove(tid)
end

on getManager tid
  return getObjectManager().getManager(tid)
end

on managerExists tid
  return getObjectManager().managerExists(tid)
end

on printManagers
  return getObjectManager().print()
end

on registerManager tid
  return getObjectManager().registerManager(tid)
end

on unregisterManager tid
  return getObjectManager().unregisterManager(tid)
end

on receivePrepare tid
  return getObjectManager().receivePrepare(tid)
end

on removePrepare tid
  return getObjectManager().removePrepare(tid)
end

on receiveUpdate tid
  return getObjectManager().receiveUpdate(tid)
end

on removeUpdate tid
  return getObjectManager().removeUpdate(tid)
end

on pauseUpdate
  return getObjectManager().pauseUpdate()
end

on unpauseUpdate
  return getObjectManager().resumeUpdate()
end
