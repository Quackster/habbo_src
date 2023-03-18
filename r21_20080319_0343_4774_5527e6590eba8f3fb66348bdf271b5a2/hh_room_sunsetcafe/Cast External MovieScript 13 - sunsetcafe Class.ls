property pAnimThisUpdate, pSin, pDiscoCounter, pSpriteList, pDiscoStyleList, pDiscoStyle, pLightTimer, pTextImageList, pDbFrameCount, pDbAnimFrame, pDbStarSpr, pDbDestRect, pActiveColors

on construct me
  pSpriteList = []
  pDiscoStyle = 1
  pLightTimer = 0
  pAnimThisUpdate = 0
  pSin = 22.39999999999999858
  pDiscoCounter = 100
  pTextImageList = [[], [], [], [], [], [], []]
  pActiveColors = []
  pDbFrameCount = 0
  pDbAnimFrame = 9
  pDbStarSpr = VOID
  pDbDestRect = rect(0, 0, 0, 0)
  if pDbStarSpr.ilk <> #sprite then
    pDbStarSpr = sprite(reserveSprite(me.getID()))
    pDbStarSpr.ink = 36
  end if
  pDiscoStyleList = []
  repeat with i = 1 to member(getmemnum("discofloor")).line.count
    pDiscoStyleList.add(member(getmemnum("discofloor")).text.line[i])
  end repeat
  return 1
end

on deconstruct me
  if pDbStarSpr.ilk = #sprite then
    releaseSprite(pDbStarSpr.spriteNum)
  end if
  return removeUpdate(me.getID())
end

on prepare me
  return receiveUpdate(me.getID())
end

