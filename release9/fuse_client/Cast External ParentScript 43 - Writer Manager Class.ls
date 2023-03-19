property pWriterClass, pPlainStruct, pItemList

on construct me
  pWriterClass = getClassVariable("writer.instance.class")
  pPlainStruct = getStructVariable("struct.font.plain")
  pItemList = [:]
  return 1
end

on deconstruct me
  call(#deconstruct, pItemList)
  pItemList = [:]
  return 1
end

on create me, tid, tMetrics
  if not voidp(pItemList[tid]) then
    return error(me, "Writer already exists:" && tid, #create)
  end if
  tObj = getObjectManager().create(#temp, pWriterClass)
  if not tObj then
    return 0
  end if
  case tMetrics.ilk of
    #struct:
      tObj.setFont(tMetrics)
    otherwise:
      tObj.setFont(pPlainStruct)
      tObj.define(tMetrics)
  end case
  pItemList[tid] = tObj
  tObj.setID(tid)
  return 1
end

on Remove me, tid
  tObj = pItemList[tid]
  if voidp(tObj) then
    return error(me, "Writer not found:" && tid, #Remove)
  end if
  tObj.deconstruct()
  return pItemList.deleteProp(tid)
end

on get me, tid
  tObj = pItemList[tid]
  if voidp(tObj) then
    return 0
  end if
  return tObj
end

on exists me, tid
  return not voidp(pItemList[tid])
end
