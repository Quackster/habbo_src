on constructStringServices
  return createManager(#string_services, getClassVariable("string.services.class"))
end

on deconstructStringServices
  return removeManager(#string_services)
end

on getStringServices
  tMgr = getObjectManager()
  if not tMgr.managerExists(#string_services) then
    return constructStringServices()
  end if
  return tMgr.getManager(#string_services)
end

on convertToPropList tString, tDelimiter
  tOldDelim = the itemDelimiter
  if voidp(tDelimiter) then
    tDelimiter = ","
  end if
  the itemDelimiter = tDelimiter
  tProps = [:]
  repeat with i = 1 to tString.item.count
    tPair = tString.item[i].word[1..tString.item[i].word.count]
    tProp = tPair.char[1..offset("=", tPair) - 1]
    tValue = tPair.char[offset("=", tPair) + 1..length(tString)]
    tProps[tProp.word[1..tProp.word.count]] = tValue.word[1..tValue.word.count]
  end repeat
  the itemDelimiter = tOldDelim
  return tProps
end

on convertToLowerCase tString
  return getStringServices().convertToLowerCase(tString)
end

on convertToHigherCase tString
  return getStringServices().convertToHigherCase(tString)
end

on convertSpecialChars tString, tDirection
  return getStringServices().convertSpecialChars(tString, tDirection)
end

on convertIntToHex tInt
  return getStringServices().convertIntToHex(tInt)
end

on convertHexToInt tHex
  return getStringServices().convertHexToInt(tHex)
end

on explode tString, tDelimiter, tLimit
  return getStringServices().explode(tString, tDelimiter, tLimit)
end

on implode tList, tDelimiter
  return getStringServices().implode(tList, tDelimiter)
end

on replaceChars tString, tCharA, tCharB
  return getStringServices().replaceChars(tString, tCharA, tCharB)
end

on replaceChunks tString, tChunkA, tChunkB
  return getStringServices().replaceChunks(tString, tChunkA, tChunkB)
end

on urlEncode tString
  return getStringServices().urlEncode(tString)
end

on obfuscate tString
  return getStringServices().obfuscate(tString)
end

on deobfuscate tString
  return getStringServices().deobfuscate(tString)
end

on getLocalFloat tStrFloat
  return getStringServices().getLocalFloat(tStrFloat)
end

on encodeUTF8 tStr
  return getStringServices().encodeUTF8(tStr)
end

on decodeUTF8 tStr, tForceDecode
  return getStringServices().decodeUTF8(tStr, tForceDecode)
end
