property pChanges, pRolling, pRollDir, pRollingDirection, pRollingStartTime, pRollAnimDir

on prepare me, tdata
  if tdata.findPos(#stuffdata) then
    pRollDir = integer(tdata[#stuffdata])
    if (pRollDir < 0) or (pRollDir > 7) then
      pRollDir = 0
    end if
  end if
  pChanges = 1
  pRolling = 0
  me.update()
  return 1
end

on diceThrown me, tValue
  if tValue >= 0 then
    pRollDir = tValue
    pRolling = 1
    pChanges = 1
  else
    me.startRolling()
  end if
  return 1
end

on update me
  if not pChanges then
    return 
  end if
  if me.pSprList.count < 1 then
    return 
  end if
  if pRolling then
    me.roll()
    me.solveMembers()
    me.moveBy(0, 0, 0)
    pChanges = 1
  else
    me.pDirection[1] = pRollDir
    me.pDirection[2] = pRollDir
    me.solveMembers()
    me.moveBy(0, 0, 0)
    pChanges = 0
  end if
  return 1
end

on roll me
  if (pRolling and ((the milliSeconds - pRollingStartTime) < 3300)) or voidp(pRollDir) then
    tTime = the milliSeconds - pRollingStartTime
    f = tTime * 1.0 / 3200.0 * 3.14158999999999988 * 0.5
    pRollAnimDir = pRollAnimDir + (cos(f) * float(pRollingDirection))
    me.pDirection[1] = abs(integer(pRollAnimDir) mod 8)
    me.pDirection[2] = abs(integer(pRollAnimDir) mod 8)
  else
    pRolling = 0
    pChanges = 1
  end if
  return 1
end

on startRolling me
  pRollDir = VOID
  pRollingStartTime = the milliSeconds
  pRollAnimDir = me.pDirection[1]
  if random(2) = 1 then
    pRollingDirection = 1
  else
    pRollingDirection = -1
  end if
  pRolling = 1
  pChanges = 1
  return 1
end

on select me
  if the doubleClick and (pRolling = 0) then
    getThread(#room).getComponent().getRoomConnection().send("THROW_DICE", me.getID())
  end if
  return 1
end
