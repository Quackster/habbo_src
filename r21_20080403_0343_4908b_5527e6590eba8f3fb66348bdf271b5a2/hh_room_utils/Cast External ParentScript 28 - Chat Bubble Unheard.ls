property pSprite

on construct me
end

on deconstruct me
  if ilk(pSprite) = #sprite then
    releaseSprite(pSprite.spriteNum)
  end if
  pSprite = VOID
end

on define me, tUserID
  tUserObj = getThread(#room).getComponent().getUserObject(tUserID)
  if not tUserObj then
    return 0
  end if
  pSprite = sprite(reserveSprite(me.getID()))
  tPeopleSize = tUserObj.getProperty(#peoplesize)
  if tPeopleSize = "sh" then
    pSprite.member = member(getmemnum("chat_typing_bubble_small"))
    tLocOffset = point(18, -1)
  else
    pSprite.member = member(getmemnum("chat_typing_bubble"))
    tLocOffset = point(20, 0)
  end if
  tloc = tUserObj.getPartLocation("hd")
  pSprite.loc = tloc + tLocOffset
  pSprite.ink = 8
  pSprite.locZ = getIntVariable("window.default.locz") - 4000
  receiveUpdate(me.getID())
end

on update me
  pSprite.loc = pSprite.loc + point(0, -10)
  if pSprite.blend > 0 then
    pSprite.blend = pSprite.blend - 10
  end if
  if pSprite.locV < -50 then
    removeUpdate(me.getID())
    me.deconstruct()
  end if
end
