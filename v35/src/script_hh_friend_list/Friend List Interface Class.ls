property pMaxFreeCategories, pRemoveConfirmID, pFriendListWindowID, pInfoPopupId, pCurrentCategoryID, pMinimized, pHighlightedCategories, pCategoryHighlBaseID, pMaxCategories, pWindowDefaultHeight, pViewsList, pInboxBlinkStep, pConfirmDeleteFriend

on construct me 
  pFriendListWindowID = "Friend List"
  pRemoveConfirmID = getText("friend_list_confirm_remove")
  pConfirmDeleteFriend = void()
  pCurrentCategoryID = getVariable("fr.window.default.category.id")
  pMaxFreeCategories = getVariable("fr.window.max.free.categories")
  pMaxCategories = (pMaxFreeCategories + 4)
  pMinimized = 0
  pViewsList = [:]
  pCategoryHighlBaseID = "fr_category_highlighter_"
  pHighlightedCategories = []
  pInboxBlinkStep = 0
  pInfoPopupId = "friend_infobox_handler"
  registerMessage(#toggle_friend_list, me.getID(), #toggleFriendList)
  registerMessage(#enterRoom, me.getID(), #updateActionIconsState)
  registerMessage(#leaveRoom, me.getID(), #updateActionIconsState)
  registerMessage(#changeRoom, me.getID(), #updateActionIconsState)
  registerMessage(#enterRoomDirect, me.getID(), #updateActionIconsState)
  registerMessage(#gamesystem_constructed, me.getID(), #closeFriendList)
  return TRUE
end

on deconstruct me 
  me.endInboxBlink()
  if windowExists(pRemoveConfirmID) then
    removeWindow(pRemoveConfirmID)
  end if
  if windowExists(pFriendListWindowID) then
    removeWindow(pFriendListWindowID)
  end if
  if objectExists(pInfoPopupId) then
    removeObject(pInfoPopupId)
  end if
  unregisterMessage(#toggle_friend_list, me.getID())
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#enterRoomDirect, me.getID())
  unregisterMessage(#gamesystem_constructed, me.getID())
  return TRUE
end

on createFriendList me 
  if not me.getComponent().isFriendListInited() then
    return FALSE
  end if
  if windowExists(pFriendListWindowID) then
    return FALSE
  end if
  createWindow(pFriendListWindowID, "friends_list_base.window")
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tWndContentID = getVariable("fr.category.content.id." & pCurrentCategoryID) & ".window"
  tWndObj.merge(tWndContentID)
  tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProc, me.getID(), #mouseWithin)
  tWndObj.registerProcedure(#eventProc, me.getID(), #mouseLeave)
  tWndObj.registerProcedure(#eventProc, me.getID(), #keyDown)
  pWindowDefaultHeight = tWndObj.getProperty(#height)
  me.changeCategory(pCurrentCategoryID)
  return TRUE
end

on openFriendList me 
  if not windowExists(pFriendListWindowID) then
    if me.createFriendList() then
      tWndObj = getWindow(pFriendListWindowID)
      tWndObj.moveTo(15, 65)
    else
      return FALSE
    end if
  else
    tWndObj = getWindow(pFriendListWindowID)
    tWndObj.show()
    activateWindowObj(pFriendListWindowID)
  end if
end

on closeFriendList me 
  me.removeInputFieldFocus()
  if objectExists(pInfoPopupId) then
    removeObject(pInfoPopupId)
  end if
  if windowExists(pFriendListWindowID) then
    tWndObj = getWindow(pFriendListWindowID)
    tWndObj.hide()
  end if
end

on toggleFriendList me 
  if not windowExists(pFriendListWindowID) then
    return(me.openFriendList())
  end if
  tWndObj = getWindow(pFriendListWindowID)
  if tWndObj.getProperty(#visible) then
    me.closeFriendList()
  else
    me.openFriendList()
  end if
end

on minimizedView me, tMinimized 
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  if voidp(tMinimized) then
    if (pMinimized = 0) then
      tMinimized = 1
    else
      tMinimized = 0
    end if
  end if
  if tMinimized then
    pMinimized = 1
    me.changeCategory(pCurrentCategoryID)
  else
    pMinimized = 0
    me.changeCategory(pCurrentCategoryID)
  end if
end

on isFriendRequestViewOpen me 
  return((pCurrentCategoryID = -2))
end

on addFriend me, tFriendData, tHoldRender 
  if (tFriendData = 0) then
    return FALSE
  end if
  tCategoryId = tFriendData.getAt(#categoryId)
  tViewObj = me.getViewListObject(tCategoryId)
  if (tViewObj = 0) then
    return FALSE
  end if
  tViewObj.addFriend(tFriendData)
  me.setCategoryHighlight(tCategoryId)
  if not tHoldRender and (pCurrentCategoryID = tCategoryId) then
    me.updateOpenCategoryPanel()
  end if
  me.updateCategoryCounts()
end

on addFriendRequest me, tRequest 
  tCategoryId = -2
  tViewObj = me.getViewListObject(tCategoryId)
  if (tViewObj = 0) then
    return FALSE
  end if
  tViewObj.addRequest(tRequest)
  me.setCategoryHighlight(tCategoryId)
  if (pCurrentCategoryID = tCategoryId) then
    me.updateOpenCategoryPanel()
  end if
end

on setCategoryHighlight me, tCategoryId 
  tAllowedCategories = getVariableValue("fr.category.highlights.allowed", [])
  if tAllowedCategories.getOne(tCategoryId) and pCurrentCategoryID <> tCategoryId or pMinimized then
    if not pHighlightedCategories.getOne(tCategoryId) then
      pHighlightedCategories.add(tCategoryId)
    end if
    me.showCategoryTitle(tCategoryId, void(), void(), void())
    tTimeoutID = pCategoryHighlBaseID & tCategoryId
    if timeoutExists(tTimeoutID) then
      removeTimeout(tTimeoutID)
    end if
    tTimeoutTime = integer(getVariable("fr.category.highlight.duration"))
    createTimeout(tTimeoutID, tTimeoutTime, #removeCategoryHighlight, me.getID(), tCategoryId, 1)
  end if
end

on removeCategoryHighlight me, tCategoryId 
  if pHighlightedCategories.deleteOne(tCategoryId) then
    me.showCategoryTitle(tCategoryId, void(), void(), void())
  end if
  tTimeoutID = pCategoryHighlBaseID & tCategoryId
  if timeoutExists(tTimeoutID) then
    removeTimeout(tTimeoutID)
  end if
end

on updateFriend me, tFriendData, tHoldRender 
  if (tFriendData = 0) then
    return FALSE
  end if
  tViewObj = me.getViewListObject(tFriendData.getAt(#categoryId))
  if not (tViewObj = 0) then
    tViewObj.updateFriend(tFriendData)
  end if
  if tHoldRender then
    return TRUE
  end if
  if (pCurrentCategoryID = tFriendData.getAt(#categoryId)) then
    me.updateOpenCategoryPanel()
  end if
end

on removeFriend me, tFriendID, tCategory, tHoldRender 
  tViewObj = me.getViewListObject(tCategory)
  if not (tViewObj = 0) then
    tViewObj.removeFriend(tFriendID)
  end if
  if tHoldRender then
    return TRUE
  end if
  if (pCurrentCategoryID = tCategory) then
    me.updateOpenCategoryPanel()
  end if
end

on updateCategoryCounts me 
  tCategoryList = me.getComponent().getCategoryList()
  repeat while tCategoryList <= undefined
    tCategory = getAt(undefined, undefined)
    tCount = me.getComponent().getItemCountForcategory(tCategory.getAt(#id))
    me.showCategoryTitle(tCategory.getAt(#id), void(), void(), tCount)
  end repeat
end

on removeInputFieldFocus me 
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  if tWndObj.elementExists("search_input") then
    tWndObj.getElement("search_input").setFocus(0)
  end if
end

on changeCategory me, tCategoryId 
  if objectExists(pInfoPopupId) then
    removeObject(pInfoPopupId)
  end if
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  if voidp(tCategoryId) then
    tCategoryId = pCurrentCategoryID
  end if
  me.removeCategoryHighlight(tCategoryId)
  if tCategoryId <> pCurrentCategoryID then
    if (pCurrentCategoryID = -3) then
      me.removeInputFieldFocus()
    end if
    tWndObj.unmerge()
    tContentID = getVariable("fr.category.content.id." & tCategoryId)
    if not tWndObj.merge(tContentID & ".window") then
      return(error(me, "Unable to merge content for category" && tCategoryId, #changeCategory, #major))
    end if
  end if
  tNo = 1
  repeat while tNo <= pMaxFreeCategories
    tBgElemID = "category_element_" & tNo
    if tWndObj.elementExists(tBgElemID) then
      tElem = tWndObj.getElement(tBgElemID)
      tElem.hide()
    end if
    tTitleElemID = "category_title_" & tNo
    if tWndObj.elementExists(tTitleElemID) then
      tElem = tWndObj.getElement(tTitleElemID)
      tElem.hide()
    end if
    tNo = (1 + tNo)
  end repeat
  tCategoryList = me.getComponent().getCategoryList()
  tCategoryTitleHeight = getVariable("fr.category.height")
  tCategoryContentHeight = tWndObj.getElement("list_panel").getProperty(#height)
  tActionsPanelHeight = tWndObj.getElement("actions_panel").getProperty(#height)
  tCurrentOffsetV = getVariable("fr.category.offset.top")
  repeat while tCategoryList <= undefined
    tCategory = getAt(undefined, tCategoryId)
    tCount = me.getComponent().getItemCountForcategory(tCategory.getAt(#id))
    me.showCategoryTitle(tCategory.getAt(#id), tCurrentOffsetV, tCategory.getAt(#name), tCount)
    tCurrentOffsetV = (tCurrentOffsetV + tCategoryTitleHeight)
    if (tCategory.getAt(#id) = tCategoryId) then
      me.moveCategoryContent(tCurrentOffsetV)
      if not pMinimized then
        tCurrentOffsetV = (((tCurrentOffsetV + tCategoryContentHeight) + tActionsPanelHeight) + 1)
      end if
    end if
  end repeat
  if pMinimized then
    tHiddenAmountPx = (((((pMaxCategories - tCategoryList.count) * tCategoryTitleHeight) + tCategoryContentHeight) + tActionsPanelHeight) + 1)
  else
    tHiddenAmountPx = ((pMaxCategories - tCategoryList.count) * tCategoryTitleHeight)
    if (tCategoryId = -2) then
      executeMessage(#FriendRequestListOpened)
    end if
  end if
  tWndObj.resizeTo(tWndObj.getProperty(#width), (pWindowDefaultHeight - tHiddenAmountPx))
  pCurrentCategoryID = tCategoryId
  me.updateOpenCategoryPanel()
  me.updateActionIconsState()
end

on updateOpenCategoryPanel me 
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tViewObj = me.getViewListObject(pCurrentCategoryID)
  if (pCurrentCategoryID = -2) then
    tViewObj.cleanUp()
  end if
  tContentElem = tWndObj.getElement("list_panel")
  if (pCurrentCategoryID = -3) and (me.getComponent().getHabboSearchLastString() = "") then
    tViewObj.pListImg = image(1, 1, 32)
    tViewObj.pNeedsRender = 0
  end if
  if tViewObj.needsRender() then
    tViewObj.resetRenderFlag()
    tViewObj.renderListImage()
    if tViewObj.hasQueue() then
      receiveUpdate(me.getID())
    else
      tListImage = tViewObj.getViewImage()
      tContentElem.feedImage(tListImage)
    end if
  else
    tListImage = tViewObj.getViewImage()
    tContentElem.feedImage(tListImage)
  end if
  me.updateActionIconsState()
end

on update me 
  tViewObj = me.getViewListObject(pCurrentCategoryID)
  if not tViewObj.hasQueue() then
    removeUpdate(me.getID())
    return TRUE
  end if
  tElem = me.getContentElement()
  if tElem <> 0 then
    tViewObj.update(tElem)
  end if
end

on getContentElement me 
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  return(tWndObj.getElement("list_panel"))
end

on showCategoryTitle me, tID, tLocV, tName, tItemCount 
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tHighLighted = 0
  if pHighlightedCategories.getOne(tID) then
    tHighLighted = 1
  end if
  tElemBaseName = "category_element_" & tID
  if not tWndObj.elementExists(tElemBaseName) then
    return FALSE
  end if
  tElemBase = tWndObj.getElement(tElemBaseName)
  tElemBase.show()
  if voidp(tName) then
    tName = me.getComponent().getCategoryName(tID)
  end if
  if voidp(tItemCount) then
    tItemCount = me.getComponent().getItemCountForcategory(tID)
  end if
  tText = getVariable("fr.category.title.template")
  tText = replaceChunks(tText, "%name%", tName)
  tText = replaceChunks(tText, "%count%", tItemCount)
  tElemText = tWndObj.getElement("category_title_" & tID)
  tElemText.show()
  tElemText.setText(tText)
  if tHighLighted then
    tmember = getMember(getVariable("fr.category.background.highlighted"))
    tTextColor = rgb(string(getVariable("fr.category.text.color.highlighted")))
    tElemBase.setProperty(#member, tmember)
    tElemBase.setProperty(#width, getVariable("fr.category.width"))
    tFont = tElemText.getFont()
    tFont.setAt(#color, tTextColor)
    tElemText.setFont(tFont)
  else
    if tID >= 0 then
      if tItemCount > 0 then
        tmember = getMember(getVariable("fr.category.background.active"))
        tTextColor = rgb(string(getVariable("fr.category.text.color.active")))
      else
        tmember = getMember(getVariable("fr.category.background.inactive"))
        tTextColor = rgb(string(getVariable("fr.category.text.color.inactive")))
      end if
      tElemBase.setProperty(#member, tmember)
      tElemBase.setProperty(#width, getVariable("fr.category.width"))
      tFont = tElemText.getFont()
      tFont.setAt(#color, tTextColor)
      tElemText.setFont(tFont)
    else
      if (tID = -2) then
        tmember = getMember(getVariable("fr.category.background.requests"))
        tElemBase.setProperty(#member, tmember)
        tElemBase.setProperty(#width, getVariable("fr.category.width"))
        tTextColor = rgb(string(getVariable("fr.category.text.color.requests")))
        tFont = tElemText.getFont()
        tFont.setAt(#color, tTextColor)
        tElemText.setFont(tFont)
      end if
    end if
  end if
  if not voidp(tLocV) then
    tElemText.moveTo(tElemText.getProperty(#locH), (tLocV + 3))
    tElemBase.moveTo(tElemBase.getProperty(#locH), tLocV)
  end if
end

on activateMailIcon me, tIconIsActive 
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  if not tWndObj.elementExists("mail_inbox_icon") then
    return FALSE
  end if
  tElem = tWndObj.getElement("mail_inbox_icon")
  if tIconIsActive then
    tElem.setProperty(#member, "friends_mini_mail_button_active")
  else
    tElem.setProperty(#member, "friends_mini_mail_button_inactive")
  end if
end

on moveCategoryContent me, tLocV 
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tLocalOffsetV = 0
  tLocalOffsetV = (tLocalOffsetV + getVariable("fr.category.offset.top"))
  tLocalOffsetV = (tLocalOffsetV + getVariable("fr.category.height"))
  tLocV = (tLocV - tLocalOffsetV)
  tElemPanel = tWndObj.getElement("list_panel")
  tElemScroll = tWndObj.getElement("list_scroll")
  tElemBG = tWndObj.getElement("actions_panel")
  tElemPanelBg = tWndObj.getElement("list_panel_bg")
  tElemPanelHeight = tElemPanel.getProperty(#height)
  tElemBgHeight = tElemBG.getProperty(#height)
  if pMinimized then
    tElemPanel.setProperty(#visible, 0)
    tElemScroll.setProperty(#visible, 0)
    tElemBG.setProperty(#visible, 0)
    tElemPanelBg.setProperty(#visible, 0)
    tContentBottom = (tElemPanel.getProperty(#locV) + tElemPanelHeight)
  else
    tElemPanel.setProperty(#visible, 1)
    tElemScroll.setProperty(#visible, 1)
    tElemBG.setProperty(#visible, 1)
    tElemPanelBg.setProperty(#visible, 1)
    tElemPanel.moveTo(tElemPanel.getProperty(#locH), tLocV)
    tElemScroll.moveTo(tElemScroll.getProperty(#locH), tLocV)
    tElemPanelBg.moveTo(tElemScroll.getProperty(#locH), tLocV)
    tContentBottom = (tElemPanel.getProperty(#locV) + tElemPanelHeight)
    tElemBG.moveTo(tElemBG.getProperty(#locH), tContentBottom)
  end if
  tActions = []
  tActions.add("mail_compose_icon")
  tActions.add("home_icon")
  tActions.add("invite_icon")
  tActions.add("remove_icon")
  tActions.add("requests_accept_all_text")
  tActions.add("requests_dismiss_all_text")
  tActions.add("requests_accept_all")
  tActions.add("requests_dismiss_all")
  tActions.add("search_button")
  tActions.add("search_button_text")
  tActions.add("search_input")
  repeat while tActions <= undefined
    tElemID = getAt(undefined, tLocV)
    if tWndObj.elementExists(tElemID) then
      tElem = tWndObj.getElement(tElemID)
      tRect = tElem.getProperty(#rect)
      tOffV = ((tElemBgHeight - tElem.getProperty(#height)) / 2)
      tElem.moveTo(tElem.getProperty(#locH), (tContentBottom + tOffV))
      if pMinimized then
        tElem.setProperty(#visible, 0)
      else
        tElem.setProperty(#visible, 1)
      end if
    end if
  end repeat
end

on updateActionIconsState me 
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tViewObj = me.getViewListObject(pCurrentCategoryID)
  if value(pCurrentCategoryID) >= -1 then
    tSelectedFriends = tViewObj.getSelectedFriends()
    tInvitesInUse = 0
    if variableExists("client.use.invites") then
      if (getVariable("client.use.invites") = 1) then
        tInvitesInUse = 1
      end if
    end if
    tActions = []
    tActions.add([#icon:"mail_compose_icon", #multiselection:1, #allowedroom:#all, #used:1])
    tActions.add([#icon:"invite_icon", #multiselection:1, #allowedroom:#room, #used:tInvitesInUse])
    tActions.add([#icon:"home_icon", #multiselection:0, #allowedroom:#all, #used:1])
    tActions.add([#icon:"remove_icon", #multiselection:0, #allowedroom:#all, #used:1])
    repeat while tActions <= undefined
      tElemData = getAt(undefined, undefined)
      tElemName = tElemData.getAt(#icon)
      tMulti = tElemData.getAt(#multiselection)
      if tWndObj.elementExists(tElemName) then
        tElement = tWndObj.getElement(tElemName)
        if tSelectedFriends.count > 1 and (tMulti = 0) then
          tElement.setProperty(#blend, getVariable("fr.actions.inactive.blend"))
        else
          if tSelectedFriends.count > 1 and (tMulti = 1) then
            tElement.setProperty(#blend, 100)
          else
            if (tSelectedFriends.count = 1) then
              tElement.setProperty(#blend, 100)
            else
              tElement.setProperty(#blend, getVariable("fr.actions.inactive.blend"))
            end if
          end if
        end if
        tSession = getObject(#session)
        if (tSession.GET("lastroom") = "Entry") then
          if tElemData.getAt(#allowedroom) <> #all then
            tElement.setProperty(#blend, getVariable("fr.actions.inactive.blend"))
          end if
        end if
        if not tElemData.getAt(#used) then
          tElement.setProperty(#visible, 0)
        end if
      end if
    end repeat
  else
    if (value(pCurrentCategoryID) = -2) then
      tElems = []
      tElems.add("requests_dismiss_all")
      tElems.add("requests_dismiss_all_text")
      tElems.add("requests_accept_all")
      tElems.add("requests_accept_all_text")
      tRequests = me.getComponent().getPendingFriendRequests()
      tCount = 0
      if (ilk(tRequests) = #propList) then
        tCount = tRequests.count
      end if
      repeat while tActions <= undefined
        tElemID = getAt(undefined, undefined)
        if tWndObj.elementExists(tElemID) then
          tElem = tWndObj.getElement(tElemID)
          if tCount > 0 then
            tElem.setProperty(#blend, 100)
          else
            tElem.setProperty(#blend, 30)
          end if
        end if
      end repeat
    end if
  end if
end

on getViewListObject me, tCategoryId 
  tCategoryId = string(tCategoryId)
  if (pViewsList.getaProp(tCategoryId) = void()) then
    tViewObj = me.createListViewObject(tCategoryId)
    if tCategoryId > -2 then
      tCategoryContent = me.getComponent().getFriendsInCategory(tCategoryId)
      tViewObj.setListData(tCategoryContent)
    end if
    pViewsList.setAt(tCategoryId, tViewObj)
  else
    tViewObj = pViewsList.getAt(tCategoryId)
  end if
  return(tViewObj)
end

on createListViewObject me, tCategoryId 
  tObjID = "list_view_object_" & tCategoryId
  if tCategoryId >= 0 then
    createObject(tObjID, ["Friend List View Base", "Friend List Actions Base", "Friend Online List View"])
  else
    if (tCategoryId = "-1") then
      createObject(tObjID, ["Friend List View Base", "Friend List Actions Base", "Friend Offline List View"])
    else
      if (tCategoryId = "-2") then
        createObject(tObjID, ["Friend List View Base", "Friend Request List View"])
      else
        if (tCategoryId = "-3") then
          createObject(tObjID, ["Friend List View Base", "Friend Search Results View"])
        end if
      end if
    end if
  end if
  tObj = getObject(tObjID)
  return(tObj)
end

on showInfoPopup me, tFriend, tWndX, tWndY, tContentElem 
  tObject = me.getInfoPopupObject()
  if (tObject = 0) then
    return FALSE
  end if
  return(tObject.showInfoPopup(tFriend, tWndX, tWndY, tContentElem))
end

on removeInfoPopup me 
  tObject = me.getInfoPopupObject()
  if (tObject = 0) then
    return FALSE
  end if
  return(tObject.removeInfoPopup())
end

on getInfoPopupObject me 
  if not objectExists(pInfoPopupId) then
    createObject(pInfoPopupId, "Friend Infobox Class")
  end if
  return(getObject(pInfoPopupId))
end

on startInboxBlink me 
  tTimeoutID = "minimail_blink"
  tBlinkTime = 1000
  if not timeoutExists(tTimeoutID) then
    createTimeout(tTimeoutID, tBlinkTime, #stepInboxBlink, me.getID(), void(), 0)
  end if
end

on endInboxBlink me 
  tTimeoutID = "minimail_blink"
  if timeoutExists(tTimeoutID) then
    removeTimeout(tTimeoutID)
  end if
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  if tWndObj.elementExists("mail_inbox_icon") then
    tElem = tWndObj.getElement("mail_inbox_icon")
    tElem.setProperty(#member, "friends_mini_mail_button_inactive")
  end if
end

on stepInboxBlink me 
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  if tWndObj.elementExists("mail_inbox_icon") then
    tElem = tWndObj.getElement("mail_inbox_icon")
    if pInboxBlinkStep > 0 then
      tElem.setProperty(#member, "friends_mini_mail_button_active")
      pInboxBlinkStep = 0
    else
      tElem.setProperty(#member, "friends_mini_mail_button_inactive")
      pInboxBlinkStep = (pInboxBlinkStep + 1)
    end if
  end if
end

on setTipText me, tText 
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElemID = "friends_tooltip"
  if not tWndObj.elementExists(tElemID) then
    return FALSE
  end if
  tElem = tWndObj.getElement(tElemID)
  tElem.setText(tText)
end

on showConfirmRemoveUser me 
  if windowExists(pRemoveConfirmID) then
    return FALSE
  end if
  if not createWindow(pRemoveConfirmID, "habbo_basic.window", 200, 120) then
    return(error(me, "Couldn't create confirmation window!", #showConfirmRemoveUser, #major))
  end if
  tWndObj = getWindow(pRemoveConfirmID)
  tMsgA = getText("friend_list_confirm_remove_1")
  tMsgB = getText("friend_list_confirm_remove_2")
  if (ilk(pConfirmDeleteFriend) = #propList) then
    tMsgB = replaceChunks(tMsgB, "%username%", pConfirmDeleteFriend.getAt(#name))
  end if
  if not tWndObj.merge("habbo_decision_dialog.window") then
    return(tWndObj.close())
  end if
  tWndObj.getElement("habbo_decision_text_a").setText(tMsgA)
  tWndObj.getElement("habbo_decision_text_b").setText(tMsgB)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcConfirm, me.getID(), #mouseUp)
  tWndObj.center()
  return TRUE
end

on hideConfirmRemoveUser me 
  if windowExists(pRemoveConfirmID) then
    removeWindow(pRemoveConfirmID)
  end if
end

on showHabboSearchResults me 
  tViewObj = me.getViewListObject(-3)
  tViewObj.setListData(me.getComponent().getHabboSearchResults())
  me.updateOpenCategoryPanel()
  me.updateActionIconsState()
end

on handleListPanelEvent me, tEvent, tLocX, tLocY 
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  if (tEvent = #mouseLeave) then
    return(me.removeInfoPopup())
  end if
  tViewObj = me.getViewListObject(pCurrentCategoryID)
  if (tViewObj = 0) then
    return(error(me, "View List Object not found.", #handleListPanelEvent, #major))
  end if
  tEventData = tViewObj.relayEvent(tEvent, tLocX, tLocY)
  if ilk(tEventData) <> #propList then
    return FALSE
  end if
  tContentElem = tWndObj.getElement("list_panel")
  if (tContentElem = 0) then
    return FALSE
  end if
  tFriend = tEventData.getAt(#friend)
  tListElement = tEventData.getAt(#element)
  if (tEventData.getAt(#Event) = #mouseWithin) then
    tCursor = "cursor.arrow"
    if (ilk(tEventData.getaProp(#cursor)) = #string) then
      tCursor = tEventData.getaProp(#cursor)
    end if
    tContentElem.setProperty(#cursor, tCursor)
    tWndX = tWndObj.getProperty(#locX)
    tWndY = tWndObj.getProperty(#locY)
    tScrollElem = tWndObj.getElement("list_scroll")
    if tScrollElem <> 0 then
      tWndY = (tWndY - tScrollElem.getScrollOffset())
      tEventData.setAt(#item_y, (tEventData.getAt(#item_y) - tScrollElem.getScrollOffset()))
    end if
    me.showInfoPopup(tEventData, tWndX, tWndY, tContentElem)
    if (tListElement = #mail) then
      me.setTipText(getText("friend_tip_mail"))
    else
      if (tListElement = #im) then
        me.setTipText(getText("friend_tip_im"))
      else
        if (tListElement = #follow) then
          me.setTipText(getText("friend_tip_follow"))
        else
          if (tListElement = #addFriend) then
            me.setTipText(getText("friend_tip_addfriend"))
          else
            me.setTipText("")
          end if
        end if
      end if
    end if
    return TRUE
  end if
  if voidp(tEventData.getaProp(#element)) then
    return FALSE
  end if
  if (tListElement = #im) then
    executeMessage(#startIMChat, tFriend.getAt(#name), "")
  else
    if (tListElement = #follow) then
      tConn = getConnection(getVariable("connection.info.id"))
      tConn.send("FOLLOW_FRIEND", [#integer:integer(tFriend.getAt(#id))])
    else
      if (tListElement = #request_accept) then
        tRequest = tEventData.getAt(#request)
        me.getComponent().updateFriendRequest(tRequest, #accepted)
      else
        if (tListElement = #request_reject) then
          tRequest = tEventData.getAt(#request)
          me.getComponent().updateFriendRequest(tRequest, #rejected)
        else
          if (tListElement = #mail) then
            if variableExists("link.format.mail.compose") then
              tDestURL = replaceChunks(getVariable("link.format.mail.compose"), "%recipientid%", tFriend.getAt(#id))
              openNetPage(tDestURL)
              executeMessage(#externalLinkClick, the mouseLoc)
            end if
          else
            if (tListElement = #addFriend) then
              me.getComponent().externalFriendRequest(tFriend.getAt(#name))
            end if
          end if
        end if
      end if
    end if
  end if
  if tEventData.getaProp(#update) then
    tListImage = tViewObj.getViewImage()
    tContentElem.clearImage()
    tContentElem.feedImage(tListImage)
  end if
  me.updateActionIconsState()
end

on eventProcConfirm me, tEvent, tElemID, tParam 
  if (tElemID = "habbo_decision_ok") then
    if (ilk(pConfirmDeleteFriend) = #propList) then
      me.getComponent().sendRemoveFriend(pConfirmDeleteFriend.getAt(#id))
      me.hideConfirmRemoveUser()
      pConfirmDeleteFriend = void()
    end if
  else
    if tElemID <> "habbo_decision_cancel" then
      if (tElemID = "close") then
        me.hideConfirmRemoveUser()
        pConfirmDeleteFriend = void()
      end if
    end if
  end if
end

on eventProc me, tEvent, tElemID, tParam 
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  if (tEvent = #mouseUp) then
    me.removeInfoPopup()
    tloc = the mouseLoc
    if (tElemID = "friends_btn_close") then
      me.closeFriendList()
    else
      if (tElemID = "friends_btn_minimize") then
        me.minimizedView()
      else
        if (tElemID = "list_panel") then
          if ilk(tParam) <> #point then
            return FALSE
          end if
          me.handleListPanelEvent(tEvent, tParam.getAt(1), tParam.getAt(2))
        else
          if (tElemID = "preferences_icon") then
            openNetPage(getVariable("link.format.friendlist.pref"))
            executeMessage(#externalLinkClick, tloc)
          else
            if (tElemID = "home_icon") then
              tViewObj = me.getViewListObject(pCurrentCategoryID)
              tSelectedFriends = tViewObj.getSelectedFriends()
              if (tSelectedFriends.count = 0) or tSelectedFriends.count > 1 then
                return FALSE
              end if
              tSelectedFriendData = tSelectedFriends.getAt(1)
              if variableExists("link.format.userpage") then
                tWebID = tSelectedFriendData.getaProp(#id)
                tDestURL = replaceChunks(getVariable("link.format.userpage"), "%ID%", string(tWebID))
                openNetPage(tDestURL)
                executeMessage(#externalLinkClick, tloc)
              end if
            else
              if (tElemID = "mail_compose_icon") then
                tViewObj = me.getViewListObject(pCurrentCategoryID)
                tSelectedFriends = tViewObj.getSelectedFriends()
                if (tSelectedFriends.count = 0) then
                  return FALSE
                end if
                tRecipients = ""
                repeat while tElemID <= tElemID
                  tFriend = getAt(tElemID, tEvent)
                  tRecipients = tRecipients & tFriend.getAt(#id) & ","
                end repeat
                tRecipients = chars(tRecipients, 1, (tRecipients.length - 1))
                if variableExists("link.format.mail.compose") then
                  tDestURL = replaceChunks(getVariable("link.format.mail.compose"), "%recipientid%", tRecipients)
                  openNetPage(tDestURL)
                  executeMessage(#externalLinkClick, tloc)
                end if
              else
                if (tElemID = "invite_icon") then
                  tViewObj = me.getViewListObject(pCurrentCategoryID)
                  tSelectedFriends = tViewObj.getSelectedFriends()
                  if (tSelectedFriends.count = 0) then
                    return FALSE
                  end if
                  tFriendIds = []
                  repeat while tElemID <= tElemID
                    tFriend = getAt(tElemID, tEvent)
                    tID = tFriend.getAt(#id)
                    tFriendIds.add(tID)
                  end repeat
                  if threadExists(#instant_messenger) then
                    tIMComponent = getThread(#instant_messenger).getComponent()
                    tIMComponent.inviteFriends(tFriendIds)
                  end if
                else
                  if (tElemID = "mail_inbox_icon") then
                    if variableExists("link.format.mail.inbox") then
                      tDestURL = getVariable("link.format.mail.inbox")
                      openNetPage(tDestURL)
                      executeMessage(#externalLinkClick, tloc)
                    end if
                  else
                    if (tElemID = "search_icon") then
                      if variableExists("link.format.user.search") then
                        tDestURL = getVariable("link.format.user.search")
                        openNetPage(tDestURL)
                        executeMessage(#externalLinkClick, tloc)
                      end if
                    else
                      if (tElemID = "remove_icon") then
                        tViewObj = me.getViewListObject(pCurrentCategoryID)
                        tSelectedFriends = tViewObj.getSelectedFriends()
                        if (tSelectedFriends.count = 0) or tSelectedFriends.count > 1 then
                          return FALSE
                        end if
                        tSelectedFriendData = tSelectedFriends.getAt(1)
                        pConfirmDeleteFriend = tSelectedFriendData.duplicate()
                        me.showConfirmRemoveUser()
                      else
                        if (tElemID = "requests_accept_all") then
                          tViewObj = me.getViewListObject(pCurrentCategoryID)
                          tViewObj.handleAll(#accepted)
                          me.getComponent().handleAllRequests(#accepted)
                          tListImage = tViewObj.getViewImage()
                          tContentElem = tWndObj.getElement("list_panel")
                          tContentElem.clearImage()
                          tContentElem.feedImage(tListImage)
                        else
                          if (tElemID = "requests_dismiss_all") then
                            tViewObj = me.getViewListObject(pCurrentCategoryID)
                            tViewObj.handleAll(#rejected)
                            me.getComponent().handleAllRequests(#rejected)
                            tListImage = tViewObj.getViewImage()
                            tContentElem = tWndObj.getElement("list_panel")
                            tContentElem.clearImage()
                            tContentElem.feedImage(tListImage)
                          else
                            if tElemID <> "search_button" then
                              if (tElemID = "search_button_text") then
                                tViewObj = me.getViewListObject(pCurrentCategoryID)
                                tSearchString = tWndObj.getElement("search_input").getText()
                                me.getComponent().sendHabboSearch(tSearchString)
                              end if
                              if tElemID contains "category_element_" or tElemID contains "category_title_" then
                                tDelim = the itemDelimiter
                                the itemDelimiter = "_"
                                tCategoryId = tElemID.getProp(#item, 3)
                                the itemDelimiter = tDelim
                                if pMinimized then
                                  me.minimizedView(0)
                                  me.changeCategory(tCategoryId)
                                else
                                  if (tCategoryId = pCurrentCategoryID) then
                                    me.minimizedView(1)
                                  else
                                    me.changeCategory(tCategoryId)
                                  end if
                                end if
                              end if
                              if (tEvent = #mouseWithin) then
                                if tWndObj.elementExists("friends_tooltip") then
                                  tElemTooltip = tWndObj.getElement("friends_tooltip")
                                  if (tElemID = "home_icon") then
                                    me.setTipText(getText("friend_tip_home"))
                                  else
                                    if (tElemID = "mail_compose_icon") then
                                      me.setTipText(getText("friend_tip_compose"))
                                    else
                                      if (tElemID = "invite_icon") then
                                        me.setTipText(getText("friend_tip_invite"))
                                      else
                                        if (tElemID = "remove_icon") then
                                          me.setTipText(getText("friend_tip_remove"))
                                        else
                                          if (tElemID = "preferences_icon") then
                                            me.setTipText(getText("friend_tip_preferences"))
                                          else
                                            if (tElemID = "search_icon") then
                                              me.setTipText(getText("friend_tip_search"))
                                            else
                                              if (tElemID = "mail_inbox_icon") then
                                                me.setTipText(getText("friend_tip_inbox"))
                                              else
                                                if tElemID <> "search_button" then
                                                  if (tElemID = "search_button_text") then
                                                    me.setTipText(getText("friend_tip_search_button"))
                                                  else
                                                    if (tElemID = "search_input") then
                                                      me.setTipText(getText("friend_tip_search_input"))
                                                    else
                                                      if (tElemID = "list_panel") then
                                                        if ilk(tParam) <> #point then
                                                          return FALSE
                                                        end if
                                                        me.handleListPanelEvent(tEvent, tParam.getAt(1), tParam.getAt(2))
                                                      else
                                                        me.setTipText("")
                                                      end if
                                                    end if
                                                  end if
                                                  if (tEvent = #mouseLeave) then
                                                    me.setTipText("")
                                                    if (tElemID = "list_panel") then
                                                      me.handleListPanelEvent(tEvent)
                                                    end if
                                                  else
                                                    if (tEvent = #keyDown) then
                                                      if (tElemID = "search_input") then
                                                        if tElemID <> 36 then
                                                          if (tElemID = 76) then
                                                            me.eventProc(#mouseUp, "search_button")
                                                            return TRUE
                                                          else
                                                            return FALSE
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
