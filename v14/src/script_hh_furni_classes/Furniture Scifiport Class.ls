on prepare me, tdata 
  if (tdata.getAt(#stuffdata) = "O") then
    me.setOn()
    me.pChanges = 1
  else
    me.setOff()
    me.pChanges = 0
  end if
  return TRUE
end

on updateStuffdata me, tValue 
  if (tValue = "O") then
    me.setOn()
  else
    me.setOff()
  end if
  me.pChanges = 1
end

on update me 
  if not me.pChanges then
    return()
  end if
  if me.count(#pSprList) < 4 then
    return()
  end if
  return(me.updateScifiPort())
end

on updateScifiPort me 
  if me.count(#pSprList) < 4 then
    return FALSE
  end if
  tGateSp1 = me.getProp(#pSprList, 3)
  tGateSp2 = me.getProp(#pSprList, 4)
  if me.pActive then
    tGateSp1.visible = 0
    tGateSp2.visible = 0
  else
    tGateSp1.visible = 1
    tGateSp2.visible = 1
  end if
  me.pChanges = 0
  return TRUE
end

on setOn me 
  me.pActive = 1
end

on setOff me 
  me.pActive = 0
end

on select me 
  if the doubleClick then
    if me.pActive then
      tStr = "C"
    else
      tStr = "O"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:tStr])
  end if
  return TRUE
end
