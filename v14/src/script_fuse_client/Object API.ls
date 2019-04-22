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

on createObject(tid)
  tClassList = []
  i = 2
  repeat while i <= the paramCount
    tParam = param(i)
    if listp(tParam) then
      repeat while tid <= undefined
        tClass = getAt(undefined, undefined)
        tClassList.add(tClass)
      end repeat
    else
      tClassList.add(tParam)
    end if
    i = 1 + i
  end repeat
  return(getObjectManager().create(tid, tClassList))
  exit
end

on removeObject(tid)
  return(getObjectManager().Remove(tid))
  exit
end

on getObject(tid)
  return(getObjectManager().GET(tid))
  exit
end

on objectExists(tid)
  return(getObjectManager().exists(tid))
  exit
end

on printObjects()
  return(getObjectManager().print())
  exit
end

on registerObject(tid, tObject)
  return(getObjectManager().registerObject(tid, tObject))
  exit
end

on unregisterObject(tid)
  return(getObjectManager().unregisterObject(tid))
  exit
end

on createManager(tid)
  tClassList = []
  i = 2
  repeat while i <= the paramCount
    tParam = param(i)
    if listp(tParam) then
      repeat while tid <= undefined
        tClass = getAt(undefined, undefined)
        tClassList.add(tClass)
      end repeat
    else
      tClassList.add(tParam)
    end if
    i = 1 + i
  end repeat
  tObjMngr = getObjectManager()
  tObjInst = tObjMngr.create(tid, tClassList)
  tObjMngr.registerManager(tid)
  tObjMngr.setaProp(tid, tObjInst)
  return(tObjInst)
  exit
end

on removeManager(tid)
  return(getObjectManager().Remove(tid))
  exit
end

on getManager(tid)
  return(getObjectManager().getManager(tid))
  exit
end

on managerExists(tid)
  return(getObjectManager().managerExists(tid))
  exit
end

on printManagers()
  return(getObjectManager().print())
  exit
end

on registerManager(tid)
  return(getObjectManager().registerManager(tid))
  exit
end

on unregisterManager(tid)
  return(getObjectManager().unregisterManager(tid))
  exit
end

on receivePrepare(tid)
  return(getObjectManager().receivePrepare(tid))
  exit
end

on removePrepare(tid)
  return(getObjectManager().removePrepare(tid))
  exit
end

on receiveUpdate(tid)
  return(getObjectManager().receiveUpdate(tid))
  exit
end

on removeUpdate(tid)
  return(getObjectManager().removeUpdate(tid))
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