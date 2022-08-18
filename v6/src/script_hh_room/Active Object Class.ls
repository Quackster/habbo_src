property pClass, pName, pCustom, pSprList, pDirection, pDimensions, pLoczList, pPartColors, pAnimFrame, pLocX, pLocY, pLocH, pAltitude, pXFactor, pCorrectLocZ, pSmallMember

on construct me
  pClass = EMPTY
  pName = EMPTY
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
  pAltitude = 0.0
  pXFactor = getThread(#room).getInterface().getGeometry().pXFactor
  if (pXFactor = 32) then
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
  pAltitude = tdata[#altitude]
  pLocX = tdata[#x]
  pLocY = tdata[#y]
  pLocH = pAltitude
  me.solveColors(tdata[#colors])
  if (me.solveMembers() = 0) then
    return 0
  end if
  if (me.prepare(tdata[#props]) = 0) then
    return 0
  end if
  me.updateLocation()
  return 1
end

on getInfo me
  tInfo = [:]
  tInfo[#class] = pClass
  tInfo[#name] = getText((("furni_" & pClass) & "_name"), (("furni_" & pClass) & "_name"))
  tInfo[#Custom] = getText((("furni_" & pClass) & "_desc"), (("furni_" & pClass) & "_desc"))
  tInfo[#smallmember] = pSmallMember
  if memberExists(pSmallMember) then
    tInfo[#image] = member(pSmallMember).image
  end if
  return tInfo
end

on getLocation me
  return [pLocX, pLocY, pLocH]
end

on getCustom me
  tCustom = getText((("furni_" & pClass) & "_desc"), (("furni_" & pClass) & "_desc"))
  return tCustom
end

on getSprites me
  return pSprList
end

on select me
  return 0
end

on moveTo me, tX, tY, tH
  pLocX = tX
  pLocY = tY
  pLocH = (tH + pAltitude)
  me.updateLocation()
end

on moveBy me, tX, tY, tH
  pLocX = (pLocX + tX)
  pLocY = (pLocY + tY)
  pLocH = (pLocH + tH)
  me.updateLocation()
end

on rotate me, tChange
  tName = sprite(pSprList[1]).member.name
  tDirection = pDirection
  if voidp(tChange) then
    tChange = 2
  end if
  repeat with j = 0 to 3
    tDirection = (((tDirection + tChange) + j) mod 8)
    if (tDirection[1] < 0) then
      tDirection = (8 + tDirection)
    end if
    tTryName = ((tName.char[1] & tDirection[1]) & "_0")
    if memberExists(tTryName) then
      exit repeat
    end if
  end repeat
  if not memberExists(tTryName) then
    return error(me, (("Direction for object not found:" && pClass) && tDirection[1]), #rotate)
  end if
  getThread(#room).getComponent().getRoomConnection().send("MOVESTUFF", (((me.getID() && me.pLocX) && me.pLocY) && tDirection[1]))
end

on prepare me, tdata
  return 1
end

on relocate me
  return 1
end

on solveColors me, tpartColors
  if voidp(tpartColors) then
    tpartColors = "0,0,0"
  end if
  pPartColors = []
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  repeat with i = 1 to tpartColors.item.count
    pPartColors.add(string(tpartColors.item[i]))
  end repeat
  repeat with j = pPartColors.count to 4
    pPartColors.add("*ffffff")
  end repeat
  the itemDelimiter = tDelim
end

on solveInk me, tPart, tClass
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists((tClass & ".props")) then
    return 8
  end if
  tPropList = value(field(getmemnum((tClass & ".props"))))
  if (tPropList[tPart] = VOID) then
    return 8
  end if
  if (tPropList[tPart][#ink] <> VOID) then
    return tPropList[tPart][#ink]
  end if
  return 8
end

on solveBlend me, tPart, tClass
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists((tClass & ".props")) then
    return 100
  end if
  tPropList = value(field(getmemnum((tClass & ".props"))))
  if (tPropList[tPart] = VOID) then
    return 100
  end if
  if (tPropList[tPart][#blend] <> VOID) then
    return tPropList[tPart][#blend]
  end if
  return 100
end

on solveLocZ me, tPart, tdir, tClass
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists((tClass & ".props")) then
    return 0
  end if
  tPropList = value(field(getmemnum((tClass & ".props"))))
  if (tPropList[tPart] = VOID) then
    return 0
  end if
  if (tPropList[tPart][#zshift] = VOID) then
    return 0
  end if
  if (tPropList[tPart][#zshift].count <= tdir) then
    tdir = 0
  end if
  return tPropList[tPart][#zshift][(tdir + 1)]
end

on solveMembers me
  tClass = pClass
  if (tClass contains "*") then
    tSmallMem = (tClass & "_small")
    tClass = tClass.char[1]
    if not memberExists(tSmallMem) then
      tSmallMem = (tClass & "_small")
    end if
  else
    tSmallMem = (tClass & "_small")
  end if
  pSmallMember = tSmallMem
  if (pSprList.count > 0) then
    repeat with tSpr in pSprList
      releaseSprite(tSpr.spriteNum)
    end repeat
    pSprList = []
  end if
  tMemNum = 1
  i = charToNum("a")
  j = 1
  repeat while (tMemNum > 0)
    tFound = 0
    repeat while (tFound = 0)
      tMemNameA = ((((tClass & "_") & numToChar(i)) & "_") & "0")
      if listp(pDimensions) then
        tMemNameA = ((((tMemNameA & "_") & pDimensions[1]) & "_") & pDimensions[2])
      end if
      if not voidp(pDirection) then
        if (count(pDirection) >= j) then
          tMemName = ((((tMemNameA & "_") & pDirection[j]) & "_") & pAnimFrame)
        else
          tMemName = ((((tMemNameA & "_") & pDirection[1]) & "_") & pAnimFrame)
        end if
      else
        tMemName = ((tMemNameA & "_") & pAnimFrame)
      end if
      tMemNum = getmemnum(tMemName)
      tOldMemName = tMemName
      if not tMemNum then
        tMemName = ((tMemNameA & "_0_") & pAnimFrame)
        tMemNum = getmemnum(tMemName)
      end if
      if (not tMemNum and (j = 1)) then
        tFound = 0
        if listp(pDirection) then
          repeat with tdir = 1 to pDirection.count
            pDirection[tdir] = integer((pDirection[tdir] + 1))
          end repeat
          if (pDirection[1] = 8) then
            error(me, ("Couldn't define members:" && tClass), #solveMembers)
            tMemNum = getmemnum("room_object_placeholder")
            pDirection = [0, 0, 0]
            tFound = 1
          end if
        end if
        next repeat
      end if
      tFound = 1
    end repeat
    if (tMemNum <> 0) then
      if (count(pSprList) >= j) then
        tSpr = pSprList[j]
      else
        tTargetID = getThread(#room).getInterface().getID()
        tSpr = sprite(reserveSprite(me.getID()))
        pSprList.add(tSpr)
        setEventBroker(tSpr.spriteNum, me.getID())
        tSpr.registerProcedure(#eventProcActiveObj, tTargetID, #mouseDown)
        tSpr.registerProcedure(#eventProcActiveRollOver, tTargetID, #mouseEnter)
        tSpr.registerProcedure(#eventProcActiveRollOver, tTargetID, #mouseLeave)
      end if
      if (pLoczList.count < pSprList.count) then
        pLoczList.add([])
      end if
      repeat with tdir = 0 to 7
        pLoczList.getLast().add(me.solveLocZ(numToChar(i), tdir, tClass))
      end repeat
      if (not voidp(tSpr) and (tSpr <> sprite(0))) then
        if (tMemNum < 1) then
          tMemNum = abs(tMemNum)
          tSpr.rotation = 180
          tSpr.skew = 180
        end if
        tSpr.castNum = tMemNum
        tSpr.width = member(tMemNum).width
        tSpr.height = member(tMemNum).height
        tSpr.ink = me.solveInk(numToChar(i), tClass)
        tSpr.blend = me.solveBlend(numToChar(i), tClass)
        if (j <= pPartColors.count) then
          if (string(pPartColors[j]).char[1] = "*") then
            tSpr.bgColor = rgb(("#" & string(pPartColors[j]).char[2]))
          else
            tSpr.bgColor = paletteIndex(integer(pPartColors[j]))
          end if
        end if
      else
        return error(me, "Out of sprites!!!", #solveMembers)
      end if
    end if
    i = (i + 1)
    j = (j + 1)
  end repeat
  tShadowName = (tClass & "_sd")
  if listp(pDirection) then
    tShadowName = ((tShadowName & "_") & pDirection[1])
  end if
  tShadowNum = getmemnum(tShadowName)
  if (not tShadowNum and listp(pDirection)) then
    tShadowNum = getmemnum((tClass & "_sd"))
  end if
  if (tShadowNum <> 0) then
    tSpr = sprite(reserveSprite(me.getID()))
    pSprList.add(tSpr)
    pLoczList.add([-4000, -4000, -4000, -4000, -4000, -4000, -4000])
    if (tShadowNum < 0) then
      tShadowNum = abs(tShadowNum)
      tSpr.rotation = 180
      tSpr.skew = 180
      tSpr.locH = (tSpr.locH + pXFactor)
    end if
    tSpr.castNum = tShadowNum
    tSpr.width = member(tShadowNum).width
    tSpr.height = member(tShadowNum).height
    tSpr.ink = me.solveInk("sd")
    tSpr.blend = me.solveBlend("sd")
    if (tSpr.blend = 100) then
      tSpr.blend = 20
    end if
  end if
  if (pSprList.count > 0) then
    return 1
  else
    return error(me, ("Couldn't define members:" && tClass), #solveMembers)
  end if
end

on updateLocation me
  tScreenLocs = getThread(#room).getInterface().getGeometry().getScreenCoordinate(pLocX, pLocY, pLocH)
  i = 0
  repeat with tSpr in pSprList
    i = (i + 1)
    tSpr.locH = tScreenLocs[1]
    tSpr.locV = tScreenLocs[2]
    if (tSpr.rotation = 180) then
      tSpr.locH = (tSpr.locH + pXFactor)
    end if
    tZ = pLoczList[i][(pDirection[1] + 1)]
    if pCorrectLocZ then
      tSpr.locZ = (((tScreenLocs[3] + (pLocH * 1000)) + tZ) - 1)
      next repeat
    end if
    tSpr.locZ = ((tScreenLocs[3] + tZ) - 1)
  end repeat
  me.relocate()
end
