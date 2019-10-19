property pAnimThisUpdate, pSin, pSin2, pSpriteList, pOrigLocs

on construct me 
  pSin = 0
  pSin2 = 0
  pAnimTimer = the timer
  pSpriteList = []
  pOrigLocs = []
  pAnimThisUpdate = 10
  return(1)
end

on deconstruct me 
  return(removeUpdate(me.getID()))
end

on prepare me 
  return(receiveUpdate(me.getID()))
end

on update me 
  pAnimThisUpdate = pAnimThisUpdate + 1
  if pAnimThisUpdate < 2 then
    return(1)
  else
    pAnimThisUpdate = 0
  end if
  pSin = pSin + 0.08
  pSin2 = pSin2 + 0.05
  if pSpriteList = [] then
    return(me.getSpriteList())
  end if
  return(me.fullRotation(35, 35, 35, 35, 35, 35))
end

on fullRotation me, tGx, tGy, tYx, tYy, tRx, try, tGoffset, tYOffset, tRoffset 
  if tGoffset = void() then
    tGoffset = point(0, 0)
  end if
  if tYOffset = void() then
    tYOffset = point(0, 0)
  end if
  if tRoffset = void() then
    tRoffset = point(0, 0)
  end if
  pSpriteList.getAt(1).loc = pOrigLocs.getAt(1) + tGoffset + point((sin(pSin2) * tGx), (cos(pSin2) * tGy))
  pSpriteList.getAt(2).loc = pOrigLocs.getAt(2) + tYOffset + (point((cos(pSin) * tYx), (sin(pSin) * tYy)) * 1.7)
  pSpriteList.getAt(3).loc = pOrigLocs.getAt(3) + tRoffset + (point((sin(pSin2 + 0.5) * tRx), (cos(pSin2 - 0.3) * try)) * 1.3)
  return(1)
end

on getSpriteList me 
  pSpriteList = []
  tObj = getThread(#room).getInterface().getRoomVisualizer()
  if tObj = 0 then
    return(0)
  end if
  i = 1
  repeat while i <= 3
    tSp = tObj.getSprById("light" & i)
    if tSp < 1 then
      return(0)
    end if
    pSpriteList.add(tSp)
    i = 1 + i
  end repeat
  pOrigLocs = [pSpriteList.getAt(1).loc, pSpriteList.getAt(2).loc, pSpriteList.getAt(3).loc]
  i = 1
  repeat while i <= pSpriteList.count
    removeEventBroker(pSpriteList.getAt(i).spriteNum)
    i = 1 + i
  end repeat
  return(1)
end
