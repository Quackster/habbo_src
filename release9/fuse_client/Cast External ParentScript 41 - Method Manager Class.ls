property pMethodCache

on construct me
  pMethodCache = [:]
  pMethodCache.sort()
  return 1
end

on deconstruct me
  me.pItemList = [:]
  pMethodCache = [:]
  return 1
end

on create me, tid, tObject
  if not me.register(tid, tObject) then
    return error(me, "Failed to register object:" && tid, #create)
  else
    me.pItemList[tid] = tObject
    return 1
  end if
end

on getMethod me, tConnectionID, tCommand
  tMethods = pMethodCache[tConnectionID]
  if voidp(tMethods) then
    return error(me, "Method list for connection not found:" && tConnectionID, #getMethod)
  else
    return tMethods[tCommand]
  end if
end

on Remove me, tid
  if voidp(me.pItemList[tid]) then
    return error(me, "Object not found:" && tid, #Remove)
  else
    me.unregister(tid)
    me.pItemList.deleteProp(tid)
    return 1
  end if
end

on register me, tid, tObject
  if not tObject.handler(#getCommands) then
    return error(me, "Invalid method object:" && tid, #register)
  end if
  tMethodList = tObject.getCommands()
  if not ilk(tMethodList, #propList) then
    return error(me, "Invalid method object:" && tid, #register)
  end if
  repeat with i = 1 to tMethodList.count
    tMethod = tMethodList.getPropAt(i)
    if voidp(pMethodCache[tMethod]) then
      pMethodCache[tMethod] = [:]
      pMethodCache[tMethod].sort()
    end if
    tCurrentList = pMethodCache[tMethod]
    repeat with j = 1 to tMethodList[i].count
      if tObject.handler(tMethodList[i][j]) then
        tCurrentList[tMethodList[i].getPropAt(j)] = [tMethodList[i][j], tid]
        next repeat
      end if
      error(me, "Method" && "#" & tMethodList[i][j] && "not found in object:" && tid, #register)
    end repeat
  end repeat
  return 1
end

on unregister me, tObjectOrID
  if objectp(tObjectOrID) then
    tid = tObjectOrID.getID()
  else
    if stringp(tObjectOrID) or symbolp(tObjectOrID) then
      if not me.get(tObjectOrID) then
        return error(me, "Object not found:" && tObjectOrID, #unregister)
      end if
      tid = tObjectOrID
    end if
  end if
  repeat with tConnection = 1 to pMethodCache.count
    repeat with tCommand = pMethodCache[tConnection].count down to 1
      if pMethodCache[tConnection][tCommand][2] = tid then
        pMethodCache[tConnection].deleteAt(tCommand)
      end if
    end repeat
  end repeat
  return 1
end
