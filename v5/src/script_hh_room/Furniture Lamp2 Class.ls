property pActive, pSwitch

on prepare me, tdata 
  if me.count(#pSprList) > 1 then
    removeEventBroker(me.getPropRef(#pSprList, 2).spriteNum)
  end if
  if (tdata.getAt("SWITCHON") = "ON") then
    me.setOn()
  else
    me.setOff()
  end if
  return TRUE
end

on updateStuffdata me, tProp, tValue 
  if (tValue = "ON") then
    me.setOn()
  else
    me.setOff()
  end if
end

on update me 
  if pActive then
    if me.count(#pSprList) < 2 then
      return()
    end if
    tDelim = the itemDelimiter
    the itemDelimiter = "_"
    tName = me.getPropRef(#pSprList, 1).member.name
    tItem = tName.getProp(#item, 1, (tName.count(#item) - 6))
    tPart = tName.getProp(#item, (tName.count(#item) - 5))
    tdata = tName.getProp(#item, (tName.count(#item) - 4), (tName.count(#item) - 1))
    tNewNameA = tItem & "_" & "b" & "_" & tdata & "_" & pSwitch
    tNewNameB = tItem & "_" & "c" & "_" & tdata & "_" & pSwitch
    the itemDelimiter = tDelim
    me.getPropRef(#pSprList, 2).locZ = (me.getPropRef(#pSprList, 1).locZ + 2)
    if memberExists(tNewNameA) then
      tmember = member(getmemnum(tNewNameA))
      me.getPropRef(#pSprList, 2).castNum = tmember.number
      me.getPropRef(#pSprList, 2).width = tmember.width
      me.getPropRef(#pSprList, 2).height = tmember.height
    end if
    pActive = 0
  end if
end

on setOn me 
  pSwitch = 1
  pActive = 1
end

on setOff me 
  pSwitch = 0
  pActive = 1
end

on select me 
  if the doubleClick then
    if pSwitch then
      tStr = "OFF"
    else
      tStr = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send(#room, "SETSTUFFDATA /" & me.getID() & "/" & "SWITCHON" & "/" & tStr)
  end if
  return TRUE
end
