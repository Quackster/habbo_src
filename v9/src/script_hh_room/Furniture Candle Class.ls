property pActive, pTimer, pLastFrm, pItem, pData

on prepare me, tdata 
  i = 2
  repeat while i <= me.count(#pSprList)
    removeEventBroker(me.getPropRef(#pSprList, i).spriteNum)
    i = 1 + i
  end repeat
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tName = undefined.name
  pItem = tName.getProp(#item, 1, tName.count(#item) - 6)
  pPart = tName.getProp(#item, tName.count(#item) - 5)
  pData = tName.getProp(#item, tName.count(#item) - 4, tName.count(#item) - 1)
  the itemDelimiter = tDelim
  i = 2
  repeat while i <= me.count(#pSprList)
    me.getPropRef(#pSprList, i).locZ = me.getPropRef(#pSprList, i - 1).locZ + 2
    i = 1 + i
  end repeat
  if tdata.getAt(#stuffdata) = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  pLastFrm = 0
  pTimer = 1
  return(1)
end

on updateStuffdata me, tValue 
  if tValue = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
end

on update me 
  if pActive then
    pTimer = not pTimer
    if pTimer then
      tRand = random(4)
      if tRand = pLastFrm then
        tRand = (tRand + 1 mod 4) + 1
      end if
      pLastFrm = tRand
      me.setAnimMembersToFrame(pLastFrm)
    end if
  end if
end

on setOn me 
  pActive = 1
end

on setOff me 
  me.setAnimMembersToFrame(0)
  pActive = 0
end

on select me 
  if the doubleClick then
    if pActive then
      tStr = "OFF"
    else
      tStr = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:tStr])
  end if
  return(1)
end

on setAnimMembersToFrame me, tFrame 
  tCharNum = charToNum("a")
  i = 2
  repeat while i <= me.count(#pSprList)
    tLayerChar = numToChar(tCharNum + i - 1)
    tNewName = pItem & "_" & tLayerChar & "_" & pData & "_" & tFrame
    if memberExists(tNewName) then
      tmember = member(getmemnum(tNewName))
      me.getPropRef(#pSprList, i).castNum = tmember.number
      me.getPropRef(#pSprList, i).width = tmember.width
      me.getPropRef(#pSprList, i).height = tmember.height
    end if
    i = 1 + i
  end repeat
end
