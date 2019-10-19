on prepare(me, tdata)
  if tdata.findPos(#stuffdata) then
    pRollDir = integer(tdata.getAt(#stuffdata))
    if pRollDir < 0 or pRollDir > 7 then
      pRollDir = 0
    end if
  end if
  pChanges = 1
  pRolling = 0
  me.update()
  return(1)
  exit
end

on diceThrown(me, tValue)
  if tValue >= 0 then
    pRollDir = tValue
    pRolling = 1
    pChanges = 1
  else
    me.startRolling()
  end if
  return(1)
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
  return(1)
  exit
end

on roll(me)
  if pRolling and the milliSeconds - pRollingStartTime < 3300 or voidp(pRollDir) then
    tTime = the milliSeconds - pRollingStartTime
    f = tTime * 0 / 0 * 3.14159 * 0
    pRollAnimDir = pRollAnimDir + cos(f) * float(pRollingDirection)
    me.setProp(#pDirection, 1, abs(integer(pRollAnimDir) mod 8))
    me.setProp(#pDirection, 2, abs(integer(pRollAnimDir) mod 8))
  else
    pRolling = 0
    pChanges = 1
  end if
  return(1)
  exit
end

on startRolling(me)
  pRollDir = void()
  pRollingStartTime = the milliSeconds
  pRollAnimDir = me.getProp(#pDirection, 1)
  if random(2) = 1 then
    pRollingDirection = 1
  else
    pRollingDirection = -1
  end if
  pRolling = 1
  pChanges = 1
  return(1)
  exit
end

on select(me)
  if the doubleClick and pRolling = 0 then
    getThread(#room).getComponent().getRoomConnection().send("THROW_DICE", [#integer:integer(me.getID())])
  end if
  return(1)
  exit
end