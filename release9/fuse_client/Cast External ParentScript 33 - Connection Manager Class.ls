property pListenerList, pCommandsList, pClassString

on construct me
  me.pItemList = []
  me.pItemList.sort()
  pListenerList = [:]
  pListenerList.sort()
  pCommandsList = [:]
  pCommandsList.sort()
  pClassString = "connection.instance.class"
  return 1
end

on create me, tid, tHost, tPort
  if not symbolp(tid) and not stringp(tid) then
    return error(me, "Symbol or string expected:" && tid, #create)
  end if
  if not stringp(tHost) then
    return error(me, "String expected:" && tHost, #create)
  end if
  if not integerp(tPort) then
    return error(me, "Integer expected:" && tPort, #create)
  end if
  if (getIntVariable("connection.log.level") = 2) and (the runMode contains "Author") then
    if not memberExists("connectionLog.text") then
      tLogField = member(createMember("connectionLog.text", #field))
      tLogField.boxType = #scroll
      tLogField.rect = rect(0, 0, 300, 250)
    else
      tLogField = member(getmemnum("connectionLog.text"))
    end if
    tLogField.text = tLogField.text & RETURN & "Connection logging" && tid & RETURN
  end if
  if not me.exists(tid) then
    if not createObject(tid, getClassVariable(pClassString)) then
      return error(me, "Failed to initialize connection:" && tid, #create)
    end if
    me.pItemList.add(tid)
  end if
  if voidp(pListenerList[tid]) then
    tMsgPtr = getStructVariable("struct.pointer")
    tMsgPtr.setaProp(#value, [:])
    pListenerList[tid] = tMsgPtr
  else
    tMsgPtr = pListenerList[tid]
  end if
  if voidp(pCommandsList[tid]) then
    tCmdPtr = getStructVariable("struct.pointer")
    tCmdPtr.setaProp(#value, [:])
    pCommandsList[tid] = tCmdPtr
  else
    tCmdPtr = pCommandsList[tid]
  end if
  me.get(tid).setProperty(#listener, tMsgPtr)
  me.get(tid).setProperty(#commands, tCmdPtr)
  me.get(tid).connect(tHost, tPort)
  return 1
end

on closeAll me
  repeat with i = 1 to me.pItemList.count
    if objectExists(me.pItemList[i]) then
      removeObject(me.pItemList[i])
    end if
  end repeat
  me.pItemList = []
end

on registerListener me, tid, tObjID, tMsgList
  if (tid.ilk <> #symbol) and (tid.ilk <> #string) then
    return error(me, "Invalid message header ID:" && tid, #registerListener)
  end if
  tObject = getObject(tObjID)
  if tObject = 0 then
    return error(me, "Object not found:" && tObjID, #registerListener)
  end if
  if voidp(pListenerList[tid]) then
    tPtr = getStructVariable("struct.pointer")
    tPtr.setaProp(#value, [:])
    pListenerList[tid] = tPtr
  else
    tPtr = pListenerList[tid]
  end if
  repeat with i = 1 to tMsgList.count
    tMsg = tMsgList.getPropAt(i)
    tMethod = tMsgList[i]
    if not tObject.handler(tMethod) then
      error(me, "Method not found:" && tMethod & "/" & tObjID, #registerListener)
      next repeat
    end if
    if voidp(tPtr.getaProp(#value).getaProp(tMsg)) then
      tPtr.getaProp(#value).setaProp(tMsg, [])
    end if
    tPtr.getaProp(#value).getaProp(tMsg).add([tObjID, tMethod])
  end repeat
  return 1
end

on unregisterListener me, tid, tObjID, tMsgList
  if (tid.ilk <> #symbol) and (tid.ilk <> #string) then
    return error(me, "Invalid message header ID:" && tid, #registerListener)
  end if
  tPtr = pListenerList[tid]
  if voidp(tPtr) then
    return 0
  end if
  tList = tPtr.getaProp(#value)
  repeat with i = 1 to tMsgList.count
    tMsg = tMsgList.getPropAt(i)
    tMethod = tMsgList[i]
    if voidp(tList.getaProp(tMsg)) then
      return error(me, "No listeners for message:" && tMsg && "/" && tid, #unregisterListener)
    end if
    repeat with j = 1 to tList.getaProp(tMsg).count
      tCallback = tList.getaProp(tMsg)[j]
      if (tCallback[1] = tObjID) and (tCallback[2] = tMethod) then
        tList.getaProp(tMsg).deleteAt(j)
        exit repeat
      end if
    end repeat
  end repeat
  return 1
end

on registerCommands me, tid, tObjID, tCmdList
  if (tid.ilk <> #symbol) and (tid.ilk <> #string) then
    return error(me, "Invalid message header ID:" && tid, #registerListener)
  end if
  if voidp(pCommandsList[tid]) then
    tPtr = getStructVariable("struct.pointer")
    tPtr.setaProp(#value, [:])
    pCommandsList[tid] = tPtr
  else
    tPtr = pCommandsList[tid]
  end if
  repeat with i = 1 to tCmdList.count
    tCmd = tCmdList.getPropAt(i)
    tNum = tCmdList[i]
    tOld = tPtr.getaProp(#value).getaProp(tCmd)
    tBy1 = numToChar(bitOr(64, tNum / 64))
    tBy2 = numToChar(bitOr(64, bitAnd(63, tNum)))
    tNew = tBy1 & tBy2
    if tOld <> VOID then
      if tOld <> tNew then
        error(me, "Registered command override:" && tCmd && "/" && tOld && "->" && tNew)
      end if
    end if
    tPtr.getaProp(#value).setaProp(tCmd, tNew)
  end repeat
  return 1
end

on unregisterCommands me, tid, tObjID, tCmdList
  if (tid.ilk <> #symbol) and (tid.ilk <> #string) then
    return error(me, "Invalid message header ID:" && tid, #registerListener)
  end if
  tPtr = pCommandsList[tid]
  if voidp(tPtr) then
    return 0
  end if
  return 1
end
