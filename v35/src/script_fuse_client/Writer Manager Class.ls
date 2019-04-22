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

on create(me, tID, tMetrics)
  if voidp(tID) then
    return(error(me, "Failed to create writer. Writer ID was void", #create, #major))
  end if
  if not voidp(pItemList.getAt(tID)) then
    return(error(me, "Writer already exists:" && tID, #create, #minor))
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
  pItemList.setAt(tID, tObj)
  tObj.setID(tID)
  return(1)
  exit
end

on Remove(me, tID)
  tObj = pItemList.getaProp(tID)
  if voidp(tObj) then
    return(error(me, "Writer not found:" && tID, #Remove, #minor))
  end if
  tObj.deconstruct()
  return(pItemList.deleteProp(tID))
  exit
end

on GET(me, tID)
  tObj = pItemList.getaProp(tID)
  if voidp(tObj) then
    return(0)
  end if
  return(tObj)
  exit
end

on exists(me, tID)
  return(not voidp(pItemList.getaProp(tID)))
  exit
end

on handlers()
  return([])
  exit
end