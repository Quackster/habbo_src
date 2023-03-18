property pChanges, pActive, pTimer, pNextChange

on prepare me, tdata
  if tdata[#stuffdata] = "ON" then
    pActive = 1
  else
    pActive = 0
  end if
  pChanges = 1
  pTimer = 0
  pNextChange = random(36) + 12
  return 1
end

on updateStuffdata me, tValue
  if tValue = "OFF" then
    pActive = 0
  else
    pActive = 1
  end if
  if me.pSprList.count < 2 then
    return 0
  end if
  me.pSprList[2].castNum = 0
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
    if me.pXFactor = 32 then
      tClass = "s_red_tv"
    else
      tClass = "red_tv"
    end if
    pTimer = pTimer + 1
    if pTimer < pNextChange then
      return 
    end if
    pTimer = 0
    pNextChange = random(36) + 12
    tNewName = tClass & "_b_0_1_1_2_" & random(8) - 1
    if memberExists(tNewName) then
      tmember = member(getmemnum(tNewName))
      me.pSprList[2].castNum = tmember.number
      me.pSprList[2].width = tmember.width
      me.pSprList[2].height = tmember.height
      me.pSprList[2].locZ = me.pSprList[1].locZ + 2
    end if
  else
    me.pSprList[2].castNum = 0
    pChanges = 0
  end if
end

on setOn me
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: "ON"])
end

on setOff me
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: "OFF"])
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
