property pWindowTitle, pOpenWindow, pProps, pGoLinkTextImg, pOpenLinkTextImg, pResourcesReady, pWriterPrivPlain, pWriterBackTabs, pWriterPlainNormLeft, pWriterPlainBoldLeft, pWriterPlainBoldCent, pWriterUnderNormLeft, pWriterPlainNormWrap, pCatBackImages, pRoomBackImages, pListItemHeight, pHistoryItemHeight, pRoomInfoHeight, pListAreaWidth, pBufferDepth

on construct me
  pWindowTitle = getText("navigator", "Hotel Navigator")
  pProps = [:]
  pRoomInfoHeight = 96
  pListAreaWidth = 311
  pListItemHeight = 18
  pHistoryItemHeight = 18
  pBufferDepth = 32
  pOpenWindow = "nav_pr"
  pResourcesReady = 0
  return me.createImgResources()
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
  return me.removeImgResources()
end

on getNaviView me
  case pOpenWindow of
    "nav_pr":
      return #unit
    "nav_gr0":
      return #flat
    "nav_gr_own":
      return #own
    "nav_gr_src":
      return #src
    "nav_gr_fav":
      return #fav
    "nav_gr_mod", "nav_gr_modify_delete1", "nav_gr_modify_delete2", "nav_gr_modify_delete3", "nav_modify_removerights":
      return #mod
  end case
  return #none
end

