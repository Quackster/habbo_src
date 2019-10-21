on construct(me)
  pClass = ""
  pName = ""
  pCustom = ""
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
  return(1)
  exit
end

on deconstruct(me)
  repeat while me <= undefined
    tSpr = getAt(undefined, undefined)
    releaseSprite(tSpr.spriteNum)
  end repeat
  pSprList = []
  return(1)
  exit
end

on define(me, tdata)
  pClass = tdata.getAt(#class)
  pName = tdata.getAt(#name)
  pCustom = tdata.getAt(#custom)
  pDirection = tdata.getAt(#direction)
  pDimensions = tdata.getAt(#dimensions)
  pAltitude = tdata.getAt(#altitude)
  pLocX = tdata.getAt(#x)
  pLocY = tdata.getAt(#y)
  pLocH = pAltitude
  if pClass contains "*" then
    pClass = pClass.getProp(#char, 1, offset("*", pClass) - 1)
  end if
  me.solveColors(tdata.getAt(#colors))
  if me.solveMembers() = 0 then
    return(0)
  end if
  if me.prepare(tdata.getAt(#props)) = 0 then
    return(0)
  end if
  me.updateLocation()
  return(1)
  exit
end

on getInfo(me)
  tInfo = []
  tInfo.setAt(#name, pName)
  tInfo.setAt(#class, pClass)
  tInfo.setAt(#custom, pCustom)
  if memberExists(pClass & "_small") then
    tInfo.setAt(#image, member(getmemnum(pClass & "_small")).image)
  end if
  return(tInfo)
  exit
end

on getCustom(me)
  return(pCustom)
  exit
end

on getSprites(me)
  return(pSprList)
  exit
end

on select(me)
  return(0)
  exit
end

on moveTo(me, tX, tY, tH)
  pLocX = tX
  pLocY = tY
  pLocH = tH + pAltitude
  me.updateLocation()
  exit
end

on moveBy(me, tX, tY, tH)
  pLocX = pLocX + tX
  pLocY = pLocY + tY
  pLocH = pLocH + tH
  me.updateLocation()
  exit
end

on rotate(me, tChange)
  tName = member.name
  tDirection = pDirection
  if voidp(tChange) then
    tChange = 2
  end if
  j = 0
  repeat while j <= 3
    tDirection = tDirection + tChange + j mod 8
    if tDirection.getAt(1) < 0 then
      tDirection = 8 + tDirection
    end if
    tTryName = tName.getProp(#char, 1, length(tName) - 3) & tDirection.getAt(1) & "_0"
    if memberExists(tTryName) then
    else
      j = 1 + j
    end if
  end repeat
  if not memberExists(tTryName) then
    return(error(me, "Direction for object not found:" && pClass && tDirection.getAt(1), #rotate))
  end if
  getThread(#room).getComponent().getRoomConnection().send(#room, "MOVESTUFF" && me.getID() && me.pLocX && me.pLocY && tDirection.getAt(1))
  exit
end

on prepare(me, tdata)
  return(1)
  exit
end

on relocate(me)
  return(1)
  exit
end

on solveColors(me, tpartColors)
  if voidp(tpartColors) then
    tpartColors = "0,0,0"
  end if
  pPartColors = []
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  i = 1
  repeat while i <= tpartColors.count(#item)
    pPartColors.add(string(tpartColors.getProp(#item, i)))
    i = 1 + i
  end repeat
  j = pPartColors.count
  repeat while j <= 4
    pPartColors.add("*ffffff")
    j = 1 + j
  end repeat
  the itemDelimiter = tDelim
  exit
end

on solveInk(me, tPart)
  tInkField = getmemnum(pClass & "_" & tPart & ".ink")
  if tInkField > 0 then
    return(integer(field(0)))
  end if
  return(8)
  exit
end

on solveBlend(me, tPart)
  tBlendField = getmemnum(pClass & "_" & tPart & ".blend")
  if tBlendField > 0 then
    return(integer(field(0)))
  end if
  return(100)
  exit
end

on solveLocZ(me, tPart, tdir)
  if not memberExists(pClass & "_" & tPart & ".zshift") then
    return(0)
  end if
  if field(0).count(#line) = 1 then
    tdir = 0
  end if
  return(integer(field(0).getProp(#line, tdir + 1)))
  exit
end

on solveMembers(me)
  if pSprList.count > 0 then
    repeat while me <= undefined
      tSpr = getAt(undefined, undefined)
      releaseSprite(tSpr.spriteNum)
    end repeat
    pSprList = []
  end if
  tMemNum = 1
  i = charToNum("a")
  j = 1
  repeat while tMemNum > 0
    tFound = 0
    repeat while tFound = 0
      tMemNameA = pClass & "_" & numToChar(i) & "_" & "0"
      if listp(pDimensions) then
        tMemNameA = tMemNameA & "_" & pDimensions.getAt(1) & "_" & pDimensions.getAt(2)
      end if
      if not voidp(pDirection) then
        if count(pDirection) >= j then
          tMemName = tMemNameA & "_" & pDirection.getAt(j) & "_" & pAnimFrame
        else
          tMemName = tMemNameA & "_" & pDirection.getAt(1) & "_" & pAnimFrame
        end if
      else
        tMemName = tMemNameA & "_" & pAnimFrame
      end if
      tMemNum = getmemnum(tMemName)
      tOldMemName = tMemName
      if not tMemNum then
        tMemName = tMemNameA & "_0_" & pAnimFrame
        tMemNum = getmemnum(tMemName)
      end if
      if not tMemNum and j = 1 then
        tFound = 0
        if listp(pDirection) then
          tdir = 1
          repeat while tdir <= pDirection.count
            pDirection.setAt(tdir, integer(pDirection.getAt(tdir) + 1))
            tdir = 1 + tdir
          end repeat
          if pDirection.getAt(1) = 8 then
            error(me, "Couldn't define members:" && pClass, #solveMembers)
            tMemNum = getmemnum("room_object_placeholder")
            pDirection = [0, 0, 0]
            tFound = 1
          end if
        end if
        next repeat
      end if
      tFound = 1
    end repeat
    if tMemNum <> 0 then
      if count(pSprList) >= j then
        tSpr = pSprList.getAt(j)
      else
        tTargetID = getThread(#room).getInterface().getID()
        tSpr = sprite(reserveSprite(me.getID()))
        pSprList.add(tSpr)
        setEventBroker(tSpr.spriteNum, me.getID())
        tSpr.registerProcedure(#eventProcActiveObj, tTargetID, #mouseDown)
        tSpr.registerProcedure(#eventProcActiveRollOver, tTargetID, #mouseEnter)
        tSpr.registerProcedure(#eventProcActiveRollOver, tTargetID, #mouseLeave)
      end if
      if pLoczList.count < pSprList.count then
        pLoczList.add([])
      end if
      tdir = 0
      repeat while tdir <= 7
        pLoczList.getLast().add(me.solveLocZ(numToChar(i), tdir))
        tdir = 1 + tdir
      end repeat
      if not voidp(tSpr) and tSpr <> sprite(0) then
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
          if string(pPartColors.getAt(j)).getProp(#char, 1) = "*" then
            tSpr.bgColor = rgb("#" & string(pPartColors.getAt(j)).getProp(#char, 2, length(string(pPartColors.getAt(j)))))
          else
            tSpr.bgColor = paletteIndex(integer(pPartColors.getAt(j)))
          end if
        end if
      else
        return(error(me, "Out of sprites!!!", #solveMembers))
      end if
    end if
    i = i + 1
    j = j + 1
  end repeat
  tShadowName = pClass & "_sd"
  if listp(pDirection) then
    tShadowName = tShadowName & "_" & pDirection.getAt(1)
  end if
  tShadowNum = getmemnum(tShadowName)
  if not tShadowNum and listp(pDirection) then
    tShadowNum = getmemnum(pClass & "_sd")
  end if
  if tShadowNum <> 0 then
    tSpr = sprite(reserveSprite(me.getID()))
    pSprList.add(tSpr)
    pLoczList.add([-4000, -4000, -4000, -4000, -4000, -4000, -4000])
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
    return(1)
  else
    return(error(me, "Couldn't define members:" && pClass, #solveMembers))
  end if
  exit
end

on updateLocation(me)
  tScreenLocs = getThread(#room).getInterface().getGeometry().getScreenCoordinate(pLocX, pLocY, pLocH)
  i = 0
  repeat while me <= undefined
    tSpr = getAt(undefined, undefined)
    i = i + 1
    tSpr.locH = tScreenLocs.getAt(1)
    tSpr.locV = tScreenLocs.getAt(2)
    if tSpr.rotation = 180 then
      tSpr.locH = tSpr.locH + pXFactor
    end if
    tZ = pLoczList.getAt(i).getAt(pDirection.getAt(1) + 1)
    if pCorrectLocZ then
      tSpr.locZ = tScreenLocs.getAt(3) + pLocH * 1000 + tZ - 1
    else
      tSpr.locZ = tScreenLocs.getAt(3) + tZ - 1
    end if
  end repeat
  me.relocate()
  exit
end