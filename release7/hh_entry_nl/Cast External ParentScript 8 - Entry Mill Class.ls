property pSprite, pFrameCount

on define me, tSprite, tNum
  pSprite = tSprite
  pFrameCount = random(8)
  return 1
end

on update me
  tFrameList = [0, 1, 2, 3, 4, 5, 6, 7]
  tImage = getmemnum("windpower_nl_" & tFrameList[pFrameCount])
  pSprite.member = tImage
  pSprite.width = pSprite.member.width
  pSprite.height = pSprite.member.height
  if pFrameCount = 8 then
    pFrameCount = 0
  end if
  pFrameCount = pFrameCount + 1
end
