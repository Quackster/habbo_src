property pObjects, pObjectTypeIndex, pCollision, pSquareRoot

on construct me
  pGeometry = createObject(#temp, getClassVariable("gamesystem.geometry.class"))
  if not objectp(pGeometry) then
    return error(me, "Cannot create pGeometry.", #construct)
  end if
  pSquareRoot = createObject(#temp, getClassVariable("gamesystem.squareroot.class"))
  if not objectp(pSquareRoot) then
    return error(me, "Cannot create pSquareRoot.", #construct)
  end if
  pCollision = createObject(#temp, getClassVariable("gamesystem.collision.class"))
  if not objectp(pCollision) then
    return error(me, "Cannot create pCollision.", #construct)
  end if
  pCollision.setaProp(#pSquareRoot, pSquareRoot)
  pObjects = [:]
  pObjectTypeIndex = [:]
  initIntVector()
  receiveUpdate(me.getID())
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  repeat while pObjects.count > 0
    me.removeGameObject(pObjects[1].getObjectId())
  end repeat
  pCollision = VOID
  pSquareRoot = VOID
  pObjects = VOID
  pObjectTypeIndex = VOID
  return 1
end

on defineClient me, tid
  return 1
end

on getCollision me
  return pCollision
end

on update me
  call(#update, pObjects)
end

on executeGameObjectEvent me, tid, tEvent, tdata
  if tid = #all then
    repeat with tGameObject in pObjects
      call(#executeGameObjectEvent, tGameObject, tEvent, tdata)
    end repeat
    return 1
  end if
  tGameObject = me.getGameObject(tid)
  if tGameObject = 0 then
    return error(me, "Cannot execute game object event:" && tEvent && "on:" && tid, #executeGameObjectEvent)
  end if
  call(#executeGameObjectEvent, tGameObject, tEvent, tdata)
  return 1
end

on calculateChecksum me, tSeed
  tCheckSum = tSeed
  repeat with tObject in pObjects
    tCheckSum = tCheckSum + tObject.addChecksum()
  end repeat
  return tCheckSum
end

on dumpChecksumValues me
  tText = EMPTY
  repeat with tObject in pObjects
    tText = tText & tObject.dump() & RETURN
  end repeat
  return tText
end

on createGameObject me, tObjectID, ttype, tdata
  if not listp(tdata) then
    tdata = [:]
  end if
  tObjectID = integer(tObjectID)
  tObjectStrId = string(tObjectID)
  if pObjectTypeIndex.getaProp(tObjectID) <> VOID then
    return error(me, "Game object by id already exists! Id:" && tObjectID, #createGameObject)
  end if
  tClass = getClassVariable(me.getSystemId() & "." & ttype & ".class")
  tBaseClass = getClassVariable("gamesystem.gameobject.class")
  if tClass = 0 then
    tClass = tBaseClass
  else
    if listp(tClass) then
      tClass.addAt(1, tBaseClass)
    else
      tClass = [tBaseClass, tClass]
    end if
  end if
  tObject = createObject(#temp, tClass)
  if tObject = 0 then
    return error(me, "Unable to create game object!", #createGameObject)
  end if
  tObject.setID(tObjectStrId)
  tObject.setObjectId(tObjectStrId)
  tObject.setGameSystemReference(me.getFacade())
  pObjects.setaProp(tObjectID, tObject)
  pObjects.sort()
  pObjectTypeIndex.setaProp(tObjectID, ttype)
  if tdata[#z] = VOID then
    tZ = 0
  else
    tZ = tdata[#z]
  end if
  tObject.pGameObjectLocation = me.getWorld().initLocation()
  tObject.pGameObjectNextTarget = me.getWorld().initLocation()
  tObject.pGameObjectFinalTarget = me.getWorld().initLocation()
  me.updateGameObject(tObjectStrId, tdata.duplicate())
  return tObject
end

on updateGameObject me, tObjectID, tdata
  tObjectID = string(tObjectID)
  tObject = me.getGameObject(tObjectID)
  if not listp(tdata) then
    return 0
  end if
  if tObject = 0 then
    return error(me, "Game object not found:" && tObjectID, #updateGameObject)
  end if
  tObject.setGameObjectSyncProperty(tdata)
  if tdata[#z] = VOID then
    tdata[#z] = 0
  end if
  if (tdata.findPos(#x) > 0) and (tdata.findPos(#y) > 0) then
    tObject.setLocation(tdata.x, tdata.y, tdata.z)
  end if
  return 1
end

on removeGameObject me, tObjectID
  tObjectID = integer(tObjectID)
  tObjectStrId = string(tObjectID)
  ttype = pObjectTypeIndex.getaProp(tObjectID)
  if ttype = VOID then
    return 1
  end if
  tObject = me.getGameObject(tObjectStrId)
  if objectp(tObject) then
    tObject.deconstruct()
  end if
  pObjects.deleteProp(tObjectID)
  pObjectTypeIndex.deleteProp(tObjectID)
  return 1
end

on executeSubturnMoves me
  tRemoveList = []
  repeat with i = 1 to pObjects.count
    tGameObject = pObjects[i]
    tGameObject.calculateFrameMovement()
    if tGameObject.getActive() = 0 then
      tRemoveList.add(tGameObject.getObjectId())
    end if
  end repeat
  repeat with tObjectID in tRemoveList
    me.removeGameObject(tObjectID)
  end repeat
  return 1
end

on getGameObject me, tObjectID
  if pObjects = VOID then
    return 0
  end if
  return pObjects.getaProp(integer(tObjectID))
end

on getGameObjectIdsOfType me, ttype
  tResult = []
  repeat with i = 1 to pObjectTypeIndex.count
    if (pObjectTypeIndex[i] = ttype) or (ttype = #all) then
      tResult.append(string(pObjectTypeIndex.getPropAt(i)))
    end if
  end repeat
  return tResult
end

on getGameObjectType me, tObjectID
  tObjectID = integer(tObjectID)
  return pObjectTypeIndex.getaProp(tObjectID)
end

on dump me
  tText = EMPTY
  repeat with tObject in pObjects
    tText = tText & tObject.dump() & RETURN
  end repeat
  return tText
end
