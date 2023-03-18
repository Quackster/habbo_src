property pSetIndex, pSetList, pSetOrderIndex, pProcedureList, pLocX, pLocY, pLocZ, pVisible, pUpdateCounter

on construct me
  pSetIndex = [:]
  pSetOrderIndex = []
  pSetList = [:]
  pProcedureList = [:]
  pVisible = 1
  receiveUpdate(me.getID())
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  me.removeAllParts()
  return 1
end

on update me
  pUpdateCounter = pUpdateCounter + 1
  if pUpdateCounter < 3 then
    return 1
  end if
  pUpdateCounter = 0
  repeat with tObject in pSetList
    tObject.update()
  end repeat
  return 1
end

on getProperty me, tKey
  case tKey of
    #visible:
      return pVisible
    #height:
      return me.getWrapperProperty(#height, #max)
    #width:
      tSetCount = me.pSetOrderIndex.count
      tWidth = 0
      repeat with i = 1 to tSetCount
        tWidth = tWidth + me.getWrapperProperty(#width, #max, i)
      end repeat
      return tWidth
  end case
  return 0
end

on moveTo me, tLocX, tLocY
  me.pLocX = tLocX
  me.pLocY = tLocY
  tOffsetX = 0
  tTopOffsetY = 0
  tColumnCount = me.pSetOrderIndex.count
  repeat with tSetColumn in me.pSetOrderIndex
    tOffsetY = tTopOffsetY
    tColumnMaxWidth = 0
    repeat with tSetID in tSetColumn
      tSetObject = pSetList.getaProp(tSetID)
      if tSetObject <> 0 then
        tSetObject.moveTo(tLocX + tOffsetX, tLocY + tOffsetY)
        tOffsetY = tOffsetY + tSetObject.getProperty(#height)
        if tSetObject.getProperty(#span_all_columns) then
          tTopOffsetY = tOffsetY
          next repeat
        end if
        tWidth = tSetObject.getProperty(#width)
        if tWidth > tColumnMaxWidth then
          tColumnMaxWidth = tWidth
        end if
      end if
    end repeat
    tOffsetX = tOffsetX + tColumnMaxWidth
  end repeat
  return 1
end

on moveZ me, tZ
  me.pLocZ = tZ
  repeat with tSetObject in me.pSetList
    if tSetObject <> 0 then
      tSetObject.moveZ(me.pLocZ)
    end if
  end repeat
  return 1
end

on addOneWindow me, tPartId, tLayout, tSetID, tProps
  if tSetID = VOID then
    return 0
  end if
  if pSetIndex.findPos(tPartId) > 0 then
    return me.replaceOneWindow(tPartId, tLayout, 0)
  end if
  tSetItem = me.getSet(tSetID)
  if tSetItem = 0 then
    tSetItem = me.createSet(tSetID)
  end if
  if tSetItem = 0 then
    return 0
  end if
  tOrderNum = tSetItem.getHighestIndex(tSetID) + 1
  createWindow(tPartId, tLayout)
  tWndObj = getWindow(tPartId)
  if tWndObj = 0 then
    return 0
  end if
  tWndObj.moveZ(me.pLocZ)
  tWndObj.lock()
  if not pVisible then
    tWndObj.hide()
  end if
  me.addCurrentProceduresOnWindow(tWndObj)
  if listp(tProps) then
    tScrollToPlace = tProps.findPos(#scrollFromLocX)
    if not tScrollToPlace and tProps.findPos(#locX) and tProps.findPos(#locY) then
      tWndObj.moveTo(tProps.getaProp(#locX), tProps.getaProp(#locY))
    end if
  end if
  if not tSetItem.addOneWindow(tPartId, tOrderNum, tProps) then
    return 0
  end if
  pSetIndex.setaProp(tPartId, tSetID)
  return 1
end

on initSet me, tSetID, tColumnNum, tOrderNum
  if me.existsSet(tSetID) then
    return me.clearSet(tSetID)
  else
    return me.createSet(tSetID, tColumnNum, tOrderNum)
  end if
end

on Activate me
  repeat with tSetColumn in me.pSetOrderIndex
    repeat with tSetID in tSetColumn
      tSetObject = pSetList.getaProp(tSetID)
      if tSetObject <> 0 then
        tSetObject.Activate()
      end if
    end repeat
  end repeat
end

on activateSet me, tSetID
  tSetObject = me.getSet(tSetID)
  if tSetObject = 0 then
    return 0
  end if
  return tSetObject.Activate()
end

on createSet me, tSetID, tColumnNum, tOrderNum
  if me.existsSet(tSetID) then
    return 1
  end if
  tSetObject = createObject(#temp, "Multicomponent Window Wrapper Set Class")
  if tSetObject = 0 then
    return 0
  end if
  tSetObject.define(tSetID)
  if tColumnNum = VOID then
    tColumnNum = 1
  end if
  if tOrderNum = VOID then
    tOrderNum = me.getNextFreeSetIndex(tColumnNum)
  end if
  pSetList.setaProp(tSetID, tSetObject)
  if pSetOrderIndex.count < tColumnNum then
    tCount = pSetOrderIndex.count
    repeat with i = tCount + 1 to tColumnNum
      pSetOrderIndex[i] = [:]
    end repeat
  end if
  pSetOrderIndex[tColumnNum].setaProp(tOrderNum, tSetID)
  me.pSetOrderIndex[tColumnNum].sort()
  me.moveTo(pLocX, pLocY)
  return tSetObject
end

on clearSet me, tSetID, tRender
  if tSetID = VOID then
    return 0
  end if
  tSetObject = me.getSet(tSetID)
  if tSetObject = VOID then
    return 1
  end if
  tSetObject.clearSet()
  i = 1
  repeat while i <= me.pSetIndex.count
    if me.pSetIndex[i] = tSetID then
      me.pSetIndex.deleteAt(i)
      next repeat
    end if
    i = i + 1
  end repeat
  me.moveTo(pLocX, pLocY)
  return 1
end

on removeSet me, tSetID, tRender
  if tSetID = VOID then
    return 0
  end if
  tSetObject = me.getSet(tSetID)
  if tSetObject = VOID then
    return 1
  end if
  tSetObject.deconstruct()
  me.pSetList.deleteProp(tSetID)
  i = 1
  repeat while i <= me.pSetIndex.count
    if me.pSetIndex[i] = tSetID then
      me.pSetIndex.deleteAt(i)
      next repeat
    end if
    i = i + 1
  end repeat
  tDone = 0
  repeat with i = 1 to pSetOrderIndex.count
    tSetColumn = pSetOrderIndex[i]
    repeat with j = 1 to tSetColumn.count
      if tSetColumn[j] = tSetID then
        tDone = 1
        tSetColumn.deleteAt(j)
      end if
      if tDone = 1 then
        exit repeat
      end if
    end repeat
    if tDone = 1 then
      exit repeat
    end if
  end repeat
  if tRender then
    me.render()
  end if
  return 1
end

on removeMatchingSets me, tWindowSetId, tRender
  if tWindowSetId = VOID then
    return 0
  end if
  tIdLength = tWindowSetId.length
  i = 1
  repeat while i <= me.pSetIndex.count
    tTestString = me.pSetIndex[i]
    if tTestString.char[1..tIdLength] = tWindowSetId then
      me.removeSet(tTestString, tRender)
      next repeat
    end if
    i = i + 1
  end repeat
  return 1
end

on existsSet me, tSetID
  if pSetList.findPos(tSetID) > 0 then
    return 1
  end if
  return 0
end

on getSetItems me, tSetID
  tSetObject = pSetList.getaProp(tSetID)
  if tSetObject = 0 then
    return 0
  end if
  return tSetObject.getItems()
end

on removeOneWindow me, tPartId, tRender
  tSetID = me.pSetIndex.getaProp(tPartId)
  if tSetID = 0 then
    return error(me, "Part not found in any set:" && tPartId, #removeOneWindow)
  end if
  tSetObject = pSetList.getaProp(tSetID)
  if tSetObject = 0 then
    return error(me, "Set object not found:" && tSetID, #removeOneWindow)
  end if
  if tSetObject.removeOneWindow(tPartId) then
    pSetIndex.deleteProp(tPartId)
    if tSetObject.getCount() = 0 then
      me.removeSet(tSetID)
    end if
  end if
  if tRender then
    me.render()
  end if
  return 1
end

on replaceOneWindow me, tPartId, tLayout, tRender
  if tPartId = VOID then
    return 0
  end if
  tSetID = me.pSetIndex.getaProp(tPartId)
  if tSetID = 0 then
    return error(me, "Part not found in set index:" && tPartId, #replaceOneWindow)
  end if
  tSetObject = pSetList.getaProp(tSetID)
  if tSetObject = 0 then
    return error(me, "Set object not found:" && tSetID, #replaceOneWindow)
  end if
  removeWindow(tPartId)
  createWindow(tPartId, tLayout)
  tWndObj = getWindow(tPartId)
  if tWndObj = 0 then
    return error(me, "New window not found:" && tPartId, #replaceOneWindow)
  end if
  tWndObj.moveZ(me.pLocZ)
  tWndObj.lock()
  me.addCurrentProceduresOnWindow(tWndObj)
  if not pVisible then
    tWndObj.hide()
  end if
  if tRender then
    me.render()
  end if
  return 1
end

on windowExists me, tPartId
  if tPartId = VOID then
    return 0
  end if
  return me.pSetIndex.findPos(tPartId) <> 0
end

on getElement me, tElemID, tWndID
  repeat with tSetObject in me.pSetList
    tElem = tSetObject.getElement(tElemID)
    if objectp(tElem) then
      return tElem
    end if
  end repeat
  return 0
end

on render me
  tOldLocation = me.getRealLocation()
  tMaxHeight = me.getWrapperProperty(#height, #total, 1)
  tColumnCount = me.pSetOrderIndex.count
  repeat with tSetColumn in me.pSetOrderIndex
    repeat with tSetID in tSetColumn
      tSetObject = pSetList.getaProp(tSetID)
      if tSetObject <> 0 then
        tSetObject.render(-1, tMaxHeight)
        if tSetObject.getProperty(#span_all_columns) then
          tMaxHeight = tMaxHeight - tSetObject.getProperty(#height)
        end if
      end if
    end repeat
  end repeat
  me.moveTo(tOldLocation[1], tOldLocation[2])
  return 1
end

on hide me
  pVisible = 0
  repeat with tSetObject in me.pSetList
    if objectp(tSetObject) then
      tSetObject.hide()
    end if
  end repeat
  return 1
end

on show me
  pVisible = 1
  repeat with tSetObject in me.pSetList
    if objectp(tSetObject) then
      tSetObject.show()
    end if
  end repeat
  return 1
end

on registerProcedure me, tMethod, tClientID, tEvent
  if tEvent = VOID then
    return 0
  end if
  if tClientID = VOID then
    return 0
  end if
  if tMethod = VOID then
    return 0
  end if
  tEventItem = pProcedureList.getaProp(tEvent)
  if tEventItem = VOID then
    tEventItem = [:]
  end if
  tEventItem.setaProp(tClientID, tMethod)
  pProcedureList.setaProp(tEvent, tEventItem)
  repeat with tSetObject in me.pSetList
    if tSetObject = 0 then
      return 0
    end if
    tPartList = tSetObject.getItems()
    repeat with tWindowID in tPartList
      tWindow = getWindow(tWindowID)
      if tWindow = 0 then
        return 0
      end if
      tWindow.registerProcedure(tMethod, tClientID, tEvent)
    end repeat
  end repeat
  return 1
end

on removeProcedure me, tEvent
  if tEvent = VOID then
    return 0
  end if
  tEventItem = pProcedureList.getaProp(tEvent)
  if tEventItem = VOID then
    return 1
  end if
  repeat with i = 1 to tEventItem.count
    tItemClientId = tEventItem.getPropAt(i)
    tWindow = getWindow(tItemClientId)
    if tWindow <> 0 then
      tWindow.removeProcedure(tEvent)
    end if
  end repeat
  pProcedureList.deleteProp(tEvent)
  return 1
end

on getRealLocation me
  if me.pSetOrderIndex.count = 0 then
    return point(pLocX, pLocY)
  end if
  tSetColumn = me.pSetOrderIndex[1]
  if tSetColumn.count = 0 then
    return point(pLocX, pLocY)
  end if
  tSetObject = me.getSet(tSetColumn[1])
  return tSetObject.getRealLocation()
end

on getSet me, tSetID
  return pSetList.getaProp(tSetID)
end

on getWrapperProperty me, tKey, tMode, tColumnNum, tResult
  tSetCount = me.pSetOrderIndex.count
  if tColumnNum > tSetCount then
    return 0
  end if
  if tColumnNum < 1 then
    repeat with i = 1 to tSetCount
      tValue = me.getWrapperProperty(tKey, #total, i)
      case tMode of
        #total:
          tResult = tResult + tValue
        #max:
          if tValue > tResult then
            tResult = tValue
          end if
      end case
    end repeat
  else
    tSetColumn = me.pSetOrderIndex[tColumnNum]
    repeat with j = 1 to tSetColumn.count
      tSetObject = me.getSet(tSetColumn[j])
      if tSetObject = 0 then
        return error(me, "Set object not found:" && tSetColumn[j], #getWrapperProperty)
      end if
      tResult = tSetObject.getAllWindowProperty(tKey, tMode, tResult)
    end repeat
  end if
  return tResult
end

on getNextFreeSetIndex me, tColumnNum
  if tColumnNum > me.pSetOrderIndex.count then
    return 1
  end if
  tSetColumn = me.pSetOrderIndex[tColumnNum]
  repeat with i = 1 to tSetColumn.count
    tNextIndex = tSetColumn.getPropAt(i) + 1
    if tSetColumn.findPos(tNextIndex) = 0 then
      return tNextIndex
    end if
  end repeat
  return 0
end

on addCurrentProceduresOnWindow me, tWndObj
  if tWndObj = 0 then
    return 0
  end if
  repeat with i = 1 to pProcedureList.count
    tEvent = pProcedureList.getPropAt(i)
    tProc = pProcedureList[i]
    repeat with j = 1 to tProc.count
      tClientID = tProc.getPropAt(j)
      tMethod = tProc[j]
      tWndObj.registerProcedure(tMethod, tClientID, tEvent)
    end repeat
  end repeat
  return 1
end

on removeAllParts me
  repeat with i = 1 to me.pSetOrderIndex.count
    tSetColumn = me.pSetOrderIndex[i]
    repeat while tSetColumn.count > 0
      tSetID = tSetColumn[1]
      me.removeSet(tSetID)
    end repeat
  end repeat
  pItemList = [:]
  pSetIndex = [:]
  pSetList = [:]
  pSetOrderIndex = []
  return 1
end
