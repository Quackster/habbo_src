property pSprite, pDelayCounter, pDirection, pBicycleTypes, pBaseCastName, pStartPoint, pOffset, pAnimFrame

on define me, tsprite
  pSprite = tsprite
  tItemDeLimiter = the itemDelimiter
  the itemDelimiter = "_"
  pDirection = pSprite.member.name.item[2]
  the itemDelimiter = tItemDeLimiter
  pBicycleTypes = ["a", "b", "c"]
  pStartPoint = pSprite.loc
  pOffset = [2, -1]
  if pDirection = "front" then
    pOffset = pOffset * -1
  end if
  me.reset()
  return 1
end

on reset me
  pBaseCastName = "bicycle_" & pDirection & "_" & pBicycleTypes[random(3)] & "_"
  pDelayCounter = random(200)
  pSprite.castNum = getmemnum(pBaseCastName & "1")
  pSprite.loc = pStartPoint
  return 1
end

on update me
  if pDelayCounter > 0 then
    pDelayCounter = pDelayCounter - 1
    return 1
  end if
  pAnimFrame = pAnimFrame + 1
  if pAnimFrame = 4 then
    pAnimFrame = 1
  end if
  pSprite.castNum = getmemnum(pBaseCastName & pAnimFrame)
  pSprite.loc = pSprite.loc + pOffset
  if pDirection = "front" then
    if pSprite.locV > 440 then
      return me.reset()
    end if
  else
    if pSprite.locV < 390 then
      return me.reset()
    end if
  end if
  return 1
end
