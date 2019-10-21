on construct(me)
  pProps = []
  return(1)
  exit
end

on deconstruct(me)
  if not voidp(pMember) then
    removeMember(pMember.name)
  end if
  pSprite = void()
  pMember = void()
  return(1)
  exit
end

on defineBalloon(me)
  pSprite = sprite(me.GET(#sprite))
  pMember = member(me.GET(#member))
  pLoc = me.GET(#loc)
  pSprite.loc = pLoc
  pSprite.member = pMember
  return(1)
  exit
end

on UpdateBalloonPos(me, tLocV)
  if voidp(pSprite) then
    return(0)
  end if
  if pLoc.locV < 0 then
    return(0)
  end if
  pLoc = pLoc + point(0, tLocV)
  pSprite.loc = pLoc
  exit
end

on removeBalloon(me)
  if voidp(pSprite) then
    return(0)
  end if
  pSprite.loc = point(0, -1000)
  removeEventBroker(pSprite.spriteNum)
  return(1)
  exit
end

on hideBalloon(me)
  if voidp(pSprite) then
    return(0)
  end if
  pSprite.visible = 0
  return(1)
  exit
end

on showBalloon(me)
  if voidp(pSprite) then
    return(0)
  end if
  pSprite.visible = 1
  return(1)
  exit
end

on set(me, tKey, tValue)
  pProps.setAt(tKey, tValue)
  return(1)
  exit
end

on GET(me, tKey)
  tValue = pProps.getAt(tKey)
  if voidp(tValue) then
    tValue = 0
  end if
  return(tValue)
  exit
end