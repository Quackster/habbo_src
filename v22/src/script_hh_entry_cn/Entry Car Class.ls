property pSprite, pOffset, pDirection, pmodel, pDelayCounter

on define me, tsprite, tCount
  if ((tCount mod 2) = 1) then
    tDirection = #right
  else
    tDirection = #left
  end if
  pSprite = tsprite
  pOffset = [0, 0]
  pDirection = tDirection
  me.reset()
  return 1
end

on reset me
  if (random(2) = 2) then
    pDelayCounter = (random(25) * 10)
  else
    pDelayCounter = 0
  end if
  pmodel = ["car", "car_b", "bus"][random(3)]
  if (pDirection = #left) then
    pSprite.castNum = getmemnum((pmodel & "1"))
    pSprite.flipH = 0
    pSprite.flipV = 0
    pSprite.loc = point(735, 391)
    pOffset = [-2, 1]
  else
    pSprite.castNum = getmemnum((pmodel & "2"))
    pSprite.flipH = 1
    pSprite.loc = point(562, 506)
    pOffset = [2, -1]
  end if
  pSprite.width = pSprite.member.width
  pSprite.height = pSprite.member.height
  pSprite.ink = 41
  pSprite.backColor = (random(150) + 20)
  return 1
end

on update me
  if (pDelayCounter > 0) then
    pDelayCounter = (pDelayCounter - 1)
    return 1
  end if
  pSprite.loc = (pSprite.loc + pOffset)
  if (pDirection = #left) then
    if (pSprite.locV > 510) then
      return me.reset()
    end if
  else
    if (pDirection = #right) then
      if (pSprite.locV < 380) then
        return me.reset()
      end if
    end if
  end if
  return 1
end
