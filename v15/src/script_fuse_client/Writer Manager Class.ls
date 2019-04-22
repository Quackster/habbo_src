property pItemList, pWriterClass, pPlainStruct

on construct me 
  pWriterClass = getClassVariable("writer.instance.class")
  pPlainStruct = getStructVariable("struct.font.plain")
  pItemList = [:]
  return(1)
end

on deconstruct me 
  call(#deconstruct, pItemList)
  pItemList = [:]
  return(1)
end

on create me, tid, tMetrics 
  if not voidp(pItemList.getAt(tid)) then
    return(error(me, "Writer already exists:" && tid, #create, #major))
  end if
  tObj = getObjectManager().create(#temp, pWriterClass)
  if not tObj then
    return(0)
  end if
  if tMetrics.ilk = #struct then
    tObj.setFont(tMetrics)
  else
    tObj.setFont(pPlainStruct)
    tObj.define(tMetrics)
  end if
  pItemList.setAt(tid, tObj)
  tObj.setID(tid)
  return(1)
end

on Remove me, tid 
  tObj = pItemList.getAt(tid)
  if voidp(tObj) then
    return(error(me, "Writer not found:" && tid, #Remove, #minor))
  end if
  tObj.deconstruct()
  return(pItemList.deleteProp(tid))
end

on GET me, tid 
  tObj = pItemList.getAt(tid)
  if voidp(tObj) then
    return(0)
  end if
  return(tObj)
end

on exists me, tid 
  return(not voidp(pItemList.getAt(tid)))
end
