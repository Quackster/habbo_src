property pObjectId, pGameObjectSyncValues, pKilled, pGameObjectLocation, pGameObjectNextTarget, pGameObjectFinalTarget, pGameSystem

on setObjectId me, tid 
  pGameObjectSyncValues = [:]
  pObjectId = tid
end

on getObjectId me 
  return(pObjectId)
end

on setGameObjectProperty me, tProp, tValue 
  if listp(tProp) then
    i = 1
    repeat while i <= tProp.count
      me.setGameObjectProperty(tProp.getPropAt(i), tProp.getAt(i))
      i = (1 + i)
    end repeat
    return TRUE
  end if
  return(me.setaProp(tProp, tValue))
end

on getGameObjectProperty me, tProp 
  if (pGameObjectSyncValues = void()) then
    pGameObjectSyncValues = [:]
  end if
  if pGameObjectSyncValues.findPos(tProp) > 0 then
    return(pGameObjectSyncValues.getAt(tProp))
  else
    return(me.getaProp(tProp))
  end if
end

on getActive me 
  return(not pKilled)
end

on setLocation me, tX, tY, tZ 
  return(pGameObjectLocation.setLocation(tX, tY, tZ))
end

on setGameSystemReference me, tObject 
  pGameSystem = tObject
end

on setGameObjectSyncProperty me, tList, tdata 
  if (pGameObjectSyncValues = void()) then
    pGameObjectSyncValues = [:]
  end if
  if listp(tList) then
    i = 1
    repeat while i <= tList.count
      me.pGameObjectSyncValues.setaProp(tList.getPropAt(i), tList.getAt(i))
      i = (1 + i)
    end repeat
    exit repeat
  end if
  me.pGameObjectSyncValues.setaProp(tList, tdata)
  return TRUE
end

on executeGameObjectEvent me, tEvent, tdata 
  if (tEvent = #set_target) then
    me.pGameObjectFinalTarget.setLoc(tdata.x, tdata.y, tdata.z)
  else
    if (tEvent = #set_target_tile) then
      me.pGameObjectFinalTarget.setTileLoc(tdata.x, tdata.y, tdata.z)
    else
      put("* Standard UNDEFINED EVENT:" && tEvent && tdata)
    end if
  end if
end

on addChecksum me 
  tCheckSum = 0
  tCounter = 1
  if (pGameObjectSyncValues = void()) then
    pGameObjectSyncValues = [:]
  end if
  i = 1
  repeat while i <= pGameObjectSyncValues.count
    if (ilk(pGameObjectSyncValues.getAt(i)) = #integer) then
      tCheckSum = (tCheckSum + (pGameObjectSyncValues.getAt(i) * tCounter))
      tCounter = (tCounter + 1)
    end if
    i = (1 + i)
  end repeat
  return(tCheckSum)
end

on define me 
  return TRUE
end

on gameObjectRefreshLocation me 
  return FALSE
end

on gameObjectNewMoveTarget me 
  return FALSE
end

on calculateFrameMovement me 
  return FALSE
end

on getLocation me 
  return(pGameObjectLocation)
end

on getNextTarget me 
  return(pGameObjectNextTarget)
end

on getFinalTarget me 
  return(pGameObjectFinalTarget)
end

on resetTargets me 
  pGameObjectNextTarget.setLoc(pGameObjectLocation.x, pGameObjectLocation.y, pGameObjectLocation.z)
  pGameObjectFinalTarget.setLoc(pGameObjectLocation.x, pGameObjectLocation.y, pGameObjectLocation.z)
end

on existsFinalTarget me 
  if not objectp(pGameObjectFinalTarget) then
    return FALSE
  end if
  if not objectp(pGameObjectLocation) then
    return FALSE
  end if
  return(pGameObjectLocation.getLocation() <> pGameObjectFinalTarget.getLocation())
end

on existsNextTarget me 
  if not objectp(pGameObjectNextTarget) then
    return FALSE
  end if
  if not objectp(pGameObjectLocation) then
    return FALSE
  end if
  return(pGameObjectLocation.getLocation() <> pGameObjectNextTarget.getLocation())
end

on dump me 
  tDumpList = []
  if (pGameObjectSyncValues = void()) then
    pGameObjectSyncValues = [:]
  end if
  i = 1
  repeat while i <= pGameObjectSyncValues.count
    if (ilk(pGameObjectSyncValues.getAt(i)) = #integer) then
      tDumpList.add(pGameObjectSyncValues.getPropAt(i) & ":" && pGameObjectSyncValues.getAt(i))
    end if
    i = (1 + i)
  end repeat
  return(tDumpList)
end

on getGameSystem me 
  return(pGameSystem)
end

on Remove me 
  me.pKilled = 1
end
