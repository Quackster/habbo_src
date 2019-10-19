property pObjectId, pGameObjectSyncValues, pGameObjectValues, pKilled, pGameObjectLocation, pGameObjectNextTarget, pGameObjectFinalTarget, pGameSystem

on setObjectId me, tID 
  pGameObjectSyncValues = [:]
  pGameObjectValues = [:]
  pObjectId = tID
end

on getObjectId me 
  return(pObjectId)
end

on setGameObjectProperty me, tProp, tValue 
  if listp(tProp) then
    tCount = tProp.count
    i = 1
    repeat while i <= tCount
      me.setGameObjectProperty(tProp.getPropAt(i), tProp.getAt(i))
      i = 1 + i
    end repeat
    return(1)
  end if
  if pGameObjectSyncValues.findPos(tProp) > 0 then
    return(pGameObjectSyncValues.setProp(tProp, tValue))
  else
    return(pGameObjectValues.setaProp(tProp, tValue))
  end if
end

on getGameObjectProperty me, tProp 
  if pGameObjectSyncValues.findPos(tProp) > 0 then
    return(pGameObjectSyncValues.getProp(tProp))
  else
    return(pGameObjectValues.getaProp(tProp))
  end if
end

on getActive me 
  return(not pKilled)
end

on setLocation me, tX, tY, tZ 
  if me.findPos(#x) then
    me.setaProp(#x, tX)
  end if
  if me.findPos(#y) then
    me.setaProp(#y, tY)
  end if
  if me.findPos(#z) then
    me.setaProp(#z, tZ)
  end if
  return(pGameObjectLocation.setLocation(tX, tY, tZ))
end

on setLocationAsTile me, tX, tY, tZ 
  pGameObjectLocation.setTileLoc(tX, tY, tZ)
  if me.findPos(#x) then
    me.setaProp(#x, pGameObjectLocation.x)
  end if
  if me.findPos(#y) then
    me.setaProp(#y, pGameObjectLocation.y)
  end if
  if me.findPos(#z) then
    me.setaProp(#z, pGameObjectLocation.z)
  end if
  return(1)
end

on setGameSystemReference me, tObject 
  pGameSystem = tObject
end

on setGameObjectSyncProperty me, tList, tdata 
  if listp(tList) then
    tCount = tList.count
    i = 1
    repeat while i <= tCount
      me.setaProp(tList.getPropAt(i), tList.getAt(i))
      i = 1 + i
    end repeat
    exit repeat
  end if
  me.setaProp(tList, tdata)
  return(1)
end

on executeGameObjectEvent me, tEvent, tdata 
  if tEvent = #set_target then
    me.setLoc(tdata.x, tdata.y, tdata.z)
  else
    if tEvent = #set_target_tile then
      me.setTileLoc(tdata.x, tdata.y, tdata.z)
    end if
  end if
  return(1)
end

on addChecksum me 
  tCheckSum = 0
  tCounter = 1
  tCount = pGameObjectSyncValues.count
  i = 1
  repeat while i <= tCount
    tValue = pGameObjectSyncValues.getAt(i)
    tIlk = ilk(tValue)
    if tIlk = #integer then
      tCheckSum = tCheckSum + (tValue * tCounter)
      tCounter = tCounter + 1
    end if
    if tIlk = #list then
      if tValue.count > 0 then
        repeat while tValue <= undefined
          tValueItem = getAt(undefined, undefined)
          tCheckSum = tCheckSum + (tValueItem * tCounter)
          tCounter = tCounter + 1
        end repeat
      end if
    end if
    i = 1 + i
  end repeat
  return(tCheckSum)
end

on define me 
  return(1)
end

on gameObjectRefreshLocation me 
  return(0)
end

on gameObjectNewMoveTarget me 
  return(0)
end

on calculateFrameMovement me 
  return(0)
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
    return(0)
  end if
  if not objectp(pGameObjectLocation) then
    return(0)
  end if
  return(pGameObjectLocation.getLocation() <> pGameObjectFinalTarget.getLocation())
end

on existsNextTarget me 
  if not objectp(pGameObjectNextTarget) then
    return(0)
  end if
  if not objectp(pGameObjectLocation) then
    return(0)
  end if
  return(pGameObjectLocation.getLocation() <> pGameObjectNextTarget.getLocation())
end

on dump me, tServerFormat 
  if tServerFormat = 1 then
    tObjectId = me.getObjectId()
    if tObjectId.length < 2 then
      tObjectId = "0" & tObjectId
    end if
    tDumpString = "O" & tObjectId & "-CS:" & me.addChecksum() && "Parms:"
    i = 1
    repeat while i <= pGameObjectSyncValues.count
      tValue = pGameObjectSyncValues.getAt(i)
      if ilk(tValue) = #integer then
        tDumpString = tDumpString & tValue
        if i < pGameObjectSyncValues.count then
          tDumpString = tDumpString & ","
        end if
      end if
      if ilk(tValue) = #list then
        if tValue.count > 0 then
          j = 1
          repeat while j <= tValue.count
            tListItem = tValue.getAt(j)
            tDumpString = tDumpString & tListItem
            if j <= tValue.count and i < pGameObjectSyncValues.count then
              tDumpString = tDumpString & ","
            end if
            j = 1 + j
          end repeat
        end if
      end if
      i = 1 + i
    end repeat
    tDumpString = "++" && "\"" & tDumpString & "\""
    return(tDumpString)
  else
    tDumpList = []
    i = 1
    repeat while i <= pGameObjectSyncValues.count
      tValue = pGameObjectSyncValues.getAt(i)
      if ilk(tValue) = #integer or ilk(tValue) = #list then
        tDumpList.add(pGameObjectSyncValues.getPropAt(i) & ":" && tValue)
      end if
      i = 1 + i
    end repeat
    return(tDumpList)
  end if
end

on getGameSystem me 
  return(pGameSystem)
end

on Remove me 
  me.pKilled = 1
  return(1)
end
