property pmode, pSkipAmount, pLocAdjust, pSprite, pActive, pSkipCounter, pMemberID, pDirection, pAnimFrame

on construct me 
  pLocAdjust = point(0, 0)
  pActive = 1
  return TRUE
end

on deconstruct me 
  pActive = 0
  me.removeSprites()
  return TRUE
end

on define me, tMode, tScreenLoc, tlocz, tMemberId, tProps, tDirection 
  pmode = tMode
  pAnimFrame = 0
  pMemberID = tMemberId
  if voidp(tDirection) then
    pDirection = 0
  else
    pDirection = tDirection
  end if
  if tProps.getAt(#loc) <> void() then
    pLocAdjust = tProps.getAt(#loc)
    tProps.deleteProp(#loc)
  end if
  if pmode <> #loop then
    if (pmode = #once) then
      pSkipAmount = 2
    else
      if (pmode = #once_slow) then
        pSkipAmount = 10
      end if
    end if
    pSkipCounter = pSkipAmount
    me.createSprites(tScreenLoc, tlocz, tProps, tDirection)
    return TRUE
  end if
end

on setLocation me, tScreenLoc 
  tScreenLoc.setAt(1, (tScreenLoc.getAt(1) + pLocAdjust.locH))
  tScreenLoc.setAt(2, (tScreenLoc.getAt(2) + pLocAdjust.locV))
  if pSprite <> void() then
    pSprite.loc = point(tScreenLoc.getAt(1), tScreenLoc.getAt(2))
  end if
  return TRUE
end

on update me 
  if not pActive then
    return TRUE
  end if
  pSkipCounter = (pSkipCounter + 1)
  if pSkipCounter < pSkipAmount then
    return TRUE
  end if
  pSkipCounter = 0
  tMemNum = getmemnum(pMemberID & pDirection & "_" & pAnimFrame)
  if (tMemNum = 0) then
    if (pmode = #loop) then
      pAnimFrame = 0
      me.update()
      return()
    else
      return(me.deconstruct())
    end if
  end if
  pSprite.member = member(tMemNum)
  if pSprite.width <> member(tMemNum).image.width then
    pSprite.width = member(tMemNum).image.width
  end if
  if pSprite.height <> member(tMemNum).image.height then
    pSprite.height = member(tMemNum).image.height
  end if
  pAnimFrame = (pAnimFrame + 1)
  return TRUE
end

on createSprites me, tScreenLoc, tlocz, tProps, tDirection 
  pSprite = sprite(reserveSprite(pMemberID & getUniqueID()))
  pSprite.locZ = tlocz
  if (tProps.getAt(#ink) = void()) then
    pSprite.ink = 8
  else
    pSprite.ink = tProps.getAt(#ink)
  end if
  me.setLocation(tScreenLoc)
  me.update()
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
