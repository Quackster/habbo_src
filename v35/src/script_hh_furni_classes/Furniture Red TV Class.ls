property pChanges, pActive, pTimer, pNextChange

on prepare me, tdata 
  tValue = integer(tdata.getAt(#stuffdata))
  if (tValue = 0) then
    pActive = 0
  else
    pActive = 1
  end if
  pChanges = 1
  pTimer = 0
  pNextChange = (random(36) + 12)
  return TRUE
end

on updateStuffdata me, tValue 
  tValue = integer(tValue)
  if (tValue = 0) then
    pActive = 0
  else
    pActive = 1
  end if
  if me.count(#pSprList) < 2 then
    return FALSE
  end if
  me.getPropRef(#pSprList, 2).castNum = 0
  pChanges = 1
end

on update me 
  if not pChanges then
    return()
  end if
  if me.count(#pSprList) < 2 then
    return()
  end if
  if pActive then
    if (me.pXFactor = 32) then
      tClass = "s_red_tv"
    else
      tClass = "red_tv"
    end if
    pTimer = (pTimer + 1)
    if pTimer < pNextChange then
      return()
    end if
    pTimer = 0
    pNextChange = (random(36) + 12)
    tNewName = tClass & "_b_0_1_1_2_" & (random(8) - 1)
    if memberExists(tNewName) then
      tmember = member(getmemnum(tNewName))
      me.getPropRef(#pSprList, 2).castNum = tmember.number
      me.getPropRef(#pSprList, 2).width = tmember.width
      me.getPropRef(#pSprList, 2).height = tmember.height
      me.getPropRef(#pSprList, 2).locZ = (me.getPropRef(#pSprList, 1).locZ + 2)
    end if
  else
    me.getPropRef(#pSprList, 2).castNum = 0
    pChanges = 0
  end if
end

on select me 
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer:integer(me.getID()), #integer:0])
  end if
  return TRUE
end
