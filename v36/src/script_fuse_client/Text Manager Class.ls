on GET me, tKey, tDefault 
  tText = me.pItemList.getaProp(tKey)
  if voidp(tText) then
    tError = "Text not found:" && tKey
    if not voidp(tDefault) then
      tText = tDefault
      tError = tError & "\r" & "Using given default:" && tDefault
    else
      tText = tKey
    end if
    error(me, tError, #GET, #minor)
  end if
  tText = getStringServices().convertSpecialChars(tText)
  return(tText)
end

on dump me, tField, tDelimiter 
  if not memberExists(tField) then
    return(error(me, "Field member expected:" && tField, #dump, #major))
  end if
  startProfilingTask("Text Manager::dump")
  tRawStr = field(0)
  tRawStr = decodeUTF8(tRawStr)
  tStrServices = getStringServices()
  tSpecialChunks = ["\\r":"\r", "\\t":"\t", "\\s":space(), "<BR>":"\r"]
  tLineChunks = []
  tMaxLinesPerChunk = 100
  tTotalChunkCount = ((tRawStr.count(#line) / tMaxLinesPerChunk) + 1)
  tChunk = 1
  repeat while tChunk <= tTotalChunkCount
    tStartChunkIndex = (((tChunk - 1) * tMaxLinesPerChunk) + 1)
    tEndChunkIndex = ((tStartChunkIndex + tMaxLinesPerChunk) - 1)
    tLines = tRawStr.getProp(#line, tStartChunkIndex, tEndChunkIndex)
    tLineChunks.setAt(tChunk, tLines)
    tChunk = (1 + tChunk)
  end repeat
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  repeat while tField <= tDelimiter
    tStr = getAt(tDelimiter, tField)
    tLineCount = tStr.count(#line)
    tLineNo = 1
    repeat while tLineNo <= tLineCount
      tPair = tStr.getProp(#line, tLineNo)
      if chars(tPair, 1, 1) <> "#" and tPair <> "" then
        tProp = tPair.getProp(#item, 1)
        tValue = tPair.getProp(#item, 2, tPair.count(#item))
        k = 1
        repeat while k <= tSpecialChunks.count
          tMark = tSpecialChunks.getPropAt(k)
          if tValue contains tMark then
            tValue = tStrServices.replaceChunks(tValue, tMark, tSpecialChunks.getAt(k))
          end if
          k = (1 + k)
        end repeat
        me.setProp(#pItemList, tProp, tValue)
      end if
      tLineNo = (1 + tLineNo)
    end repeat
  end repeat
  the itemDelimiter = tDelim
  finishProfilingTask("Text Manager::dump")
  return TRUE
end

on handlers  
  return([])
end
