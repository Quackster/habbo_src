property pImgMemberID, pSpriteProps, pWrapID, pOffsets, pCapturesEvents, pPartList, pLocZ, pVisualizerLocZ, pSprite, pTypeDef, pWrapperStatus, pBoundingRect, pBgColor

on construct me 
  pPartList = []
  pWrapperStatus = [#rendered:0, #rectOk:0]
  pOffsets = [0, 0]
  pWrapID = "NoID"
  pBoundingRect = rect(0, 0, 0, 0)
  pCapturesEvents = 0
  pSpriteProps = [#blend:100, #ink:41, #bgColor:rgb(255, 255, 255)]
  pVisualizerLocZ = 0
  pBgColor = rgb(254, 254, 254)
  return TRUE
end

on deconstruct me 
  pPartList = []
  if not voidp(pImgMemberID) then
    if memberExists(pImgMemberID) then
      removeMember(pImgMemberID)
    end if
  end if
  return TRUE
end

on define me, tProps 
  if ilk(tProps) <> #propList then
    return(error(me, "Not a proplist" && tProps, #define, #major))
  end if
  if not voidp(tProps.getAt(#palette)) then
    pSpriteProps.setAt(#palette, tProps.getAt(#palette))
  end if
  if not voidp(tProps.getAt(#id)) then
    pWrapID = tProps.getAt(#id)
  end if
  pTypeDef = tProps.getAt(#typeDef)
  pOffsets = [integer(tProps.getAt(#offsetx)), integer(tProps.getAt(#offsety))]
  pVisualizerLocZ = integer(tProps.getAt(#locZ))
  pImgMemberID = "VizWrap_" & pWrapID & "_" & me.getID()
  pWrapperStatus = [#rendered:0, #rectOk:0]
  return TRUE
end

on addPart me, tProps 
  if ilk(tProps) <> #propList then
    return(error(me, "Not a proplist" && tProps, #addPart, #major))
  end if
  if not memberExists(tProps.getAt(#member)) then
    tpartNum = member(abs(getmemnum(tProps.getAt(#member))))
    if tpartNum > 0 then
      tPartMember = member(tpartNum)
    else
      return(error(me, "No member found:" && tProps.getAt(#member), #addPart, #major))
    end if
  else
    tPartMember = member(abs(getmemnum(tProps.getAt(#member))))
  end if
  tX1 = ((tProps.getAt(#locH) + pOffsets.getAt(1)) - tPartMember.getProp(#regPoint, 1))
  tY1 = ((tProps.getAt(#locV) + pOffsets.getAt(2)) - tPartMember.getProp(#regPoint, 2))
  tX2 = (tX1 + tProps.getAt(#width))
  tY2 = (tY1 + tProps.getAt(#height))
  tProps.setAt(#screenrect, rect(tX1, tY1, tX2, tY2))
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tProps.setAt(#class, tProps.getAt(#member).getProp(#item, 2))
  the itemDelimiter = tDelim
  if not voidp(tProps.getAt(#locZ)) then
    pLocZ = tProps.getAt(#locZ)
  end if
  if not voidp(tProps.getAt(#ink)) then
    pSpriteProps.setAt(#ink, tProps.getAt(#ink))
  end if
  if not voidp(tProps.getAt(#blend)) then
    pSpriteProps.setAt(#blend, tProps.getAt(#blend))
  end if
  if not voidp(tProps.getAt(#palette)) then
    pSpriteProps.setAt(#palette, tProps.getAt(#palette))
  end if
  if (pCapturesEvents = 0) then
    pCapturesEvents = tProps.getAt(#catchEvents)
  end if
  pPartList.append(tProps)
  pWrapperStatus = [#rendered:0, #rectOk:0]
  return TRUE
end

on removePart me, tPartId 
  tPos = 1
  repeat while tPos <= pPartList.count
    if (pPartList.getAt(tPos).getAt(#id) = tPartId) then
      pPartList.deleteAt(tPos)
      pWrapperStatus = [#rendered:0, #rectOk:0]
    else
      tPos = (1 + tPos)
    end if
  end repeat
  return(me.updateWrap())
end

on setProperty me, tProp, tValue 
  if voidp(tProp) or voidp(tValue) then
    return FALSE
  end if
  if (tProp = #sprite) then
    me.setSprite(integer(tValue))
  else
    if (tProp = #owner) then
      pOwnerID = tValue
    else
      if (tProp = #locZ) then
        pLocZ = integer(tValue)
      else
        if (tProp = #visLocZ) then
          pVisualizerLocZ = integer(tValue)
        else
          if (tProp = #blend) then
            pSpriteProps.setAt(#blend, integer(tValue))
          else
            if (tProp = #ink) then
              pSpriteProps.setAt(#ink, tValue)
            else
              if (tProp = #palette) then
                pSpriteProps.setAt(#palette, tValue)
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return TRUE
end

on getProperty me, tProp 
  if (tProp = #locZ) then
    return((pLocZ + pVisualizerLocZ))
  else
    if (tProp = #sprite) then
      return(pSprite)
    else
      if (tProp = #type) then
        return(pTypeDef)
      else
        if (tProp = #id) then
          return(me.getID())
        else
          if (tProp = #imagePntr) then
            return(me.getImagePointer())
          else
            if (tProp = #Active) then
              return(pCapturesEvents)
            else
              if (tProp = #blend) then
                return(pSpriteProps.getAt(#blend))
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return FALSE
end

on fitRectToWall me, tRect, tSlope 
  if not (pTypeDef = #wallleft) or (pTypeDef = #wallright) then
    return([#insideWall:0])
  end if
  tB = me.getBounds()
  if tB.getAt(1) > tRect.getAt(1) or tB.getAt(2) > tRect.getAt(2) or tB.getAt(3) < tRect.getAt(3) or tB.getAt(4) < tRect.getAt(4) then
    return([#insideWall:0])
  end if
  if (pTypeDef = #wallleft) then
    tHighestPoint = point(tRect.getAt(3), tRect.getAt(2))
    tLowestPoint = point(tRect.getAt(1), tRect.getAt(4))
    tSlope = (tSlope * -1)
    tdir = "leftwall"
  else
    tHighestPoint = point(tRect.getAt(1), tRect.getAt(2))
    tLowestPoint = point(tRect.getAt(3), tRect.getAt(4))
    tdir = "rightwall"
  end if
  repeat while pPartList <= tSlope
    tPart = getAt(tSlope, tRect)
    if (pTypeDef = #wallleft) then
      tSlopeSpace = abs((tPart.width * tSlope))
    else
      tSlopeSpace = 0
    end if
    tPartScreenrect = tPart.screenrect
    if tHighestPoint.inside(tPartScreenrect) then
      tDistX = (tHighestPoint.getAt(1) - tPartScreenrect.getAt(1))
      tDistY = (tDistX * tSlope)
      tSlopeYAtX = ((tPartScreenrect.getAt(2) + tSlopeSpace) + tDistY)
      if tSlopeYAtX < tHighestPoint.getAt(2) then
        tPartForHighest = tPart
      else
      end if
      if voidp(tPartForHighest) then
        return([#insideWall:0])
      end if
      repeat while pPartList <= tSlope
        tPart = getAt(tSlope, tRect)
        if (pTypeDef = #wallleft) then
          tSlopeSpace = 0
        else
          tSlopeSpace = abs((tPart.width * tSlope))
        end if
        tPartScreenrect = tPart.screenrect
        if tLowestPoint.inside(tPartScreenrect) then
          tDistX = (tLowestPoint.getAt(1) - tPartScreenrect.getAt(1))
          tDistY = (tDistX * tSlope)
          tSlopeYAtX = (((tPartScreenrect.getAt(2) + tPart.height) - tSlopeSpace) + tDistY)
          if tSlopeYAtX > tLowestPoint.getAt(2) then
            tPartForLowest = tPart
          else
          end if
          if voidp(tPartForLowest) then
            return([#insideWall:0])
          end if
          if (pTypeDef = #wallleft) then
            tRePart = tPartForLowest
          else
            tRePart = tPartForHighest
          end if
          tPartScreenrect = tRePart.screenrect
          tReturnProps = [:]
          tReturnProps.setAt(#insideWall, 1)
          tReturnProps.setAt(#wallLocation, point(tRePart.locX, tRePart.locY))
          tLocalX = (tRect.getAt(1) - tPartScreenrect.getAt(1))
          tLocalY = (tRect.getAt(2) - tPartScreenrect.getAt(2))
          tReturnProps.setAt(#localCoordinate, point(tLocalX, tLocalY))
          tReturnProps.setAt(#direction, tdir)
          tReturnProps.setAt(#wallSprites, [pSprite])
          return(tReturnProps)
        end if
      end repeat
    end if
  end repeat
end

on setPartPattern me, tPatternType, tPalette, tColor, tWrapType 
  if tWrapType <> pTypeDef then
    return FALSE
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  repeat while pPartList <= tPalette
    tPart = getAt(tPalette, tPatternType)
    tMem = tPart.getAt(#member)
    tClass = tMem.getProp(#item, 1) & "_" & tMem.getProp(#item, 2) & "_"
    ttype = tPatternType & "_"
    tLayer = tMem.getProp(#item, 4) & "_"
    tObs1 = tMem.getProp(#item, 5) & "_"
    tdir = tMem.getProp(#item, 6) & "_"
    tObs2 = tMem.getProp(#item, 7)
    tNewMemName = tClass & ttype & tLayer & tObs1 & tdir & tObs2
    if memberExists(tNewMemName) then
      tPart.setAt(#member, tNewMemName)
    end if
    pSpriteProps.setAt(#bgColor, tColor)
    pSpriteProps.setAt(#palette, tPalette)
  end repeat
  the itemDelimiter = tDelim
  pWrapperStatus.setAt(#rendered, 0)
  return(me.updateWrap())
end

on updateWrap me 
  if not pWrapperStatus.getAt(#rendered) then
    me.renderImage()
  end if
  if not pWrapperStatus.getAt(#rectOk) then
    me.updateBounds()
  end if
  return(me.updateSprite())
end

on getPartAt me, tLocX, tLocY 
  repeat while pPartList <= tLocY
    tPart = getAt(tLocY, tLocX)
    if (tPart.getAt(#locX) = tLocX) and (tPart.getAt(#locY) = tLocY) then
      tPartValues = [:]
      tPartValues.setAt(#member, tPart.getAt(#member))
      tPartValues.setAt(#locH, (tPart.getAt(#locH) + pOffsets.getAt(1)))
      tPartValues.setAt(#locV, (tPart.getAt(#locV) + pOffsets.getAt(2)))
      tPartValues.setAt(#locZ, (pLocZ + pVisualizerLocZ))
      return(tPartValues)
    end if
  end repeat
  return FALSE
end

on getBounds me 
  if not pWrapperStatus.getAt(#rectOk) then
    me.updateBounds()
  end if
  return((pBoundingRect + rect(pOffsets.getAt(1), pOffsets.getAt(2), pOffsets.getAt(1), pOffsets.getAt(2))))
end

on renderWithColor me, tColor 
  if (ilk(tColor) = #color) then
    pBgColor = tColor
    me.renderImage()
  end if
end

on getImagePointer me 
  if not pWrapperStatus.getAt(#render) then
    me.renderImage()
  end if
  return(pImgMemberID)
end

on setSprite me, tSpr 
  pSprite = sprite(integer(tSpr))
  return TRUE
end

on updateBounds me 
  if (pPartList.count = 0) then
    pBoundingRect = rect(0, 0, 0, 0)
    pWrapperStatus.setAt(#rectOk, 1)
    return TRUE
  end if
  tLocs = [#X1:[], #X2:[], #Y1:[], #Y2:[]]
  repeat while pPartList <= undefined
    tPart = getAt(undefined, undefined)
    tPartMem = member(abs(getmemnum(tPart.getAt(#member))))
    tX1 = (tPart.locH - tPartMem.getProp(#regPoint, 1))
    tY1 = (tPart.locV - tPartMem.getProp(#regPoint, 2))
    tLocs.getAt(#X1).append(tX1)
    tLocs.getAt(#Y1).append(tY1)
    tLocs.getAt(#X2).append((tX1 + tPart.width))
    tLocs.getAt(#Y2).append((tY1 + tPart.height))
  end repeat
  tMinX1 = min(tLocs.getAt(#X1))
  tMaxX2 = max(tLocs.getAt(#X2))
  tMinY1 = min(tLocs.getAt(#Y1))
  tMaxY2 = max(tLocs.getAt(#Y2))
  pBoundingRect = rect(tMinX1, tMinY1, tMaxX2, tMaxY2)
  pWrapperStatus.setAt(#rectOk, 1)
  return TRUE
end

on updateSprite me 
  if voidp(pSprite) then
    return FALSE
  end if
  tMemNum = getmemnum(pImgMemberID)
  if (tMemNum = 0) then
    return FALSE
  end if
  pSprite.member = member(tMemNum)
  pSprite.width = member(tMemNum).width
  pSprite.height = member(tMemNum).height
  pSprite.locZ = (pLocZ + pVisualizerLocZ)
  pSprite.bgColor = pSpriteProps.getAt(#bgColor)
  pSprite.ink = pSpriteProps.getAt(#ink)
  pSprite.blend = pSpriteProps.getAt(#blend)
  pSprite.loc = point(pOffsets.getAt(1), pOffsets.getAt(2))
  return TRUE
end

on renderImage me 
  if getmemnum(pImgMemberID) < 1 then
    createMember(pImgMemberID, #bitmap)
  end if
  tImgMember = member(getmemnum(pImgMemberID))
  tStageWidth = (the stageRight - the stageLeft)
  tStageHeight = (the stageBottom - the stageTop)
  tTargetImage = image(tStageWidth, tStageHeight, 32)
  repeat while pPartList <= undefined
    tPart = getAt(undefined, undefined)
    tPartMem = member(getmemnum(tPart.getAt(#member)))
    tPalette = pSpriteProps.getAt(#palette)
    if (ilk(tPalette) = #symbol) then
      tPartMem.paletteRef = tPalette
    else
      tPartMem.palette = member(getmemnum(tPalette))
    end if
    tPartRectX1 = (tPart.getAt(#locH) - tPartMem.getProp(#regPoint, 1))
    tPartRectY1 = (tPart.getAt(#locV) - tPartMem.getProp(#regPoint, 2))
    tPartRectX2 = (tPartRectX1 + tPart.getAt(#width))
    tPartRectY2 = (tPartRectY1 + tPart.getAt(#height))
    tSourceImage = tPartMem.image
    if tPart.getAt(#flipH) then
      tImage = image(tSourceImage.width, tSourceImage.height, tSourceImage.depth, tSourceImage.paletteRef)
      tQuad = [point(tSourceImage.width, 0), point(0, 0), point(0, tSourceImage.height), point(tSourceImage.width, tSourceImage.height)]
      tImage.copyPixels(tSourceImage, tQuad, tSourceImage.rect)
      tSourceImage = tImage
      tPartRectX1 = (tPartRectX1 - tSourceImage.width)
      tPartRectX2 = (tPartRectX2 - tSourceImage.width)
    end if
    if tPart.getAt(#multiflip) then
      tImage = image(tSourceImage.width, tSourceImage.height, tSourceImage.depth, tSourceImage.paletteRef)
      tQuad = [point(tSourceImage.width, 0), point(0, 0), point(0, tSourceImage.height), point(tSourceImage.width, tSourceImage.height)]
      tImage.copyPixels(tSourceImage, tQuad, tSourceImage.rect)
      tSourceImage = tImage
      tPartRectX1 = (((tPart.getAt(#locH) + tPart.getAt(#offsetx)) - (tPartMem.getProp(#regPoint, 1) * -1)) - tSourceImage.width)
      tPartRectX2 = (tPartRectX1 + tSourceImage.width)
      tPartRectY1 = (tPart.getAt(#locV) - tPartMem.getProp(#regPoint, 2))
      tPartRectY2 = (tPartRectY1 + tSourceImage.height)
    end if
    tPartRect = rect(tPartRectX1, tPartRectY1, tPartRectX2, tPartRectY2)
    tMatte = tSourceImage.createMatte()
    tBgColor = pBgColor
    tTargetImage.copyPixels(tSourceImage, tPartRect, tSourceImage.rect, [#maskImage:tMatte, #ink:41, #bgColor:tBgColor])
  end repeat
  tImgMember.image = tTargetImage
  tImgMember.regPoint = point(0, 0)
  pWrapperStatus.setAt(#rendered, 1)
  return TRUE
end

on handlers  
  return([])
end
