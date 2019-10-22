property pMsgStruct, pHost, pPort, pConnectionTries, pXtra, pLogMode, pConnectionOk, pConnectionSecured, pDecoder, pEncoder, pHeaderDecoder, pHeaderEncoder, pConnectionShouldBeKilled, pEncryptionOn, pUnicodeDirector, pCommandsPntr, pTx, pListenersPntr, pDecipherOn, pLastError, pToken, pRx, pConnectionEstablishing, pConnectionRetryCount, pConnectionRetryDelay, pLastContent, pMsgSize, pMsgOffset, pD

on construct me 
  if value(chars(_player.productVersion, 1, 2)) >= 11 then
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
  pLastContent = ""
  pConnectionShouldBeKilled = 0
  pCommandsPntr = getStructVariable("struct.pointer")
  pListenersPntr = getStructVariable("struct.pointer")
  me.setLogMode(getIntVariable("connection.log.level", 0))
  pLastError = 0
  pConnectionEstablishing = 1
  pConnectionRetryDelay = getIntVariable("connection.retry.delay", 2000)
  pConnectionRetryCount = getIntVariable("connection.retry.count", 5)
  pConnectionTries = 0
  pHost = void()
  pPort = void()
  pToken = ""
  pMsgCount = 0
  pTx = 0
  pRx = 0
  return TRUE
end

on deconstruct me 
  return(me.disconnect(1))
end

