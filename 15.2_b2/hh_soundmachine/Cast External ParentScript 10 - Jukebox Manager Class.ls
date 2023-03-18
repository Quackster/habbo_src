property pOwner, pConnectionId, pDiskList, pSelectedDisk, pSelectedEject, pDiskListRenderList, pDiskListImage, pWriterID, pPlaylistWriterID, pItemWidth, pItemHeight, pItemMarginX, pItemMarginY, pDiskArrayWidth, pDiskArrayHeight, pPlaylistWidth, pPlaylistHeight, pPlaylistLimit, pItemName, pItemNameSelected, pItemNameEmpty, pItemNameEmptySelected, pEjectName, pEjectNameSelected, pTextEmpty, pTextLoadTrax

on construct me
  pConnectionId = getVariableValue("connection.info.id", #info)
  pWriterID = getUniqueID()
  tBold = getStructVariable("struct.font.plain")
  tMetrics = [#font: tBold.getaProp(#font), #fontStyle: tBold.getaProp(#fontStyle), #color: rgb("#000000")]
  createWriter(pWriterID, tMetrics)
  pPlaylistWriterID = getUniqueID()
  tMetrics = [#font: tBold.getaProp(#font), #fontStyle: tBold.getaProp(#fontStyle), #color: rgb("#F59F0A")]
  createWriter(pPlaylistWriterID, tMetrics)
  pDiskList = [[#name: "Kiss my nose, baby", #author: "Painimies"], [#name: "Kiss my nose, baby"], [#name: "Kiss my nose, baby"], VOID, VOID, [#name: "Kiss my nose, baby"], [#name: "Kiss my nose, baby"]]
  pSelectedDisk = 0
  pSelectedEject = 0
  pItemWidth = 156
  pItemHeight = 39
  pItemMarginX = 6
  pItemMarginY = 1
  pDiskArrayWidth = 2
  pDiskArrayHeight = 5
  pPlaylistLimit = 9
  pPlaylistWidth = 122
  pPlaylistHeight = 14 * pPlaylistLimit
  pItemName = "Jukebox slot"
  pItemNameSelected = "Jukebox slot2"
  pItemNameEmpty = "Jukebox slot empty"
  pItemNameEmptySelected = "Jukebox slot empty2"
  pEjectName = "Jukebox eject"
  pEjectNameSelected = "Jukebox eject2"
  pTextEmpty = getText("jukebox_empty")
  pTextLoadTrax = getText("jukebox_load_trax")
  pOwner = 1
  pDiskListImage = VOID
  pEditorSongID = 0
end

on deconstruct me
  if writerExists(pWriterID) then
    removeWriter(pWriterID)
  end if
  if writerExists(pPlaylistWriterID) then
    removeWriter(pPlaylistWriterID)
  end if
end

on setOwner me, tOwner
  pOwner = tOwner
end

on renderDiskList me
  if voidp(pDiskListImage) then
    pDiskListRenderList = VOID
  else
    if pDiskListRenderList.findPos(pSelectedDisk) = 0 then
      pDiskListRenderList.add(pSelectedDisk)
    end if
  end if
  tRetVal = me.renderList(pDiskListImage)
  if tRetVal <> 0 then
    pDiskListImage = tRetVal
  end if
  pDiskListRenderList = []
  return tRetVal
end

on renderNowPlaying me, tDiskName, tDiskAuthor
  tImg = image(pPlaylistWidth, pPlaylistHeight, 32)
  tWriterObj = getWriter(pPlaylistWriterID)
  if tWriterObj <> 0 then
    tTextList = [tDiskName, tDiskAuthor]
    tLineSpace = 17
    repeat with i = 1 to tTextList.count
      tTextImg = tWriterObj.render(tTextList[i]).duplicate()
      tTextImgTrimmed = image(tTextImg.rect[3], tTextImg.rect[4], 32)
      tTextImgTrimmed.copyPixels(tTextImg, tTextImg.rect, tTextImg.rect, [#ink: 8, #maskImage: tTextImg.createMatte()])
      tTextImg = tTextImgTrimmed.trimWhiteSpace()
      tSourceRect = tTextImg.rect
      if tSourceRect[3] > pPlaylistWidth then
        tSourceRect[3] = pPlaylistWidth
      end if
      tTargetRect = tSourceRect.duplicate()
      tTargetRect[2] = tTargetRect[2] + (tLineSpace * (i - 1))
      tTargetRect[4] = tTargetRect[4] + (tLineSpace * (i - 1))
      tImg.copyPixels(tTextImg, tTargetRect, tSourceRect, [#ink: 36, #maskImage: tTextImg.createMatte()])
    end repeat
  end if
  return tImg
end

on renderPlaylist me, tSongList
  if ilk(tSongList) <> #list then
    return 0
  end if
  tImg = image(pPlaylistWidth, pPlaylistHeight, 32)
  tWriterObj = getWriter(pPlaylistWriterID)
  if tWriterObj <> 0 then
    tLineSpace = pPlaylistHeight / pPlaylistLimit
    repeat with i = min(tSongList.count, pPlaylistLimit) down to 1
      tTextImg = tWriterObj.render(tSongList[i]).duplicate()
      tTextImgTrimmed = image(tTextImg.rect[3], tTextImg.rect[4], 32)
      tTextImgTrimmed.copyPixels(tTextImg, tTextImg.rect, tTextImg.rect, [#ink: 8, #maskImage: tTextImg.createMatte()])
      tTextImg = tTextImgTrimmed.trimWhiteSpace()
      tSourceRect = tTextImg.rect
      if tSourceRect[3] > pPlaylistWidth then
        tSourceRect[3] = pPlaylistWidth
      end if
      tTargetRect = tSourceRect.duplicate()
      tTargetRect[2] = tTargetRect[2] + (tLineSpace * (i - 1))
      tTargetRect[4] = tTargetRect[4] + (tLineSpace * (i - 1))
      tImg.copyPixels(tTextImg, tTargetRect, tSourceRect, [#ink: 36, #maskImage: tTextImg.createMatte()])
    end repeat
  end if
  return tImg
end

on diskListMouseClick me, tX, tY
  tEmpty = 0
  if (pSelectedDisk < 1) or (pSelectedDisk > pDiskList.count) then
    if (pSelectedDisk > pDiskList.count) and (pSelectedDisk <= (pDiskArrayWidth * pDiskArrayHeight)) then
      tEmpty = 1
    else
      return 0
    end if
  else
    if voidp(pDiskList[pSelectedDisk]) then
      tEmpty = 1
    end if
  end if
  if tEmpty then
    me.showLoadDisk()
  else
    if pSelectedEject then
      me.removeDisk()
    else
      me.addPlaylistDisk()
    end if
  end if
  return 0
end

on diskListMouseOver me, tX, tY
  tItemX = 1 + (tX / (pItemWidth + pItemMarginX))
  tItemY = 1 + (tY / (pItemHeight + pItemMarginY))
  tItem = tItemX + ((tItemY - 1) * pDiskArrayWidth)
  if (tItem >= 1) and (tItem <= pDiskList.count) then
    tRetVal = 0
    tmember = getMember(pEjectNameSelected)
    if (tmember <> 0) and pOwner then
      tSourceImg = tmember.image
      tRect = tSourceImg.rect
      tImgWd = tRect[3] - tRect[1]
      tImgHt = tRect[4] - tRect[2]
      tRect[1] = tRect[1] + ((pItemWidth + pItemMarginX) * (tItemX - 1)) + (pItemWidth - tImgWd)
      tRect[2] = tRect[2] + ((pItemHeight + pItemMarginY) * (tItemY - 1)) + (pItemHeight - tImgHt)
      tRect[3] = tRect[3] + ((pItemWidth + pItemMarginX) * (tItemX - 1)) + (pItemWidth - tImgWd)
      tRect[4] = tRect[4] + ((pItemHeight + pItemMarginY) * (tItemY - 1)) + (pItemHeight - tImgHt)
      if (tX >= tRect[1]) and (tX <= tRect[3]) and (tY >= tRect[2]) and (tY <= tRect[4]) then
        if not pSelectedEject then
          tRetVal = 1
          pSelectedEject = 1
        end if
      else
        if pSelectedEject then
          tRetVal = 1
          pSelectedEject = 0
        end if
      end if
    end if
  end if
  if tItem <> pSelectedDisk then
    if pDiskListRenderList.findPos(pSelectedDisk) = 0 then
      pDiskListRenderList.add(pSelectedDisk)
    end if
    pSelectedDisk = tItem
    return 1
  end if
  return tRetVal
end

on renderList me, tImg
  if ilk(pDiskList) <> #list then
    return 0
  end if
  tWidth = ((pItemWidth + pItemMarginX) * pDiskArrayWidth) - pItemMarginX
  tHeight = ((pItemHeight + pItemMarginY) * pDiskArrayHeight) - pItemMarginY
  if voidp(tImg) then
    tImg = image(tWidth, tHeight, 32)
  end if
  tMemberNormal = getMember(pItemName)
  tMemberSelected = getMember(pItemNameSelected)
  tMemberEmptyNormal = getMember(pItemNameEmpty)
  tMemberEmptySelected = getMember(pItemNameEmptySelected)
  tWriterObj = getWriter(pWriterID)
  repeat with tY = 0 to pDiskArrayHeight - 1
    repeat with tX = 0 to pDiskArrayWidth - 1
      tIndex = 1 + tX + (tY * pDiskArrayWidth)
      tRender = 1
      if not voidp(pDiskListRenderList) then
        if pDiskListRenderList.findPos(tIndex) = 0 then
          tRender = 0
        end if
      end if
      if tRender then
        if (tIndex <> pSelectedDisk) or not pOwner then
          tmember = tMemberEmptyNormal
        else
          tmember = tMemberEmptySelected
        end if
        if tIndex <= pDiskList.count then
          if pDiskList[tIndex] <> VOID then
            if (tIndex <> pSelectedDisk) or pSelectedEject then
              tmember = tMemberNormal
            else
              tmember = tMemberSelected
            end if
          end if
        end if
      end if
      if (tmember <> 0) and (tRender = 1) then
        tSourceImg = tmember.image
        tRect = tSourceImg.rect
        tImgWd = tRect[3] - tRect[1]
        tImgHt = tRect[4] - tRect[2]
        tRect[1] = tRect[1] + ((pItemWidth + pItemMarginX) * tX)
        tRect[2] = tRect[2] + ((pItemHeight + pItemMarginY) * tY)
        tRect[3] = tRect[3] + ((pItemWidth + pItemMarginX) * tX)
        tRect[4] = tRect[4] + ((pItemHeight + pItemMarginY) * tY)
        tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, [#ink: 8, #maskImage: tSourceImg.createMatte()])
        if tWriterObj <> 0 then
          tDiskName = me.getDiskName(tIndex)
          tDiskAuthor = me.getDiskAuthor(tIndex)
          tTextList = [tDiskName, tDiskAuthor]
          tTextMarginX = 20
          tTextMarginY = 7
          tLineSpace = 17
          repeat with i = 1 to tTextList.count
            tTextImg = tWriterObj.render(tTextList[i]).duplicate()
            tTextImgTrimmed = image(tTextImg.rect[3], tTextImg.rect[4], 32)
            tTextImgTrimmed.copyPixels(tTextImg, tTextImg.rect, tTextImg.rect, [#ink: 8, #maskImage: tTextImg.createMatte()])
            tTextImg = tTextImgTrimmed.trimWhiteSpace()
            tSourceRect = tTextImg.rect
            if tSourceRect[3] > (pItemWidth - (tTextMarginX * 2)) then
              tSourceRect[3] = pItemWidth - (tTextMarginX * 2)
            end if
            tTargetRect = tSourceRect.duplicate()
            tImgWd = tTargetRect[3] - tTargetRect[1]
            tImgHt = tTargetRect[4] - tTargetRect[2]
            tTargetRect[1] = tTargetRect[1] + ((pItemWidth + pItemMarginX) * tX) + ((pItemWidth - tImgWd) / 2)
            tTargetRect[2] = tTargetRect[2] + ((pItemHeight + pItemMarginY) * tY) + tTextMarginY
            tTargetRect[3] = tTargetRect[3] + ((pItemWidth + pItemMarginX) * tX) + ((pItemWidth - tImgWd) / 2)
            tTargetRect[4] = tTargetRect[4] + ((pItemHeight + pItemMarginY) * tY) + tTextMarginY
            tTargetRect[2] = tTargetRect[2] + (tLineSpace * (i - 1))
            tTargetRect[4] = tTargetRect[4] + (tLineSpace * (i - 1))
            tImg.copyPixels(tTextImg, tTargetRect, tSourceRect, [#ink: 36, #maskImage: tTextImg.createMatte()])
          end repeat
        end if
      end if
    end repeat
  end repeat
  if pOwner then
    tImg = me.renderEjectImage(tImg)
  end if
  return tImg
end

on renderEjectImage me, tImg
  tWidth = ((pItemWidth + pItemMarginX) * pDiskArrayWidth) - pItemMarginX
  tHeight = ((pItemHeight + pItemMarginY) * pDiskArrayHeight) - pItemMarginY
  if voidp(tImg) then
    tImg = image(tWidth, tHeight, 32)
  end if
  if pSelectedEject then
    tmember = getMember(pEjectNameSelected)
  else
    tmember = getMember(pEjectName)
  end if
  if (pSelectedDisk < 1) or (pSelectedDisk > pDiskList.count) then
    return tImg
  end if
  if voidp(pDiskList[pSelectedDisk]) then
    return tImg
  end if
  tY = (pSelectedDisk - 1) / pDiskArrayWidth
  tX = (pSelectedDisk - 1) mod pDiskArrayWidth
  if tmember <> 0 then
    tSourceImg = tmember.image
    tRect = tSourceImg.rect
    tImgWd = tRect[3] - tRect[1]
    tImgHt = tRect[4] - tRect[2]
    tRect[1] = tRect[1] + ((pItemWidth + pItemMarginX) * tX) + (pItemWidth - tImgWd)
    tRect[2] = tRect[2] + ((pItemHeight + pItemMarginY) * tY) + (pItemHeight - tImgHt)
    tRect[3] = tRect[3] + ((pItemWidth + pItemMarginX) * tX) + (pItemWidth - tImgWd)
    tRect[4] = tRect[4] + ((pItemHeight + pItemMarginY) * tY) + (pItemHeight - tImgHt)
    tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, [#ink: 8, #maskImage: tSourceImg.createMatte()])
  end if
  return tImg
end

on getDiskName me, tIndex
  if (tIndex < 1) or (tIndex > pDiskList.count) then
    return pTextEmpty
  end if
  if ilk(pDiskList[tIndex]) = #propList then
    if not voidp(pDiskList[tIndex][#name]) then
      return pDiskList[tIndex][#name]
    end if
  end if
  return pTextEmpty
end

on getDiskAuthor me, tIndex
  tLoad = 0
  if (tIndex < 1) or (tIndex > pDiskList.count) then
    tLoad = 1
  else
    if ilk(pDiskList[tIndex]) = #propList then
      if not voidp(pDiskList[tIndex][#author]) then
        return pDiskList[tIndex][#author]
      end if
    else
      tLoad = 1
    end if
  end if
  if tLoad and pOwner then
    return pTextLoadTrax
  end if
  return EMPTY
end

on parseDiskList me, tMsg
  if voidp(tMsg.connection) then
    return 0
  end if
  tSlotCount = tMsg.connection.GetIntFrom()
  pDiskList = []
  repeat with i = 1 to tSlotCount
    pDiskList.add(VOID)
  end repeat
  tDiskCount = tMsg.connection.GetIntFrom()
  repeat with i = 1 to tDiskCount
    tSlot = tMsg.connection.GetIntFrom()
    tid = tMsg.connection.GetIntFrom()
    tLength = tMsg.connection.GetIntFrom()
    tName = tMsg.connection.GetStrFrom()
    tAuthor = tMsg.connection.GetStrFrom()
    tDisk = [#id: tid, #name: tName, #author: tAuthor]
    if (tSlot >= 1) and (tSlot <= tSlotCount) then
      pDiskList[tSlot] = tDisk
    end if
  end repeat
  return 1
end

on showLoadDisk me
  executeMessage(#show_select_disk)
end

on insertDisk me, tid
  if (pSelectedDisk < 1) or (pSelectedDisk > pDiskList.count) then
    return 0
  end if
  if not voidp(pDiskList[pSelectedDisk]) then
    return 0
  end if
  if getConnection(pConnectionId) <> 0 then
    return getConnection(pConnectionId).send("ADD_JUKEBOX_DISK", [#integer: tid, #integer: pSelectedDisk])
  end if
  return 0
end

on removeDisk me
  if (pSelectedDisk < 1) or (pSelectedDisk > pDiskList.count) then
    return 0
  end if
  if voidp(pDiskList[pSelectedDisk]) then
    return 0
  end if
  pDiskList[pSelectedDisk] = VOID
  if getConnection(pConnectionId) <> 0 then
    return getConnection(pConnectionId).send("REMOVE_JUKEBOX_DISK", [#integer: pSelectedDisk])
  end if
  return 0
end

on addPlaylistDisk me
  if (pSelectedDisk < 1) or (pSelectedDisk > pDiskList.count) then
    return 0
  end if
  if voidp(pDiskList[pSelectedDisk]) then
    return 0
  end if
  tid = pDiskList[pSelectedDisk][#id]
  if getConnection(pConnectionId) <> 0 then
    return getConnection(pConnectionId).send("JUKEBOX_PLAYLIST_ADD", [#integer: tid])
  end if
  return 0
end
