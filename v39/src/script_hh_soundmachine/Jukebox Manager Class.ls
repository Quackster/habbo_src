property pWriterID, pPlaylistWriterID, pPlaylistLimit, pOwner, pDiskListImage, pDiskListRenderList, pSelectedDisk, pPlaylistWidth, pPlaylistHeight, pDiskList, pDiskArrayWidth, pDiskArrayHeight, pSelectedEject, pItemWidth, pItemMarginX, pItemHeight, pItemMarginY, pEjectNameSelected, pConnectionId, pItemName, pItemNameSelected, pItemNameEmpty, pItemNameEmptySelected, pEjectName, pTextEmpty, pTextLoadTrax, pSelectedLoad

on construct me 
  pConnectionId = getVariable("connection.info.id", #info)
  pWriterID = getUniqueID()
  tBold = getStructVariable("struct.font.plain")
  tMetrics = [#font:tBold.getaProp(#font), #fontStyle:tBold.getaProp(#fontStyle), #color:rgb("#000000")]
  createWriter(pWriterID, tMetrics)
  pPlaylistWriterID = getUniqueID()
  tMetrics = [#font:tBold.getaProp(#font), #fontStyle:tBold.getaProp(#fontStyle), #color:rgb("#F59F0A")]
  createWriter(pPlaylistWriterID, tMetrics)
  pDiskList = [[#name:"Kiss my nose, baby", #author:"Painimies"], [#name:"Kiss my nose, baby"], [#name:"Kiss my nose, baby"], void(), void(), [#name:"Kiss my nose, baby"], [#name:"Kiss my nose, baby"]]
  pSelectedDisk = 0
  pSelectedEject = 0
  pSelectedLoad = 0
  pItemWidth = 156
  pItemHeight = 39
  pItemMarginX = 6
  pItemMarginY = 1
  pDiskArrayWidth = 2
  pDiskArrayHeight = 5
  pPlaylistLimit = 9
  pPlaylistWidth = 122
  pPlaylistHeight = (14 * pPlaylistLimit)
  pItemName = "Jukebox slot"
  pItemNameSelected = "Jukebox slot2"
  pItemNameEmpty = "Jukebox slot empty"
  pItemNameEmptySelected = "Jukebox slot empty2"
  pEjectName = "Jukebox eject"
  pEjectNameSelected = "Jukebox eject2"
  pTextEmpty = getText("jukebox_empty")
  pTextLoadTrax = getText("jukebox_load_trax")
  pOwner = 1
  pDiskListImage = void()
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

on setOwner me, towner 
  pOwner = towner
end

on getOwner me 
  return(pOwner)
end

on renderDiskList me 
  if voidp(pDiskListImage) then
    pDiskListRenderList = void()
  else
    if (pDiskListRenderList.findPos(pSelectedDisk) = 0) then
      pDiskListRenderList.add(pSelectedDisk)
    end if
  end if
  tRetVal = me.renderList(pDiskListImage)
  if tRetVal <> 0 then
    pDiskListImage = tRetVal
  end if
  pDiskListRenderList = []
  return(tRetVal)
end

on renderPlaylist me, tSongList 
  if ilk(tSongList) <> #list then
    return FALSE
  end if
  tImg = image(pPlaylistWidth, pPlaylistHeight, 32)
  tWriterObj = getWriter(pPlaylistWriterID)
  if tWriterObj <> 0 then
    tLineSpace = (pPlaylistHeight / pPlaylistLimit)
    i = min(tSongList.count, pPlaylistLimit)
    repeat while i >= 1
      tTextImg = tWriterObj.render(tSongList.getAt(i)).duplicate()
      tTextImgTrimmed = image(tTextImg.getProp(#rect, 3), tTextImg.getProp(#rect, 4), 32)
      tTextImgTrimmed.copyPixels(tTextImg, tTextImg.rect, tTextImg.rect, [#ink:8, #maskImage:tTextImg.createMatte()])
      tTextImg = tTextImgTrimmed.trimWhiteSpace()
      tSourceRect = tTextImg.rect
      if tSourceRect.getAt(3) > pPlaylistWidth then
        tSourceRect.setAt(3, pPlaylistWidth)
      end if
      tTargetRect = tSourceRect.duplicate()
      tTargetRect.setAt(2, (tTargetRect.getAt(2) + (tLineSpace * (i - 1))))
      tTargetRect.setAt(4, (tTargetRect.getAt(4) + (tLineSpace * (i - 1))))
      tImg.copyPixels(tTextImg, tTargetRect, tSourceRect, [#ink:36, #maskImage:tTextImg.createMatte()])
      i = (255 + i)
    end repeat
  end if
  return(tImg)
end

on diskListMouseClick me, tX, tY 
  tEmpty = 0
  if pSelectedDisk < 1 or pSelectedDisk > pDiskList.count then
    if pSelectedDisk > pDiskList.count and pSelectedDisk <= (pDiskArrayWidth * pDiskArrayHeight) then
      tEmpty = 1
    else
      return FALSE
    end if
  else
    if voidp(pDiskList.getAt(pSelectedDisk)) then
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
  return FALSE
end

on diskListMouseOver me, tX, tY 
  tItemX = (1 + (tX / (pItemWidth + pItemMarginX)))
  tItemY = (1 + (tY / (pItemHeight + pItemMarginY)))
  tItem = (tItemX + ((tItemY - 1) * pDiskArrayWidth))
  if tItem >= 1 and tItem <= pDiskList.count then
    tRetVal = 0
    tmember = getMember(pEjectNameSelected)
    if tmember <> 0 and pOwner then
      tSourceImg = tmember.image
      tRect = tSourceImg.rect
      tImgWd = (tRect.getAt(3) - tRect.getAt(1))
      tImgHt = (tRect.getAt(4) - tRect.getAt(2))
      tRect.setAt(1, ((tRect.getAt(1) + ((pItemWidth + pItemMarginX) * (tItemX - 1))) + (pItemWidth - tImgWd)))
      tRect.setAt(2, ((tRect.getAt(2) + ((pItemHeight + pItemMarginY) * (tItemY - 1))) + (pItemHeight - tImgHt)))
      tRect.setAt(3, ((tRect.getAt(3) + ((pItemWidth + pItemMarginX) * (tItemX - 1))) + (pItemWidth - tImgWd)))
      tRect.setAt(4, ((tRect.getAt(4) + ((pItemHeight + pItemMarginY) * (tItemY - 1))) + (pItemHeight - tImgHt)))
      if tX >= tRect.getAt(1) and tX <= tRect.getAt(3) and tY >= tRect.getAt(2) and tY <= tRect.getAt(4) then
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
    if (pDiskListRenderList.findPos(pSelectedDisk) = 0) then
      pDiskListRenderList.add(pSelectedDisk)
    end if
    pSelectedDisk = tItem
    return TRUE
  end if
  return(tRetVal)
end

on getJukeboxDisks me 
  pDiskList = []
  pSelectedDisk = 0
  pSelectedEject = 0
  if getConnection(pConnectionId) <> 0 then
    return(getConnection(pConnectionId).send("GET_JUKEBOX_DISCS"))
  end if
  return FALSE
end

on renderList me, tImg 
  if ilk(pDiskList) <> #list then
    return FALSE
  end if
  tWidth = (((pItemWidth + pItemMarginX) * pDiskArrayWidth) - pItemMarginX)
  tHeight = (((pItemHeight + pItemMarginY) * pDiskArrayHeight) - pItemMarginY)
  if voidp(tImg) then
    tImg = image(tWidth, tHeight, 32)
  end if
  tMemberNormal = getMember(pItemName)
  tMemberSelected = getMember(pItemNameSelected)
  tMemberEmptyNormal = getMember(pItemNameEmpty)
  tMemberEmptySelected = getMember(pItemNameEmptySelected)
  tWriterObj = getWriter(pWriterID)
  tY = 0
  repeat while tY <= (pDiskArrayHeight - 1)
    tX = 0
    repeat while tX <= (pDiskArrayWidth - 1)
      tIndex = ((1 + tX) + (tY * pDiskArrayWidth))
      tRender = 1
      if not voidp(pDiskListRenderList) then
        if (pDiskListRenderList.findPos(tIndex) = 0) then
          tRender = 0
        end if
      end if
      if tRender then
        if tIndex <> pSelectedDisk or not pOwner then
          tmember = tMemberEmptyNormal
        else
          tmember = tMemberEmptySelected
        end if
        if tIndex <= pDiskList.count then
          if pDiskList.getAt(tIndex) <> void() then
            if tIndex <> pSelectedDisk or pSelectedEject then
              tmember = tMemberNormal
            else
              tmember = tMemberSelected
            end if
          end if
        end if
      end if
      if tmember <> 0 and (tRender = 1) then
        tSourceImg = tmember.image
        tRect = tSourceImg.rect
        tImgWd = (tRect.getAt(3) - tRect.getAt(1))
        tImgHt = (tRect.getAt(4) - tRect.getAt(2))
        tRect.setAt(1, (tRect.getAt(1) + ((pItemWidth + pItemMarginX) * tX)))
        tRect.setAt(2, (tRect.getAt(2) + ((pItemHeight + pItemMarginY) * tY)))
        tRect.setAt(3, (tRect.getAt(3) + ((pItemWidth + pItemMarginX) * tX)))
        tRect.setAt(4, (tRect.getAt(4) + ((pItemHeight + pItemMarginY) * tY)))
        tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, [#ink:8, #maskImage:tSourceImg.createMatte()])
        if tWriterObj <> 0 then
          tDiskName = me.getDiskName(tIndex)
          tDiskAuthor = me.getDiskAuthor(tIndex)
          tTextList = [tDiskName, tDiskAuthor]
          tTextMarginX = 20
          tTextMarginY = 7
          tLineSpace = 17
          i = 1
          repeat while i <= tTextList.count
            tTextImg = tWriterObj.render(tTextList.getAt(i)).duplicate()
            tTextImgTrimmed = image(tTextImg.getProp(#rect, 3), tTextImg.getProp(#rect, 4), 32)
            tTextImgTrimmed.copyPixels(tTextImg, tTextImg.rect, tTextImg.rect, [#ink:8, #maskImage:tTextImg.createMatte()])
            tTextImg = tTextImgTrimmed.trimWhiteSpace()
            tSourceRect = tTextImg.rect
            if tSourceRect.getAt(3) > (pItemWidth - (tTextMarginX * 2)) then
              tSourceRect.setAt(3, (pItemWidth - (tTextMarginX * 2)))
            end if
            tTargetRect = tSourceRect.duplicate()
            tImgWd = (tTargetRect.getAt(3) - tTargetRect.getAt(1))
            tImgHt = (tTargetRect.getAt(4) - tTargetRect.getAt(2))
            tTargetRect.setAt(1, ((tTargetRect.getAt(1) + ((pItemWidth + pItemMarginX) * tX)) + ((pItemWidth - tImgWd) / 2)))
            tTargetRect.setAt(2, ((tTargetRect.getAt(2) + ((pItemHeight + pItemMarginY) * tY)) + tTextMarginY))
            tTargetRect.setAt(3, ((tTargetRect.getAt(3) + ((pItemWidth + pItemMarginX) * tX)) + ((pItemWidth - tImgWd) / 2)))
            tTargetRect.setAt(4, ((tTargetRect.getAt(4) + ((pItemHeight + pItemMarginY) * tY)) + tTextMarginY))
            tTargetRect.setAt(2, (tTargetRect.getAt(2) + (tLineSpace * (i - 1))))
            tTargetRect.setAt(4, (tTargetRect.getAt(4) + (tLineSpace * (i - 1))))
            tImg.copyPixels(tTextImg, tTargetRect, tSourceRect, [#ink:36, #maskImage:tTextImg.createMatte()])
            i = (1 + i)
          end repeat
        end if
      end if
      tX = (1 + tX)
    end repeat
    tY = (1 + tY)
  end repeat
  if pOwner then
    tImg = me.renderEjectImage(tImg)
  end if
  return(tImg)
end

on renderEjectImage me, tImg 
  tWidth = (((pItemWidth + pItemMarginX) * pDiskArrayWidth) - pItemMarginX)
  tHeight = (((pItemHeight + pItemMarginY) * pDiskArrayHeight) - pItemMarginY)
  if voidp(tImg) then
    tImg = image(tWidth, tHeight, 32)
  end if
  if pSelectedEject then
    tmember = getMember(pEjectNameSelected)
  else
    tmember = getMember(pEjectName)
  end if
  if pSelectedDisk < 1 or pSelectedDisk > pDiskList.count then
    return(tImg)
  end if
  if voidp(pDiskList.getAt(pSelectedDisk)) then
    return(tImg)
  end if
  tY = ((pSelectedDisk - 1) / pDiskArrayWidth)
  tX = ((pSelectedDisk - 1) mod pDiskArrayWidth)
  if tmember <> 0 then
    tSourceImg = tmember.image
    tRect = tSourceImg.rect
    tImgWd = (tRect.getAt(3) - tRect.getAt(1))
    tImgHt = (tRect.getAt(4) - tRect.getAt(2))
    tRect.setAt(1, ((tRect.getAt(1) + ((pItemWidth + pItemMarginX) * tX)) + (pItemWidth - tImgWd)))
    tRect.setAt(2, ((tRect.getAt(2) + ((pItemHeight + pItemMarginY) * tY)) + (pItemHeight - tImgHt)))
    tRect.setAt(3, ((tRect.getAt(3) + ((pItemWidth + pItemMarginX) * tX)) + (pItemWidth - tImgWd)))
    tRect.setAt(4, ((tRect.getAt(4) + ((pItemHeight + pItemMarginY) * tY)) + (pItemHeight - tImgHt)))
    tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, [#ink:8, #maskImage:tSourceImg.createMatte()])
  end if
  return(tImg)
end

on getDiskName me, tIndex 
  if tIndex < 1 or tIndex > pDiskList.count then
    return(pTextEmpty)
  end if
  if (ilk(pDiskList.getAt(tIndex)) = #propList) then
    if not voidp(pDiskList.getAt(tIndex).getAt(#name)) then
      return(pDiskList.getAt(tIndex).getAt(#name))
    end if
  end if
  return(pTextEmpty)
end

on getDiskAuthor me, tIndex 
  tLoad = 0
  if tIndex < 1 or tIndex > pDiskList.count then
    tLoad = 1
  else
    if (ilk(pDiskList.getAt(tIndex)) = #propList) then
      if not voidp(pDiskList.getAt(tIndex).getAt(#author)) then
        return(pDiskList.getAt(tIndex).getAt(#author))
      end if
    else
      tLoad = 1
    end if
  end if
  if tLoad and pOwner then
    return(pTextLoadTrax)
  end if
  return("")
end

on parseDiskList me, tMsg 
  if voidp(tMsg.connection) then
    return FALSE
  end if
  tSlotCount = tMsg.connection.GetIntFrom()
  pDiskList = []
  i = 1
  repeat while i <= tSlotCount
    pDiskList.add(void())
    i = (1 + i)
  end repeat
  tDiskCount = tMsg.connection.GetIntFrom()
  i = 1
  repeat while i <= tDiskCount
    tSlot = tMsg.connection.GetIntFrom()
    tID = tMsg.connection.GetIntFrom()
    tLength = tMsg.connection.GetIntFrom()
    tName = tMsg.connection.GetStrFrom()
    tAuthor = tMsg.connection.GetStrFrom()
    tName = convertSpecialChars(tName, 0)
    tAuthor = convertSpecialChars(tAuthor, 0)
    tDisk = [#id:tID, #name:tName, #author:tAuthor]
    if tSlot >= 1 and tSlot <= tSlotCount then
      pDiskList.setAt(tSlot, tDisk)
    end if
    i = (1 + i)
  end repeat
  pDiskListImage = void()
  return TRUE
end

on showLoadDisk me 
  if pOwner then
    pSelectedLoad = pSelectedDisk
    executeMessage(#show_select_disk)
  end if
end

on insertDisk me, tID 
  if pSelectedLoad < 1 or pSelectedLoad > pDiskList.count then
    return FALSE
  end if
  if not voidp(pDiskList.getAt(pSelectedLoad)) then
    return FALSE
  end if
  if getConnection(pConnectionId) <> 0 then
    return(getConnection(pConnectionId).send("ADD_JUKEBOX_DISC", [#integer:tID, #integer:pSelectedLoad]))
  end if
  return FALSE
end

on removeDisk me 
  if pSelectedDisk < 1 or pSelectedDisk > pDiskList.count then
    return FALSE
  end if
  if voidp(pDiskList.getAt(pSelectedDisk)) then
    return FALSE
  end if
  pDiskList.setAt(pSelectedDisk, void())
  if getConnection(pConnectionId) <> 0 then
    return(getConnection(pConnectionId).send("REMOVE_JUKEBOX_DISC", [#integer:pSelectedDisk]))
  end if
  return FALSE
end

on addPlaylistDisk me 
  if pSelectedDisk < 1 or pSelectedDisk > pDiskList.count then
    return FALSE
  end if
  if voidp(pDiskList.getAt(pSelectedDisk)) then
    return FALSE
  end if
  tID = pDiskList.getAt(pSelectedDisk).getAt(#id)
  if getConnection(pConnectionId) <> 0 then
    return(getConnection(pConnectionId).send("JUKEBOX_PLAYLIST_ADD", [#integer:tID]))
  end if
  return FALSE
end
