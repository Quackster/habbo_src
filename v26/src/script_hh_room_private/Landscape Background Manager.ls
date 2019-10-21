on construct(me)
  pimage = image(1, 1, 32)
  pwidth = 720
  pheight = 400
  pTurnPoint = pwidth / 2
  pREquiresUpdate = 1
  if threadExists(#room) then
    pWideScreenOffset = getThread(#room).getInterface().getProperty(#widescreenoffset)
  end if
  pRandObj = me.getRandomizer()
  pRenderQueue = []
  return(1)
  exit
end

on deconstruct(me)
  pRandObj = void()
  removeUpdate(me.getID())
  pRenderQueue = []
  return(1)
  exit
end

on define(me, tdata, tWallDef, tLandscapeDef)
  pwidth = tdata.getAt(#width)
  pheight = tdata.getAt(#height)
  pBgID = tdata.getAt(#id)
  pRoomTypeID = tdata.getAt(#roomtypeid)
  pWallDef = tWallDef.getaProp(#struct)
  pWallHeight = tWallDef.getaProp(#max_piece_height)
  tFactorX = tWallDef.getaProp(#factorx)
  pGradientType = tdata.getaProp(#gradient)
  pLandscapeType = tdata.getaProp(#type)
  pLandscapeDef = tLandscapeDef
  if tFactorX = 64 then
    pScalePrefix = ""
  else
    pScalePrefix = "s_"
  end if
  if variableExists("landscape.def." & pRoomTypeID) then
    tRoomDef = getVariableValue("landscape.def." & pRoomTypeID)
    pTurnPoint = tRoomDef.getAt(#middle)
  end if
  tRoomObj = getObject(#room_component)
  if tRoomObj = 0 then
    return(0)
  end if
  tRoomData = tRoomObj.getRoomData()
  if tRoomData = 0 then
    return(0)
  end if
  pRoomId = tRoomData.getaProp(#flatId)
  pTurnPoint = pTurnPoint + tdata.getAt(#offset)
  if not me.renderLandscape() then
    me.renderDefaultLandscape()
  end if
  exit
end

on requiresUpdate(me)
  return(pREquiresUpdate)
  exit
end

on getImage(me)
  if me.requiresUpdate() then
    if pRenderQueue.count = 0 then
      pREquiresUpdate = 0
    end if
  end if
  return(pimage.duplicate())
  exit
end

on update(me)
  if pRenderQueue.count = 0 then
    removeUpdate(me.getID())
    return(1)
  end if
  tItem = pRenderQueue.getAt(1)
  pRenderQueue.deleteAt(1)
  me.renderPiece(tItem)
  exit
end

on renderPiece(me, tItem)
  pimage.copyPixels(tItem.getAt(1), tItem.getAt(2), tItem.getAt(3), tItem.getAt(4))
  me.renderWallRandomProps(tItem.getAt(5), tItem.getAt(6), tItem.getAt(7), tItem.getAt(8), tItem.getAt(9))
  pREquiresUpdate = 1
  exit
end

on renderLandscape(me)
  tMemNum = getmemnum(pScalePrefix & "lsd_bg_" & pGradientType)
  if tMemNum = 0 then
    return(0)
  end if
  tImageA = member(tMemNum).image
  tWidthA = tImageA.width
  tHeightA = tImageA.height
  tImageList = me.getImageListForTheme()
  if tImageList = 0 then
    return(0)
  end if
  tImageCount = tImageList.count
  if tImageCount = 0 then
    return(0)
  end if
  tPieceCount = pwidth / tImageList.getAt(1).width + 1
  tImageSpots = me.getRandomImageOffsets(tImageCount, tPieceCount)
  tImageSpotCounter = 1
  tPalette = member(tMemNum).paletteRef
  pimage = image(pwidth, pheight, 32)
  if not listp(pWallDef) then
    return(0)
  end if
  if pWallDef.count < 1 then
    return(0)
  end if
  tside = #left
  tSideLeft = void()
  tSideRight = void()
  tFirstBottom = void()
  tFirstLeft = void()
  tItem = pWallDef.getAt(1)
  tWallDefIndex = 1
  repeat while tItem <> 0
    if tWallDefIndex > pWallDef.count then
    else
      tItem = pWallDef.getAt(tWallDefIndex)
      tMemName = tItem.getaProp(#member)
      tmember = member(getmemnum(tMemName))
      if tMemName contains "right" then
        tPieceSide = #right
      else
        tPieceSide = #left
      end if
      if tPieceSide = tside then
        tLocH = tmember - regPoint.locH + pWideScreenOffset
        tLocV = tmember - regPoint.locV
        if voidp(tSideLeft) or not voidp(tSideLeft) and tLocH < tSideLeft then
          tSideLeft = tLocH
          if tFirstLeft = void() or tFirstLeft > tSideLeft then
            tFirstLeft = tSideLeft
          end if
          tFirstBottom = tLocV + pWallHeight
          if tside = #right then
            tRightWallElemBottomOffset = -tItem.getaProp(#width) / 2
          end if
        end if
        tPieceRight = tLocH + tItem.getaProp(#width)
        if tSideRight < tPieceRight then
          tSideRight = tPieceRight
        end if
        tWallDefIndex = tWallDefIndex + 1
      end if
      if tPieceSide <> tside or tWallDefIndex > pWallDef.count then
        tX = tSideLeft
        tBottomY = tFirstBottom
        tSideRight = tSideRight
        repeat while tX < tSideRight
          if tX + tWidthA > tSideRight then
            tPieceWidth = tSideRight - tX
          else
            tPieceWidth = tWidthA
          end if
          tPieceHeight = tHeightA
          if tside = #right then
            tY = tBottomY - tHeightA + tRightWallElemBottomOffset + tWidthA / 2
            tQuad = [point(tX + tPieceWidth, tY), point(tX, tY), point(tX, tY + tPieceHeight), point(tX + tPieceWidth, tY + tPieceHeight)]
            tSourceRect = rect(tWidthA - tPieceWidth, 0, tWidthA, tHeightA)
            tBottomY = tBottomY + tPieceWidth / 2
          else
            tY = tBottomY - tHeightA
            tQuad = [point(tX, tY), point(tX + tPieceWidth, tY), point(tX + tPieceWidth, tY + tPieceHeight), point(tX, tY + tPieceHeight)]
            tSourceRect = rect(0, 0, tPieceWidth, tHeightA)
            tBottomY = tBottomY - tPieceWidth / 2
          end if
          pimage.copyPixels(tImageA, tQuad, tSourceRect, [#palette:tPalette])
          tX = tX + tPieceWidth
        end repeat
        tX = tSideLeft
        tBottomY = tFirstBottom
        repeat while tX < tSideRight
          tImage = tImageList.getAt(tImageSpots.getAt(tImageSpotCounter))
          tImageSpotCounter = tImageSpotCounter + 1
          if tImageSpotCounter > tImageSpots.count then
            tImageSpotCounter = 1
          end if
          tImageWidth = tImage.width
          tImageHeight = tImage.height
          if tX + tImageWidth > tSideRight then
            tPieceWidth = tSideRight - tX
          else
            tPieceWidth = tImageWidth
          end if
          tPieceHeight = tImageHeight
          if tside = #right then
            tY = tBottomY - tImageHeight + tRightWallElemBottomOffset + tImageWidth / 2
            tQuad = [point(tX + tPieceWidth, tY), point(tX, tY), point(tX, tY + tPieceHeight), point(tX + tPieceWidth, tY + tPieceHeight)]
            tSourceRect = rect(tImageWidth - tPieceWidth, 0, tImageWidth - 0, tImageHeight)
            tBottomY = tBottomY + tPieceWidth / 2
          else
            tY = tBottomY - tImageHeight
            tQuad = [point(tX, tY), point(tX + tPieceWidth, tY), point(tX + tPieceWidth, tY + tPieceHeight), point(tX, tY + tPieceHeight)]
            tSourceRect = rect(0, 0, tPieceWidth, tImageHeight)
            tBottomY = tBottomY - tPieceWidth / 2
          end if
          tWallRandomPropList = me.getRandomPropList(tImageSpots.getAt(tImageSpotCounter))
          tQueueItem = [tImage, tQuad, tSourceRect, [#ink:36], tside, tX, tY, tX + tPieceWidth, tWallRandomPropList]
          pRenderQueue.append(tQueueItem)
          tX = tX + tPieceWidth
        end repeat
        tSideLeft = void()
        tside = tPieceSide
        tFirstBottom = void()
        tSideRight = void()
      end if
    end if
  end repeat
  if pRenderQueue.count > 0 then
    receiveUpdate(me.getID())
  end if
  return(pimage.duplicate())
  exit
end

on renderWallRandomProps(me, tside, tOrigX, tOrigY, tSideRight, tWallRandomPropList)
  i = 1
  repeat while i <= tWallRandomPropList.count
    tImage = tWallRandomPropList.getAt(i)
    tpoint = tWallRandomPropList.getPropAt(i)
    tImageWidth = tImage.width
    tImageHeight = tImage.height
    if tside = #right then
      tX = tSideRight - tpoint.locH
      tY = tOrigY + tpoint.locV
    else
      tX = tOrigX + tpoint.locH
      tY = tOrigY + tpoint.locV
    end if
    if tX <= tSideRight and tX >= tOrigX then
      if tX + tImageWidth > tSideRight then
        tPieceWidth = tSideRight - tX
      else
        tPieceWidth = tImageWidth
      end if
      tPieceHeight = tImageHeight
      if tside = #right then
        tQuad = [point(tX + tPieceWidth, tY), point(tX, tY), point(tX, tY + tPieceHeight), point(tX + tPieceWidth, tY + tPieceHeight)]
        tSourceRect = rect(tImageWidth - tPieceWidth, 0, tImageWidth, tImageHeight)
      else
        tQuad = [point(tX, tY), point(tX + tPieceWidth, tY), point(tX + tPieceWidth, tY + tPieceHeight), point(tX, tY + tPieceHeight)]
        tSourceRect = rect(0, 0, tPieceWidth, tImageHeight)
      end if
      pimage.copyPixels(tImage, tQuad, tSourceRect, [#ink:36])
    end if
    i = 1 + i
  end repeat
  exit
end

on renderDefaultLandscape(me)
  pimage = image(pwidth, pheight, 32)
  pimage.fill(0, 0, pTurnPoint, pheight, color(110, 173, 200))
  pimage.fill(pTurnPoint, 0, pwidth, pheight, color(132, 206, 239))
  return(pimage.duplicate())
  exit
end

on getImageListForTheme(me)
  tImageList = []
  tMemNum = getmemnum(pScalePrefix & "lsd_" & pLandscapeType & "_1")
  if tMemNum = 0 then
    return(0)
  end if
  tNum = 1
  repeat while tMemNum > 0
    tImageList.append(member(tMemNum).image)
    tNum = tNum + 1
    tMemNum = getmemnum(pScalePrefix & "lsd_" & pLandscapeType & "_" & tNum)
  end repeat
  return(tImageList)
  exit
end

on getRandomImageOffsets(me, tImageCount, tResultCount)
  tMaxList = []
  i = 1
  repeat while i <= tImageCount
    tDef = pLandscapeDef.getaProp(string(i))
    if tDef <> 0 then
      tMaxList.setaProp(string(i), tDef.getaProp(#maximum))
    else
      tMaxList.setaProp(string(i), -1)
    end if
    i = 1 + i
  end repeat
  tRandObj = me.getRandomizer()
  if tRandObj = 0 then
    return(0)
  end if
  if tImageCount > 1 then
    tImageSpots = tRandObj.getArrayWithCountLimits(tResultCount, 1, tImageCount, tMaxList)
  else
    tImageSpots = tRandObj.getArray(tResultCount, 1, 1)
  end if
  return(tImageSpots)
  exit
end

on getPropListForTheme(me)
  tImageList = []
  tMemNum = getmemnum(pScalePrefix & "lsd_" & pLandscapeType & "_item_1")
  tNum = 1
  repeat while tMemNum > 0
    tImageList.append(member(tMemNum).image)
    tNum = tNum + 1
    tMemNum = getmemnum(pScalePrefix & "lsd_" & pLandscapeType & "_item_" & tNum)
  end repeat
  return(tImageList)
  exit
end

on getRandomPropList(me, tMemberId)
  tPropList = pLandscapeDef.getaProp(tMemberId)
  if tPropList = 0 then
    return([])
  end if
  tImageList = me.getPropListForTheme()
  tMaxCount = tPropList.getaProp(#max_props)
  tOffsetList = tPropList.getaProp(#offsets)
  if tMaxCount > tOffsetList.count then
    tMaxCount = tOffsetList.count
  end if
  if pRandObj = 0 then
    return(0)
  end if
  tImageTypes = pRandObj.getArray(tMaxCount, 0, tImageList.count)
  tImageSpots = pRandObj.getArray(tMaxCount, 1, tOffsetList.count)
  tResult = []
  i = 1
  repeat while i <= tImageTypes.count
    if tImageTypes.getAt(i) > 0 then
      tResult.setaProp(tOffsetList.getAt(tImageSpots.getAt(i)), tImageList.getAt(tImageTypes.getAt(i)))
    end if
    i = 1 + i
  end repeat
  return(tResult)
  exit
end

on getRandomizer(me)
  tRandObj = createObject(#temp, "Pseudorandom Number Generator Class")
  if tRandObj = 0 then
    return(0)
  end if
  tRandObj.setSeed(integer(pRoomId))
  return(tRandObj)
  exit
end