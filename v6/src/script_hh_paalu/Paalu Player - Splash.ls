property pSprite, pCounter, pActive

on construct me 
  pActive = 0
  pCounter = 0
  pSprite = sprite(reserveSprite("Paalu splash dir:" && 0))
  pSprite.member = member(getmemnum("splash_" & pCounter))
  return TRUE
end

on deconstruct me 
  if ilk(pSprite, #sprite) then
    releaseSprite(pSprite.spriteNum)
  end if
  pSprite = void()
  return TRUE
end

on define me, tPart, tProps 
  pActive = 0
  pCounter = 0
  pSprite.member = member(getmemnum("splash_" & pCounter))
  pSprite.visible = 0
  pSprite.ink = 36
  return TRUE
end

on reset me 
  pActive = 0
  pSprite.visible = 0
end

on splash me, tloc, tlocz 
  if voidp(pSprite) then
    return FALSE
  end if
  pSprite.loc = tloc
  pSprite.locZ = tlocz
  pSprite.visible = 1
  pCounter = 0
  pActive = 1
end

on prepare me 
  if pActive then
    pSprite.member = member(getmemnum("splash_" & pCounter))
    pCounter = (pCounter + 1)
    if pCounter > 9 then
      pActive = 0
      pCounter = 0
      pSprite.visible = 0
    end if
  end if
end
