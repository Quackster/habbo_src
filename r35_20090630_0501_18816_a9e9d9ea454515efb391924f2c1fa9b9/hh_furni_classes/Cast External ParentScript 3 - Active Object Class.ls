property pClass, pName, pCustom, pSprList, pDirection, pDimensions, pLoczList, pLocShiftList, pPartColors, pAnimFrame, pLocX, pLocY, pLocH, pAltitude, pXFactor, pCorrectLocZ, pSmallMember, pGeometry, pStartloc, pDestLoc, pSlideStartTime, pSlideEndTime, pSlideTimePerTile, pPersistentFurniData, pExpireTimeStamp

on construct me
  pClass = EMPTY
  pName = EMPTY
  pCustom = EMPTY
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
  pAltitude = 0.0
  pPersistentFurniData = VOID
  pXFactor = getThread(#room).getInterface().getGeometry().pXFactor
  tRoomStruct = getObject(#session).GET("lastroom")
  if not listp(tRoomStruct) then
    error(me, "Room struct not saved in #session!", #construct)
    ttype = #public
  else
    ttype = tRoomStruct.getaProp(#type)
  end if
  if ttype = #private then
    pCorrectLocZ = 1
  else
    pCorrectLocZ = 0
  end if
  pExpireTimeStamp = -1
  pSlideTimePerTile = 500
  return 1
end

on deconstruct me
  repeat with tSpr in pSprList
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
  pExpireTimeStamp = tdata[#expire]
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

on getInfo me
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  tInfo = [:]
  tInfo[#class] = pClass
  tFurniData = pPersistentFurniData.getPropsByClass("s", pClass)
  if not voidp(tFurniData) then
    tInfo[#name] = pPersistentFurniData.getPropsByClass("s", pClass)[#localizedName]
    tInfo[#custom] = pPersistentFurniData.getPropsByClass("s", pClass)[#localizedDesc]
  else
    if pClass contains "placeholder" then
      tInfo[#name] = getText("furni_active_placeholder_name")
      tInfo[#custom] = getText("furni_active_placeholder_desc")
    else
      tInfo[#name] = EMPTY
      tInfo[#custom] = EMPTY
    end if
  end if
  tInfo[#expire] = pExpireTimeStamp
  tInfo[#smallmember] = pSmallMember
  tInfo[#image] = getObject("Preview_renderer").renderPreviewImage(VOID, pPartColors, VOID, pClass)
  return tInfo
end

on getLocation me
  return [pLocX, pLocY, pLocH]
end

on getCustom me
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  tFurniData = pPersistentFurniData.getPropsByClass("s", pClass)
  if voidp(tFurniData) then
    tCustom = EMPTY
  else
    tCustom = tFurniData[#localizedDesc]
  end if
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
  tName = sprite(pSprList[1]).member.name
  tDirection = pDirection
  if voidp(tChange) then
    tChange = 2
  end if
  repeat with j = 0 to 3
    tDirection = (tDirection + tChange + j) mod 8
    if tDirection[1] < 0 then
      tDirection = 8 + tDirection
    end if
    tNameExploded = explode(tName, "_")
    if tNameExploded.count < 2 then
      tTryName = EMPTY
      exit repeat
    end if
    tNameExploded[tNameExploded.count - 1] = string(tDirection[1])
    tTryName = implode(tNameExploded, "_")
    if memberExists(tTryName) then
      exit repeat
      next repeat
    end if
    if not (tTryName contains pClass) then
      tDelim = the itemDelimiter
      the itemDelimiter = "_"
      tTryName2 = pClass
      if pXFactor = 32 then
        tTryName2 = "s_" & tTryName2
      end if
      repeat with i = tTryName.item.count - 5 to tTryName.item.count
        tTryName2 = tTryName2 & "_" & tTryName.item[i]
      end repeat
      the itemDelimiter = tDelim
      if memberExists(tTryName2) then
        tTryName = tTryName2
        exit repeat
      end if
    end if
  end repeat
  if not memberExists(tTryName) then
    return error(me, "Direction for object not found:" && pClass && tDirection[1], #rotate, #minor)
  end if
  getThread(#room).getComponent().getRoomConnection().send("MOVESTUFF", [#integer: integer(me.getID()), #integer: me.pLocX, #integer: me.pLocY, #integer: tDirection[1]])
end

on setSlideTo me, tFromLoc, tToLoc, tTimeNow, tHasCharacter
  if voidp(tTimeNow) then
    tTimeNow = the milliSeconds
  end if
  pSlideStartTime = tTimeNow
  pLastSlideUpdateTime = pSlideStartTime
  pLocX = getLocalFloat(tFromLoc[1])
  pLocY = getLocalFloat(tFromLoc[2])
  pLocH = getLocalFloat(tFromLoc[3])
  tDistances = []
  tDistances[1] = abs(tFromLoc[1] - tToLoc[1])
  tDistances[2] = abs(tFromLoc[2] - tToLoc[2])
  tDistances[3] = abs(tFromLoc[3] - tToLoc[3])
  tMoveTime = max(tDistances) * pSlideTimePerTile
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
    pLocX = pDestLoc[1].integer
    pLocY = pDestLoc[2].integer
    pLocH = pDestLoc[3]
    getThread("room").getComponent().removeSlideObject(me.ancestor.id)
    me.updateLocation()
    return 1
  end if
  tTimeUsed = float(tTimeNow - pSlideStartTime)
  tPercentSlided = tTimeUsed / float(pSlideEndTime - pSlideStartTime)
  pLocX = (float(pDestLoc[1] - pStartloc[1]) * tPercentSlided) + pStartloc[1]
  pLocY = (float(pDestLoc[2] - pStartloc[2]) * tPercentSlided) + pStartloc[2]
  pLocH = (float(pDestLoc[3] - pStartloc[3]) * tPercentSlided) + pStartloc[3]
  me.updateLocation()
  return 1
end

on ghostObject me
  repeat with tSpr in pSprList
    if tSpr.ink = 33 then
      tSpr.visible = 0
      next repeat
    end if
    tSpr.blend = 35
  end repeat
end

on removeGhostEffect me
  repeat with tSpr in pSprList
    tSpr.visible = 1
    tSpr.blend = 100
  end repeat
end

on getScreenLocation me
  if pSprList.count < 1 then
    return point(0, 0)
  end if
  tSpr = pSprList[1]
  tloc = point(tSpr.rect[1] + (tSpr.width / 2), tSpr.rect[2] + (tSpr.height / 2))
  return tloc
end

on prepare me, tdata
  return 1
end

on relocate me, tSpriteList
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
  if not memberExists(tClass & ".props") then
    return 8
  end if
  tPropList = value(field(getmemnum(tClass & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #solveInk, #minor)
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

on solveBlend me, tPart, tClass
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists(tClass & ".props") then
    return 100
  end if
  tPropList = value(field(getmemnum(tClass & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #solveBlend, #minor)
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

on capturesEvents me, tPart, tClass
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists(tClass & ".props") then
    return 1
  end if
  tPropList = value(field(getmemnum(tClass & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #capturesEvents, #minor)
    return 1
  else
    if voidp(tPropList[tPart]) then
      return 1
    end if
    if not voidp(tPropList[tPart][#events]) then
      return tPropList[tPart][#events]
    end if
  end if
  return 1
end

on solveLocZ me, tPart, tdir, tClass
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists(tClass & ".props") then
    return 0
  end if
  tPropList = value(field(getmemnum(tClass & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #solveLocZ, #minor)
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

on solveLocShift me, tPart, tdir, tClass
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists(tClass & ".props") then
    return 0
  end if
  tPropList = value(field(getmemnum(tClass & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #solveLocShift, #minor)
    return 0
  else
    if voidp(tPropList[tPart]) then
      return 0
    end if
    if voidp(tPropList[tPart][#locshift]) then
      return 0
    end if
    if tPropList[tPart][#locshift].count <= tdir then
      return 0
    end if
    tShift = value(tPropList[tPart][#locshift][tdir + 1])
    if ilk(tShift) = #point then
      return tShift
    end if
  end if
  return 0
end

on solveMembers me
  tClass = pClass
  if tClass contains "*" then
    tSmallMem = tClass & "_small"
    tClass = tClass.char[1..offset("*", tClass) - 1]
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
    repeat with tSpr in pSprList
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
        tMemNameA = tMemNameA & "_" & pDimensions[1] & "_" & pDimensions[2]
      end if
      if not voidp(pDirection) then
        if count(pDirection) >= j then
          tMemName = tMemNameA & "_" & pDirection[j] & "_" & pAnimFrame
        else
          tMemName = tMemNameA & "_" & pDirection[1] & "_" & pAnimFrame
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
      if not tMemNum and (j = 1) then
        tFound = 0
        if listp(pDirection) then
          repeat with tdir = 1 to pDirection.count
            pDirection[tdir] = integer(pDirection[tdir] + 1)
          end repeat
          if pDirection[1] = 8 then
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
        tSpr = pSprList[j]
      else
        tTargetID = getThread(#room).getInterface().getID()
        tSpr = sprite(reserveSprite(me.getID()))
        if tSpr = sprite(0) then
          tRoomThread = getThread(#room)
          if not voidp(tRoomThread) then
            tRoomThread.getComponent().releaseSpritesFromActiveObjects()
          end if
          return error(me, "Could not reserve sprite for: " && tClass, #solveMembers, #major)
        end if
        pSprList.add(tSpr)
        tCapturesEvents = me.capturesEvents(numToChar(i), tClass)
        if tCapturesEvents then
          setEventBroker(tSpr.spriteNum, me.getID())
          tSpr.registerProcedure(#eventProcActiveObj, tTargetID, #mouseDown)
          tSpr.registerProcedure(#eventProcActiveRollOver, tTargetID, #mouseEnter)
          tSpr.registerProcedure(#eventProcActiveRollOver, tTargetID, #mouseLeave)
        else
          removeEventBroker(tSpr.spriteNum)
        end if
      end if
      if pLoczList.count < pSprList.count then
        pLoczList.add([])
      end if
      if pLocShiftList.count < pSprList.count then
        pLocShiftList.add([])
      end if
      repeat with tdir = 0 to 7
        pLoczList.getLast().add(integer(me.solveLocZ(numToChar(i), tdir, tClass)) + tLoczAdjust)
        pLocShiftList.getLast().add(me.solveLocShift(numToChar(i), tdir, tClass))
      end repeat
      tLoczAdjust = tLoczAdjust + 1
      if not voidp(tSpr) and (tSpr <> sprite(0)) then
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
          if string(pPartColors[j]).char[1] = "#" then
            tSpr.bgColor = rgb(pPartColors[j])
          else
            tSpr.bgColor = paletteIndex(integer(pPartColors[j]))
          end if
        end if
      else
        return error(me, "Out of sprites!!!", #solveMembers, #major)
      end if
    end if
    i = i + 1
    j = j + 1
  end repeat
  tShadowName = tClass & "_sd"
  if listp(pDirection) then
    tShadowName = tShadowName & "_" & pDirection[1]
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
    return 0
  end if
  tID = me.getID()
  tRoomType = getObject(#session).GET("lastroom")[#type]
  if tRoomType <> #private then
    if tShadowNum <> 0 then
      tSpr = sprite(reserveSprite(tID))
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
      return 0
    end if
    tShadowManager.removeShadow(tID)
    if (tShadowNum <> 0) and (pLocH = integer(pLocH)) then
      tProps = [:]
      tScreenLocs = tRoomThread.getInterface().getGeometry().getScreenCoordinate(pLocX, pLocY, pLocH)
      tmember = member(tShadowNum)
      if tShadowNum < 0 then
        tShadowNum = abs(tShadowNum)
        tmember = member(tShadowNum)
        tProps[#multiflip] = 1
        tProps[#offsetx] = pXFactor
      end if
      tProps[#member] = member(tShadowNum).name
      tProps[#locH] = tScreenLocs[1]
      tProps[#locV] = tScreenLocs[2]
      tProps[#width] = tmember.width
      tProps[#height] = tmember.height
      tProps[#id] = tID
      tShadowManager.addShadow(tProps)
      tShadowManager.render()
    end if
  end if
  if pSprList.count > 0 then
    return 1
  else
    return error(me, "Couldn't define members:" && tClass, #solveMembers, #major)
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
    if pDirection[1] < 0 then
      pDirection[1] = 0
    end if
    if (pDirection[1] + 1) > pLocShiftList[i].count then
      pDirection[1] = 0
    end if
    tLocShift = pLocShiftList[i][pDirection[1] + 1]
    tSpr.loc = tSpr.loc + tLocShift
    tZ = pLoczList[i][pDirection[1] + 1]
    if pCorrectLocZ then
      tSpr.locZ = tScreenLocs[3] + (pLocH * 1000) + tZ - 1
      next repeat
    end if
    tSpr.locZ = tScreenLocs[3] + tZ - 1
  end repeat
  me.relocate(pSprList)
end
