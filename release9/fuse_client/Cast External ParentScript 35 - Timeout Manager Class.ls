on construct me
  me.pItemList = [:]
  return 1
end

on deconstruct me
  tObjMngr = getObjectManager()
  repeat with i = 1 to me.pItemList.count
    tid = me.pItemList[i][#timerid]
    if tObjMngr.exists(tid) then
      tObjMngr.get(tid).forget()
    end if
  end repeat
  me.pItemList = [:]
  return 1
end

on create me, tid, tTime, tHandler, tClientID, tArgument, tIterations
  if me.exists(tid) then
    return error(me, "Timeout already registered:" && tid, #create)
  end if
  if not integerp(tTime) then
    return error(me, "Integer expected:" && tTime, #create)
  end if
  if not symbolp(tHandler) then
    return error(me, "Symbol expected:" && tHandler, #create)
  end if
  tObjMngr = getObjectManager()
  if tObjMngr.exists(tClientID) then
    if not tObjMngr.get(tClientID).handler(tHandler) then
      return error(me, "Handler not found in object:" && tHandler && tClientID, #create)
    end if
  else
    if not voidp(tClientID) then
      return error(me, "Object ID or VOID expected:" && tClientID, #create)
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
  me.pItemList[tid] = tList
  return 1
end

on get me, tid
  if not me.exists(tid) then
    return error(me, "Item not found:" && tid, #get)
  end if
  tTask = me.pItemList[tid]
  if voidp(tTask[#client]) then
    value(tTask[#handler] & "(" & tTask[#argument] & ")")
  else
    tObjMngr = getObjectManager()
    if tObjMngr.exists(tTask[#client]) then
      call(tTask[#handler], tObjMngr.get(tTask[#client]), tTask[#argument])
    else
      return me.Remove(tid)
    end if
  end if
end

on Remove me, tid
  if not me.exists(tid) then
    return error(me, "Item not found:" && tid, #Remove)
  end if
  tObjMngr = getObjectManager()
  tObject = tObjMngr.get(me.pItemList[tid][#uniqueid])
  if tObject <> 0 then
    tObject.target = VOID
    tObject.forget()
    tObject = VOID
    tObjMngr.Remove(me.pItemList[tid][#uniqueid])
  end if
  return me.pItemList.deleteProp(tid)
end

on exists me, tid
  return listp(me.pItemList[tid])
end

on executeTimeOut me, tTimeout
  repeat with i = 1 to me.pItemList.count
    if me.pItemList[i][#uniqueid] = tTimeout.name then
      tid = me.pItemList.getPropAt(i)
      tTask = me.pItemList[tid]
      exit repeat
    end if
  end repeat
  if voidp(tid) then
    tTimeout.forget()
    return 0
  end if
  me.pItemList[tid][#count] = me.pItemList[tid][#count] + 1
  if me.pItemList[tid][#count] = me.pItemList[tid][#iterations] then
    me.Remove(tid)
  end if
  if voidp(tTask[#client]) then
    value(tTask[#handler] & "(" & tTask[#argument] & ")")
  else
    tObject = getObject(tTask[#client])
    if objectp(tObject) then
      call(tTask[#handler], tObject, tTask[#argument])
    else
      return me.Remove(tid)
    end if
  end if
  return 1
end
