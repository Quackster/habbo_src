property pSprite, pTurnPoint, pVertDir, pImg, pLoc, pTurnPointList, pCurrentTurnPoint, pCloudDir, pMemName, pCloudMember, pUpdateTimerResetValue, pUpdateTimer

on define me, tsprite, tCount
  pSprite = tsprite
  if memberExists("roomcloud_" & tCount) then
    pCloudMember = member(getmemnum("roomcloud_" & tCount))
  else
    pCloudMember = member(createMember("roomcloud_" & tCount, #bitmap))
  end if
  pImg = pCloudMember.image
  tTemp = the itemDelimiter
  the itemDelimiter = "_"
  pMemName = pSprite.member.name.item[1..pSprite.member.name.item.count - 1]
  tdir = pSprite.member.name.item[pSprite.member.name.item.count]
  the itemDelimiter = tTemp
  if tdir = "left" then
    pVertDir = -1
  else
    pVertDir = 1
  end if
  pTurnPointList = [362]
  pCurrentTurnPoint = 1
  pUpdateTimer = 1
  pUpdateTimerResetValue = 2
  me.initCloud()
  pSprite.member = pCloudMember
  pSprite.width = pCloudMember.width
  pSprite.height = pCloudMember.height
  me.getFirstTurnPoint()
  pCloudDir = pVertDir
  return 1
end

on getFirstTurnPoint me
  repeat with f = 1 to pTurnPointList.count
    if pSprite.locH < pTurnPointList[f] then
      pCurrentTurnPoint = f
      pTurnPoint = pTurnPointList[f]
      exit repeat
    end if
  end repeat
end

on initCloud me
  if pSprite.left > (the stageRight - the stageLeft) then
    pVertDir = -1
    pSprite.locH = -40
    pSprite.locV = 360 - random(230)
    pMemName = pMemName.char[1..pMemName.length - 1] & random(4) - 1
    pCurrentTurnPoint = 1
    pTurnPoint = pTurnPointList[1]
  end if
  if pVertDir = -1 then
    tdir = "left"
  else
    tdir = "right"
  end if
  tTempImg = member(getmemnum(pMemName & "_" & tdir)).image.duplicate()
  pCloudMember.image = image(tTempImg.width, 60, 8)
  pUpdateTimerResetValue = 1
  tdestrect = pCloudMember.image.rect - tTempImg.rect
  tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, tTempImg.width + (tdestrect.width / 2), (tdestrect.height / 2) + tTempImg.height)
  pCloudMember.image.copyPixels(tTempImg, tdestrect, tTempImg.rect, [#ink: 8])
  pLoc = pSprite.loc
  pSprite.width = tTempImg.width
end

on getNextTurnPoint me
  pCurrentTurnPoint = pCurrentTurnPoint + 1
  if pCurrentTurnPoint > pTurnPointList.count then
    pCurrentTurnPoint = pTurnPointList.count
  end if
  pTurnPoint = pTurnPointList[pCurrentTurnPoint]
end

on update me
  if (pSprite.right > pTurnPoint) and (pSprite.left < pTurnPoint) then
    me.turn()
    pVertDir = 0
  end if
  if pSprite.left = pTurnPoint then
    pVertDir = pCloudDir * -1
    getNextTurnPoint(me)
  end if
  pUpdateTimer = pUpdateTimer - 1
  if pUpdateTimer < 1 then
    pLoc.locH = pLoc.locH + 1
    if (pLoc.locH mod 2) = 0 then
      pLoc.locV = pLoc.locV + pVertDir
    end if
    pSprite.loc = pLoc
    pUpdateTimer = pUpdateTimerResetValue
  end if
  if pSprite.left > (the stageRight - the stageLeft + 30) then
    me.initCloud()
  end if
end

on checkCloud me
  if pSprite.locH > pTurnPoint then
    me.turn()
  else
    pVertDir = -1
    pSprite.flipH = 0
  end if
end

on turn me
  if pVertDir <> 0 then
    pCloudDir = pVertDir
  end if
  if pCloudDir = -1 then
    pImg.fill(pImg.rect, rgb(255, 255, 255))
    tImg = member(getmemnum(pMemName & "_left")).image
    tWidth = pSprite.right - pTurnPoint
    tHeigth = (-tWidth / 2) - 1
    tSource = tImg.rect - rect(0, 0, tWidth, 0)
    tdestrect = tSource + rect(0, (pImg.height / 2) - (tSource.height / 2) + tHeigth, 0, (pImg.height / 2) - (tSource.height / 2) + tHeigth)
    pImg.copyPixels(tImg, tdestrect, tSource, [#ink: 8])
    tImg = member(getmemnum(pMemName & "_right")).image
    tWidth = tImg.width - tWidth
    tHeigth = -tWidth / 2
    tSource = rect(tWidth, 0, tImg.width, tImg.height)
    tDest = tSource + rect(0, (pImg.height / 2) - (tSource.height / 2) + tHeigth, 0, (pImg.height / 2) - (tSource.height / 2) + tHeigth)
    pImg.copyPixels(tImg, tDest, tSource, [#ink: 8])
  else
    pImg.fill(pImg.rect, rgb(255, 255, 255))
    tImg = member(getmemnum(pMemName & "_right")).image
    tWidth = pSprite.right - pTurnPoint
    tHeigth = (tWidth / 2) + 1
    tSource = tImg.rect - rect(0, 0, tWidth, 0)
    tdestrect = tSource + rect(0, (pImg.height / 2) - (tSource.height / 2) + tHeigth, 0, (pImg.height / 2) - (tSource.height / 2) + tHeigth)
    pImg.copyPixels(tImg, tdestrect, tSource, [#ink: 8])
    tImg = member(getmemnum(pMemName & "_left")).image
    tWidth = tImg.width - tWidth
    tHeigth = tWidth / 2
    tSource = rect(tWidth, 0, tImg.width, tImg.height)
    tDest = tSource + rect(0, (pImg.height / 2) - (tSource.height / 2) + tHeigth, 0, (pImg.height / 2) - (tSource.height / 2) + tHeigth)
    pImg.copyPixels(tImg, tDest, tSource, [#ink: 8])
  end if
end
