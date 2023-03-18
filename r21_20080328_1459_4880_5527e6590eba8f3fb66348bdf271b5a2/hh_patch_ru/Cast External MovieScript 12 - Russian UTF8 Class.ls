property pUnicodeValues, pKOI8RValues

on construct me
  tResult = russianCreateCharacterConversionArrays()
  pUnicodeValues = tResult["unicode_values"]
  pKOI8RValues = tResult["koi8r_values"]
end

on convertToUnicodeLocal tStr
  tUnicodeData = []
  repeat with i = 1 to tStr.length
    tChar = tStr.char[i]
    tValue = charToNum(tChar)
    tUnicodeValue = 0
    tIndex = tValue + 1
    if tIndex <= pUnicodeValues.count then
      tUnicodeValue = pUnicodeValues[tIndex]
    end if
    if tUnicodeValue > 0 then
      tUnicodeData.add(tUnicodeValue)
      next repeat
    end if
    put "ERROR converting KOI8-R to unicode, KOI8-R value" && tValue
  end repeat
  return tUnicodeData
end

on convertFromUnicodeLocal tUnicodeData
  tResult = EMPTY
  repeat with i = 1 to tUnicodeData.count
    tUnicodeValue = tUnicodeData[i]
    tKOI8RValue = 0
    tIndex = tUnicodeValue + 1
    if tIndex <= pKOI8RValues.count then
      tKOI8RValue = pKOI8RValues[tIndex]
    end if
    if tKOI8RValue > 0 then
      tResult = tResult & numToChar(tKOI8RValue)
      next repeat
    end if
    put "ERROR converting unicode to KOI8-R, unicode value" && tUnicodeValue
  end repeat
  return tResult
end
