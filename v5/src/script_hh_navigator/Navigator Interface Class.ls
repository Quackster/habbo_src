property pWindowTitle, pLastClickedUnitId, pFlatInfoAction, pCurrentFlatData, pResourcesReady, pWriterPlainBoldCent, pWriterPlainNormWrap, pWriterPrivPlain, pListItemHeight, pWriterPrivUnder, pPublicListWidth, pBufferDepth, pPublicDotLineImg, pWriterUnderNormLeft, PHotelEntryImg, pFlatGoTextImg, pWriterPlainNormLeft, pWriterPlainBoldLeft, pUnitList, pUnitDrawObjs, pVisibleFlatCount, pPublicListHeight, pPublicUnitsImg, pPrivateDropMode, pOpenWindow, pCachedFlatImg, pPrivateListImg, pFlatPasswords, pLastFlatSearch, pFlatsPerView, pFlatList

on construct me 
  pWindowTitle = getText("navigator", "Hotel Navigator")
  pFlatPasswords = [:]
  pUnitDrawObjs = [:]
  pUnitList = [:]
  pFlatList = [:]
  pVisibleFlatCount = 0
  pPublicListWidth = 251
  pPublicListHeight = 1
  pListItemHeight = 10
  pOpenWindow = #nothing
  pLastFlatSearch = ""
  pPrivateDropMode = "nav_rooms_popular"
  pCachedFlatImg = 0
  pBufferDepth = 32
  pFlatInfoAction = 0
  pFlatsPerView = getIntVariable("navigator.private.count", 40)
  pResourcesReady = 0
  return(me.createImgResources())
end

