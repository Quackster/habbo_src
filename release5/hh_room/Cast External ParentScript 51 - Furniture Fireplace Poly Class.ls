property pChanges, pActive, pTiming

on prepare me, tdata
  pChanges = 1
  pTiming = 1
  if tdata["FIREON"] = "ON" then
    setOn(me)
  else
    setOff(me)
  end if
  return 1
end

on updateStuffdata me, tProp, tValue
  if tValue = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  pChanges = 1
end

on update me
  pTiming = not pTiming
  if not pChanges then
    return 
  end if
  if not pTiming then
    return 
  end if
  if me.pSprList.count < 3 then
    return 
  end if
  if pActive then
    tmember = member(getmemnum("fireplace_polyfon_c_0_2_1_4_" & random(10)))
  else
    tmember = member(getmemnum("fireplace_polyfon_c_0_2_1_4_0"))
    pChanges = 0
  end if
  me.pSprList[3].castNum = tmember.number
  me.pSprList[3].width = tmember.width
  me.pSprList[3].height = tmember.height
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
      tStr = "OFF"
    else
      tStr = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send(#room, "SETSTUFFDATA /" & me.getID() & "/" & "FIREON" & "/" & tStr)
  end if
  return 1
end
