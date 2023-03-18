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

on create me, tID, tMetrics
  if not voidp(pItemList[tID]) then
    return error(me, "Writer already exists:" && tID, #create, #minor)
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
  pItemList[tID] = tObj
  tObj.setID(tID)
  return 1
end

on Remove me, tID
  tObj = pItemList[tID]
  if voidp(tObj) then
    return error(me, "Writer not found:" && tID, #Remove, #minor)
  end if
  tObj.deconstruct()
  return pItemList.deleteProp(tID)
end

on GET me, tID
  tObj = pItemList[tID]
  if voidp(tObj) then
    return 0
  end if
  return tObj
end

on exists me, tID
  return not voidp(pItemList[tID])
end
