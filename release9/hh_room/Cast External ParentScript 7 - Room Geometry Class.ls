property pXOffset, pYOffset, pZOffset, pXFactor, pYFactor, pHFactor, pHeightMap, pPlaceMap

on construct me
  pXOffset = 0.0
  pYOffset = 0.0
  pZOffset = 0.0
  pXFactor = 0.0
  pYFactor = 0.0
  pHFactor = 0.0
  pHeightMap = [[]]
  pPlaceMap = [[]]
  return 1
end

on define me, tdata
  pXOffset = getLocalFloat(tdata[#offsetx])
  pYOffset = getLocalFloat(tdata[#offsety])
  pZOffset = getLocalFloat(tdata[#offsetz])
  pXFactor = getLocalFloat(tdata[#factorx])
  pYFactor = getLocalFloat(tdata[#factory])
  pHFactor = getLocalFloat(tdata[#factorh])
  return 1
end

on loadHeightMap me, tdata
  pHeightMap = []
  pPlaceMap = []
  repeat with i = 1 to tdata.line.count
    l = []
    k = []
    tLine = tdata.line[i]
    if tLine <> EMPTY then
      repeat with j = 1 to length(tLine)
        if tLine.char[j] = "x" then
          l.add(200000)
          k.add(200000)
          next repeat
        end if
        if tLine.char[j] = "y" then
          l.add(0)
          k.add(100000)
          next repeat
        end if
        if (charToNum(tLine.char[j]) >= 65) and (charToNum(tLine.char[j]) < 73) then
          l.add(charToNum(tLine.char[j]) - 65)
          k.add(100000)
          next repeat
        end if
        l.add(integer(tLine.char[j]))
        k.add(0)
      end repeat
      pHeightMap.add(l)
      pPlaceMap.add(k)
    end if
  end repeat
  return 1
end

on getScreenCoordinate me, tLocX, tLocY, tHeight
  tPrecision = the floatPrecision
  set the floatPrecision to 2
  tLocH = ((tLocX - tLocY) * (pXFactor * 0.5)) + pXOffset
  tLocV = float(((tLocY + tLocX) * pYFactor * 0.5) + pYOffset) - (tHeight * pHFactor)
  tlocz = (1000 * (tLocX + tLocY + 1)) + pZOffset
  set the floatPrecision to tPrecision
  return [integer(tLocH), integer(tLocV), integer(tlocz)]
end

on getCoordinateHeight me, tX, tY
  tX = integer(tX)
  tY = integer(tY)
  if (tY < 0) or (tY >= pHeightMap.count) then
    return 0
  end if
  tLine = pHeightMap[integer(tY + 1)]
  if (tX < 0) or (tX >= tLine.count) then
    return 0
  end if
  return tLine[tX + 1]
end

on getWorldCoordinate me, tLocX, tLocY
  if voidp(pHeightMap) then
    return VOID
  end if
  tX = integer(((tLocX - pYFactor - pXOffset) / pXFactor) + ((tLocY - pYOffset) / pYFactor))
  tY = integer(((tLocY - pYOffset) / pYFactor) - ((tLocX - pYFactor - pXOffset) / pXFactor))
  tHeight = -1
  if (tY >= 0) and (tY < pHeightMap.count) then
    if (tX >= 0) and (tX < pHeightMap[tY + 1].count) then
      tHeight = pHeightMap[tY + 1][tX + 1]
    end if
  end if
  if tHeight = 0 then
    return [tX, tY, tHeight]
  else
    repeat with i = 1 to 9
      tX = integer(((tLocX - pYFactor - pXOffset) / pXFactor) + ((tLocY + (i * pHFactor) - pYOffset) / pYFactor))
      tY = integer(((tLocY + (i * pHFactor) - pYOffset) / pYFactor) - ((tLocX - pYFactor - pXOffset) / pXFactor))
      tHeight = -1
      if (tY >= 0) and (tY < pHeightMap.count) then
        if (tX >= 0) and (tX < pHeightMap[tY + 1].count) then
          tHeight = pHeightMap[tY + 1][tX + 1]
        end if
      end if
      if tHeight = i then
        return [tX, tY, tHeight]
      end if
    end repeat
  end if
  return 0
end

on getObjectPlaceMap me
  return pPlaceMap
end

on getObjectHeightMap me
  return pHeightMap
end

on getTileHeight me
  return pYFactor
end

on getTileWidth me
  return pXFactor
end

on emptyTile me, tX, tY
  if ((tY + 1) > 0) and ((tY + 1) <= count(pPlaceMap)) then
    if ((tX + 1) > 0) and ((tX + 1) <= count(pPlaceMap[tY + 1])) then
      if pPlaceMap[tY + 1][tX + 1] > 1000 then
        return 0
      end if
    else
      return 0
    end if
  else
    return 0
  end if
  return 1
end

on print me
  put "- - - - - - - - - - - - - - -"
  put 
  put "X offset " & pXOffset
  put "Y offset " & pYOffset
  put "Z offset " & pZOffset
  put "X factor " & pXFactor
  put "Y factor " & pYFactor
  put "H factor " & pHFactor
  put 
  put "HeightMap:"
  put 
  repeat with x = 1 to pHeightMap.count
    tStr = EMPTY
    repeat with y = 1 to pHeightMap[x].count
      if pHeightMap[x][y] < 100000 then
        tStr = tStr & pHeightMap[x][y] & "."
        next repeat
      end if
      if pHeightMap[x][y] < 200000 then
        tStr = tStr & "x" & "."
        next repeat
      end if
      tStr = tStr & "." & "."
    end repeat
    put SPACE & SPACE & tStr & SPACE
  end repeat
  put 
  put "PlaceMap:"
  put 
  repeat with x = 1 to pPlaceMap.count
    tStr = EMPTY
    repeat with y = 1 to pPlaceMap[x].count
      if pPlaceMap[x][y] < 100000 then
        tStr = tStr & pPlaceMap[x][y] & "."
        next repeat
      end if
      if pPlaceMap[x][y] < 200000 then
        tStr = tStr & "x" & "."
        next repeat
      end if
      tStr = tStr & "." & "."
    end repeat
    put SPACE & SPACE & tStr & SPACE
  end repeat
  put 
  put "- - - - - - - - - - - - - - -"
end
