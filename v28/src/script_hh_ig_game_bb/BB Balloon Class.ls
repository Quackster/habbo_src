property pMember, pSprite, pLoc, pProps

on construct me 
  pProps = [:]
  return TRUE
end

on deconstruct me 
  if not voidp(pMember) then
    removeMember(pMember.name)
  end if
  pSprite = void()
  pMember = void()
  return TRUE
end

on defineBalloon me 
  pSprite = sprite(me.GET(#sprite))
  pMember = member(me.GET(#member))
  pLoc = me.GET(#loc)
  pSprite.loc = pLoc
  pSprite.member = pMember
  return TRUE
end

on UpdateBalloonPos me, tLocV 
  if voidp(pSprite) then
    return FALSE
  end if
  if pLoc.locV < 0 then
    return FALSE
  end if
  pLoc = (pLoc + point(0, tLocV))
  pSprite.loc = pLoc
end

on removeBalloon me 
  if voidp(pSprite) then
    return FALSE
  end if
  pSprite.loc = point(0, -1000)
  removeEventBroker(pSprite.spriteNum)
  return TRUE
end

on hideBalloon me 
  if voidp(pSprite) then
    return FALSE
  end if
  pSprite.visible = 0
  return TRUE
end

on showBalloon me 
  if voidp(pSprite) then
    return FALSE
  end if
  pSprite.visible = 1
  return TRUE
end

on set me, tKey, tValue 
  pProps.setAt(tKey, tValue)
  return TRUE
end

on GET me, tKey 
  tValue = pProps.getAt(tKey)
  if voidp(tValue) then
    tValue = 0
  end if
  return(tValue)
end