on showprogram me, tMsg
  if voidp(tMsg) then
    return 0
  end if
  tNum = tMsg[#show_command]
  return me.changeDiscoStyle(tNum)
end

on changeDiscoStyle me, tNr
  if tNr = VOID then
    pDiscoStyle = pDiscoStyle + 1
  else
    pDiscoStyle = tNr
  end if
  if (pDiscoStyle < 1) or (pDiscoStyle > pDiscoStyleList.count) then
    pDiscoStyle = 1
  end if
  pSin = 22.39999999999999858
  pDiscoCounter = 100
  pActiveColors = []
  pTextImageList = [[], [], [], [], [], [], []]
  return 1
end

on update me
  pAnimThisUpdate = not pAnimThisUpdate
  if not pAnimThisUpdate then
    return 1
  end if
  pSin = pSin + 0.01
  if pSpriteList = [] then
    me.getSpriteList()
  end if
  me.animDiscoBall()
  tProps = pDiscoStyleList[integer(pDiscoStyle)]
  if tProps.word.count < 7 then
    return 0
  end if
  tStyle = tProps.word[1]
  tOrCols = value(tProps.word[2])
  tMultip = integer(tProps.word[3])
  tSpeed = integer(tProps.word[4])
  tRange = value(tProps.word[5])
  tTime = integer(tProps.word[6])
  tHorz = integer(tProps.word[7])
  if the milliSeconds < (tTime + pLightTimer) then
    return 1
  end if
  pDiscoCounter = pDiscoCounter + 1
  pLightTimer = the milliSeconds
  me.ColorTiles(tStyle, tOrCols, tMultip, tSpeed, tRange, tHorz)
end

on ColorTiles me, tStyle, tOrCols, tMultiplier, tSpeed, tRange, tHorz
  pActiveColors = tRange
  repeat with i = 1 to pSpriteList.count
    tX = i mod 7
    if tX = 0 then
      tX = 7
    end if
    tY = ((i - 1) / 7) + 1
    case tStyle of
      "#vertRotateSin":
        tCols = me.vertRotateSin(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
      "#vertRotate":
        tCols = me.vertRotate(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
      "#centerRotateMovX":
        tCols = me.centerRotateMovX(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
      "#centerRotateMovXY":
        tCols = me.centerRotateMovXY(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
      "#centerRotate":
        tCols = me.centerRotate(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
      "#randomColor":
        tCols = me.randomColor(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
      "#chessBoard":
        tCols = me.chessBoard(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
      "#arrow":
        tCols = me.arrow(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors, tHorz)
      "#textImage":
        tCols = me.textImage(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors, tHorz, 1)
      "#textImage2":
        tCols = me.textImage(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors, tHorz, 2)
      "#blink":
        tCols = me.blink(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors, tHorz)
      otherwise:
        return 0
    end case
    if tCols.ilk <> #list then
      if tCols = 0 then
        pSpriteList[i].bgColor = rgb(255, 255, 255)
      else
        pSpriteList[i].bgColor = tCols
      end if
      next repeat
    end if
    pSpriteList[i].bgColor = rgb(tCols[1], tCols[2], tCols[3])
  end repeat
end

on blink me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange, tHorz
  tAnimFrame = pDiscoCounter mod 9
  tMem = member(getmemnum("mammothblink" & tAnimFrame + 1))
  tImg = tMem.image
  tWid = tImg.width
  tMod = (tWid / 2) - 4
  return tImg.getPixel(tX + tMod, tY + tMod)
end

on textImage me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange, tHorz, tNr
  if tHorz = 1 then
    tTemp = tX
    tX = tY
    tY = tTemp
  end if
  if pTextImageList = [[], [], [], [], [], [], []] then
    if not me.getTextImage(tNr) then
      return 0
    end if
  end if
  tSpot = pDiscoCounter mod pTextImageList[1].count
  if (tX + tSpot) > pTextImageList[1].count then
    tSpot = 0
  end if
  if pTextImageList[tY][tX + tSpot] then
    return [tRange[4], tRange[5], tRange[6]]
  else
    return [tRange[1], tRange[2], tRange[3]]
  end if
end

on getTextImage me, tNr
  tImg = getMember("floortext" & tNr).image.trimWhiteSpace()
  repeat with i = 1 to 7
    repeat with j = 1 to tImg.width
      tColor = tImg.getPixel(j, i, #integer)
      if tColor = 0 then
        pTextImageList[i][j] = 1
        next repeat
      end if
      pTextImageList[i][j] = 0
    end repeat
  end repeat
  return 1
end

on randomColor me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange
  tCols = []
  repeat with k = 1 to 3
    tMax = tRange[k + 3]
    tMin = tRange[k]
    tdiff = tMax - tMin
    if tdiff < 1 then
      tCols[k] = tMin
      next repeat
    end if
    tCols[k] = tMin + random(tdiff)
  end repeat
  return tCols
end

on chessBoard me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange
  tPhase = pDiscoCounter mod 2
  tCols = []
  repeat with k = 1 to 3
    tCol1 = tRange[k + 3]
    tCol2 = tRange[k]
    if ((tX + tY + tPhase) mod 2) = 1 then
      tCols[k] = tCol1
      next repeat
    end if
    tCols[k] = tCol2
  end repeat
  return tCols
end

on vertRotateSin me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange
  tCols = []
  repeat with k = 1 to 3
    tCols[k] = tOrCols[k] + (tX + tY) + (tMultiplier * sin(pSin) * tSpeed)
    tMax = tRange[k + 3]
    tMin = tRange[k]
    if tCols[k] > tMax then
      tCols[k] = tMax - (tCols[k] mod (tMax - tMin))
    end if
    if tCols[k] < tMin then
      tCols[k] = tMin - (tCols[k] mod (tMax - tMin))
    end if
  end repeat
  return tCols
end

on vertRotate me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange
  tCols = []
  repeat with k = 1 to 3
    tCols[k] = tOrCols[k] + (tX + tY) + (tMultiplier * pSin * tSpeed)
    tMax = tRange[k + 3]
    tMin = tRange[k]
    if tCols[k] > tMax then
      tCols[k] = tMax - (tCols[k] mod (tMax - tMin))
    end if
    if tCols[k] < tMin then
      tCols[k] = tMin - (tCols[k] mod (tMax - tMin))
    end if
  end repeat
  return tCols
end

on centerRotateMovX me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange
  tCols = []
  tRow = abs((pDiscoCounter mod 14) - 7)
  tCenterX = tRow
  tCenterY = 4
  tCenterMultiplier = abs(tX - tCenterX) + abs(tY - tCenterY)
  tMultiplier = tMultiplier * tCenterMultiplier
  repeat with k = 1 to 3
    tCols[k] = tOrCols[k] + (tX + tY) + (tMultiplier * pSin * tSpeed)
    tMax = tRange[k + 3]
    tMin = tRange[k]
    if tCols[k] > tMax then
      tCols[k] = tMax - (tCols[k] mod (tMax - tMin))
    end if
    if tCols[k] < tMin then
      tCols[k] = tMin - (tCols[k] mod (tMax - tMin))
    end if
  end repeat
  return tCols
end

on centerRotateMovXY me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange
  tCols = []
  tPlace = pDiscoCounter mod 24
  if tPlace < 6 then
    tCenterX = tPlace + 1
    tCenterY = 1
  else
    if tPlace < 13 then
      tCenterX = 7
      tCenterY = tPlace - 5
    else
      if tPlace < 18 then
        tCenterX = abs(tPlace - 18) + 1
        tCenterY = 7
      else
        tCenterX = 1
        tCenterY = abs(tPlace - 25)
      end if
    end if
  end if
  tCenterMultiplier = abs(tX - tCenterX) + abs(tY - tCenterY)
  tMultiplier = tMultiplier * tCenterMultiplier
  repeat with k = 1 to 3
    tCols[k] = tOrCols[k] + (tX + tY) + (tMultiplier * pSin * tSpeed / 7.0)
    tMax = tRange[k + 3]
    tMin = tRange[k]
    if tCols[k] > tMax then
      tCols[k] = tMax - (tCols[k] mod (tMax - tMin))
    end if
    if tCols[k] < tMin then
      tCols[k] = tMin - (tCols[k] mod (tMax - tMin))
    end if
  end repeat
  return tCols
end

on arrow me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange
  tCols = []
  tRow = abs((pDiscoCounter mod 14) - 7)
  tCenterX = tRow
  tCenterY = 0
  tCenterMultiplier = abs(tX - tCenterX) + abs(tY - tCenterY)
  tMultiplier = tMultiplier * tCenterMultiplier
  repeat with k = 1 to 3
    tCols[k] = tOrCols[k] + (tX + tY) + (tMultiplier * pSin * tSpeed)
    tMax = tRange[k + 3]
    tMin = tRange[k]
    if tCols[k] > tMax then
      tCols[k] = tMax - (tCols[k] mod (tMax - tMin))
    end if
    if tCols[k] < tMin then
      tCols[k] = tMin - (tCols[k] mod (tMax - tMin))
    end if
  end repeat
  return tCols
end

on centerRotate me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange
  tCenterX = 4
  tCenterY = 4
  tCenterMultiplier = abs(tX - tCenterX) + abs(tY - tCenterY)
  tMultiplier = tMultiplier * tCenterMultiplier
  tCols = []
  repeat with k = 1 to 3
    tCols[k] = tOrCols[k] + ((tX + tY) * tMultiplier) + (pSin * tSpeed)
    tMax = tRange[k + 3]
    tMin = tRange[k]
    if tCols[k] > tMax then
      tCols[k] = tMax - (tCols[k] mod (tMax - tMin))
    end if
    if tCols[k] < tMin then
      tCols[k] = tMin - (tCols[k] mod (tMax - tMin))
    end if
  end repeat
  return tCols
end

on animDiscoBall me
  pDbFrameCount = pDbFrameCount + 1
  if (pDbFrameCount mod 2) <> 0 then
    return 
  end if
  if pDbDestRect.ilk = #rect then
    pDbAnimFrame = pDbAnimFrame + 1
    if pDbAnimFrame > 9 then
      pDbAnimFrame = 1
      tRandomSin = random(1000)
      tRandomDist = random(100)
      tX = (sin(tRandomSin) * pDbDestRect.width / 200 * tRandomDist) + pDbDestRect.left + (pDbDestRect.width / 2)
      tY = (cos(tRandomSin) * pDbDestRect.height / 200 * tRandomDist) + pDbDestRect.top + (pDbDestRect.height / 2)
      pDbStarSpr.loc = point(tX, tY)
    end if
    pDbStarSpr.sprite.member = member(getmemnum("mammothblink" & pDbAnimFrame))
  end if
end

on getSpriteList me
  pSpriteList = []
  tObj = getThread(#room).getInterface().getRoomVisualizer()
  if tObj = 0 then
    return 0
  end if
  repeat with i = 1 to 49
    tSp = tObj.getSprById("discotile" & i)
    if tSp < 1 then
      pSpriteList = []
      return 0
    end if
    pSpriteList.add(tSp)
  end repeat
  tSp = tObj.getSprById("disco_mirrorball")
  if tSp < 1 then
    return 0
  end if
  pDbDestRect = rect(tSp.rect[1], tSp.rect[4] - tSp.width, tSp.rect[3], tSp.rect[4])
  pDbStarSpr.locZ = tSp.locZ + 1
  return 1
end
