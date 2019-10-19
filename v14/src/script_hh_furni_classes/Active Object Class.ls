property pXFactor, pSprList, pAltitude, pClass, pSmallMember, pPartColors, pLocX, pLocY, pLocH, pDirection, pSlideStartTime, pSlideTimePerTile, pSlideEndTime, pDestLoc, pStartloc, pDimensions, pAnimFrame, pLoczList, pLocShiftList, pCorrectLocZ

on construct me 
  pClass = ""
  pName = ""
  pCustom = ""
  pSprList = []
  pDirection = []
  pDimensions = []
  pLoczList = []
  pLocShiftList = []
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
  pSlideTimePerTile = 500
  return(1)
end

on deconstruct me 
  repeat while pSprList <= undefined
    tSpr = getAt(undefined, undefined)
    releaseSprite(tSpr.spriteNum)
  end repeat
  if threadExists(#room) then
    tRoomThread = getThread(#room)
    tComponent = tRoomThread.getComponent()
    tShadowManager = tComponent.getShadowManager()
    tShadowManager.removeShadow(me.getID())
    tComponent.removeSlideObject(me.getID())
  end if
  pSprList = []
  return(1)
end

on define me, tdata 
  pClass = tdata.getAt(#class)
  pDirection = tdata.getAt(#direction)
  pDimensions = tdata.getAt(#dimensions)
  pAltitude = tdata.getAt(#altitude)
  pLocX = tdata.getAt(#x)
  pLocY = tdata.getAt(#y)
  pLocH = pAltitude
  me.solveColors(tdata.getAt(#colors))
  if me.solveMembers() = 0 then
    return(0)
  end if
  if me.prepare(tdata.getAt(#props)) = 0 then
    return(0)
  end if
  me.updateLocation()
  return(1)
end

on getInfo me 
  tInfo = [:]
  tInfo.setAt(#class, pClass)
  tInfo.setAt(#name, getText("furni_" & pClass & "_name", "furni_" & pClass & "_name"))
  tInfo.setAt(#custom, getText("furni_" & pClass & "_desc", "furni_" & pClass & "_desc"))
  tInfo.setAt(#smallmember, pSmallMember)
  tInfo.setAt(#image, getObject("Preview_renderer").renderPreviewImage(void(), pPartColors, void(), pClass))
  return(tInfo)
end

on getLocation me 
  return([pLocX, pLocY, pLocH])
end

on getCustom me 
  tCustom = getText("furni_" & pClass & "_desc", "furni_" & pClass & "_desc")
  return(tCustom)
end

on getSprites me 
  return(pSprList)
end

on select me 
  return(0)
end

on moveTo me, tX, tY, tH 
  pLocX = tX
  pLocY = tY
  pLocH = tH + pAltitude
  me.updateLocation()
end

on moveBy me, tX, tY, tH 
  pLocX = pLocX + tX
  pLocY = pLocY + tY
  pLocH = pLocH + tH
  me.updateLocation()
end

on rotate me, tChange 
  tName = member.name
  tDirection = pDirection
  if voidp(tChange) then
    tChange = 2
  end if
  j = 0
  repeat while j <= 3
    tDirection = (tDirection + tChange + j mod 8)
    if tDirection.getAt(1) < 0 then
      tDirection = 8 + tDirection
    end if
    tTryName = tName.getProp(#char, 1, length(tName) - 3) & tDirection.getAt(1) & "_0"
    if memberExists(tTryName) then
    else
      if not tTryName contains pClass then
        tDelim = the itemDelimiter
        the itemDelimiter = "_"
        tTryName2 = pClass
        if pXFactor = 32 then
          tTryName2 = "s_" & tTryName2
        end if
        i = tTryName.count(#item) - 5
        repeat while i <= tTryName.count(#item)
          tTryName2 = tTryName2 & "_" & tTryName.getProp(#item, i)
          i = 1 + i
        end repeat
        the itemDelimiter = tDelim
        if memberExists(tTryName2) then
          tTryName = tTryName2
        else
          j = 1 + j
        end if
        if not memberExists(tTryName) then
          return(error(me, "Direction for object not found:" && pClass && tDirection.getAt(1), #rotate, #minor))
        end if
        getThread(#room).getComponent().getRoomConnection().send("MOVESTUFF", me.getID() && me.pLocX && me.pLocY && tDirection.getAt(1))
      end if
    end if
  end repeat
end

on setSlideTo me, tFromLoc, tToLoc, tTimeNow, tHasCharacter 
  if voidp(tTimeNow) then
    tTimeNow = the milliSeconds
  end if
  pSlideStartTime = tTimeNow
  pLastSlideUpdateTime = pSlideStartTime
  pLocX = getLocalFloat(tFromLoc.getAt(1))
  pLocY = getLocalFloat(tFromLoc.getAt(2))
  pLocH = getLocalFloat(tFromLoc.getAt(3))
  tDistances = []
  tDistances.setAt(1, abs(tFromLoc.getAt(1) - tToLoc.getAt(1)))
  tDistances.setAt(2, abs(tFromLoc.getAt(2) - tToLoc.getAt(2)))
  tDistances.setAt(3, abs(tFromLoc.getAt(3) - tToLoc.getAt(3)))
  tMoveTime = (max(tDistances) * pSlideTimePerTile)
  pSlideEndTime = pSlideStartTime + tMoveTime
  pStartloc = [pLocX, pLocY, pLocH]
  pDestLoc = tToLoc
  me.updateLocation()
end

on animateSlide me, tTimeNow 
  if voidp(tTimeNow) then
    tTimeNow = the milliSeconds
  end if
  if pSlideEndTime < tTimeNow then
    pLocX = pDestLoc.getAt(1).integer
    pLocY = pDestLoc.getAt(2).integer
    pLocH = pDestLoc.getAt(3)
    me.removeSlideObject(ancestor.id)
    me.updateLocation()
    return(1)
  end if
  tTimeUsed = float(tTimeNow - pSlideStartTime)
  tPercentSlided = (tTimeUsed / float(pSlideEndTime - pSlideStartTime))
  pLocX = (float(pDestLoc.getAt(1) - pStartloc.getAt(1)) * tPercentSlided) + pStartloc.getAt(1)
  pLocY = (float(pDestLoc.getAt(2) - pStartloc.getAt(2)) * tPercentSlided) + pStartloc.getAt(2)
  pLocH = (float(pDestLoc.getAt(3) - pStartloc.getAt(3)) * tPercentSlided) + pStartloc.getAt(3)
  me.updateLocation()
  return(1)
end

on ghostObject me 
  repeat while pSprList <= undefined
    tSpr = getAt(undefined, undefined)
    if tSpr.ink = 33 then
      tSpr.visible = 0
    else
      tSpr.blend = 35
    end if
  end repeat
end

on removeGhostEffect me 
  repeat while pSprList <= undefined
    tSpr = getAt(undefined, undefined)
    tSpr.visible = 1
    tSpr.blend = 100
  end repeat
end

on prepare me, tdata 
  return(1)
end

on relocate me, tSpriteList 
  return(1)
end

on solveColors me, tpartColors 
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
end

on solveInk me, tPart, tClass 
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists(tClass & ".props") then
    return(8)
  end if
  tPropList = value(field(0))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #solveInk, #minor)
    return(8)
  else
    if voidp(tPropList.getAt(tPart)) then
      return(8)
    end if
    if not voidp(tPropList.getAt(tPart).getAt(#ink)) then
      return(tPropList.getAt(tPart).getAt(#ink))
    end if
  end if
  return(8)
end

on solveBlend me, tPart, tClass 
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists(tClass & ".props") then
    return(100)
  end if
  tPropList = value(field(0))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #solveBlend, #minor)
    return(100)
  else
    if voidp(tPropList.getAt(tPart)) then
      return(100)
    end if
    if not voidp(tPropList.getAt(tPart).getAt(#blend)) then
      return(tPropList.getAt(tPart).getAt(#blend))
    end if
  end if
  return(100)
end

on solveLocZ me, tPart, tdir, tClass 
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists(tClass & ".props") then
    return(0)
  end if
  tPropList = value(field(0))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #solveLocZ, #minor)
    return(0)
  else
    if voidp(tPropList.getAt(tPart)) then
      return(0)
    end if
    if voidp(tPropList.getAt(tPart).getAt(#zshift)) then
      return(0)
    end if
    if tPropList.getAt(tPart).getAt(#zshift).count <= tdir then
      tdir = 0
    end if
  end if
  return(tPropList.getAt(tPart).getAt(#zshift).getAt(tdir + 1))
end

on solveLocShift me, tPart, tdir, tClass 
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists(tClass & ".props") then
    return(0)
  end if
  tPropList = value(field(0))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #solveLocShift, #minor)
    return(0)
  else
    if voidp(tPropList.getAt(tPart)) then
      return(0)
    end if
    if voidp(tPropList.getAt(tPart).getAt(#locshift)) then
      return(0)
    end if
    if tPropList.getAt(tPart).getAt(#locshift).count <= tdir then
      return(0)
    end if
    tShift = value(tPropList.getAt(tPart).getAt(#locshift).getAt(tdir + 1))
    if ilk(tShift) = #point then
      return(tShift)
    end if
  end if
  return(0)
end

on solveMembers me 
  tClass = pClass
  if tClass contains "*" then
    tSmallMem = tClass & "_small"
    tClass = tClass.getProp(#char, 1, offset("*", tClass) - 1)
    if not memberExists(tSmallMem) then
      tSmallMem = tClass & "_small"
    end if
  else
    tSmallMem = tClass & "_small"
  end if
  pSmallMember = tSmallMem
  if pXFactor = 32 then
    tClass = "s_" & tClass
  end if
  if pSprList.count > 0 then
    repeat while pSprList <= undefined
      tSpr = getAt(undefined, undefined)
      releaseSprite(tSpr.spriteNum)
    end repeat
    pSprList = []
  end if
  tMemNum = 1
  i = charToNum("a")
  j = 1
  tLoczAdjust = -5
  repeat while tMemNum > 0
    tFound = 0
    repeat while tFound = 0
      tMemNameA = tClass & "_" & numToChar(i) & "_" & "0"
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
            error(me, "Couldn't define members:" && tClass, #solveMembers, #minor)
            if pXFactor = 32 then
              tMemNum = getmemnum("s_room_object_placeholder")
            else
              tMemNum = getmemnum("room_object_placeholder")
            end if
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
        if tSpr = sprite(0) then
          tRoomThread = getThread(#room)
          if not voidp(tRoomThread) then
            tRoomThread.getComponent().releaseSpritesFromActiveObjects()
          end if
          return(error(me, "Could not reserve sprite for: " && tClass, #solveMembers, #major))
        end if
        pSprList.add(tSpr)
        setEventBroker(tSpr.spriteNum, me.getID())
        tSpr.registerProcedure(#eventProcActiveObj, tTargetID, #mouseDown)
        tSpr.registerProcedure(#eventProcActiveRollOver, tTargetID, #mouseEnter)
        tSpr.registerProcedure(#eventProcActiveRollOver, tTargetID, #mouseLeave)
      end if
      if pLoczList.count < pSprList.count then
        pLoczList.add([])
      end if
      if pLocShiftList.count < pSprList.count then
        pLocShiftList.add([])
      end if
      tdir = 0
      repeat while tdir <= 7
        pLoczList.getLast().add(integer(me.solveLocZ(numToChar(i), tdir, tClass)) + tLoczAdjust)
        pLocShiftList.getLast().add(me.solveLocShift(numToChar(i), tdir, tClass))
        tdir = 1 + tdir
      end repeat
      tLoczAdjust = tLoczAdjust + 1
      if not voidp(tSpr) and tSpr <> sprite(0) then
        if tMemNum < 1 then
          tMemNum = abs(tMemNum)
          tSpr.rotation = 180
          tSpr.skew = 180
        end if
        tSpr.castNum = tMemNum
        tSpr.width = member(tMemNum).width
        tSpr.height = member(tMemNum).height
        tSpr.ink = me.solveInk(numToChar(i), tClass)
        tSpr.blend = me.solveBlend(numToChar(i), tClass)
        if j <= pPartColors.count then
          if string(pPartColors.getAt(j)).getProp(#char, 1) = "#" then
            tSpr.bgColor = rgb(pPartColors.getAt(j))
          else
            tSpr.bgColor = paletteIndex(integer(pPartColors.getAt(j)))
          end if
        end if
      else
        return(error(me, "Out of sprites!!!", #solveMembers, #major))
      end if
    end if
    i = i + 1
    j = j + 1
  end repeat
  tShadowName = tClass & "_sd"
  if listp(pDirection) then
    tShadowName = tShadowName & "_" & pDirection.getAt(1)
  end if
  tShadowNum = getmemnum(tShadowName)
  if not tShadowNum and listp(pDirection) then
    tShadowNum = getmemnum(tClass & "_sd")
  end if
  if threadExists(#room) then
    tRoomThread = getThread(#room)
    tComponent = tRoomThread.getComponent()
    tShadowManager = tComponent.getShadowManager()
  else
    return(0)
  end if
  tid = me.getID()
  tRoomType = getObject(#session).GET("lastroom").getAt(#type)
  if tRoomType <> #private then
    if tShadowNum <> 0 then
      tSpr = sprite(reserveSprite(tid))
      pSprList.add(tSpr)
      pLoczList.add([-4000, -4000, -4000, -4000, -4000, -4000, -4000])
      pLocShiftList.add([0, 0, 0, 0, 0, 0, 0, 0])
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
  else
    if voidp(tShadowManager) then
      return(0)
    end if
    tShadowManager.removeShadow(tid)
    if tShadowNum <> 0 and pLocH = integer(pLocH) then
      tProps = [:]
      tScreenLocs = tRoomThread.getInterface().getGeometry().getScreenCoordinate(pLocX, pLocY, pLocH)
      tmember = member(tShadowNum)
      if tShadowNum < 0 then
        tShadowNum = abs(tShadowNum)
        tmember = member(tShadowNum)
        tProps.setAt(#multiflip, 1)
        tProps.setAt(#offsetx, pXFactor)
      end if
      tProps.setAt(#member, member(tShadowNum).name)
      tProps.setAt(#locH, tScreenLocs.getAt(1))
      tProps.setAt(#locV, tScreenLocs.getAt(2))
      tProps.setAt(#width, tmember.width)
      tProps.setAt(#height, tmember.height)
      tProps.setAt(#id, tid)
      tShadowManager.addShadow(tProps)
      tShadowManager.render()
    end if
  end if
  if pSprList.count > 0 then
    return(1)
  else
    return(error(me, "Couldn't define members:" && tClass, #solveMembers, #major))
  end if
end

on updateLocation me 
  tScreenLocs = getThread(#room).getInterface().getGeometry().getScreenCoordinate(pLocX, pLocY, pLocH)
  i = 0
  repeat while pSprList <= undefined
    tSpr = getAt(undefined, undefined)
    i = i + 1
    tSpr.locH = tScreenLocs.getAt(1)
    tSpr.locV = tScreenLocs.getAt(2)
    if tSpr.rotation = 180 then
      tSpr.locH = tSpr.locH + pXFactor
    end if
    if pDirection.getAt(1) < 0 then
      pDirection.setAt(1, 0)
    end if
    if pDirection.getAt(1) + 1 > pLocShiftList.getAt(i).count then
      pDirection.setAt(1, 0)
    end if
    tLocShift = pLocShiftList.getAt(i).getAt(pDirection.getAt(1) + 1)
    tSpr.loc = tSpr.loc + tLocShift
    tZ = pLoczList.getAt(i).getAt(pDirection.getAt(1) + 1)
    if pCorrectLocZ then
      tSpr.locZ = tScreenLocs.getAt(3) + (pLocH * 1000) + tZ - 1
    else
      tSpr.locZ = tScreenLocs.getAt(3) + tZ - 1
    end if
  end repeat
  me.relocate(pSprList)
end
