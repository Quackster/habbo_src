on GET me, tKey, tDefault 
  tText = me.getProp(#pItemList, tKey)
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
  return(tText)
end

on dump me, tField, tDelimiter 
  if not memberExists(tField) then
    return(error(me, "Field member expected:" && tField, #dump, #major))
  end if
  tStr = field(0)
  tStrServices = getStringServices()
  tSpecialChunks = ["\\r":"\r", "\\t":"\t", "\\s":space(), "<BR>":"\r"]
  tDelim = the itemDelimiter
  if voidp(tDelimiter) then
    tDelimiter = "\r"
  end if
  the itemDelimiter = tDelimiter
  i = 1
  repeat while i <= tStr.count(#item)
    tPair = tStr.getProp(#item, i)
    if tPair.getPropRef(#word, 1).getProp(#char, 1) <> "#" and tPair <> "" then
      the itemDelimiter = "="
      tProp = tPair.getPropRef(#item, 1).getProp(#word, 1, tPair.getPropRef(#item, 1).count(#word))
      tValue = tPair.getProp(#item, 2, tPair.count(#item))
      tValue = tValue.getProp(#word, 1, tValue.count(#word))
      tValue = tStrServices.convertSpecialChars(tValue)
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
    the itemDelimiter = tDelimiter
    i = (1 + i)
  end repeat
  the itemDelimiter = tDelim
  return TRUE
end
