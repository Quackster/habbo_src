property pUnicodeValues, pSJISValues

on construct me
  tResult = japanCreateCharacterConversionArrays()
  pUnicodeValues = tResult["unicode_values"]
  pSJISValues = tResult["sjis_values"]
end

on convertToUnicode me, tStr
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
    put "ERROR converting SJIS to unicode, SJIS value" && tValue
  end repeat
  return tUnicodeData
end

on convertFromUnicode me, tUnicodeData
  tResult = EMPTY
  repeat with i = 1 to tUnicodeData.count
    tUnicodeValue = tUnicodeData[i]
    tSJISValue = 0
    tIndex = tUnicodeValue + 1
    if tIndex <= pSJISValues.count then
      tSJISValue = pSJISValues[tIndex]
    end if
    if tSJISValue > 0 then
      tResult = tResult & numToChar(tSJISValue)
      next repeat
    end if
    put "ERROR converting unicode to SJIS, unicode value" && tUnicodeValue
  end repeat
  return tResult
end

on generateStringFromUTF8 me, tUTF8Data
  tResult = EMPTY
  i = 1
  repeat while i <= tUTF8Data.count
    tValue = tUTF8Data[i]
    i = i + 1
    if ((tValue >= 129) and (tValue <= 159)) or ((tValue >= 224) and (tValue <= 239)) then
      if i <= tUTF8Data.count then
        tValue = (tValue * 256) + tUTF8Data[i]
        i = i + 1
      else
      end if
    end if
    tResult = tResult & numToChar(tValue)
  end repeat
  return tResult
end
