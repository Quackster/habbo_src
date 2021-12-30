on new me 
  return(me)
end

on handleStripData me, s 
  if voidp(gpPostItNos) then
    gpPostItNos = [:]
  end if
  oldDelim = the itemDelimiter
  sendAllSprites(#dieHandItem)
  gpStuffTypes = [:]
  i = 1
  repeat while i <= the number of item in s
    the itemDelimiter = "/"
    ln = s.item[i]
    the itemDelimiter = ";"
    if (ln.item[4] = "S") then
      stype = ln.item[6]
      sid = ln.item[2]
      swidth = ln.item[9]
      sheight = ln.item[10]
      pColors = ln.item[11]
      addProp(gpStuffTypes, sid, [#stuff, stype, swidth, sheight, pColors])
    else
      if (ln.item[4] = "I") then
        itype = ln.item[6]
        iid = ln.item[2]
        idata = ln.item[8]
        addProp(gpStuffTypes, iid, [#item, itype, idata])
        if (itype = "post.it") then
          setaProp(gpPostItNos, iid, integer(ln.item[8]))
        end if
      end if
    end if
    the itemDelimiter = "/"
    i = (1 + i)
  end repeat
  the itemDelimiter = oldDelim
end

on prepareHandItems me 
  i = 1
  repeat while i <= count(gpStuffTypes)
    id = getPropAt(gpStuffTypes, i)
    type = getAt(getaProp(gpStuffTypes, id), 2)
    put(id, type)
    if count(getaProp(gpStuffTypes, id)) >= 5 then
      colors = getAt(getaProp(gpStuffTypes, id), 5)
    else
      colors = void()
    end if
    sendSprite((616 + ((i - 1) * 2)), #setItem, type, id, getAt(getaProp(gpStuffTypes, id), 1), colors)
    i = (1 + i)
  end repeat
end
