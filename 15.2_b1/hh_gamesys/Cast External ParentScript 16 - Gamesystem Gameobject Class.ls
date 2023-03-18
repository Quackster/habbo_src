property pObjectId, pKilled, pGameSystem, pGameObjectSyncValues, pGameObjectLocation, pGameObjectNextTarget, pGameObjectFinalTarget

on setObjectId me, tid
  pGameObjectSyncValues = [:]
  pObjectId = tid
end

on getObjectId me
  return pObjectId
end

on setGameObjectProperty me, tProp, tValue
  if listp(tProp) then
    repeat with i = 1 to tProp.count
      me.setGameObjectProperty(tProp.getPropAt(i), tProp[i])
    end repeat
    return 1
  end if
  return me.setaProp(tProp, tValue)
end

on getGameObjectProperty me, tProp
  if pGameObjectSyncValues = VOID then
    pGameObjectSyncValues = [:]
  end if
  if pGameObjectSyncValues.findPos(tProp) > 0 then
    return pGameObjectSyncValues[tProp]
  else
    return me.getaProp(tProp)
  end if
end

on getActive me
  return not pKilled
end

on setLocation me, tX, tY, tZ
  return pGameObjectLocation.setLocation(tX, tY, tZ)
end

on setGameSystemReference me, tObject
  pGameSystem = tObject
end

on setGameObjectSyncProperty me, tList, tdata
  if pGameObjectSyncValues = VOID then
    pGameObjectSyncValues = [:]
  end if
  if listp(tList) then
    repeat with i = 1 to tList.count
      me.pGameObjectSyncValues.setaProp(tList.getPropAt(i), tList[i])
    end repeat
  else
    me.pGameObjectSyncValues.setaProp(tList, tdata)
  end if
  return 1
end

on executeGameObjectEvent me, tEvent, tdata
  case tEvent of
    #set_target:
      me.pGameObjectFinalTarget.setLoc(tdata.x, tdata.y, tdata.z)
    #set_target_tile:
      me.pGameObjectFinalTarget.setTileLoc(tdata.x, tdata.y, tdata.z)
    otherwise:
      put "* Standard UNDEFINED EVENT:" && tEvent && tdata
  end case
end

on addChecksum me
  tCheckSum = 0
  tCounter = 1
  if pGameObjectSyncValues = VOID then
    pGameObjectSyncValues = [:]
  end if
  repeat with i = 1 to pGameObjectSyncValues.count
    if ilk(pGameObjectSyncValues[i]) = #integer then
      tCheckSum = tCheckSum + (pGameObjectSyncValues[i] * tCounter)
      tCounter = tCounter + 1
    end if
  end repeat
  return tCheckSum
end

on define me
  return 1
end

on gameObjectRefreshLocation me
  return 0
end

on gameObjectNewMoveTarget me
  return 0
end

on calculateFrameMovement me
  return 0
end

on getLocation me
  return pGameObjectLocation
end

on getNextTarget me
  return pGameObjectNextTarget
end

on getFinalTarget me
  return pGameObjectFinalTarget
end

on resetTargets me
  pGameObjectNextTarget.setLoc(pGameObjectLocation.x, pGameObjectLocation.y, pGameObjectLocation.z)
  pGameObjectFinalTarget.setLoc(pGameObjectLocation.x, pGameObjectLocation.y, pGameObjectLocation.z)
end

on existsFinalTarget me
  if not objectp(pGameObjectFinalTarget) then
    return 0
  end if
  if not objectp(pGameObjectLocation) then
    return 0
  end if
  return pGameObjectLocation.getLocation() <> pGameObjectFinalTarget.getLocation()
end

on existsNextTarget me
  if not objectp(pGameObjectNextTarget) then
    return 0
  end if
  if not objectp(pGameObjectLocation) then
    return 0
  end if
  return pGameObjectLocation.getLocation() <> pGameObjectNextTarget.getLocation()
end

on dump me
  tDumpList = []
  if pGameObjectSyncValues = VOID then
    pGameObjectSyncValues = [:]
  end if
  repeat with i = 1 to pGameObjectSyncValues.count
    if ilk(pGameObjectSyncValues[i]) = #integer then
      tDumpList.add(pGameObjectSyncValues.getPropAt(i) & ":" && pGameObjectSyncValues[i])
    end if
  end repeat
  return tDumpList
end

on getGameSystem me
  return pGameSystem
end

on Remove me
  me.pKilled = 1
end
