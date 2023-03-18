property pPartList, pImgMemberID, pTypeDef, pSprite, pLocZ, pWrapperStatus, pOffsets, pWrapID, pBoundingRect, pCapturesEvents, pSpriteProps, pOwnerID, pVisualizerLocZ

on construct me
  pPartList = []
  pWrapperStatus = [#rendered: 0, #rectOk: 0]
  pOffsets = [0, 0]
  pWrapID = "NoID"
  pBoundingRect = rect(0, 0, 0, 0)
  pCapturesEvents = 0
  pSpriteProps = [#blend: 100, #ink: 41, #bgColor: rgb(255, 255, 255)]
  pVisualizerLocZ = 0
  return 1
end

on deconstruct me
  pPartList = []
  if not voidp(pImgMemberID) then
    if memberExists(pImgMemberID) then
      removeMember(pImgMemberID)
    end if
  end if
  return 1
end

on define me, tProps
  if ilk(tProps) <> #propList then
    return error(me, "Not a proplist" && tProps, #define)
  end if
  if not voidp(tProps[#palette]) then
    pSpriteProps[#palette] = tProps[#palette]
  end if
  if not voidp(tProps[#id]) then
    pWrapID = tProps[#id]
  end if
  pTypeDef = tProps[#typeDef]
  pOffsets = [integer(tProps[#offsetx]), integer(tProps[#offsety])]
  pVisualizerLocZ = integer(tProps[#locZ])
  pImgMemberID = "VizWrap_" & pWrapID & "_" & me.getID()
  pWrapperStatus = [#rendered: 0, #rectOk: 0]
  return 1
end

on addPart me, tProps
  if ilk(tProps) <> #propList then
    return error(me, "Not a proplist" && tProps, #addPart)
  end if
  if not memberExists(tProps[#member]) then
    tpartNum = member(abs(getmemnum(tProps[#member])))
    if tpartNum > 0 then
      tPartMember = member(tpartNum)
    else
      return error(me, "No member found:" && tProps[#member], #addPart)
    end if
  else
    tPartMember = member(abs(getmemnum(tProps[#member])))
  end if
  tX1 = tProps[#locH] + pOffsets[1] - tPartMember.regPoint[1]
  tY1 = tProps[#locV] + pOffsets[2] - tPartMember.regPoint[2]
  tX2 = tX1 + tProps[#width]
  tY2 = tY1 + tProps[#height]
  tProps[#screenrect] = rect(tX1, tY1, tX2, tY2)
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tProps[#class] = tProps[#member].item[2]
  the itemDelimiter = tDelim
  if not voidp(tProps[#locZ]) then
    pLocZ = tProps[#locZ]
  end if
  if not voidp(tProps[#ink]) then
    pSpriteProps[#ink] = tProps[#ink]
  end if
  if not voidp(tProps[#blend]) then
    pSpriteProps[#blend] = tProps[#blend]
  end if
  if not voidp(tProps[#palette]) then
    pSpriteProps[#palette] = tProps[#palette]
  end if
  if pCapturesEvents = 0 then
    pCapturesEvents = tProps[#catchEvents]
  end if
  pPartList.append(tProps)
  pWrapperStatus = [#rendered: 0, #rectOk: 0]
  return 1
end

on removePart me, tPartId
  repeat with tPos = 1 to pPartList.count
    if pPartList[tPos][#id] = tPartId then
      pPartList.deleteAt(tPos)
      pWrapperStatus = [#rendered: 0, #rectOk: 0]
      exit repeat
    end if
  end repeat
  return me.updateWrap()
end

on setProperty me, tProp, tValue
  if voidp(tProp) or voidp(tValue) then
    return 0
  end if
  case tProp of
    #sprite:
      me.setSprite(integer(tValue))
    #owner:
      pOwnerID = tValue
    #locZ:
      pLocZ = integer(tValue)
    #visLocZ:
      pVisualizerLocZ = integer(tValue)
    #blend:
      pSpriteProps[#blend] = integer(tValue)
    #ink:
      pSpriteProps[#ink] = tValue
    #palette:
      pSpriteProps[#palette] = tValue
  end case
  return 1
end

on getProperty me, tProp
  case tProp of
    #locZ:
      return pLocZ + pVisualizerLocZ
    #sprite:
      return pSprite
    #type:
      return pTypeDef
    #id:
      return me.getID()
    #imagePntr:
      return me.getImagePointer()
    #Active:
      return pCapturesEvents
    #blend:
      return pSpriteProps[#blend]
  end case
  return 0
end

on fitRectToWall me, tRect, tSlope
  if not ((pTypeDef = #wallleft) or (pTypeDef = #wallright)) then
    return [#insideWall: 0]
  end if
  tB = me.getBounds()
  if (tB[1] > tRect[1]) or (tB[2] > tRect[2]) or (tB[3] < tRect[3]) or (tB[4] < tRect[4]) then
    return [#insideWall: 0]
  end if
  if pTypeDef = #wallleft then
    tHighestPoint = point(tRect[3], tRect[2])
    tLowestPoint = point(tRect[1], tRect[4])
    tSlope = tSlope * -1
    tdir = "leftwall"
  else
    tHighestPoint = point(tRect[1], tRect[2])
    tLowestPoint = point(tRect[3], tRect[4])
    tdir = "rightwall"
  end if
  repeat with tPart in pPartList
    if pTypeDef = #wallleft then
      tSlopeSpace = abs(tPart.width * tSlope)
    else
      tSlopeSpace = 0
    end if
    tPartScreenrect = tPart.screenrect
    if tHighestPoint.inside(tPartScreenrect) then
      tDistX = tHighestPoint[1] - tPartScreenrect[1]
      tDistY = tDistX * tSlope
      tSlopeYAtX = tPartScreenrect[2] + tSlopeSpace + tDistY
      if tSlopeYAtX < tHighestPoint[2] then
        tPartForHighest = tPart
        exit repeat
      end if
    end if
  end repeat
  if voidp(tPartForHighest) then
    return [#insideWall: 0]
  end if
  repeat with tPart in pPartList
    if pTypeDef = #wallleft then
      tSlopeSpace = 0
    else
      tSlopeSpace = abs(tPart.width * tSlope)
    end if
    tPartScreenrect = tPart.screenrect
    if tLowestPoint.inside(tPartScreenrect) then
      tDistX = tLowestPoint[1] - tPartScreenrect[1]
      tDistY = tDistX * tSlope
      tSlopeYAtX = tPartScreenrect[2] + tPart.height - tSlopeSpace + tDistY
      if tSlopeYAtX > tLowestPoint[2] then
        tPartForLowest = tPart
        exit repeat
      end if
    end if
  end repeat
  if voidp(tPartForLowest) then
    return [#insideWall: 0]
  end if
  if pTypeDef = #wallleft then
    tRePart = tPartForLowest
  else
    tRePart = tPartForHighest
  end if
  tPartScreenrect = tRePart.screenrect
  tReturnProps = [:]
  tReturnProps[#insideWall] = 1
  tReturnProps[#wallLocation] = point(tRePart.locX, tRePart.locY)
  tLocalX = tRect[1] - tPartScreenrect[1]
  tLocalY = tRect[2] - tPartScreenrect[2]
  tReturnProps[#localCoordinate] = point(tLocalX, tLocalY)
  tReturnProps[#direction] = tdir
  tReturnProps[#wallSprites] = [pSprite]
  return tReturnProps
end

on setPartPattern me, tPatternType, tPalette, tColor, tWrapType
  if tWrapType <> pTypeDef then
    return 0
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  repeat with tPart in pPartList
    tMem = tPart[#member]
    tClass = tMem.item[1] & "_" & tMem.item[2] & "_"
    ttype = tPatternType & "_"
    tLayer = tMem.item[4] & "_"
    tObs1 = tMem.item[5] & "_"
    tdir = tMem.item[6] & "_"
    tObs2 = tMem.item[7]
    tNewMemName = tClass & ttype & tLayer & tObs1 & tdir & tObs2
    if memberExists(tNewMemName) then
      tPart[#member] = tNewMemName
    end if
    pSpriteProps[#bgColor] = tColor
    pSpriteProps[#palette] = tPalette
  end repeat
  the itemDelimiter = tDelim
  pWrapperStatus[#rendered] = 0
  return me.updateWrap()
end

on updateWrap me
  if not pWrapperStatus[#rendered] then
    me.renderImage()
  end if
  if not pWrapperStatus[#rectOk] then
    me.updateBounds()
  end if
  return me.updateSprite()
end

on getPartAt me, tLocX, tLocY
  repeat with tPart in pPartList
    if (tPart[#locX] = tLocX) and (tPart[#locY] = tLocY) then
      tPartValues = [:]
      tPartValues[#member] = tPart[#member]
      tPartValues[#locH] = tPart[#locH] + pOffsets[1]
      tPartValues[#locV] = tPart[#locV] + pOffsets[2]
      tPartValues[#locZ] = pLocZ + pVisualizerLocZ
      return tPartValues
    end if
  end repeat
  return 0
end

on getBounds me
  if not pWrapperStatus[#rectOk] then
    me.updateBounds()
  end if
  return pBoundingRect + rect(pOffsets[1], pOffsets[2], pOffsets[1], pOffsets[2])
end

on getImagePointer me
  if not pWrapperStatus[#render] then
    me.renderImage()
  end if
  return pImgMemberID
end

on setSprite me, tSpr
  pSprite = sprite(integer(tSpr))
  return 1
end

on updateBounds me
  if pPartList.count = 0 then
    pBoundingRect = rect(0, 0, 0, 0)
    pWrapperStatus[#rectOk] = 1
    return 1
  end if
  tLocs = [#X1: [], #X2: [], #Y1: [], #Y2: []]
  repeat with tPart in pPartList
    tPartMem = member(abs(getmemnum(tPart[#member])))
    tX1 = tPart.locH - tPartMem.regPoint[1]
    tY1 = tPart.locV - tPartMem.regPoint[2]
    tLocs[#X1].append(tX1)
    tLocs[#Y1].append(tY1)
    tLocs[#X2].append(tX1 + tPart.width)
    tLocs[#Y2].append(tY1 + tPart.height)
  end repeat
  tMinX1 = min(tLocs[#X1])
  tMaxX2 = max(tLocs[#X2])
  tMinY1 = min(tLocs[#Y1])
  tMaxY2 = max(tLocs[#Y2])
  pBoundingRect = rect(tMinX1, tMinY1, tMaxX2, tMaxY2)
  pWrapperStatus[#rectOk] = 1
  return 1
end

on updateSprite me
  if voidp(pSprite) then
    return 0
  end if
  tMemNum = getmemnum(pImgMemberID)
  if tMemNum = 0 then
    return 0
  end if
  pSprite.member = member(tMemNum)
  pSprite.width = member(tMemNum).width
  pSprite.height = member(tMemNum).height
  pSprite.locZ = pLocZ + pVisualizerLocZ
  pSprite.bgColor = pSpriteProps[#bgColor]
  pSprite.ink = pSpriteProps[#ink]
  pSprite.blend = pSpriteProps[#blend]
  pSprite.loc = point(pOffsets[1], pOffsets[2])
  return 1
end

on renderImage me
  if getmemnum(pImgMemberID) < 1 then
    createMember(pImgMemberID, #bitmap)
  end if
  tImgMember = member(getmemnum(pImgMemberID))
  tStageWidth = the stageRight - the stageLeft
  tStageHeight = the stageBottom - the stageTop
  tTargetImage = image(tStageWidth, tStageHeight, 32)
  repeat with tPart in pPartList
    tPartMem = member(getmemnum(tPart[#member]))
    tPalette = pSpriteProps[#palette]
    if ilk(tPalette) = #symbol then
      tPartMem.paletteRef = tPalette
    else
      tPartMem.palette = member(getmemnum(tPalette))
    end if
    tPartRectX1 = tPart[#locH] - tPartMem.regPoint[1]
    tPartRectY1 = tPart[#locV] - tPartMem.regPoint[2]
    tPartRectX2 = tPartRectX1 + tPart[#width]
    tPartRectY2 = tPartRectY1 + tPart[#height]
    tSourceImage = tPartMem.image
    if tPart[#flipH] then
      tImage = image(tSourceImage.width, tSourceImage.height, tSourceImage.depth, tSourceImage.paletteRef)
      tQuad = [point(tSourceImage.width, 0), point(0, 0), point(0, tSourceImage.height), point(tSourceImage.width, tSourceImage.height)]
      tImage.copyPixels(tSourceImage, tQuad, tSourceImage.rect)
      tSourceImage = tImage
      tPartRectX1 = tPartRectX1 - tSourceImage.width
      tPartRectX2 = tPartRectX2 - tSourceImage.width
    end if
    if tPart[#multiflip] then
      tImage = image(tSourceImage.width, tSourceImage.height, tSourceImage.depth, tSourceImage.paletteRef)
      tQuad = [point(tSourceImage.width, 0), point(0, 0), point(0, tSourceImage.height), point(tSourceImage.width, tSourceImage.height)]
      tImage.copyPixels(tSourceImage, tQuad, tSourceImage.rect)
      tSourceImage = tImage
      tPartRectX1 = tPart[#locH] + tPart[#offsetx] - (tPartMem.regPoint[1] * -1) - tSourceImage.width
      tPartRectX2 = tPartRectX1 + tSourceImage.width
      tPartRectY1 = tPart[#locV] - tPartMem.regPoint[2]
      tPartRectY2 = tPartRectY1 + tSourceImage.height
    end if
    tPartRect = rect(tPartRectX1, tPartRectY1, tPartRectX2, tPartRectY2)
    tMatte = tSourceImage.createMatte()
    tBgColor = rgb(254, 254, 254)
    tTargetImage.copyPixels(tSourceImage, tPartRect, tSourceImage.rect, [#maskImage: tMatte, #ink: 41, #bgColor: tBgColor])
  end repeat
  tImgMember.image = tTargetImage
  tImgMember.regPoint = point(0, 0)
  pWrapperStatus[#rendered] = 1
  return 1
end
