property pSprite, pOffset, pWaitTrainTimer

on define me, tsprite
  pSprite = tsprite
  me.reset()
end

on reset me
  tTrainSpeed = random(30) + 15
  pSprite.loc = point(613, 378)
  pOffset = [-2, -1] * random(2)
  pWaitTrainTimer = random(250)
end

on update me
  if pWaitTrainTimer > 0 then
    pWaitTrainTimer = pWaitTrainTimer - 1
    return 0
  end if
  if pSprite.locH > 100 then
    pSprite.loc = pSprite.loc + pOffset
  else
    me.reset()
  end if
end
