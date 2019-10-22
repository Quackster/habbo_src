property pListenerList, pCommandsList, pClassString, pLastMessageData

on construct me 
  pLastMessageData = [:]
  me.pItemList = []
  me.pItemList.sort()
  pListenerList = [:]
  pListenerList.sort()
  pCommandsList = [:]
  pCommandsList.sort()
  pClassString = "connection.instance.class"
  return TRUE
end

on create me, tID, tHost, tPort 
  if not symbolp(tID) and not stringp(tID) then
    return(error(me, "Symbol or string expected:" && tID, #create, #major))
  end if
  if not stringp(tHost) then
    return(error(me, "String expected:" && tHost, #create, #major))
  end if
  if not integerp(tPort) then
    return(error(me, "Integer expected:" && tPort, #create, #major))
  end if
  if (getIntVariable("connection.log.level") = 2) and the runMode contains "Author" then
    if not memberExists("connectionLog.text") then
      tLogField = member(createMember("connectionLog.text", #field))
      tLogField.boxType = #scroll
      tLogField.rect = rect(0, 0, 300, 250)
    else
      tLogField = member(getmemnum("connectionLog.text"))
    end if
    tLogField.text = tLogField.text & "\r" & "Connection logging" && tID & "\r"
  end if
  if not me.exists(tID) then
    if not createObject(tID, getClassVariable(pClassString)) then
      return(error(me, "Failed to initialize connection:" && tID, #create, #major))
    end if
    me.pItemList.add(tID)
  end if
  if voidp(pListenerList.getaProp(tID)) then
    tMsgPtr = getStructVariable("struct.pointer")
    tMsgPtr.setaProp(#value, [:])
    pListenerList.setAt(tID, tMsgPtr)
  else
    tMsgPtr = pListenerList.getaProp(tID)
  end if
  if voidp(pCommandsList.getaProp(tID)) then
    tCmdPtr = getStructVariable("struct.pointer")
    tCmdPtr.setaProp(#value, [:])
    pCommandsList.setAt(tID, tCmdPtr)
  else
    tCmdPtr = pCommandsList.getaProp(tID)
  end if
  me.GET(tID).setProperty(#listener, tMsgPtr)
  me.GET(tID).setProperty(#commands, tCmdPtr)
  me.GET(tID).connect(tHost, tPort)
  return TRUE
end

on closeAll me 
  i = 1
  repeat while i <= me.count(#pItemList)
    if objectExists(me.getProp(#pItemList, i)) then
      removeObject(me.getProp(#pItemList, i))
    end if
    i = (1 + i)
  end repeat
  me.pItemList = []
end

on registerListener me, tID, tObjID, tMsgList 
  if tID.ilk <> #symbol and tID.ilk <> #string then
    return(error(me, "Invalid message header ID:" && tID, #registerListener, #major))
  end if
  tObject = getObject(tObjID)
  if (tObject = 0) then
    return(error(me, "Object not found:" && tObjID, #registerListener, #major))
  end if
  if voidp(pListenerList.getaProp(tID)) then
    tPtr = getStructVariable("struct.pointer")
    tPtr.setaProp(#value, [:])
    pListenerList.setAt(tID, tPtr)
  else
    tPtr = pListenerList.getaProp(tID)
  end if
  i = 1
  repeat while i <= tMsgList.count
    tMsg = tMsgList.getPropAt(i)
    tMethod = tMsgList.getAt(i)
    if not tObject.handler(tMethod) then
      error(me, "Method not found:" && tMethod & "/" & tObjID, #registerListener, #major)
    else
      if voidp(tPtr.getaProp(#value).getaProp(tMsg)) then
        tPtr.getaProp(#value).setaProp(tMsg, [])
      end if
      tPtr.getaProp(#value).getaProp(tMsg).add([tObjID, tMethod])
    end if
    i = (1 + i)
  end repeat
  return TRUE
end

on unregisterListener me, tID, tObjID, tMsgList 
  if tID.ilk <> #symbol and tID.ilk <> #string then
    return(error(me, "Invalid message header ID:" && tID, #registerListener, #major))
  end if
  tPtr = pListenerList.getaProp(tID)
  if voidp(tPtr) then
    return FALSE
  end if
  tList = tPtr.getaProp(#value)
  i = 1
  repeat while i <= tMsgList.count
    tMsg = tMsgList.getPropAt(i)
    tMethod = tMsgList.getAt(i)
    if voidp(tList.getaProp(tMsg)) then
      error(me, "No listeners for message:" && tMsg && "/" && tID, #unregisterListener, #minor)
    else
      j = 1
      repeat while j <= tList.getaProp(tMsg).count
        tCallback = tList.getaProp(tMsg).getAt(j)
        if (tCallback.getAt(1) = tObjID) and (tCallback.getAt(2) = tMethod) then
          tList.getaProp(tMsg).deleteAt(j)
        else
          j = (1 + j)
        end if
      end repeat
    end if
    i = (1 + i)
  end repeat
  return TRUE
end

on registerCommands me, tID, tObjID, tCmdList 
  if tID.ilk <> #symbol and tID.ilk <> #string then
    return(error(me, "Invalid message header ID:" && tID, #registerListener, #major))
  end if
  if voidp(pCommandsList.getaProp(tID)) then
    tPtr = getStructVariable("struct.pointer")
    tPtr.setaProp(#value, [:])
    pCommandsList.setAt(tID, tPtr)
  else
    tPtr = pCommandsList.getaProp(tID)
  end if
  i = 1
  repeat while i <= tCmdList.count
    tCmd = tCmdList.getPropAt(i)
    tNum = tCmdList.getAt(i)
    tOld = tPtr.getaProp(#value).getaProp(tCmd)
    tBy1 = numToChar(bitOr(64, (tNum / 64)))
    tBy2 = numToChar(bitOr(64, bitAnd(63, tNum)))
    tNew = tBy1 & tBy2
    if tOld <> void() then
      if tOld <> tNew then
        error(me, "Registered command override:" && tCmd && "/" && tOld && "->" && tNew, #minor)
      end if
    end if
    tPtr.getaProp(#value).setaProp(tCmd, tNew)
    i = (1 + i)
  end repeat
  return TRUE
end

on unregisterCommands me, tID, tObjID, tCmdList 
  if tID.ilk <> #symbol and tID.ilk <> #string then
    return(error(me, "Invalid message header ID:" && tID, #registerListener, #major))
  end if
  tPtr = pCommandsList.getaProp(tID)
  if voidp(tPtr) then
    return FALSE
  end if
  return TRUE
end

on registerLastMessage me, tmessageId, tMessage 
  if voidp(pLastMessageData) then
    pLastMessageData = [:]
  end if
  pLastMessageData.setAt(#id, tmessageId)
  pLastMessageData.setAt(#message, tmessageId & "-" & tMessage & ";" & pLastMessageData.getAt(#message))
  pLastMessageData.setAt(#isParsed, 0)
  tMaximumLength = 128
  pLastMessageData.setAt(#message, chars(pLastMessageData.getAt(#message), 1, tMaximumLength))
end

on lastMessageParsed me 
  if voidp(pLastMessageData) then
    return FALSE
  end if
  pLastMessageData.setAt(#isParsed, 1)
end

on getLastMessageData me 
  return(pLastMessageData.duplicate())
end

on handlers  
  return([])
end
