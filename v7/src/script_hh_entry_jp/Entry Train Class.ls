on define(me, tmember)
  pMember = tmember
  pMember.image = image(314, 166, 32)
  pTrainImg = image.duplicate()
  pAnimStep = 4
  pAnimPhase = 0
  pLastUpdate = the milliSeconds + 10 * 1000 + random(10000)
  return(1)
  exit
end

on update(me)
  if the milliSeconds - pLastUpdate > 66 then
    tOffset = pAnimStep * pAnimPhase
    tCopyRect = rect(-314, -166, 0, 0) + rect(2 * tOffset, tOffset, 2 * tOffset, tOffset)
    pMember.fill(image.rect, rgb(255, 255, 255))
    pTrainImg.copyPixels(pMember, image.rect, tCopyRect, [#ink:0])
    pAnimPhase = pAnimPhase + 1
    pLastUpdate = the milliSeconds
    if pAnimPhase > 82 then
      pAnimPhase = 0
      pLastUpdate = the milliSeconds + 4 * 1000 + random(15000)
    end if
  end if
  exit
end