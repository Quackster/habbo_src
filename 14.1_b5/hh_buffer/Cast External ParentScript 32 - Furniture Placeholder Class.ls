property pDelay, pFrame, pItem, pPart, pData, pMaxFrames

on prepare me, tdata
  if me.pSprList.count < 1 then
    return 0
  end if
  pMaxFrames = 6
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tName = me.pSprList[1].member.name
  pItem = tName.item[1..tName.item.count - 6]
  pPart = tName.item[tName.item.count - 5]
  pData = tName.item[tName.item.count - 4..tName.item.count - 1]
  the itemDelimiter = tDelim
  pFrame = random(pMaxFrames) - 1
  pDelay = 0
  me.setAnimMembersToFrame()
  pTimer = 1
  return 1
end

on update me
  pDelay = pDelay + 1
  if pDelay > 4 then
    pFrame = (pFrame + 1) mod pMaxFrames
    me.setAnimMembersToFrame(pFrame)
    pDelay = 0
  end if
end

on setAnimMembersToFrame me, tFrame
  if me.pSprList.count < 1 then
    return 0
  end if
  tLayerChar = "a"
  tNewName = pItem & "_" & tLayerChar & "_" & pData & "_" & tFrame
  if memberExists(tNewName) then
    tmember = member(getmemnum(tNewName))
    me.pSprList[1].castNum = tmember.number
    me.pSprList[1].width = tmember.width
    me.pSprList[1].height = tmember.height
  end if
end
