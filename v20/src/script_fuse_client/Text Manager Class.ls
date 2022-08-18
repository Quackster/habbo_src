on GET me, tKey, tDefault
  tText = me.pItemList[tKey]
  if voidp(tText) then
    tError = ("Text not found:" && tKey)
    if not voidp(tDefault) then
      tText = tDefault
      tError = (((tError & RETURN) & "Using given default:") && tDefault)
    else
      tText = tKey
    end if
    error(me, tError, #GET, #minor)
  end if
  tText = getStringServices().convertSpecialChars(tText)
  return tText
end

on dump me, tField, tDelimiter
  if not memberExists(tField) then
    return error(me, ("Field member expected:" && tField), #dump, #major)
  end if
  tRawStr = field(tField)
  tStrServices = getStringServices()
  tSpecialChunks = ["\r": RETURN, "\t": TAB, "\s": SPACE, "<BR>": RETURN]
  tLineChunks = []
  tMaxLinesPerChunk = 100
  tTotalChunkCount = ((tRawStr.line.count / tMaxLinesPerChunk) + 1)
  repeat with tChunk = 1 to tTotalChunkCount
    tStartChunkIndex = (((tChunk - 1) * tMaxLinesPerChunk) + 1)
    tEndChunkIndex = ((tStartChunkIndex + tMaxLinesPerChunk) - 1)
    tLines = tRawStr.line[tStartChunkIndex]
    tLineChunks[tChunk] = tLines
  end repeat
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  repeat with tStr in tLineChunks
    tLineCount = tStr.line.count
    repeat with tLineNo = 1 to tLineCount
      tPair = tStr.line[tLineNo]
      if ((chars(tPair, 1, 1) <> "#") and (tPair <> EMPTY)) then
        tProp = tPair.item[1]
        tValue = tPair.item[2]
        repeat with k = 1 to tSpecialChunks.count
          tMark = tSpecialChunks.getPropAt(k)
          if (tValue contains tMark) then
            tValue = tStrServices.replaceChunks(tValue, tMark, tSpecialChunks[k])
          end if
        end repeat
        me.pItemList[tProp] = tValue
      end if
    end repeat
  end repeat
  the itemDelimiter = tDelim
  return 1
end