on getProperty me, tProp, tView
  if (tView = VOID) then
    tView = me.getNaviView()
  end if
  if (tView = #mod) then
    tView = #own
  end if
  if (tView = 0) then
    return VOID
  end if
  if (pProps[tView] = VOID) then
    return VOID
  end if
  if not voidp(pProps[tView][tProp]) then
    return pProps[tView][tProp]
  else
    return VOID
  end if
end

on setProperty me, tProp, tValue, tView
  if (tView = VOID) then
    tView = me.getNaviView()
  end if
  if (tView = 0) then
    return 0
  end if
  if (pProps[tView] = VOID) then
    pProps[tView] = [:]
  end if
  pProps[tView][tProp] = tValue
  return 1
end

on showNavigator me
  if windowExists(pWindowTitle) then
    getWindow(pWindowTitle).show()
  else
    return me.ChangeWindowView(pOpenWindow)
  end if
  return 0
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
  return 1
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
    me.ChangeWindowView(pOpenWindow)
  end if
end

on ChangeWindowView me, tWindowName
  tWndObj = getWindow(pWindowTitle)
  tScrollOffset = 0
  if (tWndObj <> 0) then
    if ((tWindowName contains "nav_pr") and tWndObj.elementExists("nav_scrollbar")) then
      tScrollOffset = tWndObj.getElement("nav_scrollbar").getScrollOffset()
    end if
    tWndObj.unmerge()
  else
    if not createWindow(pWindowTitle, "habbo_basic.window", 345, 20) then
      return error(me, "Failed to create window for Navigator!", #ChangeWindowView)
    end if
    tWndObj = getWindow(pWindowTitle)
    tWndObj.registerClient(me.getID())
  end if
  if not tWndObj.merge((tWindowName & ".window")) then
    return tWndObj.close()
  end if
  case tWindowName of
    "nav_gr_password", "nav_gr_trypassword", "nav_gr_passwordincorrect":
      tName = me.getComponent().getNodeName(me.getProperty(#viewedNodeId))
      getWindow(me.pWindowTitle).getElement("nav_roomname_text").setText(tName)
    "nav_remove_rights":
      nothing()
    otherwise:
      pOpenWindow = tWindowName
  end case
  if tWndObj.elementExists("nav_roomlist") then
    tWndObj.getElement("nav_roomlist").clearImage()
  end if
  tCategoryId = me.getProperty(#categoryId)
  tRoomInfoState = me.getProperty(#roomInfoState)
  tNaviView = me.getNaviView()
  case tNaviView of
    #unit:
      tWndObj.registerProcedure(#eventProcNavigatorPublic, me.getID(), #mouseDown)
      tWndObj.registerProcedure(#eventProcNavigatorPublic, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProcNavigatorPublic, me.getID(), #keyDown)
      me.getComponent().createNaviHistory(tCategoryId)
      me.updateRoomList(tCategoryId, VOID)
      if (tRoomInfoState = #hide) then
        me.setProperty(#roomInfoState, #show)
        me.setRoomInfoArea(#hide)
      else
        me.showNodeInfo(me.getProperty(#viewedNodeId))
      end if
      return 1
    #flat, #src, #own, #fav:
      tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #mouseDown)
      tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #keyDown)
      if (tNaviView = #flat) then
        me.getComponent().createNaviHistory(tCategoryId)
        me.updateRoomList(tCategoryId, VOID)
      else
        me.getComponent().feedNewRoomList(tCategoryId)
      end if
      if (tRoomInfoState = #hide) then
        me.setProperty(#roomInfoState, #show)
        me.setRoomInfoArea(#hide)
      else
        me.showNodeInfo(me.getProperty(#viewedNodeId))
      end if
      return 1
    #mod:
      tWndObj.registerProcedure(#eventProcNavigatorModify, me.getID(), #mouseDown)
      tWndObj.registerProcedure(#eventProcNavigatorModify, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProcNavigatorModify, me.getID(), #keyDown)
      if tWndObj.elementExists("nav_choosecategory") then
        me.prepareCategoryDropMenu(me.getProperty(#viewedNodeId))
      end if
  end case
  return 1
end

on updateRoomList me, tNodeId, tRoomList
  me.setLoadingCursor(0)
  if listp(tRoomList) then
    tImage = me.renderRoomList(tRoomList)
    if (tNodeId = me.getProperty(#categoryId, #unit)) then
      me.setProperty(#cacheImg, tImage, #unit)
    end if
    if (tNodeId = me.getProperty(#categoryId, #flat)) then
      me.setProperty(#cacheImg, tImage, #flat)
    end if
    if ((tNodeId <> me.getProperty(#categoryId)) and (tNodeId <> me.getNaviView())) then
      return 1
    end if
  else
    if ((tNodeId = me.getProperty(#categoryId)) and not voidp(me.getProperty(#cacheImg))) then
      tImage = me.getProperty(#cacheImg)
    else
      return 0
    end if
  end if
  tWndObj = getWindow(pWindowTitle)
  if (tWndObj = 0) then
    return 0
  end if
  if ((me.getComponent().getNodeName(tNodeId) <> EMPTY) and tWndObj.elementExists("nav_roomlist_hd")) then
    tHeaderImage = me.pWriterPlainBoldLeft.render(me.getComponent().getNodeName(tNodeId))
    tWndObj.getElement("nav_roomlist_hd").feedImage(tHeaderImage)
  end if
  tLstElement = tWndObj.getElement("nav_roomlist")
  if (tLstElement = 0) then
    return 0
  end if
  tLstElement.feedImage(tImage)
  tBarElement = tWndObj.getElement("nav_scrollbar")
  if (tBarElement = 0) then
    return 1
  end if
  if (tBarElement.getScrollOffset() > tImage.height) then
    tBarElement.setScrollOffset((tImage.height - tLstElement.getProperty(#height)))
  end if
  return 1
end

on clearRoomList me
  tWndObj = getWindow(me.pWindowTitle)
  if (tWndObj = 0) then
    return 0
  end if
  if tWndObj.elementExists("nav_roomlist") then
    tWndObj.getElement("nav_roomlist").clearImage()
  end if
  if tWndObj.elementExists("nav_roomlist_hd") then
    tWndObj.getElement("nav_roomlist_hd").clearImage()
  end if
  if tWndObj.elementExists("nav_roomlist") then
    tWndObj.getElement("nav_roomlist").clearBuffer()
  end if
  if tWndObj.elementExists("nav_roomlist_hd") then
    tWndObj.getElement("nav_roomlist_hd").clearBuffer()
  end if
  if tWndObj.elementExists("nav_scrollbar") then
    tWndObj.getElement("nav_scrollbar").setScrollOffset(0)
  end if
  return 1
end

on renderHistory me, tNodeId, tHistoryTxt
  if not (tNodeId = me.getProperty(#categoryId)) then
    return 0
  end if
  tWndObj = getWindow(me.pWindowTitle)
  if (tWndObj = 0) then
    return 0
  end if
  tElem = tWndObj.getElement("nav_roomlistBackTabs")
  if (tElem = 0) then
    return 0
  end if
  tOffset = me.getProperty(#historyOrigV)
  if (tOffset = VOID) then
    tOffset = tWndObj.getElement("nav_roomlist").getProperty(#locV)
    me.setProperty(#historyOrigV, tOffset)
  end if
  tItemCount = tHistoryTxt.line.count
  if (tHistoryTxt = EMPTY) then
    tItemCount = 0
  end if
  tOffset = (tOffset - tWndObj.getElement("nav_roomlist").getProperty(#locV))
  tOffset = ((tItemCount * pHistoryItemHeight) + tOffset)
  if ((me.getNaviView() = #flat) and (tItemCount > 0)) then
    tOffset = (tOffset + 7)
  end if
  tWndObj.getElement("nav_roomlist_hd").moveBy(0, tOffset)
  tScaleList = [tWndObj.getElement("nav_roomlist"), tWndObj.getElement("nav_scrollbar"), tWndObj.getElement("nav_roomlistArea")]
  call(#moveBy, tScaleList, 0, tOffset)
  call(#resizeBy, tScaleList, 0, -tOffset)
  tTextImg = me.pWriterBackTabs.render(tHistoryTxt)
  tWndObj.getElement("nav_roomlistBackLinks").feedImage(tTextImg)
end

on showNodeInfo me, tNodeId
  me.setLoadingCursor(0)
  if not windowExists(pWindowTitle) then
    return 0
  end if
  tWndObj = getWindow(pWindowTitle)
  tElem = tWndObj.getElement("nav_roomnfo_hd")
  if (tElem = 0) then
    return 0
  end if
  if not voidp(tNodeId) then
    tNodeInfo = me.getComponent().getNodeInfo(tNodeId, me.getProperty(#categoryId))
  end if
  if not listp(tNodeInfo) then
    tNodeInfo = 0
  else
    if (tNodeInfo[#nodeType] = 0) then
      tNodeInfo = 0
    end if
  end if
  me.setRoomInfoArea(#show)
  tView = me.getNaviView()
  if (tNodeInfo = 0) then
    case tView of
      #unit:
        tIconName = "nav_ico_def_pr"
        tRoomDesc = getText("nav_public_helptext")
        tHeaderTxt = getText("nav_public_helptext_hd")
      #src:
        tIconName = "nav_ico_def_src"
        tRoomDesc = getText("nav_search_helptext")
        tHeaderTxt = getText("nav_private_helptext_hd")
      #fav:
        tIconName = "nav_ico_def_fav"
        tRoomDesc = getText("nav_favourites_helptext")
        tHeaderTxt = getText("nav_private_helptext_hd")
      #own:
        tIconName = "nav_ico_def_own"
        tRoomDesc = getText("nav_ownrooms_helptext")
        tHeaderTxt = getText("nav_private_helptext_hd")
      otherwise:
        tIconName = "nav_ico_def_gr"
        tRoomDesc = getText("nav_private_helptext")
        tHeaderTxt = getText("nav_private_helptext_hd")
    end case
    if tWndObj.elementExists("nav_modify_button") then
      tWndObj.getElement("nav_modify_button").hide()
    end if
    if tWndObj.elementExists("nav_addtofavourites_button") then
      tWndObj.getElement("nav_addtofavourites_button").hide()
    end if
    if tWndObj.elementExists("nav_removefavourites_button") then
      tWndObj.getElement("nav_removefavourites_button").hide()
    end if
    tWndObj.getElement("nav_go_button").hide()
  else
    case tView of
      #unit:
        if (tNodeInfo[#door] > 0) then
          tRoomDesc = getText((((("nav_venue_" & tNodeInfo[#unitStrId]) & "/") & tNodeInfo[#door]) & "_desc"))
        else
          tRoomDesc = getText((("nav_venue_" & tNodeInfo[#unitStrId]) & "/0_desc"))
        end if
        tIconName = ("thumb." & tNodeInfo[#unitStrId])
        if not memberExists(tIconName) then
          tDelim = the itemDelimiter
          the itemDelimiter = "_"
          tIconName = tIconName.item[1]
          the itemDelimiter = tDelim
        end if
        tHeaderTxt = tNodeInfo[#name]
        tWndObj.getElement("nav_go_button").show()
      otherwise:
        if voidp(tNodeInfo[#name]) then
          tNodeInfo[#name] = "-"
        end if
        if voidp(tNodeInfo[#usercount]) then
          tNodeInfo[#usercount] = 0
        end if
        if voidp(tNodeInfo[#owner]) then
          tNodeInfo[#owner] = "-"
        end if
        if voidp(tNodeInfo[#description]) then
          tNodeInfo[#description] = "-"
        end if
        tHeaderTxt = ((((tNodeInfo[#name] & RETURN) & "(") & tNodeInfo[#usercount]) & "/25) ")
        tHeaderTxt = (((tHeaderTxt & getText("nav_owner")) & ":") && tNodeInfo[#owner])
        tRoomDesc = tNodeInfo[#description]
        case tNodeInfo[#door] of
          "open":
            tIconName = "door_open"
          "closed":
            tIconName = "door_closed"
          "password":
            tIconName = "door_password"
          otherwise:
            tNodeInfo[#door] = "open"
            tIconName = "door_open"
        end case
        if tWndObj.elementExists("nav_modify_button") then
          tWndObj.getElement("nav_modify_button").show()
        end if
        if tWndObj.elementExists("nav_addtofavourites_button") then
          tWndObj.getElement("nav_addtofavourites_button").show()
        end if
        if tWndObj.elementExists("nav_removefavourites_button") then
          tWndObj.getElement("nav_removefavourites_button").show()
        end if
        if tWndObj.elementExists("nav_go_button") then
          tWndObj.getElement("nav_go_button").show()
        end if
    end case
  end if
  tHeaderImage = pWriterPlainBoldLeft.render(tHeaderTxt)
  tElem.feedImage(tHeaderImage)
  tWidth = tElem.getProperty(#width)
  pWriterPlainNormWrap.define([#rect: rect(0, 0, tWidth, 0)])
  tImage = pWriterPlainNormWrap.render(tRoomDesc)
  tWndObj.getElement("nav_roomnfo").feedImage(tImage)
  if (memberExists(tIconName) and tWndObj.elementExists("nav_roomnfo_icon")) then
    tElemID = "nav_roomnfo_icon"
    tTempImg = member(getmemnum(tIconName)).image
    tTempImg = tTempImg.trimWhiteSpace()
    tElement = tWndObj.getElement(tElemID)
    tWidth = tElement.getProperty(#width)
    tHeight = tElement.getProperty(#height)
    tDepth = tElement.getProperty(#depth)
    tPrewImg = image(tWidth, tHeight, tDepth)
    tdestrect = (tPrewImg.rect - tTempImg.rect)
    tdestrect = rect((tdestrect.width / 2), (tdestrect.height / 2), (tTempImg.width + (tdestrect.width / 2)), ((tdestrect.height / 2) + tTempImg.height))
    tPrewImg.copyPixels(tTempImg, tdestrect, tTempImg.rect, [#ink: 8])
    tElement.clearImage()
    tElement.feedImage(tPrewImg)
  end if
  return 1
end

on createImgResources me
  if pResourcesReady then
    return 0
  end if
  tPlain = getStructVariable("struct.font.plain")
  tBold = getStructVariable("struct.font.bold")
  tLink = getStructVariable("struct.font.link")
  createWriter("nav_plain_norm_left", tPlain)
  pWriterPlainNormLeft = getWriter("nav_plain_norm_left")
  createWriter("nav_plain_bold_left", tBold)
  pWriterPlainBoldLeft = getWriter("nav_plain_bold_left")
  createWriter("nav_under_norm_left", tLink)
  pWriterUnderNormLeft = getWriter("nav_under_norm_left")
  createWriter("nav_plain_bold_cent", tBold)
  pWriterPlainBoldCent = getWriter("nav_plain_bold_cent")
  pWriterPlainBoldCent.define([#alignment: #center])
  createWriter("nav_plain_norm_wrap", tPlain)
  pWriterPlainNormWrap = getWriter("nav_plain_norm_wrap")
  pWriterPlainNormWrap.define([#wordWrap: 1])
  createWriter("nav_private_plain", tPlain)
  pWriterPrivPlain = getWriter("nav_private_plain")
  pWriterPrivPlain.define([#wordWrap: 0, #fixedLineSpace: pListItemHeight])
  createWriter("nav_backtabs_plain", tBold)
  pWriterBackTabs = getWriter("nav_backtabs_plain")
  pWriterBackTabs.define([#wordWrap: 0, #fixedLineSpace: pHistoryItemHeight, #color: rgb(51, 102, 102)])
  pGoLinkTextImg = pWriterUnderNormLeft.render(getText("nav_gobutton")).duplicate()
  pOpenLinkTextImg = pWriterUnderNormLeft.render(getText("nav_openbutton")).duplicate()
  createWindow("naviTempWindow")
  tTempWindowObj = getWindow("naviTempWindow")
  pRoomBackImages = []
  pRoomBackImages.add(createRoomItemImage(1, paletteIndex(81)))
  pRoomBackImages.add(createRoomItemImage(2, paletteIndex(128)))
  pRoomBackImages.add(createRoomItemImage(3, paletteIndex(129)))
  pRoomBackImages.add(createRoomItemImage(4, paletteIndex(130)))
  pCatBackImages = []
  pCatBackImages.add(createCatItemImage(1, paletteIndex(81)))
  pCatBackImages.add(createCatItemImage(2, paletteIndex(128)))
  pCatBackImages.add(createCatItemImage(3, paletteIndex(129)))
  pCatBackImages.add(createCatItemImage(4, paletteIndex(130)))
  removeWindow("naviTempWindow")
  pResourcesReady = 1
  return 1
end

on removeImgResources me
  if not pResourcesReady then
    return 0
  end if
  removeWriter(pWriterPlainNormLeft.getID())
  pWriterPlainNormLeft = VOID
  removeWriter(pWriterPlainBoldLeft.getID())
  pWriterPlainBoldLeft = VOID
  removeWriter(pWriterUnderNormLeft.getID())
  pWriterUnderNormLeft = VOID
  removeWriter(pWriterPlainBoldCent.getID())
  pWriterPlainBoldCent = VOID
  removeWriter(pWriterPlainNormWrap.getID())
  pWriterPlainNormWrap = VOID
  removeWriter(pWriterPrivPlain.getID())
  pWriterPrivPlain = VOID
  removeWriter(pWriterBackTabs.getID())
  pWriterBackTabs = VOID
  pResourcesReady = 0
  return 1
end

on createCatItemImage tNum, tColor
  tImg = image(311, 16, 8, member("nav_ui_palette"))
  tSrc = member(("nav_rw_lf" & tNum)).image
  tImg.copyPixels(tSrc, tSrc.rect, tSrc.rect)
  tImg.fill(6, 0, 311, 16, tColor)
  tSrc = member(("nav_rw_lf" & tNum)).image
  tImg.copyPixels(tSrc, [point(311, 0), point(305, 0), point(305, 16), point(311, 16)], tSrc.rect)
  tSrc = member("nav_rw_plus").image
  tImg.copyPixels(tSrc, rect(6, 4, 14, 12), tSrc.rect, [#ink: 36])
  tSrc = member("nav_rw_arr").image
  tImg.copyPixels(tSrc, rect(286, 4, 293, 12), tSrc.rect, [#ink: 36])
  tImg.copyPixels(tSrc, rect(293, 4, 300, 12), tSrc.rect, [#ink: 36])
  tImg.copyPixels(tSrc, rect(300, 4, 307, 12), tSrc.rect, [#ink: 36])
  return tImg
end

on createRoomItemImage tNum, tColor
  tImg = image(311, 16, 8, member("nav_ui_palette"))
  tSrc = member("nav_rw_lf").image
  tImg.copyPixels(tSrc, tSrc.rect, tSrc.rect)
  tImg.fill(6, 0, 246, 16, paletteIndex(82))
  tSrc = member("nav_rw_lf").image
  tImg.copyPixels(tSrc, [point(251, 0), point(245, 0), point(245, 16), point(251, 16)], tSrc.rect)
  tSrc = member(("nav_rw_lf" & tNum)).image
  tImg.copyPixels(tSrc, rect(253, 0, 259, 16), tSrc.rect)
  tImg.fill(259, 0, 305, 16, tColor)
  tSrc = member(("nav_rw_lf" & tNum)).image
  tImg.copyPixels(tSrc, [point(311, 0), point(305, 0), point(305, 16), point(311, 16)], tSrc.rect)
  tSrc = member("nav_rw_arr").image
  tImg.copyPixels(tSrc, rect(300, 4, 307, 12), tSrc.rect, [#ink: 36])
  return tImg
end

on renderRoomList me, tList
  if not listp(tList) then
    return 0
  end if
  tCount = tList.count
  tListHeight = (tCount * me.pListItemHeight)
  tTargetImg = image(me.pListAreaWidth, tListHeight, me.pBufferDepth)
  tLockMemImgA = member(getmemnum("lock1")).image
  tLockMemImgB = member(getmemnum("lock2")).image
  tNameTxt = EMPTY
  repeat with i = 1 to tCount
    tItem = tList[i]
    tItemName = tItem[#name]
    tNameTxt = ((tNameTxt & tItemName) & RETURN)
    tPercentFilled = tItem.getaProp(#percentFilled)
    if (tPercentFilled = VOID) then
      tUserStatus = (float(tItem[#usercount]) / 25)
    else
      tUserStatus = (float(tPercentFilled) / 100)
    end if
    if (tItem[#nodeType] = 0) then
      me.renderRoomListItem(#cat, i, tTargetImg, tUserStatus)
    else
      me.renderRoomListItem(#room, i, tTargetImg, tUserStatus)
    end if
    case tItem[#door] of
      "closed":
        tLockImg = tLockMemImgA
      "password":
        tLockImg = tLockMemImgB
      otherwise:
        tLockImg = 0
    end case
    if (tLockImg <> 0) then
      tSrcRect = tLockImg.rect
      tLocV = ((i - 1) * me.pListItemHeight)
      tdestrect = (tSrcRect + rect(7, (tLocV + 5), 7, (tLocV + 5)))
      tTargetImg.copyPixels(tLockImg, tdestrect, tSrcRect, [#ink: 36])
    end if
  end repeat
  delete char -30003 of tNameTxt
  tNameImage = me.pWriterPrivPlain.render(tNameTxt)
  tTargetImg.copyPixels(tNameImage, (tNameImage.rect + rect(17, -5, 17, -5)), tNameImage.rect)
  return tTargetImg
end

on renderRoomListItem me, ttype, tNum, tTargetImg, tUserStatus
  if (tUserStatus = 0) then
    tBackImgId = 1
  else
    if (tUserStatus < 0.34000000000000002) then
      tBackImgId = 2
    else
      if (tUserStatus < 0.78000000000000003) then
        tBackImgId = 3
      else
        tBackImgId = 4
      end if
    end if
  end if
  if (ttype = #room) then
    tBackImg = me.pRoomBackImages[tBackImgId]
  else
    tBackImg = me.pCatBackImages[tBackImgId]
  end if
  tLocV = ((tNum - 1) * me.pListItemHeight)
  tdestrect = (tBackImg.rect + rect(0, tLocV, 0, tLocV))
  tTargetImg.copyPixels(tBackImg, tdestrect, tBackImg.rect)
  if (ttype = #room) then
    tX1 = ((tBackImg.width - me.pGoLinkTextImg.width) - 12)
    tX2 = (tX1 + me.pGoLinkTextImg.width)
    tY1 = (3 + tLocV)
    tY2 = (tY1 + me.pGoLinkTextImg.height)
    tdestrect = rect(tX1, tY1, tX2, tY2)
    tTargetImg.copyPixels(me.pGoLinkTextImg, tdestrect, me.pGoLinkTextImg.rect, [#bgColor: rgb("#DDDDDD"), #ink: 36])
  else
    tX1 = ((tBackImg.width - me.pOpenLinkTextImg.width) - 27)
    tX2 = (tX1 + me.pOpenLinkTextImg.width)
    tY1 = (3 + tLocV)
    tY2 = (tY1 + me.pOpenLinkTextImg.height)
    tdestrect = rect(tX1, tY1, tX2, tY2)
    tTargetImg.copyPixels(me.pOpenLinkTextImg, tdestrect, me.pOpenLinkTextImg.rect, [#bgColor: rgb("#DDDDDD"), #ink: 36])
  end if
  return 1
end

on setRoomInfoArea me, tstate
  if not windowExists(me.pWindowTitle) then
    return 0
  end if
  if (me.getProperty(#roomInfoState) = VOID) then
    me.setProperty(#roomInfoState, #show)
  end if
  if (tstate = me.getProperty(#roomInfoState)) then
    return 0
  end if
  me.setProperty(#roomInfoState, tstate)
  if (tstate = #hide) then
    me.setProperty(#viewedNodeId, VOID)
  end if
  tWndObj = getWindow(me.pWindowTitle)
  tScaleElemList = [tWndObj.getElement("nav_roomlist"), tWndObj.getElement("nav_scrollbar"), tWndObj.getElement("nav_roomlistArea")]
  tOffset = pRoomInfoHeight
  if (tstate = #show) then
    tOffset = -tOffset
  end if
  call(#resizeBy, tScaleElemList, 0, tOffset)
  return 1
end

on setLoadingCursor me, tstate
  if tstate then
    setcursor(#timer)
  else
    setcursor(#arrow)
  end if
end

on renderLoadingText me, tTempElementId
  if voidp(tTempElementId) then
    return 0
  end if
  tElem = getWindow(me.pWindowTitle).getElement(tTempElementId)
  tWidth = tElem.getProperty(#width)
  tHeight = tElem.getProperty(#height)
  tTempImg = image(tWidth, tHeight, pBufferDepth)
  tTextImg = pWriterPlainBoldCent.render(getText("loading"))
  tOffX = ((tWidth - tTextImg.width) / 2)
  tOffY = ((tHeight - tTextImg.height) / 2)
  tDstRect = (tTextImg.rect + rect(tOffX, tOffY, tOffX, tOffY))
  tTempImg.copyPixels(tTextImg, tDstRect, tTextImg.rect)
  tElem.feedImage(tTempImg)
  return 1
end

on flipImage me, tImg_a
  tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth)
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return tImg_b
end
