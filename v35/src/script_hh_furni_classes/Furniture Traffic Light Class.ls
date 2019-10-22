on prepare me, tdata 
  me.setState(tdata.getAt(#stuffdata))
  return TRUE
end

on updateStuffdata me, tValue 
  me.setState(tValue)
end

on setState me, tValue 
  tValue = integer(tValue)
  if me.count(#pSprList) < 3 then
    return FALSE
  end if
  pState = tValue
  if (tValue = 0) then
    me.switchMember("c", "0")
    me.getPropRef(#pSprList, 3).visible = 1
  else
    if (tValue = 1) then
      me.switchMember("c", "1")
      me.getPropRef(#pSprList, 3).visible = 1
    else
      me.getPropRef(#pSprList, 3).visible = 0
    end if
  end if
  return TRUE
end

on switchMember me, tPart, tNewMem 
  tSprNum = ["a", "b", "c", "d", "e", "f"].getPos(tPart)
  if me.count(#pSprList) < tSprNum or (tSprNum = 0) then
    return FALSE
  end if
  tName = me.getPropRef(#pSprList, tSprNum).member.name
  tName = tName.getProp(#char, 1, (tName.length - 1)) & tNewMem
  if memberExists(tName) then
    tmember = member(getmemnum(tName))
    me.getPropRef(#pSprList, tSprNum).castNum = tmember.number
    me.getPropRef(#pSprList, tSprNum).width = tmember.width
    me.getPropRef(#pSprList, tSprNum).height = tmember.height
  end if
  return TRUE
end

on select me 
  if the doubleClick then
    tUserObj = getThread(#room).getComponent().getOwnUser()
    if not tUserObj then
      return TRUE
    end if
    if abs((tUserObj.pLocX - me.pLocX)) > 1 or abs((tUserObj.pLocY - me.pLocY)) > 1 then
      return TRUE
    end if
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer:integer(me.getID()), #integer:0])
  end if
  return TRUE
end
