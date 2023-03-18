property pAnimThisUpdate, pSin, pDiscoCounter, pAnimTimer, pSpriteList, pGlowList, pDiscoStyleList, pDiscoStyle, pLightTimer, pColorOrder, pItemObjList

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
      exit repeat
    end if
    i = i + 1
  end repeat
  pAnimTimer = the timer
  pSpriteList = []
  pGlowList = []
  pDiscoStyle = 1
  pLightTimer = 0
  pAnimThisUpdate = 0
  pSin = 22.39999999999999858
  pDiscoCounter = 100
  pColorOrder = [0, 3, 2, 1, 2, 3, 0, 6, 5, 4, 5, 6, 0, 9, 8, 7, 8, 9]
  pDiscoStyleList = []
  if getmemnum("discofloor") <= 0 then
    return 0
  end if
  if member(getmemnum("discofloor")).type <> #field then
    return 0
  end if
  repeat with i = 1 to member(getmemnum("discofloor")).line.count
    pDiscoStyleList.add(member(getmemnum("discofloor")).text.line[i])
  end repeat
  return 1
end

on deconstruct me
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
  return 1
end

on update me
  call(#update, pItemObjList)
  pAnimThisUpdate = not pAnimThisUpdate
  if not pAnimThisUpdate then
    return 1
  end if
  pSin = pSin + 0.01
  if pSpriteList = [] then
    me.getSpriteList()
  end if
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
    tX = i mod 6
    if tX = 0 then
      tX = 6
    end if
    tY = ((i - 1) / 6) + 1
    case tStyle of
      "#vertRotateSin":
        tColNum = me.vertRotateSin(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
      "#vertRotate":
        tColNum = me.vertRotate(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
      "#centerRotateMovX":
        tColNum = me.centerRotateMovX(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
      "#centerRotateMovXY":
        tColNum = me.centerRotateMovXY(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
      "#centerRotate":
        tColNum = me.centerRotate(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
      "#randomColor":
        tColNum = me.randomColor(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
      "#chessBoard":
        tColNum = me.chessBoard(tX, tY, tOrCols, tMultiplier, tSpeed, pActiveColors)
      otherwise:
        return 0
    end case
    tNum = (tColNum mod pColorOrder.count) + 1
    pSpriteList[i].member = getMember("disco_" & pColorOrder[tNum])
    pGlowList[i].member = getMember("light_disco_" & pColorOrder[tNum])
  end repeat
end

on randomColor me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange
  return random(100)
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
  return tCols[1]
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
  return tCols[1]
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
  return tCols[1]
end

on centerRotateMovX me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange
  tCols = []
  tRow = abs((pDiscoCounter mod 12) - 6)
  tCenterX = tRow
  tCenterY = 4
  tCenterMultiplier = abs(tX - tCenterX) + abs(tY - tCenterY)
  tMultiplier = tMultiplier * tCenterMultiplier
  return tRow + tX
end

on centerRotateMovXY me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange
  tCols = []
  tPlace = pDiscoCounter mod 18
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
  return tCols[1]
end

on centerRotate me, tX, tY, tOrCols, tMultiplier, tSpeed, tRange
  tCenterX = 3
  tCenterY = 3
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
  return tCols[1]
end

on getSpriteList me
  pSpriteList = []
  tObj = getThread(#room).getInterface().getRoomVisualizer()
  if tObj = 0 then
    return 0
  end if
  repeat with i = 1 to 30
    tSp = tObj.getSprById("discolight" & i)
    tSp2 = tObj.getSprById("discoglow" & i)
    if tSp < 1 then
      pSpriteList = []
      return 0
    end if
    pSpriteList.add(tSp)
    pGlowList.add(tSp2)
  end repeat
  return 1
end
