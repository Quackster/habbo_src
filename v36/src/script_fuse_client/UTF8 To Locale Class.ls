property pUnicodeValues, plocalevalues, plocaleformat

on construct me 
  pUnicodeValues = [:]
  plocalevalues = [:]
  plocaleformat = ""
end

on defineLocale me, tlocaleformat 
  if tlocaleformat <> "sjis" and tlocaleformat <> "windows-1251" then
    return(error(me, "Invalid locale format:" && tlocaleformat, #defineLocale, #major))
  end if
  plocaleformat = tlocaleformat
  tResult = me.createcharacterconversionarrays(tlocaleformat)
  pUnicodeValues = tResult.getAt("unicode_values")
  plocalevalues = tResult.getAt("locale_values")
end

on convertToUnicode me, tStr 
  if pUnicodeValues.count = 0 or plocalevalues.count = 0 then
    return(0)
  end if
  tUnicodeData = []
  i = 1
  repeat while i <= tStr.length
    tChar = tStr.getProp(#char, i)
    tValue = charToNum(tChar)
    tUnicodeValue = 0
    tIndex = tValue + 1
    if tValue < 128 then
      tUnicodeValue = tValue
    else
      if tIndex <= pUnicodeValues.count then
        tUnicodeValue = pUnicodeValues.getAt(tIndex)
      end if
    end if
    if tUnicodeValue > 0 then
      tUnicodeData.add(tUnicodeValue)
    else
    end if
    i = 1 + i
  end repeat
  return(tUnicodeData)
end

on convertFromUnicode me, tUnicodeData 
  if pUnicodeValues.count = 0 or plocalevalues.count = 0 then
    return(0)
  end if
  tResult = ""
  i = 1
  repeat while i <= tUnicodeData.count
    tUnicodeValue = tUnicodeData.getAt(i)
    tlocalevalue = 0
    tIndex = tUnicodeValue + 1
    if tUnicodeValue < 128 then
      tlocalevalue = tUnicodeValue
    else
      if tIndex <= plocalevalues.count then
        tlocalevalue = plocalevalues.getAt(tIndex)
      end if
    end if
    if tlocalevalue > 0 then
      tResult = tResult & numToChar(tlocalevalue)
    else
    end if
    i = 1 + i
  end repeat
  return(tResult)
end

on generateStringFromUTF8 me, tUTF8Data 
  if plocaleformat = "windows-1251" then
    return(void())
  end if
  tResult = ""
  i = 1
  repeat while i <= tUTF8Data.count
    tValue = tUTF8Data.getAt(i)
    i = i + 1
    if tValue >= 129 and tValue <= 159 or tValue >= 224 and tValue <= 239 then
      if i <= tUTF8Data.count then
        tValue = tValue * 256 + tUTF8Data.getAt(i)
        i = i + 1
      else
      end if
    end if
    tResult = tResult & numToChar(tValue)
  end repeat
  return(tResult)
end

on createcharacterconversionarrays me, tencodingformat 
  tUnicodeValues = []
  tlocalevalues = []
  tText = ""
  if tencodingformat = "sjis" then
    tText = member("Shift JIS to Unicode map").text
  else
    if tencodingformat = "windows-1251" then
      tText = member("Windows-1251 to Unicode map").text
    end if
  end if
  if ilk(tText) = #string then
    tLineCount = the number of line in tText
    tChunkSize = 100
    tChunkCount = tLineCount / tChunkSize
    if tLineCount mod tChunkSize <> 0 then
      tChunkCount = tChunkCount + 1
    end if
    j = 1
    repeat while j <= tChunkCount
      tFirstLineIndex = 1 + j - 1 * tChunkSize
      tLastLineIndex = tFirstLineIndex + tChunkSize - 1
      tSubText = tText.getProp(#line, tFirstLineIndex, tLastLineIndex)
      tSubLineCount = the number of line in tSubText
      i = 1
      repeat while i <= tSubLineCount
        tLine = tSubText.line[1]
        tvaluelocale = tLine.word[1]
        if tvaluelocale.getProp(#char, 1, 2) = "0x" then
          tValueUnicode = tLine.word[2]
          tvaluelocale = tvaluelocale.getProp(#char, 3, tvaluelocale.length)
          if tValueUnicode.getProp(#char, 1, 2) = "0x" then
            tValueUnicode = tValueUnicode.getProp(#char, 3, tValueUnicode.length)
            tValueUnicode = me.hextoint(tValueUnicode)
            tvaluelocale = me.hextoint(tvaluelocale)
            tUnicodeValues.setAt(tvaluelocale + 1, tValueUnicode)
            tlocalevalues.setAt(tValueUnicode + 1, tvaluelocale)
          end if
        end if
        i = 1 + i
      end repeat
      j = 1 + j
    end repeat
  end if
  return(["unicode_values":tUnicodeValues, "locale_values":tlocalevalues])
end

on hextoint me, tStr 
  tValue = 0
  i = 1
  repeat while i <= tStr.length
    tValue = tValue * 16
    tChar = tStr.getProp(#char, i)
    tVal = value(tChar)
    if voidp(tVal) then
      if tChar = "a" then
        tVal = 10
      else
        if tChar = "b" then
          tVal = 11
        else
          if tChar = "c" then
            tVal = 12
          else
            if tChar = "d" then
              tVal = 13
            else
              if tChar = "e" then
                tVal = 14
              else
                if tChar = "f" then
                  tVal = 15
                end if
              end if
            end if
          end if
        end if
      end if
    end if
    tValue = tValue + tVal
    i = 1 + i
  end repeat
  return(tValue)
end

on handlers  
  return([])
end
