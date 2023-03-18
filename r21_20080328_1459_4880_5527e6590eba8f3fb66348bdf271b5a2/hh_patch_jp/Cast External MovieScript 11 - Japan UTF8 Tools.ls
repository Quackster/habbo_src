on japanHexToInt tStr
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

on japanCreateCharacterConversionArrays
  tUnicodeValues = []
  tSJISValues = []
  tText = member("Shift JIS to Unicode map").text
  if ilk(tText) = #string then
    tLineCount = the number of lines in tText
    tChunkSize = 100
    tChunkCount = tLineCount / tChunkSize
    if (tLineCount mod tChunkSize) <> 0 then
      tChunkCount = tChunkCount + 1
    end if
    repeat with j = 1 to tChunkCount
      tSubText = tText.line[1 + ((j - 1) * tChunkCount)..j * tChunkCount]
      tSubLineCount = the number of lines in tSubText
      repeat with i = 1 to tSubLineCount
        tLine = line 1 of tSubText
        delete line 1 of tSubText
        tValueSJIS = word 1 of tLine
        tValueUnicode = word 2 of tLine
        if tValueSJIS.char[1..2] = "0x" then
          tValueSJIS = tValueSJIS.char[3..tValueSJIS.length]
          if tValueUnicode.char[1..2] = "U+" then
            tValueUnicode = tValueUnicode.char[3..tValueUnicode.length]
            tValueUnicode = japanHexToInt(tValueUnicode)
            tValueSJIS = japanHexToInt(tValueSJIS)
            tUnicodeValues[tValueSJIS + 1] = tValueUnicode
            tSJISValues[tValueUnicode + 1] = tValueSJIS
          end if
        end if
      end repeat
    end repeat
  end if
  return ["unicode_values": tUnicodeValues, "sjis_values": tSJISValues]
end
