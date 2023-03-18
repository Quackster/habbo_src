on russianHexToInt tStr
  tValue = 0
  repeat with i = 1 to tStr.length
    tValue = tValue * 16
    tChar = tStr.char[i]
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
  end repeat
  return tValue
end

on russianCreateCharacterConversionArrays
  tUnicodeValues = []
  tKOI8RValues = []
  tText = member("KOI8-R to Unicode map").text
  if ilk(tText) = #string then
    tLineCount = the number of lines in tText
    repeat with i = 1 to tLineCount
      tLine = line 1 of tText
      delete line 1 of tText
      tValueKOI8R = word 1 of tLine
      tValueUnicode = word 2 of tLine
      if tValueKOI8R.char[1..2] = "0x" then
        tValueKOI8R = tValueKOI8R.char[3..tValueKOI8R.length]
        if tValueUnicode.char[1..2] = "U+" then
          tValueUnicode = tValueUnicode.char[3..tValueUnicode.length]
          tValueUnicode = russianHexToInt(tValueUnicode)
          tValueKOI8R = russianHexToInt(tValueKOI8R)
          tUnicodeValues[tValueKOI8R + 1] = tValueUnicode
          tKOI8RValues[tValueUnicode + 1] = tValueKOI8R
        end if
      end if
    end repeat
  end if
  return ["unicode_values": tUnicodeValues, "koi8r_values": tKOI8RValues]
end
