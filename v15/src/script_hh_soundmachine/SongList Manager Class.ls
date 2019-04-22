property pWriterID, pSelectedSong, pPlaylist, pPlaylistLimit, pSongList, pEditorSongID, pPlaylistChanged, pSelectedDisk, pDiskListImage, pDiskListRenderList, pDiskList, pSongListImage, pSongListRenderList, pSelectedPlaylistSong, pArrowListWidth, pItemHeight, pArrowUpName, pArrowUpNameDimmed, pArrowDownName, pArrowDownNameDimmed, pPlayTime, pInitialPlaylistTime, pConnectionId, pItemWidth, pItemName, pItemNameSelected, pItemNameBurnTag

on construct me 
  pConnectionId = getVariableValue("connection.info.id", #info)
  pWriterID = getUniqueID()
  tBold = getStructVariable("struct.font.plain")
  tMetrics = [#font:tBold.getaProp(#font), #fontStyle:tBold.getaProp(#fontStyle), #color:rgb("#000000")]
  createWriter(pWriterID, tMetrics)
  pSongList = []
  pPlaylist = []
  pPlayTime = 0
  pInitialPlaylistTime = 0
  pPlaylistLimit = 5
  pSelectedSong = 0
  pItemWidth = 150
  pItemHeight = 18
  pArrowListWidth = 40
  pItemName = "soundmachine_playlist_item"
  pItemNameSelected = "soundmachine_playlist_item2"
  pItemNameBurnTag = "soundmachine_playlist_burned_tag"
  pArrowUpName = "soundmachine_playlist_up"
  pArrowUpNameDimmed = "soundmachine_playlist_up2"
  pArrowDownName = "soundmachine_playlist_down"
  pArrowDownNameDimmed = "soundmachine_playlist_down2"
  pSelectedSong = 1
  pSelectedPlaylistSong = 0
  pPlaylistChanged = 0
  pSongListImage = void()
  pSongListRenderList = []
  pEditorSongID = 0
  pDiskList = []
  pSelectedDisk = 1
  pDiskListRenderList = []
  pDiskListImage = void()
end

on deconstruct me 
  if writerExists(pWriterID) then
    removeWriter(pWriterID)
  end if
end

on addPlaylistSong me 
  tIndex = pSelectedSong
  if pPlaylist.count >= pPlaylistLimit then
    return(0)
  end if
  if tIndex < 1 or tIndex > pSongList.count then
    return(0)
  end if
  pPlaylist.setAt(pPlaylist.count + 1, pSongList.getAt(tIndex).duplicate())
  pPlaylistChanged = 1
  return(1)
end

on insertPlaylistSong me, tid, tLength, tName, tAuthor 
  if voidp(tid) or voidp(tLength) or voidp(tName) or voidp(tAuthor) then
    return(0)
  end if
  pPlaylist.setAt(pPlaylist.count + 1, [#id:tid, #length:tLength, #name:tName, #author:tAuthor])
  if pPlaylist.count = 1 then
    me.resetPlayTime()
  end if
  return(1)
end

on removePlaylistSong me, tIndex 
  if tIndex < 1 or tIndex > pPlaylist.count then
    return(0)
  end if
  pPlaylist.deleteAt(tIndex)
  pPlaylistChanged = 1
  return(1)
end

on getPlaylistCount me 
  return(pPlaylist.count)
end

on getPlaylistSong me, tIndex 
  if tIndex < 1 or tIndex > pPlaylist.count then
    return(0)
  end if
  return(pPlaylist.getAt(tIndex).duplicate())
end

on getPlaylistSongName me, tIndex 
  if tIndex >= 1 and tIndex <= pPlaylist.count then
    tSongName = ""
    if ilk(pPlaylist.getAt(tIndex)) = #propList then
      if not voidp(pPlaylist.getAt(tIndex).getAt(#name)) then
        tSongName = pPlaylist.getAt(tIndex).getAt(#name)
      end if
    end if
    return(tSongName)
  end if
  return("")
end

on getPlaylistSongAuthor me, tIndex 
  if tIndex >= 1 and tIndex <= pPlaylist.count then
    tAuthor = ""
    if ilk(pPlaylist.getAt(tIndex)) = #propList then
      if not voidp(pPlaylist.getAt(tIndex).getAt(#author)) then
        tAuthor = pPlaylist.getAt(tIndex).getAt(#author)
      end if
    end if
    return(tAuthor)
  end if
  return("")
end

on getSongName me 
  tIndex = pSelectedSong
  if tIndex >= 1 and tIndex <= pSongList.count then
    tSongName = ""
    if ilk(pSongList.getAt(tIndex)) = #propList then
      if not voidp(pSongList.getAt(tIndex).getAt(#name)) then
        tSongName = pSongList.getAt(tIndex).getAt(#name)
      end if
    end if
    return(tSongName)
  end if
  return("")
end

on getSongDate me 
  return("1.1.2007")
end

on getSongLength me 
  tSongLength = -1
  if pSelectedSong >= 1 and pSelectedSong <= pSongList.count then
    if ilk(pSongList.getAt(pSelectedSong)) = #propList then
      if not voidp(pSongList.getAt(pSelectedSong).getAt(#length)) then
        tSongLength = pSongList.getAt(pSelectedSong).getAt(#length)
      end if
    end if
  end if
  return(tSongLength)
end

on getPlaylistLength me 
  tLength = 0
  i = 1
  repeat while i <= pPlaylist.count
    tSong = pPlaylist.getAt(i)
    if not voidp(tSong.getAt(#length)) then
      if tSong.getAt(#length) = -1 then
        return(-1)
      end if
      tLength = tLength + tSong.getAt(#length)
    else
      return(-1)
    end if
    i = 1 + i
  end repeat
  return(tLength)
end

on getPlaylistSongLength me, tIndex 
  if tIndex >= 1 and tIndex <= pPlaylist.count then
    tSongLength = -1
    if ilk(pPlaylist.getAt(tIndex)) = #propList then
      if not voidp(pPlaylist.getAt(tIndex).getAt(#length)) then
        tSongLength = pPlaylist.getAt(tIndex).getAt(#length)
      end if
    end if
    return(tSongLength)
  end if
  return(-1)
end

on getEditorSongID me 
  return(pEditorSongID)
end

on getPlaylistChanged me 
  return(pPlaylistChanged)
end

on getSelectedDiskIndex me 
  return(pSelectedDisk)
end

on renderDiskList me 
  if voidp(pDiskListImage) then
    pDiskListRenderList = void()
  else
    if pDiskListRenderList.findPos(pSelectedDisk) = 0 then
      pDiskListRenderList.add(pSelectedDisk)
    end if
  end if
  tRetVal = me.renderList(pDiskList, pSelectedDisk, pDiskListRenderList, pDiskListImage)
  if tRetVal <> 0 then
    pDiskListImage = tRetVal
  end if
  pDiskListRenderList = []
  return(tRetVal)
end

on renderSongList me 
  if voidp(pSongListImage) then
    pSongListRenderList = void()
  else
    if pSongListRenderList.findPos(pSelectedSong) = 0 then
      pSongListRenderList.add(pSelectedSong)
    end if
  end if
  tRetVal = me.renderList(pSongList, pSelectedSong, pSongListRenderList, pSongListImage)
  if tRetVal <> 0 then
    me.renderBurnedTag(tRetVal, pSongList, pSongListRenderList)
    pSongListImage = tRetVal
  end if
  pSongListRenderList = []
  return(tRetVal)
end

on renderPlaylist me 
  return(me.renderList(pPlaylist, pSelectedPlaylistSong, void(), void(), getText("sound_machine_song_remove")))
end

on renderPlaylistArrows me 
  tWidth = pArrowListWidth
  tHeight = pItemHeight * pPlaylist.count
  tImg = image(tWidth, tHeight, 32)
  tMemberUp = getMember(pArrowUpName)
  tMemberUp2 = getMember(pArrowUpNameDimmed)
  tMemberDown = getMember(pArrowDownName)
  tMemberDown2 = getMember(pArrowDownNameDimmed)
  j = 1
  repeat while j <= 2
    i = 1
    repeat while i <= pPlaylist.count
      if j = 1 then
        if i = 1 then
          tmember = tMemberUp2
        else
          tmember = tMemberUp
        end if
      else
        if i = pPlaylist.count then
          tmember = tMemberDown2
        else
          tmember = tMemberDown
        end if
      end if
      if tmember <> 0 then
        tSourceImg = tmember.image
        tRect = tSourceImg.rect
        tImgWd = tRect.getAt(3) - tRect.getAt(1)
        tImgHt = tRect.getAt(4) - tRect.getAt(2)
        tRect.setAt(1, tRect.getAt(1) + tWidth / 2 - tImgWd / 2 + tWidth / 2 * j - 1)
        tRect.setAt(2, tRect.getAt(2) + i - 1 * pItemHeight + pItemHeight - tImgHt / 2)
        tRect.setAt(3, tRect.getAt(3) + tWidth / 2 - tImgWd / 2 + tWidth / 2 * j - 1)
        tRect.setAt(4, tRect.getAt(4) + i - 1 * pItemHeight + pItemHeight - tImgHt / 2)
        tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, [#ink:8, #maskImage:tSourceImg.createMatte()])
      end if
      i = 1 + i
    end repeat
    j = 1 + j
  end repeat
  return(tImg)
end

on diskListMouseClick me, tX, tY 
  tItem = 1 + tY / pItemHeight
  if tItem >= 1 and tItem <= pDiskList.count then
    if pDiskListRenderList.findPos(pSelectedDisk) = 0 then
      pDiskListRenderList.add(pSelectedDisk)
    end if
    pSelectedDisk = tItem
    return(1)
  end if
  return(0)
end

on songListMouseClick me, tX, tY 
  tItem = 1 + tY / pItemHeight
  if tItem >= 1 and tItem <= pSongList.count then
    if pSongListRenderList.findPos(pSelectedSong) = 0 then
      pSongListRenderList.add(pSelectedSong)
    end if
    pSelectedSong = tItem
    return(1)
  end if
  return(0)
end

on playlistMouseClick me, tX, tY 
  tItem = 1 + tY / pItemHeight
  if tItem >= 1 and tItem <= pPlaylist.count then
    return(me.removePlaylistSong(tItem))
  end if
  return(0)
end

on playlistMouseOver me, tX, tY 
  tItem = 1 + tY / pItemHeight
  if tItem <> pSelectedPlaylistSong then
    pSelectedPlaylistSong = tItem
    return(1)
  end if
  return(0)
end

on playlistArrowMouseClick me, tX, tY 
  tItem = 1 + tY / pItemHeight
  if tItem >= 1 and tItem <= pPlaylist.count then
    if tX < pArrowListWidth / 2 then
      if tItem = 1 then
        return(0)
      end if
      tItem2 = tItem - 1
    else
      if tItem = pPlaylist.count then
        return(0)
      end if
      tItem2 = tItem + 1
    end if
    tSong = pPlaylist.getAt(tItem)
    pPlaylist.setAt(tItem, pPlaylist.getAt(tItem2))
    pPlaylist.setAt(tItem2, tSong)
    pPlaylistChanged = 1
    return(1)
  end if
  return(0)
end

on getPlayTime me 
  return(pPlayTime + the milliSeconds - pInitialPlaylistTime / 100)
end

on changePlayTime me, tDelta 
  pPlayTime = pPlayTime + tDelta
end

on resetPlayTime me 
  pPlayTime = 0
  pInitialPlaylistTime = the milliSeconds
end

on getPlaylistData me 
  pPlaylist = []
  pSelectedPlaylistSong = 0
  pPlayTime = 0
  pInitialPlaylistTime = 0
  if getConnection(pConnectionId) <> 0 then
    return(getConnection(pConnectionId).send("GET_PLAY_LIST"))
  end if
  return(0)
end

on getSongListData me 
  pSongList = []
  pSongListImage = void()
  pSelectedSong = 1
  if getConnection(pConnectionId) <> 0 then
    return(getConnection(pConnectionId).send("GET_SONG_LIST"))
  end if
  return(0)
end

on savePlaylist me 
  tMessage = [:]
  tMessage.addProp(#integer, pPlaylist.count)
  i = 1
  repeat while i <= pPlaylist.count
    tSong = pPlaylist.getAt(i)
    tMessage.addProp(#integer, tSong.getAt(#id))
    i = 1 + i
  end repeat
  if getConnection(pConnectionId) <> 0 then
    return(getConnection(pConnectionId).send("UPDATE_PLAY_LIST", tMessage))
  end if
  return(0)
end

on editSong me 
  if pSelectedSong < 1 or pSelectedSong > pSongList.count then
    return(0)
  end if
  if getConnection(pConnectionId) <> 0 then
    tSong = pSongList.getAt(pSelectedSong)
    pEditorSongID = tSong.getAt(#id)
    return(getConnection(pConnectionId).send("EDIT_SONG", [#integer:pEditorSongID]))
  end if
  return(0)
end

on newSong me 
  if getConnection(pConnectionId) <> 0 then
    return(getConnection(pConnectionId).send("NEW_SONG"))
  end if
  return(0)
end

on deleteSong me 
  if pSelectedSong < 1 or pSelectedSong > pSongList.count then
    return(0)
  end if
  if getConnection(pConnectionId) <> 0 then
    tSong = pSongList.getAt(pSelectedSong)
    pSongList.deleteAt(pSelectedSong)
    if pSelectedSong > pSongList.count then
      pSelectedSong = pSongList.count
    end if
    pSongListImage = void()
    tid = tSong.getAt(#id)
    return(getConnection(pConnectionId).send("DELETE_SONG", [#integer:tid]))
  end if
  return(0)
end

on downloadSong me, tid 
  if getConnection(pConnectionId) <> 0 then
    return(getConnection(pConnectionId).send("GET_SONG_INFO", [#integer:tid]))
  end if
  return(0)
end

on burnSong me 
  if pSelectedSong < 1 or pSelectedSong > pSongList.count then
    return(0)
  end if
  if getConnection(pConnectionId) <> 0 then
    tSong = pSongList.getAt(pSelectedSong)
    tid = tSong.getAt(#id)
    return(getConnection(pConnectionId).send("BURN_SONG", [#integer:tid]))
  end if
  return(0)
end

on setDiskList me, tDiskList 
  pDiskList = tDiskList
  pSelectedDisk = 1
  pDiskListImage = void()
  return(1)
end

on parseSongList me, tMsg 
  if voidp(tMsg.connection) then
    return(0)
  end if
  pSongList = []
  pSelectedSong = 1
  tCount = tMsg.GetIntFrom()
  i = 1
  repeat while i <= tCount
    tid = tMsg.GetIntFrom()
    tLength = tMsg.GetIntFrom()
    tName = tMsg.GetStrFrom()
    tIslocked = tMsg.GetIntFrom()
    tName = convertSpecialChars(tName, 0)
    pSongList.setAt(pSongList.count + 1, [#id:tid, #length:tLength, #name:tName, #locked:tIslocked, #author:""])
    i = 1 + i
  end repeat
  if pPlaylistChanged then
    i = pPlaylist.count
    repeat while i >= 1
      tFound = 0
      tid = pPlaylist.getAt(i).getAt(#id)
      j = 1
      repeat while j <= pSongList.count
        if pSongList.getAt(j).getAt(#id) = tid then
          tFound = 1
        else
          j = 1 + j
        end if
      end repeat
      if not tFound then
        pPlaylist.deleteAt(i)
      end if
      i = 255 + i
    end repeat
  end if
  pSongListImage = void()
  return(1)
end

on parsePlaylist me, tMsg 
  if voidp(tMsg.connection) then
    return(0)
  end if
  pPlaylist = []
  pSelectedPlaylistSong = 0
  pPlayTime = tMsg.GetIntFrom()
  pInitialPlaylistTime = the milliSeconds
  tCount = tMsg.GetIntFrom()
  i = 1
  repeat while i <= tCount
    tid = tMsg.GetIntFrom()
    tLength = tMsg.GetIntFrom()
    tName = tMsg.GetStrFrom()
    tAuthor = tMsg.GetStrFrom()
    tName = convertSpecialChars(tName, 0)
    tAuthor = convertSpecialChars(tAuthor, 0)
    pPlaylist.setAt(pPlaylist.count + 1, [#id:tid, #length:tLength, #name:tName, #author:tAuthor])
    i = 1 + i
  end repeat
  pPlaylistChanged = 0
  return(1)
end

on renderList me, tList, tSelected, tRenderList, tImg, tSelectedText 
  if ilk(tList) <> #list then
    return(0)
  end if
  tWidth = pItemWidth
  tHeight = pItemHeight * tList.count
  if voidp(tImg) then
    tImg = image(tWidth, tHeight, 32)
  end if
  tMemberNormal = getMember(pItemName)
  tMemberSelected = getMember(pItemNameSelected)
  tWriterObj = getWriter(pWriterID)
  i = 1
  repeat while i <= tList.count
    tRender = 1
    if not voidp(tRenderList) then
      if tRenderList.findPos(i) = 0 then
        tRender = 0
      end if
    end if
    if i <> tSelected then
      tmember = tMemberNormal
    else
      tmember = tMemberSelected
    end if
    if tmember <> 0 and tRender = 1 then
      tSourceImg = tmember.image
      tRect = tSourceImg.rect
      tImgWd = tRect.getAt(3) - tRect.getAt(1)
      tImgHt = tRect.getAt(4) - tRect.getAt(2)
      tRect.setAt(1, tRect.getAt(1) + pItemWidth - tImgWd / 2)
      tRect.setAt(2, tRect.getAt(2) + i - 1 * pItemHeight + pItemHeight - tImgHt / 2)
      tRect.setAt(3, tRect.getAt(3) + pItemWidth - tImgWd / 2)
      tRect.setAt(4, tRect.getAt(4) + i - 1 * pItemHeight + pItemHeight - tImgHt / 2)
      tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, [#ink:8, #maskImage:tSourceImg.createMatte()])
      if tWriterObj <> 0 then
        tSongName = ""
        if ilk(tList.getAt(i)) = #propList then
          if not voidp(tList.getAt(i).getAt(#name)) then
            tSongName = tList.getAt(i).getAt(#name)
          end if
        end if
        if i = tSelected and not voidp(tSelectedText) then
          tSongName = tSelectedText
        end if
        tTextImg = tWriterObj.render(tSongName).duplicate()
        tTextImgTrimmed = image(tTextImg.getProp(#rect, 3), tTextImg.getProp(#rect, 4), 32)
        tTextImgTrimmed.copyPixels(tTextImg, tTextImg.rect, tTextImg.rect, [#ink:8, #maskImage:tTextImg.createMatte()])
        tTextImg = tTextImgTrimmed.trimWhiteSpace()
        tTextMargin = 20
        tSourceRect = tTextImg.rect
        if tSourceRect.getAt(3) > pItemWidth - tTextMargin * 2 then
          tSourceRect.setAt(3, pItemWidth - tTextMargin * 2)
        end if
        tTargetRect = tSourceRect.duplicate()
        tImgWd = tTargetRect.getAt(3) - tTargetRect.getAt(1)
        tImgHt = tTargetRect.getAt(4) - tTargetRect.getAt(2)
        tTargetRect.setAt(1, tTargetRect.getAt(1) + tTextMargin)
        tTargetRect.setAt(2, tTargetRect.getAt(2) + i - 1 * pItemHeight + pItemHeight - tImgHt / 2)
        tTargetRect.setAt(3, tTargetRect.getAt(3) + tTextMargin)
        tTargetRect.setAt(4, tTargetRect.getAt(4) + i - 1 * pItemHeight + pItemHeight - tImgHt / 2)
        tImg.copyPixels(tTextImg, tTargetRect, tSourceRect, [#ink:36, #maskImage:tTextImg.createMatte()])
      end if
    end if
    i = 1 + i
  end repeat
  return(tImg)
end

on renderBurnedTag me, tImg, tList, tRenderList 
  if ilk(tList) <> #list then
    return(0)
  end if
  tWidth = pItemWidth
  tHeight = pItemHeight * tList.count
  if voidp(tImg) then
    tImg = image(tWidth, tHeight, 32)
  end if
  tmember = getMember(pItemNameBurnTag)
  i = 1
  repeat while i <= tList.count
    tRender = 0
    if not voidp(tList.getAt(i).getAt(#locked)) then
      if tList.getAt(i).getAt(#locked) then
        tRender = 1
      end if
    end if
    if not voidp(tRenderList) then
      if tRenderList.findPos(i) = 0 then
        tRender = 0
      end if
    end if
    if tmember <> 0 and tRender = 1 then
      tSourceImg = tmember.image
      tRect = tSourceImg.rect
      tImgWd = tRect.getAt(3) - tRect.getAt(1)
      tImgHt = tRect.getAt(4) - tRect.getAt(2)
      tRect.setAt(1, tRect.getAt(1) + pItemWidth - tImgWd + 3)
      tRect.setAt(2, tRect.getAt(2) + i - 1 * pItemHeight + pItemHeight - tImgHt / 2)
      tRect.setAt(3, tRect.getAt(3) + pItemWidth - tImgWd + 3)
      tRect.setAt(4, tRect.getAt(4) + i - 1 * pItemHeight + pItemHeight - tImgHt / 2)
      tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, [#ink:8, #maskImage:tSourceImg.createMatte()])
    end if
    i = 1 + i
  end repeat
  return(tImg)
end
