property pListIndex, pListData, pListItemContainerClass

on construct me
  me.pListIndex = []
  me.pListData = [:]
  return me.ancestor.construct()
end

on deconstruct me
  me.pListIndex = []
  me.pListData = [:]
  return me.ancestor.deconstruct()
end

on storeNewList me, tdata, tOverwrite
  if not listp(tdata) then
    return 0
  end if
  tPurgeList = me.pListIndex.duplicate()
  repeat with i = 1 to tdata.count
    tPurgeList.deleteOne(tdata[i].getaProp(#id))
  end repeat
  repeat with tID in tPurgeList
    me.removeListEntry(tID)
  end repeat
  me.pListIndex = []
  repeat with tInstanceData in tdata
    tItemID = tInstanceData.getaProp(#id)
    if me.pListIndex.findPos(tItemID) = 0 then
      me.pListIndex.append(tItemID)
    end if
    if (me.pListData.findPos(tItemID) = 0) or tOverwrite then
      me.updateListItemObject(tInstanceData)
    end if
  end repeat
  me.setUpdateTimestamp()
  return me.announceUpdate(me.pListIndex)
end

on updateEntry me, tdata
  tObject = me.updateListItemObject(tdata)
  if tObject <> 0 then
    me.announceUpdate(tdata.getaProp(#id))
  end if
  return tObject
end

on getListEntry me, tID
  if voidp(tID) then
    return 0
  end if
  return pListData.getaProp(tID)
end

on getListCount me
  return pListData.count
end

on dump me
  return me.pListData
end

on updateListItemObject me, tInstanceData
  if not listp(tInstanceData) then
    return 0
  end if
  if not tInstanceData.findPos(#id) then
    return error(me, "List instance struct must contain id!" && tInstanceData, #updateListItemObject)
  end if
  tID = tInstanceData.getaProp(#id)
  tObject = me.pListData.getaProp(tID)
  if tObject = 0 then
    tObject = me.getNewListItemObject()
    if tObject = 0 then
      return 0
    end if
    tObject.define(tInstanceData)
    me.pListData.setaProp(tID, tObject)
    if me.pListIndex.findPos(tID) = 0 then
      me.pListIndex.append(tID)
    end if
  else
    tObject.Refresh(tInstanceData)
  end if
  return tObject
end

on getListIdByIndex me, tIndex
  if tIndex < 1 then
    return -1
  end if
  if tIndex > pListIndex.count then
    return -1
  end if
  return pListIndex[tIndex]
end

on removeListEntry me, tID
  tObject = me.pListData.getaProp(tID)
  if objectp(tObject) then
    tObject.deconstruct()
  end if
  me.pListIndex.deleteOne(tID)
  me.pListData.deleteProp(tID)
end

on getNewListItemObject me
  tObject = createObject(#temp, me.pListItemContainerClass)
  if tObject = 0 then
    return 0
  end if
  tObject.pIGComponentId = me.getID()
  return tObject
end
