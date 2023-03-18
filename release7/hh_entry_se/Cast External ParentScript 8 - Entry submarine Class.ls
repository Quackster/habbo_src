property pSprite, pOffset, pTurnPnt, pDirection, pVertDir, pFrameCount, pCount, pTimer

on define me, tSprite
  pSprite = tSprite
  me.reset()
  return 1
end

on reset me
  pSprite.member = getmemnum("se_submarine_anim_0")
  pFrameCount = 1
  pCount = 0
end

on update me
  tFrameList = [0, 1, 2, 3, 4, 5, 6]
  pCount = pCount + 1
  case 1 of
    ((pCount > 130) and (pCount < 140)):
      if pFrameCount <= count(tFrameList) then
        tImage = getmemnum("se_submarine_anim_" & tFrameList[pFrameCount])
        pSprite.member = tImage
        pFrameCount = pFrameCount + 1
      end if
    (pCount = 140):
      pFrameCount = count(tFrameList)
    (pCount = 141), (pCount = 143), (pCount = 145), (pCount = 147), (pCount = 149):
      pSprite.flipH = random(2) - 1
    ((pCount > 150) and (pCount < 160)):
      if pFrameCount > 1 then
        pFrameCount = pFrameCount - 1
        pSprite.member = getmemnum("se_submarine_anim_" & tFrameList[pFrameCount])
      end if
    (pCount > 160):
      me.reset()
  end case
end
