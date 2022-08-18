property pConvList, pDigits

on construct me
  pConvList = [:]
  pDigits = "0123456789ABCDEF"
  me.initConvList()
  return 1
end

on convertToPropList me, tStr, tDelim
  tOldDelim = the itemDelimiter
  if (tDelim = VOID) then
    tDelim = ","
  end if
  the itemDelimiter = tDelim
  tProps = [:]
  repeat with i = 1 to tStr.item.count
    tPair = tStr.item[i].word[1]
    tProp = tPair.char[1]
    tValue = tPair.char[(offset("=", tPair) + 1)]
    tProps[tProp.word[1]] = tValue.word[1]
  end repeat
  the itemDelimiter = tOldDelim
  return tProps
end

on convertToLowerCase me, tString
  tValueStr = EMPTY
  repeat with i = 1 to length(tString)
    tChar = tString.char[i]
    tNum = charToNum(tChar)
    if ((tNum >= 65) and (tNum <= 90)) then
      tChar = numToChar((tNum + 32))
    end if
    tValueStr = (tValueStr & tChar)
  end repeat
  return tValueStr
end

on convertToHigherCase me, tString
  tValueStr = EMPTY
  repeat with i = 1 to length(tString)
    tChar = tString.char[i]
    tNum = charToNum(tChar)
    if ((tNum >= 97) and (tNum <= 122)) then
      tChar = numToChar((tNum - 32))
    end if
    tValueStr = (tValueStr & tChar)
  end repeat
  return tValueStr
end

on convertSpecialChars me, tString, tDirection
  tRetString = EMPTY
  tLength = tString.length
  if voidp(tDirection) then
    tDirection = 0
  end if
  if (tDirection = 0) then
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
      if (tPos > 0) then
        put pConvList.getPropAt(tPos) after tRetString
        next repeat
      end if
      put tChar after tRetString
    end repeat
  end if
  return tRetString
end

on convertIntToHex me, tInt
  if (tInt <= 0) then
    return "00"
  else
    repeat while (tInt > 0)
      tD = (tInt mod 16)
      tInt = (tInt / 16)
      tHexstr = (pDigits.char[(tD + 1)] & tHexstr)
    end repeat
  end if
  if ((length(tHexstr) mod 2) = 1) then
    tHexstr = ("0" & tHexstr)
  end if
  return tHexstr
end

on convertHexToInt me, tHex
  tBase = 1
  tValue = 0
  repeat while (length(tHex) > 0)
    tLc = the last char in tHex
    delete char -30000 of tHex
    tVl = (offset(tLc, pDigits) - 1)
    tValue = (tValue + (tBase * tVl))
    tBase = (tBase * 16)
  end repeat
  return tValue
end

on replaceChars me, tString, tCharA, tCharB
  if (tCharA = tCharB) then
    return tString
  end if
  repeat while (offset(tCharA, tString) > 0)
    put tCharB into char offset(tCharA, tString) of tString
  end repeat
  return tString
end

on replaceChunks me, tString, tChunkA, tChunkB
  tStr = EMPTY
  repeat while (tString contains tChunkA)
    tPos = (offset(tChunkA, tString) - 1)
    if (tPos > 0) then
      put tString.char[1] after tStr
    end if
    put tChunkB after tStr
    delete tString.char[1]
  end repeat
  put tString after tStr
  return tStr
end

on initConvList me
  if (the platform contains "win") then
    tMachineType = ".win"
  else
    tMachineType = ".mac"
  end if
  pConvList = [:]
  tCharList = getVariableValue(("char.conversion" & tMachineType), [:])
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
