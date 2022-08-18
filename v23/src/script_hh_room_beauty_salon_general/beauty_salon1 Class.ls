property pAnimThisUpdate, pSin, pSin2, pAnimTimer, pSpriteList, pOrigLocs

on construct me
  pSin = 0.0
  pSin2 = 0.0
  pAnimTimer = the timer
  pSpriteList = []
  pOrigLocs = []
  pAnimThisUpdate = 10
  return 1
end

on deconstruct me
  return removeUpdate(me.getID())
end

on prepare me
  return receiveUpdate(me.getID())
end

on update me
  pAnimThisUpdate = (pAnimThisUpdate + 1)
  if (pAnimThisUpdate < 2) then
    return 1
  else
    pAnimThisUpdate = 0
  end if
  pSin = (pSin + 0.08)
  pSin2 = (pSin2 + 0.05)
  if (pSpriteList = []) then
    return me.getSpriteList()
  end if
  return me.fullRotation(35, 35, 35, 35, 35, 35)
end

on fullRotation me, tGx, tGy, tYx, tYy, tRx, try, tGoffset, tYOffset, tRoffset
  if (tGoffset = VOID) then
    tGoffset = point(0, 0)
  end if
  if (tYOffset = VOID) then
    tYOffset = point(0, 0)
  end if
  if (tRoffset = VOID) then
    tRoffset = point(0, 0)
  end if
  pSpriteList[1].loc = ((pOrigLocs[1] + tGoffset) + point((sin(pSin2) * tGx), (cos(pSin2) * tGy)))
  pSpriteList[2].loc = ((pOrigLocs[2] + tYOffset) + (point((cos(pSin) * tYx), (sin(pSin) * tYy)) * 1.69999999999999996))
  pSpriteList[3].loc = ((pOrigLocs[3] + tRoffset) + (point((sin((pSin2 + 0.5)) * tRx), (cos((pSin2 - 0.29999999999999999)) * try)) * 1.30000000000000004))
  return 1
end

on getSpriteList me
  pSpriteList = []
  tObj = getThread(#room).getInterface().getRoomVisualizer()
  if (tObj = 0) then
    return 0
  end if
  repeat with i = 1 to 3
    tSp = tObj.getSprById(("light" & i))
    if (tSp < 1) then
      return 0
    end if
    pSpriteList.add(tSp)
  end repeat
  pOrigLocs = [pSpriteList[1].loc, pSpriteList[2].loc, pSpriteList[3].loc]
  repeat with i = 1 to pSpriteList.count
    removeEventBroker(pSpriteList[i].spriteNum)
  end repeat
  return 1
end
