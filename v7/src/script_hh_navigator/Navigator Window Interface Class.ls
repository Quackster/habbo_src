property pWindowTitle, pOpenWindow, pProps, pHistoryItemHeight, pWriterPlainBoldLeft, pWriterPlainNormWrap, pResourcesReady, pWriterPlainBoldCent, pWriterPrivPlain, pListItemHeight, pWriterBackTabs, pWriterUnderNormLeft, pRoomBackImages, pCatBackImages, pWriterPlainNormLeft, pRoomInfoHeight, pBufferDepth

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
  return(me.removeImgResources())
end

on getNaviView me 
  if pOpenWindow = "nav_pr" then
    return(#unit)
  else
    if pOpenWindow = "nav_gr0" then
      return(#flat)
    else
      if pOpenWindow = "nav_gr_own" then
        return(#own)
      else
        if pOpenWindow = "nav_gr_src" then
          return(#src)
        else
          if pOpenWindow = "nav_gr_fav" then
            return(#fav)
          else
            if pOpenWindow <> "nav_gr_mod" then
              if pOpenWindow <> "nav_gr_modify_delete1" then
                if pOpenWindow <> "nav_gr_modify_delete2" then
                  if pOpenWindow <> "nav_gr_modify_delete3" then
                    if pOpenWindow = "nav_modify_removerights" then
                      return(#mod)
                    else
                      return(#none)
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

on getProperty me, tProp, tView 
  if tView = void() then
    tView = me.getNaviView()
  end if
  if tView = #mod then
    tView = #own
  end if
  if tView = 0 then
    return(void())
  end if
  if pProps.getAt(tView) = void() then
    return(void())
  end if
  if not voidp(pProps.getAt(tView).getAt(tProp)) then
    return(pProps.getAt(tView).getAt(tProp))
  else
    return(void())
  end if
end

on setProperty me, tProp, tValue, tView 
  if tView = void() then
    tView = me.getNaviView()
  end if
  if tView = 0 then
    return(0)
  end if
  if pProps.getAt(tView) = void() then
    pProps.setAt(tView, [:])
  end if
  pProps.getAt(tView).setAt(tProp, tValue)
  return(1)
end

on showNavigator me 
  if windowExists(pWindowTitle) then
    getWindow(pWindowTitle).show()
  else
    return(me.ChangeWindowView(pOpenWindow))
  end if
  return(0)
end

on hideNavigator me, tHideOrRemove 
  if voidp(tHideOrRemove) then
    tHideOrRemove = #remove
  end if
  if windowExists(pWindowTitle) then
    if tHideOrRemove = #remove then
      removeWindow(pWindowTitle)
    else
      getWindow(pWindowTitle).hide()
    end if
  end if
  return(1)
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
  if tWndObj <> 0 then
    if tWindowName contains "nav_pr" and tWndObj.elementExists("nav_scrollbar") then
      tScrollOffset = tWndObj.getElement("nav_scrollbar").getScrollOffset()
    end if
    tWndObj.unmerge()
  else
    if not createWindow(pWindowTitle, "habbo_basic.window", 345, 20) then
      return(error(me, "Failed to create window for Navigator!", #ChangeWindowView))
    end if
    tWndObj = getWindow(pWindowTitle)
    tWndObj.registerClient(me.getID())
  end if
  if not tWndObj.merge(tWindowName & ".window") then
    return(tWndObj.close())
  end if
  if tWindowName <> "nav_gr_password" then
    if tWindowName <> "nav_gr_trypassword" then
      if tWindowName = "nav_gr_passwordincorrect" then
        tName = me.getComponent().getNodeName(me.getProperty(#viewedNodeId))
        getWindow(me.pWindowTitle).getElement("nav_roomname_text").setText(tName)
      else
        if tWindowName = "nav_remove_rights" then
          nothing()
        else
          pOpenWindow = tWindowName
        end if
      end if
      if tWndObj.elementExists("nav_roomlist") then
        tWndObj.getElement("nav_roomlist").clearImage()
      end if
      tCategoryId = me.getProperty(#categoryId)
      tRoomInfoState = me.getProperty(#roomInfoState)
      tNaviView = me.getNaviView()
      if tWindowName = #unit then
        tWndObj.registerProcedure(#eventProcNavigatorPublic, me.getID(), #mouseDown)
        tWndObj.registerProcedure(#eventProcNavigatorPublic, me.getID(), #mouseUp)
        tWndObj.registerProcedure(#eventProcNavigatorPublic, me.getID(), #keyDown)
        me.getComponent().createNaviHistory(tCategoryId)
        me.updateRoomList(tCategoryId, void())
        if tRoomInfoState = #hide then
          me.setProperty(#roomInfoState, #show)
          me.setRoomInfoArea(#hide)
        else
          me.showNodeInfo(me.getProperty(#viewedNodeId))
        end if
        return(1)
      else
        if tWindowName <> #flat then
          if tWindowName <> #src then
            if tWindowName <> #own then
              if tWindowName = #fav then
                tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #mouseDown)
                tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #mouseUp)
                tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #keyDown)
                if tNaviView = #flat then
                  me.getComponent().createNaviHistory(tCategoryId)
                  me.updateRoomList(tCategoryId, void())
                else
                  me.getComponent().feedNewRoomList(tCategoryId)
                end if
                if tRoomInfoState = #hide then
                  me.setProperty(#roomInfoState, #show)
                  me.setRoomInfoArea(#hide)
                else
                  me.showNodeInfo(me.getProperty(#viewedNodeId))
                end if
                return(1)
              else
                if tWindowName = #mod then
                  tWndObj.registerProcedure(#eventProcNavigatorModify, me.getID(), #mouseDown)
                  tWndObj.registerProcedure(#eventProcNavigatorModify, me.getID(), #mouseUp)
                  tWndObj.registerProcedure(#eventProcNavigatorModify, me.getID(), #keyDown)
                  if tWndObj.elementExists("nav_choosecategory") then
                    me.prepareCategoryDropMenu(me.getProperty(#viewedNodeId))
                  end if
                end if
              end if
              return(1)
            end if
          end if
        end if
      end if
    end if
  end if
end

on updateRoomList me, tNodeId, tRoomList 
  me.setLoadingCursor(0)
  if listp(tRoomList) then
    tImage = me.renderRoomList(tRoomList)
    if tNodeId = me.getProperty(#categoryId, #unit) then
      me.setProperty(#cacheImg, tImage, #unit)
    end if
    if tNodeId = me.getProperty(#categoryId, #flat) then
      me.setProperty(#cacheImg, tImage, #flat)
    end if
    if tNodeId <> me.getProperty(#categoryId) and tNodeId <> me.getNaviView() then
      return(1)
    end if
  else
    if tNodeId = me.getProperty(#categoryId) and not voidp(me.getProperty(#cacheImg)) then
      tImage = me.getProperty(#cacheImg)
    else
      return(0)
    end if
  end if
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return(0)
  end if
  if me.getComponent().getNodeName(tNodeId) <> "" and tWndObj.elementExists("nav_roomlist_hd") then
    tHeaderImage = pWriterPlainBoldLeft.render(me.getComponent().getNodeName(tNodeId))
    tWndObj.getElement("nav_roomlist_hd").feedImage(tHeaderImage)
  end if
  tLstElement = tWndObj.getElement("nav_roomlist")
  if tLstElement = 0 then
    return(0)
  end if
  tLstElement.feedImage(tImage)
  tBarElement = tWndObj.getElement("nav_scrollbar")
  if tBarElement = 0 then
    return(1)
  end if
  if tBarElement.getScrollOffset() > tImage.height then
    tBarElement.setScrollOffset(tImage.height - tLstElement.getProperty(#height))
  end if
  return(1)
end

on clearRoomList me 
  tWndObj = getWindow(me.pWindowTitle)
  if tWndObj = 0 then
    return(0)
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
  return(1)
end

on renderHistory me, tNodeId, tHistoryTxt 
  if not tNodeId = me.getProperty(#categoryId) then
    return(0)
  end if
  tWndObj = getWindow(me.pWindowTitle)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("nav_roomlistBackTabs")
  if tElem = 0 then
    return(0)
  end if
  tOffset = me.getProperty(#historyOrigV)
  if tOffset = void() then
    tOffset = tWndObj.getElement("nav_roomlist").getProperty(#locV)
    me.setProperty(#historyOrigV, tOffset)
  end if
  tItemCount = tHistoryTxt.count(#line)
  if tHistoryTxt = "" then
    tItemCount = 0
  end if
  tOffset = tOffset - tWndObj.getElement("nav_roomlist").getProperty(#locV)
  tOffset = tItemCount * pHistoryItemHeight + tOffset
  if me.getNaviView() = #flat and tItemCount > 0 then
    tOffset = tOffset + 7
  end if
  tWndObj.getElement("nav_roomlist_hd").moveBy(0, tOffset)
  tScaleList = [tWndObj.getElement("nav_roomlist"), tWndObj.getElement("nav_scrollbar"), tWndObj.getElement("nav_roomlistArea")]
  call(#moveBy, tScaleList, 0, tOffset)
  call(#resizeBy, tScaleList, 0, -tOffset)
  tTextImg = pWriterBackTabs.render(tHistoryTxt)
  tWndObj.getElement("nav_roomlistBackLinks").feedImage(tTextImg)
end

on showNodeInfo me, tNodeId 
  me.setLoadingCursor(0)
  if not windowExists(pWindowTitle) then
    return(0)
  end if
  tWndObj = getWindow(pWindowTitle)
  tElem = tWndObj.getElement("nav_roomnfo_hd")
  if tElem = 0 then
    return(0)
  end if
  if not voidp(tNodeId) then
    tNodeInfo = me.getComponent().getNodeInfo(tNodeId, me.getProperty(#categoryId))
  end if
  if not listp(tNodeInfo) then
    tNodeInfo = 0
  else
    if tNodeInfo.getAt(#nodeType) = 0 then
      tNodeInfo = 0
    end if
  end if
  me.setRoomInfoArea(#show)
  tView = me.getNaviView()
  if tNodeInfo = 0 then
    if tView = #unit then
      tIconName = "nav_ico_def_pr"
      tRoomDesc = getText("nav_public_helptext")
      tHeaderTxt = getText("nav_public_helptext_hd")
    else
      if tView = #src then
        tIconName = "nav_ico_def_src"
        tRoomDesc = getText("nav_search_helptext")
        tHeaderTxt = getText("nav_private_helptext_hd")
      else
        if tView = #fav then
          tIconName = "nav_ico_def_fav"
          tRoomDesc = getText("nav_favourites_helptext")
          tHeaderTxt = getText("nav_private_helptext_hd")
        else
          if tView = #own then
            tIconName = "nav_ico_def_own"
            tRoomDesc = getText("nav_ownrooms_helptext")
            tHeaderTxt = getText("nav_private_helptext_hd")
          else
            tIconName = "nav_ico_def_gr"
            tRoomDesc = getText("nav_private_helptext")
            tHeaderTxt = getText("nav_private_helptext_hd")
          end if
        end if
      end if
    end if
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
    if tView = #unit then
      if tNodeInfo.getAt(#door) > 0 then
        tRoomDesc = getText("nav_venue_" & tNodeInfo.getAt(#unitStrId) & "/" & tNodeInfo.getAt(#door) & "_desc")
      else
        tRoomDesc = getText("nav_venue_" & tNodeInfo.getAt(#unitStrId) & "/0_desc")
      end if
      tIconName = "thumb." & tNodeInfo.getAt(#unitStrId)
      if not memberExists(tIconName) then
        tDelim = the itemDelimiter
        the itemDelimiter = "_"
        tIconName = tIconName.getProp(#item, 1, tIconName.count(#item) - 1)
        the itemDelimiter = tDelim
      end if
      tHeaderTxt = tNodeInfo.getAt(#name)
      tWndObj.getElement("nav_go_button").show()
    else
      if voidp(tNodeInfo.getAt(#name)) then
        tNodeInfo.setAt(#name, "-")
      end if
      if voidp(tNodeInfo.getAt(#usercount)) then
        tNodeInfo.setAt(#usercount, 0)
      end if
      if voidp(tNodeInfo.getAt(#owner)) then
        tNodeInfo.setAt(#owner, "-")
      end if
      if voidp(tNodeInfo.getAt(#description)) then
        tNodeInfo.setAt(#description, "-")
      end if
      tHeaderTxt = tNodeInfo.getAt(#name) & "\r" & "(" & tNodeInfo.getAt(#usercount) & "/25) "
      tHeaderTxt = tHeaderTxt & getText("nav_owner") & ":" && tNodeInfo.getAt(#owner)
      tRoomDesc = tNodeInfo.getAt(#description)
      if tView = "open" then
        tIconName = "door_open"
      else
        if tView = "closed" then
          tIconName = "door_closed"
        else
          if tView = "password" then
            tIconName = "door_password"
          else
            tNodeInfo.setAt(#door, "open")
            tIconName = "door_open"
          end if
        end if
      end if
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
    end if
  end if
  tHeaderImage = pWriterPlainBoldLeft.render(tHeaderTxt)
  tElem.feedImage(tHeaderImage)
  tWidth = tElem.getProperty(#width)
  pWriterPlainNormWrap.define([#rect:rect(0, 0, tWidth, 0)])
  tImage = pWriterPlainNormWrap.render(tRoomDesc)
  tWndObj.getElement("nav_roomnfo").feedImage(tImage)
  if memberExists(tIconName) and tWndObj.elementExists("nav_roomnfo_icon") then
    tElemID = "nav_roomnfo_icon"
    tTempImg = member(getmemnum(tIconName)).image
    tTempImg = tTempImg.trimWhiteSpace()
    tElement = tWndObj.getElement(tElemID)
    tWidth = tElement.getProperty(#width)
    tHeight = tElement.getProperty(#height)
    tDepth = tElement.getProperty(#depth)
    tPrewImg = image(tWidth, tHeight, tDepth)
    tdestrect = tPrewImg.rect - tTempImg.rect
    tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, tTempImg.width + tdestrect.width / 2, tdestrect.height / 2 + tTempImg.height)
    tPrewImg.copyPixels(tTempImg, tdestrect, tTempImg.rect, [#ink:8])
    tElement.clearImage()
    tElement.feedImage(tPrewImg)
  end if
  return(1)
end

on createImgResources me 
  if pResourcesReady then
    return(0)
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
  pWriterPlainBoldCent.define([#alignment:#center])
  createWriter("nav_plain_norm_wrap", tPlain)
  pWriterPlainNormWrap = getWriter("nav_plain_norm_wrap")
  pWriterPlainNormWrap.define([#wordWrap:1])
  createWriter("nav_private_plain", tPlain)
  pWriterPrivPlain = getWriter("nav_private_plain")
  pWriterPrivPlain.define([#wordWrap:0, #fixedLineSpace:pListItemHeight])
  createWriter("nav_backtabs_plain", tBold)
  pWriterBackTabs = getWriter("nav_backtabs_plain")
  pWriterBackTabs.define([#wordWrap:0, #fixedLineSpace:pHistoryItemHeight, #color:rgb(51, 102, 102)])
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
  return(1)
end

on removeImgResources me 
  if not pResourcesReady then
    return(0)
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
  removeWriter(pWriterBackTabs.getID())
  pWriterBackTabs = void()
  pResourcesReady = 0
  return(1)
end

on createCatItemImage tNum, tColor 
  tImg = image(311, 16, 8, member("nav_ui_palette"))
  tSrc = member("nav_rw_lf" & tNum).image
  tImg.copyPixels(tSrc, tSrc.rect, tSrc.rect)
  tImg.fill(6, 0, 311, 16, tColor)
  tSrc = member("nav_rw_lf" & tNum).image
  tImg.copyPixels(tSrc, [point(311, 0), point(305, 0), point(305, 16), point(311, 16)], tSrc.rect)
  tSrc = member("nav_rw_plus").image
  tImg.copyPixels(tSrc, rect(6, 4, 14, 12), tSrc.rect, [#ink:36])
  tSrc = member("nav_rw_arr").image
  tImg.copyPixels(tSrc, rect(286, 4, 293, 12), tSrc.rect, [#ink:36])
  tImg.copyPixels(tSrc, rect(293, 4, 300, 12), tSrc.rect, [#ink:36])
  tImg.copyPixels(tSrc, rect(300, 4, 307, 12), tSrc.rect, [#ink:36])
  return(tImg)
end

on createRoomItemImage tNum, tColor 
  tImg = image(311, 16, 8, member("nav_ui_palette"))
  tSrc = member("nav_rw_lf").image
  tImg.copyPixels(tSrc, tSrc.rect, tSrc.rect)
  tImg.fill(6, 0, 246, 16, paletteIndex(82))
  tSrc = member("nav_rw_lf").image
  tImg.copyPixels(tSrc, [point(251, 0), point(245, 0), point(245, 16), point(251, 16)], tSrc.rect)
  tSrc = member("nav_rw_lf" & tNum).image
  tImg.copyPixels(tSrc, rect(253, 0, 259, 16), tSrc.rect)
  tImg.fill(259, 0, 305, 16, tColor)
  tSrc = member("nav_rw_lf" & tNum).image
  tImg.copyPixels(tSrc, [point(311, 0), point(305, 0), point(305, 16), point(311, 16)], tSrc.rect)
  tSrc = member("nav_rw_arr").image
  tImg.copyPixels(tSrc, rect(300, 4, 307, 12), tSrc.rect, [#ink:36])
  return(tImg)
end

on renderRoomList me, tList 
  if not listp(tList) then
    return(0)
  end if
  tCount = tList.count
  tListHeight = tCount * me.pListItemHeight
  tTargetImg = image(me.pListAreaWidth, tListHeight, me.pBufferDepth)
  tLockMemImgA = member(getmemnum("lock1")).image
  tLockMemImgB = member(getmemnum("lock2")).image
  tNameTxt = ""
  i = 1
  repeat while i <= tCount
    tItem = tList.getAt(i)
    tItemName = tItem.getAt(#name)
    tNameTxt = tNameTxt & tItemName & "\r"
    tPercentFilled = tItem.getaProp(#percentFilled)
    if tPercentFilled = void() then
      tUserStatus = float(tItem.getAt(#usercount)) / 25
    else
      tUserStatus = float(tPercentFilled) / 100
    end if
    if tItem.getAt(#nodeType) = 0 then
      me.renderRoomListItem(#cat, i, tTargetImg, tUserStatus)
    else
      me.renderRoomListItem(#room, i, tTargetImg, tUserStatus)
    end if
    if tItem.getAt(#door) = "closed" then
      tLockImg = tLockMemImgA
    else
      if tItem.getAt(#door) = "password" then
        tLockImg = tLockMemImgB
      else
        tLockImg = 0
      end if
    end if
    if tLockImg <> 0 then
      tSrcRect = tLockImg.rect
      tLocV = i - 1 * me.pListItemHeight
      tdestrect = tSrcRect + rect(7, tLocV + 5, 7, tLocV + 5)
      tTargetImg.copyPixels(tLockImg, tdestrect, tSrcRect, [#ink:36])
    end if
    i = 1 + i
  end repeat
  tNameImage = pWriterPrivPlain.render(tNameTxt)
  tTargetImg.copyPixels(tNameImage, tNameImage.rect + rect(17, -5, 17, -5), tNameImage.rect)
  return(tTargetImg)
end

on renderRoomListItem me, ttype, tNum, tTargetImg, tUserStatus 
  if tUserStatus = 0 then
    tBackImgId = 1
  else
    if tUserStatus < 0.34 then
      tBackImgId = 2
    else
      if tUserStatus < 0.78 then
        tBackImgId = 3
      else
        tBackImgId = 4
      end if
    end if
  end if
  if ttype = #room then
    tBackImg = me.getProp(#pRoomBackImages, tBackImgId)
  else
    tBackImg = me.getProp(#pCatBackImages, tBackImgId)
  end if
  tLocV = tNum - 1 * me.pListItemHeight
  tdestrect = tBackImg.rect + rect(0, tLocV, 0, tLocV)
  tTargetImg.copyPixels(tBackImg, tdestrect, tBackImg.rect)
  if ttype = #room then
    tX1 = tBackImg.width - pGoLinkTextImg.width - 12
    tX2 = tBackImg.width + pGoLinkTextImg.width
    tY1 = 3 + tLocV
    tY2 = tBackImg.width + pGoLinkTextImg.height
    tdestrect = rect(tX1, tY1, tX2, tY2)
    me.pGoLinkTextImg.copyPixels(tdestrect, me, pGoLinkTextImg.rect, [#bgColor:rgb("#DDDDDD"), #ink:36])
  else
    tX1 = tBackImg.width - pOpenLinkTextImg.width - 27
    tX2 = tBackImg.width + pOpenLinkTextImg.width
    tY1 = 3 + tLocV
    tY2 = tBackImg.width + pOpenLinkTextImg.height
    tdestrect = rect(tX1, tY1, tX2, tY2)
    me.pOpenLinkTextImg.copyPixels(tdestrect, me, pOpenLinkTextImg.rect, [#bgColor:rgb("#DDDDDD"), #ink:36])
  end if
  return(1)
end

on setRoomInfoArea me, tstate 
  if not windowExists(me.pWindowTitle) then
    return(0)
  end if
  if me.getProperty(#roomInfoState) = void() then
    me.setProperty(#roomInfoState, #show)
  end if
  if tstate = me.getProperty(#roomInfoState) then
    return(0)
  end if
  me.setProperty(#roomInfoState, tstate)
  if tstate = #hide then
    me.setProperty(#viewedNodeId, void())
  end if
  tWndObj = getWindow(me.pWindowTitle)
  tScaleElemList = [tWndObj.getElement("nav_roomlist"), tWndObj.getElement("nav_scrollbar"), tWndObj.getElement("nav_roomlistArea")]
  tOffset = pRoomInfoHeight
  if tstate = #show then
    tOffset = -tOffset
  end if
  call(#resizeBy, tScaleElemList, 0, tOffset)
  return(1)
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
    return(0)
  end if
  tElem = getWindow(me.pWindowTitle).getElement(tTempElementId)
  tWidth = tElem.getProperty(#width)
  tHeight = tElem.getProperty(#height)
  tTempImg = image(tWidth, tHeight, pBufferDepth)
  tTextImg = pWriterPlainBoldCent.render(getText("loading"))
  tOffX = tWidth - tTextImg.width / 2
  tOffY = tHeight - tTextImg.height / 2
  tDstRect = tTextImg.rect + rect(tOffX, tOffY, tOffX, tOffY)
  tTempImg.copyPixels(tTextImg, tDstRect, tTextImg.rect)
  tElem.feedImage(tTempImg)
  return(1)
end

on flipImage me, tImg_a 
  tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth)
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return(tImg_b)
end
