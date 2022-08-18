property pHost, pPort, pXtra, pMsgStruct, pConnectionOk, pConnectionSecured, pConnectionShouldBeKilled, pEncryptionOn, pDecoder, pEncoder, pHeaderDecoder, pHeaderEncoder, pLastContent, pContentChunk, pLogMode, pLogfield, pCommandsPntr, pListenersPntr, pDecipherOn, pD, pUnicodeDirector, pLastError, pConnectionEstablishing, pConnectionRetryDelay, pConnectionRetryCount, pConnectionTries, pMsgOffset, pMsgSize, pToken, pMsgCount, pTx, pRx, pHelloReceived, pDontProfile

on construct me
  if (value(chars(_player.productVersion, 1, 2)) >= 11) then
    pUnicodeDirector = 1
  else
    pUnicodeDirector = 0
  end if
  pDecipherOn = 0
  pEncryptionOn = 0
  pMsgStruct = getStructVariable("struct.message")
  pMsgStruct.setaProp(#connection, me)
  pMsgOffset = 0
  pMsgSize = 0
  pDecoder = 0
  pEncoder = 0
  pHeaderDecoder = 0
  pHeaderEncoder = 0
  pLastContent = EMPTY
  pConnectionShouldBeKilled = 0
  pCommandsPntr = getStructVariable("struct.pointer")
  pListenersPntr = getStructVariable("struct.pointer")
  me.setLogMode(getIntVariable("connection.log.level", 0))
  pLastError = 0
  pConnectionEstablishing = 1
  pConnectionRetryDelay = getIntVariable("connection.retry.delay", 2000)
  pConnectionRetryCount = getIntVariable("connection.retry.count", 5)
  pConnectionTries = 0
  pHost = VOID
  pPort = VOID
  pToken = EMPTY
  pMsgCount = 0
  pTx = 0
  pRx = 0
  pHelloReceived = 0
  pDontProfile = 1
  if (pDontProfile and getObjectManager().managerExists(#variable_manager)) then
    if variableExists("profile.network.enabled") then
      pDontProfile = 0
    end if
  end if
  return 1
end

on deconstruct me
  return me.disconnect(1)
end

on connect me, tHost, tPort
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  if (voidp(pHost) and voidp(pPort)) then
    sendProcessTracking(30)
    pHost = tHost
    pPort = tPort
  end if
  pConnectionTries = (pConnectionTries + 1)
  if timeoutExists("RetryConnection") then
    removeTimeout("RetryConnection")
  end if
  if not checkForXtra("Multiusr") then
    return fatalError(["error": "mus_xtra_not_found"])
  end if
  pXtra = new(xtra("Multiuser"))
  pXtra.setNetBufferLimits((16 * 1024), (100 * 1024), 100)
  tErrCode = pXtra.setNetMessageHandler(#xtraMsgHandler, me)
  if (tErrCode = 0) then
    tConnectErrorCode = pXtra.connectToNetServer("*", "*", pHost, pPort, "*", 1)
  else
    return error(me, ("Creation of callback failed:" && tErrCode), #connect, #major)
  end if
  if (tConnectErrorCode <> 0) then
    return fatalError(["error": "connect_to_net_server"])
  end if
  pLastContent = EMPTY
  if (pLogMode > 0) then
    me.log(((("Connection initialized:" && me.getID()) && pHost) && pPort))
  end if
  return 1
end

on disconnect me, tControlled
  if (tControlled <> 1) then
    me.forwardMsg(-1)
  end if
  pConnectionShouldBeKilled = 1
  if objectp(pXtra) then
    pXtra.sendNetMessage(0, 0, numToChar(0))
    pXtra.setNetMessageHandler(VOID, VOID)
  end if
  pXtra = VOID
  if not tControlled then
    error(me, ("Connection disconnected:" && me.getID()), #disconnect, #minor)
  end if
  return 1
end

on connectionReady me
  return (pConnectionOk and pConnectionSecured)
end

on setDecoder me, tDecoder
  if not objectp(tDecoder) then
    return error(me, ("Decoder object expected:" && tDecoder), #setDecoder, #major)
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
    return error(me, ("Encoder object expected:" && tEncoder), #setEncoder, #major)
  else
    pEncoder = tEncoder
    return 1
  end if
end

on getEncoder me
  return pEncoder
end

on setHeaderDecoder me, tDecoder
  if not objectp(tDecoder) then
    return error(me, ("Decoder object expected:" && tDecoder), #setHeaderDecoder, #major)
  else
    pHeaderDecoder = tDecoder
    return 1
  end if
end

on getHeaderDecoder me
  return pHeaderDecoder
end

on setHeaderEncoder me, tEncoder
  if not objectp(tEncoder) then
    return error(me, ("Encoder object expected:" && tEncoder), #setHeaderEncoder, #major)
  else
    pHeaderEncoder = tEncoder
    return 1
  end if
end

on getHeaderEncoder me
  return pHeaderEncoder
end

on setLogMode me, tMode
  if (tMode.ilk <> #integer) then
    return error(me, ("Invalid argument:" && tMode), #setLogMode, #minor)
  end if
  pLogMode = tMode
  if (pLogMode = 2) then
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
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  if pConnectionShouldBeKilled then
    return 0
  end if
  if (tMsg.ilk = #propList) then
    return me.sendNew(tCmd, tMsg)
  end if
  if not (pConnectionOk and objectp(pXtra)) then
    return error(me, ("Connection not ready:" && me.getID()), #send, #major)
  end if
  if (tMsg.ilk <> #string) then
    tMsg = string(tMsg)
  end if
  if (not (pEncryptionOn and objectp(pEncoder)) and pUnicodeDirector) then
    repeat with i = 1 to tMsg.length
      if (charToNum(tMsg.char[i]) > 127) then
        return error(me, "Encryption required for non-ascii content with SW11", #send, #critical)
      end if
    end repeat
  end if
  tMsg = encodeUTF8(tMsg)
  if (tCmd.ilk <> #integer) then
    tStr = tCmd
    tCmd = pCommandsPntr.getaProp(#value).getaProp(tStr)
  end if
  if (tCmd.ilk = #void) then
    return error(me, "Unrecognized command!", #send, #major)
  end if
  if (pLogMode > 0) then
    me.log(((((("<--" && tStr) && "(") & tCmd) & ")") && tMsg))
  end if
  tMsg = (tCmd & tMsg)
  tLength = 0
  repeat with tChar = 1 to length(tMsg)
    tCharNum = charToNum(char tChar of tMsg)
    tLength = ((tLength + 1) + ((tCharNum > 255) and (tCharNum mod 256)))
  end repeat
  tL1 = numToChar(bitOr(bitAnd(tLength, 63), 64))
  tL2 = numToChar(bitOr(bitAnd((tLength / 64), 63), 64))
  tL3 = numToChar(bitOr(bitAnd((tLength / 4096), 63), 64))
  tHeader = ((tL3 & tL2) & tL1)
  if (pEncryptionOn and objectp(pEncoder)) then
    tOriginalMessageLength = tMsg.char.count
    pTx = me.iterateRandom(pTx)
    tMsg = me.addPad(tMsg, (pTx mod 5))
    tMsg = pEncoder.AkwGx8bHG2kc1xGG4xbdHPCV0fqvK(tMsg)
    tLength = tMsg.char.count
    tL1 = numToChar(bitOr(bitAnd(tLength, 63), 64))
    tL2 = numToChar(bitOr(bitAnd((tLength / 64), 63), 64))
    tL3 = numToChar(bitOr(bitAnd((tLength / 4096), 63), 64))
    tHeader = (((numToChar(random(127)) & tL3) & tL2) & tL1)
    tHeaderUncData = []
    repeat with i = 1 to tHeader.char.count
      tHeaderUncData.add(charToNum(tHeader.char[i]))
    end repeat
    tHeader = pHeaderEncoder.AkwGx8bHG2kc1xGG4xbdHPCV0fqvK(tHeader)
    tHeaderDecData = []
    repeat with i = 1 to tHeader.char.count
      tHeaderDecData.add(charToNum(tHeader.char[i]))
    end repeat
  end if
  pXtra.sendNetMessage(0, 0, (tHeader & tMsg))
  return 1
end

on sendNew me, tCmd, tParmArr
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  if not (pConnectionOk and objectp(pXtra)) then
    return error(me, ("Connection not ready:" && me.getID()), #send, #major)
  end if
  tMsg = EMPTY
  tLength = 2
  if listp(tParmArr) then
    repeat with i = 1 to tParmArr.count
      ttype = tParmArr.getPropAt(i)
      tParm = tParmArr[i]
      case ttype of
        #string:
          tParm = encodeUTF8(tParm)
          if (tParm contains numToChar(2)) then
            return 0
          end if
          tLen = 0
          repeat with tChar = 1 to length(tParm)
            tNum = charToNum(char tChar of tParm)
            tLen = ((tLen + 1) + ((tNum > 255) and (tNum mod 256)))
          end repeat
          tBy1 = numToChar(bitOr(64, (tLen / 64)))
          tBy2 = numToChar(bitOr(64, bitAnd(63, tLen)))
          tMsg = (((tMsg & tBy1) & tBy2) & tParm)
          tLength = ((tLength + tLen) + 2)
        #short:
          tBy1 = numToChar(bitOr(64, (tParm / 64)))
          tBy2 = numToChar(bitOr(64, bitAnd(63, tParm)))
          tMsg = ((tMsg & tBy1) & tBy2)
          tLength = (tLength + 2)
        #integer, #boolean:
          if (ttype = #boolean) then
            tParm = (tParm <> 0)
          end if
          if (tParm < 0) then
            tNegMask = 4
            tParm = -tParm
          else
            tNegMask = 0
          end if
          tStr = numToChar((64 + bitAnd(tParm, 3)))
          tBytes = 1
          tParm = (tParm / 4)
          repeat while (tParm <> 0)
            tBytes = (tBytes + 1)
            put numToChar((64 + bitAnd(tParm, 63))) after tStr
            tParm = (tParm / 64)
          end repeat
          put numToChar(bitOr(bitOr(charToNum(char 1 of tStr), (tBytes * 8)), tNegMask)) after tMsg
          put chars(tStr, 2, tBytes) after tMsg
          tLength = (tLength + tBytes)
        otherwise:
          error(me, ("Unsupported param type:" && ttype), #send, #major)
      end case
    end repeat
  end if
  if (tCmd.ilk <> #integer) then
    tStr = tCmd
    tCmd = pCommandsPntr.getaProp(#value).getaProp(tStr)
  end if
  if (tCmd.ilk = #void) then
    return error(me, "Unrecognized command!", #send, #major)
  end if
  if (pLogMode > 0) then
    me.log(((((("<--" && tStr) && "(") & tCmd) & ")") && tMsg))
  end if
  tMsg = (tCmd & tMsg)
  tL1 = numToChar(bitOr(bitAnd(tLength, 63), 64))
  tL2 = numToChar(bitOr(bitAnd((tLength / 64), 63), 64))
  tL3 = numToChar(bitOr(bitAnd((tLength / 4096), 63), 64))
  tHeader = ((tL3 & tL2) & tL1)
  if (pEncryptionOn and objectp(pEncoder)) then
    tOriginalContent = tMsg
    tOriginalMessageLength = tMsg.char.count
    pTx = me.iterateRandom(pTx)
    tMsg = me.addPad(tMsg, (pTx mod 5))
    tMsg = pEncoder.AkwGx8bHG2kc1xGG4xbdHPCV0fqvK(tMsg)
    tLength = tMsg.char.count
    tL1 = numToChar(bitOr(bitAnd(tLength, 63), 64))
    tL2 = numToChar(bitOr(bitAnd((tLength / 64), 63), 64))
    tL3 = numToChar(bitOr(bitAnd((tLength / 4096), 63), 64))
    tHeader = (((numToChar(random(127)) & tL3) & tL2) & tL1)
    tHeaderUncData = []
    repeat with i = 1 to tHeader.char.count
      tHeaderUncData.add(charToNum(tHeader.char[i]))
    end repeat
    tHeader = pHeaderEncoder.AkwGx8bHG2kc1xGG4xbdHPCV0fqvK(tHeader)
    tHeaderDecData = []
    repeat with i = 1 to tHeader.char.count
      tHeaderDecData.add(charToNum(tHeader.char[i]))
    end repeat
  end if
  pXtra.sendNetMessage(0, 0, (tHeader & tMsg))
  return 1
end

on randomPad me, tMsg, tTarget
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  tEscapeList = [0, 103]
  tContent = tMsg
  repeat with i = tContent.char.count to (tTarget - 1)
    tRandom = random(255)
    repeat while (tEscapeList.getPos(tRandom) <> 0)
      tRandom = random(255)
    end repeat
    tChar = numToChar(tRandom)
    tContent = (tChar & tContent)
  end repeat
  return tContent
end

on unPad me, tMsg
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  tEscapeChar = 103
  tCount = 0
  repeat with i = 1 to tMsg.char.count
    if (charToNum(chars(tMsg, i, i)) = tEscapeChar) then
      tCount = (tCount + 1)
    end if
  end repeat
  return chars(tMsg, (4 - tCount), tMsg.length)
end

on addPad me, tMsg, tAmount
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  tContent = tMsg
  repeat with i = 1 to tAmount
    tContent = (numToChar(random(255)) & tContent)
  end repeat
  return tContent
end

on removePad me, tMsg, tAmount
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  return chars(tMsg, (tAmount + 1), tMsg.length)
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
      if (tValue.ilk = #struct) then
        pListenersPntr = tValue
        return 1
      else
        return 0
      end if
    #commands:
      if (tValue.ilk = #struct) then
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
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  tValue = me.GetIntFrom()
  return (tValue <> 0)
end

on GetByteFrom me
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  tByteStr = pMsgStruct.getaProp(#content)
  tByte = bitAnd(charToNum(char 1 of tByteStr), 63)
  pMsgStruct.setaProp(#content, tByteStr.char[2])
  return tByte
end

on GetIntFrom me
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  tByteStr = pMsgStruct.getaProp(#content)
  tByte = bitAnd(charToNum(char 1 of tByteStr), 63)
  tByCnt = bitOr((bitAnd(tByte, 56) / 8), 0)
  tNeg = bitAnd(tByte, 4)
  tInt = bitAnd(tByte, 3)
  if (tByCnt > 1) then
    tPowTbl = [4, 256, 16384, 1048576, 67108864]
    repeat with i = 2 to tByCnt
      tByte = bitAnd(charToNum(char i of tByteStr), 63)
      tInt = bitOr((tByte * tPowTbl[(i - 1)]), tInt)
    end repeat
  end if
  if tNeg then
    tInt = -tInt
  end if
  pMsgStruct.setaProp(#content, tByteStr.char[(tByCnt + 1)])
  return tInt
end

on GetStrFrom me
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  tArr = pMsgStruct.getaProp(#content)
  tLen = offset(numToChar(2), tArr)
  if (tLen > 1) then
    tStr = char 1 to (tLen - 1) of tArr
  else
    tStr = EMPTY
  end if
  pMsgStruct.setaProp(#content, char (tLen + 1) to length(tArr) of tArr)
  return tStr
end

on print me
  tStr = EMPTY
  if symbolp(me.getID()) then
    put "#" after tStr
  end if
  put (me.getID() & RETURN) after tStr
  put ("-- -- -- -- -- -- -- --" & RETURN) after tStr
  tMsgsList = pListenersPntr.getaProp(#value)
  if listp(tMsgsList) then
    repeat with i = 1 to count(tMsgsList)
      put ((TAB & tMsgsList.getPropAt(i)) & RETURN) after tStr
      tCallbackList = tMsgsList[i]
      repeat with tCallback in tCallbackList
        put (((((TAB & TAB) & tCallback[1]) && "->") && tCallback[2]) & RETURN) after tStr
      end repeat
      put RETURN after tStr
    end repeat
  end if
  put (tStr & RETURN)
  return 1
end

on GetLastError me
  return pLastError
end

on SetToken me, tToken
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  pToken = tToken
  tSeedHex = chars(pToken, (pToken.length - 3), pToken.length)
  pTx = 0
  tVals = ["0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "a": 10, "b": 11, "c": 12, "d": 13, "e": 14, "f": 15, "A": 10, "B": 11, "C": 12, "D": 13, "E": 14, "F": 15]
  repeat with i = 0 to 3
    pTx = (pTx + (integer(power(16, i)) * tVals[tSeedHex.char[(4 - i)]]))
  end repeat
  pRx = 0
  tSeedHex = chars(pToken, 1, 4)
  repeat with i = 0 to 3
    pRx = (pRx + (integer(power(16, i)) * tVals[tSeedHex.char[(4 - i)]]))
  end repeat
end

on iterateRandom me, tSeed
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  if 1 then
    return (((19979 * tSeed) + 5) mod 65536)
  end if
end

on xtraMsgHandler me
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  if not pDontProfile then
    startProfilingTask("Connection Instance::xtraMsgHandler")
  end if
  if (pConnectionShouldBeKilled <> 0) then
    return 0
  end if
  pConnectionOk = 1
  tNewMsg = pXtra.getNetMessage()
  tErrCode = tNewMsg.getaProp(#errorCode)
  tContent = tNewMsg.getaProp(#content)
  tSender = tNewMsg.getaProp(#senderID)
  tSubject = tNewMsg.getaProp(#subject)
  if (((tSender = "System") and (tSubject = "ConnectToNetServer")) and (tErrCode = 0)) then
    pConnectionEstablishing = 0
    pHelloReceived = 1
    me.forwardMsg(0, EMPTY)
  end if
  if (tErrCode <> 0) then
    pLastError = tErrCode
    if (ilk(tNewMsg) = #propList) then
      pLastError = ((pLastError & "_") & tNewMsg[#subject])
    end if
    if not pConnectionEstablishing then
      if (pLogMode > 0) then
        me.log((("Connection" && me.getID()) && "was disconnected"))
        me.log(((("host = " & pHost) && ", port = ") & pPort))
        me.log(tNewMsg)
      end if
      me.disconnect()
      return 0
    else
      if (pConnectionTries > pConnectionRetryCount) then
        if (pLogMode > 0) then
          me.log((("Connection" && me.getID()) && "was disconnected"))
          me.log(((("host = " & pHost) && ", port = ") & pPort))
          me.log(tNewMsg)
        end if
        error(me, (("Failed connection retry" && pConnectionTries) && "times."), #xtraMsgHandler, #critical)
        me.disconnect()
        return 0
      else
        pConnectionOk = 0
        createTimeout("RetryConnection", pConnectionRetryDelay, #connect, me.getID(), VOID, 1)
        return 1
      end if
    end if
  end if
  pConnectionEstablishing = 0
  if (pEncryptionOn and pDecipherOn) then
    tOffset = 0
    repeat while (tOffset < tContent.char.count)
      if (pLastContent.length = 0) then
        pRx = me.iterateRandom(pRx)
        pMsgOffset = 0
        tHeader = chars(tContent, (1 + tOffset), (6 + tOffset))
        tHeader = pHeaderDecoder.kg4R6Jo5xjlqtFGs1klMrK4ZTzb3R(tHeader)
        tByte1 = bitAnd(charToNum(char 4 of tHeader), 63)
        tByte2 = bitAnd(charToNum(char 3 of tHeader), 63)
        tByte3 = bitAnd(charToNum(char 2 of tHeader), 63)
        pMsgSize = bitOr((tByte2 * 64), tByte1)
        pMsgSize = bitOr(((tByte3 * 64) * 64), pMsgSize)
        tBody = chars(tContent, (7 + tOffset), ((6 + pMsgSize) + tOffset))
        tLength = tBody.char.count
        tOffset = ((tOffset + 6) + tLength)
        pMsgOffset = (pMsgOffset + tLength)
        if (tLength < pMsgSize) then
          pLastContent = tBody
          return 1
        end if
      else
        tBody = chars(tContent, 1, (pMsgSize - pMsgOffset))
        tLength = tBody.char.count
        tOffset = (tOffset + tLength)
        pLastContent = (pLastContent & tBody)
        pMsgOffset = (pMsgOffset + tLength)
        if (pLastContent.char.count < pMsgSize) then
          return 1
        end if
        tBody = pLastContent
      end if
      tBody = pDecoder.kg4R6Jo5xjlqtFGs1klMrK4ZTzb3R(tBody)
      pLastContent = EMPTY
      me.msghandler(tBody)
    end repeat
  else
    if voidp(tContent) then
      return 0
    else
      me.msghandler(tContent)
    end if
  end if
  if not pDontProfile then
    finishProfilingTask("Connection Instance::xtraMsgHandler")
  end if
end

on msghandler me, tContent
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  if (tContent.ilk <> #string) then
    return 0
  end if
  if ((pEncryptionOn and pDecipherOn) and (pLastContent.length = 0)) then
    tContent = me.removePad(tContent, (pRx mod 5))
  end if
  if (pLastContent.length > 0) then
    tContent = (pLastContent & tContent)
    pLastContent = EMPTY
  end if
  repeat while (tContent.length > 0)
    if (tContent.length < 3) then
      pLastContent = (pLastContent & tContent)
      return 
    end if
    tByte1 = bitAnd(charToNum(char 2 of tContent), 63)
    tByte2 = bitAnd(charToNum(char 1 of tContent), 63)
    tMsgType = bitOr((tByte2 * 64), tByte1)
    tLength = offset(numToChar(1), tContent)
    if ((tLength = 0) and not pUnicodeDirector) then
      repeat with i = 3 to tContent.length
        tCharVal = charToNum(tContent.char[i])
        if ((tCharVal mod 256) = 1) then
          tContent = (((tContent.char[1] & numToChar((tCharVal - 1))) & numToChar(1)) & tContent.char[(i + 1)])
          tLength = (i + 1)
          exit repeat
        end if
      end repeat
    end if
    if (tLength = 0) then
      pLastContent = tContent
      return 
    else
      pLastContent = EMPTY
    end if
    tParams = char 3 to (tLength - 1) of tContent
    tContent = char (tLength + 1) to tContent.length of tContent
    tParams = decodeUTF8(tParams, pDecipherOn)
    if ((tMsgType = 0) and pHelloReceived) then
      return 0
    end if
    me.forwardMsg(tMsgType, tParams)
  end repeat
end

on forwardMsg me, tSubject, tParams
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  if not pDontProfile then
    startProfilingTask("Connection Instance::forwardMsg")
  end if
  if (pLogMode > 0) then
    me.log(((("-->" && tSubject) & RETURN) & tParams))
  end if
  tParams = getStringServices().convertSpecialChars(tParams)
  tCallbackList = pListenersPntr.getaProp(#value).getaProp(tSubject)
  if (tCallbackList.ilk <> #list) then
    return error(me, ((("Listener not found:" && tSubject) && "/") && me.getID()), #forwardMsg, #minor)
  end if
  tObjMgr = getObjectManager()
  repeat with i = 1 to count(tCallbackList)
    tCallback = tCallbackList[i]
    tObject = tObjMgr.GET(tCallback[1])
    if (tObject <> 0) then
      pMsgStruct.setaProp(#subject, tSubject)
      pMsgStruct.setaProp(#content, tParams)
      getConnectionManager().registerLastMessage(tSubject, tParams)
      call(tCallback[2], tObject, pMsgStruct)
      getConnectionManager().lastMessageParsed()
      next repeat
    end if
    error(me, ("Listening obj not found, removed:" && tCallback[1]), #forwardMsg, #minor)
    tCallbackList.deleteAt(1)
    i = (i - 1)
  end repeat
  if not pDontProfile then
    finishProfilingTask("Connection Instance::forwardMsg")
  end if
end

on log me, tMsg
  if (_player.windowList.count > 0) then
    return stopMovie()
  end if
  the traceLogFile = EMPTY
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  if not pD then
    the debugPlaybackEnabled = 0
    if not (the runMode contains "Author") then
      return 1
    end if
  end if
end

on handlers me
  return []
end
