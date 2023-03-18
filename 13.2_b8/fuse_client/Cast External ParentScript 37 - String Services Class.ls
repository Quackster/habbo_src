property pConvList, pDigits

on construct me
  pConvList = [:]
  pDigits = "0123456789ABCDEF"
  me.initConvList()
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
    error(me, "At least one of the parameters was void!", me.getID(), #replaceChunks)
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
