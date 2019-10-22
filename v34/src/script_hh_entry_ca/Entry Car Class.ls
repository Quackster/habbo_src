property pDirection, pSprite, pIndex, pPausedTime, pOffset, pTurnPnt

on define me, tsprite, tCount 
  pIndex = (tCount - 1)
  if (tCount mod 2) then
    tdir = #right
  else
    tdir = #left
  end if
  pSprite = tsprite
  pOffset = [0, 0]
  pTurnPnt = 0
  pDirection = tdir
  me.reset()
  return TRUE
end

on reset me 
  tmodel = ["car2", "car_b2"].getAt(random(2))
  if (pDirection = #left) then
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 0
    pSprite.loc = point(782, 497)
    pOffset = [-2, -1]
    pTurnPnt = 494
  else
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 1
    pSprite.loc = point(217, 505)
    pOffset = [2, -1]
    pTurnPnt = 487
  end if
  pSprite.width = pSprite.member.width
  pSprite.height = pSprite.member.height
  pSprite.ink = 41
  pSprite.backColor = (random(150) + 20)
  pPausedTime = ((pIndex * 30) + random(50))
end

on update me 
  if pPausedTime > 0 then
    pPausedTime = (pPausedTime - 1)
    return FALSE
  end if
  pSprite.loc = (pSprite.loc + pOffset)
  if (pSprite.locH = pTurnPnt) then
    pOffset.setAt(2, -pOffset.getAt(2))
    tMemName = pSprite.member.name
    tDirNum = integer(tMemName.getProp(#char, length(tMemName)))
    tDirNum = (not (tDirNum - 1) + 1)
    tMemName = tMemName.getProp(#char, 1, (length(tMemName) - 1)) & tDirNum
    pSprite.castNum = getmemnum(tMemName)
  end if
  if pSprite.locV > 510 then
    if (random(2) = 1) then
      pDirection = #left
    else
      pDirection = #right
    end if
    return(me.reset())
  end if
end
