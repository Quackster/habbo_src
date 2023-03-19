property pDate, pPackageID, pCardWndID, pNoIconPlaceholderName, pIconType, pIconCode, pIconColor

on construct me
  pDate = EMPTY
  pPackageID = EMPTY
  pCardWndID = "Card" && getUniqueID()
  pNoIconPlaceholderName = "icon_placeholder"
  registerMessage(#leaveRoom, me.getID(), #hideCard)
  registerMessage(#changeRoom, me.getID(), #hideCard)
  pIconType = VOID
  pIconCode = VOID
  pIconColor = VOID
  return 1
end

on deconstruct me
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  return 1
end

on define me, tProps
  pPackageID = tProps[#id]
  pDate = tProps[#date]
  me.showCard(tProps[#loc] + [0, -220])
  return 1
end

on showCard me, tloc
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  if voidp(tloc) then
    tloc = [100, 100]
  end if
  if tloc[1] > ((the stage).rect.width - 260) then
    tloc[1] = (the stage).rect.width - 260
  end if
  if tloc[2] < 2 then
    tloc[2] = 2
  end if
  if not createWindow(pCardWndID, "ecotron_box_card.window", tloc[1], tloc[2]) then
    return 0
  end if
  tWndObj = getWindow(pCardWndID)
  if tWndObj = 0 then
    return 0
  end if
  tUserRights = getObject(#session).GET("user_rights")
  tUserCanOpen = getObject(#session).GET("room_owner") or tUserRights.findPos("fuse_pick_up_any_furni")
  if not tUserCanOpen and (tWndObj.getElement("eco_box_open") <> 0) then
    tWndObj.getElement("eco_box_open").hide()
  end if
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcCard, me.getID(), #mouseUp)
  me.setText(getText("eco_box_card"), "eco_box_text")
  me.setText(pDate, "eco_box_date")
  return 1
end

on setText me, tText, tElem
  tWndObj = getWindow(pCardWndID)
  if not tWndObj then
    return 0
  end if
  if tWndObj.elementExists(tElem) then
    tWndObj.getElement(tElem).setText(tText)
  end if
end

on hideCard me
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  return 1
end

on openPresent me
  return getThread(#room).getComponent().getRoomConnection().send("PRESENTOPEN", [#integer: integer(pPackageID)])
end

on showContent me, tdata
  if not windowExists(pCardWndID) then
    return 0
  end if
  pIconType = tdata[#type]
  pIconCode = tdata[#code]
  pIconColor = tdata[#color]
  tMemNum = VOID
  if pIconColor = EMPTY then
    pIconColor = VOID
  end if
  case pIconType of
    "ticket":
      tMemNum = getmemnum("ticket_icon")
    "film":
      tMemNum = getmemnum("film_icon")
  end case
  if pIconType contains "*" then
    tDelim = the itemDelimiter
    the itemDelimiter = "*"
    pIconType = pIconType.item[1]
    the itemDelimiter = tDelim
  end if
  if memberExists(pIconCode & "_small") then
    tMemNum = getmemnum(pIconCode & "_small")
  else
    if memberExists("ctlg_pic_small_" & pIconCode) then
      tMemNum = getmemnum("ctlg_pic_small_" & pIconCode)
    end if
  end if
  if tMemNum = 0 then
    tDynThread = getThread(#dynamicdownloader)
    if tDynThread = 0 then
      tImg = getObject("Preview_renderer").renderPreviewImage(VOID, VOID, pIconColor, pIconType)
    else
      tDownloadIdName = EMPTY
      if pIconType contains "poster" then
        tDownloadIdName = pIconCode
      else
        tDownloadIdName = pIconType
      end if
      tDynComponent = tDynThread.getComponent()
      tRoomSizePrefix = EMPTY
      tRoomThread = getThread(#room)
      if tRoomThread <> 0 then
        tTileSize = tRoomThread.getInterface().getGeometry().getTileWidth()
        if tTileSize = 32 then
          tRoomSizePrefix = "s_"
        end if
      end if
      tDownloadIdName = tRoomSizePrefix & tDownloadIdName
      if not tDynComponent.isAssetDownloaded(tDownloadIdName) then
        tDynComponent.downloadCastDynamically(tDownloadIdName, #unknown, me.getID(), #packetIconDownloadCallback, 1)
        tImg = member(pNoIconPlaceholderName).image
      else
        me.packetIconDownloadCallback(tDownloadIdName)
      end if
    end if
  else
    tImg = member(tMemNum).image.duplicate()
  end if
  me.feedIconToCard(tImg)
  me.setText(tdata[#name], "eco_box_text")
end

on packetIconDownloadCallback me, tDownloadedClass
  if tDownloadedClass contains "poster" then
    tImg = getObject("Preview_renderer").renderPreviewImage(VOID, VOID, pIconColor, pIconCode)
  else
    tImg = getObject("Preview_renderer").renderPreviewImage(VOID, VOID, pIconColor, pIconType)
  end if
  me.feedIconToCard(tImg)
end

on feedIconToCard me, tImg
  if ilk(tImg) <> #image then
    return error(me, "tImg is not an #image", #feedIconToCard, #minor)
  end if
  tWndObj = getWindow(pCardWndID)
  if tWndObj = 0 then
    me.showCard()
    tWndObj = getWindow(pCardWndID)
    if tWndObj = 0 then
      return 0
    end if
  end if
  tElem = tWndObj.getElement("eco_box_preview")
  if tElem = 0 then
    return 0
  end if
  tWid = tElem.getProperty(#width)
  tHei = tElem.getProperty(#height)
  tCenteredImage = image(tWid, tHei, 32)
  tMatte = tImg.createMatte()
  tXchange = (tCenteredImage.width - tImg.width) / 2
  tYchange = (tCenteredImage.height - tImg.height) / 2
  tRect1 = tImg.rect + rect(tXchange, tYchange, tXchange, tYchange)
  tCenteredImage.copyPixels(tImg, tRect1, tImg.rect, [#maskImage: tMatte, #ink: 41])
  tElem.feedImage(tCenteredImage)
  tWndObj.getElement("eco_box_open").hide()
end

on eventProcCard me, tEvent, tElemID, tParam
  if tEvent <> #mouseUp then
    return 0
  end if
  case tElemID of
    "eco_box_close":
      return me.hideCard()
    "eco_box_open":
      return me.openPresent()
  end case
end
