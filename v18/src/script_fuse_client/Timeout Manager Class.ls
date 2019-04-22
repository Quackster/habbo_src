on construct me 
  me.pItemList = [:]
  return(1)
end

on deconstruct me 
  tObjMngr = getObjectManager()
  i = 1
  repeat while i <= me.count(#pItemList)
    tID = me.getPropRef(#pItemList, i).getAt(#timerid)
    if tObjMngr.exists(tID) then
      tObjMngr.GET(tID).forget()
    end if
    i = 1 + i
  end repeat
  me.pItemList = [:]
  return(1)
end

on create me, tID, tTime, tHandler, tClientID, tArgument, tIterations 
  if me.exists(tID) then
    return(error(me, "Timeout already registered:" && tID, #create, #major))
  end if
  if not integerp(tTime) then
    return(error(me, "Integer expected:" && tTime, #create, #major))
  end if
  if not symbolp(tHandler) then
    return(error(me, "Symbol expected:" && tHandler, #create, #major))
  end if
  tObjMngr = getObjectManager()
  if tObjMngr.exists(tClientID) then
    if not tObjMngr.GET(tClientID).handler(tHandler) then
      return(error(me, "Handler not found in object:" && tHandler && tClientID, #create, #major))
    end if
  else
    if not voidp(tClientID) then
      return(error(me, "Object ID or VOID expected:" && tClientID, #create, #major))
    end if
  end if
  tUniqueId = "Timeout" && getUniqueID()
  tObjMngr.create(tUniqueId, timeout(tUniqueId).new(tTime, #executeTimeOut, me))
  tList = [:]
  tList.setAt(#uniqueid, tUniqueId)
  tList.setAt(#handler, tHandler)
  tList.setAt(#client, tClientID)
  tList.setAt(#argument, tArgument)
  tList.setAt(#iterations, tIterations)
  tList.setAt(#count, 0)
  me.setProp(#pItemList, tID, tList)
  return(1)
end

on GET me, tID 
  if not me.exists(tID) then
    return(error(me, "Item not found:" && tID, #GET, #minor))
  end if
  tTask = me.getProp(#pItemList, tID)
  if voidp(tTask.getAt(#client)) then
    value(tTask.getAt(#handler) & "(" & tTask.getAt(#argument) & ")")
  else
    tObjMngr = getObjectManager()
    if tObjMngr.exists(tTask.getAt(#client)) then
      call(tTask.getAt(#handler), tObjMngr.GET(tTask.getAt(#client)), tTask.getAt(#argument))
    else
      return(me.Remove(tID))
    end if
  end if
end

on Remove me, tID 
  if not me.exists(tID) then
    return(error(me, "Item not found:" && tID, #Remove, #minor))
  end if
  tObjMngr = getObjectManager()
  tObject = tObjMngr.GET(me.getPropRef(#pItemList, tID).getAt(#uniqueid))
  if tObject <> 0 then
    tObject.target = void()
    tObject.forget()
    tObject = void()
    tObjMngr.Remove(me.getPropRef(#pItemList, tID).getAt(#uniqueid))
  end if
  return(me.deleteProp(tID))
end

on exists me, tID 
  return(listp(me.getProp(#pItemList, tID)))
end

on executeTimeOut me, tTimeout 
  i = 1
  repeat while i <= me.count(#pItemList)
    if me.getPropRef(#pItemList, i).getAt(#uniqueid) = tTimeout.name then
      tID = me.getPropAt(i)
      tTask = me.getProp(#pItemList, tID)
    else
      i = 1 + i
    end if
  end repeat
  if voidp(tID) then
    tTimeout.forget()
    return(0)
  end if
  me.getPropRef(#pItemList, tID).setAt(#count, me.getPropRef(#pItemList, tID).getAt(#count) + 1)
  if me.getPropRef(#pItemList, tID).getAt(#count) = me.getPropRef(#pItemList, tID).getAt(#iterations) then
    me.Remove(tID)
  end if
  if voidp(tTask.getAt(#client)) then
    value(tTask.getAt(#handler) & "(" & tTask.getAt(#argument) & ")")
  else
    tObject = getObject(tTask.getAt(#client))
    if objectp(tObject) then
      call(tTask.getAt(#handler), tObject, tTask.getAt(#argument))
    else
      return(me.Remove(tID))
    end if
  end if
  return(1)
end
