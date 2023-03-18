property pSprite, pMember, pLoc, pProps

on construct me
  pProps = [:]
  return 1
end

on deconstruct me
  if not voidp(pMember) then
    removeMember(pMember.name)
  end if
  if ilk(pSprite) = #sprite then
    removeEventBroker(pSprite.spriteNum)
  end if
  pSprite = VOID
  pMember = VOID
  return 1
end

on defineBalloon me
  pSprite = sprite(me.get(#sprite))
  pMember = member(me.get(#member))
  pLoc = me.get(#loc)
  pSprite.loc = pLoc
  pSprite.member = pMember
  setEventBroker(pSprite.spriteNum, me.get(#ownerID))
  tTargetID = getThread(#room).getInterface().getID()
  pSprite.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
  pSprite.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseEnter)
  pSprite.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseLeave)
  return 1
end

on UpdateBalloonPos me, tLocV
  if pLoc.locV < 0 then
    return 0
  end if
  pLoc = pLoc + point(0, tLocV)
  pSprite.loc = pLoc
end

on removeBalloon me
  if voidp(pSprite) then
    return 0
  end if
  pSprite.loc = point(0, -1000)
  removeEventBroker(pSprite.spriteNum)
  return 1
end

on hideBalloon me
  if voidp(pSprite) then
    return 0
  end if
  pSprite.visible = 0
  return 1
end

on showBalloon me
  if voidp(pSprite) then
    return 0
  end if
  pSprite.visible = 1
  return 1
end

on set me, tKey, tValue
  pProps[tKey] = tValue
  return 1
end

on get me, tKey
  tValue = pProps[tKey]
  if voidp(tValue) then
    tValue = 0
  end if
  return tValue
end
