on constructObjectManager me 
  if objectp(gCore) then
    return(gCore)
  end if
  tClass = value(convertToPropList(field(0), "\r").getAt("object.manager.class")).getAt(1)
  gCore = script(tClass).new()
  gCore.construct()
  return(gCore)
end

on deconstructObjectManager  
  if voidp(gCore) then
    return(0)
  end if
  gCore.deconstruct()
  gCore = void()
  return(1)
end

on getObjectManager  
  if voidp(gCore) then
    return(constructObjectManager())
  end if
  return(gCore)
end

on createObject tID 
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
end

on removeObject tID 
  return(getObjectManager().Remove(tID))
end

on getObject tID 
  return(getObjectManager().GET(tID))
end

on objectExists tID 
  return(getObjectManager().exists(tID))
end

on printObjects  
  return(getObjectManager().print())
end

on registerObject tID, tObject 
  return(getObjectManager().registerObject(tID, tObject))
end

on unregisterObject tID 
  return(getObjectManager().unregisterObject(tID))
end

on createManager tID 
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
end

on removeManager tID 
  return(getObjectManager().Remove(tID))
end

on getManager tID 
  return(getObjectManager().getManager(tID))
end

on managerExists tID 
  return(getObjectManager().managerExists(tID))
end

on printManagers  
  return(getObjectManager().print())
end

on registerManager tID 
  return(getObjectManager().registerManager(tID))
end

on unregisterManager tID 
  return(getObjectManager().unregisterManager(tID))
end

on receivePrepare tID 
  return(getObjectManager().receivePrepare(tID))
end

on removePrepare tID 
  return(getObjectManager().removePrepare(tID))
end

on receiveUpdate tID 
  return(getObjectManager().receiveUpdate(tID))
end

on removeUpdate tID 
  return(getObjectManager().removeUpdate(tID))
end

on pauseUpdate  
  return(getObjectManager().pauseUpdate())
end

on unpauseUpdate  
  return(getObjectManager().resumeUpdate())
end
