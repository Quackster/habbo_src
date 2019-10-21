property pSquareRoot, pCollision, pObjects, pObjectTypeIndex

on construct me 
  pGeometry = createObject(#temp, getClassVariable("gamesystem.geometry.class"))
  if not objectp(pGeometry) then
    return(error(me, "Cannot create pGeometry.", #construct))
  end if
  pSquareRoot = createObject(#temp, getClassVariable("gamesystem.squareroot.class"))
  if not objectp(pSquareRoot) then
    return(error(me, "Cannot create pSquareRoot.", #construct))
  end if
  pCollision = createObject(#temp, getClassVariable("gamesystem.collision.class"))
  if not objectp(pCollision) then
    return(error(me, "Cannot create pCollision.", #construct))
  end if
  pCollision.setaProp(#pSquareRoot, pSquareRoot)
  pObjects = [:]
  pObjectTypeIndex = [:]
  initIntVector()
  receiveUpdate(me.getID())
  return TRUE
end

on deconstruct me 
  removeUpdate(me.getID())
  repeat while pObjects.count > 0
    me.removeGameObject(pObjects.getAt(1).getObjectId())
  end repeat
  pCollision = void()
  pSquareRoot = void()
  pObjects = void()
  pObjectTypeIndex = void()
  return TRUE
end

on defineClient me, tID 
  return TRUE
end

on getCollision me 
  return(pCollision)
end

on update me 
  call(#update, pObjects)
end

on executeGameObjectEvent me, tID, tEvent, tdata 
  if (tID = #all) then
    repeat while pObjects <= tEvent
      tGameObject = getAt(tEvent, tID)
      call(#executeGameObjectEvent, tGameObject, tEvent, tdata)
    end repeat
    return TRUE
  end if
  tGameObject = me.getGameObject(tID)
  if (tGameObject = 0) then
    return(error(me, "Cannot execute game object event:" && tEvent && "on:" && tID, #executeGameObjectEvent))
  end if
  call(#executeGameObjectEvent, tGameObject, tEvent, tdata)
  return TRUE
end

on calculateChecksum me, tSeed 
  tCheckSum = tSeed
  repeat while pObjects <= undefined
    tObject = getAt(undefined, tSeed)
    tCheckSum = (tCheckSum + tObject.addChecksum())
  end repeat
  return(tCheckSum)
end

on dumpChecksumValues me 
  tText = ""
  repeat while pObjects <= undefined
    tObject = getAt(undefined, undefined)
    tText = tText & tObject.dump() & "\r"
  end repeat
  return(tText)
end

on createGameObject me, tObjectID, ttype, tdata 
  if not listp(tdata) then
    tdata = [:]
  end if
  tObjectID = integer(tObjectID)
  tObjectStrId = string(tObjectID)
  if pObjectTypeIndex.getaProp(tObjectID) <> void() then
    return(error(me, "Game object by id already exists! Id:" && tObjectID, #createGameObject))
  end if
  tClass = getClassVariable(me.getSystemId() & "." & ttype & ".class")
  tBaseClass = getClassVariable("gamesystem.gameobject.class")
  if (tClass = 0) then
    tClass = tBaseClass
  else
    if listp(tClass) then
      tClass.addAt(1, tBaseClass)
    else
      tClass = [tBaseClass, tClass]
    end if
  end if
  tObject = createObject(#temp, tClass)
  if (tObject = 0) then
    return(error(me, "Unable to create game object!", #createGameObject))
  end if
  tObject.setID(tObjectStrId)
  tObject.setObjectId(tObjectStrId)
  tObject.setGameSystemReference(me.getFacade())
  pObjects.setaProp(tObjectID, tObject)
  pObjects.sort()
  pObjectTypeIndex.setaProp(tObjectID, ttype)
  if (tdata.getAt(#z) = void()) then
    tZ = 0
  else
    tZ = tdata.getAt(#z)
  end if
  tObject.pGameObjectLocation = me.getWorld().initLocation()
  tObject.pGameObjectNextTarget = me.getWorld().initLocation()
  tObject.pGameObjectFinalTarget = me.getWorld().initLocation()
  me.updateGameObject(tObjectStrId, tdata.duplicate())
  return(tObject)
end

on updateGameObject me, tObjectID, tdata 
  tObjectID = string(tObjectID)
  tObject = me.getGameObject(tObjectID)
  if not listp(tdata) then
    return FALSE
  end if
  if (tObject = 0) then
    return(error(me, "Game object not found:" && tObjectID, #updateGameObject))
  end if
  tObject.setGameObjectSyncProperty(tdata)
  if (tdata.getAt(#z) = void()) then
    tdata.setAt(#z, 0)
  end if
  if tdata.findPos(#x) > 0 and tdata.findPos(#y) > 0 then
    tObject.setLocation(tdata.x, tdata.y, tdata.z)
  end if
  return TRUE
end

on removeGameObject me, tObjectID 
  tObjectID = integer(tObjectID)
  tObjectStrId = string(tObjectID)
  ttype = pObjectTypeIndex.getaProp(tObjectID)
  if (ttype = void()) then
    return TRUE
  end if
  tObject = me.getGameObject(tObjectStrId)
  if objectp(tObject) then
    tObject.deconstruct()
  end if
  pObjects.deleteProp(tObjectID)
  pObjectTypeIndex.deleteProp(tObjectID)
  return TRUE
end

on executeSubturnMoves me 
  tRemoveList = []
  i = 1
  repeat while i <= pObjects.count
    tGameObject = pObjects.getAt(i)
    tGameObject.calculateFrameMovement()
    if (tGameObject.getActive() = 0) then
      tRemoveList.add(tGameObject.getObjectId())
    end if
    i = (1 + i)
  end repeat
  repeat while tRemoveList <= undefined
    tObjectID = getAt(undefined, undefined)
    me.removeGameObject(tObjectID)
  end repeat
  return TRUE
end

on getGameObject me, tObjectID 
  if (pObjects = void()) then
    return FALSE
  end if
  return(pObjects.getaProp(integer(tObjectID)))
end

on getGameObjectIdsOfType me, ttype 
  tResult = []
  i = 1
  repeat while i <= pObjectTypeIndex.count
    if (pObjectTypeIndex.getAt(i) = ttype) or (ttype = #all) then
      tResult.append(string(pObjectTypeIndex.getPropAt(i)))
    end if
    i = (1 + i)
  end repeat
  return(tResult)
end

on getGameObjectType me, tObjectID 
  tObjectID = integer(tObjectID)
  return(pObjectTypeIndex.getaProp(tObjectID))
end

on dump me 
  tText = ""
  repeat while pObjects <= undefined
    tObject = getAt(undefined, undefined)
    tText = tText & tObject.dump() & "\r"
  end repeat
  return(tText)
end
