property pItemDataDB

on construct me
  pItemDataDB = [:]
  tItemIndex = getmemnum("Poster Index List")
  if not tItemIndex then
    return 1
  end if
  tItemIndex = member(tItemIndex).text
  tDelim = the itemDelimiter
  the itemDelimiter = ":"
  repeat with i = 1 to tItemIndex.line.count
    tLine = tItemIndex.line[i]
    ttype = tLine.item[1]
    tName = tLine.item[2]
    tDesc = tLine.item[3]
    pItemDataDB[ttype] = [#name: tName, #text: tDesc]
  end repeat
  the itemDelimiter = tDelim
  return 1
end

on getPosterData me, ttype
  tdata = pItemDataDB[ttype]
  if voidp(tdata) then
    return 0
  else
    return tdata
  end if
end
