on construct(me)
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
  pObjects = []
  pObjectTypeIndex = []
  pObjectGroupIndex = []
  pObjectIdIndex = []
  initIntVector()
  receiveUpdate(me.getID())
  return(1)
  exit
end

on deconstruct(me)
  removeUpdate(me.getID())
  repeat while pObjects.count > 0
    me.removeGameObject(pObjects.getAt(1).getObjectId())
  end repeat
  pCollision = void()
  pSquareRoot = void()
  pObjects = void()
  pObjectTypeIndex = void()
  pObjectGroupIndex = void()
  pObjectIdIndex = void()
  return(1)
  exit
end

on defineClient(me, tID)
  return(1)
  exit
end

on getCollision(me)
  return(pCollision)
  exit
end

on update(me)
  call(#update, pObjects)
  exit
end

on executeGameObjectEvent(me, tID, tEvent, tdata)
  if tID = #all then
    repeat while me <= tEvent
      tGameObject = getAt(tEvent, tID)
      call(#executeGameObjectEvent, tGameObject, tEvent, tdata)
    end repeat
    return(1)
  end if
  tGameObject = me.getGameObject(tID)
  if tGameObject = 0 then
    return(error(me, "Cannot execute game object event:" && tEvent && "on:" && tID, #executeGameObjectEvent))
  end if
  call(#executeGameObjectEvent, tGameObject, tEvent, tdata)
  return(1)
  exit
end

on calculateChecksum(me, tSeed)
  tCheckSum = tSeed
  repeat while me <= undefined
    tObject = getAt(undefined, tSeed)
    tCheckSum = tCheckSum + tObject.addChecksum()
  end repeat
  return(tCheckSum)
  exit
end

on dumpChecksumValues(me)
  tText = ""
  repeat while me <= undefined
    tObject = getAt(undefined, undefined)
    tText = tText & tObject.dump(1) & "\r"
  end repeat
  return(tText)
  exit
end

on createGameObject(me, tObjectId, ttype, tdata)
  if not listp(tdata) then
    tdata = []
  end if
  tObjectId = integer(tObjectId)
  tObjectStrId = string(tObjectId)
  if pObjectTypeIndex.getaProp(tObjectId) <> void() then
    return(error(me, "Game object by id already exists! Id:" && tObjectId, #createGameObject))
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
    return(error(me, "Unable to create game object!", #createGameObject))
  end if
  tObject.setID(tObjectStrId)
  tObject.setObjectId(tObjectStrId)
  tObject.setGameSystemReference(me.getFacade())
  pObjects.setaProp(tObjectId, tObject)
  pObjects.sort()
  pObjectTypeIndex.setaProp(tObjectId, ttype)
  pObjectIdIndex.add(tObjectId)
  if tdata.getAt(#z) = void() then
    tZ = 0
  else
    tZ = tdata.getAt(#z)
  end if
  tObject.pGameObjectLocation = me.getWorld().initLocation()
  tObject.pGameObjectNextTarget = me.getWorld().initLocation()
  tObject.pGameObjectFinalTarget = me.getWorld().initLocation()
  me.updateGameObject(tObjectStrId, tdata.duplicate())
  return(tObject)
  exit
end

on updateGameObject(me, tObjectId, tdata)
  tObjectId = string(tObjectId)
  tObject = me.getGameObject(tObjectId)
  if not listp(tdata) then
    return(0)
  end if
  if tObject = 0 then
    return(error(me, "Game object not found:" && tObjectId, #updateGameObject))
  end if
  tObject.setGameObjectSyncProperty(tdata)
  if tdata.getAt(#z) = void() then
    tdata.setAt(#z, 0)
  end if
  if tdata.findPos(#x) > 0 and tdata.findPos(#y) > 0 then
    tObject.setLocation(tdata.x, tdata.y, tdata.z)
  end if
  return(1)
  exit
end

on removeGameObject(me, tObjectId)
  tObjectId = integer(tObjectId)
  tObjectStrId = string(tObjectId)
  ttype = pObjectTypeIndex.getaProp(tObjectId)
  if ttype = void() then
    return(1)
  end if
  pObjectIdIndex.deleteOne(tObjectId)
  me.removeGameObjectFromAllGroups(tObjectId)
  tObject = me.getGameObject(tObjectStrId)
  if objectp(tObject) then
    tObject.deconstruct()
  end if
  pObjects.deleteProp(tObjectId)
  pObjectTypeIndex.deleteProp(tObjectId)
  return(1)
  exit
end

on executeSubturnMoves(me, tTurnNum, tSubTurnNum)
  tRemoveList = []
  tCount = pObjects.count
  i = 1
  repeat while i <= tCount
    tGameObject = pObjects.getAt(i)
    tGameObject.calculateFrameMovement()
    i = 1 + i
  end repeat
  i = 1
  repeat while i <= tCount
    tGameObject = pObjects.getAt(i)
    if tGameObject.getActive() = 0 then
      tRemoveList.add(tGameObject.getObjectId())
    end if
    i = 1 + i
  end repeat
  repeat while me <= tSubTurnNum
    tObjectId = getAt(tSubTurnNum, tTurnNum)
    me.removeGameObject(tObjectId)
  end repeat
  return(1)
  exit
end

on getGameObject(me, tObjectId)
  if voidp(pObjects) then
    return(0)
  end if
  return(pObjects.getaProp(integer(tObjectId)))
  exit
end

on getGameObjectIdsOfType(me, ttype)
  tResult = []
  tCount = pObjectTypeIndex.count
  i = 1
  repeat while i <= tCount
    if pObjectTypeIndex.getAt(i) = ttype or ttype = #all then
      tResult.append(string(pObjectTypeIndex.getPropAt(i)))
    end if
    i = 1 + i
  end repeat
  return(tResult)
  exit
end

on getGameObjectType(me, tObjectId)
  tObjectId = integer(tObjectId)
  return(pObjectTypeIndex.getaProp(tObjectId))
  exit
end

on getAllGameObjectIds(me)
  return(pObjectIdIndex.duplicate())
  exit
end

on setGameObjectInGroup(me, tGameObjectId, tGroupId)
  if tGroupId = void() then
    return(0)
  end if
  if pObjectGroupIndex.findPos(tGroupId) = 0 then
    pObjectGroupIndex.addProp(tGroupId, [])
  end if
  pObjectGroupIndex.getProp(tGroupId).add(tGameObjectId)
  return(1)
  exit
end

on removeGameObjectFromAllGroups(me, tGameObjectId)
  repeat while me <= undefined
    tGroup = getAt(undefined, tGameObjectId)
    tGroup.deleteOne(tGameObjectId)
  end repeat
  return(1)
  exit
end

on removeGameObjectFromGroup(me, tGameObjectId, tGroupId)
  if tGroupId = void() then
    return(0)
  end if
  if pObjectGroupIndex.findPos(tGroupId) = 0 then
    return(0)
  end if
  pObjectGroupIndex.getProp(tGroupId).deleteOne(tGameObjectId)
  return(1)
  exit
end

on getGameObjectGroup(me, tGroupId)
  if pObjectGroupIndex.findPos(tGroupId) = 0 then
    return([])
  end if
  return(pObjectGroupIndex.getaProp(tGroupId).duplicate())
  exit
end

on dumpGameObjectGroups(me)
  return(pObjectGroupIndex)
  exit
end

on dump(me)
  tText = ""
  repeat while me <= undefined
    tObject = getAt(undefined, undefined)
    tText = tText & tObject.dump() & "\r"
  end repeat
  return(tText)
  exit
end