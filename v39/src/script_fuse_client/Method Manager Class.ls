property pMethodCache

on construct me 
  pMethodCache = [:]
  pMethodCache.sort()
  return TRUE
end

on deconstruct me 
  me.pItemList = [:]
  pMethodCache = [:]
  return TRUE
end

on create me, tID, tObject 
  if voidp(tID) then
    return(error(me, "Failed to create method object, ID was void", #create, #major))
  end if
  if not me.register(tID, tObject) then
    return(error(me, "Failed to register object:" && tID, #create, #major))
  else
    me.setProp(#pItemList, tID, tObject)
    return TRUE
  end if
end

on getMethod me, tConnectionID, tCommand 
  tMethods = pMethodCache.getAt(tConnectionID)
  if voidp(tMethods) then
    return(error(me, "Method list for connection not found:" && tConnectionID, #getMethod, #major))
  else
    return(tMethods.getAt(tCommand))
  end if
end

on Remove me, tID 
  if voidp(me.pItemList.getaProp(tID)) then
    return(error(me, "Object not found:" && tID, #Remove, #minor))
  else
    me.unregister(tID)
    me.pItemList.deleteProp(tID)
    return TRUE
  end if
end

on register me, tID, tObject 
  if not tObject.handler(#getCommands) then
    return(error(me, "Invalid method object:" && tID, #register, #major))
  end if
  tMethodList = tObject.getCommands()
  if not ilk(tMethodList, #propList) then
    return(error(me, "Invalid method object:" && tID, #register, #major))
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
        tCurrentList.setAt(tMethodList.getAt(i).getPropAt(j), [tMethodList.getAt(i).getAt(j), tID])
      else
        error(me, "Method" && "#" & tMethodList.getAt(i).getAt(j) && "not found in object:" && tID, #register, #major)
      end if
      j = (1 + j)
    end repeat
    i = (1 + i)
  end repeat
  return TRUE
end

on unregister me, tObjectOrID 
  if objectp(tObjectOrID) then
    tID = tObjectOrID.getID()
  else
    if stringp(tObjectOrID) or symbolp(tObjectOrID) then
      if not me.GET(tObjectOrID) then
        return(error(me, "Object not found:" && tObjectOrID, #unregister, #minor))
      end if
      tID = tObjectOrID
    end if
  end if
  tConnection = 1
  repeat while tConnection <= pMethodCache.count
    tCommand = pMethodCache.getAt(tConnection).count
    repeat while tCommand >= 1
      if (pMethodCache.getAt(tConnection).getAt(tCommand).getAt(2) = tID) then
        pMethodCache.getAt(tConnection).deleteAt(tCommand)
      end if
      tCommand = (255 + tCommand)
    end repeat
    tConnection = (1 + tConnection)
  end repeat
  return TRUE
end

on handlers  
  return([])
end
