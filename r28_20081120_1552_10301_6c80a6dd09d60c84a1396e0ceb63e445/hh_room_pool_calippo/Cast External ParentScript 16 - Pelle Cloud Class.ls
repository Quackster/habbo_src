property pStartPntX, pSprite, pAnimFrm, pSpeed

on prepare me, tsprite, tStartPntX
  pSprite = tsprite
  pStartPntX = tStartPntX
  tRand = random(tStartPntX)
  if (tRand mod 2) <> 0 then
    tRand = tRand - 1
  end if
  pSprite.locH = tRand
  pSprite.locV = (tStartPntX - tRand) / 2
  pSpeed = random(3) - 1
  tRand = random(5)
  tmember = member(getmemnum("pilvi" & tRand))
  pSprite.member = tmember
  pSprite.width = tmember.width
  pSprite.height = tmember.height
  return 1
end

on update me
  pAnimFrm = pAnimFrm + 1
  if (pAnimFrm mod pSpeed) = 0 then
    pSprite.locH = pSprite.locH - 1
    if (pSprite.locH mod 2) = 0 then
      pSprite.locV = pSprite.locV + 1
    end if
    if pSprite.locH < -45 then
      me.reset()
    end if
  end if
end

on reset me
  pSpeed = random(3) - 1
  tmember = member(getmemnum("pilvi" & random(5)))
  pSprite.locH = pStartPntX
  pSprite.locV = -34
  pSprite.member = tmember
  pSprite.width = tmember.width
  pSprite.height = tmember.height
end
