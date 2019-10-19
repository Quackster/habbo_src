property pFloorMap, pHeightMap, pPlaceMap, pXFactor, pXOffset, pYFactor, pYOffset, pHFactor, pZOffset

on construct me 
  pXOffset = 0
  pYOffset = 0
  pZOffset = 0
  pXFactor = 0
  pYFactor = 0
  pHFactor = 0
  pHeightMap = [[]]
  pPlaceMap = [[]]
  pFloorMap = [[]]
  return(1)
end

on define me, tdata 
  pXOffset = getLocalFloat(tdata.getAt(#offsetx))
  pYOffset = getLocalFloat(tdata.getAt(#offsety))
  pZOffset = getLocalFloat(tdata.getAt(#offsetz))
  pXFactor = getLocalFloat(tdata.getAt(#factorx))
  pYFactor = getLocalFloat(tdata.getAt(#factory))
  pHFactor = getLocalFloat(tdata.getAt(#factorh))
  return(1)
end

on loadHeightMap me, tdata, tUseFloorMap 
  if tUseFloorMap then
    pFloorMap = []
  else
    pHeightMap = []
    pPlaceMap = []
  end if
  i = 1
  repeat while i <= tdata.count(#line)
    l = []
    k = []
    tLine = tdata.getProp(#line, i)
    if tLine <> "" then
      j = 1
      repeat while j <= length(tLine)
        if tLine.getProp(#char, j) = "x" then
          l.add(200000)
          k.add(200000)
        else
          if tLine.getProp(#char, j) = "y" then
            l.add(0)
            k.add(100000)
          else
            if charToNum(tLine.getProp(#char, j)) >= 65 and charToNum(tLine.getProp(#char, j)) < 73 then
              l.add(charToNum(tLine.getProp(#char, j)) - 65)
              k.add(100000)
            else
              l.add(integer(tLine.getProp(#char, j)))
              k.add(0)
            end if
          end if
        end if
        j = 1 + j
      end repeat
      if tUseFloorMap then
        pFloorMap.add(l)
      else
        pHeightMap.add(l)
        pPlaceMap.add(k)
      end if
    end if
    i = 1 + i
  end repeat
  return(1)
end

on getScreenCoordinate me, tLocX, tLocY, tHeight 
  tPrecision = the floatPrecision
  the floatPrecision = 2
  tLocH = (tLocX - tLocY * (pXFactor * 0.5)) + pXOffset
  tLocV = float(((tLocY + tLocX * pYFactor) * 0.5) + pYOffset) - (tHeight * pHFactor)
  tlocz = (1000 * tLocX + tLocY + 1) + pZOffset
  the floatPrecision = tPrecision
  return([integer(tLocH), integer(tLocV), integer(tlocz)])
end

on getCoordinateHeight me, tX, tY 
  tX = integer(tX)
  tY = integer(tY)
  if tY < 0 or tY >= pHeightMap.count then
    return(0)
  end if
  tLine = pHeightMap.getAt(integer(tY + 1))
  if tX < 0 or tX >= tLine.count then
    return(0)
  end if
  return(tLine.getAt(tX + 1))
end

on getWorldCoordinate me, tLocX, tLocY 
  if voidp(pHeightMap) then
    return(void())
  end if
  tX = integer((tLocX - pYFactor - pXOffset / pXFactor) + (tLocY - pYOffset / pYFactor))
  tY = integer((tLocY - pYOffset / pYFactor) - (tLocX - pYFactor - pXOffset / pXFactor))
  tHeight = -1
  if tY >= 0 and tY < pHeightMap.count then
    if tX >= 0 and tX < pHeightMap.getAt(tY + 1).count then
      tHeight = pHeightMap.getAt(tY + 1).getAt(tX + 1)
    end if
  end if
  if tHeight = 0 then
    return([tX, tY, 0])
  else
    i = 1
    repeat while i <= 9
      tX = integer((tLocX - pYFactor - pXOffset / pXFactor) + (tLocY + (i * pHFactor) - pYOffset / pYFactor))
      tY = integer((tLocY + (i * pHFactor) - pYOffset / pYFactor) - (tLocX - pYFactor - pXOffset / pXFactor))
      tHeight = -1
      if tY >= 0 and tY < pHeightMap.count then
        if tX >= 0 and tX < pHeightMap.getAt(tY + 1).count then
          tHeight = pHeightMap.getAt(tY + 1).getAt(tX + 1)
        end if
      end if
      if tHeight = i then
        return([tX, tY, tHeight])
      end if
      i = 1 + i
    end repeat
  end if
  return(0)
end

on getFloorCoordinate me, tLocX, tLocY 
  if voidp(pFloorMap) then
    return(void())
  end if
  tX = integer((tLocX - pYFactor - pXOffset / pXFactor) + (tLocY - pYOffset / pYFactor))
  tY = integer((tLocY - pYOffset / pYFactor) - (tLocX - pYFactor - pXOffset / pXFactor))
  tHeight = -1
  if tY >= 0 and tY < pFloorMap.count then
    if tX >= 0 and tX < pFloorMap.getAt(tY + 1).count then
      tHeight = pFloorMap.getAt(tY + 1).getAt(tX + 1)
    end if
  end if
  if tHeight = 0 then
    return([tX, tY, 0])
  else
    i = 1
    repeat while i <= 9
      tX = integer((tLocX - pYFactor - pXOffset / pXFactor) + (tLocY + (i * pHFactor) - pYOffset / pYFactor))
      tY = integer((tLocY + (i * pHFactor) - pYOffset / pYFactor) - (tLocX - pYFactor - pXOffset / pXFactor))
      tHeight = -1
      if tY >= 0 and tY < pFloorMap.count then
        if tX >= 0 and tX < pFloorMap.getAt(tY + 1).count then
          tHeight = pFloorMap.getAt(tY + 1).getAt(tX + 1)
        end if
      end if
      if tHeight = i then
        return([tX, tY, tHeight])
      end if
      i = 1 + i
    end repeat
  end if
  return(0)
end

on getObjectPlaceMap me 
  return(pPlaceMap)
end

on getObjectHeightMap me 
  return(pHeightMap)
end

on getTileHeight me 
  return(pYFactor)
end

on getTileWidth me 
  return(pXFactor)
end

on emptyTile me, tX, tY 
  tX = tX + 1
  tY = tY + 1
  if tY < 1 or tY > pPlaceMap.count then
    return(0)
  end if
  if tX < 1 or tX > pPlaceMap.getAt(tY).count then
    return(0)
  end if
  return(pPlaceMap.getAt(tY).getAt(tX) < 100000)
end

on print me 
  put("- - - - - - - - - - - - - - -")
  put()
  put("X offset " & pXOffset)
  put("Y offset " & pYOffset)
  put("Z offset " & pZOffset)
  put("X factor " & pXFactor)
  put("Y factor " & pYFactor)
  put("H factor " & pHFactor)
  put()
  put("HeightMap:")
  put()
  x = 1
  repeat while x <= pHeightMap.count
    tStr = ""
    y = 1
    repeat while y <= pHeightMap.getAt(x).count
      if pHeightMap.getAt(x).getAt(y) < 100000 then
        tStr = tStr & pHeightMap.getAt(x).getAt(y) & "."
      else
        if pHeightMap.getAt(x).getAt(y) < 200000 then
          tStr = tStr & "x" & "."
        else
          tStr = tStr & "." & "."
        end if
      end if
      y = 1 + y
    end repeat
    put(space() & space() & tStr & space())
    x = 1 + x
  end repeat
  put()
  put("PlaceMap:")
  put()
  x = 1
  repeat while x <= pPlaceMap.count
    tStr = ""
    y = 1
    repeat while y <= pPlaceMap.getAt(x).count
      if pPlaceMap.getAt(x).getAt(y) < 100000 then
        tStr = tStr & pPlaceMap.getAt(x).getAt(y) & "."
      else
        if pPlaceMap.getAt(x).getAt(y) < 200000 then
          tStr = tStr & "x" & "."
        else
          tStr = tStr & "." & "."
        end if
      end if
      y = 1 + y
    end repeat
    put(space() & space() & tStr & space())
    x = 1 + x
  end repeat
  put()
  put("- - - - - - - - - - - - - - -")
end

on printFloor me 
  put("--- FLOOR MAP ---")
  x = 1
  repeat while x <= pFloorMap.count
    tStr = ""
    y = 1
    repeat while y <= pFloorMap.getAt(x).count
      if pFloorMap.getAt(x).getAt(y) < 100000 then
        tStr = tStr & pFloorMap.getAt(x).getAt(y) & "."
      else
        if pFloorMap.getAt(x).getAt(y) < 200000 then
          tStr = tStr & "x" & "."
        else
          tStr = tStr & "." & "."
        end if
      end if
      y = 1 + y
    end repeat
    put(space() & space() & tStr & space())
    x = 1 + x
  end repeat
  put()
end
