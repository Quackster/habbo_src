on construct(me)
  pWriterClass = getClassVariable("writer.instance.class")
  pPlainStruct = getStructVariable("struct.font.plain")
  pItemList = []
  return(1)
  exit
end

on deconstruct(me)
  call(#deconstruct, pItemList)
  pItemList = []
  return(1)
  exit
end

on create(me, tid, tMetrics)
  if not voidp(pItemList.getAt(tid)) then
    return(error(me, "Writer already exists:" && tid, #create))
  end if
  tObj = getObjectManager().create(#temp, pWriterClass)
  if not tObj then
    return(0)
  end if
  if me = #struct then
    tObj.setFont(tMetrics)
  else
    tObj.setFont(pPlainStruct)
    tObj.define(tMetrics)
  end if
  pItemList.setAt(tid, tObj)
  tObj.setID(tid)
  return(1)
  exit
end

on Remove(me, tid)
  tObj = pItemList.getAt(tid)
  if voidp(tObj) then
    return(error(me, "Writer not found:" && tid, #Remove))
  end if
  tObj.deconstruct()
  return(pItemList.deleteProp(tid))
  exit
end

on get(me, tid)
  tObj = pItemList.getAt(tid)
  if voidp(tObj) then
    return(0)
  end if
  return(tObj)
  exit
end

on exists(me, tid)
  return(not voidp(pItemList.getAt(tid)))
  exit
end