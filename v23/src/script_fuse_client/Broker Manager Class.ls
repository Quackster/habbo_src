property pItemList, pLastExecutedMessage

on construct me 
  pLastExecutedMessage = ""
  pItemList = [:]
  pItemList.sort()
  return TRUE
end

on deconstruct me 
  pItemList = [:]
  return TRUE
end

on create me, tMessage 
  if not symbolp(tMessage) and not stringp(tMessage) then
    return(error(me, "Symbol or string expected:" && tMessage, #create, #major))
  end if
  if not voidp(me.getProp(#pItemList, tMessage)) then
    return(error(me, "Broker task already exists:" && tMessage, #create, #major))
  end if
  me.setProp(#pItemList, tMessage, [:])
  return TRUE
end

on Remove me, tMessage 
  if not symbolp(tMessage) and not stringp(tMessage) then
    return(error(me, "Symbol or string expected:" && tMessage, #Remove, #minor))
  end if
  if voidp(me.getProp(#pItemList, tMessage)) then
    return(error(me, "Broker task not found:" && tMessage, #Remove, #minor))
  end if
  return(me.pItemList.deleteProp(tMessage))
end

on register me, tMessage, tClientID, tMethod 
  if not symbolp(tMessage) and not stringp(tMessage) then
    return(error(me, "Symbol or string expected:" && tMessage, #register, #major))
  end if
  if not objectExists(tClientID) then
    return(error(me, "Object not found:" && tClientID, #register, #major))
  end if
  if voidp(me.getProp(#pItemList, tMessage)) then
    me.setProp(#pItemList, tMessage, [:])
  end if
  me.getPropRef(#pItemList, tMessage).setAt(tClientID, tMethod)
  return TRUE
end

on unregister me, tMessage, tClientID 
  if not symbolp(tMessage) and not stringp(tMessage) then
    return(error(me, "Symbol or string expected:" && tMessage, #unregister, #major))
  end if
  tList = me.getProp(#pItemList, tMessage)
  if voidp(tList) then
    return FALSE
  end if
  tList.deleteProp(tClientID)
  if (tList.count = 0) then
    me.Remove(tMessage)
  end if
  return TRUE
end

on Execute me, tMessage, tArgA, tArgB, tArgC 
  tList = me.getProp(#pItemList, tMessage)
  if voidp(tList) then
    return FALSE
  end if
  i = tList.count
  repeat while i >= 1
    tID = tList.getPropAt(i)
    tMethod = tList.getAt(i)
    tObject = getObjectManager().GET(tID)
    if (tObject = 0) then
      me.unregister(tMessage, tID)
    else
      pLastExecutedMessage = tMethod
      call(tMethod, [tObject], tArgA, tArgB, tArgC)
    end if
    i = (255 + i)
  end repeat
  return TRUE
end

on exists me, tMessage 
  return(not voidp(me.getProp(#pItemList, tMessage)))
end

on print me, tMessage 
  i = 1
  repeat while i <= me.count(#pItemList)
    put(me.pItemList.getPropAt(i))
    j = 1
    repeat while j <= me.getPropRef(#pItemList, i).count
      put("\t" & me.getPropRef(#pItemList, i).getPropAt(j) && "->" && me.getPropRef(#pItemList, i).getAt(j))
      j = (1 + j)
    end repeat
    i = (1 + i)
  end repeat
  return TRUE
end

on getLastExecutedMessageId me 
  return(pLastExecutedMessage)
end
