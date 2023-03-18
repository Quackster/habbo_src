property pClass, pSprList, pDirection, pDimensions, pLoczList, pPartColors, pAnimFrame, pLocX, pLocY, pLocH, pAltitude, pXFactor, pCustom, pCorrectLocZ

on construct me
  pClass = EMPTY
  pCustom = EMPTY
  pSprList = []
  pDirection = []
  pDimensions = []
  pLoczList = []
  pPartColors = []
  pAnimFrame = 0
  pLocX = 0
  pLocY = 0
  pLocH = 0
  pAltitude = 0
  pXFactor = getThread(#room).getInterface().getGeometry().pXFactor
  if pXFactor = 32 then
    pCorrectLocZ = 0
  else
    pCorrectLocZ = 1
  end if
  return 1
end

on deconstruct me
  repeat with tSpr in pSprList
    releaseSprite(tSpr.spriteNum)
  end repeat
  pSprList = []
  return 1
end

on define me, tdata
  pClass = tdata[#class]
  pDirection = tdata[#direction]
  pDimensions = tdata[#dimensions]
  pLocX = tdata[#x]
  pLocY = tdata[#y]
  pLocH = tdata[#h]
  me.solveColors(tdata[#colors])
  if me.solveMembers() = 0 then
    return 0
  end if
  if me.prepare(tdata[#props]) = 0 then
    return 0
  end if
  me.updateLocation()
  return 1
end

on prepare me, tdata
  return 1
end

on getInfo me
  tInfo = [:]
  tInfo[#name] = pClass
  tInfo[#class] = pClass
  tInfo[#custom] = pCustom
  return tInfo
end

on getLocation me
  return [pLocX, pLocY, pLocH]
end

on getDirection me
  return pDirection
end

on getSprites me
  return pSprList
end

on select me
  return 0
end

on solveColors me, tpartColors
  if voidp(tpartColors) then
    tpartColors = "0,0,0"
  end if
  pPartColors = []
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  repeat with t = 1 to tpartColors.item.count
    pPartColors.add(string(tpartColors.item[t]))
  end repeat
  repeat with j = pPartColors.count to 4
    pPartColors.add("*ffffff")
  end repeat
  the itemDelimiter = tDelim
end

on solveInk me, tPart
  if not memberExists(pClass & ".props") then
    return 8
  end if
  tPropList = value(field(getmemnum(pClass & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, pClass & ".props is not valid!", #solveInk)
    return 8
  else
    if voidp(tPropList[tPart]) then
      return 8
    end if
    if not voidp(tPropList[tPart][#ink]) then
      return tPropList[tPart][#ink]
    end if
  end if
  return 8
end

on solveBlend me, tPart
  if not memberExists(pClass & ".props") then
    return 100
  end if
  tPropList = value(field(getmemnum(pClass & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, pClass & ".props is not valid!", #solveBlend)
    return 100
  else
    if voidp(tPropList[tPart]) then
      return 100
    end if
    if not voidp(tPropList[tPart][#blend]) then
      return tPropList[tPart][#blend]
    end if
  end if
  return 100
end

on solveLocZ me, tPart, tdir
  if not memberExists(pClass & ".props") then
    return 0
  end if
  tPropList = value(field(getmemnum(pClass & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, pClass & ".props is not valid!", #solveLocZ)
    return 0
  else
    if voidp(tPropList[tPart]) then
      return 0
    end if
    if voidp(tPropList[tPart][#zshift]) then
      return 0
    end if
    if tPropList[tPart][#zshift].count <= tdir then
      tdir = 0
    end if
  end if
  return tPropList[tPart][#zshift][tdir + 1]
end

on solveMembers me
  if listp(pDirection) then
    tTmpDirection = pDirection.duplicate()
  else
    tTmpDirection = pDirection
  end if
  if pSprList.count > 0 then
    repeat with tSpr in pSprList
      releaseSprite(tSpr.spriteNum)
    end repeat
    pSprList = []
  end if
  tMemNum = 1
  i = charToNum("a")
  j = 1
  repeat while tMemNum > 0
    if pClass = "null" then
      opopop = 0
    end if
    tFound = 0
    repeat while tFound = 0
      tMemNameA = pClass & "_" & numToChar(i) & "_" & "0"
      if listp(pDimensions) then
        tMemNameA = tMemNameA & "_" & pDimensions[1] & "_" & pDimensions[2]
      end if
      if not voidp(tTmpDirection) then
        if count(tTmpDirection) >= j then
          tMemName = tMemNameA & "_" & tTmpDirection[j] & "_" & pAnimFrame
        else
          tMemName = tMemNameA & "_" & tTmpDirection[1] & "_" & pAnimFrame
        end if
      else
        tMemName = tMemNameA & "_" & pAnimFrame
      end if
      tMemNum = getmemnum(tMemName)
      tOldMemName = tMemName
      if tMemNum = 0 then
        tMemName = tMemNameA & "_0_" & pAnimFrame
        tMemNum = getmemnum(tMemName)
      end if
      if (tMemNum = 0) and (j = 1) then
        tFound = 0
        if listp(pDirection) then
          repeat with tdir = 1 to tTmpDirection.count
            tTmpDirection[tdir] = integer(tTmpDirection[tdir] + 1)
          end repeat
          if tTmpDirection[1] = 8 then
            return 0
          end if
        else
          return error(me, "No good object:" && pClass, #solveMembers)
        end if
        next repeat
      end if
      tFound = 1
    end repeat
    if tMemNum <> 0 then
      if count(pSprList) >= j then
        tSpr = pSprList[j]
      else
        tSpr = sprite(reserveSprite(me.getID()))
        pSprList.add(tSpr)
        setEventBroker(tSpr.spriteNum, me.getID())
        tTargetID = getThread(#room).getInterface().getID()
        tSpr.registerProcedure(#eventProcPassiveObj, tTargetID, #mouseDown)
      end if
      if not voidp(pDirection) then
        if count(pDirection) >= j then
          pLoczList.add(me.solveLocZ(numToChar(i), pDirection[j]))
        else
          pLoczList.add(me.solveLocZ(numToChar(i), VOID))
        end if
      else
        pLoczList.add(me.solveLocZ(numToChar(i), VOID))
      end if
      if not voidp(tSpr) and (tSpr <> sprite(0)) then
        if tMemNum < 1 then
          tMemNum = abs(tMemNum)
          tSpr.rotation = 180
          tSpr.skew = 180
        end if
        tSpr.castNum = tMemNum
        tSpr.width = member(tMemNum).width
        tSpr.height = member(tMemNum).height
        tSpr.ink = me.solveInk(numToChar(i))
        tSpr.blend = me.solveBlend(numToChar(i))
        if j <= pPartColors.count then
          if string(pPartColors[j]).char[1] = "#" then
            tSpr.bgColor = rgb(pPartColors[j])
          else
            tSpr.bgColor = paletteIndex(integer(pPartColors[j]))
          end if
        end if
      else
        return error(me, "Out of sprites!!!", #solveMembers)
      end if
    end if
    i = i + 1
    j = j + 1
  end repeat
  tShadowName = pClass & "_sd"
  if listp(pDirection) then
    tShadowName = tShadowName & "_" & pDirection[1]
  end if
  tShadowNum = getmemnum(tShadowName)
  if not tShadowNum and listp(tTmpDirection) then
    tShadowNum = getmemnum(pClass & "_sd")
  end if
  if tShadowNum <> 0 then
    tSpr = sprite(reserveSprite(me.getID()))
    pSprList.add(tSpr)
    pLoczList.add(-4000)
    if tShadowNum < 0 then
      tShadowNum = abs(tShadowNum)
      tSpr.rotation = 180
      tSpr.skew = 180
      tSpr.locH = tSpr.locH + pXFactor
    end if
    tSpr.castNum = tShadowNum
    tSpr.width = member(tShadowNum).width
    tSpr.height = member(tShadowNum).height
    tSpr.ink = me.solveInk("sd")
    tSpr.blend = me.solveBlend("sd")
    if tSpr.blend = 100 then
      tSpr.blend = 20
    end if
  end if
  if pSprList.count > 0 then
    return 1
  else
    return error(me, "Couldn't define members:" && pClass, #solveMembers)
  end if
end

on updateLocation me
  tScreenLocs = getThread(#room).getInterface().getGeometry().getScreenCoordinate(pLocX, pLocY, pLocH)
  i = 0
  repeat with tSpr in pSprList
    i = i + 1
    tSpr.locH = tScreenLocs[1]
    tSpr.locV = tScreenLocs[2]
    if tSpr.rotation = 180 then
      tSpr.locH = tSpr.locH + pXFactor
    end if
    if i <= pLoczList.count then
      tZ = pLoczList[i]
    else
      tZ = 0
    end if
    if pCorrectLocZ then
      tSpr.locZ = tScreenLocs[3] + (pLocH * 1000) + tZ
      next repeat
    end if
    tSpr.locZ = tScreenLocs[3] + tZ
  end repeat
end

on show me
  repeat with tSpr in pSprList
    tSpr.visible = 1
  end repeat
end

on hide me
  repeat with tSpr in pSprList
    tSpr.visible = 0
  end repeat
end
