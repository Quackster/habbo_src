on construct(me)
  pItemDataDB = []
  tItemIndex = getmemnum("Poster Index List")
  if not tItemIndex then
    return(1)
  end if
  tItemIndex = member(tItemIndex).text
  tDelim = the itemDelimiter
  the itemDelimiter = ":"
  i = 1
  repeat while i <= tItemIndex.count(#line)
    tLine = tItemIndex.getProp(#line, i)
    ttype = tLine.getProp(#item, 1)
    tName = tLine.getProp(#item, 2)
    tDesc = tLine.getProp(#item, 3)
    pItemDataDB.setAt(ttype, [#name:tName, #text:tDesc])
    i = 1 + i
  end repeat
  the itemDelimiter = tDelim
  return(1)
  exit
end

on getPosterData(me, ttype)
  tdata = pItemDataDB.getAt(ttype)
  if voidp(tdata) then
    return(0)
  else
    return(tdata)
  end if
  exit
end