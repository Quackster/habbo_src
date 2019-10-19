property pConvList, pDigits

on construct me 
  pConvList = [:]
  pDigits = "0123456789ABCDEF"
  me.initConvList()
  return(1)
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
      tD = (tInt mod 16)
      tInt = (tInt / 16)
      tHexstr = pDigits.getProp(#char, tD + 1) & tHexstr
    end repeat
  end if
  if (length(tHexstr) mod 2) = 1 then
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
    tValue = tValue + (tBase * tVl)
    tBase = (tBase * 16)
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

on obfuscate me, tStr 
  tResult = ""
  i = 1
  repeat while i <= tStr.length
    tNumber = charToNum(tStr.getProp(#char, i))
    tNewNumber1 = (bitAnd(tNumber, 15) * 2)
    tNewNumber2 = (bitAnd(tNumber, 240) / 8)
    tRandom = random(6) + 1
    tNewNumber1 = tNewNumber1 + (bitAnd(tRandom, 6) * 16) + bitAnd(tRandom, 1)
    tRandom = random(6) + 1
    tNewNumber2 = tNewNumber2 + (bitAnd(tRandom, 6) * 16) + bitAnd(tRandom, 1)
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
      tNumbers = [(bitAnd(tRawNumbers.getAt(1), 30) / 2), (bitAnd(tRawNumbers.getAt(2), 30) * 8)]
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

on initConvList me 
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
