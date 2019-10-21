on define(me, tSprite)
  pSprite = tSprite
  pTurnPoint = 332
  pVertDir = -1
  pSprite.flipH = 0
  return(1)
  exit
end

on update(me)
  pSprite.locH = pSprite.locH + 1
  if pSprite.locH mod 2 = 0 then
    pSprite.locV = pSprite.locV + pVertDir
  end if
  if pSprite.locH > pTurnPoint then
    me.turn()
  end if
  if pSprite.locH > the stageRight - the stageLeft + 30 then
    me.initCloud()
  end if
  exit
end

on initCloud(me)
  pVertDir = -1
  pSprite.locH = -30
  pSprite.flipH = 0
  pSprite.locV = random(81) + 150
  exit
end

on checkCloud(me)
  if pSprite.locH > pTurnPoint then
    me.turn()
  else
    pVertDir = -1
    pSprite.flipH = 0
  end if
  exit
end

on turn(me)
  pVertDir = 1
  pSprite.flipH = 1
  exit
end