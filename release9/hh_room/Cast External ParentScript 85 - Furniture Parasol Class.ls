property pChanges, pActive

on prepare me, tdata
  if tdata[#stuffdata] = "O" then
    me.setOn()
    pChanges = 1
  else
    me.setOff()
    pChanges = 0
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
  if me.pSprList.count < 4 then
    return 
  end if
  tCurName = me.pSprList[1].member.name
  tNewName = tCurName.char[1..length(tCurName) - 11]
  tParts = ["a", "b", "c", "d"]
  repeat with i = 1 to 4
    tMemNum = getmemnum(tNewName & tParts[i] & "_" & "0_1_1_0_" & pActive)
    if tMemNum > 0 then
      tmember = member(tMemNum)
      me.pSprList[i].castNum = tMemNum
      me.pSprList[i].width = tmember.width
      me.pSprList[i].height = tmember.height
    end if
  end repeat
  pChanges = 0
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