on deconstruct me 
  if windowExists(#login_a) then
    removeWindow(#login_a)
  end if
  if windowExists(#login_b) then
    removeWindow(#login_b)
  end if
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
  if timeoutExists(#login_blinker) then
    removeTimeout(#login_blinker)
  end if
  me.removeImgResources()
  removeObject(#navigator_login)
  return TRUE
end

on getLogin me 
  tid = #navigator_login
  if not objectExists(tid) then
    createObject(tid, "Login Dialogs Class")
  end if
  return(getObject(tid))
end

on showNavigator me 
  if windowExists(pWindowTitle) then
    getWindow(pWindowTitle).show()
  else
    if me.ChangeWindowView("nav_public_start.window") then
      pPrivateDropMode = "nav_rooms_popular"
      me.delay(2, #renderUnitList)
      return TRUE
    end if
  end if
  return FALSE
end

on hideNavigator me, tHideOrRemove 
  if voidp(tHideOrRemove) then
    tHideOrRemove = #remove
  end if
  if windowExists(pWindowTitle) then
    if (tHideOrRemove = #remove) then
      removeWindow(pWindowTitle)
    else
      getWindow(pWindowTitle).hide()
    end if
  end if
  return TRUE
end

on showhidenavigator me, tHideOrRemove 
  if voidp(tHideOrRemove) then
    tHideOrRemove = #remove
  end if
  if windowExists(pWindowTitle) then
    if getWindow(pWindowTitle).getProperty(#visible) then
      me.hideNavigator(tHideOrRemove)
    else
      getWindow(pWindowTitle).show()
    end if
  else
    pPrivateDropMode = "nav_rooms_popular"
    me.getComponent().getUnitUpdates()
    if not voidp(pLastClickedUnitId) then
      me.ChangeWindowView("nav_public_info.window")
      me.CreatepublicRoomInfo(pLastClickedUnitId)
    else
      me.ChangeWindowView("nav_public_start.window")
    end if
  end if
end

on showDisconnectionDialog me 
  me.hideNavigator()
  createWindow(#error, "error.window", 0, 0, #modal)
  tWndObj = getWindow(#error)
  tWndObj.getElement("error_title").setText(getText("Alert_ConnectionFailure"))
  tWndObj.getElement("error_text").setText(getText("Alert_ConnectionDisconnected"))
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcDisconnect, me.getID(), #mouseUp)
  the keyboardFocusSprite = 0
end

on saveFlatInfo me, tFlatData 
  pCurrentFlatData = tFlatData
  if (pFlatInfoAction = #enterflat) then
    tFlatPort = pCurrentFlatData.getAt(#port)
    pCurrentFlatData.setAt(#ip, me.getComponent().getFlatIp(tFlatPort))
    if (pCurrentFlatData.getAt(#owner) = getObject(#session).get("user_name")) then
      tDoor = "open"
    else
      tDoor = pCurrentFlatData.getAt(#door)
      pFlatPasswords = [:]
    end if
    if pFlatInfoAction <> "open" then
      if (pFlatInfoAction = "closed") then
        if voidp(pCurrentFlatData) then
          return(error(me, "Can't enter flat, no room is selected!!!", #saveFlatInfo))
        end if
        me.getComponent().updateState("enterFlat", pCurrentFlatData.getAt(#id))
      else
        if (pFlatInfoAction = "password") then
          me.ChangeWindowView("nav_private_password.window")
          getWindow(pWindowTitle).getElement("nav_roomname_text").setText(pCurrentFlatData.getAt(#name))
          me.CreatePrivateRoomInfo(pCurrentFlatData)
        end if
      end if
      pFlatInfoAction = 0
      if (pFlatInfoAction = #flatInfo) then
        me.ChangeWindowView("nav_private_info.window")
        me.CreatePrivateRoomInfo(pCurrentFlatData)
        pFlatInfoAction = 0
      else
        if (pFlatInfoAction = #modifyInfo) then
          me.modifyPrivateRoom(pCurrentFlatData)
          pFlatInfoAction = 0
        else
          error(me, "Unknown action:" && pFlatInfoAction, #saveFlatInfo)
        end if
      end if
    end if
  end if
end

on createImgResources me 
  if pResourcesReady then
    return FALSE
  end if
  tPlain = getStructVariable("struct.font.plain")
  tBold = getStructVariable("struct.font.bold")
  tLink = getStructVariable("struct.font.link")
  pListItemHeight = (tPlain.getaProp(#lineHeight) + 4)
  createWriter("nav_plain_norm_left", tPlain)
  pWriterPlainNormLeft = getWriter("nav_plain_norm_left")
  createWriter("nav_plain_bold_left", tBold)
  pWriterPlainBoldLeft = getWriter("nav_plain_bold_left")
  createWriter("nav_under_norm_left", tLink)
  pWriterUnderNormLeft = getWriter("nav_under_norm_left")
  createWriter("nav_plain_bold_cent", tBold)
  pWriterPlainBoldCent = getWriter("nav_plain_bold_cent")
  pWriterPlainBoldCent.define([#alignment:#center])
  createWriter("nav_plain_norm_wrap", tPlain)
  pWriterPlainNormWrap = getWriter("nav_plain_norm_wrap")
  pWriterPlainNormWrap.define([#wordWrap:1])
  createWriter("nav_private_plain", tPlain)
  pWriterPrivPlain = getWriter("nav_private_plain")
  pWriterPrivPlain.define([#boxType:#adjust, #wordWrap:1, #fixedLineSpace:pListItemHeight])
  createWriter("nav_private_under", tLink)
  pWriterPrivUnder = getWriter("nav_private_under")
  pWriterPrivUnder.define([#boxType:#adjust, #wordWrap:0, #fixedLineSpace:pListItemHeight])
  pPublicDotLineImg = image(pPublicListWidth, 1, pBufferDepth)
  tXPoint = 0
  repeat while tXPoint <= (pPublicListWidth / 2)
    pPublicDotLineImg.setPixel((tXPoint * 2), 0, rgb(0, 0, 0))
    tXPoint = (1 + tXPoint)
  end repeat
  pFlatGoTextImg = pWriterUnderNormLeft.render(getText("nav_gobutton")).duplicate()
  tTempImg = pWriterUnderNormLeft.render(getText("nav_hotelview"))
  PHotelEntryImg = image(pPublicListWidth, tTempImg.height, pBufferDepth)
  x1 = 5
  x2 = (x1 + tTempImg.width)
  y1 = 0
  y2 = tTempImg.height
  tdestrect = rect(x1, y1, x2, y2)
  PHotelEntryImg.copyPixels(tTempImg, tdestrect, tTempImg.rect)
  x1 = x2
  y1 = (PHotelEntryImg.height - 1)
  x2 = (PHotelEntryImg.width - 5)
  y2 = (y1 + 1)
  tdestrect = rect(x1, y1, x2, y2)
  tSourceRect = rect(0, 0, (x2 - x1), 1)
  PHotelEntryImg.copyPixels(pPublicDotLineImg, tdestrect, tSourceRect)
  x1 = ((PHotelEntryImg.width - pFlatGoTextImg.width) + 2)
  y1 = 0
  x2 = (x1 + pFlatGoTextImg.width)
  y2 = (y1 + pFlatGoTextImg.height)
  tdestrect = rect(x1, y1, x2, y2)
  PHotelEntryImg.copyPixels(pFlatGoTextImg, tdestrect, pFlatGoTextImg.rect)
  pResourcesReady = 1
  return TRUE
end

on removeImgResources me 
  if not pResourcesReady then
    return FALSE
  end if
  removeWriter(pWriterPlainNormLeft.getID())
  pWriterPlainNormLeft = void()
  removeWriter(pWriterPlainBoldLeft.getID())
  pWriterPlainBoldLeft = void()
  removeWriter(pWriterUnderNormLeft.getID())
  pWriterUnderNormLeft = void()
  removeWriter(pWriterPlainBoldCent.getID())
  pWriterPlainBoldCent = void()
  removeWriter(pWriterPlainNormWrap.getID())
  pWriterPlainNormWrap = void()
  removeWriter(pWriterPrivPlain.getID())
  pWriterPrivPlain = void()
  removeWriter(pWriterPrivUnder.getID())
  pWriterPrivUnder = void()
  pResourcesReady = 0
  return TRUE
end

on createUnitlist me, tUnitlist 
  pUnitList = [:]
  f = 1
  repeat while f <= tUnitlist.count()
    me.UpdateListOfUnits(tUnitlist.getPropAt(f), tUnitlist.getAt(tUnitlist.getPropAt(f)), #closed)
    f = (1 + f)
  end repeat
  f = 1
  repeat while f <= pUnitList.count
    tUnitid = pUnitList.getPropAt(f)
    tUnitName = pUnitList.getAt(pUnitList.getPropAt(f)).getAt(#name)
    if voidp(pUnitDrawObjs.getAt(tUnitid)) then
      tProps = [:]
      tProps.setAt(#id, tUnitid)
      tProps.setAt(#name, tUnitName)
      tProps.setAt(#height, pListItemHeight)
      tProps.setAt(#dotline, pPublicDotLineImg)
      tProps.setAt(#number, 666)
      tObject = createObject(#temp, "Draw Unit Class")
      tObject.define(tProps)
      pUnitDrawObjs.addProp(tUnitid, tObject)
    end if
    if (pUnitList.getAt(f).getAt(#visible) = 1) then
      pVisibleFlatCount = (pVisibleFlatCount + 1)
    end if
    f = (1 + f)
  end repeat
  me.renderUnitList()
end

on UpdateUnitList me, tUnitlist 
  f = 1
  repeat while f <= tUnitlist.count()
    me.UpdateListOfUnits(tUnitlist.getPropAt(f), tUnitlist.getAt(tUnitlist.getPropAt(f)), void())
    f = (1 + f)
  end repeat
  me.renderUnitList()
end

on UpdateListOfUnits me, tUnitid, tUnitData, tstate 
  tUnit = tUnitData
  if voidp(tstate) then
    if not voidp(pUnitList.getAt(tUnitid).getAt(#multiroomOpen)) then
      tstate = pUnitList.getAt(tUnitid).getAt(#multiroomOpen)
    else
      tstate = #closed
    end if
  end if
  if (tUnitData.getAt(#subunitcount) = 0) then
    tUnit.setAt(#type, #subUnit)
    if not voidp(tUnit.getAt(#mymainunitid)) then
      tMyMainId = tUnit.getAt(#mymainunitid)
    else
      return FALSE
    end if
    if not voidp(pUnitList.getAt(tMyMainId)) then
      if (pUnitList.getAt(tMyMainId).getAt(#multiroomOpen) = #open) then
        tUnit.setAt(#visible, 1)
      else
        tUnit.setAt(#visible, 0)
      end if
    else
      tUnit.setAt(#visible, 0)
    end if
  else
    if (tUnitData.getAt(#subunitcount) = 1) then
      tUnit.setAt(#type, #mainUnit)
      tUnit.setAt(#visible, 1)
    else
      if tUnitData.getAt(#subunitcount) > 1 then
        tUnit.setAt(#type, #MultiUnit)
        tUnit.setAt(#visible, 1)
        tUnit.setAt(#multiroomOpen, tstate)
      end if
    end if
  end if
  pUnitList.setAt(tUnitid, tUnit)
end

on renderUnitList me 
  tWndObj = getWindow(pWindowTitle)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElement = tWndObj.getElement("nav_public_rooms_list")
  if (tElement = 0) then
    return FALSE
  end if
  pVisibleFlatCount = 0
  f = 1
  repeat while f <= pUnitList.count()
    tUnitid = pUnitList.getPropAt(f)
    if (pUnitList.getAt(tUnitid).getAt(#visible) = 1) then
      pVisibleFlatCount = (pVisibleFlatCount + 1)
      pUnitDrawObjs.getAt(tUnitid).setProp(#pPropList, #number, pVisibleFlatCount)
    end if
    f = (1 + f)
  end repeat
  if pPublicListHeight <> ((pVisibleFlatCount + 1) * pListItemHeight) then
    pPublicListHeight = ((pVisibleFlatCount + 1) * pListItemHeight)
    pPublicUnitsImg = image(pPublicListWidth, pPublicListHeight, pBufferDepth)
  end if
  pPublicUnitsImg.copyPixels(PHotelEntryImg, PHotelEntryImg.rect, PHotelEntryImg.rect)
  call(#render, pUnitDrawObjs, pPublicUnitsImg)
  tElement.feedImage(pPublicUnitsImg)
end

on getUnitData me, tUnitName 
  return(pUnitList.getAt(tUnitName))
end

on ChangeWindowView me, tWindowName 
  tWndObj = getWindow(pWindowTitle)
  tScrollOffset = 0
  if tWndObj <> 0 then
    if tWindowName contains "public" and tWndObj.elementExists("scroll_public") then
      tScrollOffset = tWndObj.getElement("scroll_public").getScrollOffset()
    end if
    tWndObj.unmerge()
  else
    if not createWindow(pWindowTitle, "habbo_basic.window", 382, 73) then
      return(error(me, "Failed to create window for Navigator!", #ChangeWindowView))
    end if
    tWndObj = getWindow(pWindowTitle)
    tWndObj.registerClient(me.getID())
  end if
  tWndObj.merge(tWindowName)
  pOpenWindow = tWindowName
  if tWindowName contains "public" then
    tWndObj.registerProcedure(#eventProcNavigatorPublic, me.getID(), #mouseDown)
    tWndObj.registerProcedure(#eventProcNavigatorPublic, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcNavigatorPublic, me.getID(), #keyDown)
    if not voidp(pPublicUnitsImg) and tWndObj.elementExists("nav_public_rooms_list") then
      tWndObj.getElement("nav_public_rooms_list").feedImage(pPublicUnitsImg)
      if tScrollOffset > 0 and tWndObj.elementExists("scroll_public") then
        tWndObj.getElement("scroll_public").setScrollOffset(tScrollOffset)
      end if
    end if
  else
    if tWindowName contains "private" then
      tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #mouseDown)
      tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #keyDown)
      if pPrivateDropMode <> "nav_rooms_search" then
        me.searchPrivateRooms(0)
      end if
      if tWndObj.elementExists("nav_private_dropdown") then
        tWndObj.getElement("nav_private_dropdown").setSelection(pPrivateDropMode)
      end if
    else
      return(error(me, "Couldn't solve Navigator's state:" && tWindowName, #ChangeWindowView))
    end if
  end if
  return TRUE
end

on renderLoadingText me, tTempElementId 
  if voidp(tTempElementId) then
    return FALSE
  end if
  tElem = getWindow(pWindowTitle).getElement(tTempElementId)
  tWidth = tElem.getProperty(#width)
  tHeight = tElem.getProperty(#height)
  tTempImg = image(tWidth, tHeight, pBufferDepth)
  tTextImg = pWriterPlainBoldCent.render(getText("loading"))
  tOffX = ((tWidth - tTextImg.width) / 2)
  tOffY = ((tHeight - tTextImg.height) / 2)
  tDstRect = (tTextImg.rect + rect(tOffX, tOffY, tOffX, tOffY))
  tTempImg.copyPixels(tTextImg, tDstRect, tTextImg.rect)
  tElem.feedImage(tTempImg)
  return TRUE
end

on updateUnitUsers me, tUsersStr 
  if (pOpenWindow = "nav_public_people.window") then
    tWndObj = getWindow(pWindowTitle)
    if tWndObj.elementExists("nav_people_list") then
      tElem = tWndObj.getElement("nav_people_list")
      tWidth = tElem.getProperty(#width)
      tHeight = tElem.getProperty(#height)
      pWriterPlainNormWrap.define([#rect:rect(0, 0, tWidth, 0)])
      tImage = pWriterPlainNormWrap.render(tUsersStr).duplicate()
      if tWndObj.elementExists("scroll_people_list") then
        if tHeight > tImage.height then
          tWndObj.getElement("scroll_people_list").hide()
        else
          tWndObj.getElement("scroll_people_list").show()
        end if
      end if
      tElem.feedImage(tImage)
    end if
  end if
end

on GetUnitUsers me, tUnitid 
  if not voidp(tUnitid) then
    if pOpenWindow <> "nav_public_people.window" then
      me.ChangeWindowView("nav_public_people.window")
    end if
    if (pUnitList.getAt(tUnitid).getAt(#type) = #subUnit) then
      tMainUnitID = pUnitList.getAt(tUnitid).getAt(#mymainunitid)
      tMainUnitName = pUnitList.getAt(tMainUnitID).getAt(#name)
      me.getComponent().GetUnitUsers(tMainUnitName, pUnitList.getAt(tUnitid).getAt(#name))
    else
      me.getComponent().GetUnitUsers(pUnitList.getAt(tUnitid).getAt(#name), void())
    end if
  end if
end

on CreatepublicRoomInfo me, tUnitid 
  if voidp(tUnitid) then
    return(error(me, "Cant create room info because unitID is VOID", #CreatepublicRoomInfo))
  end if
  if pOpenWindow <> "nav_public_info.window" then
    me.ChangeWindowView("nav_public_info.window")
  end if
  tWndObj = getWindow(pWindowTitle)
  tElem = tWndObj.getElement("nav_roominfo")
  if (tElem = 0) then
    return FALSE
  end if
  tInfo = getText("nav_roominfo_" & tUnitid, "")
  tWidth = tElem.getProperty(#width)
  pWriterPlainNormWrap.define([#rect:rect(0, 0, tWidth, 0)])
  tImage = pWriterPlainNormWrap.render(tInfo).duplicate()
  tElem.feedImage(tImage)
  tIconName = getVariable("thumb." & tUnitid)
  if memberExists(tIconName) then
    tIconMemNum = getmemnum(tIconName)
    if tIconMemNum <> 0 then
      tWndObj.getElement("public_room_icon").feedImage(member(tIconMemNum).image)
    else
      tWndObj.getElement("public_room_icon").clearImage()
    end if
  end if
end

on saveFlatList me, tFlats, tMode 
  pFlatList = tFlats
  if not pOpenWindow contains "private" then
    return FALSE
  end if
  tWndObj = getWindow(pWindowTitle)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElement = tWndObj.getElement("nav_private_rooms_list")
  if (tElement = 0) then
    return FALSE
  end if
  if (tMode = #cached) then
    if pCachedFlatImg <> 0 then
      pPrivateListImg = pCachedFlatImg
      tElement.feedImage(pPrivateListImg)
      return TRUE
    else
      tMode = #busy
    end if
  end if
  pBufferDepth = tElement.getProperty(#depth)
  tItemWidth = tElement.getProperty(#width)
  pPrivateListImg = image(tItemWidth, (tFlats.count() * pListItemHeight), pBufferDepth)
  tUsersTxt = ""
  tFlatstxt = ""
  tLockMemImgA = member(getmemnum("lock1")).image
  tLockMemImgB = member(getmemnum("lock2")).image
  f = 1
  repeat while f <= tFlats.count
    tFlat = tFlats.getAt(f)
    tUsersTxt = tUsersTxt & tFlat.getAt(#usercount) & "\r"
    tFlatstxt = tFlatstxt & tFlat.getAt(#name) & "\r"
    tSrcRect = rect(0, 0, (tItemWidth - 30), 1)
    tCurrLocY = (f * pListItemHeight)
    tDstRect = (tSrcRect + rect(20, (tCurrLocY - 1), 20, (tCurrLocY - 1)))
    pPrivateListImg.copyPixels(pPublicDotLineImg, tDstRect, tSrcRect)
    tDstRect = (pFlatGoTextImg.rect + rect((tItemWidth - pFlatGoTextImg.width), (tCurrLocY - pFlatGoTextImg.height), (tItemWidth - pFlatGoTextImg.width), (tCurrLocY - pFlatGoTextImg.height)))
    pPrivateListImg.copyPixels(pFlatGoTextImg, tDstRect, pFlatGoTextImg.rect)
    if tFlat.getAt(#door) <> "open" then
      if (tFlat.getAt(#door) = "closed") then
        tLockImg = tLockMemImgA
      else
        if (tFlat.getAt(#door) = "password") then
          tLockImg = tLockMemImgB
        else
          tLockImg = 0
        end if
      end if
      if tLockImg <> 0 then
        tSrcRect = tLockImg.rect
        tDstRect = (tSrcRect + rect(((tItemWidth - pFlatGoTextImg.width) - 20), (tCurrLocY - (tLockImg.height * 1.5)), ((tItemWidth - pFlatGoTextImg.width) - 20), (tCurrLocY - (tLockImg.height * 1.5))))
        pPrivateListImg.copyPixels(tLockImg, tDstRect, tSrcRect)
      end if
    end if
    f = (1 + f)
  end repeat
  tUsersTxt = tUsersTxt.getProp(#line, 1, (tUsersTxt.count(#line) - 1))
  tFlatstxt = tFlatstxt.getProp(#line, 1, (tFlatstxt.count(#line) - 1))
  tTempRoomNamesImg = pWriterPrivUnder.render(tFlatstxt)
  tTempUserCountImg = pWriterPrivPlain.render(tUsersTxt)
  tDstRect = (tTempUserCountImg.rect + rect(0, 0, 0, 0))
  pPrivateListImg.copyPixels(tTempUserCountImg, tDstRect, tTempUserCountImg.rect)
  tDstRect = (tTempRoomNamesImg.rect + rect(20, 0, 20, 0))
  pPrivateListImg.copyPixels(tTempRoomNamesImg, tDstRect, tTempRoomNamesImg.rect)
  if (tMode = #busy) then
    pCachedFlatImg = pPrivateListImg
  end if
  tElement.feedImage(pPrivateListImg)
  return TRUE
end

on CreatePrivateRoomInfo me, tRoomData 
  if listp(tRoomData) then
    pCurrentFlatData = tRoomData
  end if
  if voidp(pCurrentFlatData) then
    return(error(me, "Can't create flat info, 'pCurrentFlatData' is VOID!", #CreatePrivateRoomInfo))
  end if
  if voidp(pPrivateDropMode) then
    return(error(me, "Can't create flat info, 'pPrivateDropMode' is VOID!", #CreatePrivateRoomInfo))
  end if
  tWndObj = getWindow(pWindowTitle)
  if (tWndObj = 0) then
    return(error(me, "Window doesn't exist!", #CreatePrivateRoomInfo))
  end if
  if (pPrivateDropMode = "nav_rooms_favourite") then
    me.ChangeWindowView("nav_private_removefavorite.window")
  end if
  if voidp(pPrivateListImg) then
    error(me, "Invalid image buffer:" && pPrivateListImg, #CreatePrivateRoomInfo)
  else
    if tWndObj.elementExists("nav_private_rooms_list") then
      tWndObj.getElement("nav_private_rooms_list").feedImage(pPrivateListImg)
    end if
  end if
  if voidp(pCurrentFlatData.getAt(#name)) then
    pCurrentFlatData.setAt(#name, "-")
  end if
  if voidp(pCurrentFlatData.getAt(#usercount)) then
    pCurrentFlatData.setAt(#usercount, "-")
  end if
  if voidp(pCurrentFlatData.getAt(#owner)) then
    pCurrentFlatData.setAt(#owner, "-")
  end if
  if voidp(pCurrentFlatData.getAt(#description)) then
    pCurrentFlatData.setAt(#description, "-")
  end if
  tRoomName = pCurrentFlatData.getAt(#name) && "(" & tRoomData.getAt(#usercount) & "/25)" & "\r"
  tRoomName = tRoomName & getText("nav_owner") & ":" && pCurrentFlatData.getAt(#owner)
  tRoomInfo = pCurrentFlatData.getAt(#description)
  tElem = tWndObj.getElement("nav_room_name_owner")
  if tElem <> 0 then
    tWidth = tElem.getProperty(#width)
    tImage = pWriterPlainBoldLeft.render(tRoomName)
    tElem.feedImage(tImage)
  end if
  tElem = tWndObj.getElement("nav_roominfo")
  if tElem <> 0 then
    tWidth = tElem.getProperty(#width)
    pWriterPlainNormWrap.define([#rect:rect(0, 0, tWidth, 0)])
    tImage = pWriterPlainNormWrap.render(tRoomInfo)
    tElem.feedImage(tImage)
  end if
  if tWndObj.elementExists("nav_door_icon") then
    if voidp(pCurrentFlatData.getAt(#door)) then
      return FALSE
    end if
    if (pCurrentFlatData.getAt(#door) = "open") then
      tLockmem = "door_open"
    else
      if (pCurrentFlatData.getAt(#door) = "closed") then
        tLockmem = "door_closed"
      else
        if (pCurrentFlatData.getAt(#door) = "password") then
          tLockmem = "door_password"
        else
          return(error(me, "Saved flat data is not valid!", #CreatePrivateRoomInfo))
        end if
      end if
    end if
    if memberExists(tLockmem) then
      tDoorImg = member(getmemnum(tLockmem)).image
      tWndObj.getElement("nav_door_icon").feedImage(tDoorImg)
    end if
  end if
  if tWndObj.elementExists("nav_modify_button") and not voidp(tRoomData.getAt(#owner)) then
    if (tRoomData.getAt(#owner) = getObject(#session).get("user_name")) then
      tWndObj.getElement("nav_modify_button").show()
    else
      tWndObj.getElement("nav_modify_button").hide()
    end if
  end if
end

on modifyPrivateRoom me 
  pFlatPasswords = [:]
  if pCurrentFlatData.getAt(#owner) <> getObject(#session).get("user_name") then
    return FALSE
  end if
  me.ChangeWindowView("nav_private_modify.window")
  tWndObj = getWindow(pWindowTitle)
  tTempProps = [#name:"nav_modify_roomnamefield", #description:"nav_modify_roomdescription_field"]
  f = 1
  repeat while f <= tTempProps.count
    tProp = tTempProps.getPropAt(f)
    tField = tTempProps.getAt(tProp)
    if tWndObj.elementExists(tField) then
      if not voidp(pCurrentFlatData.getAt(tProp)) then
        tWndObj.getElement(tField).setText(pCurrentFlatData.getAt(tProp))
      end if
    end if
    f = (1 + f)
  end repeat
  tCheckOnImg = member(getmemnum("button.checkbox.on")).image
  tCheckOffImg = member(getmemnum("button.checkbox.off")).image
  if (pCurrentFlatData.getAt(#showownername) = 1) then
    me.updateRadioButton("nav_modify_nameshow_yes_radio", ["nav_modify_nameshow_no_radio"])
  else
    me.updateRadioButton("nav_modify_nameshow_no_radio", ["nav_modify_nameshow_yes_radio"])
  end if
  if (pCurrentFlatData.getAt(#door) = "open") then
    me.updateRadioButton("nav_modify_door_open_radio", ["nav_modify_door_locked_radio", "nav_modify_door_pw_radio"])
  else
    if (pCurrentFlatData.getAt(#door) = "closed") then
      me.updateRadioButton("nav_modify_door_locked_radio", ["nav_modify_door_open_radio", "nav_modify_door_pw_radio"])
    else
      if (pCurrentFlatData.getAt(#door) = "password") then
        me.updateRadioButton("nav_modify_door_pw_radio", ["nav_modify_door_open_radio", "nav_modify_door_locked_radio"])
      end if
    end if
  end if
  me.updateCheckButton("nav_modify_furnituremove_check", #ableothersmovefurniture, void())
end

on checkPasswords me 
  tElementId1 = "nav_modify_door_pw"
  tElementId2 = "nav_modify_door_pw2"
  if voidp(pFlatPasswords.getAt(tElementId1)) then
    tPw1 = []
  else
    tPw1 = pFlatPasswords.getAt(tElementId1)
  end if
  if voidp(pFlatPasswords.getAt(tElementId2)) then
    tPw2 = []
  else
    tPw2 = pFlatPasswords.getAt(tElementId2)
  end if
  if (tPw1.count = 0) then
    executeMessage(#alert, [#msg:"Alert_ForgotSetPassword"])
    return FALSE
  end if
  if tPw1.count < 3 then
    executeMessage(#alert, [#msg:"Alert_YourPasswordIstooShort"])
    return FALSE
  end if
  if tPw1 <> tPw2 then
    executeMessage(#alert, [#msg:"Alert_WrongPassword"])
    return FALSE
  end if
  return TRUE
end

on getPassword me, tElementId 
  tPw = ""
  if voidp(pFlatPasswords.getAt(tElementId)) then
    return("null")
  end if
  repeat while pFlatPasswords.getAt(tElementId) <= undefined
    f = getAt(undefined, tElementId)
    tPw = tPw & f
  end repeat
  return(tPw)
end

on updateRadioButton me, tElement, tListOfOthersElements 
  if voidp(pCurrentFlatData) then
    return(error(me, "Can't update radio buttons!", #updateRadioButton))
  end if
  tOnImg = member(getmemnum("button.radio.on")).image
  tOffImg = member(getmemnum("button.radio.off")).image
  tWndObj = getWindow(pWindowTitle)
  if tWndObj.elementExists(tElement) then
    tWndObj.getElement(tElement).feedImage(tOnImg)
  end if
  repeat while tListOfOthersElements <= tListOfOthersElements
    tRadioElement = getAt(tListOfOthersElements, tElement)
    if tWndObj.elementExists(tRadioElement) then
      tWndObj.getElement(tRadioElement).feedImage(tOffImg)
    end if
  end repeat
end

on updateCheckButton me, tElement, tProp, tChangeMode 
  if voidp(pCurrentFlatData) then
    return(error(me, "Can't update check buttons!", #updateCheckButton))
  end if
  tOnImg = member(getmemnum("button.checkbox.on")).image
  tOffImg = member(getmemnum("button.checkbox.off")).image
  tWndObj = getWindow(pWindowTitle)
  if voidp(pCurrentFlatData.getAt(tProp)) then
    pCurrentFlatData.setAt(tProp, 1)
  end if
  if voidp(tChangeMode) then
    tChangeMode = 0
  end if
  if tChangeMode then
    if (pCurrentFlatData.getAt(tProp) = 1) then
      pCurrentFlatData.setAt(tProp, 0)
    else
      pCurrentFlatData.setAt(tProp, 1)
    end if
  end if
  if (pCurrentFlatData.getAt(tProp) = 1) then
    if tWndObj.elementExists(tElement) then
      tWndObj.getElement(tElement).feedImage(tOnImg)
    end if
  else
    if tWndObj.elementExists(tElement) then
      tWndObj.getElement(tElement).feedImage(tOffImg)
    end if
  end if
end

on searchPrivateRooms me, tMode 
  if pOpenWindow contains "private" then
    tWndObj = getWindow(pWindowTitle)
    if not tWndObj.elementExists("nav_private_search_field") then
      return FALSE
    end if
    if (tMode = 1) then
      pPrivateDropMode = "nav_rooms_search"
      tWndObj.getElement("nav_private_dropdown").setSelection("nav_rooms_search")
      tElement = tWndObj.getElement("nav_private_search_field")
      tElement.setText("")
      tElement.setEdit(1)
      tElement.setProperty(#blend, 100)
      if tWndObj.elementExists("nav_private_button_search") then
        tWndObj.getElement("nav_private_button_search").Activate()
      end if
      if tWndObj.elementExists("nav_search_field_bg") then
        tWndObj.getElement("nav_search_field_bg").setProperty(#blend, 100)
      end if
    else
      pLastFlatSearch = ""
      tElement = tWndObj.getElement("nav_private_search_field")
      tElement.setText("")
      tElement.setEdit(0)
      tElement.setProperty(#blend, 30)
      if tWndObj.elementExists("nav_private_button_search") then
        tWndObj.getElement("nav_private_button_search").deactivate()
      end if
      if tWndObj.elementExists("nav_search_field_bg") then
        tWndObj.getElement("nav_search_field_bg").setProperty(#blend, 30)
      end if
    end if
  end if
end

on makePrivateRoomSearch me 
  tWndObj = getWindow(pWindowTitle)
  if tWndObj.elementExists("nav_private_search_field") then
    tSearchQuery = tWndObj.getElement("nav_private_search_field").getText()
    if pLastFlatSearch <> tSearchQuery then
      pLastFlatSearch = tSearchQuery
      if (tSearchQuery = "") then
        return(me.failedFlatSearch(getText("nav_prvrooms_notfound")))
      end if
      me.renderLoadingText("nav_private_rooms_list")
      me.getComponent().searchFlats(tSearchQuery)
    end if
  end if
end

on roomkioskGoingFlat me, tRoomId 
  pFlatInfoAction = #enterflat
  me.getComponent().getFlatInfo(tRoomId)
end

on failedFlatSearch me, tText 
  tElem = getWindow(pWindowTitle).getElement("nav_private_rooms_list")
  tWidth = tElem.getProperty(#width)
  tHeight = tElem.getProperty(#height)
  tTempImg = image(tWidth, tHeight, 8)
  tTextImg = pWriterPlainNormLeft.render(tText)
  tTempImg.copyPixels(tTextImg, (tTextImg.rect + rect(8, 5, 8, 5)), tTextImg.rect)
  tElem.feedImage(tTempImg)
end

on getFlatPassword me 
  if voidp(pCurrentFlatData) then
    return FALSE
  end if
  if pCurrentFlatData.getAt(#door) <> "password" then
    return FALSE
  end if
  if voidp(pCurrentFlatData.getAt(#password)) then
    return FALSE
  else
    return(pCurrentFlatData.getAt(#password))
  end if
end

on flatPasswordIncorrect me 
  me.ChangeWindowView("nav_private_pw_incorrect.window")
  getWindow(pWindowTitle).getElement("nav_roomname_text").setText(pCurrentFlatData.getAt(#name))
end

on roomlistupdate me 
  if not voidp(pOpenWindow) and windowExists(pWindowTitle) then
    if pOpenWindow contains "public" then
      me.getComponent().getUnitUpdates()
    else
      if pOpenWindow contains "private" then
        if (pPrivateDropMode = "nav_rooms_own") then
          me.getComponent().getOwnFlats()
        else
          if (pPrivateDropMode = "nav_rooms_popular") then
            me.getComponent().searchBusyFlats(0, pFlatsPerView, #update)
          else
            if (pPrivateDropMode = "nav_rooms_favourite") then
              me.getComponent().getFavouriteFlats()
            else
              if (pPrivateDropMode = "nav_rooms_search") then
                me.searchPrivateRooms(1)
              else
                return FALSE
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcNavigatorPublic me, tEvent, tSprID, tParm 
  if (tEvent = #mouseDown) then
    if (tSprID = "nav_private_tab") then
      me.ChangeWindowView("nav_private_start.window")
      pPrivateDropMode = "nav_rooms_popular"
      if not me.getComponent().searchBusyFlats(0, pFlatsPerView) then
        me.renderLoadingText("nav_private_rooms_list")
      end if
    else
      if (tSprID = "nav_public_rooms_list") then
        if not ilk(tParm, #point) or (pUnitList.count = 0) then
          return()
        end if
        if (pOpenWindow = "nav_public_start.window") then
          me.ChangeWindowView("nav_public_info.window")
        end if
        tClickLine = integer((tParm.locV / pListItemHeight))
        if tClickLine < 1 then
          tGoLinkArea = (pPublicListWidth - pFlatGoTextImg.width)
          if tParm.locH > tGoLinkArea then
            getConnection(getVariable("connection.info.id")).send(#room, "QUIT")
            return(me.getComponent().updateState("enterEntry"))
          else
            return TRUE
          end if
        end if
        if tClickLine > pVisibleFlatCount then
          tClickLine = pVisibleFlatCount
        end if
        call(#getClickedUnitName, pUnitDrawObjs, tClickLine)
        tClickedUnit = the result
        if not stringp(tClickedUnit) then
          return(error(me, "Navigator room list error", #eventProcNavigator))
        end if
        if voidp(pUnitList.getAt(tClickedUnit)) then
          return(error(me, "Unit data not found:" && tClickedUnit, #eventProcNavigator))
        end if
        pLastClickedUnitId = tClickedUnit
        tGoLinkH = (pPublicListWidth - pFlatGoTextImg.width)
        if tParm.locH > tGoLinkH and pUnitList.getAt(tClickedUnit).getAt(#type) <> #MultiUnit then
          return(me.getComponent().updateState("enterUnit", tClickedUnit))
        else
          if (pOpenWindow = "nav_public_info.window") then
            me.CreatepublicRoomInfo(tClickedUnit)
          else
            me.GetUnitUsers(tClickedUnit)
          end if
          if (pUnitList.getAt(tClickedUnit).getAt(#type) = #MultiUnit) then
            if (pUnitList.getAt(tClickedUnit).getAt(#multiroomOpen) = #open) then
              tstate = #closed
            else
              tstate = #open
            end if
            pUnitList.getAt(tClickedUnit).setAt(#multiroomOpen, tstate)
            if not voidp(pUnitList.findPos(tClickedUnit)) then
              tMainPos = pUnitList.findPos(tClickedUnit)
            end if
            f = (tMainPos + 1)
            repeat while f <= (tMainPos + pUnitList.getAt(tClickedUnit).getAt(#subunitcount))
              if (tstate = #open) then
                pUnitList.getAt(pUnitList.getPropAt(f)).setAt(#visible, 1)
              else
                pUnitList.getAt(pUnitList.getPropAt(f)).setAt(#visible, 0)
              end if
              f = (1 + f)
            end repeat
            me.renderUnitList()
          end if
        end if
      else
        if (tSprID = "nav_public_people_tab") then
          me.GetUnitUsers(pLastClickedUnitId)
        else
          if (tSprID = "nav_public_info_tab") then
            me.CreatepublicRoomInfo(pLastClickedUnitId)
          else
            if tSprID <> "create_room" then
              if (tSprID = "nav_public_helptext") then
                return(executeMessage(#open_roomkiosk))
              end if
              if (tEvent = #mouseUp) then
                if (tSprID = "close") then
                  me.hideNavigator(#hide)
                else
                  if (tSprID = "nav_go_public_button") then
                    if not voidp(pLastClickedUnitId) then
                      me.getComponent().updateState("enterUnit", pLastClickedUnitId)
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcNavigatorPrivate me, tEvent, tSprID, tParm 
  if (tEvent = #mouseDown) then
    if (tSprID = "nav_public_tab") then
      if not voidp(pLastClickedUnitId) then
        me.ChangeWindowView("nav_public_info.window")
        me.CreatepublicRoomInfo(pLastClickedUnitId)
      else
        me.ChangeWindowView("nav_public_start.window")
      end if
    else
      if (tSprID = "nav_private_rooms_list") then
        if not ilk(tParm, #point) or (pFlatList.count = 0) then
          return FALSE
        end if
        tClickLine = (integer((tParm.locV / pListItemHeight)) + 1)
        if tClickLine > pFlatList.count then
          tClickLine = pFlatList.count
        end if
        if tClickLine > 0 then
          if not voidp(pFlatList.getAt(tClickLine)) then
            tRoomId = pFlatList.getAt(tClickLine).getAt(#id)
            if not voidp(tRoomId) then
              tGoLinkArea = (pPrivateListImg.width - pFlatGoTextImg.width)
              if tParm.locH > tGoLinkArea then
                if not getObject(#session).get("user_rights").getOne("can_enter_others_rooms") then
                  if pFlatList.getAt(tRoomId).getAt(#owner) <> getObject(#session).get(#userName) then
                    executeMessage(#alert, [#msg:"nav_norights"])
                    return TRUE
                  end if
                end if
                pFlatInfoAction = #enterflat
                me.getComponent().getFlatInfo(tRoomId)
                me.renderLoadingText("nav_private_rooms_list")
              else
                pFlatInfoAction = #flatInfo
                tWndObj = getWindow(pWindowTitle)
                tScroll = tWndObj.getElement("scroll_private").getScrollOffset()
                me.ChangeWindowView("nav_private_info.window")
                me.CreatePrivateRoomInfo(pFlatList.getAt(tRoomId))
                tWndObj.getElement("scroll_private").setScrollOffset(tScroll)
                pFlatInfoAction = 0
              end if
            end if
          end if
        end if
      else
        if (tSprID = "nav_private_search_field") then
          me.searchPrivateRooms(1)
        else
          if (tSprID = "nav_modify_nameshow_yes_radio") then
            pCurrentFlatData.setAt(#showownername, "1")
            me.updateRadioButton("nav_modify_nameshow_yes_radio", ["nav_modify_nameshow_no_radio"])
          else
            if (tSprID = "nav_modify_nameshow_no_radio") then
              pCurrentFlatData.setAt(#showownername, "0")
              me.updateRadioButton("nav_modify_nameshow_no_radio", ["nav_modify_nameshow_yes_radio"])
            else
              if (tSprID = "nav_modify_door_open_radio") then
                pCurrentFlatData.setAt(#door, "open")
                me.updateRadioButton("nav_modify_door_open_radio", ["nav_modify_door_locked_radio", "nav_modify_door_pw_radio"])
              else
                if (tSprID = "nav_modify_door_locked_radio") then
                  pCurrentFlatData.setAt(#door, "closed")
                  me.updateRadioButton("nav_modify_door_locked_radio", ["nav_modify_door_open_radio", "nav_modify_door_pw_radio"])
                else
                  if (tSprID = "nav_modify_door_pw_radio") then
                    pCurrentFlatData.setAt(#door, "password")
                    me.updateRadioButton("nav_modify_door_pw_radio", ["nav_modify_door_open_radio", "nav_modify_door_locked_radio"])
                  else
                    if (tSprID = "nav_modify_furnituremove_check") then
                      me.updateCheckButton("nav_modify_furnituremove_check", #ableothersmovefurniture, 1)
                    else
                      if tSprID <> "create_room" then
                        if (tSprID = "nav_public_helptext") then
                          return(executeMessage(#open_roomkiosk))
                        end if
                        if (tEvent = #mouseUp) then
                          if (tSprID = "close") then
                            me.hideNavigator(#hide)
                          else
                            if (tSprID = "nav_go_private_button") then
                              if not getObject(#session).get("user_rights").getOne("can_enter_others_rooms") then
                                if pCurrentFlatData.getAt(#owner) <> getObject(#session).get(#userName) then
                                  executeMessage(#alert, [#msg:"nav_norights"])
                                  return TRUE
                                end if
                              end if
                              pFlatInfoAction = #enterflat
                              me.getComponent().getFlatInfo(pCurrentFlatData.getAt(#id))
                              me.renderLoadingText("nav_private_rooms_list")
                            else
                              if (tSprID = "nav_private_dropdown") then
                                if tParm.ilk <> #string or (tParm = pPrivateDropMode) then
                                  return TRUE
                                end if
                                pPrivateDropMode = tParm
                                if (pPrivateDropMode = "nav_rooms_search") then
                                  return(me.searchPrivateRooms(1))
                                else
                                  me.searchPrivateRooms(0)
                                end if
                                if (tSprID = "nav_rooms_own") then
                                  me.getComponent().getOwnFlats()
                                else
                                  if (tSprID = "nav_rooms_popular") then
                                    return(me.getComponent().searchBusyFlats(0, pFlatsPerView))
                                  else
                                    if (tSprID = "nav_rooms_search") then
                                      me.makePrivateRoomSearch()
                                    else
                                      if (tSprID = "nav_rooms_favourite") then
                                        me.getComponent().getFavouriteFlats()
                                      end if
                                    end if
                                  end if
                                end if
                                me.renderLoadingText("nav_private_rooms_list")
                              else
                                if (tSprID = "nav_private_button_search") then
                                  me.makePrivateRoomSearch()
                                else
                                  if (tSprID = "nav_modify_button") then
                                    if not voidp(pCurrentFlatData.getAt(#id)) then
                                      pFlatInfoAction = #modifyInfo
                                      me.getComponent().getFlatInfo(pCurrentFlatData.getAt(#id))
                                      me.renderLoadingText("nav_private_rooms_list")
                                    end if
                                  else
                                    if (tSprID = "nav_modify_ok") then
                                      if voidp(pCurrentFlatData) then
                                        return FALSE
                                      end if
                                      tWndObj = getWindow(pWindowTitle)
                                      if (pCurrentFlatData.getAt(#door) = "password") then
                                        if not me.checkPasswords() then
                                          return FALSE
                                        end if
                                      end if
                                      pCurrentFlatData.setAt(#name, tWndObj.getElement("nav_modify_roomnamefield").getText().getProp(#line, 1))
                                      pCurrentFlatData.setAt(#description, tWndObj.getElement("nav_modify_roomdescription_field").getText())
                                      pCurrentFlatData.setAt(#password, me.getPassword("nav_modify_door_pw"))
                                      me.getComponent().sendupdateFlatInfo(pCurrentFlatData)
                                      me.getComponent().getOwnFlats()
                                      me.getComponent().getFlatInfo(pCurrentFlatData.getAt(#id))
                                      pFlatInfoAction = #flatInfo
                                      me.roomlistupdate()
                                      me.ChangeWindowView("nav_private_info.window")
                                      me.renderLoadingText("nav_private_rooms_list")
                                    else
                                      if (tSprID = "nav_modify_cancel") then
                                        me.roomlistupdate()
                                        me.ChangeWindowView("nav_private_info.window")
                                        me.renderLoadingText("nav_private_rooms_list")
                                      else
                                        if (tSprID = "nav_modify_deleteroom") then
                                          me.ChangeWindowView("nav_private_modify_delete1.window")
                                        else
                                          if (tSprID = "nav_addtofavourites_button") then
                                            if voidp(pCurrentFlatData.getAt(#id)) then
                                              return FALSE
                                            end if
                                            me.getComponent().addToFavouriteFlats(pCurrentFlatData.getAt(#id))
                                          else
                                            if (tSprID = "nav_removefavourites_button") then
                                              if voidp(pCurrentFlatData.getAt(#id)) then
                                                return FALSE
                                              end if
                                              me.getComponent().removeFavouriteFlats(pCurrentFlatData.getAt(#id))
                                              me.getComponent().getFavouriteFlats()
                                            else
                                              if tSprID <> "nav_ringbell_cancel_button" then
                                                if tSprID <> "nav_flatpassword_cancel_button" then
                                                  if (tSprID = "nav_trypw_cancel_button") then
                                                    if tSprID <> "nav_flatpassword_cancel_button" then
                                                      me.getComponent().updateState("enterEntry")
                                                    end if
                                                    me.ChangeWindowView("nav_private_start.window")
                                                    if not me.getComponent().searchBusyFlats(0, pFlatsPerView) then
                                                      me.renderLoadingText("nav_private_rooms_list")
                                                    end if
                                                  else
                                                    if (tSprID = "nav_flatpassword_ok_button") then
                                                      tTemp = me.getPassword("nav_flatpassword_field")
                                                      if (length(tTemp) = 0) then
                                                        return()
                                                      end if
                                                      pCurrentFlatData.setAt(#password, tTemp)
                                                      me.ChangeWindowView("nav_private_try_pw.window")
                                                      getWindow(pWindowTitle).getElement("nav_roomname_text").setText(pCurrentFlatData.getAt(#name))
                                                      me.getComponent().updateState("enterFlat", pCurrentFlatData.getAt(#id))
                                                    else
                                                      if (tSprID = "nav_tryagain_ok_button") then
                                                        pFlatInfoAction = #enterflat
                                                        me.getComponent().getFlatInfo(pCurrentFlatData.getAt(#id))
                                                      else
                                                        if (tSprID = "nav_noanswer_ok_button") then
                                                          me.getComponent().updateState("enterEntry")
                                                          me.ChangeWindowView("nav_private_info.window")
                                                          if not me.getComponent().searchBusyFlats(0, pFlatsPerView) then
                                                            me.renderLoadingText("nav_private_rooms_list")
                                                          end if
                                                        else
                                                          if tSprID contains "nav_delete_room_ok_" then
                                                            if not voidp(pCurrentFlatData.getAt(#id)) then
                                                              if (tSprID = 1) then
                                                                me.ChangeWindowView("nav_private_modify_delete2.window")
                                                              else
                                                                if (tSprID = 2) then
                                                                  me.ChangeWindowView("nav_private_modify_delete3.window")
                                                                else
                                                                  if (tSprID = 3) then
                                                                    me.getComponent().deleteFlat(pCurrentFlatData.getAt(#id))
                                                                    me.ChangeWindowView("nav_private_start.window")
                                                                    pPrivateDropMode = "nav_rooms_own"
                                                                    me.getComponent().getOwnFlats()
                                                                    me.renderLoadingText("nav_private_rooms_list")
                                                                  end if
                                                                end if
                                                              end if
                                                            end if
                                                          else
                                                            if tSprID contains "nav_delete_room_cancel_" then
                                                              if voidp(pCurrentFlatData.getAt(#id)) then
                                                                return FALSE
                                                              end if
                                                              me.getComponent().getFlatInfo(pCurrentFlatData.getAt(#id))
                                                              pFlatInfoAction = #modifyInfo
                                                            end if
                                                          end if
                                                        end if
                                                      end if
                                                    end if
                                                  end if
                                                  if (tEvent = #keyDown) then
                                                    if (tSprID = "nav_private_search_field") then
                                                      if (the key = "\r") then
                                                        me.makePrivateRoomSearch()
                                                      end if
                                                    else
                                                      if tSprID <> "nav_modify_door_pw" then
                                                        if tSprID <> "nav_modify_door_pw2" then
                                                          if (tSprID = "nav_flatpassword_field") then
                                                            if voidp(pFlatPasswords.getAt(tSprID)) then
                                                              pFlatPasswords.setAt(tSprID, [])
                                                            end if
                                                            if (tSprID = 48) then
                                                              return FALSE
                                                            else
                                                              if tSprID <> 36 then
                                                                if (tSprID = 76) then
                                                                  if (tSprID = "nav_flatpassword_field") then
                                                                    return(me.eventProcNavigatorPrivate(#mouseUp, "nav_flatpassword_ok_button", void()))
                                                                  else
                                                                    return TRUE
                                                                  end if
                                                                else
                                                                  if (tSprID = 51) then
                                                                    if pFlatPasswords.getAt(tSprID).count > 0 then
                                                                      pFlatPasswords.getAt(tSprID).deleteAt(pFlatPasswords.getAt(tSprID).count)
                                                                    end if
                                                                  else
                                                                    if (tSprID = 117) then
                                                                      pFlatPasswords.setAt(tSprID, [])
                                                                    else
                                                                      tValidKeys = getVariable("permitted.name.chars", "1234567890qwertyuiopasdfghjklzxcvbnm_-=+?!@<>:.,")
                                                                      tTheKey = the key
                                                                      tASCII = charToNum(tTheKey)
                                                                      if tASCII > 31 and tASCII < 128 then
                                                                        if tValidKeys contains tTheKey or (tValidKeys = "") then
                                                                          if pFlatPasswords.getAt(tSprID).count < 32 then
                                                                            pFlatPasswords.getAt(tSprID).append(tTheKey)
                                                                          end if
                                                                        end if
                                                                      end if
                                                                    end if
                                                                  end if
                                                                end if
                                                                tStr = ""
                                                                i = 1
                                                                repeat while i <= pFlatPasswords.getAt(tSprID).count
                                                                  i = (1 + i)
                                                                end repeat
                                                                getWindow(pWindowTitle).getElement(tSprID).setText(tStr)
                                                                the selStart = pFlatPasswords.getAt(tSprID).count
                                                                the selEnd = pFlatPasswords.getAt(tSprID).count
                                                                return TRUE
                                                              end if
                                                            end if
                                                          end if
                                                        end if
                                                      end if
                                                    end if
                                                  end if
                                                end if
                                              end if
                                            end if
                                          end if
                                        end if
                                      end if
                                    end if
                                  end if
                                end if
                              end if
                            end if
                          end if
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcDisconnect me, tEvent, tElemID, tParam 
  if (tEvent = #mouseUp) then
    if (tElemID = "error_close") then
      removeWindow(#error)
      resetClient()
    end if
  end if
end
