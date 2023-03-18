global gpStuffTypes, gpPostItNos

on new me
  return me
end

on handleStripData me, s
  if voidp(gpPostItNos) then
    gpPostItNos = [:]
  end if
  oldDelim = the itemDelimiter
  sendAllSprites(#dieHandItem)
  gpStuffTypes = [:]
  repeat with i = 1 to the number of items in s
    the itemDelimiter = "/"
    ln = item i of s
    the itemDelimiter = ";"
    if item 4 of ln = "S" then
      stype = item 6 of ln
      sid = item 2 of ln
      swidth = item 9 of ln
      sheight = item 10 of ln
      pColors = item 11 of ln
      addProp(gpStuffTypes, sid, [#stuff, stype, swidth, sheight, pColors])
    else
      if item 4 of ln = "I" then
        itype = item 6 of ln
        iid = item 2 of ln
        idata = item 8 of ln
        addProp(gpStuffTypes, iid, [#item, itype, idata])
        if itype = "post.it" then
          setaProp(gpPostItNos, iid, integer(item 8 of ln))
        end if
      end if
    end if
    the itemDelimiter = "/"
  end repeat
  the itemDelimiter = oldDelim
end

on prepareHandItems me
  repeat with i = 1 to count(gpStuffTypes)
    id = getPropAt(gpStuffTypes, i)
    type = getAt(getaProp(gpStuffTypes, id), 2)
    put id, type
    if count(getaProp(gpStuffTypes, id)) >= 5 then
      colors = getAt(getaProp(gpStuffTypes, id), 5)
    else
      colors = VOID
    end if
    sendSprite(616 + ((i - 1) * 2), #setItem, type, id, getAt(getaProp(gpStuffTypes, id), 1), colors)
  end repeat
end
