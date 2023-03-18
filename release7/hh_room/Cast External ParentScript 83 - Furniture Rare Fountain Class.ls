property pChanges, pActive, pTimer, pNextChange

on prepare me, tdata
  if tdata["CHANNEL"] = "ON" then
    pActive = 1
  else
    pActive = 0
  end if
  pChanges = 1
  pTimer = 0
  pNextChange = 6
  return 1
end

on updateStuffdata me, tProp, tValue
  if tValue = "OFF" then
    pActive = 0
  else
    pActive = 1
  end if
  me.pSprList[2].castNum = 0
  pChanges = 1
end

on update me
  if me.pSprList.count = 0 then
    return 
  end if
  if not pChanges then
    return 
  end if
  if pActive then
    pTimer = pTimer + 1
    if pTimer < pNextChange then
      return 
    end if
    pTimer = 0
    pNextChange = 6
    tNewName = "rare_fountain_b_0_1_1_0_" & random(3)
    if memberExists(tNewName) then
      me.pSprList[2].castNum = getmemnum(tNewName)
      me.pSprList[2].width = me.pSprList[2].member.width
      me.pSprList[2].height = me.pSprList[2].member.height
      me.pSprList[2].locZ = me.pSprList[1].locZ + 2
    end if
  else
    me.pSprList[2].castNum = 0
    pChanges = 0
  end if
end

on setOn me
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "FIREON" & "/" & "ON")
end

on setOff me
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "FIREON" & "/" & "OFF")
end

on select me
  if the doubleClick then
    if pActive then
      me.setOff()
    else
      me.setOn()
    end if
  end if
  return 1
end
