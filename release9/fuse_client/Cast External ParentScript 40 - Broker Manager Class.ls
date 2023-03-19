property pItemList

on construct me
  pItemList = [:]
  pItemList.sort()
  return 1
end

on deconstruct me
  pItemList = [:]
  return 1
end

on create me, tMessage
  if not symbolp(tMessage) and not stringp(tMessage) then
    return error(me, "Symbol or string expected:" && tMessage, #create)
  end if
  if not voidp(me.pItemList[tMessage]) then
    return error(me, "Broker task already exists:" && tMessage, #create)
  end if
  me.pItemList[tMessage] = [:]
  return 1
end

on Remove me, tMessage
  if not symbolp(tMessage) and not stringp(tMessage) then
    return error(me, "Symbol or string expected:" && tMessage, #Remove)
  end if
  if voidp(me.pItemList[tMessage]) then
    return error(me, "Broker task not found:" && tMessage, #Remove)
  end if
  return me.pItemList.deleteProp(tMessage)
end

on register me, tMessage, tClientID, tMethod
  if not symbolp(tMessage) and not stringp(tMessage) then
    return error(me, "Symbol or string expected:" && tMessage, #register)
  end if
  if not objectExists(tClientID) then
    return error(me, "Object not found:" && tClientID, #register)
  end if
  if voidp(me.pItemList[tMessage]) then
    me.pItemList[tMessage] = [:]
  end if
  me.pItemList[tMessage][tClientID] = tMethod
  return 1
end

on unregister me, tMessage, tClientID
  if not symbolp(tMessage) and not stringp(tMessage) then
    return error(me, "Symbol or string expected:" && tMessage, #unregister)
  end if
  tList = me.pItemList[tMessage]
  if voidp(tList) then
    return 0
  end if
  tList.deleteProp(tClientID)
  if tList.count = 0 then
    me.Remove(tMessage)
  end if
  return 1
end

on execute me, tMessage, tArgA, tArgB, tArgC
  tList = me.pItemList[tMessage]
  if voidp(tList) then
    return 0
  end if
  repeat with i = tList.count down to 1
    tid = tList.getPropAt(i)
    tMethod = tList[i]
    tObject = getObjectManager().get(tid)
    if tObject = 0 then
      me.unregister(tMessage, tid)
      next repeat
    end if
    call(tMethod, tObject, tArgA, tArgB, tArgC)
  end repeat
  return 1
end

on exists me, tMessage
  return not voidp(me.pItemList[tMessage])
end

on print me, tMessage
  repeat with i = 1 to me.pItemList.count
    put me.pItemList.getPropAt(i)
    repeat with j = 1 to me.pItemList[i].count
      put TAB & me.pItemList[i].getPropAt(j) && "->" && me.pItemList[i][j]
    end repeat
  end repeat
  return 1
end
