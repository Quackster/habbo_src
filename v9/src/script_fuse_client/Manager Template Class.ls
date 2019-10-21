on construct(me)
  pItemList = []
  pItemList.sort()
  return(1)
  exit
end

on deconstruct(me)
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
  exit
end

on create(me, tid, tClass)
  if getObjectManager().exists(tid) then
    return(error(me, "Object already exists:" && tid, #create))
  end if
  if not getObjectManager().create(tid, tClass) then
    return(0)
  end if
  pItemList.add(tid)
  return(1)
  exit
end

on get(me, tid)
  return(getObjectManager().get(tid))
  exit
end

on Remove(me, tid)
  if not me.exists(tid) then
    return(0)
  end if
  pItemList.deleteOne(tid)
  return(getObjectManager().Remove(tid))
  exit
end

on exists(me, tid)
  return(me.getOne(tid) > 0)
  exit
end

on print(me)
  tListMode = ilk(me.pItemList)
  i = 1
  repeat while i <= me.count(#pItemList)
    if tListMode = #list then
      tid = me.getProp(#pItemList, i)
    else
      tid = me.getPropAt(i)
    end if
    tObj = me.get(tid)
    if symbolp(tid) then
      tid = "#" & tid
    end if
    put(tid && ":" && tObj)
    i = 1 + i
  end repeat
  return(1)
  exit
end