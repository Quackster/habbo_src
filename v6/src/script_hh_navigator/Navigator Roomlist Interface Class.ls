property pFlatPasswords

on construct me 
  pStrLastFlatSearch = ""
  pFlatInfoAction = 0
  return TRUE
end

on deconstruct me 
  return TRUE
end

on showSpaceNodeUsers me, tNodeId, tUsersStr 
  executeMessage(#alert, [#title:"nav_people", #msg:tUsersStr])
end

on getPasswordFromField me, tElementId 
  tPw = ""
  if voidp(pFlatPasswords.getAt(tElementId)) then
    return("null")
  end if
  repeat while pFlatPasswords.getAt(tElementId) <= 1
    f = getAt(1, count(pFlatPasswords.getAt(tElementId)))
    tPw = tPw & f
  end repeat
  return(tPw)
end

on flatPasswordIncorrect me 
  me.ChangeWindowView("nav_gr_passwordincorrect")
end

on checkFlatAccess me, tFlatData 
  unregisterMessage(#flatinfo_received, me.getID())
  if not getObject(#session).get("user_rights").getOne("can_enter_others_rooms") then
    if tFlatData.getAt(#owner) <> getObject(#session).get(#userName) then
      executeMessage(#alert, [#msg:"nav_norights"])
      return TRUE
    end if
  end if
  if (tFlatData.getAt(#owner) = getObject(#session).get("user_name")) then
    tDoor = "open"
  else
    tDoor = tFlatData.getAt(#door)
    pFlatPasswords = [:]
  end if
  if tDoor <> "open" then
    if (tDoor = "closed") then
      if voidp(tFlatData) then
        return(error(me, "Can't enter flat, no room is selected!!!", #processFlatInfo))
      end if
      return(me.getComponent().executeRoomEntry(tFlatData.getAt(#id)))
    else
      if (tDoor = "password") then
        me.ChangeWindowView("nav_gr_password")
        getWindow(me.pWindowTitle).getElement("nav_roomname_text").setText(tFlatData.getAt(#name))
        me.setProperty(#viewedNodeId, tFlatData.getAt(#id))
      end if
    end if
  end if
end

on handleRoomListClicked me, tParm 
  tNodeList = me.getComponent().getNodeChildren(me.getProperty(#categoryId))
  if not ilk(tNodeList, #list) then
    return FALSE
  end if
  tNodeCount = tNodeList.count
  if not ilk(tParm, #point) or (tNodeCount = 0) then
    return FALSE
  end if
  tClickedLine = (integer((tParm.locV / me.pListItemHeight)) + 1)
  if tClickedLine > tNodeCount then
    tClickedLine = tNodeCount
  end if
  tNodeInfo = tNodeList.getAt(tClickedLine)
  if not listp(tNodeInfo) then
    return FALSE
  end if
  me.setProperty(#viewedNodeId, tNodeInfo.getAt(#id))
  tGoLinkH = 255
  if (tNodeInfo.getAt(#nodeType) = 0) then
    me.setLoadingCursor(1)
    me.getComponent().expandNode(tNodeInfo.getAt(#id))
  else
    if the shiftDown then
      if (tNodeInfo.getAt(#nodeType) = 1) then
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
end

on startFlatSearch me 
  tWndObj = getWindow(me.pWindowTitle)
  if tWndObj.elementExists("nav_private_search_field") then
    tSearchQuery = tWndObj.getElement("nav_private_search_field").getText()
    pStrLastFlatSearch = tSearchQuery
    me.clearRoomList()
    if (tSearchQuery = "") then
      return(me.showRoomlistError(getText("nav_prvrooms_notfound")))
    end if
    me.setLoadingCursor(1)
    me.renderLoadingText()
    return(me.getComponent().sendSearchFlats(tSearchQuery))
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
    return(me.getComponent().sendGetFlatInfo(tFlatInfo))
  end if
  unregisterMessage(#flatinfo_received, me.getID())
  tFlatInfo = me.getComponent().getNodeInfo(tFlatInfo.getAt(#id))
  if (tFlatInfo = 0) then
    return(error(me, "Flat info is VOID", #modifyPrivateRoom))
  end if
  if (tFlatInfo.findPos(#parentid) = void()) then
    registerMessage(#flatcat_received, me.getID(), #modifyPrivateRoom)
    return(me.getComponent().sendGetFlatCategory(tFlatInfo.getAt(#id)))
  end if
  unregisterMessage(#flatcat_received, me.getID())
  pFlatPasswords = [:]
  if tFlatInfo.getAt(#owner) <> getObject(#session).get("user_name") then
    return FALSE
  end if
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
    f = (1 + f)
  end repeat
  tCheckOnImg = member(getmemnum("button.checkbox.on")).image
  tCheckOffImg = member(getmemnum("button.checkbox.off")).image
  if (tFlatInfo.getAt(#showownername) = 1) then
    me.updateRadioButton("nav_modify_nameshow_yes_radio", ["nav_modify_nameshow_no_radio"])
  else
    me.updateRadioButton("nav_modify_nameshow_no_radio", ["nav_modify_nameshow_yes_radio"])
  end if
  if (tFlatInfo.getAt(#door) = "open") then
    me.updateRadioButton("nav_modify_door_open_radio", ["nav_modify_door_locked_radio", "nav_modify_door_pw_radio"])
  else
    if (tFlatInfo.getAt(#door) = "closed") then
      me.updateRadioButton("nav_modify_door_locked_radio", ["nav_modify_door_open_radio", "nav_modify_door_pw_radio"])
    else
      if (tFlatInfo.getAt(#door) = "password") then
        me.updateRadioButton("nav_modify_door_pw_radio", ["nav_modify_door_open_radio", "nav_modify_door_locked_radio"])
      end if
    end if
  end if
  me.updateCheckButton("nav_modify_furnituremove_check", tFlatInfo.getAt(#ableothersmovefurniture))
end

on checkModifiedFlatPasswords me 
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
    executeMessage(#alert, [#msg:"nav_error_passwordtooshort"])
    return FALSE
  end if
  if tPw1 <> tPw2 then
    executeMessage(#alert, [#msg:"Alert_WrongPassword"])
    return FALSE
  end if
  return TRUE
end

on updateRadioButton me, tElement, tListOfOthersElements 
  tOnImg = member(getmemnum("button.radio.on")).image
  tOffImg = member(getmemnum("button.radio.off")).image
  tWndObj = getWindow(me.pWindowTitle)
  if tWndObj.elementExists(tElement) then
    tWndObj.getElement(tElement).feedImage(tOnImg)
  end if
  repeat while tListOfOthersElements <= 1
    tRadioElement = getAt(1, count(tListOfOthersElements))
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
    return FALSE
  end if
  tDefaultCatId = me.getComponent().getNodeProperty(tNodeId, #parentid)
  tDropDown = tWndObj.getElement("nav_choosecategory")
  if not ilk(tDropDown, #instance) then
    return(error(me, "Unable to retrieve Dropdown:" && tDropDown, #ChangeWindowView))
  end if
  tCatProps = getObject(#session).get("user_flat_cats")
  if not ilk(tCatProps, #propList) then
    return(error(me, "Category list was not property list:" && tCatProps, #ChangeWindowView))
  end if
  tCatTxtItems = []
  tCatKeyItems = []
  i = 1
  repeat while i <= tCatProps.count
    tCatTxtItems.setAt(i, getAt(tCatProps, i))
    tCatKeyItems.setAt(i, getPropAt(tCatProps, i))
    i = (1 + i)
  end repeat
  tDropDown.pMenuItems = tCatTxtItems
  tDropDown.pTextlist = tDropDown.pMenuItems
  tDropDown.pTextKeys = tCatKeyItems
  tDefaultCatItem = tCatKeyItems.getPos(tDefaultCatId)
  if (tDefaultCatItem = 0) then
    tDefaultCatItem = 1
  end if
  tDropDown.pSelectedItemNum = tDefaultCatItem
  tDropDown.pNumberOfMenuItems = tDropDown.count(#pMenuItems)
  tDropDown.pDropMenuImg = tDropDown.createDropImg(tDropDown.pMenuItems, 1, #up)
  tDropDown.pDropActiveBtnImg = tDropDown.createDropImg([tDropDown.getProp(#pMenuItems, tDropDown.pSelectedItemNum)], 0, #up)
  tDropDown.pBuffer.image = tDropDown.pDropActiveBtnImg
  tDropDown.pBuffer.regPoint = point(0, 0)
  tDropDown.pimage = tDropDown.pDropActiveBtnImg
  tDropDown.render()
end

on eventProcNavigatorPublic me, tEvent, tSprID, tParm 
  if (tEvent = #mouseDown) then
    if (tSprID = "nav_closeInfo") then
      me.setRoomInfoArea(#hide)
    else
      if (tSprID = "nav_tb_guestRooms") then
        me.setLoadingCursor(1)
        me.setRoomInfoArea(#show)
        me.ChangeWindowView("nav_gr0")
      else
        if (tSprID = "nav_roomlistBackLinks") then
          return(me.getComponent().expandHistoryItem((integer((tParm.locV / me.pHistoryItemHeight)) + 1)))
        else
          if (tSprID = "nav_roomlist") then
            me.handleRoomListClicked(tParm)
          else
            if tSprID <> "create_room" then
              if (tSprID = "nav_public_helptext") then
                return(executeMessage(#open_roomkiosk))
              end if
              if (tEvent = #mouseUp) then
                if (tSprID = "close") then
                  me.hideNavigator(#hide)
                else
                  if (tSprID = "nav_go_button") then
                    return(me.getComponent().prepareRoomEntry(me.getProperty(#viewedNodeId)))
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
    if (tSprID = "nav_closeInfo") then
      me.setRoomInfoArea(#hide)
    else
      if (tSprID = "nav_tb_publicRooms") then
        me.setLoadingCursor(1)
        me.setRoomInfoArea(#show)
        me.ChangeWindowView("nav_pr")
      else
        if (tSprID = "nav_tb_guestRooms") then
          me.setLoadingCursor(1)
          me.ChangeWindowView("nav_gr0")
        else
          if (tSprID = "nav_tab_srch") then
            me.ChangeWindowView("nav_gr_src")
          else
            if (tSprID = "nav_tab_own") then
              me.setLoadingCursor(1)
              me.ChangeWindowView("nav_gr_own")
            else
              if (tSprID = "nav_tab_fav") then
                me.setLoadingCursor(1)
                me.ChangeWindowView("nav_gr_fav")
              else
                if (tSprID = "nav_roomlistBackLinks") then
                  me.setLoadingCursor(1)
                  return(me.getComponent().expandHistoryItem((integer((tParm.locV / me.pHistoryItemHeight)) + 1)))
                else
                  if (tSprID = "nav_roomlist") then
                    me.setLoadingCursor(1)
                    me.handleRoomListClicked(tParm)
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  else
    if (tEvent = #mouseUp) then
      if (tSprID = "close") then
        me.hideNavigator(#hide)
      else
        if (tSprID = "nav_go_button") then
          return(me.getComponent().prepareRoomEntry(me.getProperty(#viewedNodeId)))
        else
          if (tSprID = "nav_private_button_search") then
            return(me.startFlatSearch())
          else
            if (tSprID = "nav_modify_button") then
              me.modifyPrivateRoom(me.getProperty(#viewedNodeId))
            else
              if (tSprID = "nav_addtofavourites_button") then
                me.getComponent().sendAddFavoriteFlat(me.getProperty(#viewedNodeId))
                me.getComponent().sendGetFavoriteFlats()
              else
                if (tSprID = "nav_removefavourites_button") then
                  me.getComponent().sendRemoveFavoriteFlat(me.getProperty(#viewedNodeId))
                  me.setProperty(#viewedNodeId, void())
                  me.getComponent().sendGetFavoriteFlats()
                else
                  if tSprID <> "nav_ringbell_cancel_button" then
                    if tSprID <> "nav_flatpassword_cancel_button" then
                      if tSprID <> "nav_trypw_cancel_button" then
                        if (tSprID = "nav_noanswer_ok_button") then
                          me.ChangeWindowView("nav_gr0")
                          me.getComponent().updateState("enterEntry")
                        else
                          if (tSprID = "nav_flatpassword_ok_button") then
                            tLastClickedId = me.getProperty(#viewedNodeId)
                            tTemp = me.getPasswordFromField("nav_flatpassword_field")
                            if (length(tTemp) = 0) then
                              return()
                            end if
                            tFlatData = me.getComponent().getNodeInfo(tLastClickedId)
                            if (tFlatData = 0) then
                              return FALSE
                            end if
                            tFlatData.setAt(#password, tTemp)
                            me.ChangeWindowView("nav_gr_trypassword")
                            me.getComponent().executeRoomEntry(tLastClickedId)
                          else
                            if (tSprID = "nav_tryagain_ok_button") then
                              pFlatPasswords.setAt("nav_flatpassword_field", [])
                              me.ChangeWindowView("nav_gr_password")
                            else
                              if tSprID <> "nav_createroom_button" then
                                if (tSprID = "nav_createroom_icon") then
                                  return(executeMessage(#open_roomkiosk))
                                end if
                                if (tEvent = #keyDown) then
                                  if (tSprID = "nav_private_search_field") then
                                    if (the key = "\r") then
                                      return(me.startFlatSearch())
                                    end if
                                  else
                                    if tSprID <> "nav_modify_door_pw" then
                                      if tSprID <> "nav_modify_door_pw2" then
                                        if (tSprID = "nav_flatpassword_field") then
                                          if voidp(pFlatPasswords.getAt(tSprID)) then
                                            pFlatPasswords.setAt(tSprID, [])
                                          end if
                                          if (the keyCode = 48) then
                                            return FALSE
                                          else
                                            if the keyCode <> 36 then
                                              if (the keyCode = 76) then
                                                if (tSprID = "nav_flatpassword_field") then
                                                  return(me.eventProcNavigatorPrivate(#mouseUp, "nav_flatpassword_ok_button", void()))
                                                else
                                                  return TRUE
                                                end if
                                              else
                                                if (the keyCode = 51) then
                                                  if pFlatPasswords.getAt(tSprID).count > 0 then
                                                    pFlatPasswords.getAt(tSprID).deleteAt(pFlatPasswords.getAt(tSprID).count)
                                                  end if
                                                else
                                                  if (the keyCode = 117) then
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
                                              getWindow(me.pWindowTitle).getElement(tSprID).setText(tStr)
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
end

on eventProcNavigatorModify me, tEvent, tSprID, tParm 
  tNodeId = me.getProperty(#viewedNodeId)
  if (tEvent = #mouseDown) then
    if (tSprID = "nav_modify_removerights") then
      me.ChangeWindowView("nav_remove_rights")
    else
      if (tSprID = "nav_remove_rights_cancel_2") then
        me.modifyPrivateRoom(me.getProperty(#viewedNodeId))
      else
        if (tSprID = "nav_remove_rights_ok_2") then
          tNodeId = me.getProperty(#viewedNodeId, #mod)
          me.getComponent().sendRemoveAllRights(tNodeId)
          me.modifyPrivateRoom(me.getProperty(#viewedNodeId))
        else
          if (tSprID = "nav_modify_nameshow_yes_radio") then
            me.getComponent().setNodeProperty(tNodeId, #showownername, "1")
            me.updateRadioButton("nav_modify_nameshow_yes_radio", ["nav_modify_nameshow_no_radio"])
          else
            if (tSprID = "nav_modify_nameshow_no_radio") then
              me.getComponent().setNodeProperty(tNodeId, #showownername, "0")
              me.updateRadioButton("nav_modify_nameshow_no_radio", ["nav_modify_nameshow_yes_radio"])
            else
              if (tSprID = "nav_modify_door_open_radio") then
                me.getComponent().setNodeProperty(tNodeId, #door, "open")
                me.updateRadioButton("nav_modify_door_open_radio", ["nav_modify_door_locked_radio", "nav_modify_door_pw_radio"])
              else
                if (tSprID = "nav_modify_door_locked_radio") then
                  me.getComponent().setNodeProperty(tNodeId, #door, "closed")
                  me.updateRadioButton("nav_modify_door_locked_radio", ["nav_modify_door_open_radio", "nav_modify_door_pw_radio"])
                else
                  if (tSprID = "nav_modify_door_pw_radio") then
                    me.getComponent().setNodeProperty(tNodeId, #door, "password")
                    me.updateRadioButton("nav_modify_door_pw_radio", ["nav_modify_door_open_radio", "nav_modify_door_locked_radio"])
                  else
                    if (tSprID = "nav_modify_furnituremove_check") then
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
  else
    if (tEvent = #mouseUp) then
      if (tSprID = "close") then
        me.hideNavigator(#hide)
      else
        if (tSprID = "nav_go_button") then
          me.getComponent().prepareRoomEntry(tNodeId)
        else
          if (tSprID = "nav_choosecategory") then
            return(me.getComponent().setNodeProperty(tNodeId, #parentid, tParm))
          else
            if (tSprID = "nav_modify_next") then
              if voidp(tNodeId) then
                return FALSE
              end if
              tWndObj = getWindow(me.pWindowTitle)
              tFlatData = me.getComponent().getNodeInfo(tNodeId)
              if (tFlatData.getAt(#door) = "password") then
                if not me.checkModifiedFlatPasswords() then
                  return FALSE
                end if
              end if
              tFlatData.setAt(#name, tWndObj.getElement("nav_modify_roomnamefield").getText().getProp(#line, 1))
              tFlatData.setAt(#description, tWndObj.getElement("nav_modify_roomdescription_field").getText())
              tFlatData.setAt(#password, me.getPasswordFromField("nav_modify_door_pw"))
              me.getComponent().sendupdateFlatInfo(tFlatData)
              if tFlatData.findPos(#parentid) <> void() then
                me.getComponent().sendSetFlatCategory(tNodeId, tFlatData.getAt(#parentid))
              end if
              me.getComponent().callNodeUpdate()
              me.ChangeWindowView("nav_gr_mod2")
            else
              if (tSprID = "nav_modify_ok") then
                me.ChangeWindowView("nav_gr_own")
              else
                if (tSprID = "nav_modify_cancel") then
                  me.ChangeWindowView("nav_gr_own")
                else
                  if (tSprID = "nav_modify_deleteroom") then
                    me.ChangeWindowView("nav_gr_modify_delete1")
                  else
                    if voidp(tNodeId) then
                      return FALSE
                    end if
                    if tSprID contains "nav_delete_room_ok_" then
                      if (tSprID.getProp(#char, length(tSprID)) = 1) then
                        me.ChangeWindowView("nav_gr_modify_delete2")
                      else
                        if (tSprID.getProp(#char, length(tSprID)) = 2) then
                          me.ChangeWindowView("nav_gr_modify_delete3")
                        else
                          if (tSprID.getProp(#char, length(tSprID)) = 3) then
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
    else
      if (tEvent = #keyDown) then
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
                  getWindow(me.pWindowTitle).getElement(tSprID).setText(tStr)
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
end
