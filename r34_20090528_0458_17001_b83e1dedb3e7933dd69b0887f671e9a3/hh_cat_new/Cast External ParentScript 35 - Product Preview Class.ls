property pClass, pName, pCustom, pLayerProps, pDirection, pDimensions, pPartColors, pAnimFrame, pObjectType, pLoczList, pLocShiftList

on construct me
  pClass = EMPTY
  pName = EMPTY
  pCustom = EMPTY
  pDirection = []
  pDimensions = []
  pPartColors = []
  pAnimFrame = 0
  pLayerProps = []
  pObjectType = EMPTY
  return 1
end

on deconstruct me
  pLayerProps = []
  return 1
end

on define me, tdata
  pClass = tdata[#class]
  pName = tdata[#name]
  pCustom = tdata[#custom]
  pDirection = tdata[#direction]
  pDimensions = tdata[#dimensions]
  pObjectType = tdata[#objectType]
  if pClass contains "*" then
    pClass = pClass.char[1..offset("*", pClass) - 1]
  end if
  case pObjectType of
    "s":
      me.solveColors(tdata[#colors])
      if me.solveStuffMembers() = 0 then
        return 0
      end if
    "i":
      pPartColors = []
      if me.solveItemMembers() = 0 then
        return 0
      end if
  end case
  return 1
end

on getPicture me, tImg
  if pLayerProps.ilk <> #list then
    return error(me, "Properties not found!!!", #getPicture, #minor)
  end if
  if pLayerProps.count < 1 then
    return error(me, "No Properties!!!", #getPicture, #minor)
  end if
  tCanvas = image(300, 400, 32)
  tCanvas.fill(tCanvas.rect, rgb(255, 255, 255))
  tFlipFlag = 0
  case pObjectType of
    "i":
      tProps = pLayerProps[1]
      tMemNum = tProps[#member]
      tImage = member(tMemNum).image
      tCanvas = tImage.duplicate()
      tFlipItem = tProps[#flipH]
    "s":
      tTempLayerProps = [:]
      tTempLayerProps.sort()
      tTempLocShifts = [:]
      tTempLocShifts.sort()
      repeat with f = 1 to pLayerProps.count
        tlocz = pLoczList[f][pDirection[1] + 1]
        tTempLayerProps.addProp(tlocz, pLayerProps[f])
        tTempLocShifts.addProp(tlocz, pLocShiftList[f][pDirection[1] + 1])
      end repeat
      repeat with j = 1 to tTempLayerProps.count
        tProps = tTempLayerProps[j]
        tMemNum = tProps[#member]
        tBlend = tProps[#blend]
        tColor = tProps[#bgColor]
        tInk = tProps[#ink]
        tImage = member(tMemNum).image
        tRegp = member(tMemNum).regPoint
        tY = (tCanvas.height / 2) - tRegp[2]
        if tProps[#flipH] then
          tImage = me.flipImage(tImage)
          tNewRegX = tImage.width - tRegp[1]
          tX = (tCanvas.width / 2) - tNewRegX + 64
          if ilk(tTempLocShifts[j]) = #point then
            tX = tX - tTempLocShifts[j].locH
            tY = tY + tTempLocShifts[j].locV
          else
            if ilk(tTempLocShifts[j]) = #integer then
              tX = tX - tTempLocShifts[j]
              tX = tX - tTempLocShifts[j]
            end if
          end if
        else
          tX = (tCanvas.width / 2) - tRegp[1]
          if ilk(tTempLocShifts[j]) = #point then
            tX = tX + tTempLocShifts[j].locH
            tY = tY + tTempLocShifts[j].locV
          else
            if ilk(tTempLocShifts[j]) = #integer then
              tX = tX + tTempLocShifts[j]
              tX = tX + tTempLocShifts[j]
            end if
          end if
        end if
        tRect = rect(tX, tY, tX + tImage.width, tY + tImage.height)
        if tProps[#flipH] then
          tFlipFlag = 1
        end if
        tMatte = tImage.createMatte()
        tCanvas.copyPixels(tImage, tRect, tImage.rect, [#maskImage: tMatte, #ink: tInk, #bgColor: tColor, #blend: tBlend])
      end repeat
  end case
  if voidp(tImg) then
    tImg = tCanvas
  else
    tdestrect = tImg.rect - tCanvas.rect
    tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, tCanvas.width + (tdestrect.width / 2), (tdestrect.height / 2) + tCanvas.height)
    tImg.copyPixels(tCanvas, tdestrect, tCanvas.rect, [#ink: 36])
  end if
  if tFlipItem then
    tImg = me.flipImage(tImg)
  end if
  return tImg.trimWhiteSpace()
end

on flipImage me, tImg_a
  tPaletteRef = tImg_a.paletteRef
  if tPaletteRef.ilk = #member then
    tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth, member(tPaletteRef))
  else
    tImg_b = image(tImg_a.width, tImg_a.height, 32)
  end if
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return tImg_b
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

on solveInk me, tPart
  if not memberExists(pClass & ".props") then
    return 8
  end if
  tPropList = value(field(getmemnum(pClass & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, pClass & ".props is not valid!", #solveInk, #minor)
    return 8
  else
    if tPropList[tPart] = VOID then
      return 8
    end if
    if tPropList[tPart][#ink] <> VOID then
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
    error(me, pClass & ".props is not valid!", #solveBlend, #minor)
    return 100
  else
    if tPropList[tPart] = VOID then
      return 100
    end if
    if tPropList[tPart][#blend] <> VOID then
      return tPropList[tPart][#blend]
    end if
  end if
  return 100
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
    repeat while tFound = 0
      tMemNameA = pClass & "_" & numToChar(i) & "_" & "0"
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
      repeat with tdir = 0 to 7
        pLoczList.getLast().add(me.solveLocZ(numToChar(i), tdir) + i)
        pLocShiftList.getLast().add(me.solveLocShift(numToChar(i), tdir))
      end repeat
      if tMemNum < 1 then
        tMemNum = abs(tMemNum)
        tFlipH = 1
      else
        tFlipH = 0
      end if
      tProps = [:]
      tProps[#member] = tMemNum
      tProps[#width] = member(tMemNum).width
      tProps[#height] = member(tMemNum).height
      tProps[#ink] = me.solveInk(numToChar(i))
      tProps[#blend] = me.solveBlend(numToChar(i))
      tProps[#flipH] = tFlipH
      if j <= pPartColors.count then
        if string(pPartColors[j]).char[1] = "#" then
          tProps[#bgColor] = rgb(pPartColors[j])
          tInk = 41
        else
          tProps[#bgColor] = paletteIndex(integer(pPartColors[j]))
        end if
      end if
      pLayerProps.append(tProps)
    end if
    i = i + 1
    j = j + 1
  end repeat
  if pLayerProps.count > 0 then
    return 1
  else
    return error(me, "Couldn't define members:" && pClass, #solveStuffMembers, #minor)
  end if
end

on solveItemMembers me
  tMemNum = 0
  pLayerProps = []
  tMemName = "rightwall" && pClass
  tMemNum = getmemnum(tMemName)
  tProps = [:]
  tProps[#flipH] = tMemNum < 0
  tProps[#member] = abs(tMemNum)
  if tMemNum <> 0 then
    pLayerProps.append(tProps)
  end if
  if pLayerProps.count > 0 then
    return 1
  else
    if not me.solveAnimatedItemMembers() then
      return error(me, "Couldn't define members:" && pClass, #solveItemMembers, #minor)
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
    repeat with tFrame = 0 to 10
      tMemName = tMemNameA & string(tFrame)
      tMemNum = getmemnum(tMemName)
      tOldMemName = tMemName
      if tMemNum <> 0 then
        exit repeat
      end if
    end repeat
    if tMemNum <> 0 then
      pLoczList.add([])
      pLocShiftList.add([])
      repeat with tdir = 0 to 7
        pLoczList.getLast().add(me.solveLocZ(numToChar(i), tdir) + i)
        pLocShiftList.getLast().add(me.solveLocShift(numToChar(i), tdir))
      end repeat
      if tMemNum < 1 then
        tMemNum = abs(tMemNum)
        tFlipH = 1
      else
        tFlipH = 0
      end if
      tProps = [:]
      tProps[#member] = tMemNum
      tProps[#width] = member(tMemNum).width
      tProps[#height] = member(tMemNum).height
      tProps[#ink] = me.solveInk(numToChar(i))
      tProps[#blend] = me.solveBlend(numToChar(i))
      tProps[#flipH] = tFlipH
      if j <= pPartColors.count then
        if string(pPartColors[j]).char[1] = "#" then
          tProps[#bgColor] = rgb(pPartColors[j])
          tInk = 41
        else
          tProps[#bgColor] = paletteIndex(integer(pPartColors[j]))
        end if
      end if
      pLayerProps.append(tProps)
    end if
    i = i + 1
    j = j + 1
  end repeat
  if pLayerProps.count > 0 then
    pObjectType = "s"
    return 1
  else
    return error(me, "Couldn't define members:" && pClass, #solveAnimatedItemMembers, #minor)
  end if
end

on solveLocZ me, tPart, tdir
  if not memberExists(pClass & ".props") then
    return charToNum(tPart)
  end if
  tPropList = value(field(getmemnum(pClass & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, pClass & ".props is not valid!", #solveLocZ, #minor)
    return 0
  else
    if tPropList[tPart] = VOID then
      return 0
    end if
    if tPropList[tPart][#zshift] = VOID then
      return 0
    end if
    if tPropList[tPart][#zshift].count <= tdir then
      tdir = 0
    end if
  end if
  return tPropList[tPart][#zshift][tdir + 1]
end

on solveLocShift me, tPart, tdir
  if not memberExists(pClass & ".props") then
    return 0
  end if
  tPropList = value(field(getmemnum(pClass & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, pClass & ".props is not valid!", #solveLocShift, #minor)
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
