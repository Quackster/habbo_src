property pMaxFrames, pDelay, pFrame, pItem, pData

on prepare me, tdata 
  if me.count(#pSprList) < 1 then
    return(0)
  end if
  pMaxFrames = 6
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tName = member.name
  pItem = tName.getProp(#item, 1, tName.count(#item) - 6)
  pPart = tName.getProp(#item, tName.count(#item) - 5)
  pData = tName.getProp(#item, tName.count(#item) - 4, tName.count(#item) - 1)
  the itemDelimiter = tDelim
  pFrame = random(pMaxFrames) - 1
  pDelay = 0
  me.setAnimMembersToFrame()
  pTimer = 1
  return(1)
end

on update me 
  pDelay = pDelay + 1
  if pDelay > 4 then
    pFrame = pFrame + 1 mod pMaxFrames
    me.setAnimMembersToFrame(pFrame)
    pDelay = 0
  end if
end

on setAnimMembersToFrame me, tFrame 
  if me.count(#pSprList) < 1 then
    return(0)
  end if
  tLayerChar = "a"
  tNewName = pItem & "_" & tLayerChar & "_" & pData & "_" & tFrame
  if memberExists(tNewName) then
    tmember = member(getmemnum(tNewName))
    me.getPropRef(#pSprList, 1).castNum = tmember.number
    me.getPropRef(#pSprList, 1).width = tmember.width
    me.getPropRef(#pSprList, 1).height = tmember.height
  end if
end
