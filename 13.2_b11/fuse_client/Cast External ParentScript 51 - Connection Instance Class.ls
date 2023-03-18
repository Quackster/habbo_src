property pHost, pPort, pXtra, pMsgStruct, pConnectionOk, pConnectionSecured, pConnectionShouldBeKilled, pEncryptionOn, pDecoder, pEncoder, pLastContent, pContentChunk, pLogMode, pLogfield, pCommandsPntr, pListenersPntr, pDecipherOn, pD

on construct me
  pDecipherOn = 0
  pEncryptionOn = 0
  pMsgStruct = getStructVariable("struct.message")
  pMsgStruct.setaProp(#connection, me)
  pDecoder = 0
  pEncoder = 0
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

on setEncoder me, tEncoder
  if not objectp(tEncoder) then
    return error(me, "Encoder object expected:" && tEncoder, #setEncoder)
  else
    pEncoder = tEncoder
    return 1
  end if
end

on getEncoder me
  return pEncoder
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
  if pConnectionShouldBeKilled then
    return 0
  end if
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
  tMsg = tCmd & tMsg
  tLength = 0
  repeat with tChar = 1 to length(tMsg)
    tCharNum = charToNum(char tChar of tMsg)
    tLength = tLength + 1 + (tCharNum > 255)
  end repeat
  tL1 = numToChar(bitOr(bitAnd(tLength, 63), 64))
  tL2 = numToChar(bitOr(bitAnd(tLength / 64, 63), 64))
  tL3 = numToChar(bitOr(bitAnd(tLength / 4096, 63), 64))
  tMsg = tL3 & tL2 & tL1 & tMsg
  if pEncryptionOn and objectp(pEncoder) then
    tMsg = pEncoder.encipher(tMsg)
  end if
  pXtra.sendNetMessage(0, 0, tMsg)
  return 1
end

on sendNew me, tCmd, tParmArr
  if not (pConnectionOk and objectp(pXtra)) then
    return error(me, "Connection not ready:" && me.getID(), #send)
  end if
  tMsg = EMPTY
  tLength = 2
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
          tBy1 = numToChar(bitOr(64, tLen / 64))
          tBy2 = numToChar(bitOr(64, bitAnd(63, tLen)))
          tMsg = tMsg & tBy1 & tBy2 & tParm
          tLength = tLength + tLen + 2
        #short:
          tBy1 = numToChar(bitOr(64, tParm / 64))
          tBy2 = numToChar(bitOr(64, bitAnd(63, tParm)))
          tMsg = tMsg & tBy1 & tBy2
          tLength = tLength + 2
        #integer:
          if tParm < 0 then
            tNegMask = 4
            tParm = -tParm
          else
            tNegMask = 0
          end if
          tStr = numToChar(64 + bitAnd(tParm, 3))
          tBytes = 1
          tParm = tParm / 4
          repeat while tParm <> 0
            tBytes = tBytes + 1
            put numToChar(64 + bitAnd(tParm, 63)) after tStr
            tParm = tParm / 64
          end repeat
          put numToChar(bitOr(bitOr(charToNum(char 1 of tStr), tBytes * 8), tNegMask)) after tMsg
          put chars(tStr, 2, tBytes) after tMsg
          tLength = tLength + tBytes
        #boolean:
          tParm = tParm <> 0
          tBy1 = numToChar(bitOr(64, bitAnd(63, tParm)))
          tMsg = tMsg & tBy1
          tLength = tLength + 1
        otherwise:
          error(me, "Unsupported param type:" && ttype, #send)
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
  tMsg = tCmd & tMsg
  tL1 = numToChar(bitOr(bitAnd(tLength, 63), 64))
  tL2 = numToChar(bitOr(bitAnd(tLength / 64, 63), 64))
  tL3 = numToChar(bitOr(bitAnd(tLength / 4096, 63), 64))
  tMsg = tL3 & tL2 & tL1 & tMsg
  if pEncryptionOn and objectp(pEncoder) then
    tMsg = pEncoder.encipher(tMsg)
  end if
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
    #encoder:
      return me.getEncoder()
    #logmode:
      return me.getLogMode()
    #listener:
      return pListenersPntr
    #commands:
      return pCommandsPntr
    #message:
      return pMsgStruct
    #deciphering:
      return pDecipherOn
  end case
  return 0
end

on setProperty me, tProp, tValue
  case tProp of
    #decoder:
      return me.setDecoder(tValue)
    #encoder:
      return me.setEncoder(tValue)
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
    #deciphering:
      pDecipherOn = tValue
  end case
  return 0
end

on GetBoolFrom me
  tByteStr = pMsgStruct.getaProp(#content)
  tByte = bitAnd(charToNum(char 1 of tByteStr), 63)
  pMsgStruct.setaProp(#content, tByteStr.char[2..length(tByteStr)])
  return tByte <> 0
end

on GetByteFrom me
  tByteStr = pMsgStruct.getaProp(#content)
  tByte = bitAnd(charToNum(char 1 of tByteStr), 63)
  pMsgStruct.setaProp(#content, tByteStr.char[2..length(tByteStr)])
  return tByte
end

on GetIntFrom me
  tByteStr = pMsgStruct.getaProp(#content)
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
  pMsgStruct.setaProp(#content, tByteStr.char[tByCnt + 1..length(tByteStr)])
  return tInt
end

on GetStrFrom me
  tArr = pMsgStruct.getaProp(#content)
  tLen = offset(numToChar(2), tArr)
  if tLen > 1 then
    tStr = char 1 to tLen - 1 of tArr
  else
    tStr = EMPTY
  end if
  pMsgStruct.setaProp(#content, char tLen + 1 to length(tArr) of tArr)
  return tStr
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
  if pEncryptionOn and pDecipherOn then
    tContent = pDecoder.decipher(tContent)
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
  tLength = offset(numToChar(1), tContent)
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
  tParams = getStringServices().convertSpecialChars(tParams)
  tCallbackList = pListenersPntr.getaProp(#value).getaProp(tSubject)
  if tCallbackList.ilk <> #list then
    return error(me, "Listener not found:" && tSubject && "/" && me.getID(), #forwardMsg)
  end if
  tObjMgr = getObjectManager()
  repeat with i = 1 to count(tCallbackList)
    tCallback = tCallbackList[i]
    tObject = tObjMgr.GET(tCallback[1])
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
  if not pD then
    the debugPlaybackEnabled = 0
    if not (the runMode contains "Author") then
      return 1
    end if
  end if
  case pLogMode of
    1:
      put "[Connection" && me.getID() & "] :" && tMsg
    2:
      if not (the runMode contains "Author") then
        return 1
      end if
      if ilk(pLogfield, #member) then
        put RETURN & "[Connection" && me.getID() & "] :" && tMsg after pLogfield
      end if
    3:
      executeMessage(#logdata, tMsg)
  end case
end
