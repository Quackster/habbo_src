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
    return FALSE
  end if
  gCore.deconstruct()
  gCore = void()
  return TRUE
end

on getObjectManager  
  if voidp(gCore) then
    return(constructObjectManager())
  end if
  return(gCore)
end

on createObject tid 
  tClassList = []
  i = 2
  repeat while i <= the paramCount
    tParam = param(i)
    if listp(tParam) then
      repeat while tParam <= 1
        tClass = getAt(1, count(tParam))
        tClassList.add(tClass)
      end repeat
    else
      tClassList.add(tParam)
    end if
    i = (1 + i)
  end repeat
  return(getObjectManager().create(tid, tClassList))
end

on removeObject tid 
  return(getObjectManager().remove(tid))
end

on getObject tid 
  return(getObjectManager().get(tid))
end

on objectExists tid 
  return(getObjectManager().exists(tid))
end

on printObjects  
  return(getObjectManager().print())
end

on registerObject tid, tObject 
  return(getObjectManager().registerObject(tid, tObject))
end

on unregisterObject tid 
  return(getObjectManager().unregisterObject(tid))
end

on createManager tid 
  tClassList = []
  i = 2
  repeat while i <= the paramCount
    tParam = param(i)
    if listp(tParam) then
      repeat while tParam <= 1
        tClass = getAt(1, count(tParam))
        tClassList.add(tClass)
      end repeat
    else
      tClassList.add(tParam)
    end if
    i = (1 + i)
  end repeat
  tObjMngr = getObjectManager()
  tObjInst = tObjMngr.create(tid, tClassList)
  tObjMngr.registerManager(tid)
  tObjMngr.setaProp(tid, tObjInst)
  return(tObjInst)
end

on removeManager tid 
  return(getObjectManager().remove(tid))
end

on getManager tid 
  return(getObjectManager().getManager(tid))
end

on managerExists tid 
  return(getObjectManager().managerExists(tid))
end

on printManagers  
  return(getObjectManager().print())
end

on registerManager tid 
  return(getObjectManager().registerManager(tid))
end

on unregisterManager tid 
  return(getObjectManager().unregisterManager(tid))
end

on receivePrepare tid 
  return(getObjectManager().receivePrepare(tid))
end

on removePrepare tid 
  return(getObjectManager().removePrepare(tid))
end

on receiveUpdate tid 
  return(getObjectManager().receiveUpdate(tid))
end

on removeUpdate tid 
  return(getObjectManager().removeUpdate(tid))
end

on pauseUpdate  
  return(getObjectManager().pauseUpdate())
end

on unpauseUpdate  
  return(getObjectManager().resumeUpdate())
end
