property pActive, pDelay, pFrame, pCycles

on prepare me, tdata 
  pActive = 0
  pFrame = 0
  pCycles = 0
  pDelay = 0
  return TRUE
end

on updateStuffdata me, tValue 
  tValue = integer(tValue)
  if (tValue = 1) then
    me.setOn()
  end if
  return TRUE
end

on update me 
  if not pActive then
    return()
  end if
  if me.count(#pSprList) < 3 then
    return()
  end if
  pDelay = not pDelay
  if pDelay then
    return()
  end if
  pFrame = (pFrame + 1)
  if (pFrame = 5) then
    pFrame = 1
    pCycles = (pCycles + 1)
    if (pCycles = 4) then
      pCycles = 0
      me.setOff()
    end if
  end if
  the itemDelimiter = "_"
  tMemName = me.getPropRef(#pSprList, 3).member.name
  tClass = tMemName.getProp(#item, 1, (tMemName.count(#item) - 6))
  if pActive then
    tmember = member(getmemnum(tClass & "_c_0_1_1_0_" & pFrame))
  else
    tmember = member(getmemnum(tClass & "_c_0_1_1_0_0"))
  end if
  me.getPropRef(#pSprList, 3).castNum = tmember.number
  me.getPropRef(#pSprList, 3).width = tmember.width
  me.getPropRef(#pSprList, 3).height = tmember.height
end

on setOn me 
  pActive = 1
end

on setOff me 
  pActive = 0
end

on select me 
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer:integer(me.getID()), #integer:0])
  end if
  return TRUE
end
