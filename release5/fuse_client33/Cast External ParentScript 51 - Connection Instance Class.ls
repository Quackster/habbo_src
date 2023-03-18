property pHost, pPort, pXtra, pMsgStruct, pConnectionOk, pConnectionSecured, pConnectionShouldBeKilled, pEncryptionOn, pDecoder, pLastContent, pContentChunk, pLogMode, pLogfield, pCommandsPntr, pListenersPntr

on construct me
  pEncryptionOn = 0
  pMsgStruct = getStructVariable("struct.message")
  pMsgStruct.setaProp(#connection, me.getID())
  pDecoder = 0
  pLastContent = EMPTY
  pConnectionShouldBeKilled = 0
  pCommandsPntr = getStructVariable("struct.pointer")
  pListenersPntr = getStructVariable("struct.pointer")
  me.setLogMode(getIntVariable("connection.log.level", 0))
  return 1
end

on deconstruct me
  return me.disconnect(1)
end

on connect me, tHost, tPort
  pHost = tHost
  pPort = tPort
  pXtra = new(xtra("Multiuser"))
  pXtra.setNetBufferLimits(16 * 1024, 100 * 1024, 100)
  tErrCode = pXtra.setNetMessageHandler(#xtraMsgHandler, me)
  if tErrCode = 0 then
    pXtra.connectToNetServer("*", "*", pHost, pPort, "*", 1)
  else
    return error(me, "Creation of callback failed:" && tErrCode, #connect)
  end if
  pLastContent = EMPTY
  if pLogMode > 0 then
    me.log("Connection initialized:" && me.getID() && pHost && pPort)
  end if
  return 1
end

on disconnect me, tControlled
  if tControlled <> 1 then
    me.forwardMsg(-1)
  end if
  pConnectionShouldBeKilled = 1
  if objectp(pXtra) then
    pXtra.sendNetMessage(0, 0, numToChar(0))
    pXtra.setNetMessageHandler(VOID, VOID)
  end if
  pXtra = VOID
  if not tControlled then
    error(me, "Connection disconnected:" && me.getID(), #disconnect)
  end if
  return 1
end

on connectionReady me
  return pConnectionOk and pConnectionSecured
end

on setDecoder me, tDecoder
  if not objectp(tDecoder) then
    return error(me, "Decoder object expected:" && tDecoder, #setDecoder)
  else
    pDecoder = tDecoder
    return 1
  end if
end

on getDecoder me
  return pDecoder
end

on setLogMode me, tMode
  if tMode.ilk <> #integer then
    return error(me, "Invalid argument:" && tMode, #setLogMode)
  end if
  pLogMode = tMode
  if pLogMode = 2 then
    if memberExists("connectionLog.text") then
      pLogfield = member(getmemnum("connectionLog.text"))
    else
      pLogfield = VOID
      pLogMode = 1
    end if
  end if
  return 1
end

on getLogMode me
  return pLogMode
end

on setEncryption me, tBoolean
  pEncryptionOn = tBoolean
  pConnectionSecured = 1
  return 1
end

on send me, tCmd, tMsg
  if tMsg.ilk = #propList then
    return me.sendNew(tCmd, tMsg)
  end if
  if not (pConnectionOk and objectp(pXtra)) then
    return error(me, "Connection not ready:" && me.getID(), #send)
  end if
  if tMsg.ilk <> #string then
    tMsg = string(tMsg)
  end if
  if tCmd.ilk <> #integer then
    tStr = tCmd
    tCmd = pCommandsPntr.getaProp(#value).getaProp(tStr)
  end if
  if tCmd.ilk = #void then
    return error(me, "Unrecognized command!", #send)
  end if
  if pLogMode > 0 then
    me.log("<--" && tStr && "(" & tCmd & ")" && tMsg)
  end if
  getObject(#session).set("con_lastsend", tStr && tMsg && "-" && the long time)
  if pEncryptionOn and objectp(pDecoder) then
    tMsg = pDecoder.encipher(tMsg)
  end if
  tLength = 0
  repeat with tChar = 1 to length(tMsg)
    tCharNum = charToNum(char tChar of tMsg)
    tLength = tLength + 1 + (tCharNum > 255)
  end repeat
  tL1 = numToChar(bitOr(bitAnd(tLength, 127), 128))
  tL2 = numToChar(bitOr(bitAnd(tLength / 128, 127), 128))
  tL3 = numToChar(bitOr(bitAnd(tLength / 16384, 127), 128))
  tMsg = tCmd & tL3 & tL2 & tL1 & tMsg
  pXtra.sendNetMessage(0, 0, tMsg)
  return 1
end

on sendNew me, tCmd, tParmArr
  if not (pConnectionOk and objectp(pXtra)) then
    return error(me, "Connection not ready:" && me.getID(), #send)
  end if
  tMsg = EMPTY
  tLength = 0
  if listp(tParmArr) then
    repeat with i = 1 to tParmArr.count
      ttype = tParmArr.getPropAt(i)
      tParm = tParmArr[i]
      case ttype of
        #string:
          tLen = 0
          repeat with tChar = 1 to length(tParm)
            tNum = charToNum(char tChar of tParm)
            tLen = tLen + 1 + (tNum > 255)
          end repeat
          tBy1 = numToChar(bitOr(128, tLen / 128))
          tBy2 = numToChar(bitOr(128, bitAnd(127, tLen)))
          tMsg = tMsg & tBy1 & tBy2 & tParm
          tLength = tLength + tLen + 2
        #integer:
          tBy1 = numToChar(bitOr(128, tParm / 32820))
          tBy2 = numToChar(bitOr(128, tParm / 16384))
          tBy3 = numToChar(bitOr(128, tParm / 128))
          tBy4 = numToChar(bitOr(128, bitAnd(127, tParm)))
          tMsg = tMsg & tBy1 & tBy2 & tBy3 & tBy4
          tLength = tLength + 4
        #short:
          tBy1 = numToChar(bitOr(128, tParm / 128))
          tBy2 = numToChar(bitOr(128, bitAnd(127, tParm)))
          tMsg = tMsg & tBy1 & tBy2
          tLength = tLength + 2
        otherwise:
          error(me, "Unsupported param type:" && tParm, #send)
      end case
    end repeat
  end if
  if tCmd.ilk <> #integer then
    tStr = tCmd
    tCmd = pCommandsPntr.getaProp(#value).getaProp(tStr)
  end if
  if tCmd.ilk = #void then
    return error(me, "Unrecognized command!", #send)
  end if
  if pLogMode > 0 then
    me.log("<--" && tStr && "(" & tCmd & ")" && tMsg)
  end if
  getObject(#session).set("con_lastsend", tStr && tMsg && "-" && the long time)
  if pEncryptionOn and objectp(pDecoder) then
    tMsg = pDecoder.encipher(tMsg)
    tLength = tLength * 2
  end if
  tL1 = numToChar(bitOr(bitAnd(tLength, 127), 128))
  tL2 = numToChar(bitOr(bitAnd(tLength / 128, 127), 128))
  tL3 = numToChar(bitOr(bitAnd(tLength / 16384, 127), 128))
  tMsg = tCmd & tL3 & tL2 & tL1 & tMsg
  pXtra.sendNetMessage(0, 0, tMsg)
  return 1
end

on getWaitingMessagesCount me
  return pXtra.getNumberWaitingNetMessages()
end

on processWaitingMessages me, tCount
  if voidp(tCount) then
    tCount = 1
  end if
  return pXtra.checkNetMessages(tCount)
end

on getProperty me, tProp
  case tProp of
    #xtra:
      return pXtra
    #host:
      return pHost
    #port:
      return pPort
    #decoder:
      return me.getDecoder()
    #logmode:
      return me.getLogMode()
    #listener:
      return pListenersPntr
    #commands:
      return pCommandsPntr
    #message:
      return pMsgStruct
  end case
  return 0
end

on setProperty me, tProp, tValue
  case tProp of
    #decoder:
      return me.setDecoder(tValue)
    #logmode:
      return me.setLogMode(tValue)
    #listener:
      if tValue.ilk = #struct then
        pListenersPntr = tValue
        return 1
      else
        return 0
      end if
    #commands:
      if tValue.ilk = #struct then
        pCommandsPntr = tValue
        return 1
      else
        return 0
      end if
  end case
  return 0
end

on print me
  tStr = EMPTY
  if symbolp(me.getID()) then
    put "#" after tStr
  end if
  put me.getID() & RETURN after tStr
  put "-- -- -- -- -- -- -- --" & RETURN after tStr
  tMsgsList = pListenersPntr.getaProp(#value)
  if listp(tMsgsList) then
    repeat with i = 1 to count(tMsgsList)
      put TAB & tMsgsList.getPropAt(i) & RETURN after tStr
      tCallbackList = tMsgsList[i]
      repeat with tCallback in tCallbackList
        put TAB & TAB & tCallback[1] && "->" && tCallback[2] & RETURN after tStr
      end repeat
      put RETURN after tStr
    end repeat
  end if
  put tStr & RETURN
  return 1
end

on GetIntFrom me, tByStrPtr
  tByteStr = tByStrPtr[1]
  tByte = bitAnd(charToNum(char 1 of tByteStr), 63)
  tByCnt = bitOr(bitAnd(tByte, 56) / 8, 0)
  tNeg = bitAnd(tByte, 4)
  tInt = bitAnd(tByte, 3)
  if tByCnt > 1 then
    tPowTbl = [4, 256, 16384, 1048576, 67108864]
    repeat with i = 2 to tByCnt
      tByte = bitAnd(charToNum(char i of tByteStr), 63)
      tInt = bitOr(tByte * tPowTbl[i - 1], tInt)
    end repeat
  end if
  if tNeg then
    tInt = -tInt
  end if
  tByStrPtr[1] = tByteStr.char[tByCnt + 1..length(tByteStr)]
  return tInt
end

on GetStrFrom me, tByStrPtr
  tLen = GetIntFrom(tByStrPtr)
  tArr = tByStrPtr[1]
  tStr = char 1 to tLen of tArr
  tByStrPtr[1] = char tLen + 1 to length(tArr) of tArr
  return tStr
end

on xtraMsgHandler me
  if pConnectionShouldBeKilled <> 0 then
    return 0
  end if
  pConnectionOk = 1
  tNewMsg = pXtra.getNetMessage()
  tErrCode = tNewMsg.getaProp(#errorCode)
  tContent = tNewMsg.getaProp(#content)
  if tErrCode <> 0 then
    if pLogMode > 0 then
      me.log("Connection" && me.getID() && "was disconnected")
      me.log("host = " & pHost && ", port = " & pPort)
      me.log(tNewMsg)
    end if
    me.disconnect()
    return 0
  end if
  me.msghandler(tContent)
end

on msghandler me, tContent
  if tContent.ilk <> #string then
    return 0
  end if
  if pLastContent.length > 0 then
    tContent = pLastContent & tContent
    pLastContent = EMPTY
  end if
  if tContent.length < 3 then
    pLastContent = pLastContent & tContent
    return 
  end if
  tByte1 = bitAnd(charToNum(char 2 of tContent), 63)
  tByte2 = bitAnd(charToNum(char 1 of tContent), 63)
  tMsgType = bitOr(tByte2 * 64, tByte1)
  tLength = offset("#", tContent)
  if tLength = 0 then
    pLastContent = tContent
    return 
  end if
  tParams = char 3 to tLength - 1 of tContent
  tContent = char tLength + 1 to tContent.length of tContent
  me.forwardMsg(tMsgType, tParams)
  if tContent.length > 0 then
    me.msghandler(tContent)
  end if
end

on forwardMsg me, tSubject, tParams
  if pLogMode > 0 then
    me.log("-->" && tSubject & RETURN & tParams)
  end if
  getObject(#session).set("con_lastreceived", tSubject && "-" && the long time)
  tParams = getStringServices().convertSpecialChars(tParams)
  tCallbackList = pListenersPntr.getaProp(#value).getaProp(tSubject)
  if tCallbackList.ilk <> #list then
    return error(me, "Listener not found:" && tSubject && "/" && me.getID(), #forwardMsg)
  end if
  tObjMgr = getObjectManager()
  repeat with i = 1 to count(tCallbackList)
    tCallback = tCallbackList[i]
    tObject = tObjMgr.get(tCallback[1])
    if tObject <> 0 then
      pMsgStruct.setaProp(#subject, tSubject)
      pMsgStruct.setaProp(#content, tParams)
      call(tCallback[2], tObject, pMsgStruct)
      next repeat
    end if
    error(me, "Listening obj not found, removed:" && tCallback[1], #forwardMsg)
    tCallbackList.deleteAt(1)
    i = i - 1
  end repeat
end

on log me, tMsg
  case pLogMode of
    1:
      put "[Connection" && me.getID() & "] :" && tMsg
    2:
      if ilk(pLogfield, #member) then
        put RETURN & "[Connection" && me.getID() & "] :" && tMsg after pLogfield
      end if
  end case
end
