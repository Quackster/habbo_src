property pClass, pObjectType, pLayerProps, pLoczList, pDirection, pLocShiftList, pPartColors, pDimensions, pAnimFrame

on construct me 
  pClass = ""
  pName = ""
  pCustom = ""
  pDirection = []
  pDimensions = []
  pPartColors = []
  pAnimFrame = 0
  pLayerProps = []
  pObjectType = ""
  return TRUE
end

on deconstruct me 
  pLayerProps = []
  return TRUE
end

on define me, tdata 
  pClass = tdata.getAt(#class)
  pName = tdata.getAt(#name)
  pCustom = tdata.getAt(#custom)
  pDirection = tdata.getAt(#direction)
  pDimensions = tdata.getAt(#dimensions)
  pObjectType = tdata.getAt(#objectType)
  if pClass contains "*" then
    pClass = pClass.getProp(#char, 1, (offset("*", pClass) - 1))
  end if
  if (pObjectType = "s") then
    me.solveColors(tdata.getAt(#colors))
    if (me.solveStuffMembers() = 0) then
      return FALSE
    end if
  else
    if (pObjectType = "i") then
      pPartColors = []
      if (me.solveItemMembers() = 0) then
        return FALSE
      end if
    end if
  end if
  return TRUE
end

on getPicture me, tImg 
  if pLayerProps.ilk <> #list then
    return(error(me, "Properties not found!!!", #getImage, #minor))
  end if
  if pLayerProps.count < 1 then
    return(error(me, "No Properties!!!", #getImage, #minor))
  end if
  tCanvas = image(300, 300, 24)
  tCanvas.fill(tCanvas.rect, rgb(255, 255, 255))
  tFlipFlag = 0
  if (pObjectType = "i") then
    tProps = pLayerProps.getAt(1)
    tMemNum = tProps.getAt(#member)
    tImage = member(tMemNum).image
    tCanvas = tImage.duplicate()
    tFlipItem = tProps.getAt(#flipH)
  else
    if (pObjectType = "s") then
      tTempLayerProps = [:]
      tTempLayerProps.sort()
      tTempLocShifts = [:]
      tTempLocShifts.sort()
      f = 1
      repeat while f <= pLayerProps.count
        tlocz = pLoczList.getAt(f).getAt((pDirection.getAt(1) + 1))
        tTempLayerProps.addProp(tlocz, pLayerProps.getAt(f))
        tTempLocShifts.addProp(tlocz, pLocShiftList.getAt(f).getAt((pDirection.getAt(1) + 1)))
        f = (1 + f)
      end repeat
      j = 1
      repeat while j <= tTempLayerProps.count
        tProps = tTempLayerProps.getAt(j)
        tMemNum = tProps.getAt(#member)
        tBlend = tProps.getAt(#blend)
        tColor = tProps.getAt(#bgColor)
        tInk = tProps.getAt(#ink)
        tImage = member(tMemNum).image
        tRegp = member(tMemNum).regPoint
        tX = (150 - tRegp.getAt(1))
        tY = (150 - tRegp.getAt(2))
        if (ilk(tTempLocShifts.getAt(j)) = #point) then
          tX = (tX + tTempLocShifts.getAt(j).locH)
          tY = (tY + tTempLocShifts.getAt(j).locV)
        else
          if (ilk(tTempLocShifts.getAt(j)) = #integer) then
            tX = (tX + tTempLocShifts.getAt(j))
            tX = (tX + tTempLocShifts.getAt(j))
          end if
        end if
        tRect = rect(tX, tY, (tX + tImage.width), (tY + tImage.height))
        if tProps.getAt(#flipH) then
          tFlipFlag = 1
        end if
        tMatte = tImage.createMatte()
        tCanvas.copyPixels(tImage, tRect, tImage.rect, [#maskImage:tMatte, #ink:tInk, #bgColor:tColor, #blend:tBlend])
        j = (1 + j)
      end repeat
    end if
  end if
  if voidp(tImg) then
    tImg = tCanvas
  else
    tdestrect = (tImg.rect - tCanvas.rect)
    tdestrect = rect((tdestrect.width / 2), (tdestrect.height / 2), (tCanvas.width + (tdestrect.width / 2)), ((tdestrect.height / 2) + tCanvas.height))
    tImg.copyPixels(tCanvas, tdestrect, tCanvas.rect, [#ink:36])
  end if
  if tFlipItem then
    tImg = me.flipImage(tImg)
  end if
  return(tImg.trimWhiteSpace())
end

on flipImage me, tImg_a 
  tPaletteRef = tImg_a.paletteRef
  if (tPaletteRef.ilk = #member) then
    tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth, member(tPaletteRef))
  else
    tImg_b = image(tImg_a.width, tImg_a.height, 32)
  end if
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return(tImg_b)
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
    i = (1 + i)
  end repeat
  j = pPartColors.count
  repeat while j <= 4
    pPartColors.add("*ffffff")
    j = (1 + j)
  end repeat
  the itemDelimiter = tDelim
end

on solveInk me, tPart 
  if not memberExists(pClass & ".props") then
    return(8)
  end if
  tPropList = value(field(0))
  if ilk(tPropList) <> #propList then
    error(me, pClass & ".props is not valid!", #solveInk, #minor)
    return(8)
  else
    if (tPropList.getAt(tPart) = void()) then
      return(8)
    end if
    if tPropList.getAt(tPart).getAt(#ink) <> void() then
      return(tPropList.getAt(tPart).getAt(#ink))
    end if
  end if
  return(8)
end

on solveBlend me, tPart 
  if not memberExists(pClass & ".props") then
    return(100)
  end if
  tPropList = value(field(0))
  if ilk(tPropList) <> #propList then
    error(me, pClass & ".props is not valid!", #solveBlend, #minor)
    return(100)
  else
    if (tPropList.getAt(tPart) = void()) then
      return(100)
    end if
    if tPropList.getAt(tPart).getAt(#blend) <> void() then
      return(tPropList.getAt(tPart).getAt(#blend))
    end if
  end if
  return(100)
end

on solveStuffMembers me 
  tMemNum = 1
  i = charToNum("a")
  j = 1
  pLayerProps = []
  pLoczList = []
  pLocShiftList = []
  repeat while tMemNum > 0
    tFound = 0
    repeat while (tFound = 0)
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
      if not tMemNum and (j = 1) then
        tFound = 0
        if listp(pDirection) then
          tdir = 1
          repeat while tdir <= pDirection.count
            pDirection.setAt(tdir, integer((pDirection.getAt(tdir) + 1)))
            tdir = (1 + tdir)
          end repeat
          if (pDirection.getAt(1) = 8) then
            error(me, "Couldn't define members:" && pClass, #solveMembers, #minor)
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
      pLoczList.add([])
      pLocShiftList.add([])
      tdir = 0
      repeat while tdir <= 7
        pLoczList.getLast().add((me.solveLocZ(numToChar(i), tdir) + i))
        pLocShiftList.getLast().add(me.solveLocShift(numToChar(i), tdir))
        tdir = (1 + tdir)
      end repeat
      if tMemNum < 1 then
        tMemNum = abs(tMemNum)
        tFlipH = 1
      else
        tFlipH = 0
      end if
      tProps = [:]
      tProps.setAt(#member, tMemNum)
      tProps.setAt(#width, member(tMemNum).width)
      tProps.setAt(#height, member(tMemNum).height)
      tProps.setAt(#ink, me.solveInk(numToChar(i)))
      tProps.setAt(#blend, me.solveBlend(numToChar(i)))
      tProps.setAt(#flipH, tFlipH)
      if j <= pPartColors.count then
        if (string(pPartColors.getAt(j)).getProp(#char, 1) = "#") then
          tProps.setAt(#bgColor, rgb(pPartColors.getAt(j)))
          tInk = 41
        else
          tProps.setAt(#bgColor, paletteIndex(integer(pPartColors.getAt(j))))
        end if
      end if
      pLayerProps.append(tProps)
    end if
    i = (i + 1)
    j = (j + 1)
  end repeat
  if pLayerProps.count > 0 then
    return TRUE
  else
    return(error(me, "Couldn't define members:" && pClass, #solveStuffMembers, #minor))
  end if
end

on solveItemMembers me 
  tMemNum = 0
  pLayerProps = []
  tMemName = "rightwall" && pClass
  tMemNum = getmemnum(tMemName)
  tProps = [:]
  tProps.setAt(#flipH, tMemNum < 0)
  tProps.setAt(#member, abs(tMemNum))
  if tMemNum <> 0 then
    pLayerProps.append(tProps)
  end if
  if pLayerProps.count > 0 then
    return TRUE
  else
    if not me.solveAnimatedItemMembers() then
      return(error(me, "Couldn't define members:" && pClass, #solveItemMembers, #minor))
    end if
  end if
end

on solveAnimatedItemMembers me 
  tMemNum = 1
  i = charToNum("a")
  j = 1
  pLayerProps = []
  pLoczList = []
  pLocShiftList = []
  repeat while tMemNum > 0
    tMemNameA = "rightwall" && pClass & "_" & numToChar(i) & "_"
    tFrame = 0
    repeat while tFrame <= 10
      tMemName = tMemNameA & string(tFrame)
      tMemNum = getmemnum(tMemName)
      tOldMemName = tMemName
      if tMemNum <> 0 then
      else
        tFrame = (1 + tFrame)
      end if
    end repeat
    if tMemNum <> 0 then
      pLoczList.add([])
      pLocShiftList.add([])
      tdir = 0
      repeat while tdir <= 7
        pLoczList.getLast().add((me.solveLocZ(numToChar(i), tdir) + i))
        pLocShiftList.getLast().add(me.solveLocShift(numToChar(i), tdir))
        tdir = (1 + tdir)
      end repeat
      if tMemNum < 1 then
        tMemNum = abs(tMemNum)
        tFlipH = 1
      else
        tFlipH = 0
      end if
      tProps = [:]
      tProps.setAt(#member, tMemNum)
      tProps.setAt(#width, member(tMemNum).width)
      tProps.setAt(#height, member(tMemNum).height)
      tProps.setAt(#ink, me.solveInk(numToChar(i)))
      tProps.setAt(#blend, me.solveBlend(numToChar(i)))
      tProps.setAt(#flipH, tFlipH)
      if j <= pPartColors.count then
        if (string(pPartColors.getAt(j)).getProp(#char, 1) = "#") then
          tProps.setAt(#bgColor, rgb(pPartColors.getAt(j)))
          tInk = 41
        else
          tProps.setAt(#bgColor, paletteIndex(integer(pPartColors.getAt(j))))
        end if
      end if
      pLayerProps.append(tProps)
    end if
    i = (i + 1)
    j = (j + 1)
  end repeat
  if pLayerProps.count > 0 then
    pObjectType = "s"
    return TRUE
  else
    return(error(me, "Couldn't define members:" && pClass, #solveAnimatedItemMembers, #minor))
  end if
end

on solveLocZ me, tPart, tdir 
  if not memberExists(pClass & ".props") then
    return(charToNum(tPart))
  end if
  tPropList = value(field(0))
  if ilk(tPropList) <> #propList then
    error(me, pClass & ".props is not valid!", #solveLocZ, #minor)
    return FALSE
  else
    if (tPropList.getAt(tPart) = void()) then
      return FALSE
    end if
    if (tPropList.getAt(tPart).getAt(#zshift) = void()) then
      return FALSE
    end if
    if tPropList.getAt(tPart).getAt(#zshift).count <= tdir then
      tdir = 0
    end if
  end if
  return(tPropList.getAt(tPart).getAt(#zshift).getAt((tdir + 1)))
end

on solveLocShift me, tPart, tdir 
  if not memberExists(pClass & ".props") then
    return FALSE
  end if
  tPropList = value(field(0))
  if ilk(tPropList) <> #propList then
    error(me, pClass & ".props is not valid!", #solveLocShift, #minor)
    return FALSE
  else
    if voidp(tPropList.getAt(tPart)) then
      return FALSE
    end if
    if voidp(tPropList.getAt(tPart).getAt(#locshift)) then
      return FALSE
    end if
    if tPropList.getAt(tPart).getAt(#locshift).count <= tdir then
      return FALSE
    end if
    tShift = value(tPropList.getAt(tPart).getAt(#locshift).getAt((tdir + 1)))
    if (ilk(tShift) = #point) then
      return(tShift)
    end if
  end if
  return FALSE
end
