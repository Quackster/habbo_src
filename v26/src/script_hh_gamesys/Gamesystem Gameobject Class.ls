on setObjectId(me, tID)
  pGameObjectSyncValues = []
  pObjectId = tID
  exit
end

on getObjectId(me)
  return(pObjectId)
  exit
end

on setGameObjectProperty(me, tProp, tValue)
  if listp(tProp) then
    i = 1
    repeat while i <= tProp.count
      me.setGameObjectProperty(tProp.getPropAt(i), tProp.getAt(i))
      i = 1 + i
    end repeat
    return(1)
  end if
  return(me.setaProp(tProp, tValue))
  exit
end

on getGameObjectProperty(me, tProp)
  if pGameObjectSyncValues = void() then
    pGameObjectSyncValues = []
  end if
  if pGameObjectSyncValues.findPos(tProp) > 0 then
    return(pGameObjectSyncValues.getAt(tProp))
  else
    return(me.getaProp(tProp))
  end if
  exit
end

on getActive(me)
  return(not pKilled)
  exit
end

on setLocation(me, tX, tY, tZ)
  return(pGameObjectLocation.setLocation(tX, tY, tZ))
  exit
end

on setGameSystemReference(me, tObject)
  pGameSystem = tObject
  exit
end

on setGameObjectSyncProperty(me, tList, tdata)
  if pGameObjectSyncValues = void() then
    pGameObjectSyncValues = []
  end if
  if listp(tList) then
    i = 1
    repeat while i <= tList.count
      me.setaProp(tList.getPropAt(i), tList.getAt(i))
      i = 1 + i
    end repeat
    exit repeat
  end if
  me.setaProp(tList, tdata)
  return(1)
  exit
end

on executeGameObjectEvent(me, tEvent, tdata)
  if me = #set_target then
    me.setLoc(tdata.x, tdata.y, tdata.z)
  else
    if me = #set_target_tile then
      me.setTileLoc(tdata.x, tdata.y, tdata.z)
    else
      put("* Standard UNDEFINED EVENT:" && tEvent && tdata)
    end if
  end if
  exit
end

on addChecksum(me)
  tCheckSum = 0
  tCounter = 1
  if pGameObjectSyncValues = void() then
    pGameObjectSyncValues = []
  end if
  i = 1
  repeat while i <= pGameObjectSyncValues.count
    if ilk(pGameObjectSyncValues.getAt(i)) = #integer then
      tCheckSum = tCheckSum + pGameObjectSyncValues.getAt(i) * tCounter
      tCounter = tCounter + 1
    end if
    i = 1 + i
  end repeat
  return(tCheckSum)
  exit
end

on define(me)
  return(1)
  exit
end

on gameObjectRefreshLocation(me)
  return(0)
  exit
end

on gameObjectNewMoveTarget(me)
  return(0)
  exit
end

on calculateFrameMovement(me)
  return(0)
  exit
end

on getLocation(me)
  return(pGameObjectLocation)
  exit
end

on getNextTarget(me)
  return(pGameObjectNextTarget)
  exit
end

on getFinalTarget(me)
  return(pGameObjectFinalTarget)
  exit
end

on resetTargets(me)
  pGameObjectNextTarget.setLoc(pGameObjectLocation.x, pGameObjectLocation.y, pGameObjectLocation.z)
  pGameObjectFinalTarget.setLoc(pGameObjectLocation.x, pGameObjectLocation.y, pGameObjectLocation.z)
  exit
end

on existsFinalTarget(me)
  if not objectp(pGameObjectFinalTarget) then
    return(0)
  end if
  if not objectp(pGameObjectLocation) then
    return(0)
  end if
  return(pGameObjectLocation.getLocation() <> pGameObjectFinalTarget.getLocation())
  exit
end

on existsNextTarget(me)
  if not objectp(pGameObjectNextTarget) then
    return(0)
  end if
  if not objectp(pGameObjectLocation) then
    return(0)
  end if
  return(pGameObjectLocation.getLocation() <> pGameObjectNextTarget.getLocation())
  exit
end

on dump(me)
  tDumpList = []
  if pGameObjectSyncValues = void() then
    pGameObjectSyncValues = []
  end if
  i = 1
  repeat while i <= pGameObjectSyncValues.count
    if ilk(pGameObjectSyncValues.getAt(i)) = #integer then
      tDumpList.add(pGameObjectSyncValues.getPropAt(i) & ":" && pGameObjectSyncValues.getAt(i))
    end if
    i = 1 + i
  end repeat
  return(tDumpList)
  exit
end

on getGameSystem(me)
  return(pGameSystem)
  exit
end

on Remove(me)
  me.pKilled = 1
  exit
end