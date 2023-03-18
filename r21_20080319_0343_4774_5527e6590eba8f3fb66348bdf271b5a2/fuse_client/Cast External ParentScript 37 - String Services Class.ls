property pConvList, pDigits, pUsesUTF8, pUTF8ObjectName, pUTF8Object, pUnicodeDirector

on construct me
  pConvList = [:]
  pDigits = "0123456789ABCDEF"
  me.initConvList()
  pUsesUTF8 = VOID
  pUTF8ObjectName = "Localized UTF8 converter"
  if objectExists(pUTF8ObjectName) then
    pUTF8Object = getObject(pUTF8ObjectName)
    unregisterObject(pUTF8ObjectName)
  else
    pUTF8Object = VOID
  end if
  pUnicodeDirector = value(_player.productVersion) >= 11
  return 1
end

on convertToPropList me, tStr, tDelim
  tOldDelim = the itemDelimiter
  if tDelim = VOID then
    tDelim = ","
  end if
  the itemDelimiter = tDelim
  tProps = [:]
  repeat with i = 1 to tStr.item.count
    tPair = tStr.item[i].word[1..tStr.item[i].word.count]
    tProp = tPair.char[1..offset("=", tPair) - 1]
    tValue = tPair.char[offset("=", tPair) + 1..length(tStr)]
    tProps[tProp.word[1..tProp.word.count]] = tValue.word[1..tValue.word.count]
  end repeat
  the itemDelimiter = tOldDelim
  return tProps
end

on convertToLowerCase me, tString
  tValueStr = EMPTY
  repeat with i = 1 to length(tString)
    tChar = tString.char[i]
    tNum = charToNum(tChar)
    if (tNum >= 65) and (tNum <= 90) then
      tChar = numToChar(tNum + 32)
    end if
    tValueStr = tValueStr & tChar
  end repeat
  return tValueStr
end

on convertToHigherCase me, tString
  tValueStr = EMPTY
  repeat with i = 1 to length(tString)
    tChar = tString.char[i]
    tNum = charToNum(tChar)
    if (tNum >= 97) and (tNum <= 122) then
      tChar = numToChar(tNum - 32)
    end if
    tValueStr = tValueStr & tChar
  end repeat
  return tValueStr
end

on convertSpecialChars me, tString, tDirection
  tRetString = EMPTY
  tLength = tString.length
  if voidp(tDirection) then
    tDirection = 0
  end if
  if tDirection = 0 then
    repeat with pos = 1 to tLength
      tChar = char pos of tString
      tConv = pConvList[tChar]
      if not voidp(tConv) then
        put tConv after tRetString
        next repeat
      end if
      put tChar after tRetString
    end repeat
  else
    repeat with pos = 1 to tLength
      tChar = char pos of tString
      tPos = pConvList.getPos(tChar)
      if tPos > 0 then
        put pConvList.getPropAt(tPos) after tRetString
        next repeat
      end if
      put tChar after tRetString
    end repeat
  end if
  return tRetString
end

on convertIntToHex me, tInt
  if tInt <= 0 then
    return "00"
  else
    repeat while tInt > 0
      tD = tInt mod 16
      tInt = tInt / 16
      tHexstr = pDigits.char[tD + 1] & tHexstr
    end repeat
  end if
  if (length(tHexstr) mod 2) = 1 then
    tHexstr = "0" & tHexstr
  end if
  return tHexstr
end

on convertHexToInt me, tHex
  tBase = 1
  tValue = 0
  repeat while length(tHex) > 0
    tLc = the last char in tHex
    delete char -30000 of tHex
    tVl = offset(tLc, pDigits) - 1
    tValue = tValue + (tBase * tVl)
    tBase = tBase * 16
  end repeat
  return tValue
end

on explode me, tStr, tDelim, tLimit
  tList = []
  if voidp(tStr) then
    return tList
  end if
  if voidp(tLimit) then
    tLimit = the maxinteger
  end if
  tDelimLength = length(tDelim)
  repeat while 1
    tPos = offset(tDelim, tStr)
    if tPos = 0 then
      exit repeat
    end if
    tSubStr = tStr.char[1..tPos - 1]
    tList.add(tSubStr)
    delete char 1 to tPos + tDelimLength - 1 of tStr
    if tList.count = (tLimit - 1) then
      tList.add(tStr)
      return tList
    end if
  end repeat
  if tPos = 0 then
    tPos = 1 - tDelimLength
  end if
  tList.add(tStr.char[tPos + tDelimLength..length(tStr)])
  return tList
end

