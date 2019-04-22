on construct(me)
  pStrLastFlatSearch = ""
  pFlatInfoAction = 0
  pDoorStatusModified = 0
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on showSpaceNodeUsers(me, tNodeId, tUserList)
  tUsersStr = ""
  i = 1
  repeat while i <= tUserList.count
    tUsersStr = tUsersStr & tUserList.getAt(i)
    if i < tUserList.count then
      tUsersStr = tUsersStr & ", "
    end if
    i = 1 + i
  end repeat
  pWinId = getText("nav_people")
  if not createWindow(pWinId, "habbo_basic.window") then
    return(0)
  end if
  tWndObj = getWindow(pWinId)
  if not tWndObj.merge("habbo_alert_b.window") then
    return(tWndObj.close())
  end if
  tTextImg = me.render(tUsersStr)
  tWndObj.getElement("alert_text").feedImage(tTextImg)
  tWndObj.resizeTo(tTextImg.width + 50, tTextImg.height + 100)
  tWndObj.registerProcedure(#hideSpaceNodeUsers, me.getID(), #mouseUp)
  return(1)
  exit
end

on hideSpaceNodeUsers(me)
  return(removeWindow(getText("nav_people")))
  exit
end

on getPasswordFromField(me, tElementId)
  tPwd = pFlatPasswords.getAt(tElementId)
  return(tPwd)
  exit
end

on flatPasswordIncorrect(me)
  me.ChangeWindowView("nav_gr_passwordincorrect")
  exit
end

on checkFlatAccess(me, tFlatData)
  if tFlatData.getAt(#owner) = getObject(#session).GET("user_name") then
    tDoor = "open"
  else
    tDoor = tFlatData.getAt(#door)
    pFlatPasswords = []
  end if
  if me = "password" then
    me.ChangeWindowView("nav_gr_password")
    getWindow(me.pWindowTitle).getElement("nav_roomname_text").setText(tFlatData.getAt(#name))
    me.setProperty(#passwordNodeId, tFlatData.getAt(#id))
  else
    if voidp(tFlatData) then
      return(error(me, "Can't enter flat, no room is selected!!!", #processFlatInfo, #major))
    end if
    return(me.getComponent().executeRoomEntry(tFlatData.getAt(#id)))
  end if
  return(1)
  exit
end

on handleRecommendedRoomListClicked(me, tParm)
  tNodeInfo = me.getComponent().getRecomNodeInfo()
  tRoomList = tNodeInfo.getaProp(#children)
  if voidp(tRoomList) then
    return(0)
  end if
  tClickedLine = integer(tParm.locV / me.pListItemHeight) + 1
  if tClickedLine > tRoomList.count then
    return(0)
  end if
  tNodeInfo = tRoomList.getAt(tClickedLine)
  me.setProperty(#viewedNodeId, tNodeInfo.getAt(#id))
  tGoLinkH = 255
  me.setLoadingCursor(1)
  if tParm.locH > tGoLinkH then
    me.getComponent().prepareRoomEntry(string(tNodeInfo.getAt(#id)), #private)
  else
    me.showNodeInfo(tNodeInfo.getAt(#id))
  end if
  return(1)
  exit
end

on handleRoomListClicked(me, tParm)
  tCategoryId = me.getProperty(#categoryId)
  tNodeInfo = me.getComponent().getNodeInfo(tCategoryId)
  if not listp(tNodeInfo) then
    return(error(me, "Nodeinfo not found, id:" && tCategoryId, #handleRoomListClicked, #major))
  end if
  tNodeList = tNodeInfo.getAt(#children)
  if not listp(tNodeList) then
    return(error(me, "Node content not found, id:" & tCategoryId, #handleRoomListClicked, #major))
  end if
  tNodeCount = tNodeList.count
  if not ilk(tParm, #point) or tNodeCount = 0 then
    return(0)
  end if
  tClickedLine = integer(tParm.locV / me.pListItemHeight) + 1
  if tClickedLine > tNodeCount then
    tClickedLine = tNodeCount
  else
    if tClickedLine < 1 then
      tClickedLine = 1
    end if
  end if
  tNodeInfo = tNodeList.getAt(tClickedLine)
  if not listp(tNodeInfo) then
    return(0)
  end if
  me.setProperty(#viewedNodeId, tNodeInfo.getAt(#id))
  tGoLinkH = 255
  if tNodeInfo.getAt(#nodeType) = 0 then
    me.setLoadingCursor(1)
    me.getComponent().expandNode(tNodeInfo.getAt(#id))
    executeMessage(#tutorial_roomcategory_expanded)
  else
    if the shiftDown then
      if tNodeInfo.getAt(#nodeType) = 1 then
        return(me.getComponent().sendGetSpaceNodeUsers(tNodeInfo.getAt(#id)))
      end if
    end if
    me.setLoadingCursor(1)
    if tParm.locH > tGoLinkH then
      me.getComponent().prepareRoomEntry(tNodeInfo.getAt(#id))
    else
      me.showNodeInfo(tNodeInfo.getAt(#id))
    end if
  end if
  return(1)
  exit
end

on startFlatSearch(me)
  tWndObj = getWindow(me.pWindowTitle)
  if tWndObj.elementExists("nav_private_search_field") then
    tSearchQuery = tWndObj.getElement("nav_private_search_field").getText()
    pStrLastFlatSearch = tSearchQuery
    me.clearRoomList()
    if tSearchQuery = "" then
      return(me.showRoomlistError(getText("nav_prvrooms_notfound")))
    end if
    me.setLoadingCursor(1)
    me.renderLoadingText()
    return(me.getComponent().sendSearchFlats(tSearchQuery))
  end if
  exit
end

on showRoomlistError(me, tText)
  me.setLoadingCursor(0)
  tElem = getWindow(me.pWindowTitle).getElement("nav_roomlist")
  if tElem <> 0 then
    tWidth = tElem.getProperty(#width)
    tHeight = tElem.getProperty(#height)
    tTempImg = image(tWidth, tHeight, 8)
    tTextImg = me.render(tText)
    tTempImg.copyPixels(tTextImg, tTextImg.rect + rect(8, 5, 8, 5), tTextImg.rect)
    tElem.feedImage(tTempImg)
  end if
  exit
end

on modifyPrivateRoom(me, tFlatInfo)
  if not tFlatInfo.ilk = #propList then
    return(me.getComponent().getInfoBroker().requestRoomData(tFlatInfo, #private, [me.getID(), #modifyPrivateRoom]))
  end if
  tFlatInfo = me.getComponent().getNodeInfo(tFlatInfo.getAt(#id), #own)
  if tFlatInfo = 0 then
    return(error(me, "Flat info is VOID", #modifyPrivateRoom, #major))
  else
    pModifyFlatInfo = tFlatInfo
  end if
  if tFlatInfo.findPos(#parentid) = void() then
    registerMessage(#flatcat_received, me.getID(), #modifyPrivateRoom)
    return(me.getComponent().sendGetFlatCategory(tFlatInfo.getAt(#id)))
  end if
  unregisterMessage(#flatcat_received, me.getID())
  pFlatPasswords = []
  pDoorStatusModified = 0
  if tFlatInfo.getAt(#owner) <> getObject(#session).GET("user_name") then
    return(0)
  end if
  me.setModifyFirstPage()
  exit
end

on setModifyFirstPage(me)
  tFlatInfo = pModifyFlatInfo
  me.ChangeWindowView("nav_gr_mod")
  tWndObj = getWindow(me.pWindowTitle)
  tTempProps = [#name:"nav_modify_roomnamefield", #description:"nav_modify_roomdescription_field"]
  f = 1
  repeat while f <= tTempProps.count
    tProp = tTempProps.getPropAt(f)
    tField = tTempProps.getAt(tProp)
    if tWndObj.elementExists(tField) then
      if not voidp(tFlatInfo.getAt(tProp)) then
        tWndObj.getElement(tField).setText(tFlatInfo.getAt(tProp))
      end if
    end if
    f = 1 + f
  end repeat
  tCheckOnImg = member(getmemnum("button.checkbox.on")).image
  tCheckOffImg = member(getmemnum("button.checkbox.off")).image
  if tFlatInfo.getAt(#showownername) = 1 then
    me.updateRadioButton("nav_modify_nameshow_yes_radio", ["nav_modify_nameshow_no_radio"])
  else
    me.updateRadioButton("nav_modify_nameshow_no_radio", ["nav_modify_nameshow_yes_radio"])
  end if
  tMaxVisitorsElm = tWndObj.getElement("nav_maxusers_amount")
  tMaxVisitors = pModifyFlatInfo.getAt(#maxVisitors)
  tAbsoluteMaxVisitors = pModifyFlatInfo.getAt(#absoluteMaxVisitors)
  if tMaxVisitors > tAbsoluteMaxVisitors then
    tMaxVisitors = tAbsoluteMaxVisitors
  end if
  tMaxVisitorsElm.setText(pModifyFlatInfo.getAt(#maxVisitors))
  exit
end

on setModifySecondPage(me)
  tFlatInfo = pModifyFlatInfo
  me.ChangeWindowView("nav_gr_mod_b")
  tWndObj = getWindow(me.pWindowTitle)
  if me = "open" then
    me.updateRadioButton("nav_modify_door_open_radio", ["nav_modify_door_locked_radio", "nav_modify_door_pw_radio"])
    me.hidePasswordFields(1)
  else
    if me = "closed" then
      me.updateRadioButton("nav_modify_door_locked_radio", ["nav_modify_door_open_radio", "nav_modify_door_pw_radio"])
      me.hidePasswordFields(1)
    else
      if me = "password" then
        me.updateRadioButton("nav_modify_door_pw_radio", ["nav_modify_door_open_radio", "nav_modify_door_locked_radio"])
        me.hidePasswordFields(0)
      end if
    end if
  end if
  me.updateCheckButton("nav_modify_furnituremove_check", tFlatInfo.getAt(#ableothersmovefurniture))
  exit
end

on leaveModifyPage(me)
  tPage = me.pLastWindowName
  if me = "nav_gr_mod" then
    pModifyFlatInfo.setAt(#name, getWindow(me.pWindowTitle).getElement("nav_modify_roomnamefield").getText())
    pModifyFlatInfo.setAt(#description, getWindow(me.pWindowTitle).getElement("nav_modify_roomdescription_field").getText())
    pModifyFlatInfo.setAt(#maxVisitors, getWindow(me.pWindowTitle).getElement("nav_maxusers_amount").getText())
  else
    if me = "nav_gr_mod_b" then
      pModifyFlatInfo.setAt(#password, me.getPasswordFromField("nav_modify_door_pw"))
    end if
  end if
  exit
end

on showHideRefreshRecomLink(me, tShow)
  tWndObj = getWindow(me.pWindowTitle)
  if not tWndObj then
    return(0)
  end if
  if not tWndObj.elementExists("nav_refresh_recoms") then
    return(0)
  end if
  tElem = tWndObj.getElement("nav_refresh_recoms")
  if tShow then
    tElem.show()
  else
    tElem.hide()
  end if
  return(1)
  exit
end

on hidePasswordFields(me, tHidden)
  tPassWordElements = ["nav_modify_door_pw", "nav_modify_door_pw2", "nav_pwfields", "nav_pwdescr"]
  tWndObj = getWindow(me.pWindowTitle)
  repeat while me <= undefined
    tElemID = getAt(undefined, tHidden)
    tElem = tWndObj.getElement(tElemID)
    tElem.setProperty(#visible, not tHidden)
  end repeat
  exit
end

on checkModifiedFlatPasswords(me)
  tElementId1 = "nav_modify_door_pw"
  tElementId2 = "nav_modify_door_pw2"
  tPw1 = pFlatPasswords.getAt(tElementId1)
  tPw2 = pFlatPasswords.getAt(tElementId2)
  if tPw1.length = 0 then
    executeMessage(#alert, [#Msg:"Alert_ForgotSetPassword", #modal:1])
    return(0)
  end if
  if tPw1.length < 3 then
    executeMessage(#alert, [#Msg:"nav_error_passwordtooshort", #modal:1])
    return(0)
  end if
  if tPw1 <> tPw2 then
    executeMessage(#alert, [#Msg:"Alert_WrongPassword", #modal:1])
    return(0)
  end if
  return(1)
  exit
end

on updateRadioButton(me, tElement, tListOfOthersElements)
  tOnImg = member(getmemnum("button.radio.on")).image
  tOffImg = member(getmemnum("button.radio.off")).image
  tWndObj = getWindow(me.pWindowTitle)
  if tWndObj.elementExists(tElement) then
    tWndObj.getElement(tElement).feedImage(tOnImg)
  end if
  repeat while me <= tListOfOthersElements
    tRadioElement = getAt(tListOfOthersElements, tElement)
    if tWndObj.elementExists(tRadioElement) then
      tWndObj.getElement(tRadioElement).feedImage(tOffImg)
    end if
  end repeat
  exit
end

on updateCheckButton(me, tElement, tstate)
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
  exit
end

on prepareCategoryDropMenu(me, tNodeId)
  tWndObj = getWindow(me.pWindowTitle)
  if tWndObj = 0 then
    return(0)
  end if
  tDefaultCatId = me.getComponent().getNodeProperty(tNodeId, #parentid)
  tDropDown = tWndObj.getElement("nav_choosecategory")
  if not ilk(tDropDown, #instance) then
    return(error(me, "Unable to retrieve dropdown:" && tDropDown, #prepareCategoryDropMenu, #major))
  end if
  tCatProps = getObject(#session).GET("user_flat_cats")
  if not ilk(tCatProps, #propList) then
    return(error(me, "Category list was not a property list:" && tCatProps, #prepareCategoryDropMenu, #major))
  end if
  tCatTxtItems = []
  tCatKeyItems = []
  i = 1
  repeat while i <= tCatProps.count
    tCatTxtItems.setAt(i, getAt(tCatProps, i))
    tCatKeyItems.setAt(i, getPropAt(tCatProps, i))
    i = 1 + i
  end repeat
  tDefaultCatItem = tCatKeyItems.getPos(tDefaultCatId)
  if tDefaultCatItem = 0 then
    tDefaultCatItem = 1
  end if
  tDropDown.updateData(tCatTxtItems, tCatKeyItems, tDefaultCatItem)
  return(1)
  exit
end

on eventProcNavigatorPublic(me, tEvent, tSprID, tParm)
  if tEvent = #mouseDown then
    if me = "nav_closeInfo" then
      me.setRoomInfoArea(#hide)
    else
      if me = "nav_tb_guestRooms" then
        me.setLoadingCursor(1)
        me.setRoomInfoArea(#show)
        me.ChangeWindowView("nav_gr0")
      else
        if me = "nav_roomlistBackLinks" then
          return(me.getComponent().expandHistoryItem(integer(tParm.locV / me.pHistoryItemHeight) + 1))
        else
          if me = "nav_roomlist" then
            me.handleRoomListClicked(tParm)
          else
            if me <> "create_room" then
              if me = "nav_public_helptext" then
                return(executeMessage(#open_roomkiosk))
              end if
              if tEvent = #mouseUp then
                if me = "close" then
                  return(me.hideNavigator(#hide))
                else
                  if me = "nav_go_button" then
                    return(me.getComponent().prepareRoomEntry(me.getProperty(#viewedNodeId)))
                  else
                    if me = "nav_addtofavourites_button" then
                      me.getComponent().sendAddFavoriteFlat(me.getProperty(#viewedNodeId))
                      return(me.getComponent().sendGetFavoriteFlats())
                    else
                      if me = "nav_hidefull" then
                        return(me.getComponent().showHideFullRooms(me.getProperty(#categoryId)))
                      end if
                    end if
                  end if
                end if
              end if
              exit
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcNavigatorPrivate(me, tEvent, tSprID, tParm)
  if tEvent = #mouseDown then
    if me = "nav_closeInfo" then
      me.setRoomInfoArea(#hide)
    else
      if me = "nav_tb_publicRooms" then
        me.setLoadingCursor(1)
        me.setRoomInfoArea(#show)
        me.ChangeWindowView("nav_pr")
      else
        if me = "nav_tb_guestRooms" then
          me.setLoadingCursor(1)
          me.ChangeWindowView("nav_gr0")
        else
          if me = "nav_tab_srch" then
            me.ChangeWindowView("nav_gr_src")
          else
            if me = "nav_tab_own" then
              me.setLoadingCursor(1)
              me.ChangeWindowView("nav_gr_own")
              executeMessage(#tutorial_ownrooms_tab_clicked)
            else
              if me = "nav_tab_fav" then
                me.setLoadingCursor(1)
                me.ChangeWindowView("nav_gr_fav")
              else
                if me = "nav_roomlistBackLinks" then
                  me.setLoadingCursor(1)
                  return(me.getComponent().expandHistoryItem(integer(tParm.locV / me.pHistoryItemHeight) + 1))
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  else
    if tEvent = #mouseUp then
      if me = "nav_recom_roomlist" then
        me.setLoadingCursor(1)
        return(me.handleRecommendedRoomListClicked(tParm))
      else
        if me = "nav_roomlist" then
          me.setLoadingCursor(1)
          return(me.handleRoomListClicked(tParm))
        else
          if me = "close" then
            me.hideNavigator(#hide)
          else
            if me = "nav_go_button" then
              return(me.getComponent().prepareRoomEntry(me.getProperty(#viewedNodeId)))
            else
              if me = "nav_private_button_search" then
                return(me.startFlatSearch())
              else
                if me = "nav_modify_button" then
                  me.modifyPrivateRoom(me.getProperty(#viewedNodeId))
                else
                  if me = "nav_addtofavourites_button" then
                    me.getComponent().sendAddFavoriteFlat(me.getProperty(#viewedNodeId))
                    me.getComponent().sendGetFavoriteFlats()
                  else
                    if me = "nav_removefavourites_button" then
                      me.getComponent().sendRemoveFavoriteFlat(me.getProperty(#viewedNodeId))
                      me.setProperty(#viewedNodeId, void())
                      me.setRoomInfoArea(#hide)
                      me.getComponent().sendGetFavoriteFlats()
                    else
                      if me <> "nav_ringbell_cancel_button" then
                        if me <> "nav_flatpassword_cancel_button" then
                          if me <> "nav_trypw_cancel_button" then
                            if me = "nav_noanswer_ok_button" then
                              me.ChangeWindowView("nav_gr0")
                              me.getComponent().updateState("enterEntry")
                            else
                              if me = "nav_flatpassword_ok_button" then
                                tLastClickedId = me.getProperty(#passwordNodeId)
                                tCategory = me.getProperty(#categoryId)
                                tTemp = me.getPasswordFromField("nav_flatpassword_field")
                                if voidp(tTemp) or tTemp = "" then
                                  return()
                                end if
                                tFlatData = me.getComponent().getNodeInfo(tLastClickedId, tCategory)
                                if tFlatData = 0 then
                                  return(0)
                                end if
                                tFlatData.setAt(#password, tTemp)
                                me.getComponent().updateSingleSubNodeInfo(tFlatData)
                                me.ChangeWindowView("nav_gr_trypassword")
                                me.getComponent().executeRoomEntry(tLastClickedId)
                              else
                                if me = "nav_tryagain_ok_button" then
                                  pFlatPasswords.setAt("nav_flatpassword_field", [])
                                  me.ChangeWindowView("nav_gr_password")
                                else
                                  if me <> "nav_createroom_button" then
                                    if me = "nav_createroom_icon" then
                                      return(executeMessage(#open_roomkiosk))
                                    else
                                      if me = "nav_hidefull" then
                                        return(me.getComponent().showHideFullRooms(me.getProperty(#categoryId)))
                                      else
                                        if me = "nav_refresh_recoms" then
                                          return(me.getComponent().updateRecomRooms())
                                        end if
                                      end if
                                    end if
                                    if tEvent = #keyDown then
                                      if me = "nav_private_search_field" then
                                        if the key = "\r" then
                                          return(me.startFlatSearch())
                                        end if
                                      else
                                        if me = "OLD" then
                                        else
                                          if me = "nav_flatpassword_field" then
                                            tKeyCatched = me.passwordFieldTypeEvent(tSprID, 0)
                                            if tKeyCatched then
                                              pPasswordChecked = 0
                                              tTimeoutHideName = "asteriskUpdate" & the milliSeconds
                                              createTimeout(tTimeoutHideName, 1, #updatePasswordAsterisks, me.getID(), [me.pWindowTitle, tSprID], 1)
                                            end if
                                            return(0)
                                          end if
                                        end if
                                      end if
                                    end if
                                    exit
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

on eventProcNavigatorModify(me, tEvent, tSprID, tParm)
  tNodeId = me.getProperty(#viewedNodeId)
  if tEvent = #mouseDown then
    if me = "nav_modify_removerights" then
      me.ChangeWindowView("nav_remove_rights")
    else
      if me = "nav_remove_rights_cancel_2" then
        me.setModifySecondPage()
      else
        if me = "nav_remove_rights_ok_2" then
          tNodeId = me.getProperty(#viewedNodeId, #mod)
          me.getComponent().sendRemoveAllRights(tNodeId)
          me.setModifySecondPage()
        else
          if me = "nav_maxusers_minus" then
            tMaxVisitors = integer(me.getComponent().getNodeProperty(tNodeId, #maxVisitors) - 5)
            if tMaxVisitors < 10 then
              tMaxVisitors = 10
            end if
            getWindow(me.pWindowTitle).getElement("nav_maxusers_amount").setText(tMaxVisitors)
            me.getComponent().setNodeProperty(tNodeId, #maxVisitors, tMaxVisitors)
          else
            if me = "nav_maxusers_plus" then
              tAbsoluteMax = me.getComponent().getNodeProperty(tNodeId, #absoluteMaxVisitors)
              tMaxVisitors = integer(me.getComponent().getNodeProperty(tNodeId, #maxVisitors) + 5)
              if tMaxVisitors > tAbsoluteMax then
                tMaxVisitors = tAbsoluteMax
              end if
              getWindow(me.pWindowTitle).getElement("nav_maxusers_amount").setText(tMaxVisitors)
              me.getComponent().setNodeProperty(tNodeId, #maxVisitors, tMaxVisitors)
            else
              if me = "nav_modify_nameshow_yes_radio" then
                me.getComponent().setNodeProperty(tNodeId, #showownername, "1")
                me.updateRadioButton("nav_modify_nameshow_yes_radio", ["nav_modify_nameshow_no_radio"])
              else
                if me = "nav_modify_nameshow_no_radio" then
                  me.getComponent().setNodeProperty(tNodeId, #showownername, "0")
                  me.updateRadioButton("nav_modify_nameshow_no_radio", ["nav_modify_nameshow_yes_radio"])
                else
                  if me = "nav_modify_door_open_radio" then
                    me.getComponent().setNodeProperty(tNodeId, #door, "open")
                    me.updateRadioButton("nav_modify_door_open_radio", ["nav_modify_door_locked_radio", "nav_modify_door_pw_radio"])
                    pDoorStatusModified = 1
                    me.hidePasswordFields(1)
                  else
                    if me = "nav_modify_door_locked_radio" then
                      me.getComponent().setNodeProperty(tNodeId, #door, "closed")
                      me.updateRadioButton("nav_modify_door_locked_radio", ["nav_modify_door_open_radio", "nav_modify_door_pw_radio"])
                      pDoorStatusModified = 1
                      me.hidePasswordFields(1)
                    else
                      if me = "nav_modify_door_pw_radio" then
                        me.getComponent().setNodeProperty(tNodeId, #door, "password")
                        me.updateRadioButton("nav_modify_door_pw_radio", ["nav_modify_door_open_radio", "nav_modify_door_locked_radio"])
                        pDoorStatusModified = 1
                        me.hidePasswordFields(0)
                      else
                        if me = "nav_modify_furnituremove_check" then
                          tValue = integer(not me.getComponent().getNodeProperty(tNodeId, #ableothersmovefurniture))
                          me.getComponent().setNodeProperty(tNodeId, #ableothersmovefurniture, tValue)
                          me.updateCheckButton("nav_modify_furnituremove_check", tValue)
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
  else
    if tEvent = #mouseUp then
      if me = "close" then
        executeMessage(#removeEnterRoomAlert)
        me.hideNavigator(#hide)
      else
        if me = "nav_go_button" then
          me.getComponent().prepareRoomEntry(tNodeId)
        else
          if me = "nav_choosecategory" then
            return(me.getComponent().setNodeProperty(tNodeId, #parentid, tParm))
          else
            if me = "nav_modify_next" then
              me.leaveModifyPage()
              me.setModifySecondPage()
            else
              if me = "nav_modify_prev" then
                me.leaveModifyPage()
                me.setModifyFirstPage()
              else
                if me = "nav_modify_ready" then
                  if voidp(tNodeId) then
                    return(0)
                  end if
                  me.leaveModifyPage()
                  tWndObj = getWindow(me.pWindowTitle)
                  tFlatData = me.getComponent().getNodeInfo(tNodeId, #own)
                  if tFlatData.getAt(#door) = "password" and pDoorStatusModified then
                    if not me.checkModifiedFlatPasswords() then
                      return(0)
                    end if
                  end if
                  tFlatData.setAt(#name, replaceChars(pModifyFlatInfo.getAt(#name).getProp(#line, 1), "/", ""))
                  if tFlatData.getAt(#name) = "" then
                    return(0)
                  end if
                  tFlatData.setAt(#description, pModifyFlatInfo.getAt(#description))
                  tFlatData.setAt(#password, pModifyFlatInfo.getAt(#password))
                  tFlatData.setAt(#name, convertSpecialChars(tFlatData.getAt(#name), 1))
                  tFlatData.setAt(#description, convertSpecialChars(tFlatData.getAt(#description), 1))
                  me.getComponent().sendupdateFlatInfo(tFlatData)
                  if tFlatData.findPos(#parentid) <> void() then
                    me.getComponent().sendSetFlatCategory(tNodeId, tFlatData.getAt(#parentid))
                  end if
                  me.getComponent().callNodeUpdate()
                  me.ChangeWindowView("nav_gr_mod2")
                else
                  if me = "nav_modify_ok" then
                    executeMessage(#removeEnterRoomAlert)
                    me.ChangeWindowView("nav_gr_own")
                  else
                    if me = "nav_modify_cancel" then
                      executeMessage(#removeEnterRoomAlert)
                      me.ChangeWindowView("nav_gr_own")
                    else
                      if me = "nav_modify_deleteroom" then
                        executeMessage(#removeEnterRoomAlert)
                        me.ChangeWindowView("nav_gr_modify_delete1")
                      else
                        if me = "nav_modifyBackTab" then
                          me.ChangeWindowView("nav_gr_own")
                        else
                          if voidp(tNodeId) then
                            return(0)
                          end if
                          if tSprID contains "nav_delete_room_ok_" then
                            if me = 1 then
                              me.ChangeWindowView("nav_gr_modify_delete2")
                            else
                              if me = 2 then
                                me.ChangeWindowView("nav_gr_modify_delete3")
                              else
                                if me = 3 then
                                  me.setProperty(#viewedNodeId, void(), #own)
                                  me.getComponent().sendDeleteFlat(tNodeId)
                                  me.getComponent().sendGetOwnFlats()
                                  me.ChangeWindowView("nav_gr_own")
                                end if
                              end if
                            end if
                          else
                            if tSprID contains "nav_delete_room_cancel_" then
                              me.modifyPrivateRoom(tNodeId)
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
    else
      if tEvent = #keyDown then
        if me <> "nav_modify_door_pw" then
          if me = "nav_modify_door_pw2" then
            tKeyCatched = me.passwordFieldTypeEvent(tSprID, 1)
            if tKeyCatched then
              pPasswordChecked = 0
              tTimeoutHideName = "asteriskUpdate" & the milliSeconds
              createTimeout(tTimeoutHideName, 1, #updatePasswordAsterisks, me.getID(), [me.pWindowTitle, tSprID], 1)
            end if
            return(0)
          else
            if me <> "nav_modify_roomdescription_field" then
              if me = "nav_modify_roomnamefield" then
                tKeyCode = the keyCode
                if me <> 36 then
                  if me = 76 then
                    return(1)
                  end if
                  exit
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on passwordFieldTypeEvent(me, tSprID, tCheckLength)
  if voidp(tSprID) then
    return(error(me, "No password field defined!", #passwordFieldTypeEvent, #minor))
  end if
  if voidp(tCheckLength) then
    tCheckLength = 1
  end if
  tValidKeys = getVariable("permitted.name.chars", "1234567890qwertyuiopasdfghjklzxcvbnm_-=+?!@<>:.,")
  if voidp(pFlatPasswords.getAt(tSprID)) then
    pFlatPasswords.setAt(tSprID, "")
  end if
  if me <> 36 then
    if me = 76 then
      return(1)
    else
      if me = 48 then
        return(0)
      else
        if me <> 123 then
          if me <> 124 then
            if me <> 125 then
              if me = 126 then
                return(1)
              else
                if me = 51 then
                  if pFlatPasswords.getAt(tSprID).length > 0 then
                    tTempPass = pFlatPasswords.getAt(tSprID)
                    pFlatPasswords.setAt(tSprID, chars(tTempPass, 1, tTempPass.length - 1))
                  end if
                else
                  if me = 117 then
                    getWindow(me.pWindowTitle).getElement(tSprID).setText("")
                    pFlatPasswords.setAt(tSprID, "")
                  else
                    tValidKeys = getVariable("permitted.name.chars")
                    tTheKey = the key
                    if not tValidKeys = "" then
                      if not tValidKeys contains tTheKey then
                        tMessageTxt = getText("reg_use_allowed_chars") & "\r" & tValidKeys
                        executeMessage(#alert, [#Msg:tMessageTxt, #modal:1])
                        return(1)
                      end if
                      if tCheckLength then
                        if pFlatPasswords.getAt(tSprID).length > getIntVariable("pass.length.max", 16) then
                          executeMessage(#alert, [#Msg:"alert_shortenPW", #modal:1])
                          return(1)
                        end if
                      end if
                    end if
                  end if
                end if
              end if
              return(1)
              exit
            end if
          end if
        end if
      end if
    end if
  end if
end