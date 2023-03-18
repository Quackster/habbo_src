property pSprite, pEventList

on construct me
  pEventList = [:]
  pSprite = sprite(reserveSprite(me.getID()))
  if pSprite.spriteNum = 0 then
    return 0
  end if
  pSprite.member = member(getmemnum("null"))
  pSprite.rect = rect(-90, -90, -80, -80)
  pSprite.locZ = 20000000
  pSprite.blend = 0
  getSpriteManager().setEventBroker(pSprite.spriteNum, me.getID())
  return 1
end

on deconstruct me
  removePrepare(me.getID())
  getSpriteManager().releaseSprite(pSprite.spriteNum)
  return 1
end

on registerEvent me, tObj, tEvent, tMethod
  pEventList[tEvent] = [tObj, tMethod]
  pSprite.registerProcedure(#eventProcDefault, me.getID(), tEvent)
  pSprite.visible = 1
  return receivePrepare(me.getID())
end

on unregisterEvent me, tEvent
  pEventList.deleteProp(tEvent)
  if pEventList.count = 0 then
    removePrepare(me.getID())
    pSprite.visible = 0
    pSprite.rect = rect(-90, -90, -80, -80)
  end if
  return 1
end

on prepare me
  pSprite.loc = the mouseLoc - [5, 5]
end

on eventProcDefault me, tEvent, tSprID, tParam
  tTarget = pEventList[tEvent]
  if voidp(tTarget) then
    return pSprite.removeProcedure(tEvent)
  end if
  return call(tTarget[2], tTarget[1])
end

on null me
end
