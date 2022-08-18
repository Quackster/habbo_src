property pFriendListWindowID, pMaxCategories, pMaxFreeCategories, pWindowDefaultHeight, pViewsList, pCurrentCategoryID, pRemoveConfirmID, pConfirmDeleteFriend, pMinimized, pCategoryHighlBaseID, pHighlightedCategories

on construct me
  pFriendListWindowID = getUniqueID()
  pRemoveConfirmID = getText("friend_list_confirm_remove")
  pConfirmDeleteFriend = VOID
  pCurrentCategoryID = getVariable("fr.window.default.category.id")
  pMaxFreeCategories = getVariable("fr.window.max.free.categories")
  pMaxCategories = (pMaxFreeCategories + 3)
  pMinimized = 0
  pViewsList = [:]
  pCategoryHighlBaseID = "fr_category_highlighter_"
  pHighlightedCategories = []
  registerMessage(#toggle_friend_list, me.getID(), #toggleFriendList)
  return 1
end

on deconstruct me
  if windowExists(pFriendListWindowID) then
    removeWindow(pFriendListWindowID)
  end if
  unregisterMessage(#toggle_friend_list)
  return 1
end

on createFriendList me
  if not me.getComponent().isFriendListInited() then
    return 0
  end if
  if windowExists(pFriendListWindowID) then
    return 0
  end if
  createWindow(pFriendListWindowID, "friends_list_base.window")
  tWndObj = getWindow(pFriendListWindowID)
  tWndContentID = (getVariable(("fr.category.content.id." & pCurrentCategoryID)) & ".window")
  tWndObj.merge(tWndContentID)
  tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
  pWindowDefaultHeight = tWndObj.getProperty(#height)
  if not variableExists("url_friend_list_pref") then
    if tWndObj.elementExists("preferences_btn") then
      tWndObj.getElement("preferences_btn").setProperty(#visible, 0)
    end if
  end if
  me.changeCategory(pCurrentCategoryID)
end

on openFriendList me
  if not windowExists(pFriendListWindowID) then
    me.createFriendList()
    tWndObj = getWindow(pFriendListWindowID)
    tWndObj.moveTo(15, 65)
  else
    tWndObj = getWindow(pFriendListWindowID)
    tWndObj.show()
    activateWindow(pFriendListWindowID)
  end if
end

on closeFriendList me
  if windowExists(pFriendListWindowID) then
    tWndObj = getWindow(pFriendListWindowID)
    tWndObj.hide()
  end if
end

on toggleFriendList me
  if not windowExists(pFriendListWindowID) then
    return me.openFriendList()
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
    return 0
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
  return (pCurrentCategoryID = -2)
end

on addFriend me, tFriendData
  tCategoryId = tFriendData[#categoryId]
  tViewObj = me.getViewListObject(tCategoryId)
  if (tViewObj = 0) then
    return 0
  end if
  tViewObj.addFriend(tFriendData)
  me.setCategoryHighlight(tCategoryId)
  if (pCurrentCategoryID = tCategoryId) then
    me.updateOpenCategoryPanel()
  end if
  me.updateCategoryCounts()
end

on addFriendRequest me, tRequest
  tCategoryId = -2
  tViewObj = me.getViewListObject(tCategoryId)
  if (tViewObj = 0) then
    return 0
  end if
  tViewObj.addRequest(tRequest)
  me.setCategoryHighlight(tCategoryId)
  if (pCurrentCategoryID = tCategoryId) then
    me.updateOpenCategoryPanel()
  end if
end

on setCategoryHighlight me, tCategoryId
  tAllowedCategories = getVariableValue("fr.category.highlights.allowed", [])
  if (tAllowedCategories.getOne(tCategoryId) and ((pCurrentCategoryID <> tCategoryId) or pMinimized)) then
    if not pHighlightedCategories.getOne(tCategoryId) then
      pHighlightedCategories.add(tCategoryId)
    end if
    me.showCategoryTitle(tCategoryId, VOID, VOID, VOID)
    tTimeoutID = (pCategoryHighlBaseID & tCategoryId)
    if timeoutExists(tTimeoutID) then
      removeTimeout(tTimeoutID)
    end if
    tTimeoutTime = integer(getVariable("fr.category.highlight.duration"))
    createTimeout(tTimeoutID, tTimeoutTime, #removeCategoryHighlight, me.getID(), tCategoryId, 1)
  end if
end

on removeCategoryHighlight me, tCategoryId
  if pHighlightedCategories.deleteOne(tCategoryId) then
    me.showCategoryTitle(tCategoryId, VOID, VOID, VOID)
  end if
  tTimeoutID = (pCategoryHighlBaseID & tCategoryId)
  if timeoutExists(tTimeoutID) then
    removeTimeout(tTimeoutID)
  end if
end

on updateFriend me, tFriendData
  tViewObj = me.getViewListObject(tFriendData[#categoryId])
  if not (tViewObj = 0) then
    tViewObj.updateFriend(tFriendData)
  end if
  if (pCurrentCategoryID = tFriendData[#categoryId]) then
    me.updateOpenCategoryPanel()
  end if
end

on removeFriend me, tFriendID, tCategory
  tViewObj = me.getViewListObject(tCategory)
  if not (tViewObj = 0) then
    tViewObj.removeFriend(tFriendID)
  end if
  if (pCurrentCategoryID = tCategory) then
    me.updateOpenCategoryPanel()
  end if
end

on updateCategoryCounts me
  tCategoryList = me.getComponent().getCategoryList()
  repeat with tCategory in tCategoryList
    tCount = me.getComponent().getItemCountForcategory(tCategory[#id])
    me.showCategoryTitle(tCategory[#id], VOID, VOID, tCount)
  end repeat
end

on changeCategory me, tCategoryId
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return 0
  end if
  if voidp(tCategoryId) then
    tCategoryId = pCurrentCategoryID
  end if
  me.removeCategoryHighlight(tCategoryId)
  if (tCategoryId <> pCurrentCategoryID) then
    tWndObj.unmerge()
    tContentID = getVariable(("fr.category.content.id." & tCategoryId))
    if not tWndObj.merge((tContentID & ".window")) then
      return error(me, ("Unable to merge content for category" && tCategoryId), #changeCategory, #major)
    end if
  end if
  repeat with tNo = 1 to pMaxFreeCategories
    tElem = tWndObj.getElement(("category_element_" & tNo))
    tElem.hide()
    tElem = tWndObj.getElement(("category_title_" & tNo))
    tElem.hide()
  end repeat
  tCategoryList = me.getComponent().getCategoryList()
  tCategoryTitleHeight = getVariable("fr.category.height")
  tCategoryContentHeight = tWndObj.getElement("list_panel").getProperty(#height)
  tActionsPanelHeight = tWndObj.getElement("actions_panel").getProperty(#height)
  tCurrentOffsetV = getVariable("fr.category.offset.top")
  repeat with tCategory in tCategoryList
    tCount = me.getComponent().getItemCountForcategory(tCategory[#id])
    me.showCategoryTitle(tCategory[#id], tCurrentOffsetV, tCategory[#name], tCount)
    tCurrentOffsetV = (tCurrentOffsetV + tCategoryTitleHeight)
    if (tCategory[#id] = tCategoryId) then
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
    return 0
  end if
  tViewObj = me.getViewListObject(pCurrentCategoryID)
  if (pCurrentCategoryID = -2) then
    tViewObj.cleanup()
  end if
  tContentElem = tWndObj.getElement("list_panel")
  tListImage = tViewObj.getViewImage()
  tContentElem.feedImage(tListImage)
  me.updateActionIconsState()
end

on showCategoryTitle me, tID, tLocV, tName, tItemCount
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return 0
  end if
  tHighLighted = 0
  if pHighlightedCategories.getOne(tID) then
    tHighLighted = 1
  end if
  tElemBaseName = ("category_element_" & tID)
  if not tWndObj.elementExists(tElemBaseName) then
    return 0
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
  tElemText = tWndObj.getElement(("category_title_" & tID))
  tElemText.show()
  tElemText.setText(tText)
  if tHighLighted then
    tmember = getMember(getVariable("fr.category.background.highlighted"))
    tTextColor = rgb(string(getVariable("fr.category.text.color.highlighted")))
    tElemBase.setProperty(#member, tmember)
    tElemBase.setProperty(#width, getVariable("fr.category.width"))
    tFont = tElemText.getFont()
    tFont[#color] = tTextColor
    tElemText.setFont(tFont)
  else
    if (tID >= 0) then
      if (tItemCount > 0) then
        tmember = getMember(getVariable("fr.category.background.active"))
        tTextColor = rgb(string(getVariable("fr.category.text.color.active")))
      else
        tmember = getMember(getVariable("fr.category.background.inactive"))
        tTextColor = rgb(string(getVariable("fr.category.text.color.inactive")))
      end if
      tElemBase.setProperty(#member, tmember)
      tElemBase.setProperty(#width, getVariable("fr.category.width"))
      tFont = tElemText.getFont()
      tFont[#color] = tTextColor
      tElemText.setFont(tFont)
    else
      if (tID = -2) then
        tmember = getMember(getVariable("fr.category.background.requests"))
        tElemBase.setProperty(#member, tmember)
        tElemBase.setProperty(#width, getVariable("fr.category.width"))
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
    return 0
  end if
  if not tWndObj.elementExists("mail_inbox_icon") then
    return 0
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
    return 0
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
  tActions.add("remove_icon")
  tActions.add("requests_accept_all_text")
  tActions.add("requests_dismiss_all_text")
  tActions.add("requests_accept_all")
  tActions.add("requests_dismiss_all")
  repeat with tElemID in tActions
    if tWndObj.elementExists(tElemID) then
      tElem = tWndObj.getElement(tElemID)
      tOffV = ((tElemBgHeight - tElem.getProperty(#height)) / 2)
      tElem.moveTo(tElem.getProperty(#locH), (tContentBottom + tOffV))
      if pMinimized then
        tElem.setProperty(#visible, 0)
        next repeat
      end if
      tElem.setProperty(#visible, 1)
    end if
  end repeat
end

on updateActionIconsState me
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return 0
  end if
  tViewObj = me.getViewListObject(pCurrentCategoryID)
  if (value(pCurrentCategoryID) >= -1) then
    tSelectedFriends = tViewObj.getSelectedFriends()
    tActions = []
    tActions.add([#icon: "mail_compose_icon", #multiselection: 1])
    tActions.add([#icon: "home_icon", #multiselection: 0])
    tActions.add([#icon: "remove_icon", #multiselection: 0])
    repeat with tElemData in tActions
      tElemName = tElemData[#icon]
      tMulti = tElemData[#multiselection]
      if tWndObj.elementExists(tElemName) then
        tElement = tWndObj.getElement(tElemName)
        if ((tSelectedFriends.count > 1) and (tMulti = 0)) then
          tElement.setProperty(#blend, getVariable("fr.actions.inactive.blend"))
          next repeat
        end if
        if ((tSelectedFriends.count > 1) and (tMulti = 1)) then
          tElement.setProperty(#blend, 100)
          next repeat
        end if
        if (tSelectedFriends.count = 1) then
          tElement.setProperty(#blend, 100)
          next repeat
        end if
        tElement.setProperty(#blend, getVariable("fr.actions.inactive.blend"))
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
      repeat with tElemID in tElems
        if tWndObj.elementExists(tElemID) then
          tElem = tWndObj.getElement(tElemID)
          if (tCount > 0) then
            tElem.setProperty(#blend, 100)
            next repeat
          end if
          tElem.setProperty(#blend, 30)
        end if
      end repeat
    end if
  end if
end

on getViewListObject me, tCategoryId
  tCategoryId = string(tCategoryId)
  if (pViewsList.getaProp(tCategoryId) = VOID) then
    tViewObj = me.createListViewObject(tCategoryId)
    if (tCategoryId > -2) then
      tCategoryContent = me.getComponent().getFriendsInCategory(tCategoryId)
      tViewObj.setListData(tCategoryContent)
    end if
    pViewsList[tCategoryId] = tViewObj
  else
    tViewObj = pViewsList[tCategoryId]
  end if
  return tViewObj
end

on createListViewObject me, tCategoryId
  tObjID = ("list_view_object_" & tCategoryId)
  if (tCategoryId >= 0) then
    createObject(tObjID, ["Friend List View Base", "Friend List Actions Base", "Friend Online List View"])
  else
    if (tCategoryId = "-1") then
      createObject(tObjID, ["Friend List View Base", "Friend List Actions Base", "Friend Offline List View"])
    else
      if (tCategoryId = "-2") then
        createObject(tObjID, ["Friend List View Base", "Friend Request List View"])
      end if
    end if
  end if
  tObj = getObject(tObjID)
  return tObj
end

on showConfirmRemoveUser me
  if windowExists(pRemoveConfirmID) then
    return 0
  end if
  if not createWindow(pRemoveConfirmID, "habbo_basic.window", 200, 120) then
    return error(me, "Couldn't create confirmation window!", #showConfirmRemoveUser, #major)
  end if
  tWndObj = getWindow(pRemoveConfirmID)
  tMsgA = getText("friend_list_confirm_remove_1")
  tMsgB = getText("friend_list_confirm_remove_2")
  if (ilk(pConfirmDeleteFriend) = #propList) then
    tMsgB = replaceChunks(tMsgB, "%username%", pConfirmDeleteFriend[#name])
  end if
  if not tWndObj.merge("habbo_decision_dialog.window") then
    return tWndObj.close()
  end if
  tWndObj.getElement("habbo_decision_text_a").setText(tMsgA)
  tWndObj.getElement("habbo_decision_text_b").setText(tMsgB)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcConfirm, me.getID(), #mouseUp)
  tWndObj.center()
  return 1
end

on hideConfirmRemoveUser me
  if windowExists(pRemoveConfirmID) then
    removeWindow(pRemoveConfirmID)
  end if
end

on handleListPanelEvent me, tEvent, tLocX, tLocY
  tWndObj = getWindow(pFriendListWindowID)
  if (tWndObj = 0) then
    return 0
  end if
  tViewObj = me.getViewListObject(pCurrentCategoryID)
  tEventData = tViewObj.relayEvent(tEvent, tLocX, tLocY)
  if (ilk(tEventData) <> #propList) then
    return 0
  end if
  if voidp(tEventData.getaProp(#element)) then
    return 0
  end if
  tFriend = tEventData[#friend]
  tListElement = tEventData[#element]
  case tListElement of
    #im:
      executeMessage(#startIMChat, tFriend[#name], EMPTY)
    #follow:
      tConn = getConnection(getVariable("connection.info.id"))
      tConn.send("FOLLOW_FRIEND", [#integer: integer(tFriend[#id])])
    #request_accept:
      tRequest = tEventData[#request]
      me.getComponent().updateFriendRequest(tRequest, #accepted)
    #request_reject:
      tRequest = tEventData[#request]
      me.getComponent().updateFriendRequest(tRequest, #rejected)
  end case
  if tEventData.getaProp(#update) then
    tListImage = tViewObj.getViewImage()
    tContentElem = tWndObj.getElement("list_panel")
    tContentElem.clearImage()
    tContentElem.feedImage(tListImage)
  end if
  me.updateActionIconsState()
end

on eventProcConfirm me, tEvent, tElemID, tParam
  case tElemID of
    "habbo_decision_ok":
      if (ilk(pConfirmDeleteFriend) = #propList) then
        me.getComponent().sendRemoveFriend(pConfirmDeleteFriend[#id])
        me.hideConfirmRemoveUser()
        pConfirmDeleteFriend = VOID
      end if
    "habbo_decision_cancel", "close":
      me.hideConfirmRemoveUser()
      pConfirmDeleteFriend = VOID
  end case
end

on eventProc me, tEvent, tElemID, tParam
  tWndObj = getWindow(pFriendListWindowID)
  if (tEvent = #mouseUp) then
    case tElemID of
      "friends_btn_close":
        me.closeFriendList()
      "list_panel":
        me.handleListPanelEvent(tEvent, tParam[1], tParam[2])
      "preferences_icon":
        openNetPage(getVariable("link.format.friendlist.pref"))
      "home_icon":
        tViewObj = me.getViewListObject(pCurrentCategoryID)
        tSelectedFriends = tViewObj.getSelectedFriends()
        if ((tSelectedFriends.count = 0) or (tSelectedFriends.count > 1)) then
          return 0
        end if
        tSelectedFriendData = tSelectedFriends[1]
        if variableExists("link.format.userpage") then
          tWebID = tSelectedFriendData.getaProp(#id)
          tDestURL = replaceChunks(getVariable("link.format.userpage"), "%ID%", string(tWebID))
          openNetPage(tDestURL)
        end if
      "mail_compose_icon":
        tViewObj = me.getViewListObject(pCurrentCategoryID)
        tSelectedFriends = tViewObj.getSelectedFriends()
        if (tSelectedFriends.count = 0) then
          return 0
        end if
        tRecipients = EMPTY
        repeat with tFriend in tSelectedFriends
          tRecipients = ((tRecipients & tFriend[#id]) & ",")
        end repeat
        tRecipients = chars(tRecipients, 1, (tRecipients.length - 1))
        if variableExists("link.format.mail.compose") then
          tDestURL = replaceChunks(getVariable("link.format.mail.compose"), "%recipientid%", tRecipients)
          openNetPage(tDestURL)
        end if
      "mail_inbox_icon":
        if variableExists("link.format.mail.inbox") then
          tDestURL = getVariable("link.format.mail.inbox")
          openNetPage(tDestURL)
        end if
      "search_icon":
        if variableExists("link.format.user.search") then
          tDestURL = getVariable("link.format.user.search")
          openNetPage(tDestURL)
        end if
      "remove_icon":
        tViewObj = me.getViewListObject(pCurrentCategoryID)
        tSelectedFriends = tViewObj.getSelectedFriends()
        if ((tSelectedFriends.count = 0) or (tSelectedFriends.count > 1)) then
          return 0
        end if
        tSelectedFriendData = tSelectedFriends[1]
        pConfirmDeleteFriend = tSelectedFriendData.duplicate()
        me.showConfirmRemoveUser()
      "requests_accept_all":
        tViewObj = me.getViewListObject(pCurrentCategoryID)
        tViewObj.handleAll(#accepted)
        me.getComponent().handleAllRequests(#accepted)
        tListImage = tViewObj.getViewImage()
        tContentElem = tWndObj.getElement("list_panel")
        tContentElem.clearImage()
        tContentElem.feedImage(tListImage)
      "requests_dismiss_all":
        tViewObj = me.getViewListObject(pCurrentCategoryID)
        tViewObj.handleAll(#rejected)
        me.getComponent().handleAllRequests(#rejected)
        tListImage = tViewObj.getViewImage()
        tContentElem = tWndObj.getElement("list_panel")
        tContentElem.clearImage()
        tContentElem.feedImage(tListImage)
    end case
    if ((tElemID contains "category_element_") or (tElemID contains "category_title_")) then
      tDelim = the itemDelimiter
      the itemDelimiter = "_"
      tCategoryId = tElemID.item[3]
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
  end if
end
