property pObjectId, pKilled, pGameSystem, pGameObjectSyncValues, pGameObjectValues, pGameObjectLocation, pGameObjectNextTarget, pGameObjectFinalTarget

on setObjectId me, tID
  pGameObjectSyncValues = [:]
  pGameObjectValues = [:]
  pObjectId = tID
end

on getObjectId me
  return pObjectId
end

on setGameObjectProperty me, tProp, tValue
  if listp(tProp) then
    tCount = tProp.count
    repeat with i = 1 to tCount
      me.setGameObjectProperty(tProp.getPropAt(i), tProp[i])
    end repeat
    return 1
  end if
  if pGameObjectSyncValues.findPos(tProp) > 0 then
    return pGameObjectSyncValues.setProp(tProp, tValue)
  else
    return pGameObjectValues.setaProp(tProp, tValue)
  end if
end

on getGameObjectProperty me, tProp
  if pGameObjectSyncValues.findPos(tProp) > 0 then
    return pGameObjectSyncValues.getProp(tProp)
  else
    return pGameObjectValues.getaProp(tProp)
  end if
end

on getActive me
  return not pKilled
end

on setLocation me, tX, tY, tZ
  if me.pGameObjectSyncValues.findPos(#x) then
    me.pGameObjectSyncValues.setaProp(#x, tX)
  end if
  if me.pGameObjectSyncValues.findPos(#y) then
    me.pGameObjectSyncValues.setaProp(#y, tY)
  end if
  if me.pGameObjectSyncValues.findPos(#z) then
    me.pGameObjectSyncValues.setaProp(#z, tZ)
  end if
  return pGameObjectLocation.setLocation(tX, tY, tZ)
end

on setLocationAsTile me, tX, tY, tZ
  pGameObjectLocation.setTileLoc(tX, tY, tZ)
  if me.pGameObjectSyncValues.findPos(#x) then
    me.pGameObjectSyncValues.setaProp(#x, pGameObjectLocation.x)
  end if
  if me.pGameObjectSyncValues.findPos(#y) then
    me.pGameObjectSyncValues.setaProp(#y, pGameObjectLocation.y)
  end if
  if me.pGameObjectSyncValues.findPos(#z) then
    me.pGameObjectSyncValues.setaProp(#z, pGameObjectLocation.z)
  end if
  return 1
end

on setGameSystemReference me, tObject
  pGameSystem = tObject
end

on setGameObjectSyncProperty me, tList, tdata
  if listp(tList) then
    tCount = tList.count
    repeat with i = 1 to tCount
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
  end case
  return 1
end

on addChecksum me
  tCheckSum = 0
  tCounter = 1
  tCount = pGameObjectSyncValues.count
  repeat with i = 1 to tCount
    tValue = pGameObjectSyncValues[i]
    tIlk = ilk(tValue)
    if tIlk = #integer then
      tCheckSum = tCheckSum + (tValue * tCounter)
      tCounter = tCounter + 1
    end if
    if tIlk = #list then
      if tValue.count > 0 then
        repeat with tValueItem in tValue
          tCheckSum = tCheckSum + (tValueItem * tCounter)
          tCounter = tCounter + 1
        end repeat
      end if
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

on dump me, tServerFormat
  if tServerFormat = 1 then
    tObjectId = me.getObjectId()
    if tObjectId.length < 2 then
      tObjectId = "0" & tObjectId
    end if
    tDumpString = "O" & tObjectId & "-CS:" & me.addChecksum() && "Parms:"
    repeat with i = 1 to pGameObjectSyncValues.count
      tValue = pGameObjectSyncValues[i]
      if ilk(tValue) = #integer then
        tDumpString = tDumpString & tValue
        if i < pGameObjectSyncValues.count then
          tDumpString = tDumpString & ","
        end if
      end if
      if ilk(tValue) = #list then
        if tValue.count > 0 then
          repeat with j = 1 to tValue.count
            tListItem = tValue[j]
            tDumpString = tDumpString & tListItem
            if (j <= tValue.count) and (i < pGameObjectSyncValues.count) then
              tDumpString = tDumpString & ","
            end if
          end repeat
        end if
      end if
    end repeat
    tDumpString = "++" && QUOTE & tDumpString & QUOTE
    return tDumpString
  else
    tDumpList = []
    repeat with i = 1 to pGameObjectSyncValues.count
      tValue = pGameObjectSyncValues[i]
      if (ilk(tValue) = #integer) or (ilk(tValue) = #list) then
        tDumpList.add(pGameObjectSyncValues.getPropAt(i) & ":" && tValue)
      end if
    end repeat
    return tDumpList
  end if
end

on getGameSystem me
  return pGameSystem
end

on Remove me
  me.pKilled = 1
  return 1
end
