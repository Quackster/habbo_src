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

on create me, tID, tHost, tPort
  if not symbolp(tID) and not stringp(tID) then
    return error(me, "Symbol or string expected:" && tID, #create, #major)
  end if
  if not stringp(tHost) then
    return error(me, "String expected:" && tHost, #create, #major)
  end if
  if not integerp(tPort) then
    return error(me, "Integer expected:" && tPort, #create, #major)
  end if
  if (getIntVariable("connection.log.level") = 2) and (the runMode contains "Author") then
    if not memberExists("connectionLog.text") then
      tLogField = member(createMember("connectionLog.text", #field))
      tLogField.boxType = #scroll
      tLogField.rect = rect(0, 0, 300, 250)
    else
      tLogField = member(getmemnum("connectionLog.text"))
    end if
    tLogField.text = tLogField.text & RETURN & "Connection logging" && tID & RETURN
  end if
  if not me.exists(tID) then
    if not createObject(tID, getClassVariable(pClassString)) then
      return error(me, "Failed to initialize connection:" && tID, #create, #major)
    end if
    me.pItemList.add(tID)
  end if
  if voidp(pListenerList[tID]) then
    tMsgPtr = getStructVariable("struct.pointer")
    tMsgPtr.setaProp(#value, [:])
    pListenerList[tID] = tMsgPtr
  else
    tMsgPtr = pListenerList[tID]
  end if
  if voidp(pCommandsList[tID]) then
    tCmdPtr = getStructVariable("struct.pointer")
    tCmdPtr.setaProp(#value, [:])
    pCommandsList[tID] = tCmdPtr
  else
    tCmdPtr = pCommandsList[tID]
  end if
  me.GET(tID).setProperty(#listener, tMsgPtr)
  me.GET(tID).setProperty(#commands, tCmdPtr)
  me.GET(tID).connect(tHost, tPort)
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

on registerListener me, tID, tObjID, tMsgList
  if (tID.ilk <> #symbol) and (tID.ilk <> #string) then
    return error(me, "Invalid message header ID:" && tID, #registerListener, #major)
  end if
  tObject = getObject(tObjID)
  if tObject = 0 then
    return error(me, "Object not found:" && tObjID, #registerListener, #major)
  end if
  if voidp(pListenerList[tID]) then
    tPtr = getStructVariable("struct.pointer")
    tPtr.setaProp(#value, [:])
    pListenerList[tID] = tPtr
  else
    tPtr = pListenerList[tID]
  end if
  repeat with i = 1 to tMsgList.count
    tMsg = tMsgList.getPropAt(i)
    tMethod = tMsgList[i]
    if not tObject.handler(tMethod) then
      error(me, "Method not found:" && tMethod & "/" & tObjID, #registerListener, #major)
      next repeat
    end if
    if voidp(tPtr.getaProp(#value).getaProp(tMsg)) then
      tPtr.getaProp(#value).setaProp(tMsg, [])
    end if
    tPtr.getaProp(#value).getaProp(tMsg).add([tObjID, tMethod])
  end repeat
  return 1
end

on unregisterListener me, tID, tObjID, tMsgList
  if (tID.ilk <> #symbol) and (tID.ilk <> #string) then
    return error(me, "Invalid message header ID:" && tID, #registerListener, #major)
  end if
  tPtr = pListenerList[tID]
  if voidp(tPtr) then
    return 0
  end if
  tList = tPtr.getaProp(#value)
  repeat with i = 1 to tMsgList.count
    tMsg = tMsgList.getPropAt(i)
    tMethod = tMsgList[i]
    if voidp(tList.getaProp(tMsg)) then
      error(me, "No listeners for message:" && tMsg && "/" && tID, #unregisterListener, #minor)
      next repeat
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

on registerCommands me, tID, tObjID, tCmdList
  if (tID.ilk <> #symbol) and (tID.ilk <> #string) then
    return error(me, "Invalid message header ID:" && tID, #registerListener, #major)
  end if
  if voidp(pCommandsList[tID]) then
    tPtr = getStructVariable("struct.pointer")
    tPtr.setaProp(#value, [:])
    pCommandsList[tID] = tPtr
  else
    tPtr = pCommandsList[tID]
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
        error(me, "Registered command override:" && tCmd && "/" && tOld && "->" && tNew, #minor)
      end if
    end if
    tPtr.getaProp(#value).setaProp(tCmd, tNew)
  end repeat
  return 1
end

on unregisterCommands me, tID, tObjID, tCmdList
  if (tID.ilk <> #symbol) and (tID.ilk <> #string) then
    return error(me, "Invalid message header ID:" && tID, #registerListener, #major)
  end if
  tPtr = pCommandsList[tID]
  if voidp(tPtr) then
    return 0
  end if
  return 1
end
