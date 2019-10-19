on prepare(me, tdata)
  tValue = integer(tdata.getAt(#stuffdata))
  if tValue = 0 then
    me.setOff()
    pChanges = 0
  else
    me.setOn()
    pChanges = 1
  end if
  return(1)
  exit
end

on updateStuffdata(me, tValue)
  tValue = integer(tValue)
  if tValue = 0 then
    me.setOff()
  else
    me.setOn()
  end if
  pChanges = 1
  exit
end

on update(me)
  if not pChanges then
    return()
  end if
  if me.count(#pSprList) < 2 then
    return()
  end if
  tCurName = member.name
  tNewName = tCurName.getProp(#char, 1, length(tCurName) - 1) & pActive
  tMemNum = getmemnum(tNewName)
  if pActive then
    tDelim = the itemDelimiter
    the itemDelimiter = "_"
    tItemCount = tNewName.count(#item)
    if tNewName.getProp(#item, tItemCount - 1) = "0" or tNewName.getProp(#item, tItemCount - 1) = "6" then
      me.getPropRef(#pSprList, 2).locZ = me.getPropRef(#pSprList, 1).locZ + 502
    else
      if tNewName.getProp(#item, tItemCount - 1) <> "0" and tNewName.getProp(#item, tItemCount - 1) <> "6" then
        me.getPropRef(#pSprList, 2).locZ = me.getPropRef(#pSprList, 1).locZ + 2
      end if
    end if
    the itemDelimiter = tDelim
  else
    me.getPropRef(#pSprList, 2).locZ = me.getPropRef(#pSprList, 1).locZ + 1
  end if
  if tMemNum > 0 then
    tmember = member(tMemNum)
    me.getPropRef(#pSprList, 2).castNum = tMemNum
    me.getPropRef(#pSprList, 2).width = tmember.width
    me.getPropRef(#pSprList, 2).height = tmember.height
  end if
  pChanges = 0
  exit
end

on setOn(me)
  pActive = 1
  if me.count(#pLoczList) < 2 then
    return(0)
  end if
  me.setProp(#pLoczList, 2, [200, 200, 0, 0, 0, 0, 200, 200])
  exit
end

on setOff(me)
  pActive = 0
  if me.count(#pLoczList) < 2 then
    return(0)
  end if
  me.setProp(#pLoczList, 2, [0, 0, 0, 0, 0, 0, 0, 0])
  exit
end

on select(me)
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer:integer(me.getID()), #integer:0])
  else
    getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:me.pLocY])
  end if
  return(1)
  exit
end