on test(me)
  tItem = [#type:#newbadge, #value:"ACH_RegistrationDuration" & random(10)]
  me.createItem(tItem)
  exit
end

on construct(me)
  pBaseClassName = "Infofeed Item Base Class"
  pItemList = []
  pMaxItems = 10
  return(1)
  exit
end

on deconstruct(me)
  me.removeAllItems()
  return(1)
  exit
end

on getItem(me, tID)
  if voidp(tID) then
    return(0)
  end if
  return(pItemList.getaProp(tID))
  exit
end

on getItemCount(me)
  return(pItemList.count)
  exit
end

on getItemPos(me, tID)
  if voidp(tID) then
    return(0)
  end if
  return(pItemList.findPos(tID))
  exit
end

on getFirstItemId(me)
  if pItemList.count = 0 then
    return(-1)
  end if
  return(pItemList.getPropAt(1))
  exit
end

on getLatestItemId(me)
  if pItemList.count = 0 then
    return(-1)
  end if
  return(pItemList.getPropAt(pItemList.count))
  exit
end

on getPreviousFrom(me, tID)
  if voidp(tID) then
    return(-1)
  end if
  tPos = pItemList.findPos(tID)
  if tPos < 1 or tPos = 1 then
    return(me.getFirstItemId())
  end if
  return(pItemList.getPropAt(tPos - 1))
  exit
end

on getNextFrom(me, tID)
  if voidp(tID) then
    return(-1)
  end if
  tPos = pItemList.findPos(tID)
  if tPos < 1 or tPos = pItemList.count then
    return(me.getLatestItemId())
  end if
  return(pItemList.getPropAt(tPos + 1))
  exit
end

on createItem(me, tStruct)
  if not listp(tStruct) then
    return(0)
  end if
  tID = me.getLatestItemId() + 1
  tStruct.setaProp(#id, tID)
  if pItemList.findPos(tID) > 0 then
    return(error(me, "Info entry by id" && tID && "already exists." & "\r" & tStruct, #createItem))
  end if
  ttype = tStruct.getaProp(#type)
  tClass = me.getItemClass(ttype)
  if tClass = 0 then
    return(0)
  end if
  tObject = createObject(#temp, tClass)
  if tObject = 0 then
    return(error(me, "Cannot create info instance." && "\r" && tStruct, #createItem))
  end if
  tObject.define(tStruct)
  pItemList.setaProp(tID, tObject)
  me.purgeItems()
  me.getInterface().itemCreated(tID)
  return(1)
  exit
end

on purgeItems(me)
  if pItemList.count <= pMaxItems then
    return(1)
  end if
  repeat while pItemList.count > pMaxItems
    pItemList.deleteAt(1)
  end repeat
  return(1)
  exit
end

on removeAllItems(me)
  repeat while me <= undefined
    tItem = getAt(undefined, undefined)
    tItem.deconstruct()
  end repeat
  pItemList = []
  exit
end

on getItemClass(me, ttype)
  tClassName = "Infofeed Item" && ttype && "Class"
  if getmemnum(tClassName) > 0 then
    return([me.pBaseClassName, tClassName])
  end if
  return(me.pBaseClassName)
  exit
end