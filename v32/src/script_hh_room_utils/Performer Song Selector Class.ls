property pSongList, pWindowID, pRowHeight, pListImage, pWriter, pSelectedRow, pSelectionColor, pOffsetX

on construct me 
  pWindowID = #performer_song_selector
  pRowHeight = 25
  pOffsetX = 10
  pSelectionColor = rgb("A5BDF7")
  pSelectedRow = 1
  pListImage = image(1, 1, 32)
  tID = getUniqueID()
  createWriter(tID, getStructVariable("struct.font.plain"))
  pWriter = getWriter(tID)
  registerMessage(#close_performer_song_selector, me.getID(), #close)
  return(1)
end

on deconstruct me 
  unregisterMessage(#close_performer_song_selector, me.getID())
  return(1)
end

on open me, tSongList 
  if tSongList.ilk <> #propList then
    return(0)
  end if
  pSongList = [0:getText("performer_no_song")]
  i = 1
  repeat while i <= tSongList.count
    pSongList.setaProp(tSongList.getPropAt(i), tSongList.getAt(i))
    i = 1 + i
  end repeat
  tWindow = me.getWindowObj()
  tWindow.registerProcedure(#eventProcSongList, me.getID(), #mouseUp)
  pSelectedRow = 1
  me.Refresh()
end

on close me 
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
end

on getWindowObj me 
  if windowExists(pWindowID) then
    return(getWindow(pWindowID))
  end if
  createWindow(pWindowID)
  tWindow = getWindow(pWindowID)
  tWindow.setProperty(#title, getText("performer_song_selector"))
  tWindow.merge("habbo_full.window")
  tWindow.merge("song_selection.window")
  if tWindow.elementExists("close") then
    tWindow.getElement("close").hide()
  end if
  return(tWindow)
end

on Refresh me 
  if pSongList.ilk <> #propList then
    return(0)
  end if
  tWindow = me.getWindowObj()
  if not tWindow.elementExists("performer_song_list") then
    return(0)
  end if
  tListElem = tWindow.getElement("performer_song_list")
  tListWidth = tListElem.getProperty(#width)
  tListHeight = (pSongList.count * pRowHeight)
  if pListImage.width <> tListWidth or pListImage.height <> tListHeight then
    pListImage = image(tListWidth, tListHeight, 32)
  end if
  i = 1
  repeat while i <= pSongList.count
    tSongName = pSongList.getAt(i)
    tNameImage = pWriter.render(tSongName).duplicate()
    tRowRect = rect(0, (i - 1 * pRowHeight), tListWidth, (i * pRowHeight))
    if pSelectedRow = i then
      pListImage.fill(tRowRect, pSelectionColor)
    else
      pListImage.fill(tRowRect, rgb("FFFFFF"))
    end if
    tOffsetY = tRowRect.top + (tRowRect.height - tNameImage.height / 2)
    tNameTarget = tNameImage.rect + [pOffsetX, tOffsetY, pOffsetX, tOffsetY]
    pListImage.copyPixels(tNameImage, tNameTarget, tNameImage.rect, [#ink:36])
    i = 1 + i
  end repeat
  tListElem.feedImage(pListImage)
  if tWindow.elementExists("performer_song_list_scroll") then
    tShowScroll = (pSongList.count * pRowHeight) > tListElem.getProperty(#height)
    tWindow.getElement("performer_song_list_scroll").setProperty(#visible, tShowScroll)
  end if
end

on eventProcSongList me, tEvent, tSprID, tParam 
  if tSprID = "performer_song_list" then
    if tParam.ilk <> #point then
      return(0)
    end if
    pSelectedRow = (tParam.getAt(2) / pRowHeight) + 1
    me.Refresh()
  else
    if tSprID = "performer_start_button" then
      tConn = getConnection(getVariable("connection.info.id"))
      if not tConn then
        return(me.close())
      end if
      tSongID = pSongList.getPropAt(pSelectedRow)
      tConn.send("START_PERFORMANCE", [#integer:integer(tSongID)])
      me.close()
    end if
  end if
end
