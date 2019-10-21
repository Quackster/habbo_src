property pActive, pStep, pAnimFrame, pSprite

on construct me 
  pActive = 1
  return TRUE
end

on deconstruct me 
  pActive = 0
  me.removeSprites()
  return TRUE
end

on define me, tScreenLoc, tlocz 
  pStep = 0
  pAnimFrame = 1
  me.createSprites(tScreenLoc, tlocz)
  return TRUE
end

on update me 
  if not pActive then
    return FALSE
  end if
  pStep = not pStep
  if pStep then
    return TRUE
  end if
  if (pAnimFrame = 4) then
    return(me.deconstruct())
  end if
  pSprite.member = member(getmemnum("hit" & pAnimFrame))
  pAnimFrame = (pAnimFrame + 1)
  return TRUE
end

on createSprites me, tScreenLoc, tlocz 
  pSprite = sprite(reserveSprite("snowball_hit_" & getUniqueID()))
  pSprite.member = member(getmemnum("hit1"))
  pSprite.locZ = tlocz
  pSprite.ink = 8
  pSprite.loc = point(tScreenLoc.getAt(1), tScreenLoc.getAt(2))
  return TRUE
end

on removeSprites me 
  if ilk(pSprite) <> #sprite then
    return FALSE
  end if
  releaseSprite(pSprite.spriteNum)
  pSprite = void()
  return TRUE
end
