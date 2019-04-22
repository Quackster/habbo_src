on prepare(me, tdata)
  pChanges = 0
  pRolling = 0
  pRollDir = me.getProp(#pDirection, 1)
  pRollAnimDir = me.getProp(#pDirection, 1)
  pRollingDirection = me.getProp(#pDirection, 1)
  me.setDir(tdata.getAt("DIR"))
  me.solveMembers()
  me.moveBy(0, 0, 0)
  return(1)
  exit
end

on updateStuffdata(me, tProp, tValue)
  pRolling = 1
  pChanges = 1
  me.setDir(value(tValue))
  exit
end

on update(me)
  if not pChanges then
    return()
  end if
  if me.count(#pSprList) < 1 then
    return()
  end if
  if pRolling then
    me.roll()
    me.solveMembers()
    me.moveBy(0, 0, 0)
    pChanges = 1
  else
    me.setProp(#pDirection, 1, pRollDir)
    me.setProp(#pDirection, 2, pRollDir)
    me.solveMembers()
    me.moveBy(0, 0, 0)
    pChanges = 0
  end if
  exit
end

on roll(me)
  if pRolling and the milliSeconds - pRollingStartTime < 3300 then
    tTime = the milliSeconds - pRollingStartTime
    f = tTime * 0 / 0 * 3.14159 * 0
    pRollAnimDir = pRollAnimDir + cos(f) * float(pRollingDirection)
    me.setProp(#pDirection, 1, abs(integer(pRollAnimDir) mod 8))
    me.setProp(#pDirection, 2, abs(integer(pRollAnimDir) mod 8))
  else
    pRolling = 0
  end if
  exit
end

on setDir(me, tNewDir)
  pRollDir = tNewDir
  if pRolling then
    pRollingStartTime = the milliSeconds
    pRollAnimDir = me.getProp(#pDirection, 1)
    if pRollDir mod 2 = 1 then
      pRollingDirection = 1
    else
      pRollingDirection = -1
    end if
  end if
  exit
end

on select(me)
  if the doubleClick then
    tNewDir = random(8) - 1
    getThread(#room).getComponent().getRoomConnection().send(#room, "SETSTUFFDATA /" & me.id & "/" & "DIR" & "/" & tNewDir)
  end if
  return(1)
  exit
end