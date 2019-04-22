property pMethodCache

on construct me 
  pMethodCache = [:]
  pMethodCache.sort()
  return(1)
end

on deconstruct me 
  me.pItemList = [:]
  pMethodCache = [:]
  return(1)
end

on create me, tid, tObject 
  if not me.register(tid, tObject) then
    return(error(me, "Failed to register object:" && tid, #create))
  else
    me.setProp(#pItemList, tid, tObject)
    return(1)
  end if
end

on getMethod me, tConnectionID, tCommand 
  tMethods = pMethodCache.getAt(tConnectionID)
  if voidp(tMethods) then
    return(error(me, "Method list for connection not found:" && tConnectionID, #getMethod))
  else
    return(tMethods.getAt(tCommand))
  end if
end

on Remove me, tid 
  if voidp(me.getProp(#pItemList, tid)) then
    return(error(me, "Object not found:" && tid, #Remove))
  else
    me.unregister(tid)
    me.deleteProp(tid)
    return(1)
  end if
end

on register me, tid, tObject 
  if not tObject.handler(#getCommands) then
    return(error(me, "Invalid method object:" && tid, #register))
  end if
  tMethodList = tObject.getCommands()
  if not ilk(tMethodList, #propList) then
    return(error(me, "Invalid method object:" && tid, #register))
  end if
  i = 1
  repeat while i <= tMethodList.count
    tMethod = tMethodList.getPropAt(i)
    if voidp(pMethodCache.getAt(tMethod)) then
      pMethodCache.setAt(tMethod, [:])
      pMethodCache.getAt(tMethod).sort()
    end if
    tCurrentList = pMethodCache.getAt(tMethod)
    j = 1
    repeat while j <= tMethodList.getAt(i).count
      if tObject.handler(tMethodList.getAt(i).getAt(j)) then
        tCurrentList.setAt(tMethodList.getAt(i).getPropAt(j), [tMethodList.getAt(i).getAt(j), tid])
      else
        error(me, "Method" && "#" & tMethodList.getAt(i).getAt(j) && "not found in object:" && tid, #register)
      end if
      j = 1 + j
    end repeat
    i = 1 + i
  end repeat
  return(1)
end

on unregister me, tObjectOrID 
  if objectp(tObjectOrID) then
    tid = tObjectOrID.getID()
  else
    if stringp(tObjectOrID) or symbolp(tObjectOrID) then
      if not me.get(tObjectOrID) then
        return(error(me, "Object not found:" && tObjectOrID, #unregister))
      end if
      tid = tObjectOrID
    end if
  end if
  tConnection = 1
  repeat while tConnection <= pMethodCache.count
    tCommand = pMethodCache.getAt(tConnection).count
    repeat while tCommand >= 1
      if pMethodCache.getAt(tConnection).getAt(tCommand).getAt(2) = tid then
        pMethodCache.getAt(tConnection).deleteAt(tCommand)
      end if
      tCommand = 255 + tCommand
    end repeat
    tConnection = 1 + tConnection
  end repeat
  return(1)
end
