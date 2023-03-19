property pChanges, pActive

on prepare me, tdata
  if tdata[#stuffdata] = "O" then
    me.setOn()
    pChanges = 1
  else
    me.setOff()
    pChanges = 0
  end if
  if me.pSprList.count > 1 then
    removeEventBroker(me.pSprList[1].spriteNum)
    removeEventBroker(me.pSprList[2].spriteNum)
  end if
  return 1
end

on updateStuffdata me, tValue
  if tValue = "O" then
    me.setOn()
  else
    me.setOff()
  end if
  pChanges = 1
end

on update me
  if not pChanges then
    return 
  end if
  if me.pSprList.count < 2 then
    return 
  end if
  if pActive then
    repeat with tPart in ["b", "c", "d"]
      me.switchMember(tPart, "1")
    end repeat
  else
    repeat with tPart in ["b", "c", "d"]
      me.switchMember(tPart, "0")
    end repeat
  end if
  pChanges = 0
end

on switchMember me, tPart, tNewMem
  tSprNum = ["a", "b", "c", "d", "e", "f"].getPos(tPart)
  tName = me.pSprList[tSprNum].member.name
  tName = tName.char[1..tName.length - 1] & tNewMem
  if memberExists(tName) then
    tmember = member(getmemnum(tName))
    me.pSprList[tSprNum].castNum = tmember.number
    me.pSprList[tSprNum].width = tmember.width
    me.pSprList[tSprNum].height = tmember.height
  end if
end

on setOn me
  pActive = 1
end

on setOff me
  pActive = 0
end

on select me
  if the doubleClick then
    if pActive then
      tStr = "C"
    else
      tStr = "O"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: tStr])
  end if
  return 1
end
