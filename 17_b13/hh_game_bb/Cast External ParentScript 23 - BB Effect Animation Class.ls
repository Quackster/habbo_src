property pActive, pSprite, pMemberID, pmode, pLocAdjust, pSkipAmount, pSkipCounter, pAnimFrame, pDirection

on construct me
  pLocAdjust = point(0, 0)
  pActive = 1
  return 1
end

on deconstruct me
  pActive = 0
  me.removeSprites()
  return 1
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
  if tProps[#loc] <> VOID then
    pLocAdjust = tProps[#loc]
    tProps.deleteProp(#loc)
  end if
  case pmode of
    #loop, #once:
      pSkipAmount = 2
    #once_slow:
      pSkipAmount = 10
  end case
  pSkipCounter = pSkipAmount
  me.createSprites(tScreenLoc, tlocz, tProps, tDirection)
  return 1
end

on setLocation me, tScreenLoc
  tScreenLoc[1] = tScreenLoc[1] + pLocAdjust.locH
  tScreenLoc[2] = tScreenLoc[2] + pLocAdjust.locV
  if pSprite <> VOID then
    pSprite.loc = point(tScreenLoc[1], tScreenLoc[2])
  end if
  return 1
end

on update me
  if not pActive then
    return 1
  end if
  pSkipCounter = pSkipCounter + 1
  if pSkipCounter < pSkipAmount then
    return 1
  end if
  pSkipCounter = 0
  tMemNum = getmemnum(pMemberID & pDirection & "_" & pAnimFrame)
  if tMemNum = 0 then
    if pmode = #loop then
      pAnimFrame = 0
      me.update()
      return 
    else
      return me.deconstruct()
    end if
  end if
  pSprite.member = member(tMemNum)
  if pSprite.width <> member(tMemNum).image.width then
    pSprite.width = member(tMemNum).image.width
  end if
  if pSprite.height <> member(tMemNum).image.height then
    pSprite.height = member(tMemNum).image.height
  end if
  pAnimFrame = pAnimFrame + 1
  return 1
end

on createSprites me, tScreenLoc, tlocz, tProps, tDirection
  pSprite = sprite(reserveSprite(pMemberID & getUniqueID()))
  pSprite.locZ = tlocz
  if tProps[#ink] = VOID then
    pSprite.ink = 8
  else
    pSprite.ink = tProps[#ink]
  end if
  me.setLocation(tScreenLoc)
  me.update()
  return 1
end

on removeSprites me
  if ilk(pSprite) <> #sprite then
    return 0
  end if
  releaseSprite(pSprite.spriteNum)
  pSprite = VOID
  return 1
end
