on construct(me)
  pWindowID = #photo_window
  pPhotoCache = []
  pPhotoMember = void()
  createWriter(#photo_timestamp_writer_black, [#color:rgb(0, 0, 0)])
  createWriter(#photo_timestamp_writer_white, [#color:rgb(255, 255, 240)])
  return(1)
  exit
end

on deconstruct(me)
  if pPhotoMember.ilk = #member then
    removeMember(pPhotoMember.name)
    pPhotoMember = void()
  end if
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  removeWriter(#photo_timestamp_writer_black)
  removeWriter(#photo_timestamp_writer_white)
  return(1)
  exit
end

on storePicture(me, tmember, tText)
  if not voidp(tText) then
    tText = getStringServices().convertSpecialChars(tText, 1)
  end if
  tCS = me.countCS(tmember.image)
  tdata = [#image:tmember.media, #time:the date && the time, #cs:tCS]
  addMessageToBinaryQueue("PHOTOTXT /" & tText)
  storeBinaryData(tdata, me.getID())
  pLastPhotoData = tdata
  exit
end

on binaryDataStored(me, tID)
  me.getInterface().saveOk()
  pPhotoCache.setaProp(tID, pLastPhotoData)
  pLastPhotoData = void()
  exit
end

on binaryDataReceived(me, tdata, tID)
  if ilk(tdata) <> #propList then
    return(0)
  end if
  if tdata.getAt(#image) = void() then
    return(0)
  end if
  tText = pPhotoText
  pPhotoCache.setaProp(tID, tdata)
  if not windowExists(pWindowID) then
    return(0)
  end if
  getWindow(pWindowID).getElement("photo_text").setText(tText)
  if pPhotoMember.ilk <> #member then
    pPhotoMember = member(createMember(getUniqueID(), #bitmap))
  end if
  pPhotoMember.media = tdata.getAt(#image)
  if pPhotoMember.type <> #bitmap or pPhotoMember.scriptText <> "" then
    pPhotoMember.erase()
    return(0)
  end if
  if tdata.getAt(#cs) <> void() then
    tCheckSumOk = me.countCS(pPhotoMember.image) = tdata.getAt(#cs)
  else
    tCheckSumOk = 0
  end if
  if tCheckSumOk = 0 then
    pPhotoMember.media = member(getmemnum("photo_invalid")).media
  else
    if pPhotoTime <> void() and length(pPhotoTime) > 5 then
      tBlackImg = getWriter(#photo_timestamp_writer_black).render(pPhotoTime)
      tWhiteImg = getWriter(#photo_timestamp_writer_white).render(pPhotoTime)
      tL = image.width - 3 - tBlackImg.width
      tt = image.height - 3 - tBlackImg.height
      tR = rect(tL, tt, tL + tBlackImg.width, tt + tBlackImg.height)
      image.copyPixels(tBlackImg, tR + rect(-1, 0, -1, 0), tBlackImg.rect, [#ink:36])
      image.copyPixels(tBlackImg, tR + rect(1, 0, 1, 0), tBlackImg.rect, [#ink:36])
      image.copyPixels(tBlackImg, tR + rect(0, 1, 0, 1), tBlackImg.rect, [#ink:36])
      image.copyPixels(tBlackImg, tR + rect(0, -1, 0, -1), tBlackImg.rect, [#ink:36])
      image.copyPixels(tWhiteImg, tR, tBlackImg.rect, [#ink:36])
    end if
  end if
  getWindow(pWindowID).getElement("photo_picture").setProperty(#buffer, pPhotoMember)
  exit
end

on openPhoto(me, tItemID, tLocX, tLocY)
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  pLocX = tLocX
  pLocY = tLocY
  registerMessage(symbol("itemdata_received" & tItemID), me.getID(), #setItemData)
  getConnection(getVariable("connection.room.id")).send("G_IDATA", tItemID)
  exit
end

on countCS(me, tImg)
  tL = [3, 2, 73, 28, 83, 21, 43, 90, 92, 91, 37, 4, 3, 84, 12, 102, 103, 108, 97, 43, 44, 89, 109, 65, 61, -4, 76]
  tA = 0
  tW = tImg.width
  tH = tImg.height
  i = 1
  repeat while i <= 100
    tA = ERROR mod ERROR mod tA + tImg.getPixel(i mod tW, i * i mod tH).paletteIndex * tL.getAt(i mod tL.count + 1).undefined
    i = 1 + i
  end repeat
  return(tA)
  exit
end

on setFilm(me, tFilm)
  pFilm = tFilm
  me.getInterface().setButtonHilites()
  me.getInterface().updateFilm()
  exit
end

on getFilm(me)
  return(pFilm)
  exit
end

on setItemData(me, tMsg)
  pItemId = tMsg.getAt(#id)
  tLine1 = tMsg.getAt(#text).getProp(#line, 1)
  tAuthId = tLine1.getProp(#word, 1)
  pPhotoTime = tLine1.getProp(#word, 2, tLine1.count(#word))
  pPhotoText = tMsg.getAt(#text).getProp(#line, 2, tMsg.getAt(#text).count(#line))
  pPhotoText = me.convertScandinavian(pPhotoText)
  unregisterMessage(symbol("itemdata_received" & pItemId), me.getID())
  if pLocX > 500 then
    pLocX = 500
  end if
  if pLocY < 100 then
    pLocY = 100
  end if
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  if not createWindow(pWindowID) then
    return(0)
  end if
  tWndObj = getWindow(pWindowID)
  tWndObj.merge("photo_window.window")
  tWndObj.moveTo(pLocX, pLocY)
  tWndObj.registerProcedure(#eventProcPhotoMouseDown, me.getID(), #mouseDown)
  if pPhotoCache.getaProp(pPhotoId) = void() then
    retrieveBinaryData(pItemId, tAuthId, me.getID())
  else
    me.binaryDataReceived(pPhotoCache.getaProp(pPhotoId), pPhotoId)
  end if
  towner = getObject(#session).GET("room_owner")
  tCanRemovePhotos = getObject(#session).GET("user_rights").getOne("fuse_remove_photos")
  if not towner and not tCanRemovePhotos then
    tWndObj.getElement("photo_remove").setProperty(#visible, 0)
  end if
  exit
end

on convertScandinavian(me, tString)
  if tString.length < 6 then
    return(tString)
  end if
  tEncArray = ["&AUML;":"�", "&OUML;":"�", "&auml;":"�", "&ouml;":"�"]
  tOutputStr = ""
  i = 1
  repeat while i <= tString.length
    tChar = tString.getProp(#char, i)
    if not tChar = "&" then
    else
      tChunkArr = chars(tString, i, i + 5)
      tChunkScan = getaProp(tEncArray, tChunkArr)
      if tChunkScan <> void() then
        i = i + 5
      else
      end if
    end if
    i = 1 + i
  end repeat
  return(tOutputStr)
  exit
end

on eventProcPhotoMouseDown(me, tEvent, tElemID, tParam)
  if me = "photo_close" then
    removeWindow(pWindowID)
  else
    if me = "photo_remove" then
      if getThread("room").getComponent().getRoomConnection().send("REMOVEITEM", [#integer:integer(pItemId)]) then
        removeWindow(pWindowID)
      end if
    end if
  end if
  exit
end