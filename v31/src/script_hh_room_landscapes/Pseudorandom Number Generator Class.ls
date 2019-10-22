property pMult, pSeed, pIncrement, pModulus

on construct me 
  pSeed = 1
  pModulus = 16777216
  pMult = 69069
  pIncrement = 5
  return TRUE
end

on setSeed me, tSeed 
  pSeed = tSeed
end

on setModulus me, tModulus 
  pModulus = tModulus
end

on iterate me 
  tX = (abs(((integer(pMult) * integer(pSeed)) + integer(pIncrement))) mod integer(pModulus))
  pSeed = tX
  return(tX)
end

on getScaled me, tMin, tMax 
  tX = me.iterate()
  if voidp(tMin) and voidp(tMax) then
    return(tX)
  end if
  tRange = float((tMax - tMin))
  if (tRange = 0) then
    return(tMin)
  end if
  tScale = (pModulus / tRange)
  return(integer(((tX / tScale) + tMin)))
end

on getArray me, tCount, tMin, tMax 
  tArray = []
  i = 1
  repeat while i <= tCount
    tArray.add(me.getScaled(tMin, tMax))
    i = (1 + i)
  end repeat
  return(tArray)
end

on getArrayWithCountLimits me, tCount, tMin, tMax, tLimitList 
  if not listp(tLimitList) then
    return(getArray(tCount, tMin, tMax))
  end if
  tArray = []
  tOrderList = []
  i = 1
  repeat while i <= tCount
    tOrderList.setAt(i, i)
    i = (1 + i)
  end repeat
  i = 1
  repeat while i <= tCount
    tTarget = me.getScaled(1, tCount)
    repeat while (tTarget = i)
      tTarget = me.getScaled(1, tCount)
    end repeat
    tTemp = tOrderList.getAt(i)
    tOrderList.setAt(i, tOrderList.getAt(tTarget))
    tOrderList.setAt(tTarget, tTemp)
    i = (1 + i)
  end repeat
  tLims = tLimitList.duplicate()
  c = 1
  repeat while c < (tCount + 1)
    t = me.getScaled(tMin, tMax)
    tCountLeft = tLims.getaProp(t)
    if tCountLeft > 0 then
      tLims.setaProp(t, (tCountLeft - 1))
    else
      if not voidp(tCountLeft) and tCountLeft > -1 then
        next repeat
      end if
    end if
    tArray.setAt(tOrderList.getAt(c), t)
    c = (c + 1)
  end repeat
  return(tArray)
end
