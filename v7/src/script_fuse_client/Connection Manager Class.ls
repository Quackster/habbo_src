property pListenerList, pCommandsList, pClassString

on construct me 
  me.pItemList = []
  me.sort()
  pListenerList = [:]
  pListenerList.sort()
  pCommandsList = [:]
  pCommandsList.sort()
  pClassString = "connection.instance.class"
  return(1)
end

on create me, tid, tHost, tPort 
  if not symbolp(tid) and not stringp(tid) then
    return(error(me, "Symbol or string expected:" && tid, #create))
  end if
  if not stringp(tHost) then
    return(error(me, "String expected:" && tHost, #create))
  end if
  if not integerp(tPort) then
    return(error(me, "Integer expected:" && tPort, #create))
  end if
  if getIntVariable("connection.log.level") = 2 then
    if not memberExists("connectionLog.text") then
      tLogField = member(createMember("connectionLog.text", #field))
      tLogField.boxType = #scroll
      tLogField.rect = rect(0, 0, 300, 250)
    else
      tLogField = member(getmemnum("connectionLog.text"))
    end if
    tLogField.text = tLogField.text & "\r" & "Connection logging" && tid & "\r"
  end if
  if not me.exists(tid) then
    if not createObject(tid, getClassVariable(pClassString)) then
      return(error(me, "Failed to initialize connection:" && tid, #create))
    end if
    me.add(tid)
  end if
  if voidp(pListenerList.getAt(tid)) then
    tMsgPtr = getStructVariable("struct.pointer")
    tMsgPtr.setaProp(#value, [:])
    pListenerList.setAt(tid, tMsgPtr)
  else
    tMsgPtr = pListenerList.getAt(tid)
  end if
  if voidp(pCommandsList.getAt(tid)) then
    tCmdPtr = getStructVariable("struct.pointer")
    tCmdPtr.setaProp(#value, [:])
    pCommandsList.setAt(tid, tCmdPtr)
  else
    tCmdPtr = pCommandsList.getAt(tid)
  end if
  me.get(tid).setProperty(#listener, tMsgPtr)
  me.get(tid).setProperty(#commands, tCmdPtr)
  me.get(tid).connect(tHost, tPort)
  return(1)
end

on closeAll me 
  i = 1
  repeat while i <= me.count(#pItemList)
    if objectExists(me.getProp(#pItemList, i)) then
      removeObject(me.getProp(#pItemList, i))
    end if
    i = 1 + i
  end repeat
  me.pItemList = []
end

on registerListener me, tid, tObjID, tMsgList 
  if tid.ilk <> #symbol and tid.ilk <> #string then
    return(error(me, "Invalid message header ID:" && tid, #registerListener))
  end if
  tObject = getObject(tObjID)
  if tObject = 0 then
    return(error(me, "Object not found:" && tObjID, #registerListener))
  end if
  if voidp(pListenerList.getAt(tid)) then
    tPtr = getStructVariable("struct.pointer")
    tPtr.setaProp(#value, [:])
    pListenerList.setAt(tid, tPtr)
  else
    tPtr = pListenerList.getAt(tid)
  end if
  i = 1
  repeat while i <= tMsgList.count
    tMsg = tMsgList.getPropAt(i)
    tMethod = tMsgList.getAt(i)
    if not tObject.handler(tMethod) then
      return(error(me, "Method not found:" && tMethod & "/" & tObjID, #registerListener))
    end if
    if voidp(tPtr.getaProp(#value).getaProp(tMsg)) then
      tPtr.getaProp(#value).setaProp(tMsg, [])
    end if
    tPtr.getaProp(#value).getaProp(tMsg).add([tObjID, tMethod])
    i = 1 + i
  end repeat
  return(1)
end

on unregisterListener me, tid, tObjID, tMsgList 
  if tid.ilk <> #symbol and tid.ilk <> #string then
    return(error(me, "Invalid message header ID:" && tid, #registerListener))
  end if
  tPtr = pListenerList.getAt(tid)
  if voidp(tPtr) then
    return(0)
  end if
  tList = tPtr.getaProp(#value)
  i = 1
  repeat while i <= tMsgList.count
    tMsg = tMsgList.getPropAt(i)
    tMethod = tMsgList.getAt(i)
    if voidp(tList.getaProp(tMsg)) then
      return(error(me, "No listeners for message:" && tMsg && "/" && tid, #unregisterListener))
    end if
    j = 1
    repeat while j <= tList.getaProp(tMsg).count
      tCallback = tList.getaProp(tMsg).getAt(j)
      if tCallback.getAt(1) = tObjID and tCallback.getAt(2) = tMethod then
        tList.getaProp(tMsg).deleteAt(j)
      else
        j = 1 + j
      end if
    end repeat
    i = 1 + i
  end repeat
  return(1)
end

on registerCommands me, tid, tObjID, tCmdList 
  if tid.ilk <> #symbol and tid.ilk <> #string then
    return(error(me, "Invalid message header ID:" && tid, #registerListener))
  end if
  if voidp(pCommandsList.getAt(tid)) then
    tPtr = getStructVariable("struct.pointer")
    tPtr.setaProp(#value, [:])
    pCommandsList.setAt(tid, tPtr)
  else
    tPtr = pCommandsList.getAt(tid)
  end if
  i = 1
  repeat while i <= tCmdList.count
    tCmd = tCmdList.getPropAt(i)
    tNum = tCmdList.getAt(i)
    tOld = tPtr.getaProp(#value).getaProp(tCmd)
    tBy1 = numToChar(bitOr(64, tNum / 64))
    tBy2 = numToChar(bitOr(64, bitAnd(63, tNum)))
    tNew = tBy1 & tBy2
    if tOld <> void() then
      if tOld <> tNew then
        error(me, "Registered command override:" && tCmd && "/" && tOld && "->" && tNew)
      end if
    end if
    tPtr.getaProp(#value).setaProp(tCmd, tNew)
    i = 1 + i
  end repeat
  return(1)
end

on unregisterCommands me, tid, tObjID, tCmdList 
  if tid.ilk <> #symbol and tid.ilk <> #string then
    return(error(me, "Invalid message header ID:" && tid, #registerListener))
  end if
  tPtr = pCommandsList.getAt(tid)
  if voidp(tPtr) then
    return(0)
  end if
  return(1)
end
