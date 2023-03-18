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

on create me, tID, tObject
  if voidp(tID) then
    return error(me, "Failed to create method object, ID was void", #create, #major)
  end if
  if not me.register(tID, tObject) then
    return error(me, "Failed to register object:" && tID, #create, #major)
  else
    me.pItemList[tID] = tObject
    return 1
  end if
end

on getMethod me, tConnectionID, tCommand
  tMethods = pMethodCache[tConnectionID]
  if voidp(tMethods) then
    return error(me, "Method list for connection not found:" && tConnectionID, #getMethod, #major)
  else
    return tMethods[tCommand]
  end if
end

on Remove me, tID
  if voidp(me.pItemList.getaProp(tID)) then
    return error(me, "Object not found:" && tID, #Remove, #minor)
  else
    me.unregister(tID)
    me.pItemList.deleteProp(tID)
    return 1
  end if
end

on register me, tID, tObject
  if not tObject.handler(#getCommands) then
    return error(me, "Invalid method object:" && tID, #register, #major)
  end if
  tMethodList = tObject.getCommands()
  if not ilk(tMethodList, #propList) then
    return error(me, "Invalid method object:" && tID, #register, #major)
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
        tCurrentList[tMethodList[i].getPropAt(j)] = [tMethodList[i][j], tID]
        next repeat
      end if
      error(me, "Method" && "#" & tMethodList[i][j] && "not found in object:" && tID, #register, #major)
    end repeat
  end repeat
  return 1
end

on unregister me, tObjectOrID
  if objectp(tObjectOrID) then
    tID = tObjectOrID.getID()
  else
    if stringp(tObjectOrID) or symbolp(tObjectOrID) then
      if not me.GET(tObjectOrID) then
        return error(me, "Object not found:" && tObjectOrID, #unregister, #minor)
      end if
      tID = tObjectOrID
    end if
  end if
  repeat with tConnection = 1 to pMethodCache.count
    repeat with tCommand = pMethodCache[tConnection].count down to 1
      if pMethodCache[tConnection][tCommand][2] = tID then
        pMethodCache[tConnection].deleteAt(tCommand)
      end if
    end repeat
  end repeat
  return 1
end

on handlers
  return []
end
