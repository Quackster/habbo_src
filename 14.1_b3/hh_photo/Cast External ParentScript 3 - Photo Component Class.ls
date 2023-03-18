property pPhotoCache, pPhotoWindow, pWindowID, pItemId, pPhotoId, pLastPhotoData, pLocX, pLocY, pPhotoMember, pFilm, pPhotoTime, pPhotoText

on construct me
  pWindowID = #photo_window
  pPhotoCache = [:]
  pPhotoMember = VOID
  createWriter(#photo_timestamp_writer_black, [#color: rgb(0, 0, 0)])
  createWriter(#photo_timestamp_writer_white, [#color: rgb(255, 255, 240)])
  return 1
end

on deconstruct me
  if pPhotoMember.ilk = #member then
    removeMember(pPhotoMember.name)
    pPhotoMember = VOID
  end if
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  removeWriter(#photo_timestamp_writer_black)
  removeWriter(#photo_timestamp_writer_white)
  return 1
end

on storePicture me, tmember, tText
  if not voidp(tText) then
    tText = getStringServices().convertSpecialChars(tText, 1)
  end if
  tCS = me.countCS(tmember.image)
  tdata = [#image: tmember.media, #time: the date && the time, #cs: tCS]
  addMessageToBinaryQueue("PHOTOTXT /" & tText)
  storeBinaryData(tdata, me.getID())
  pLastPhotoData = tdata
end

on binaryDataStored me, tid
  me.getInterface().saveOk()
  pPhotoCache.setaProp(tid, pLastPhotoData)
  pLastPhotoData = VOID
end

on binaryDataReceived me, tdata, tid
  if ilk(tdata) <> #propList then
    return 0
  end if
  if tdata[#image] = VOID then
    return 0
  end if
  tText = pPhotoText
  pPhotoCache.setaProp(tid, tdata)
  if not windowExists(pWindowID) then
    return 0
  end if
  getWindow(pWindowID).getElement("photo_text").setText(tText)
  if pPhotoMember.ilk <> #member then
    pPhotoMember = member(createMember(getUniqueID(), #bitmap))
  end if
  pPhotoMember.media = tdata[#image]
  if tdata[#cs] <> VOID then
    tCheckSumOk = me.countCS(pPhotoMember.image) = tdata[#cs]
  else
    tCheckSumOk = 0
  end if
  if tCheckSumOk = 0 then
    pPhotoMember.media = member(getmemnum("photo_invalid")).media
  else
    if (pPhotoTime <> VOID) and (length(pPhotoTime) > 5) then
      tBlackImg = getWriter(#photo_timestamp_writer_black).render(pPhotoTime)
      tWhiteImg = getWriter(#photo_timestamp_writer_white).render(pPhotoTime)
      tL = pPhotoMember.image.width - 3 - tBlackImg.width
      tt = pPhotoMember.image.height - 3 - tBlackImg.height
      tR = rect(tL, tt, tL + tBlackImg.width, tt + tBlackImg.height)
      pPhotoMember.image.copyPixels(tBlackImg, tR + rect(-1, 0, -1, 0), tBlackImg.rect, [#ink: 36])
      pPhotoMember.image.copyPixels(tBlackImg, tR + rect(1, 0, 1, 0), tBlackImg.rect, [#ink: 36])
      pPhotoMember.image.copyPixels(tBlackImg, tR + rect(0, 1, 0, 1), tBlackImg.rect, [#ink: 36])
      pPhotoMember.image.copyPixels(tBlackImg, tR + rect(0, -1, 0, -1), tBlackImg.rect, [#ink: 36])
      pPhotoMember.image.copyPixels(tWhiteImg, tR, tBlackImg.rect, [#ink: 36])
    end if
  end if
  getWindow(pWindowID).getElement("photo_picture").setProperty(#buffer, pPhotoMember)
end

on openPhoto me, tItemID, tLocX, tLocY
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  pLocX = tLocX
  pLocY = tLocY
  registerMessage(symbol("itemdata_received" & tItemID), me.getID(), #setItemData)
  getConnection(getVariable("connection.room.id")).send("G_IDATA", tItemID)
end

on countCS me, tImg
  tL = [3, 2, 73, 28, 83, 21, 43, 90, 92, 91, 37, 4, 3, 84, 12, 102, 103, 108, 97, 43, 44, 89, 109, 65, 61, -4, 76]
  tA = 0
  tW = tImg.width
  tH = tImg.height
  repeat with i = 1 to 100
    tA = (tA + (tImg.getPixel(i mod tW, i * i mod tH).paletteIndex * tL[(i mod tL.count) + 1])) mod 85000
  end repeat
  return tA
end

on setFilm me, tFilm
  pFilm = tFilm
  me.getInterface().setButtonHilites()
  me.getInterface().updateFilm()
end

on getFilm me
  return pFilm
end

on setItemData me, tMsg
  pItemId = tMsg[#id]
  pPhotoId = tMsg[#text].line[1].word[1]
  tAuthId = tMsg[#text].line[1].word[2]
  pPhotoTime = tMsg[#text].line[1].word[3..4]
  pPhotoText = tMsg[#text].line[2..tMsg[#text].line.count]
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
    return 0
  end if
  tWndObj = getWindow(pWindowID)
  tWndObj.merge("photo_window.window")
  tWndObj.moveTo(pLocX, pLocY)
  tWndObj.registerProcedure(#eventProcPhotoMouseDown, me.getID(), #mouseDown)
  if pPhotoCache.getaProp(pPhotoId) = VOID then
    retrieveBinaryData(pPhotoId, tAuthId, me.getID())
  else
    me.binaryDataReceived(pPhotoCache.getaProp(pPhotoId), pPhotoId)
  end if
  tOwner = getObject(#session).GET("room_owner")
  tCanRemovePhotos = getObject(#session).GET("user_rights").getOne("fuse_remove_photos")
  if not tOwner and not tCanRemovePhotos then
    tWndObj.getElement("photo_remove").setProperty(#visible, 0)
  end if
end

on convertScandinavian me, tString
  if tString.length < 6 then
    return tString
  end if
  tEncArray = ["&AUML;": "Ä", "&OUML;": "…", "&auml;": "Š", "&ouml;": "š"]
  tOutputStr = EMPTY
  repeat with i = 1 to tString.length
    tChar = tString.char[i]
    if not (tChar = "&") then
      put tChar after tOutputStr
      next repeat
    end if
    tChunkArr = chars(tString, i, i + 5)
    tChunkScan = getaProp(tEncArray, tChunkArr)
    if tChunkScan <> VOID then
      put tChunkScan after tOutputStr
      i = i + 5
      next repeat
    end if
    put "&" after tOutputStr
  end repeat
  return tOutputStr
end

on eventProcPhotoMouseDown me, tEvent, tElemID, tParam
  case tElemID of
    "photo_close":
      removeWindow(pWindowID)
    "photo_remove":
      if getThread("room").getComponent().getRoomConnection().send("REMOVEITEM", pItemId) then
        removeWindow(pWindowID)
      end if
  end case
end
