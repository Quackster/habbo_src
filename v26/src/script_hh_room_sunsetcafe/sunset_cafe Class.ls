property pItemObjList, pDiscoStyleList, pDiscoStyle, pAnimThisUpdate, pSin, pSpriteList, pLightTimer, pDiscoCounter, pColorOrder, pGlowList

on construct me 
  pItemObjList = []
  receiveUpdate(me.getID())
  tVisObj = getThread(#room).getInterface().getRoomVisualizer()
  i = 1
  repeat while 1
    tSpr = tVisObj.getSprById("duck" & i)
    if tSpr <> 0 then
      tObj = createObject(#temp, "Duck Class")
      tObj.define(tSpr)
      pItemObjList.add(tObj)
    else
    end if
    i = i + 1
  end repeat
  pAnimTimer = the timer
  pSpriteList = []
  pGlowList = []
  pDiscoStyle = 1
  pLightTimer = 0
  pAnimThisUpdate = 0
  pSin = 22.4
  pDiscoCounter = 100
  pColorOrder = [0, 3, 2, 1, 2, 3, 0, 6, 5, 4, 5, 6, 0, 9, 8, 7, 8, 9]
  pDiscoStyleList = []
  if getmemnum("discofloor") <= 0 then
    return(0)
  end if
  if member(getmemnum("discofloor")).type <> #field then
    return(0)
  end if
  i = 1
  repeat while i <= member(getmemnum("discofloor")).count(#line)
    member(getmemnum("discofloor")).add(text.getProp(#line, i))
    i = 1 + i
  end repeat
  return(1)
end

on deconstruct me 
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
  return(1)
end

on update me 
  call(#update, pItemObjList)
  pAnimThisUpdate = not pAnimThisUpdate
  if not pAnimThisUpdate then
    return(1)
  end if
  pSin = pSin + 0.01
  if pSpriteList = [] then
    me.getSpriteList()
  end if
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
    tX = (i mod 6)
    if tX = 0 then
      tX = 6
    end if
    tY = (i - 1 / 6) + 1
    if tStyle = "#vertRotateSin" then
      tColNum = me.vertRotateSin(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
    else
      if tStyle = "#vertRotate" then
        tColNum = me.vertRotate(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
      else
        if tStyle = "#centerRotateMovX" then
          tColNum = me.centerRotateMovX(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
        else
          if tStyle = "#centerRotateMovXY" then
            tColNum = me.centerRotateMovXY(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
          else
            if tStyle = "#centerRotate" then
              tColNum = me.centerRotate(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
            else
              if tStyle = "#randomColor" then
                tColNum = me.randomColor(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
              else
                if tStyle = "#chessBoard" then
                  tColNum = me.chessBoard(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
                else
                  return(0)
                end if
              end if
            end if
          end if
        end if
      end if
    end if
    tNum = (tColNum mod pColorOrder.count) + 1
    pSpriteList.getAt(i).member = getMember("disco_" & pColorOrder.getAt(tNum))
    pGlowList.getAt(i).member = getMember("light_disco_" & pColorOrder.getAt(tNum))
    i = 1 + i
  end repeat
end

on randomColor me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange 
  return(random(100))
end

on chessBoard me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange 
  tPhase = (pDiscoCounter mod 2)
  tCols = []
  k = 1
  repeat while k <= 3
    tCol1 = tRange.getAt(k + 3)
    tCol2 = tRange.getAt(k)
    if (tX + tY + tPhase mod 2) = 1 then
      tCols.setAt(k, tCol1)
    else
      tCols.setAt(k, tCol2)
    end if
    k = 1 + k
  end repeat
  return(tCols.getAt(1))
end

on vertRotateSin me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange 
  tCols = []
  k = 1
  repeat while k <= 3
    tCols.setAt(k, tOrCols.getAt(k) + tX + tY + ((tMultiplier * sin(pSin)) * tSpeed))
    tMax = tRange.getAt(k + 3)
    tMin = tRange.getAt(k)
    if tCols.getAt(k) > tMax then
      tCols.setAt(k, tMax - (tCols.getAt(k) mod tMax - tMin))
    end if
    if tCols.getAt(k) < tMin then
      tCols.setAt(k, tMin - (tCols.getAt(k) mod tMax - tMin))
    end if
    k = 1 + k
  end repeat
  return(tCols.getAt(1))
end

on vertRotate me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange 
  tCols = []
  k = 1
  repeat while k <= 3
    tCols.setAt(k, tOrCols.getAt(k) + tX + tY + ((tMultiplier * pSin) * tSpeed))
    tMax = tRange.getAt(k + 3)
    tMin = tRange.getAt(k)
    if tCols.getAt(k) > tMax then
      tCols.setAt(k, tMax - (tCols.getAt(k) mod tMax - tMin))
    end if
    if tCols.getAt(k) < tMin then
      tCols.setAt(k, tMin - (tCols.getAt(k) mod tMax - tMin))
    end if
    k = 1 + k
  end repeat
  return(tCols.getAt(1))
end

on centerRotateMovX me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange 
  tCols = []
  tRow = abs((pDiscoCounter mod 12) - 6)
  tCenterX = tRow
  tCenterY = 4
  tCenterMultiplier = abs(tX - tCenterX) + abs(tY - tCenterY)
  tMultiplier = (tMultiplier * tCenterMultiplier)
  return(tRow + tX)
end

on centerRotateMovXY me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange 
  tCols = []
  tPlace = (pDiscoCounter mod 18)
  if tPlace < 6 then
    tCenterX = tPlace + 1
    tCenterY = 1
  else
    if tPlace < 10 then
      tCenterX = 3
      tCenterY = tPlace - 3
    else
      if tPlace < 14 then
        tCenterX = abs(tPlace - 14) + 1
        tCenterY = 3
      else
        tCenterX = 1
        tCenterY = abs(tPlace - 18)
      end if
    end if
  end if
  tCenterMultiplier = abs(tX - tCenterX) + abs(tY - tCenterY)
  tMultiplier = (tMultiplier * tCenterMultiplier)
  k = 1
  repeat while k <= 3
    tCols.setAt(k, tOrCols.getAt(k) + tX + tY + (((tMultiplier * pSin) * tSpeed) / 7))
    tMax = tRange.getAt(k + 3)
    tMin = tRange.getAt(k)
    if tCols.getAt(k) > tMax then
      tCols.setAt(k, tMax - (tCols.getAt(k) mod tMax - tMin))
    end if
    if tCols.getAt(k) < tMin then
      tCols.setAt(k, tMin - (tCols.getAt(k) mod tMax - tMin))
    end if
    k = 1 + k
  end repeat
  return(tCols.getAt(1))
end

on centerRotate me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange 
  tCenterX = 3
  tCenterY = 3
  tCenterMultiplier = abs(tX - tCenterX) + abs(tY - tCenterY)
  tMultiplier = (tMultiplier * tCenterMultiplier)
  tCols = []
  k = 1
  repeat while k <= 3
    tCols.setAt(k, tOrCols.getAt(k) + (tX + tY * tMultiplier) + (pSin * tSpeed))
    tMax = tRange.getAt(k + 3)
    tMin = tRange.getAt(k)
    if tCols.getAt(k) > tMax then
      tCols.setAt(k, tMax - (tCols.getAt(k) mod tMax - tMin))
    end if
    if tCols.getAt(k) < tMin then
      tCols.setAt(k, tMin - (tCols.getAt(k) mod tMax - tMin))
    end if
    k = 1 + k
  end repeat
  return(tCols.getAt(1))
end

on getSpriteList me 
  pSpriteList = []
  tObj = getThread(#room).getInterface().getRoomVisualizer()
  if tObj = 0 then
    return(0)
  end if
  i = 1
  repeat while i <= 30
    tSp = tObj.getSprById("discolight" & i)
    tSp2 = tObj.getSprById("discoglow" & i)
    if tSp < 1 then
      pSpriteList = []
      return(0)
    end if
    pSpriteList.add(tSp)
    pGlowList.add(tSp2)
    i = 1 + i
  end repeat
  return(1)
end
