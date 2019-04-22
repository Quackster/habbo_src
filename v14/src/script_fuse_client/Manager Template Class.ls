property pItemList

on construct me 
  pItemList = []
  pItemList.sort()
  return(1)
end

on deconstruct me 
  tObjMngr = getObjectManager()
  i = 1
  repeat while i <= pItemList.count
    if tObjMngr.exists(pItemList.getAt(i)) then
      tObjMngr.Remove(pItemList.getAt(i))
    end if
    i = 1 + i
  end repeat
  pItemList = []
  return(1)
end

on create me, tid, tClass 
  if getObjectManager().exists(tid) then
    return(error(me, "Object already exists:" && tid, #create, #major))
  end if
  if not getObjectManager().create(tid, tClass) then
    return(0)
  end if
  pItemList.add(tid)
  return(1)
end

on GET me, tid 
  return(getObjectManager().GET(tid))
end

on Remove me, tid 
  if not me.exists(tid) then
    return(0)
  end if
  pItemList.deleteOne(tid)
  return(getObjectManager().Remove(tid))
end

on exists me, tid 
  return(pItemList.getOne(tid) > 0)
end

on print me 
  tListMode = ilk(me.pItemList)
  i = 1
  repeat while i <= me.count(#pItemList)
    if tListMode = #list then
      tid = me.getProp(#pItemList, i)
    else
      tid = pItemList.getPropAt(i)
    end if
    tObj = me.GET(tid)
    if symbolp(tid) then
      tid = "#" & tid
    end if
    put(tid && ":" && tObj)
    i = 1 + i
  end repeat
  return(1)
end
