on define(me, tSprite, tNum)
  pSprite = tSprite
  pFrameCount = random(8)
  return(1)
  exit
end

on update(me)
  tFrameList = [0, 1, 2, 3, 4, 5, 6, 7]
  tImage = getmemnum("windpower_nl_" & tFrameList.getAt(pFrameCount))
  pSprite.member = tImage
  pSprite.width = member.width
  pSprite.height = member.height
  if pFrameCount = 8 then
    pFrameCount = 0
  end if
  pFrameCount = pFrameCount + 1
  exit
end