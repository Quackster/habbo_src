property pActive, pTimer, pLastFrm, pItem, pPart, pData

on prepare me, tdata
  repeat with i = 2 to me.pSprList.count
    removeEventBroker(me.pSprList[i].spriteNum)
  end repeat
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tName = me.pSprList[1].member.name
  pItem = tName.item[1..tName.item.count - 6]
  pPart = tName.item[tName.item.count - 5]
  pData = tName.item[tName.item.count - 4..tName.item.count - 1]
  the itemDelimiter = tDelim
  repeat with i = 2 to me.pSprList.count
    me.pSprList[i].locZ = me.pSprList[i - 1].locZ + 2
  end repeat
  if tdata[#stuffdata] = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  pLastFrm = 0
  pTimer = 1
  return 1
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
        tRand = ((tRand + 1) mod 4) + 1
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
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: tStr])
  end if
  return 1
end

on setAnimMembersToFrame me, tFrame
  tCharNum = charToNum("a")
  repeat with i = 2 to me.pSprList.count
    tLayerChar = numToChar(tCharNum + i - 1)
    tNewName = pItem & "_" & tLayerChar & "_" & pData & "_" & tFrame
    if memberExists(tNewName) then
      tmember = member(getmemnum(tNewName))
      me.pSprList[i].castNum = tmember.number
      me.pSprList[i].width = tmember.width
      me.pSprList[i].height = tmember.height
    end if
  end repeat
end
