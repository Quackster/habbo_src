property pItemList

on construct me
  pItemList = []
  pItemList.sort()
  return 1
end

on deconstruct me
  tObjMngr = getObjectManager()
  repeat with i = 1 to pItemList.count
    if tObjMngr.exists(pItemList[i]) then
      tObjMngr.Remove(pItemList[i])
    end if
  end repeat
  pItemList = []
  return 1
end

on create me, tID, tClass
  if getObjectManager().exists(tID) then
    return error(me, "Object already exists:" && tID, #create, #major)
  end if
  if not getObjectManager().create(tID, tClass) then
    return 0
  end if
  pItemList.add(tID)
  return 1
end

on GET me, tID
  return getObjectManager().GET(tID)
end

on getIDList me
  tIDList = []
  tListMode = ilk(me.pItemList)
  repeat with i = 1 to me.pItemList.count
    if tListMode = #list then
      tID = me.pItemList[i]
    else
      tID = me.pItemList.getPropAt(i)
    end if
    tIDList.add(tID)
  end repeat
  return tIDList
end

on Remove me, tID
  if not me.exists(tID) then
    return 0
  end if
  pItemList.deleteOne(tID)
  return getObjectManager().Remove(tID)
end

on exists me, tID
  return me.pItemList.getOne(tID) > 0
end

on print me
  tListMode = ilk(me.pItemList)
  repeat with i = 1 to me.pItemList.count
    if tListMode = #list then
      tID = me.pItemList[i]
    else
      tID = me.pItemList.getPropAt(i)
    end if
    tObj = me.GET(tID)
    if symbolp(tID) then
      tID = "#" & tID
    end if
    put tID && ":" && tObj
  end repeat
  return 1
end
