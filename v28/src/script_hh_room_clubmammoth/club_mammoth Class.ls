property pDbStarSpr, pDiscoStyleList, pDiscoStyle, pAnimThisUpdate, pSin, pSpriteList, pLightTimer, pDiscoCounter, pActiveColors, pTextImageList, pDbFrameCount, pDbDestRect, pDbAnimFrame

on construct me 
  pSpriteList = []
  pDiscoStyle = 1
  pLightTimer = 0
  pAnimThisUpdate = 0
  pSin = 22.4
  pDiscoCounter = 100
  pTextImageList = [[], [], [], [], [], [], []]
  pActiveColors = []
  pDbFrameCount = 0
  pDbAnimFrame = 9
  pDbStarSpr = void()
  pDbDestRect = rect(0, 0, 0, 0)
  if pDbStarSpr.ilk <> #sprite then
    pDbStarSpr = sprite(reserveSprite(me.getID()))
    pDbStarSpr.ink = 36
  end if
  pDiscoStyleList = []
  i = 1
  repeat while i <= member(getmemnum("discofloor")).count(#line)
    member(getmemnum("discofloor")).add(text.getProp(#line, i))
    i = 1 + i
  end repeat
  return(1)
end

on deconstruct me 
  if pDbStarSpr.ilk = #sprite then
    releaseSprite(pDbStarSpr.spriteNum)
  end if
  return(removeUpdate(me.getID()))
end

on prepare me 
  return(receiveUpdate(me.getID()))
end

on showprogram me, tMsg 
  if voidp(tMsg) then
    return(0)
  end if
  tNum = tMsg.getAt(#show_command)
  return(me.changeDiscoStyle(tNum))
end

on changeDiscoStyle me, tNr 
  if tNr = void() then
    pDiscoStyle = pDiscoStyle + 1
  else
    pDiscoStyle = tNr
  end if
  if pDiscoStyle < 1 or pDiscoStyle > pDiscoStyleList.count then
    pDiscoStyle = 1
  end if
  pSin = 22.4
  pDiscoCounter = 100
  pActiveColors = []
  pTextImageList = [[], [], [], [], [], [], []]
  return(1)
end

on update me 
  pAnimThisUpdate = not pAnimThisUpdate
  if not pAnimThisUpdate then
    return(1)
  end if
  pSin = pSin + 0.01
  if pSpriteList = [] then
    me.getSpriteList()
  end if
  me.animDiscoBall()
  tProps = pDiscoStyleList.getAt(integer(pDiscoStyle))
  if tProps.count(#word) < 7 then
    return(0)
  end if
  tStyle = tProps.getProp(#word, 1)
  tOrCols = value(tProps.getProp(#word, 2))
  tMultip = integer(tProps.getProp(#word, 3))
  tSpeed = integer(tProps.getProp(#word, 4))
  tRange = value(tProps.getProp(#word, 5))
  tTime = integer(tProps.getProp(#word, 6))
  tHorz = integer(tProps.getProp(#word, 7))
  if the milliSeconds < tTime + pLightTimer then
    return(1)
  end if
  pDiscoCounter = pDiscoCounter + 1
  pLightTimer = the milliSeconds
  me.ColorTiles(tStyle, tOrCols, tMultip, tSpeed, tRange, tHorz)
end

on ColorTiles me, tStyle, tOrCols, tMultiplier, tSpeed, tRange, tHorz 
  pActiveColors = tRange
  i = 1
  repeat while i <= pSpriteList.count
    tX = i mod 7
    if tX = 0 then
      tX = 7
    end if
    tY = i - 1 / 7 + 1
    if tStyle = "#vertRotateSin" then
      tCols = me.vertRotateSin(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
    else
      if tStyle = "#vertRotate" then
        tCols = me.vertRotate(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
      else
        if tStyle = "#centerRotateMovX" then
          tCols = me.centerRotateMovX(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
        else
          if tStyle = "#centerRotateMovXY" then
            tCols = me.centerRotateMovXY(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
          else
            if tStyle = "#centerRotate" then
              tCols = me.centerRotate(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
            else
              if tStyle = "#randomColor" then
                tCols = me.randomColor(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
              else
                if tStyle = "#chessBoard" then
                  tCols = me.chessBoard(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
                else
                  if tStyle = "#arrow" then
                    tCols = me.arrow(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors, tHorz)
                  else
                    if tStyle = "#textImage" then
                      tCols = me.textImage(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors, tHorz, 1)
                    else
                      if tStyle = "#textImage2" then
                        tCols = me.textImage(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors, tHorz, 2)
                      else
                        if tStyle = "#blink" then
                          tCols = me.blink(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors, tHorz)
                        else
                          return(0)
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
    if tCols.ilk <> #list then
      if tCols = 0 then
        pSpriteList.getAt(i).bgColor = rgb(255, 255, 255)
      else
        pSpriteList.getAt(i).bgColor = tCols
      end if
    else
      pSpriteList.getAt(i).bgColor = rgb(tCols.getAt(1), tCols.getAt(2), tCols.getAt(3))
    end if
    i = 1 + i
  end repeat
end

on blink me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange, tHorz 
  tAnimFrame = pDiscoCounter mod 9
  tMem = member(getmemnum("mammothblink" & tAnimFrame + 1))
  tImg = tMem.image
  tWid = tImg.width
  tMod = tWid / 2 - 4
  return(tImg.getPixel(tX + tMod, tY + tMod))
end

on textImage me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange, tHorz, tNr 
  if tHorz = 1 then
    tTemp = tX
    tX = tY
    tY = tTemp
  end if
  if pTextImageList = [[], [], [], [], [], [], []] then
    if not me.getTextImage(tNr) then
      return(0)
    end if
  end if
  tSpot = pDiscoCounter mod pTextImageList.getAt(1).count
  if tX + tSpot > pTextImageList.getAt(1).count then
    tSpot = 0
  end if
  if pTextImageList.getAt(tY).getAt(tX + tSpot) then
    return([tRange.getAt(4), tRange.getAt(5), tRange.getAt(6)])
  else
    return([tRange.getAt(1), tRange.getAt(2), tRange.getAt(3)])
  end if
end

on getTextImage me, tNr 
  tImg = undefined.trimWhiteSpace()
  i = 1
  repeat while i <= 7
    j = 1
    repeat while j <= tImg.width
      tColor = tImg.getPixel(j, i, #integer)
      if tColor = 0 then
        pTextImageList.getAt(i).setAt(j, 1)
      else
        pTextImageList.getAt(i).setAt(j, 0)
      end if
      j = 1 + j
    end repeat
    i = 1 + i
  end repeat
  return(1)
end

on randomColor me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange 
  tCols = []
  k = 1
  repeat while k <= 3
    tMax = tRange.getAt(k + 3)
    tMin = tRange.getAt(k)
    tDiff = tMax - tMin
    if tDiff < 1 then
      tCols.setAt(k, tMin)
    else
      tCols.setAt(k, tMin + random(tDiff))
    end if
    k = 1 + k
  end repeat
  return(tCols)
end

on chessBoard me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange 
  tPhase = pDiscoCounter mod 2
  tCols = []
  k = 1
  repeat while k <= 3
    tCol1 = tRange.getAt(k + 3)
    tCol2 = tRange.getAt(k)
    if tX + tY + tPhase mod 2 = 1 then
      tCols.setAt(k, tCol1)
    else
      tCols.setAt(k, tCol2)
    end if
    k = 1 + k
  end repeat
  return(tCols)
end

on vertRotateSin me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange 
  tCols = []
  k = 1
  repeat while k <= 3
    tCols.setAt(k, tOrCols.getAt(k) + tX + tY + tMultiplier * sin(pSin) * tSpeed)
    tMax = tRange.getAt(k + 3)
    tMin = tRange.getAt(k)
    if tCols.getAt(k) > tMax then
      tCols.setAt(k, tMax - tCols.getAt(k) mod tMax - tMin)
    end if
    if tCols.getAt(k) < tMin then
      tCols.setAt(k, tMin - tCols.getAt(k) mod tMax - tMin)
    end if
    k = 1 + k
  end repeat
  return(tCols)
end

on vertRotate me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange 
  tCols = []
  k = 1
  repeat while k <= 3
    tCols.setAt(k, tOrCols.getAt(k) + tX + tY + tMultiplier * pSin * tSpeed)
    tMax = tRange.getAt(k + 3)
    tMin = tRange.getAt(k)
    if tCols.getAt(k) > tMax then
      tCols.setAt(k, tMax - tCols.getAt(k) mod tMax - tMin)
    end if
    if tCols.getAt(k) < tMin then
      tCols.setAt(k, tMin - tCols.getAt(k) mod tMax - tMin)
    end if
    k = 1 + k
  end repeat
  return(tCols)
end

on centerRotateMovX me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange 
  tCols = []
  tRow = abs(pDiscoCounter mod 14 - 7)
  tCenterX = tRow
  tCenterY = 4
  tCenterMultiplier = abs(tX - tCenterX) + abs(tY - tCenterY)
  tMultiplier = tMultiplier * tCenterMultiplier
  k = 1
  repeat while k <= 3
    tCols.setAt(k, tOrCols.getAt(k) + tX + tY + tMultiplier * pSin * tSpeed)
    tMax = tRange.getAt(k + 3)
    tMin = tRange.getAt(k)
    if tCols.getAt(k) > tMax then
      tCols.setAt(k, tMax - tCols.getAt(k) mod tMax - tMin)
    end if
    if tCols.getAt(k) < tMin then
      tCols.setAt(k, tMin - tCols.getAt(k) mod tMax - tMin)
    end if
    k = 1 + k
  end repeat
  return(tCols)
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
  k = 1
  repeat while k <= 3
    tCols.setAt(k, tOrCols.getAt(k) + tX + tY + tMultiplier * pSin * tSpeed / 7)
    tMax = tRange.getAt(k + 3)
    tMin = tRange.getAt(k)
    if tCols.getAt(k) > tMax then
      tCols.setAt(k, tMax - tCols.getAt(k) mod tMax - tMin)
    end if
    if tCols.getAt(k) < tMin then
      tCols.setAt(k, tMin - tCols.getAt(k) mod tMax - tMin)
    end if
    k = 1 + k
  end repeat
  return(tCols)
end

on arrow me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange 
  tCols = []
  tRow = abs(pDiscoCounter mod 14 - 7)
  tCenterX = tRow
  tCenterY = 0
  tCenterMultiplier = abs(tX - tCenterX) + abs(tY - tCenterY)
  tMultiplier = tMultiplier * tCenterMultiplier
  k = 1
  repeat while k <= 3
    tCols.setAt(k, tOrCols.getAt(k) + tX + tY + tMultiplier * pSin * tSpeed)
    tMax = tRange.getAt(k + 3)
    tMin = tRange.getAt(k)
    if tCols.getAt(k) > tMax then
      tCols.setAt(k, tMax - tCols.getAt(k) mod tMax - tMin)
    end if
    if tCols.getAt(k) < tMin then
      tCols.setAt(k, tMin - tCols.getAt(k) mod tMax - tMin)
    end if
    k = 1 + k
  end repeat
  return(tCols)
end

on centerRotate me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange 
  tCenterX = 4
  tCenterY = 4
  tCenterMultiplier = abs(tX - tCenterX) + abs(tY - tCenterY)
  tMultiplier = tMultiplier * tCenterMultiplier
  tCols = []
  k = 1
  repeat while k <= 3
    tCols.setAt(k, tOrCols.getAt(k) + tX + tY * tMultiplier + pSin * tSpeed)
    tMax = tRange.getAt(k + 3)
    tMin = tRange.getAt(k)
    if tCols.getAt(k) > tMax then
      tCols.setAt(k, tMax - tCols.getAt(k) mod tMax - tMin)
    end if
    if tCols.getAt(k) < tMin then
      tCols.setAt(k, tMin - tCols.getAt(k) mod tMax - tMin)
    end if
    k = 1 + k
  end repeat
  return(tCols)
end

on animDiscoBall me 
  pDbFrameCount = pDbFrameCount + 1
  if pDbFrameCount mod 2 <> 0 then
    return()
  end if
  if pDbDestRect.ilk = #rect then
    pDbAnimFrame = pDbAnimFrame + 1
    if pDbAnimFrame > 9 then
      pDbAnimFrame = 1
      tRandomSin = random(1000)
      tRandomDist = random(100)
      tX = sin(tRandomSin) * pDbDestRect.width / 200 * tRandomDist + pDbDestRect.left + pDbDestRect.width / 2
      tY = cos(tRandomSin) * pDbDestRect.height / 200 * tRandomDist + pDbDestRect.top + pDbDestRect.height / 2
      pDbStarSpr.loc = point(tX, tY)
    end if
    sprite.member = member(getmemnum("mammothblink" & pDbAnimFrame))
  end if
end

on getSpriteList me 
  pSpriteList = []
  tObj = getThread(#room).getInterface().getRoomVisualizer()
  if tObj = 0 then
    return(0)
  end if
  i = 1
  repeat while i <= 49
    tSp = tObj.getSprById("discotile" & i)
    if tSp < 1 then
      pSpriteList = []
      return(0)
    end if
    pSpriteList.add(tSp)
    i = 1 + i
  end repeat
  tSp = tObj.getSprById("disco_mirrorball")
  if tSp < 1 then
    return(0)
  end if
  pDbDestRect = rect(tSp.getProp(#rect, 1), tSp.getProp(#rect, 4) - tSp.width, tSp.getProp(#rect, 3), tSp.getProp(#rect, 4))
  pDbStarSpr.locZ = tSp.locZ + 1
  return(1)
end
