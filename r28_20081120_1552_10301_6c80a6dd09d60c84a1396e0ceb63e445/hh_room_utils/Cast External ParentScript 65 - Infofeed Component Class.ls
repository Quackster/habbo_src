property pBaseClassName, pItemList, pMaxItems

on test me
  tItem = [#type: #newbadge, #value: "ACH_RegistrationDuration" & random(10)]
  me.createItem(tItem)
end

on construct me
  pBaseClassName = "Infofeed Item Base Class"
  pItemList = [:]
  pMaxItems = 10
  return 1
end

on deconstruct me
  me.removeAllItems()
  return 1
end

on getItem me, tID
  if voidp(tID) then
    return 0
  end if
  return pItemList.getaProp(tID)
end

on getItemCount me
  return pItemList.count
end

on getItemPos me, tID
  if voidp(tID) then
    return 0
  end if
  return pItemList.findPos(tID)
end

on getFirstItemId me
  if pItemList.count = 0 then
    return -1
  end if
  return pItemList.getPropAt(1)
end

on getLatestItemId me
  if pItemList.count = 0 then
    return -1
  end if
  return pItemList.getPropAt(pItemList.count)
end

on getPreviousFrom me, tID
  if voidp(tID) then
    return -1
  end if
  tPos = pItemList.findPos(tID)
  if (tPos < 1) or (tPos = 1) then
    return me.getFirstItemId()
  end if
  return pItemList.getPropAt(tPos - 1)
end

on getNextFrom me, tID
  if voidp(tID) then
    return -1
  end if
  tPos = pItemList.findPos(tID)
  if (tPos < 1) or (tPos = pItemList.count) then
    return me.getLatestItemId()
  end if
  return pItemList.getPropAt(tPos + 1)
end

on createItem me, tStruct
  if not listp(tStruct) then
    return 0
  end if
  tID = me.getLatestItemId() + 1
  tStruct.setaProp(#id, tID)
  if pItemList.findPos(tID) > 0 then
    return error(me, "Info entry by id" && tID && "already exists." & RETURN & tStruct, #createItem)
  end if
  ttype = tStruct.getaProp(#type)
  tClass = me.getItemClass(ttype)
  if tClass = 0 then
    return 0
  end if
  tObject = createObject(#temp, tClass)
  if tObject = 0 then
    return error(me, "Cannot create info instance." && RETURN && tStruct, #createItem)
  end if
  tObject.define(tStruct)
  pItemList.setaProp(tID, tObject)
  me.purgeItems()
  me.getInterface().itemCreated(tID)
  return 1
end

on purgeItems me
  if pItemList.count <= pMaxItems then
    return 1
  end if
  repeat while pItemList.count > pMaxItems
    pItemList.deleteAt(1)
  end repeat
  return 1
end

on removeAllItems me
  repeat with tItem in pItemList
    tItem.deconstruct()
  end repeat
  pItemList = [:]
end

on getItemClass me, ttype
  case ttype of
  end case
  tClassName = "Infofeed Item" && ttype && "Class"
  if getmemnum(tClassName) > 0 then
    return [me.pBaseClassName, tClassName]
  end if
  return me.pBaseClassName
end
