property pStrLastFlatSearch, pFlatPasswords, pFlatInfoAction

on construct me
  pStrLastFlatSearch = EMPTY
  pFlatInfoAction = 0
  return 1
end

on deconstruct me
  return 1
end

on showSpaceNodeUsers me, tNodeId, tUsersStr
  executeMessage(#alert, [#title: "nav_people", #msg: tUsersStr])
end

on getPasswordFromField me, tElementId
  tPw = EMPTY
  if voidp(pFlatPasswords[tElementId]) then
    return "null"
  end if
  repeat with f in pFlatPasswords[tElementId]
    tPw = (tPw & f)
  end repeat
  return tPw
end

on flatPasswordIncorrect me
  me.ChangeWindowView("nav_gr_passwordincorrect")
end

on checkFlatAccess me, tFlatData
  unregisterMessage(#flatinfo_received, me.getID())
  if not getObject(#session).get("user_rights").getOne("can_enter_others_rooms") then
    if (tFlatData[#owner] <> getObject(#session).get(#userName)) then
      executeMessage(#alert, [#msg: "nav_norights"])
      return 1
    end if
  end if
  if (tFlatData[#owner] = getObject(#session).get("user_name")) then
    tDoor = "open"
  else
    tDoor = tFlatData[#door]
    pFlatPasswords = [:]
  end if
  case tDoor of
    "open", "closed":
      if voidp(tFlatData) then
        return error(me, "Can't enter flat, no room is selected!!!", #processFlatInfo)
      end if
      return me.getComponent().executeRoomEntry(tFlatData[#id])
    "password":
      me.ChangeWindowView("nav_gr_password")
      getWindow(me.pWindowTitle).getElement("nav_roomname_text").setText(tFlatData[#name])
      me.setProperty(#viewedNodeId, tFlatData[#id])
  end case
end

on handleRoomListClicked me, tParm
  tNodeList = me.getComponent().getNodeChildren(me.getProperty(#categoryId))
  if not ilk(tNodeList, #list) then
    return 0
  end if
  tNodeCount = tNodeList.count
  if (not ilk(tParm, #point) or (tNodeCount = 0)) then
    return 0
  end if
  tClickedLine = (integer((tParm.locV / me.pListItemHeight)) + 1)
  if (tClickedLine > tNodeCount) then
    tClickedLine = tNodeCount
  end if
  tNodeInfo = tNodeList[tClickedLine]
  if not listp(tNodeInfo) then
    return 0
  end if
  me.setProperty(#viewedNodeId, tNodeInfo[#id])
  tGoLinkH = 255
  if (tNodeInfo[#nodeType] = 0) then
    me.setLoadingCursor(1)
    me.getComponent().expandNode(tNodeInfo[#id])
  else
    if the shiftDown then
      if (tNodeInfo[#nodeType] = 1) then
        return me.getComponent().sendGetSpaceNodeUsers(tNodeInfo[#id])
      end if
    end if
    me.setLoadingCursor(1)
    if (tParm.locH > tGoLinkH) then
      me.getComponent().prepareRoomEntry(tNodeInfo[#id])
    else
      me.showNodeInfo(tNodeInfo[#id])
    end if
  end if
end

on startFlatSearch me
  tWndObj = getWindow(me.pWindowTitle)
  if tWndObj.elementExists("nav_private_search_field") then
    tSearchQuery = tWndObj.getElement("nav_private_search_field").getText()
    pStrLastFlatSearch = tSearchQuery
    me.clearRoomList()
    if (tSearchQuery = EMPTY) then
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
  tWidth = tElem.getProperty(#width)
  tHeight = tElem.getProperty(#height)
  tTempImg = image(tWidth, tHeight, 8)
  tTextImg = me.pWriterPlainNormLeft.render(tText)
  tTempImg.copyPixels(tTextImg, (tTextImg.rect + rect(8, 5, 8, 5)), tTextImg.rect)
  tElem.feedImage(tTempImg)
end

on modifyPrivateRoom me, tFlatInfo
  if not (tFlatInfo.ilk = #propList) then
    registerMessage(#flatinfo_received, me.getID(), #modifyPrivateRoom)
    return me.getComponent().sendGetFlatInfo(tFlatInfo)
  end if
  unregisterMessage(#flatinfo_received, me.getID())
  tFlatInfo = me.getComponent().getNodeInfo(tFlatInfo[#id])
  if (tFlatInfo = 0) then
    return error(me, "Flat info is VOID", #modifyPrivateRoom)
  end if
  if (tFlatInfo.findPos(#parentid) = VOID) then
    registerMessage(#flatcat_received, me.getID(), #modifyPrivateRoom)
    return me.getComponent().sendGetFlatCategory(tFlatInfo[#id])
  end if
  unregisterMessage(#flatcat_received, me.getID())
  pFlatPasswords = [:]
  if (tFlatInfo[#owner] <> getObject(#session).get("user_name")) then
    return 0
  end if
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
  if (tFlatInfo[#showownername] = 1) then
    me.updateRadioButton("nav_modify_nameshow_yes_radio", ["nav_modify_nameshow_no_radio"])
  else
    me.updateRadioButton("nav_modify_nameshow_no_radio", ["nav_modify_nameshow_yes_radio"])
  end if
  case tFlatInfo[#door] of
    "open":
      me.updateRadioButton("nav_modify_door_open_radio", ["nav_modify_door_locked_radio", "nav_modify_door_pw_radio"])
    "closed":
      me.updateRadioButton("nav_modify_door_locked_radio", ["nav_modify_door_open_radio", "nav_modify_door_pw_radio"])
    "password":
      me.updateRadioButton("nav_modify_door_pw_radio", ["nav_modify_door_open_radio", "nav_modify_door_locked_radio"])
  end case
  me.updateCheckButton("nav_modify_furnituremove_check", tFlatInfo[#ableothersmovefurniture])
end

on checkModifiedFlatPasswords me
  tElementId1 = "nav_modify_door_pw"
  tElementId2 = "nav_modify_door_pw2"
  if voidp(pFlatPasswords[tElementId1]) then
    tPw1 = []
  else
    tPw1 = pFlatPasswords[tElementId1]
  end if
  if voidp(pFlatPasswords[tElementId2]) then
    tPw2 = []
  else
    tPw2 = pFlatPasswords[tElementId2]
  end if
  if (tPw1.count = 0) then
    executeMessage(#alert, [#msg: "Alert_ForgotSetPassword"])
    return 0
  end if
  if (tPw1.count < 3) then
    executeMessage(#alert, [#msg: "nav_error_passwordtooshort"])
    return 0
  end if
  if (tPw1 <> tPw2) then
    executeMessage(#alert, [#msg: "Alert_WrongPassword"])
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
  if (tWndObj = 0) then
    return 0
  end if
  tDefaultCatId = me.getComponent().getNodeProperty(tNodeId, #parentid)
  tDropDown = tWndObj.getElement("nav_choosecategory")
  if not ilk(tDropDown, #instance) then
    return error(me, ("Unable to retrieve Dropdown:" && tDropDown), #ChangeWindowView)
  end if
  tCatProps = getObject(#session).get("user_flat_cats")
  if not ilk(tCatProps, #propList) then
    return error(me, ("Category list was not property list:" && tCatProps), #ChangeWindowView)
  end if
  tCatTxtItems = []
  tCatKeyItems = []
  repeat with i = 1 to tCatProps.count
    tCatTxtItems[i] = getAt(tCatProps, i)
    tCatKeyItems[i] = getPropAt(tCatProps, i)
  end repeat
  tDropDown.pMenuItems = tCatTxtItems
  tDropDown.pTextlist = tDropDown.pMenuItems
  tDropDown.pTextKeys = tCatKeyItems
  tDefaultCatItem = tCatKeyItems.getPos(tDefaultCatId)
  if (tDefaultCatItem = 0) then
    tDefaultCatItem = 1
  end if
  tDropDown.pSelectedItemNum = tDefaultCatItem
  tDropDown.pNumberOfMenuItems = tDropDown.pMenuItems.count
  tDropDown.pDropMenuImg = tDropDown.createDropImg(tDropDown.pMenuItems, 1, #up)
  tDropDown.pDropActiveBtnImg = tDropDown.createDropImg([tDropDown.pMenuItems[tDropDown.pSelectedItemNum]], 0, #up)
  tDropDown.pBuffer.image = tDropDown.pDropActiveBtnImg
  tDropDown.pBuffer.regPoint = point(0, 0)
  tDropDown.pimage = tDropDown.pDropActiveBtnImg
  tDropDown.render()
end

on eventProcNavigatorPublic me, tEvent, tSprID, tParm
  if (tEvent = #mouseDown) then
    case tSprID of
      "nav_closeInfo":
        me.setRoomInfoArea(#hide)
      "nav_tb_guestRooms":
        me.setLoadingCursor(1)
        me.setRoomInfoArea(#show)
        me.ChangeWindowView("nav_gr0")
      "nav_roomlistBackLinks":
        return me.getComponent().expandHistoryItem((integer((tParm.locV / me.pHistoryItemHeight)) + 1))
      "nav_roomlist":
        me.handleRoomListClicked(tParm)
      "create_room", "nav_public_helptext":
        return executeMessage(#open_roomkiosk)
    end case
  else
    if (tEvent = #mouseUp) then
      case tSprID of
        "close":
          me.hideNavigator(#hide)
        "nav_go_button":
          return me.getComponent().prepareRoomEntry(me.getProperty(#viewedNodeId))
      end case
    end if
  end if
end

on eventProcNavigatorPrivate me, tEvent, tSprID, tParm
  if (tEvent = #mouseDown) then
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
        return me.getComponent().expandHistoryItem((integer((tParm.locV / me.pHistoryItemHeight)) + 1))
      "nav_roomlist":
        me.setLoadingCursor(1)
        me.handleRoomListClicked(tParm)
    end case
  else
    if (tEvent = #mouseUp) then
      case tSprID of
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
          me.getComponent().sendGetFavoriteFlats()
        "nav_ringbell_cancel_button", "nav_flatpassword_cancel_button", "nav_trypw_cancel_button", "nav_noanswer_ok_button":
          me.ChangeWindowView("nav_gr0")
          me.getComponent().updateState("enterEntry")
        "nav_flatpassword_ok_button":
          tLastClickedId = me.getProperty(#viewedNodeId)
          tTemp = me.getPasswordFromField("nav_flatpassword_field")
          if (length(tTemp) = 0) then
            return 
          end if
          tFlatData = me.getComponent().getNodeInfo(tLastClickedId)
          if (tFlatData = 0) then
            return 0
          end if
          tFlatData[#password] = tTemp
          me.ChangeWindowView("nav_gr_trypassword")
          me.getComponent().executeRoomEntry(tLastClickedId)
        "nav_tryagain_ok_button":
          pFlatPasswords["nav_flatpassword_field"] = []
          me.ChangeWindowView("nav_gr_password")
        "nav_createroom_button", "nav_createroom_icon":
          return executeMessage(#open_roomkiosk)
      end case
    else
      if (tEvent = #keyDown) then
        case tSprID of
          "nav_private_search_field":
            if (the key = RETURN) then
              return me.startFlatSearch()
            end if
          "nav_modify_door_pw", "nav_modify_door_pw2", "nav_flatpassword_field":
            if voidp(pFlatPasswords[tSprID]) then
              pFlatPasswords[tSprID] = []
            end if
            case the keyCode of
              48:
                return 0
              36, 76:
                if (tSprID = "nav_flatpassword_field") then
                  return me.eventProcNavigatorPrivate(#mouseUp, "nav_flatpassword_ok_button", VOID)
                else
                  return 1
                end if
              51:
                if (pFlatPasswords[tSprID].count > 0) then
                  pFlatPasswords[tSprID].deleteAt(pFlatPasswords[tSprID].count)
                end if
              117:
                pFlatPasswords[tSprID] = []
              otherwise:
                tValidKeys = getVariable("permitted.name.chars", "1234567890qwertyuiopasdfghjklzxcvbnm_-=+?!@<>:.,")
                tTheKey = the key
                tASCII = charToNum(tTheKey)
                if ((tASCII > 31) and (tASCII < 128)) then
                  if ((tValidKeys contains tTheKey) or (tValidKeys = EMPTY)) then
                    if (pFlatPasswords[tSprID].count < 32) then
                      pFlatPasswords[tSprID].append(tTheKey)
                    end if
                  end if
                end if
            end case
            tStr = EMPTY
            repeat with i = 1 to pFlatPasswords[tSprID].count
              put "*" after tStr
            end repeat
            getWindow(me.pWindowTitle).getElement(tSprID).setText(tStr)
            set the selStart to pFlatPasswords[tSprID].count
            set the selEnd to pFlatPasswords[tSprID].count
            return 1
        end case
      end if
    end if
  end if
end

on eventProcNavigatorModify me, tEvent, tSprID, tParm
  tNodeId = me.getProperty(#viewedNodeId)
  if (tEvent = #mouseDown) then
    case tSprID of
      "nav_modify_removerights":
        me.ChangeWindowView("nav_remove_rights")
      "nav_remove_rights_cancel_2":
        me.modifyPrivateRoom(me.getProperty(#viewedNodeId))
      "nav_remove_rights_ok_2":
        tNodeId = me.getProperty(#viewedNodeId, #mod)
        me.getComponent().sendRemoveAllRights(tNodeId)
        me.modifyPrivateRoom(me.getProperty(#viewedNodeId))
      "nav_modify_nameshow_yes_radio":
        me.getComponent().setNodeProperty(tNodeId, #showownername, "1")
        me.updateRadioButton("nav_modify_nameshow_yes_radio", ["nav_modify_nameshow_no_radio"])
      "nav_modify_nameshow_no_radio":
        me.getComponent().setNodeProperty(tNodeId, #showownername, "0")
        me.updateRadioButton("nav_modify_nameshow_no_radio", ["nav_modify_nameshow_yes_radio"])
      "nav_modify_door_open_radio":
        me.getComponent().setNodeProperty(tNodeId, #door, "open")
        me.updateRadioButton("nav_modify_door_open_radio", ["nav_modify_door_locked_radio", "nav_modify_door_pw_radio"])
      "nav_modify_door_locked_radio":
        me.getComponent().setNodeProperty(tNodeId, #door, "closed")
        me.updateRadioButton("nav_modify_door_locked_radio", ["nav_modify_door_open_radio", "nav_modify_door_pw_radio"])
      "nav_modify_door_pw_radio":
        me.getComponent().setNodeProperty(tNodeId, #door, "password")
        me.updateRadioButton("nav_modify_door_pw_radio", ["nav_modify_door_open_radio", "nav_modify_door_locked_radio"])
      "nav_modify_furnituremove_check":
        tValue = integer(not me.getComponent().getNodeProperty(tNodeId, #ableothersmovefurniture))
        me.getComponent().setNodeProperty(tNodeId, #ableothersmovefurniture, tValue)
        me.updateCheckButton("nav_modify_furnituremove_check", tValue)
    end case
  else
    if (tEvent = #mouseUp) then
      case tSprID of
        "close":
          me.hideNavigator(#hide)
        "nav_go_button":
          me.getComponent().prepareRoomEntry(tNodeId)
        "nav_choosecategory":
          return me.getComponent().setNodeProperty(tNodeId, #parentid, tParm)
        "nav_modify_next":
          if voidp(tNodeId) then
            return 0
          end if
          tWndObj = getWindow(me.pWindowTitle)
          tFlatData = me.getComponent().getNodeInfo(tNodeId)
          if (tFlatData[#door] = "password") then
            if not me.checkModifiedFlatPasswords() then
              return 0
            end if
          end if
          tFlatData[#name] = tWndObj.getElement("nav_modify_roomnamefield").getText().line[1]
          tFlatData[#description] = tWndObj.getElement("nav_modify_roomdescription_field").getText()
          tFlatData[#password] = me.getPasswordFromField("nav_modify_door_pw")
          me.getComponent().sendupdateFlatInfo(tFlatData)
          if (tFlatData.findPos(#parentid) <> VOID) then
            me.getComponent().sendSetFlatCategory(tNodeId, tFlatData[#parentid])
          end if
          me.getComponent().callNodeUpdate()
          me.ChangeWindowView("nav_gr_mod2")
        "nav_modify_ok":
          me.ChangeWindowView("nav_gr_own")
        "nav_modify_cancel":
          me.ChangeWindowView("nav_gr_own")
        "nav_modify_deleteroom":
          me.ChangeWindowView("nav_gr_modify_delete1")
        otherwise:
          if voidp(tNodeId) then
            return 0
          end if
          if (tSprID contains "nav_delete_room_ok_") then
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
            if (tSprID contains "nav_delete_room_cancel_") then
              me.modifyPrivateRoom(tNodeId)
            end if
          end if
      end case
    else
      if (tEvent = #keyDown) then
        case tSprID of
          "nav_modify_door_pw", "nav_modify_door_pw2", "nav_flatpassword_field":
            if voidp(pFlatPasswords[tSprID]) then
              pFlatPasswords[tSprID] = []
            end if
            case the keyCode of
              48:
                return 0
              36, 76:
                if (tSprID = "nav_flatpassword_field") then
                  return me.eventProcNavigatorPrivate(#mouseUp, "nav_flatpassword_ok_button", VOID)
                else
                  return 1
                end if
              51:
                if (pFlatPasswords[tSprID].count > 0) then
                  pFlatPasswords[tSprID].deleteAt(pFlatPasswords[tSprID].count)
                end if
              117:
                pFlatPasswords[tSprID] = []
              otherwise:
                tValidKeys = getVariable("permitted.name.chars", "1234567890qwertyuiopasdfghjklzxcvbnm_-=+?!@<>:.,")
                tTheKey = the key
                tASCII = charToNum(tTheKey)
                if ((tASCII > 31) and (tASCII < 128)) then
                  if ((tValidKeys contains tTheKey) or (tValidKeys = EMPTY)) then
                    if (pFlatPasswords[tSprID].count < 32) then
                      pFlatPasswords[tSprID].append(tTheKey)
                    end if
                  end if
                end if
            end case
            tStr = EMPTY
            repeat with i = 1 to pFlatPasswords[tSprID].count
              put "*" after tStr
            end repeat
            getWindow(me.pWindowTitle).getElement(tSprID).setText(tStr)
            set the selStart to pFlatPasswords[tSprID].count
            set the selEnd to pFlatPasswords[tSprID].count
            return 1
        end case
      end if
    end if
  end if
end
