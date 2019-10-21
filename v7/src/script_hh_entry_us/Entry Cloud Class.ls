on define(me, tSprite, tCount)
  pSprite = tSprite
  if memberExists("entrycloud_" & tCount) then
    pCloudMember = member(getmemnum("entrycloud_" & tCount))
  else
    pCloudMember = member(createMember("entrycloud_" & tCount, #bitmap))
  end if
  pImg = pCloudMember.image
  tTemp = the itemDelimiter
  the itemDelimiter = "_"
  pMemName = 1.getProp(pSprite, member, name.count(#item) - 1)
  tdir = pSprite.getProp(member, name.count(#item))
  the itemDelimiter = tTemp
  if tdir = "left" then
    pVertDir = -1
  else
    pVertDir = 1
  end if
  pTurnPointList = [330]
  pCurrentTurnPoint = 0
  initCloud(me)
  pSprite.member = pCloudMember
  pSprite.width = pCloudMember.width
  pSprite.height = pCloudMember.height
  getFirstTurnPoint(me)
  pCloudDir = pVertDir
  return(1)
  exit
end

on getFirstTurnPoint(me)
  f = 1
  repeat while f <= pTurnPointList.count
    if pSprite.right < pTurnPointList.getAt(f) then
      pCurrentTurnPoint = f
      pTurnPoint = pTurnPointList.getAt(f)
    else
      f = 1 + f
    end if
  end repeat
  exit
end

on initCloud(me)
  if pSprite.left > the stageRight - the stageLeft then
    pVertDir = -1
    pSprite.locH = -40
    pSprite.locV = 260 - random(30)
    pMemName = pMemName.getProp(#char, 1, pMemName.length - 1) & random(4) - 1
    pCurrentTurnPoint = 1
    pTurnPoint = pTurnPointList.getAt(1)
  end if
  if pVertDir = -1 then
    tdir = "left"
  else
    tdir = "right"
  end if
  tTempImg = image.duplicate()
  pCloudMember.image = image(tTempImg.width, 60, 8)
  tdestrect = image.rect - tTempImg.rect
  tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, tTempImg.width + tdestrect.width / 2, tdestrect.height / 2 + tTempImg.height)
  image.copyPixels(tTempImg, tdestrect, tTempImg.rect, [#ink:8])
  pLoc = pSprite.loc
  pSprite.width = tTempImg.width
  exit
end

on getNextTurnPoint(me)
  pCurrentTurnPoint = pCurrentTurnPoint + 1
  if pCurrentTurnPoint > pTurnPointList.count then
    pCurrentTurnPoint = pTurnPointList.count
  end if
  pTurnPoint = pTurnPointList.getAt(pCurrentTurnPoint)
  exit
end

on update(me)
  if pSprite.right > pTurnPoint and pSprite.left <= pTurnPoint then
    me.turn()
    pVertDir = 0
  end if
  if pSprite.left = pTurnPoint then
    pVertDir = pCloudDir * -1
    getNextTurnPoint(me)
  end if
  pLoc.locH = pLoc.locH + 1
  if pLoc.locH mod 2 = 0 then
    pLoc.locV = pLoc.locV + pVertDir
  end if
  pSprite.loc = pLoc
  if pSprite.left > the stageRight - the stageLeft + 30 then
    me.initCloud()
  end if
  exit
end

on checkCloud(me)
  if pSprite.locH > pTurnPoint then
    me.turn()
  else
    pVertDir = -1
    pSprite.flipH = 0
  end if
  exit
end

on turn(me)
  if pVertDir <> 0 then
    pCloudDir = pVertDir
  end if
  if pCloudDir = -1 then
    pImg.fill(pImg.rect, rgb(255, 255, 255))
    tImg = member(getmemnum(pMemName & "_left")).image
    tWidth = pSprite.right - pTurnPoint
    tHeigth = -tWidth / 2 - 1
    tSource = tImg.rect - rect(0, 0, tWidth, 0)
    tdestrect = tSource + rect(0, pImg.height / 2 - tSource.height / 2 + tHeigth, 0, pImg.height / 2 - tSource.height / 2 + tHeigth)
    pImg.copyPixels(tImg, tdestrect, tSource, [#ink:8])
    tImg = member(getmemnum(pMemName & "_right")).image
    tWidth = tImg.width - tWidth
    tHeigth = -tWidth / 2
    tSource = rect(tWidth, 0, tImg.width, tImg.height)
    tDest = tSource + rect(0, pImg.height / 2 - tSource.height / 2 + tHeigth, 0, pImg.height / 2 - tSource.height / 2 + tHeigth)
    pImg.copyPixels(tImg, tDest, tSource, [#ink:8])
  else
    pImg.fill(pImg.rect, rgb(255, 255, 255))
    tImg = member(getmemnum(pMemName & "_right")).image
    tWidth = pSprite.right - pTurnPoint
    tHeigth = tWidth / 2 + 1
    tSource = tImg.rect - rect(0, 0, tWidth, 0)
    tdestrect = tSource + rect(0, pImg.height / 2 - tSource.height / 2 + tHeigth, 0, pImg.height / 2 - tSource.height / 2 + tHeigth)
    pImg.copyPixels(tImg, tdestrect, tSource, [#ink:8])
    tImg = member(getmemnum(pMemName & "_left")).image
    tWidth = tImg.width - tWidth
    tHeigth = tWidth / 2
    tSource = rect(tWidth, 0, tImg.width, tImg.height)
    tDest = tSource + rect(0, pImg.height / 2 - tSource.height / 2 + tHeigth, 0, pImg.height / 2 - tSource.height / 2 + tHeigth)
    pImg.copyPixels(tImg, tDest, tSource, [#ink:8])
  end if
  exit
end