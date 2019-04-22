property pConvList, pDigits, pUsesUTF8, pUnicodeDirector

on construct me 
  pConvList = [:]
  pDigits = "0123456789ABCDEF"
  pUsesUTF8 = void()
  if value(chars(_player.productVersion, 1, 2)) >= 11 then
    pUnicodeDirector = 1
  else
    pUnicodeDirector = 0
  end if
  me.initConvList()
  return(1)
end

on getUTF8ObjInstance me 
  tUTF8ObjectName = "Localized UTF8 converter"
  tutf8convclassname = "UTF8 To Locale Class"
  if objectExists(tUTF8ObjectName) then
    tUTF8Object = getObject(tUTF8ObjectName)
  else
    if variableExists("local.utf8.conversion") then
      tConversionFormat = getVariable("local.utf8.conversion")
      tUTF8Object = createObject(tUTF8ObjectName, tutf8convclassname)
      if not tUTF8Object = void() then
        tUTF8Object.defineLocale(tConversionFormat)
      end if
    else
      return(void())
    end if
  end if
  return(tUTF8Object)
end

on convertToPropList me, tStr, tDelim 
  tOldDelim = the itemDelimiter
  if tDelim = void() then
    tDelim = ","
  end if
  the itemDelimiter = tDelim
  tProps = [:]
  i = 1
  repeat while i <= tStr.count(#item)
    tPair = tStr.getPropRef(#item, i).getProp(#word, 1, tStr.getPropRef(#item, i).count(#word))
    tProp = tPair.getProp(#char, 1, offset("=", tPair) - 1)
    tValue = tPair.getProp(#char, offset("=", tPair) + 1, length(tStr))
    tProps.setAt(tProp.getProp(#word, 1, tProp.count(#word)), tValue.getProp(#word, 1, tValue.count(#word)))
    i = 1 + i
  end repeat
  the itemDelimiter = tOldDelim
  return(tProps)
end

on convertToLowerCase me, tString 
  tValueStr = ""
  i = 1
  repeat while i <= length(tString)
    tChar = tString.getProp(#char, i)
    tNum = charToNum(tChar)
    if tNum >= 65 and tNum <= 90 then
      tChar = numToChar(tNum + 32)
    end if
    tValueStr = tValueStr & tChar
    i = 1 + i
  end repeat
  return(tValueStr)
end

on convertToHigherCase me, tString 
  tValueStr = ""
  i = 1
  repeat while i <= length(tString)
    tChar = tString.getProp(#char, i)
    tNum = charToNum(tChar)
    if tNum >= 97 and tNum <= 122 then
      tChar = numToChar(tNum - 32)
    end if
    tValueStr = tValueStr & tChar
    i = 1 + i
  end repeat
  return(tValueStr)
end

on convertSpecialChars me, tString, tDirection 
  tRetString = ""
  tLength = tString.length
  if voidp(tDirection) then
    tDirection = 0
  end if
  if tDirection = 0 then
    pos = 1
    repeat while pos <= tLength
      tChar = tString.char[pos]
      tConv = pConvList.getAt(tChar)
      if not voidp(tConv) then
      else
      end if
      pos = 1 + pos
    end repeat
    exit repeat
  end if
  pos = 1
  repeat while pos <= tLength
    tChar = tString.char[pos]
    tPos = pConvList.getPos(tChar)
    if tPos > 0 then
    else
    end if
    pos = 1 + pos
  end repeat
  return(tRetString)
end

on convertIntToHex me, tInt 
  if tInt <= 0 then
    return("00")
  else
    repeat while tInt > 0
      tD = tInt mod 16
      tInt = tInt / 16
      tHexstr = pDigits.getProp(#char, tD + 1) & tHexstr
    end repeat
  end if
  if length(tHexstr) mod 2 = 1 then
    tHexstr = "0" & tHexstr
  end if
  return(tHexstr)
end

on convertHexToInt me, tHex 
  tBase = 1
  tValue = 0
  repeat while length(tHex) > 0
    tLc = the last char in tHex
    tVl = offset(tLc, pDigits) - 1
    tValue = tValue + tBase * tVl
    tBase = tBase * 16
  end repeat
  return(tValue)
end

on explode me, tStr, tDelim, tLimit 
  tList = []
  if voidp(tStr) then
    return(tList)
  end if
  if voidp(tLimit) then
    tLimit = the maxinteger
  end if
  tDelimLength = length(tDelim)
  repeat while 1
    tPos = offset(tDelim, tStr)
    if tPos = 0 then
    else
      tSubStr = tStr.getProp(#char, 1, tPos - 1)
      tList.add(tSubStr)
      if tList.count = tLimit - 1 then
        tList.add(tStr)
        return(tList)
      end if
    end if
  end repeat
  if tPos = 0 then
    tPos = 1 - tDelimLength
  end if
  tList.add(tStr.getProp(#char, tPos + tDelimLength, length(tStr)))
  return(tList)
end

on implode me, tList, tDelim 
  if voidp(tDelim) then
    return(0)
  end if
  if voidp(tList) then
    return(0)
  end if
  tStr = ""
  repeat while tList <= tDelim
    tListItem = getAt(tDelim, tList)
    tStr = tStr & tListItem & tDelim
  end repeat
  tStr = chars(tStr, 1, tStr.length - tDelim.length)
  return(tStr)
end

on replaceChars me, tString, tCharA, tCharB 
  if tCharA = tCharB then
    return(tString)
  end if
  repeat while offset(tCharA, tString) > 0
  end repeat
  return(tString)
end

on replaceChunks me, tString, tChunkA, tChunkB 
  tStr = ""
  if voidp(tString) or voidp(tChunkA) or voidp(tChunkB) then
    error(me, "At least one of the parameters was void!", me.getID(), #replaceChunks, #minor)
    return(tStr)
  end if
  repeat while tString contains tChunkA
    tPos = offset(tChunkA, tString) - 1
    if tPos > 0 then
    end if
    tPos + length(tChunkA).getPropRef().delete()
  end repeat
  return(tStr)
end

on urlEncode me, tStr 
  tEncodedStr = ""
  tOkChars = "-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_"
  i = 1
  repeat while i <= tStr.length
    tChar = tStr.getProp(#char, i)
    if offset(tChar, tOkChars) then
    else
      if tChar = space() then
      else
      end if
    end if
    i = 1 + i
  end repeat
  return(tEncodedStr)
end

on obfuscate me, tStr 
  tResult = ""
  i = 1
  repeat while i <= tStr.length
    tNumber = charToNum(tStr.getProp(#char, i))
    tNewNumber1 = bitAnd(tNumber, 15) * 2
    tNewNumber2 = bitAnd(tNumber, 240) / 8
    tRandom = random(6) + 1
    tNewNumber1 = tNewNumber1 + bitAnd(tRandom, 6) * 16 + bitAnd(tRandom, 1)
    tRandom = random(6) + 1
    tNewNumber2 = tNewNumber2 + bitAnd(tRandom, 6) * 16 + bitAnd(tRandom, 1)
    tResult = tResult & numToChar(tNewNumber2) & numToChar(tNewNumber1)
    i = 1 + i
  end repeat
  return(tResult)
end

on deobfuscate me, tStr 
  tResult = ""
  i = 1
  repeat while i <= tStr.length
    if i >= tStr.length then
    else
      tRawNumbers = [charToNum(tStr.getProp(#char, i + 1)), charToNum(tStr.getProp(#char, i))]
      tNumbers = [bitAnd(tRawNumbers.getAt(1), 30) / 2, bitAnd(tRawNumbers.getAt(2), 30) * 8]
      tNumber = bitOr(tNumbers.getAt(1), tNumbers.getAt(2))
      tResult = tResult & numToChar(tNumber)
      i = i + 1
      i = 1 + i
    end if
  end repeat
  return(tResult)
end

on getLocalFloat me, tStrFloat 
  if not stringp(tStrFloat) then
    return(float(tStrFloat))
  end if
  if not tStrFloat contains "." then
    return(float(tStrFloat))
  end if
  tStrFloatLocal = tStrFloat
  if not value("1.2") > value("1.0") then
  end if
  return(float(tStrFloatLocal))
end

on encodeUTF8 me, tStr 
  if voidp(pUsesUTF8) then
    tVar = "client.textdata.utf8"
    if variableExists(tVar) then
      pUsesUTF8 = getVariableValue(tVar)
    else
      pUsesUTF8 = void()
    end if
  end if
  if not pUsesUTF8 then
    return(tStr)
  end if
  tUnicodeData = me.convertToUnicode(tStr)
  tUTF8Data = []
  i = 1
  repeat while i <= tUnicodeData.count
    tValue = tUnicodeData.getAt(i)
    if tValue < 128 then
      tUTF8Data.add(tValue)
    else
      if tValue < 2048 then
        tUTF8Data.add(192 + bitAnd(tValue / 64, 31))
        tUTF8Data.add(128 + bitAnd(tValue, 63))
      else
        if tValue < 65536 then
          tUTF8Data.add(224 + bitAnd(tValue / 64 * 64, 15))
          tUTF8Data.add(128 + bitAnd(tValue / 64, 63))
          tUTF8Data.add(128 + bitAnd(tValue, 63))
        end if
      end if
    end if
    i = 1 + i
  end repeat
  tResult = me.generateStringFromUTF8(tUTF8Data)
  return(tResult)
end

on decodeUTF8 me, tStr, tForceDecode 
  startProfilingTask("DecodeUTF8")
  if voidp(pUsesUTF8) then
    tVar = "client.textdata.utf8"
    if variableExists(tVar) then
      pUsesUTF8 = getIntVariable(tVar)
    else
      pUsesUTF8 = void()
    end if
  end if
  if not pUsesUTF8 then
    return(tStr)
  end if
  if pUnicodeDirector and not tForceDecode then
    return(tStr)
  end if
  tUTF8Obj = me.getUTF8ObjInstance()
  tBinData = []
  tCutPos = 1000
  repeat while tStr.length > 0
    if tStr.length >= tCutPos then
      tSubStr = tStr.getProp(#char, 1, tCutPos)
      tStr = tStr.getProp(#char, tCutPos + 1, tStr.length)
    else
      tSubStr = tStr
      tStr = ""
    end if
    tLength = tSubStr.length
    i = 1
    repeat while i <= tLength
      tChar = tSubStr.getProp(#char, i)
      tValue = charToNum(tChar)
      if tValue < 255 then
        tBinData.add(tValue)
      else
        tBinData.add(tValue / 256)
        if tValue mod 256 <> 0 then
          tBinData.add(tValue mod 256)
        end if
      end if
      i = 1 + i
    end repeat
  end repeat
  tUnicodeData = []
  i = 1
  repeat while i <= tBinData.count
    tValue = tBinData.getAt(i)
    if tValue < 128 then
      tUnicodeData.add(tValue)
    else
      if tValue > 224 then
        if i + 2 <= tBinData.count then
          tValue2 = tBinData.getAt(i + 1)
          tValue3 = tBinData.getAt(i + 2)
          tResVal = bitAnd(tValue, 15) * 64 + bitAnd(tValue2, 63) * 64 + bitAnd(tValue3, 63)
          tUnicodeData.add(tResVal)
        end if
        i = i + 2
      else
        if tValue > 192 then
          if i + 1 <= tBinData.count then
            tValue2 = tBinData.getAt(i + 1)
            tResVal = bitAnd(tValue, 31) * 64 + bitAnd(tValue2, 63)
            tUnicodeData.add(tResVal)
          end if
          i = i + 1
        end if
      end if
    end if
    i = i + 1
  end repeat
  tResult = me.convertFromUnicode(tUnicodeData)
  finishProfilingTask("DecodeUTF8")
  return(tResult)
end

on convertToUnicode me, tStr 
  if not pUnicodeDirector then
    tUTF8Object = me.getUTF8ObjInstance()
    if not voidp(tUTF8Object) then
      tdata = call(#convertToUnicode, [tUTF8Object], tStr)
      if ilk(tdata) = #list then
        return(tdata)
      end if
    end if
  end if
  tUnicodeData = []
  i = 1
  repeat while i <= tStr.length
    tChar = tStr.getProp(#char, i)
    tValue = charToNum(tChar)
    tUnicodeData.add(tValue)
    i = 1 + i
  end repeat
  return(tUnicodeData)
end

on generateStringFromUTF8 me, tUTF8Data 
  if not pUnicodeDirector then
    tUTF8Object = me.getUTF8ObjInstance()
    if not voidp(tUTF8Object) then
      tString = call(#generateStringFromUTF8, [tUTF8Object], tUTF8Data)
      if ilk(tString) = #string then
        return(tString)
      end if
    end if
  end if
  tResult = ""
  i = 1
  repeat while i <= tUTF8Data.count
    tResult = tResult & numToChar(tUTF8Data.getAt(i))
    i = 1 + i
  end repeat
  return(tResult)
end

on convertFromUnicode me, tUnicodeData 
  if not pUnicodeDirector then
    tUTF8Object = me.getUTF8ObjInstance()
    if not voidp(tUTF8Object) then
      tdata = call(#convertFromUnicode, [tUTF8Object], tUnicodeData)
      if ilk(tdata) = #string then
        return(tdata)
      end if
    end if
  end if
  tResult = ""
  tCutPos = 1000
  i = 0
  repeat while i < tUnicodeData.count
    if i + tCutPos <= tUnicodeData.count then
      tCount = tCutPos
    else
      tCount = tUnicodeData.count - i
    end if
    tSubResult = ""
    j = 1
    repeat while j <= tCount
      tSubResult = tSubResult & numToChar(tUnicodeData.getAt(i + j))
      j = 1 + j
    end repeat
    i = i + tCount
    tResult = tResult & tSubResult
  end repeat
  return(tResult)
end

on initConvList me 
  if pUnicodeDirector then
    setVariable("char.conversion.mac", [:])
    setVariable("char.conversion.win", [:])
    return(1)
  end if
  if the platform contains "win" then
    tMachineType = ".win"
  else
    tMachineType = ".mac"
  end if
  pConvList = [:]
  tCharList = getVariableValue("char.conversion" & tMachineType, [:])
  i = 1
  repeat while i <= tCharList.count
    tKey = tCharList.getPropAt(i)
    tVal = tCharList.getAt(i)
    if integerp(integer(tKey)) then
      tKey = numToChar(integer(tKey))
    end if
    if integerp(integer(tVal)) then
      tVal = numToChar(integer(tVal))
    end if
    pConvList.setAt(tKey, tVal)
    i = 1 + i
  end repeat
  return(1)
end

on handlers  
  return([])
end