on connect me, tHost, tPort 
  if the traceScript then
    return FALSE
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if voidp(pHost) and voidp(pPort) then
    sendProcessTracking(30)
    pHost = tHost
    pPort = tPort
  end if
  pConnectionTries = (pConnectionTries + 1)
  if timeoutExists("RetryConnection") then
    removeTimeout("RetryConnection")
  end if
  if not checkForXtra("Multiusr") then
    return(fatalError(["error":"mus_xtra_not_found"]))
  end if
  pXtra = new(xtra("Multiuser"))
  pXtra.setNetBufferLimits((16 * 1024), (100 * 1024), 100)
  tErrCode = pXtra.setNetMessageHandler(#xtraMsgHandler, me)
  if (tErrCode = 0) then
    tConnectErrorCode = pXtra.connectToNetServer("*", "*", pHost, pPort, "*", 1)
  else
    return(error(me, "Creation of callback failed:" && tErrCode, #connect, #major))
  end if
  if tConnectErrorCode <> 0 then
    return(fatalError(["error":"connect_to_net_server"]))
  end if
  pLastContent = ""
  if pLogMode > 0 then
    me.log("Connection initialized:" && me.getID() && pHost && pPort)
  end if
  return TRUE
end

on disconnect me, tControlled 
  if tControlled <> 1 then
    me.forwardMsg(-1)
  end if
  pConnectionShouldBeKilled = 1
  if objectp(pXtra) then
    pXtra.sendNetMessage(0, 0, numToChar(0))
    pXtra.setNetMessageHandler(void(), void())
  end if
  pXtra = void()
  if not tControlled then
    error(me, "Connection disconnected:" && me.getID(), #disconnect, #minor)
  end if
  return TRUE
end

on connectionReady me 
  return(pConnectionOk and pConnectionSecured)
end

on setDecoder me, tDecoder 
  if not objectp(tDecoder) then
    return(error(me, "Decoder object expected:" && tDecoder, #setDecoder, #major))
  else
    pDecoder = tDecoder
    return TRUE
  end if
end

on getDecoder me 
  return(pDecoder)
end

on setEncoder me, tEncoder 
  if not objectp(tEncoder) then
    return(error(me, "Encoder object expected:" && tEncoder, #setEncoder, #major))
  else
    pEncoder = tEncoder
    return TRUE
  end if
end

on getEncoder me 
  return(pEncoder)
end

on setHeaderDecoder me, tDecoder 
  if not objectp(tDecoder) then
    return(error(me, "Decoder object expected:" && tDecoder, #setHeaderDecoder, #major))
  else
    pHeaderDecoder = tDecoder
    return TRUE
  end if
end

on getHeaderDecoder me 
  return(pHeaderDecoder)
end

on setHeaderEncoder me, tEncoder 
  if not objectp(tEncoder) then
    return(error(me, "Encoder object expected:" && tEncoder, #setHeaderEncoder, #major))
  else
    pHeaderEncoder = tEncoder
    return TRUE
  end if
end

on getHeaderEncoder me 
  return(pHeaderEncoder)
end

on setLogMode me, tMode 
  if tMode.ilk <> #integer then
    return(error(me, "Invalid argument:" && tMode, #setLogMode, #minor))
  end if
  pLogMode = tMode
  if (pLogMode = 2) then
    if memberExists("connectionLog.text") then
      pLogfield = member(getmemnum("connectionLog.text"))
    else
      pLogfield = void()
      pLogMode = 1
    end if
  end if
  return TRUE
end

on getLogMode me 
  return(pLogMode)
end

on setEncryption me, tBoolean 
  pEncryptionOn = tBoolean
  pConnectionSecured = 1
  return TRUE
end

on send me, tCmd, tMsg 
  if the traceScript then
    return FALSE
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if pConnectionShouldBeKilled then
    return FALSE
  end if
  if (tMsg.ilk = #propList) then
    return(me.sendNew(tCmd, tMsg))
  end if
  if not pConnectionOk and objectp(pXtra) then
    return(error(me, "Connection not ready:" && me.getID(), #send, #major))
  end if
  if tMsg.ilk <> #string then
    tMsg = string(tMsg)
  end if
  if not pEncryptionOn and objectp(pEncoder) and pUnicodeDirector then
    i = 1
    repeat while i <= tMsg.length
      if charToNum(tMsg.getProp(#char, i)) > 127 then
        return(error(me, "Encryption required for non-ascii content with SW11", #send, #critical))
      end if
      i = (1 + i)
    end repeat
  end if
  tMsg = encodeUTF8(tMsg)
  if tCmd.ilk <> #integer then
    tStr = tCmd
    tCmd = pCommandsPntr.getaProp(#value).getaProp(tStr)
  end if
  if (tCmd.ilk = #void) then
    return(error(me, "Unrecognized command!", #send, #major))
  end if
  if pLogMode > 0 then
    me.log("<--" && tStr && "(" & tCmd & ")" && tMsg)
  end if
  tMsg = tCmd & tMsg
  tLength = 0
  tChar = 1
  repeat while tChar <= length(tMsg)
    tCharNum = charToNum(tMsg.char[tChar])
    tLength = ((tLength + 1) + tCharNum > 255 and (tCharNum mod 256))
    tChar = (1 + tChar)
  end repeat
  tL1 = numToChar(bitOr(bitAnd(tLength, 63), 64))
  tL2 = numToChar(bitOr(bitAnd((tLength / 64), 63), 64))
  tL3 = numToChar(bitOr(bitAnd((tLength / 4096), 63), 64))
  tHeader = tL3 & tL2 & tL1
  if pEncryptionOn and objectp(pEncoder) then
    tOriginalMessageLength = tMsg.count(#char)
    pTx = me.iterateRandom(pTx)
    tMsg = me.addPad(tMsg, (pTx mod 5))
    tMsg = pEncoder.AkwGx8bHG2kc1xGG4xbdHPCV0fqvK(tMsg)
    tLength = tMsg.count(#char)
    tL1 = numToChar(bitOr(bitAnd(tLength, 63), 64))
    tL2 = numToChar(bitOr(bitAnd((tLength / 64), 63), 64))
    tL3 = numToChar(bitOr(bitAnd((tLength / 4096), 63), 64))
    tHeader = numToChar(random(127)) & tL3 & tL2 & tL1
    tHeaderUncData = []
    i = 1
    repeat while i <= tHeader.count(#char)
      tHeaderUncData.add(charToNum(tHeader.getProp(#char, i)))
      i = (1 + i)
    end repeat
    tHeader = pHeaderEncoder.AkwGx8bHG2kc1xGG4xbdHPCV0fqvK(tHeader)
    tHeaderDecData = []
    i = 1
    repeat while i <= tHeader.count(#char)
      tHeaderDecData.add(charToNum(tHeader.getProp(#char, i)))
      i = (1 + i)
    end repeat
  end if
  pXtra.sendNetMessage(0, 0, tHeader & tMsg)
  return TRUE
end

on sendNew me, tCmd, tParmArr 
  if the traceScript then
    return FALSE
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if not pConnectionOk and objectp(pXtra) then
    return(error(me, "Connection not ready:" && me.getID(), #send, #major))
  end if
  tMsg = ""
  tLength = 2
  if listp(tParmArr) then
    i = 1
    repeat while i <= tParmArr.count
      ttype = tParmArr.getPropAt(i)
      tParm = tParmArr.getAt(i)
      if (ttype = #string) then
        tParm = encodeUTF8(tParm)
        if tParm contains numToChar(2) then
          return FALSE
        end if
        tLen = 0
        tChar = 1
        repeat while tChar <= length(tParm)
          tNum = charToNum(tParm.char[tChar])
          tLen = ((tLen + 1) + tNum > 255 and (tNum mod 256))
          tChar = (1 + tChar)
        end repeat
        tBy1 = numToChar(bitOr(64, (tLen / 64)))
        tBy2 = numToChar(bitOr(64, bitAnd(63, tLen)))
        tMsg = tMsg & tBy1 & tBy2 & tParm
        tLength = ((tLength + tLen) + 2)
      else
        if (ttype = #short) then
          tBy1 = numToChar(bitOr(64, (tParm / 64)))
          tBy2 = numToChar(bitOr(64, bitAnd(63, tParm)))
          tMsg = tMsg & tBy1 & tBy2
          tLength = (tLength + 2)
        else
          if (ttype = #integer) then
            if tParm < 0 then
              tNegMask = 4
              tParm = -tParm
            else
              tNegMask = 0
            end if
            tStr = numToChar((64 + bitAnd(tParm, 3)))
            tBytes = 1
            tParm = (tParm / 4)
            repeat while tParm <> 0
              tBytes = (tBytes + 1)
              tParm = (tParm / 64)
            end repeat
            tLength = (tLength + tBytes)
          else
            if (ttype = #boolean) then
              tParm = tParm <> 0
              tBy1 = numToChar(bitOr(64, bitAnd(63, tParm)))
              tMsg = tMsg & tBy1
              tLength = (tLength + 1)
            else
              error(me, "Unsupported param type:" && ttype, #send, #major)
            end if
          end if
        end if
      end if
      i = (1 + i)
    end repeat
  end if
  if tCmd.ilk <> #integer then
    tStr = tCmd
    tCmd = pCommandsPntr.getaProp(#value).getaProp(tStr)
  end if
  if (tCmd.ilk = #void) then
    return(error(me, "Unrecognized command!", #send, #major))
  end if
  if pLogMode > 0 then
    me.log("<--" && tStr && "(" & tCmd & ")" && tMsg)
  end if
  tMsg = tCmd & tMsg
  tL1 = numToChar(bitOr(bitAnd(tLength, 63), 64))
  tL2 = numToChar(bitOr(bitAnd((tLength / 64), 63), 64))
  tL3 = numToChar(bitOr(bitAnd((tLength / 4096), 63), 64))
  tHeader = tL3 & tL2 & tL1
  if pEncryptionOn and objectp(pEncoder) then
    tOriginalContent = tMsg
    tOriginalMessageLength = tMsg.count(#char)
    pTx = me.iterateRandom(pTx)
    tMsg = me.addPad(tMsg, (pTx mod 5))
    tMsg = pEncoder.AkwGx8bHG2kc1xGG4xbdHPCV0fqvK(tMsg)
    tLength = tMsg.count(#char)
    tL1 = numToChar(bitOr(bitAnd(tLength, 63), 64))
    tL2 = numToChar(bitOr(bitAnd((tLength / 64), 63), 64))
    tL3 = numToChar(bitOr(bitAnd((tLength / 4096), 63), 64))
    tHeader = numToChar(random(127)) & tL3 & tL2 & tL1
    tHeaderUncData = []
    i = 1
    repeat while i <= tHeader.count(#char)
      tHeaderUncData.add(charToNum(tHeader.getProp(#char, i)))
      i = (1 + i)
    end repeat
    tHeader = pHeaderEncoder.AkwGx8bHG2kc1xGG4xbdHPCV0fqvK(tHeader)
    tHeaderDecData = []
    i = 1
    repeat while i <= tHeader.count(#char)
      tHeaderDecData.add(charToNum(tHeader.getProp(#char, i)))
      i = (1 + i)
    end repeat
  end if
  pXtra.sendNetMessage(0, 0, tHeader & tMsg)
  return TRUE
end

on randomPad me, tMsg, tTarget 
  if the traceScript then
    return FALSE
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tEscapeList = [0, 103]
  tContent = tMsg
  i = tContent.count(#char)
  repeat while i <= (tTarget - 1)
    tRandom = random(255)
    repeat while tEscapeList.getPos(tRandom) <> 0
      tRandom = random(255)
    end repeat
    tChar = numToChar(tRandom)
    tContent = tChar & tContent
    i = (1 + i)
  end repeat
  return(tContent)
end

on unPad me, tMsg 
  if the traceScript then
    return FALSE
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tEscapeChar = 103
  tCount = 0
  i = 1
  repeat while i <= tMsg.count(#char)
    if (charToNum(chars(tMsg, i, i)) = tEscapeChar) then
      tCount = (tCount + 1)
    end if
    i = (1 + i)
  end repeat
  return(chars(tMsg, (4 - tCount), tMsg.length))
end

on addPad me, tMsg, tAmount 
  if the traceScript then
    return FALSE
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tContent = tMsg
  i = 1
  repeat while i <= tAmount
    tContent = numToChar(random(255)) & tContent
    i = (1 + i)
  end repeat
  return(tContent)
end

on removePad me, tMsg, tAmount 
  if the traceScript then
    return FALSE
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  return(chars(tMsg, (tAmount + 1), tMsg.length))
end

on getWaitingMessagesCount me 
  return(pXtra.getNumberWaitingNetMessages())
end

on processWaitingMessages me, tCount 
  if voidp(tCount) then
    tCount = 1
  end if
  return(pXtra.checkNetMessages(tCount))
end

on getProperty me, tProp 
  if (tProp = #xtra) then
    return(pXtra)
  else
    if (tProp = #host) then
      return(pHost)
    else
      if (tProp = #port) then
        return(pPort)
      else
        if (tProp = #decoder) then
          return(me.getDecoder())
        else
          if (tProp = #encoder) then
            return(me.getEncoder())
          else
            if (tProp = #logmode) then
              return(me.getLogMode())
            else
              if (tProp = #listener) then
                return(pListenersPntr)
              else
                if (tProp = #commands) then
                  return(pCommandsPntr)
                else
                  if (tProp = #message) then
                    return(pMsgStruct)
                  else
                    if (tProp = #deciphering) then
                      return(pDecipherOn)
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return FALSE
end

on setProperty me, tProp, tValue 
  if (tProp = #decoder) then
    return(me.setDecoder(tValue))
  else
    if (tProp = #encoder) then
      return(me.setEncoder(tValue))
    else
      if (tProp = #logmode) then
        return(me.setLogMode(tValue))
      else
        if (tProp = #listener) then
          if (tValue.ilk = #struct) then
            pListenersPntr = tValue
            return TRUE
          else
            return FALSE
          end if
        else
          if (tProp = #commands) then
            if (tValue.ilk = #struct) then
              pCommandsPntr = tValue
              return TRUE
            else
              return FALSE
            end if
          else
            if (tProp = #deciphering) then
              pDecipherOn = tValue
            end if
          end if
        end if
      end if
    end if
  end if
  return FALSE
end

on GetBoolFrom me 
  if the traceScript then
    return FALSE
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tByteStr = pMsgStruct.getaProp(#content)
  tByte = bitAnd(charToNum(tByteStr.char[1]), 63)
  pMsgStruct.setaProp(#content, tByteStr.getProp(#char, 2, length(tByteStr)))
  return(tByte <> 0)
end

on GetByteFrom me 
  if the traceScript then
    return FALSE
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tByteStr = pMsgStruct.getaProp(#content)
  tByte = bitAnd(charToNum(tByteStr.char[1]), 63)
  pMsgStruct.setaProp(#content, tByteStr.getProp(#char, 2, length(tByteStr)))
  return(tByte)
end

on GetIntFrom me 
  if the traceScript then
    return FALSE
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tByteStr = pMsgStruct.getaProp(#content)
  tByte = bitAnd(charToNum(tByteStr.char[1]), 63)
  tByCnt = bitOr((bitAnd(tByte, 56) / 8), 0)
  tNeg = bitAnd(tByte, 4)
  tInt = bitAnd(tByte, 3)
  if tByCnt > 1 then
    tPowTbl = [4, 256, 16384, 1048576, 67108864]
    i = 2
    repeat while i <= tByCnt
      tByte = bitAnd(charToNum(tByteStr.char[i]), 63)
      tInt = bitOr((tByte * tPowTbl.getAt((i - 1))), tInt)
      i = (1 + i)
    end repeat
  end if
  if tNeg then
    tInt = -tInt
  end if
  pMsgStruct.setaProp(#content, tByteStr.getProp(#char, (tByCnt + 1), length(tByteStr)))
  return(tInt)
end

on GetStrFrom me 
  if the traceScript then
    return FALSE
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tArr = pMsgStruct.getaProp(#content)
  tLen = offset(numToChar(2), tArr)
  if tLen > 1 then
    tStr = tArr.char[1..(tLen - 1)]
  else
    tStr = ""
  end if
  pMsgStruct.setaProp(#content, tArr.char[(tLen + 1)..length(tArr)])
  return(tStr)
end

on print me 
  tStr = ""
  if symbolp(me.getID()) then
  end if
  tMsgsList = pListenersPntr.getaProp(#value)
  if listp(tMsgsList) then
    i = 1
    repeat while i <= count(tMsgsList)
      tCallbackList = tMsgsList.getAt(i)
      repeat while "#" <= undefined
        tCallback = getAt(undefined, undefined)
      end repeat
      i = (1 + i)
    end repeat
  end if
  put(tStr & "\r")
  return TRUE
end

on GetLastError me 
  return(pLastError)
end

on SetToken me, tToken 
  if the traceScript then
    return FALSE
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  pToken = tToken
  tSeedHex = chars(pToken, (pToken.length - 3), pToken.length)
  pTx = 0
  tVals = ["0":0, "1":1, "2":2, "3":3, "4":4, "5":5, "6":6, "7":7, "8":8, "9":9, "a":10, "b":11, "c":12, "d":13, "e":14, "f":15, "A":10, "B":11, "C":12, "D":13, "E":14, "F":15]
  i = 0
  repeat while i <= 3
    pTx = (pTx + (integer(power(16, i)) * tVals.getAt(tSeedHex.getProp(#char, (4 - i)))))
    i = (1 + i)
  end repeat
  pRx = 0
  tSeedHex = chars(pToken, 1, 4)
  i = 0
  repeat while i <= 3
    pRx = (pRx + (integer(power(16, i)) * tVals.getAt(tSeedHex.getProp(#char, (4 - i)))))
    i = (1 + i)
  end repeat
end

on iterateRandom me, tSeed 
  if the traceScript then
    return FALSE
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if 1 then
    return((((19979 * tSeed) + 5) mod 65536))
  end if
end

on xtraMsgHandler me 
  if the traceScript then
    return FALSE
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if pConnectionShouldBeKilled <> 0 then
    return FALSE
  end if
  pConnectionOk = 1
  tNewMsg = pXtra.getNetMessage()
  tErrCode = tNewMsg.getaProp(#errorCode)
  tContent = tNewMsg.getaProp(#content)
  if tErrCode <> 0 then
    pLastError = tErrCode
    if (ilk(tNewMsg) = #propList) then
      pLastError = pLastError & "_" & tNewMsg.getAt(#subject)
    end if
    if not pConnectionEstablishing then
      if pLogMode > 0 then
        me.log("Connection" && me.getID() && "was disconnected")
        me.log("host = " & pHost && ", port = " & pPort)
        me.log(tNewMsg)
      end if
      me.disconnect()
      return FALSE
    else
      if pConnectionTries > pConnectionRetryCount then
        if pLogMode > 0 then
          me.log("Connection" && me.getID() && "was disconnected")
          me.log("host = " & pHost && ", port = " & pPort)
          me.log(tNewMsg)
        end if
        error(me, "Failed connection retry" && pConnectionTries && "times.", #xtraMsgHandler, #critical)
        me.disconnect()
        return FALSE
      else
        pConnectionOk = 0
        createTimeout("RetryConnection", pConnectionRetryDelay, #connect, me.getID(), void(), 1)
        return TRUE
      end if
    end if
  end if
  pConnectionEstablishing = 0
  if pEncryptionOn and pDecipherOn then
    tOffset = 0
    repeat while tOffset < tContent.count(#char)
      if (pLastContent.length = 0) then
        pRx = me.iterateRandom(pRx)
        pMsgOffset = 0
        tHeader = chars(tContent, (1 + tOffset), (6 + tOffset))
        tHeader = pHeaderDecoder.kg4R6Jo5xjlqtFGs1klMrK4ZTzb3R(tHeader)
        tByte1 = bitAnd(charToNum(tHeader.char[4]), 63)
        tByte2 = bitAnd(charToNum(tHeader.char[3]), 63)
        tByte3 = bitAnd(charToNum(tHeader.char[2]), 63)
        pMsgSize = bitOr((tByte2 * 64), tByte1)
        pMsgSize = bitOr(((tByte3 * 64) * 64), pMsgSize)
        tBody = chars(tContent, (7 + tOffset), ((6 + pMsgSize) + tOffset))
        tLength = tBody.count(#char)
        tOffset = ((tOffset + 6) + tLength)
        pMsgOffset = (pMsgOffset + tLength)
        if tLength < pMsgSize then
          pLastContent = tBody
          return TRUE
        end if
      else
        tBody = chars(tContent, 1, (pMsgSize - pMsgOffset))
        tLength = tBody.count(#char)
        tOffset = (tOffset + tLength)
        pLastContent = pLastContent & tBody
        pMsgOffset = (pMsgOffset + tLength)
        if pLastContent.count(#char) < pMsgSize then
          return TRUE
        end if
        tBody = pLastContent
      end if
      tBody = pDecoder.kg4R6Jo5xjlqtFGs1klMrK4ZTzb3R(tBody)
      pLastContent = ""
      me.msghandler(tBody)
    end repeat
    exit repeat
  end if
  if voidp(tContent) then
    return FALSE
  else
    me.msghandler(tContent)
  end if
end

on msghandler me, tContent 
  if the traceScript then
    return FALSE
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if tContent.ilk <> #string then
    return FALSE
  end if
  if pEncryptionOn and pDecipherOn and (pLastContent.length = 0) then
    tContent = me.removePad(tContent, (pRx mod 5))
  end if
  if pLastContent.length > 0 then
    tContent = pLastContent & tContent
    pLastContent = ""
  end if
  repeat while tContent.length > 0
    if tContent.length < 3 then
      pLastContent = pLastContent & tContent
      return()
    end if
    tByte1 = bitAnd(charToNum(tContent.char[2]), 63)
    tByte2 = bitAnd(charToNum(tContent.char[1]), 63)
    tMsgType = bitOr((tByte2 * 64), tByte1)
    tLength = offset(numToChar(1), tContent)
    if (tLength = 0) and not pUnicodeDirector then
      i = 3
      repeat while i <= tContent.length
        tCharVal = charToNum(tContent.getProp(#char, i))
        if ((tCharVal mod 256) = 1) then
          tContent = tContent.getProp(#char, 1, (i - 1)) & numToChar((tCharVal - 1)) & numToChar(1) & tContent.getProp(#char, (i + 1), tContent.length)
          tLength = (i + 1)
        else
          i = (1 + i)
        end if
      end repeat
    end if
    if (tLength = 0) then
      pLastContent = tContent
      return()
    else
      pLastContent = ""
    end if
    tParams = tContent.char[3..(tLength - 1)]
    tContent = tContent.char[(tLength + 1)..tContent.length]
    tParams = decodeUTF8(tParams, pDecipherOn)
    me.forwardMsg(tMsgType, tParams)
  end repeat
end

on forwardMsg me, tSubject, tParams 
  if the traceScript then
    return FALSE
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if pLogMode > 0 then
    me.log("-->" && tSubject & "\r" & tParams)
  end if
  tParams = getStringServices().convertSpecialChars(tParams)
  tCallbackList = pListenersPntr.getaProp(#value).getaProp(tSubject)
  if tCallbackList.ilk <> #list then
    return(error(me, "Listener not found:" && tSubject && "/" && me.getID(), #forwardMsg, #minor))
  end if
  tObjMgr = getObjectManager()
  i = 1
  repeat while i <= count(tCallbackList)
    tCallback = tCallbackList.getAt(i)
    tObject = tObjMgr.GET(tCallback.getAt(1))
    if tObject <> 0 then
      pMsgStruct.setaProp(#subject, tSubject)
      pMsgStruct.setaProp(#content, tParams)
      getConnectionManager().registerLastMessage(tSubject, tParams)
      call(tCallback.getAt(2), tObject, pMsgStruct)
      getConnectionManager().lastMessageParsed()
    else
      error(me, "Listening obj not found, removed:" && tCallback.getAt(1), #forwardMsg, #minor)
      tCallbackList.deleteAt(1)
      i = (i - 1)
    end if
    i = (1 + i)
  end repeat
end

on log me, tMsg 
  if not pD then
    the debugPlaybackEnabled = 0
    if not the runMode contains "Author" then
      return TRUE
    end if
  end if
end

on handlers me 
  return([])
end