on implode me, tList, tDelim
  if voidp(tDelim) then
    return 0
  end if
  if voidp(tList) then
    return 0
  end if
  tStr = EMPTY
  repeat with tListItem in tList
    tStr = tStr & tListItem & tDelim
  end repeat
  tStr = chars(tStr, 1, tStr.length - tDelim.length)
  return tStr
end

on replaceChars me, tString, tCharA, tCharB
  if tCharA = tCharB then
    return tString
  end if
  repeat while offset(tCharA, tString) > 0
    put tCharB into char offset(tCharA, tString) of tString
  end repeat
  return tString
end

on replaceChunks me, tString, tChunkA, tChunkB
  tStr = EMPTY
  if voidp(tString) or voidp(tChunkA) or voidp(tChunkB) then
    error(me, "At least one of the parameters was void!", me.getID(), #replaceChunks, #minor)
    return tStr
  end if
  repeat while tString contains tChunkA
    tPos = offset(tChunkA, tString) - 1
    if tPos > 0 then
      put tString.char[1..tPos] after tStr
    end if
    put tChunkB after tStr
    delete tString.char[1..tPos + length(tChunkA)]
  end repeat
  put tString after tStr
  return tStr
end

on urlEncode me, tStr
  tEncodedStr = EMPTY
  tOkChars = "-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_"
  repeat with i = 1 to tStr.length
    tChar = tStr.char[i]
    if offset(tChar, tOkChars) then
      put tChar after tEncodedStr
      next repeat
    end if
    if tChar = SPACE then
      put "+" after tEncodedStr
      next repeat
    end if
    put "%" & rgb(charToNum(tChar), 0, 0).hexString().char[2..3] after tEncodedStr
  end repeat
  return tEncodedStr
end

on obfuscate me, tStr
  tResult = EMPTY
  repeat with i = 1 to tStr.length
    tNumber = charToNum(tStr.char[i])
    tNewNumber1 = bitAnd(tNumber, 15) * 2
    tNewNumber2 = bitAnd(tNumber, 240) / 8
    tRandom = random(6) + 1
    tNewNumber1 = tNewNumber1 + (bitAnd(tRandom, 6) * 16) + bitAnd(tRandom, 1)
    tRandom = random(6) + 1
    tNewNumber2 = tNewNumber2 + (bitAnd(tRandom, 6) * 16) + bitAnd(tRandom, 1)
    tResult = tResult & numToChar(tNewNumber2) & numToChar(tNewNumber1)
  end repeat
  return tResult
end

on deobfuscate me, tStr
  tResult = EMPTY
  repeat with i = 1 to tStr.length
    if i >= tStr.length then
      exit repeat
    end if
    tRawNumbers = [charToNum(tStr.char[i + 1]), charToNum(tStr.char[i])]
    tNumbers = [bitAnd(tRawNumbers[1], 30) / 2, bitAnd(tRawNumbers[2], 30) * 8]
    tNumber = bitOr(tNumbers[1], tNumbers[2])
    tResult = tResult & numToChar(tNumber)
    i = i + 1
  end repeat
  return tResult
end

on getLocalFloat me, tStrFloat
  if not stringp(tStrFloat) then
    return float(tStrFloat)
  end if
  if not (tStrFloat contains ".") then
    return float(tStrFloat)
  end if
  tStrFloatLocal = tStrFloat
  if not (value("1.2") > value("1.0")) then
    put "," into char offset(".", tStrFloat) of tStrFloatLocal
  end if
  return float(tStrFloatLocal)
end

on encodeUTF8 me, tStr
  if voidp(pUsesUTF8) then
    tVar = "client.textdata.utf8"
    if variableExists(tVar) then
      pUsesUTF8 = getVariableValue(tVar)
    else
      pUsesUTF8 = VOID
    end if
  end if
  if not pUsesUTF8 then
    return tStr
  end if
  tUnicodeData = me.convertToUnicode(tStr)
  tUTF8Data = []
  repeat with i = 1 to tUnicodeData.count
    tValue = tUnicodeData[i]
    if tValue < 128 then
      tUTF8Data.add(tValue)
      next repeat
    end if
    if tValue < 2048 then
      tUTF8Data.add(192 + bitAnd(tValue / 64, 31))
      tUTF8Data.add(128 + bitAnd(tValue, 63))
      next repeat
    end if
    if tValue < 65536 then
      tUTF8Data.add(224 + bitAnd(tValue / (64 * 64), 15))
      tUTF8Data.add(128 + bitAnd(tValue / 64, 63))
      tUTF8Data.add(128 + bitAnd(tValue, 63))
    end if
  end repeat
  tResult = me.generateStringFromUTF8(tUTF8Data)
  return tResult
end

on decodeUTF8 me, tStr, tForceDecode
  tVar = "client.textdata.utf8"
  if variableExists(tVar) then
    pUsesUTF8 = getVariableValue(tVar)
  else
    pUsesUTF8 = VOID
  end if
  if not pUsesUTF8 then
    return tStr
  end if
  if pUnicodeDirector and not tForceDecode then
    return tStr
  end if
  tBinData = []
  tCutPos = 1000
  repeat while tStr.length > 0
    if tStr.length >= tCutPos then
      tSubStr = tStr.char[1..tCutPos]
      tStr = tStr.char[tCutPos + 1..tStr.length]
    else
      tSubStr = tStr
      tStr = EMPTY
    end if
    tLength = tSubStr.length
    repeat with i = 1 to tLength
      tChar = tSubStr.char[i]
      tValue = charToNum(tChar)
      if tValue < 255 then
        tBinData.add(tValue)
        next repeat
      end if
      tBinData.add(tValue / 256)
      tBinData.add(tValue mod 256)
    end repeat
  end repeat
  if tBinData.count > 0 then
    if tBinData[tBinData.count] = 0 then
      tBinData.deleteAt(tBinData.count)
    end if
  end if
  tUnicodeData = []
  i = 1
  repeat while i <= tBinData.count
    tValue = tBinData[i]
    if tValue < 128 then
      tUnicodeData.add(tValue)
    else
      if tValue > 224 then
        if i <= (tBinData.count + 2) then
          tValue2 = tBinData[i + 1]
          tValue3 = tBinData[i + 2]
          tResVal = (((bitAnd(tValue, 15) * 64) + bitAnd(tValue2, 63)) * 64) + bitAnd(tValue3, 63)
          tUnicodeData.add(tResVal)
        end if
        i = i + 2
      else
        if tValue > 192 then
          if i <= (tBinData.count + 1) then
            tValue2 = tBinData[i + 1]
            tResVal = (bitAnd(tValue, 31) * 64) + bitAnd(tValue2, 63)
            tUnicodeData.add(tResVal)
          end if
          i = i + 1
        end if
      end if
    end if
    i = i + 1
  end repeat
  tResult = me.convertFromUnicode(tUnicodeData)
  return tResult
end

on convertToUnicode me, tStr
  if not pUnicodeDirector then
    if not voidp(pUTF8Object) then
      tdata = call(#convertToUnicode, [pUTF8Object], tStr)
      if ilk(tdata) = #list then
        return tdata
      end if
    end if
  end if
  tUnicodeData = []
  repeat with i = 1 to tStr.length
    tChar = tStr.char[i]
    tValue = charToNum(tChar)
    tUnicodeData.add(tValue)
  end repeat
  return tUnicodeData
end

on generateStringFromUTF8 me, tUTF8Data
  if not pUnicodeDirector then
    if not voidp(pUTF8Object) then
      tString = call(#generateStringFromUTF8, [pUTF8Object], tUTF8Data)
      if ilk(tString) = #string then
        return tString
      end if
    end if
  end if
  tResult = EMPTY
  repeat with i = 1 to tUTF8Data.count
    tResult = tResult & numToChar(tUTF8Data[i])
  end repeat
  return tResult
end

on convertFromUnicode me, tUnicodeData
  if not pUnicodeDirector then
    if not voidp(pUTF8Object) then
      tdata = call(#convertFromUnicode, [pUTF8Object], tUnicodeData)
      if ilk(tdata) = #string then
        return tdata
      end if
    end if
  end if
  tResult = EMPTY
  tCutPos = 1000
  i = 0
  repeat while i < tUnicodeData.count
    if (i + tCutPos) <= tUnicodeData.count then
      tCount = tCutPos
    else
      tCount = tUnicodeData.count - i
    end if
    tSubResult = EMPTY
    repeat with j = 1 to tCount
      tSubResult = tSubResult & numToChar(tUnicodeData[i + j])
    end repeat
    i = i + tCount
    tResult = tResult & tSubResult
  end repeat
  return tResult
end

on initConvList me
  if the platform contains "win" then
    tMachineType = ".win"
  else
    tMachineType = ".mac"
  end if
  pConvList = [:]
  tCharList = getVariableValue("char.conversion" & tMachineType, [:])
  repeat with i = 1 to tCharList.count
    tKey = tCharList.getPropAt(i)
    tVal = tCharList[i]
    if integerp(integer(tKey)) then
      tKey = numToChar(integer(tKey))
    end if
    if integerp(integer(tVal)) then
      tVal = numToChar(integer(tVal))
    end if
    pConvList[tKey] = tVal
  end repeat
  return 1
end
