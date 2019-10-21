property pChanges, pActive

on prepare me, tdata 
  if (tdata.getAt(#stuffdata) = "O") then
    me.setOn()
    pChanges = 1
  else
    me.setOff()
    pChanges = 0
  end if
  return TRUE
end

on updateStuffdata me, tValue 
  if (tValue = "O") then
    me.setOn()
  else
    me.setOff()
  end if
  pChanges = 1
end

on update me 
  if not pChanges then
    return()
  end if
  if me.count(#pSprList) < 2 then
    return()
  end if
  tCurName = me.getPropRef(#pSprList, 2).member.name
  tNewName = tCurName.getProp(#char, 1, (length(tCurName) - 1)) & pActive
  tMemNum = getmemnum(tNewName)
  if pActive then
    tDelim = the itemDelimiter
    the itemDelimiter = "_"
    if (tNewName.getProp(#item, 6) = "0") or (tNewName.getProp(#item, 6) = "6") then
      me.getPropRef(#pSprList, 2).locZ = (me.getPropRef(#pSprList, 1).locZ + 502)
    else
      if tNewName.getProp(#item, 6) <> "0" and tNewName.getProp(#item, 6) <> "6" then
        me.getPropRef(#pSprList, 2).locZ = (me.getPropRef(#pSprList, 1).locZ + 2)
      end if
    end if
    the itemDelimiter = tDelim
  else
    me.getPropRef(#pSprList, 2).locZ = (me.getPropRef(#pSprList, 1).locZ + 1)
  end if
  if tMemNum > 0 then
    tmember = member(tMemNum)
    me.getPropRef(#pSprList, 2).castNum = tMemNum
    me.getPropRef(#pSprList, 2).width = tmember.width
    me.getPropRef(#pSprList, 2).height = tmember.height
  end if
  pChanges = 0
end

on setOn me 
  pActive = 1
end

on setOff me 
  pActive = 0
end

on select me 
  if the doubleClick then
    if pActive then
      tStr = "C"
    else
      tStr = "O"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:tStr])
  end if
  return TRUE
end
