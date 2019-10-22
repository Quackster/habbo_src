property pState, pBlinkCounter

on prepare me, tdata 
  me.setState(tdata.getAt(#stuffdata))
  return TRUE
end

on updateStuffdata me, tValue 
  me.setState(tValue)
end

on setState me, tValue 
  if me.count(#pSprList) < 5 then
    return FALSE
  end if
  pBlinkCounter = 0
  pState = integer(tValue)
  me.getPropRef(#pSprList, 5).visible = pState <> 0
  return TRUE
end

on update me 
  if (pState = 0) then
    return TRUE
  end if
  if me.count(#pSprList) < 5 then
    return FALSE
  end if
  if (pBlinkCounter = 0) then
    me.getPropRef(#pSprList, 5).visible = 1
  end if
  if (pBlinkCounter = 20) then
    me.getPropRef(#pSprList, 5).visible = 0
  end if
  pBlinkCounter = (pBlinkCounter + 1)
  if pBlinkCounter > 45 then
    pBlinkCounter = 0
  end if
end

on select me 
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer:integer(me.getID()), #integer:0])
  end if
  return TRUE
end
