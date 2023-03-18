property pFlagList, pFlagSetIndex, pCloseTimerList, pUpdateCounter, pUpdateInterval, pFlagCloseTimeout

on construct me
  pUpdateInterval = 3
  pFlagCloseTimeout = 4
  pFlagList = [:]
  pFlagSetIndex = [:]
  pCloseTimerList = [:]
  receiveUpdate(me.getID())
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  me.reset()
  return 1
end

on toggle me, tID
  tID = me.getMatchingFlagId(tID)
  if tID = VOID then
    return 0
  end if
  tObject = me.pFlagList.getaProp(tID)
  if not objectp(tObject) then
    return 0
  end if
  tObject.toggle(tID)
  me.alignZ()
  return 1
end

on open me, tID
  if pCloseTimerList.findPos(tID) then
    pCloseTimerList.deleteProp(tID)
  end if
  repeat with i = 1 to pFlagList.count
    tObject = pFlagList[i]
    if tID contains pFlagList.getPropAt(i) then
      pCloseTimerList.deleteProp(pFlagList.getPropAt(i))
      tObject.open()
      next repeat
    end if
    tObject.close()
  end repeat
  me.alignZ()
  return 1
end

on close me, tID
  if tID = VOID then
    repeat with i = 1 to pFlagList.count
      tObject = pFlagList[i]
      tID = pFlagList.getPropAt(i)
      pCloseTimerList.setaProp(tID, [tObject, pFlagCloseTimeout])
    end repeat
  else
    tID = me.getMatchingFlagId(tID)
    tObject = me.pFlagList.getaProp(tID)
    if objectp(tObject) then
      if pCloseTimerList.findPos(tID) = 0 then
        pCloseTimerList.setaProp(tID, [tObject, pFlagCloseTimeout])
      end if
    end if
  end if
  return 1
end

on reset me
  return removeAllFlagObjects()
end

on getFlagState me, tID
  tID = me.getMatchingFlagId(tID)
  tObject = pFlagList.getaProp(tID)
  if tObject = 0 then
    return 0
  end if
  return tObject.getState()
end

on alignZ me
  repeat with tObject in pFlagList
    tObject.alignZ()
  end repeat
  return 1
end

on update me
  pUpdateCounter = pUpdateCounter + 1
  if pUpdateCounter < pUpdateInterval then
    return 1
  end if
  pUpdateCounter = 0
  if pFlagList.count = 0 then
    return 0
  end if
  repeat with tObject in pFlagList
    tObject.update()
  end repeat
  tChanges = 0
  i = 1
  repeat while i <= pCloseTimerList.count
    tItem = pCloseTimerList[i]
    if tItem[2] = 0 then
      tObject = tItem[1]
      tObject.close()
      pCloseTimerList.deleteAt(i)
      tChanges = 1
      next repeat
    end if
    pCloseTimerList[i][2] = tItem[2] - 1
    i = i + 1
  end repeat
  if tChanges then
    me.alignZ()
  end if
  return 1
end

on setInfoFlag me, tSetID, tID, tWndID, tElemID, tFlagType, tColor, tItemInfo
  if me.exists(tID) then
    return 1
  end if
  tWndObj = getWindow(tWndID)
  if tWndObj = 0 then
    return error(me, "Reference window not found:" && tWndID, #setInfoFlag)
  end if
  tElem = tWndObj.getElement(tElemID)
  if tElem = 0 then
    return error(me, "Reference element not found in window:" && tWndID && tElemID, #setInfoFlag)
  end if
  tLocV = tWndObj.getProperty(#locY) + tElem.getProperty(#locY) - 7
  tlocz = tWndObj.getProperty(#locZ) + (tElem.getProperty(#locY) * 10)
  tObject = me.getFlagObject(tSetID, tID, tFlagType, 1)
  tObject.define(tID, tLocV, tlocz, tColor, tFlagType, tItemInfo)
  tObject.createWindows(tObject)
  return 1
end

on removeFlagSet me, tSetID
  if pFlagSetIndex.findPos(tSetID) = 0 then
    return 1
  end if
  tFlagSet = pFlagSetIndex.getaProp(tSetID)
  repeat with tObjectId in tFlagSet
    me.Remove(tObjectId)
  end repeat
  pFlagSetIndex.deleteProp(tSetID)
  return 1
end

on Remove me, tID
  tID = me.getMatchingFlagId(tID)
  if tID = VOID then
    return 0
  end if
  tObject = pFlagList.getaProp(tID)
  if tObject <> 0 then
    tObject.deconstruct()
  end if
  pFlagList.deleteProp(tID)
  pFlagSetIndex.deleteProp(tID)
  pCloseTimerList.deleteProp(tID)
  return 1
end

on exists me, tID
  tID = me.getMatchingFlagId(tID)
  if tID = VOID then
    return 0
  end if
  return pFlagList.findPos(tID) > 0
end

on getMatchingFlagId me, tWndID
  repeat with i = 1 to pFlagList.count
    tItemName = pFlagList.getPropAt(i)
    if (tWndID = tItemName) or (tWndID contains tItemName & "_") then
      return pFlagList.getPropAt(i)
    end if
  end repeat
  return 0
end

on getFlagObject me, tSetID, tID, tFlagType, tAddIfMissing
  if tSetID = VOID then
    return 0
  end if
  if tID = VOID then
    return 0
  end if
  tObject = pFlagList.getaProp(tID)
  if tObject <> 0 then
    return tObject
  end if
  if not tAddIfMissing then
    return 0
  end if
  if memberExists("IG UIFlag" && tFlagType) then
    tObject = createObject(getUniqueID(), ["IG UIFlag Class", "IG UIFlag" && tFlagType])
  else
    tObject = createObject(getUniqueID(), "IG UIFlag Class")
  end if
  if tObject = 0 then
    return 0
  end if
  pFlagList.setaProp(tID, tObject)
  tSetIndex = pFlagSetIndex.getaProp(tSetID)
  if not listp(tSetIndex) then
    tSetIndex = []
  end if
  tSetIndex.append(tID)
  pFlagSetIndex.setaProp(tSetID, tSetIndex)
  return tObject
end

on removeAllFlagObjects me
  repeat with tObject in pFlagList
    tObject.deconstruct()
  end repeat
  pFlagList = [:]
  pFlagSetIndex = [:]
  pCloseTimerList = [:]
  return 1
end

on getWindowWrapper me
  return getObject(#ig_window_wrapper)
end
