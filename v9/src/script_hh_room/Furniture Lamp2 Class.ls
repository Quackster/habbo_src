on prepare(me, tdata)
  if me.count(#pSprList) > 1 then
    removeEventBroker(me.getPropRef(#pSprList, 2).spriteNum)
  end if
  if tdata.getAt(#stuffdata) = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  return(1)
  exit
end

on updateStuffdata(me, tValue)
  if tValue = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  exit
end

on update(me)
  if pActive then
    if me.count(#pSprList) < 2 then
      return()
    end if
    tDelim = the itemDelimiter
    the itemDelimiter = "_"
    tName = undefined.name
    tItem = tName.getProp(#item, 1, tName.count(#item) - 6)
    tPart = tName.getProp(#item, tName.count(#item) - 5)
    tdata = tName.getProp(#item, tName.count(#item) - 4, tName.count(#item) - 1)
    tNewNameA = tItem & "_" & "b" & "_" & tdata & "_" & pSwitch
    tNewNameB = tItem & "_" & "c" & "_" & tdata & "_" & pSwitch
    the itemDelimiter = tDelim
    me.getPropRef(#pSprList, 2).locZ = me.getPropRef(#pSprList, 1).locZ + 2
    if memberExists(tNewNameA) then
      tmember = member(getmemnum(tNewNameA))
      me.getPropRef(#pSprList, 2).castNum = tmember.number
      me.getPropRef(#pSprList, 2).width = tmember.width
      me.getPropRef(#pSprList, 2).height = tmember.height
    end if
    pActive = 0
  end if
  exit
end

on setOn(me)
  pSwitch = 1
  pActive = 1
  exit
end

on setOff(me)
  pSwitch = 0
  pActive = 1
  exit
end

on select(me)
  if the doubleClick then
    if pSwitch then
      tStr = "OFF"
    else
      tStr = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:tStr])
  end if
  return(1)
  exit
end