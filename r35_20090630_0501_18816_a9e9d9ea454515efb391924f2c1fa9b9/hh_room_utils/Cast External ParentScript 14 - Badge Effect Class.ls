property pFrameCount, pAnimFrame, pStarSpr, pDestRect, pTargetElement

on construct me
  pFrameCount = 0
  pAnimFrame = 9
  if pStarSpr.ilk <> #sprite then
    pStarSpr = sprite(reserveSprite(me.getID()))
    pStarSpr.ink = 36
  end if
  receiveUpdate(me.getID())
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  if pStarSpr.ilk = #sprite then
    releaseSprite(pStarSpr.spriteNum)
  end if
  return 1
end

on Init me, tElem
  pTargetElement = tElem
end

on update me
  pFrameCount = pFrameCount + 1
  if (pFrameCount mod 3) <> 0 then
    return 
  end if
  pDestRect = pTargetElement.getProperty(#rect)
  if pDestRect.ilk = #rect then
    pAnimFrame = pAnimFrame + 1
    if pAnimFrame > 9 then
      pAnimFrame = 1
      tX = random(pDestRect.width) + pDestRect.left
      tY = random(pDestRect.height) + pDestRect.top
      pStarSpr.loc = point(tX, tY)
    end if
    pStarSpr.sprite.member = member(getmemnum("starblink" & pAnimFrame))
    if objectExists(#session) then
      if getObject(#session).GET("badge_visible") = 0 then
        pStarSpr.sprite.visible = 0
      else
        pStarSpr.sprite.visible = 1
      end if
    end if
  end if
end
