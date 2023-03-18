on construct me
  me.pItemList = [:]
  return 1
end

on deconstruct me
  tObjMngr = getObjectManager()
  repeat with i = 1 to me.pItemList.count
    tID = me.pItemList[i][#timerid]
    if tObjMngr.exists(tID) then
      tObjMngr.GET(tID).forget()
    end if
  end repeat
  me.pItemList = [:]
  return 1
end

on create me, tID, tTime, tHandler, tClientID, tArgument, tIterations
  if me.exists(tID) then
    return error(me, "Timeout already registered:" && tID, #create, #major)
  end if
  if not integerp(tTime) then
    return error(me, "Integer expected:" && tTime, #create, #major)
  end if
  if not symbolp(tHandler) then
    return error(me, "Symbol expected:" && tHandler, #create, #major)
  end if
  tObjMngr = getObjectManager()
  if tObjMngr.exists(tClientID) then
    if not tObjMngr.GET(tClientID).handler(tHandler) then
      return error(me, "Handler not found in object:" && tHandler && tClientID, #create, #major)
    end if
  else
    if not voidp(tClientID) then
      return error(me, "Object ID or VOID expected:" && tClientID, #create, #major)
    end if
  end if
  tUniqueId = "Timeout" && getUniqueID()
  tObjMngr.create(tUniqueId, timeout(tUniqueId).new(tTime, #executeTimeOut, me))
  tList = [:]
  tList[#uniqueid] = tUniqueId
  tList[#handler] = tHandler
  tList[#client] = tClientID
  tList[#argument] = tArgument
  tList[#iterations] = tIterations
  tList[#count] = 0
  me.pItemList[tID] = tList
  return 1
end

on GET me, tID
  if not me.exists(tID) then
    return error(me, "Item not found:" && tID, #GET, #minor)
  end if
  tTask = me.pItemList[tID]
  if voidp(tTask[#client]) then
    value(tTask[#handler] & "(" & tTask[#argument] & ")")
  else
    tObjMngr = getObjectManager()
    if tObjMngr.exists(tTask[#client]) then
      call(tTask[#handler], tObjMngr.GET(tTask[#client]), tTask[#argument])
    else
      return me.Remove(tID)
    end if
  end if
end

on Remove me, tID
  if not me.exists(tID) then
    return error(me, "Item not found:" && tID, #Remove, #minor)
  end if
  tObjMngr = getObjectManager()
  tObject = tObjMngr.GET(me.pItemList[tID][#uniqueid])
  if tObject <> 0 then
    tObject.target = VOID
    tObject.forget()
    tObject = VOID
    tObjMngr.Remove(me.pItemList[tID][#uniqueid])
  end if
  return me.pItemList.deleteProp(tID)
end

on exists me, tID
  return listp(me.pItemList[tID])
end

on executeTimeOut me, tTimeout
  repeat with i = 1 to me.pItemList.count
    if me.pItemList[i][#uniqueid] = tTimeout.name then
      tID = me.pItemList.getPropAt(i)
      tTask = me.pItemList[tID]
      exit repeat
    end if
  end repeat
  if voidp(tID) then
    tTimeout.forget()
    return 0
  end if
  me.pItemList[tID][#count] = me.pItemList[tID][#count] + 1
  if me.pItemList[tID][#count] = me.pItemList[tID][#iterations] then
    me.Remove(tID)
  end if
  if voidp(tTask[#client]) then
    value(tTask[#handler] & "(" & tTask[#argument] & ")")
  else
    tObject = getObject(tTask[#client])
    if objectp(tObject) then
      call(tTask[#handler], tObject, tTask[#argument])
    else
      return me.Remove(tID)
    end if
  end if
  return 1
end
