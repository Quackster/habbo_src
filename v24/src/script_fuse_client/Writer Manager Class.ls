property pItemList, pWriterClass, pPlainStruct

on construct me 
  pWriterClass = getClassVariable("writer.instance.class")
  pPlainStruct = getStructVariable("struct.font.plain")
  pItemList = [:]
  return TRUE
end

on deconstruct me 
  call(#deconstruct, pItemList)
  pItemList = [:]
  return TRUE
end

on create me, tID, tMetrics 
  if not voidp(pItemList.getAt(tID)) then
    return(error(me, "Writer already exists:" && tID, #create, #minor))
  end if
  tObj = getObjectManager().create(#temp, pWriterClass)
  if not tObj then
    return FALSE
  end if
  if (tMetrics.ilk = #struct) then
    tObj.setFont(tMetrics)
  else
    tObj.setFont(pPlainStruct)
    tObj.define(tMetrics)
  end if
  pItemList.setAt(tID, tObj)
  tObj.setID(tID)
  return TRUE
end

on Remove me, tID 
  tObj = pItemList.getAt(tID)
  if voidp(tObj) then
    return(error(me, "Writer not found:" && tID, #Remove, #minor))
  end if
  tObj.deconstruct()
  return(pItemList.deleteProp(tID))
end

on GET me, tID 
  tObj = pItemList.getAt(tID)
  if voidp(tObj) then
    return FALSE
  end if
  return(tObj)
end

on exists me, tID 
  return(not voidp(pItemList.getAt(tID)))
end
