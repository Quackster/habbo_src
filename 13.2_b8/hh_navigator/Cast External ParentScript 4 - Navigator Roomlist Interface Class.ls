property pStrLastFlatSearch, pFlatPasswords, pFlatInfoAction, pModifyFlatInfo, pDoorStatusModified

on construct me
  pStrLastFlatSearch = EMPTY
  pFlatInfoAction = 0
  pDoorStatusModified = 0
  return 1
end

on deconstruct me
  return 1
end

on showSpaceNodeUsers me, tNodeId, tUserList
  tUsersStr = EMPTY
  repeat with i = 1 to tUserList.count
    tUsersStr = tUsersStr & tUserList[i]
    if i < tUserList.count then
      tUsersStr = tUsersStr & ", "
    end if
  end repeat
  pWinId = getText("nav_people")
  if not createWindow(pWinId, "habbo_basic.window") then
    return 0
  end if
  tWndObj = getWindow(pWinId)
  if not tWndObj.merge("habbo_alert_b.window") then
    return tWndObj.close()
  end if
  tTextImg = me.pWriterPlainNormWrap.render(tUsersStr)
  tWndObj.getElement("alert_text").feedImage(tTextImg)
  tWndObj.resizeTo(tTextImg.width + 50, tTextImg.height + 100)
  tWndObj.registerProcedure(#hideSpaceNodeUsers, me.getID(), #mouseUp)
  return 1
end

on hideSpaceNodeUsers me
  return removeWindow(getText("nav_people"))
end

on getPasswordFromField me, tElementId
  tPwd = pFlatPasswords[tElementId]
  return tPwd
end

on flatPasswordIncorrect me
  me.ChangeWindowView("nav_gr_passwordincorrect")
end

on checkFlatAccess me, tFlatData
  if tFlatData[#owner] = getObject(#session).GET("user_name") then
    tDoor = "open"
  else
    tDoor = tFlatData[#door]
    pFlatPasswords = [:]
  end if
  case tDoor of
    "password":
      me.ChangeWindowView("nav_gr_password")
      getWindow(me.pWindowTitle).getElement("nav_roomname_text").setText(tFlatData[#name])
      me.setProperty(#passwordNodeId, tFlatData[#id])
    otherwise:
      if voidp(tFlatData) then
        return error(me, "Can't enter flat, no room is selected!!!", #processFlatInfo)
      end if
      return me.getComponent().executeRoomEntry(tFlatData[#id])
  end case
  return 1
end

on handleRoomListClicked me, tParm
  tCategoryId = me.getProperty(#categoryId)
  tNodeInfo = me.getComponent().getNodeInfo(tCategoryId)
  if not listp(tNodeInfo) then
    return error(me, "Nodeinfo not found, id:" && tCategoryId, #handleRoomListClicked)
  end if
  tNodeList = tNodeInfo[#children]
  if not listp(tNodeInfo) then
    return error(me, "Node content not found, id:" & tCategoryId, #handleRoomListClicked)
  end if
  tNodeCount = tNodeList.count
  if not ilk(tParm, #point) or (tNodeCount = 0) then
    return 0
  end if
  tClickedLine = integer(tParm.locV / me.pListItemHeight) + 1
  if tClickedLine > tNodeCount then
    tClickedLine = tNodeCount
  end if
  tNodeInfo = tNodeList[tClickedLine]
  if not listp(tNodeInfo) then
    return 0
  end if
  me.setProperty(#viewedNodeId, tNodeInfo[#id])
  tGoLinkH = 255
  if tNodeInfo[#nodeType] = 0 then
    me.setLoadingCursor(1)
    me.getComponent().expandNode(tNodeInfo[#id])
  else
    if the shiftDown then
      if tNodeInfo[#nodeType] = 1 then
        return me.getComponent().sendGetSpaceNodeUsers(tNodeInfo[#id])
      end if
    end if
    me.setLoadingCursor(1)
    if tParm.locH > tGoLinkH then
      me.getComponent().prepareRoomEntry(tNodeInfo[#id])
    else
      me.showNodeInfo(tNodeInfo[#id])
    end if
  end if
  return 1
end

on startFlatSearch me
  tWndObj = getWindow(me.pWindowTitle)
  if tWndObj.elementExists("nav_private_search_field") then
    tSearchQuery = tWndObj.getElement("nav_private_search_field").getText()
    pStrLastFlatSearch = tSearchQuery
    me.clearRoomList()
    if tSearchQuery = EMPTY then
      return me.showRoomlistError(getText("nav_prvrooms_notfound"))
    end if
    me.setLoadingCursor(1)
    me.renderLoadingText()
    return me.getComponent().sendSearchFlats(tSearchQuery)
  end if
end

on showRoomlistError me, tText
  me.setLoadingCursor(0)
  tElem = getWindow(me.pWindowTitle).getElement("nav_roomlist")
  if tElem <> 0 then
    tWidth = tElem.getProperty(#width)
    tHeight = tElem.getProperty(#height)
    tTempImg = image(tWidth, tHeight, 8)
    tTextImg = me.pWriterPlainNormLeft.render(tText)
    tTempImg.copyPixels(tTextImg, tTextImg.rect + rect(8, 5, 8, 5), tTextImg.rect)
    tElem.feedImage(tTempImg)
  end if
end

on modifyPrivateRoom me, tFlatInfo
  if not (tFlatInfo.ilk = #propList) then
    return me.getComponent().getInfoBroker().requestRoomData(tFlatInfo, #private, [me.getID(), #modifyPrivateRoom])
  end if
  tFlatInfo = me.getComponent().getNodeInfo(tFlatInfo[#id], #own)
  if tFlatInfo = 0 then
    return error(me, "Flat info is VOID", #modifyPrivateRoom)
  else
    pModifyFlatInfo = tFlatInfo
  end if
  if tFlatInfo.findPos(#parentid) = VOID then
    registerMessage(#flatcat_received, me.getID(), #modifyPrivateRoom)
    return me.getComponent().sendGetFlatCategory(tFlatInfo[#id])
  end if
  unregisterMessage(#flatcat_received, me.getID())
  pFlatPasswords = [:]
  pDoorStatusModified = 0
  if tFlatInfo[#owner] <> getObject(#session).GET("user_name") then
    return 0
  end if
  me.setModifyFirstPage()
end

on setModifyFirstPage me
  tFlatInfo = pModifyFlatInfo
  me.ChangeWindowView("nav_gr_mod")
  tWndObj = getWindow(me.pWindowTitle)
  tTempProps = [#name: "nav_modify_roomnamefield", #description: "nav_modify_roomdescription_field"]
  repeat with f = 1 to tTempProps.count
    tProp = tTempProps.getPropAt(f)
    tField = tTempProps[tProp]
    if tWndObj.elementExists(tField) then
      if not voidp(tFlatInfo[tProp]) then
        tWndObj.getElement(tField).setText(tFlatInfo[tProp])
      end if
    end if
  end repeat
  tCheckOnImg = member(getmemnum("button.checkbox.on")).image
  tCheckOffImg = member(getmemnum("button.checkbox.off")).image
  if tFlatInfo[#showownername] = 1 then
    me.updateRadioButton("nav_modify_nameshow_yes_radio", ["nav_modify_nameshow_no_radio"])
  else
    me.updateRadioButton("nav_modify_nameshow_no_radio", ["nav_modify_nameshow_yes_radio"])
  end if
  tMaxVisitorsElm = tWndObj.getElement("nav_maxusers_amount")
  tMaxVisitors = pModifyFlatInfo[#maxVisitors]
  tAbsoluteMaxVisitors = pModifyFlatInfo[#absoluteMaxVisitors]
  if tMaxVisitors > tAbsoluteMaxVisitors then
    tMaxVisitors = tAbsoluteMaxVisitors
  end if
  tMaxVisitorsElm.setText(pModifyFlatInfo[#maxVisitors])
end

on setModifySecondPage me
  tFlatInfo = pModifyFlatInfo
  me.ChangeWindowView("nav_gr_mod_b")
  tWndObj = getWindow(me.pWindowTitle)
  case tFlatInfo[#door] of
    "open":
      me.updateRadioButton("nav_modify_door_open_radio", ["nav_modify_door_locked_radio", "nav_modify_door_pw_radio"])
      me.hidePasswordFields(1)
    "closed":
      me.updateRadioButton("nav_modify_door_locked_radio", ["nav_modify_door_open_radio", "nav_modify_door_pw_radio"])
      me.hidePasswordFields(1)
    "password":
      me.updateRadioButton("nav_modify_door_pw_radio", ["nav_modify_door_open_radio", "nav_modify_door_locked_radio"])
      me.hidePasswordFields(0)
  end case
  me.updateCheckButton("nav_modify_furnituremove_check", tFlatInfo[#ableothersmovefurniture])
end

on leaveModifyPage me
  tPage = me.pLastWindowName
  case tPage of
    "nav_gr_mod":
      pModifyFlatInfo[#name] = getWindow(me.pWindowTitle).getElement("nav_modify_roomnamefield").getText()
      pModifyFlatInfo[#description] = getWindow(me.pWindowTitle).getElement("nav_modify_roomdescription_field").getText()
      pModifyFlatInfo[#maxVisitors] = getWindow(me.pWindowTitle).getElement("nav_maxusers_amount").getText()
    "nav_gr_mod_b":
      pModifyFlatInfo[#password] = me.getPasswordFromField("nav_modify_door_pw")
  end case
end

on hidePasswordFields me, tHidden
  tPassWordElements = ["nav_modify_door_pw", "nav_modify_door_pw2", "nav_pwfields", "nav_pwdescr"]
  tWndObj = getWindow(me.pWindowTitle)
  repeat with tElemID in tPassWordElements
    tElem = tWndObj.getElement(tElemID)
    tElem.setProperty(#visible, not tHidden)
  end repeat
end

on checkModifiedFlatPasswords me
  tElementId1 = "nav_modify_door_pw"
  tElementId2 = "nav_modify_door_pw2"
  tPw1 = pFlatPasswords[tElementId1]
  tPw2 = pFlatPasswords[tElementId2]
  if tPw1.length = 0 then
    executeMessage(#alert, [#Msg: "Alert_ForgotSetPassword", #modal: 1])
    return 0
  end if
  if tPw1.length < 3 then
    executeMessage(#alert, [#Msg: "nav_error_passwordtooshort", #modal: 1])
    return 0
  end if
  if tPw1 <> tPw2 then
    executeMessage(#alert, [#Msg: "Alert_WrongPassword", #modal: 1])
    return 0
  end if
  return 1
end

on updateRadioButton me, tElement, tListOfOthersElements
  tOnImg = member(getmemnum("button.radio.on")).image
  tOffImg = member(getmemnum("button.radio.off")).image
  tWndObj = getWindow(me.pWindowTitle)
  if tWndObj.elementExists(tElement) then
    tWndObj.getElement(tElement).feedImage(tOnImg)
  end if
  repeat with tRadioElement in tListOfOthersElements
    if tWndObj.elementExists(tRadioElement) then
      tWndObj.getElement(tRadioElement).feedImage(tOffImg)
    end if
  end repeat
end

on updateCheckButton me, tElement, tstate
  tOnImg = member(getmemnum("button.checkbox.on")).image
  tOffImg = member(getmemnum("button.checkbox.off")).image
  tWndObj = getWindow(me.pWindowTitle)
  if tstate then
    if tWndObj.elementExists(tElement) then
      tWndObj.getElement(tElement).feedImage(tOnImg)
    end if
  else
    if tWndObj.elementExists(tElement) then
      tWndObj.getElement(tElement).feedImage(tOffImg)
    end if
  end if
end

on prepareCategoryDropMenu me, tNodeId
  tWndObj = getWindow(me.pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tDefaultCatId = me.getComponent().getNodeProperty(tNodeId, #parentid)
  tDropDown = tWndObj.getElement("nav_choosecategory")
  if not ilk(tDropDown, #instance) then
    return error(me, "Unable to retrieve dropdown:" && tDropDown, #prepareCategoryDropMenu)
  end if
  tCatProps = getObject(#session).GET("user_flat_cats")
  if not ilk(tCatProps, #propList) then
    return error(me, "Category list was not a property list:" && tCatProps, #prepareCategoryDropMenu)
  end if
  tCatTxtItems = []
  tCatKeyItems = []
  repeat with i = 1 to tCatProps.count
    tCatTxtItems[i] = getAt(tCatProps, i)
    tCatKeyItems[i] = getPropAt(tCatProps, i)
  end repeat
  tDefaultCatItem = tCatKeyItems.getPos(tDefaultCatId)
  if tDefaultCatItem = 0 then
    tDefaultCatItem = 1
  end if
  tDropDown.updateData(tCatTxtItems, tCatKeyItems, tDefaultCatItem)
  return 1
end

on eventProcNavigatorPublic me, tEvent, tSprID, tParm
  if tEvent = #mouseDown then
    case tSprID of
      "nav_closeInfo":
        me.setRoomInfoArea(#hide)
      "nav_tb_guestRooms":
        me.setLoadingCursor(1)
        me.setRoomInfoArea(#show)
        me.ChangeWindowView("nav_gr0")
      "nav_roomlistBackLinks":
        return me.getComponent().expandHistoryItem(integer(tParm.locV / me.pHistoryItemHeight) + 1)
      "nav_roomlist":
        me.handleRoomListClicked(tParm)
      "create_room", "nav_public_helptext":
        return executeMessage(#open_roomkiosk)
    end case
  else
    if tEvent = #mouseUp then
      case tSprID of
        "close":
          return me.hideNavigator(#hide)
        "nav_go_button":
          return me.getComponent().prepareRoomEntry(me.getProperty(#viewedNodeId))
        "nav_addtofavourites_button":
          me.getComponent().sendAddFavoriteFlat(me.getProperty(#viewedNodeId))
          return me.getComponent().sendGetFavoriteFlats()
        "nav_hidefull":
          return me.getComponent().showHideFullRooms(me.getProperty(#categoryId))
      end case
    end if
  end if
end

on eventProcNavigatorPrivate me, tEvent, tSprID, tParm
  if tEvent = #mouseDown then
    case tSprID of
      "nav_closeInfo":
        me.setRoomInfoArea(#hide)
      "nav_tb_publicRooms":
        me.setLoadingCursor(1)
        me.setRoomInfoArea(#show)
        me.ChangeWindowView("nav_pr")
      "nav_tb_guestRooms":
        me.setLoadingCursor(1)
        me.ChangeWindowView("nav_gr0")
      "nav_tab_srch":
        me.ChangeWindowView("nav_gr_src")
      "nav_tab_own":
        me.setLoadingCursor(1)
        me.ChangeWindowView("nav_gr_own")
      "nav_tab_fav":
        me.setLoadingCursor(1)
        me.ChangeWindowView("nav_gr_fav")
      "nav_roomlistBackLinks":
        me.setLoadingCursor(1)
        return me.getComponent().expandHistoryItem(integer(tParm.locV / me.pHistoryItemHeight) + 1)
    end case
  else
    if tEvent = #mouseUp then
      case tSprID of
        "nav_roomlist":
          me.setLoadingCursor(1)
          return me.handleRoomListClicked(tParm)
        "close":
          me.hideNavigator(#hide)
        "nav_go_button":
          return me.getComponent().prepareRoomEntry(me.getProperty(#viewedNodeId))
        "nav_private_button_search":
          return me.startFlatSearch()
        "nav_modify_button":
          me.modifyPrivateRoom(me.getProperty(#viewedNodeId))
        "nav_addtofavourites_button":
          me.getComponent().sendAddFavoriteFlat(me.getProperty(#viewedNodeId))
          me.getComponent().sendGetFavoriteFlats()
        "nav_removefavourites_button":
          me.getComponent().sendRemoveFavoriteFlat(me.getProperty(#viewedNodeId))
          me.setProperty(#viewedNodeId, VOID)
          me.setRoomInfoArea(#hide)
          me.getComponent().sendGetFavoriteFlats()
        "nav_ringbell_cancel_button", "nav_flatpassword_cancel_button", "nav_trypw_cancel_button", "nav_noanswer_ok_button":
          me.ChangeWindowView("nav_gr0")
          me.getComponent().updateState("enterEntry")
        "nav_flatpassword_ok_button":
          tLastClickedId = me.getProperty(#passwordNodeId)
          tCategory = me.getProperty(#categoryId)
          tTemp = me.getPasswordFromField("nav_flatpassword_field")
          if voidp(tTemp) or (tTemp = EMPTY) then
            return 
          end if
          tFlatData = me.getComponent().getNodeInfo(tLastClickedId, tCategory)
          if tFlatData = 0 then
            return 0
          end if
          tFlatData[#password] = tTemp
          me.getComponent().updateSingleSubNodeInfo(tFlatData)
          me.ChangeWindowView("nav_gr_trypassword")
          me.getComponent().executeRoomEntry(tLastClickedId)
        "nav_tryagain_ok_button":
          pFlatPasswords["nav_flatpassword_field"] = []
          me.ChangeWindowView("nav_gr_password")
        "nav_createroom_button", "nav_createroom_icon":
          return executeMessage(#open_roomkiosk)
        "nav_hidefull":
          return me.getComponent().showHideFullRooms(me.getProperty(#categoryId))
      end case
    else
      if tEvent = #keyDown then
        case tSprID of
          "nav_private_search_field":
            if the key = RETURN then
              return me.startFlatSearch()
            end if
          "OLD":
          "nav_flatpassword_field":
            tKeyCatched = me.passwordFieldTypeEvent(tSprID, 0)
            if tKeyCatched then
              pPasswordChecked = 0
              tTimeoutHideName = "asteriskUpdate" & the milliSeconds
              createTimeout(tTimeoutHideName, 1, #updatePasswordAsterisks, me.getID(), [me.pWindowTitle, tSprID], 1)
            end if
            return 0
        end case
      end if
    end if
  end if
end

on eventProcNavigatorModify me, tEvent, tSprID, tParm
  tNodeId = me.getProperty(#viewedNodeId)
  if tEvent = #mouseDown then
    case tSprID of
      "nav_modify_removerights":
        me.ChangeWindowView("nav_remove_rights")
      "nav_remove_rights_cancel_2":
        me.setModifySecondPage()
      "nav_remove_rights_ok_2":
        tNodeId = me.getProperty(#viewedNodeId, #mod)
        me.getComponent().sendRemoveAllRights(tNodeId)
        me.setModifySecondPage()
      "nav_maxusers_minus":
        tMaxVisitors = integer(me.getComponent().getNodeProperty(tNodeId, #maxVisitors) - 5)
        if tMaxVisitors < 10 then
          tMaxVisitors = 10
        end if
        getWindow(me.pWindowTitle).getElement("nav_maxusers_amount").setText(tMaxVisitors)
        me.getComponent().setNodeProperty(tNodeId, #maxVisitors, tMaxVisitors)
      "nav_maxusers_plus":
        tAbsoluteMax = me.getComponent().getNodeProperty(tNodeId, #absoluteMaxVisitors)
        tMaxVisitors = integer(me.getComponent().getNodeProperty(tNodeId, #maxVisitors) + 5)
        if tMaxVisitors > tAbsoluteMax then
          tMaxVisitors = tAbsoluteMax
        end if
        getWindow(me.pWindowTitle).getElement("nav_maxusers_amount").setText(tMaxVisitors)
        me.getComponent().setNodeProperty(tNodeId, #maxVisitors, tMaxVisitors)
      "nav_modify_nameshow_yes_radio":
        me.getComponent().setNodeProperty(tNodeId, #showownername, "1")
        me.updateRadioButton("nav_modify_nameshow_yes_radio", ["nav_modify_nameshow_no_radio"])
      "nav_modify_nameshow_no_radio":
        me.getComponent().setNodeProperty(tNodeId, #showownername, "0")
        me.updateRadioButton("nav_modify_nameshow_no_radio", ["nav_modify_nameshow_yes_radio"])
      "nav_modify_door_open_radio":
        me.getComponent().setNodeProperty(tNodeId, #door, "open")
        me.updateRadioButton("nav_modify_door_open_radio", ["nav_modify_door_locked_radio", "nav_modify_door_pw_radio"])
        pDoorStatusModified = 1
        me.hidePasswordFields(1)
      "nav_modify_door_locked_radio":
        me.getComponent().setNodeProperty(tNodeId, #door, "closed")
        me.updateRadioButton("nav_modify_door_locked_radio", ["nav_modify_door_open_radio", "nav_modify_door_pw_radio"])
        pDoorStatusModified = 1
        me.hidePasswordFields(1)
      "nav_modify_door_pw_radio":
        me.getComponent().setNodeProperty(tNodeId, #door, "password")
        me.updateRadioButton("nav_modify_door_pw_radio", ["nav_modify_door_open_radio", "nav_modify_door_locked_radio"])
        pDoorStatusModified = 1
        me.hidePasswordFields(0)
      "nav_modify_furnituremove_check":
        tValue = integer(not me.getComponent().getNodeProperty(tNodeId, #ableothersmovefurniture))
        me.getComponent().setNodeProperty(tNodeId, #ableothersmovefurniture, tValue)
        me.updateCheckButton("nav_modify_furnituremove_check", tValue)
    end case
  else
    if tEvent = #mouseUp then
      case tSprID of
        "close":
          executeMessage(#removeEnterRoomAlert)
          me.hideNavigator(#hide)
        "nav_go_button":
          me.getComponent().prepareRoomEntry(tNodeId)
        "nav_choosecategory":
          return me.getComponent().setNodeProperty(tNodeId, #parentid, tParm)
        "nav_modify_next":
          me.leaveModifyPage()
          me.setModifySecondPage()
        "nav_modify_prev":
          me.leaveModifyPage()
          me.setModifyFirstPage()
        "nav_modify_ready":
          if voidp(tNodeId) then
            return 0
          end if
          me.leaveModifyPage()
          tWndObj = getWindow(me.pWindowTitle)
          tFlatData = me.getComponent().getNodeInfo(tNodeId, #own)
          if (tFlatData[#door] = "password") and pDoorStatusModified then
            if not me.checkModifiedFlatPasswords() then
              return 0
            end if
          end if
          tFlatData[#name] = replaceChars(pModifyFlatInfo[#name].line[1], "/", EMPTY)
          if tFlatData[#name] = EMPTY then
            return 0
          end if
          tFlatData[#description] = pModifyFlatInfo[#description]
          tFlatData[#password] = pModifyFlatInfo[#password]
          tFlatData[#name] = convertSpecialChars(tFlatData[#name], 1)
          tFlatData[#description] = convertSpecialChars(tFlatData[#description], 1)
          me.getComponent().sendupdateFlatInfo(tFlatData)
          if tFlatData.findPos(#parentid) <> VOID then
            me.getComponent().sendSetFlatCategory(tNodeId, tFlatData[#parentid])
          end if
          me.getComponent().callNodeUpdate()
          me.ChangeWindowView("nav_gr_mod2")
        "nav_modify_ok":
          executeMessage(#removeEnterRoomAlert)
          me.ChangeWindowView("nav_gr_own")
        "nav_modify_cancel":
          executeMessage(#removeEnterRoomAlert)
          me.ChangeWindowView("nav_gr_own")
        "nav_modify_deleteroom":
          executeMessage(#removeEnterRoomAlert)
          me.ChangeWindowView("nav_gr_modify_delete1")
        "nav_modifyBackTab":
          me.ChangeWindowView("nav_gr_own")
        otherwise:
          if voidp(tNodeId) then
            return 0
          end if
          if tSprID contains "nav_delete_room_ok_" then
            case tSprID.char[length(tSprID)] of
              1:
                me.ChangeWindowView("nav_gr_modify_delete2")
              2:
                me.ChangeWindowView("nav_gr_modify_delete3")
              3:
                me.setProperty(#viewedNodeId, VOID, #own)
                me.getComponent().sendDeleteFlat(tNodeId)
                me.getComponent().sendGetOwnFlats()
                me.ChangeWindowView("nav_gr_own")
            end case
          else
            if tSprID contains "nav_delete_room_cancel_" then
              me.modifyPrivateRoom(tNodeId)
            end if
          end if
      end case
    else
      if tEvent = #keyDown then
        case tSprID of
          "nav_modify_door_pw", "nav_modify_door_pw2":
            tKeyCatched = me.passwordFieldTypeEvent(tSprID, 1)
            if tKeyCatched then
              pPasswordChecked = 0
              tTimeoutHideName = "asteriskUpdate" & the milliSeconds
              createTimeout(tTimeoutHideName, 1, #updatePasswordAsterisks, me.getID(), [me.pWindowTitle, tSprID], 1)
            end if
            return 0
          "nav_modify_roomdescription_field", "nav_modify_roomnamefield":
            tKeyCode = the keyCode
            case tKeyCode of
              36, 76:
                return 1
            end case
        end case
      end if
    end if
  end if
end

on passwordFieldTypeEvent me, tSprID, tCheckLength
  if voidp(tSprID) then
    return error(me, "No password field defined!", #passwordFieldTypeEvent)
  end if
  if voidp(tCheckLength) then
    tCheckLength = 1
  end if
  tValidKeys = getVariable("permitted.name.chars", "1234567890qwertyuiopasdfghjklzxcvbnm_-=+?!@<>:.,")
  if voidp(pFlatPasswords[tSprID]) then
    pFlatPasswords[tSprID] = EMPTY
  end if
  case the keyCode of
    36, 76:
      return 1
    48:
      return 0
    123, 124, 125, 126:
      return 1
    51:
      if pFlatPasswords[tSprID].length > 0 then
        tTempPass = pFlatPasswords[tSprID]
        pFlatPasswords[tSprID] = chars(tTempPass, 1, tTempPass.length - 1)
      end if
    117:
      getWindow(me.pWindowTitle).getElement(tSprID).setText(EMPTY)
      pFlatPasswords[tSprID] = EMPTY
    otherwise:
      tValidKeys = getVariable("permitted.name.chars")
      tTheKey = the key
      if not (tValidKeys = EMPTY) then
        if not (tValidKeys contains tTheKey) then
          tMessageTxt = getText("reg_use_allowed_chars") & RETURN & tValidKeys
          executeMessage(#alert, [#Msg: tMessageTxt, #modal: 1])
          return 1
        end if
        if tCheckLength then
          if pFlatPasswords[tSprID].length > getIntVariable("pass.length.max", 16) then
            executeMessage(#alert, [#Msg: "alert_shortenPW", #modal: 1])
            return 1
          end if
        end if
      end if
  end case
  return 1
end
