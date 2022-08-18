property pActive, pSprite, pStep, pAnimFrame

on construct me
  pActive = 1
  return 1
end

on deconstruct me
  pActive = 0
  me.removeSprites()
  return 1
end

on define me, tScreenLoc, tlocz
  pStep = 0
  pAnimFrame = 1
  me.createSprites(tScreenLoc, tlocz)
  return 1
end

on update me
  if not pActive then
    return 0
  end if
  pStep = not pStep
  if pStep then
    return 1
  end if
  if (pAnimFrame = 4) then
    return me.deconstruct()
  end if
  pSprite.member = member(getmemnum(("hit" & pAnimFrame)))
  pAnimFrame = (pAnimFrame + 1)
  return 1
end

on createSprites me, tScreenLoc, tlocz
  pSprite = sprite(reserveSprite(("snowball_hit_" & getUniqueID())))
  pSprite.member = member(getmemnum("hit1"))
  pSprite.locZ = tlocz
  pSprite.ink = 8
  pSprite.loc = point(tScreenLoc[1], tScreenLoc[2])
  return 1
end

on removeSprites me
  if (ilk(pSprite) <> #sprite) then
    return 0
  end if
  releaseSprite(pSprite.spriteNum)
  pSprite = VOID
  return 1
end
