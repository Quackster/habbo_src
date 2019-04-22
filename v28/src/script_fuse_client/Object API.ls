on constructObjectManager(me)
  if objectp(gCore) then
    return(gCore)
  end if
  tClass = value(convertToPropList(field(0), "\r").getAt("object.manager.class")).getAt(1)
  gCore = script(tClass).new()
  gCore.construct()
  return(gCore)
  exit
end

on deconstructObjectManager()
  if voidp(gCore) then
    return(0)
  end if
  gCore.deconstruct()
  gCore = void()
  return(1)
  exit
end

on getObjectManager()
  if voidp(gCore) then
    return(constructObjectManager())
  end if
  return(gCore)
  exit
end

on createObject(tID)
  tClassList = []
  i = 2
  repeat while i <= the paramCount
    tParam = param(i)
    if listp(tParam) then
      repeat while tID <= undefined
        tClass = getAt(undefined, undefined)
        tClassList.add(tClass)
      end repeat
    else
      tClassList.add(tParam)
    end if
    i = 1 + i
  end repeat
  return(getObjectManager().create(tID, tClassList))
  exit
end

on removeObject(tID)
  return(getObjectManager().Remove(tID))
  exit
end

on getObject(tID)
  return(getObjectManager().GET(tID))
  exit
end

on objectExists(tID)
  return(getObjectManager().exists(tID))
  exit
end

on printObjects()
  return(getObjectManager().print())
  exit
end

on registerObject(tID, tObject)
  return(getObjectManager().registerObject(tID, tObject))
  exit
end

on unregisterObject(tID)
  return(getObjectManager().unregisterObject(tID))
  exit
end

on createManager(tID)
  tClassList = []
  i = 2
  repeat while i <= the paramCount
    tParam = param(i)
    if listp(tParam) then
      repeat while tID <= undefined
        tClass = getAt(undefined, undefined)
        tClassList.add(tClass)
      end repeat
    else
      tClassList.add(tParam)
    end if
    i = 1 + i
  end repeat
  tObjMngr = getObjectManager()
  tObjInst = tObjMngr.create(tID, tClassList)
  tObjMngr.registerManager(tID)
  tObjMngr.setaProp(tID, tObjInst)
  return(tObjInst)
  exit
end

on removeManager(tID)
  return(getObjectManager().Remove(tID))
  exit
end

on getManager(tID)
  return(getObjectManager().getManager(tID))
  exit
end

on managerExists(tID)
  return(getObjectManager().managerExists(tID))
  exit
end

on printManagers()
  return(getObjectManager().print())
  exit
end

on registerManager(tID)
  return(getObjectManager().registerManager(tID))
  exit
end

on unregisterManager(tID)
  return(getObjectManager().unregisterManager(tID))
  exit
end

on receivePrepare(tID)
  return(getObjectManager().receivePrepare(tID))
  exit
end

on removePrepare(tID)
  return(getObjectManager().removePrepare(tID))
  exit
end

on receiveUpdate(tID)
  return(getObjectManager().receiveUpdate(tID))
  exit
end

on removeUpdate(tID)
  return(getObjectManager().removeUpdate(tID))
  exit
end

on pauseUpdate()
  return(getObjectManager().pauseUpdate())
  exit
end

on unpauseUpdate()
  return(getObjectManager().resumeUpdate())
  exit
end