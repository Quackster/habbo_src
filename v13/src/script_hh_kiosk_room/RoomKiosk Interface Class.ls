property pWindowTitle, pRoomProps, pTempPassword, pRoomsProps, pRoomIndex

on construct me 
  pTempPassword = [:]
  pWindowTitle = "RoomMatic"
  pRoomProps = [:]
  pRoomsProps = getVariableValue("private.room.properties")
  pRoomIndex = 1
  return(1)
end

on deconstruct me 
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
  return(1)
end

on showHideRoomKiosk me 
  if windowExists(pWindowTitle) then
    me.getComponent().updateState("start")
    removeWindow(pWindowTitle)
  else
    pTempPassword = [:]
    pRoomProps = [:]
    me.ChangeWindowView("roomatic1.window")
  end if
end

on ChangeWindowView me, tWindowName 
  createWindow(pWindowTitle)
  if windowExists(pWindowTitle) then
    tWndObj = getWindow(pWindowTitle)
    tWndObj.merge(tWindowName)
    tWndObj.moveTo(0, -4)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProc, me.getID(), #keyDown)
    me.setPageValues(tWindowName)
  end if
end

on createRoom me 
  pRoomProps.setAt(#name, getStringServices().convertSpecialChars(pRoomProps.getAt(#name), 1))
  pRoomProps.setAt(#description, getStringServices().convertSpecialChars(pRoomProps.getAt(#description), 1))
  pRoomProps.setAt(#marker, "model_" & pRoomProps.getAt("model"))
  tFlatData = "/first floor/"
  repeat while [#name, #marker, #door, #showownername] <= undefined
    f = getAt(undefined, undefined)
    tFlatData = tFlatData & replaceChars(pRoomProps.getAt(f), "/", space()) & "/"
  end repeat
  tFlatData = tFlatData.getProp(#char, 1, length(tFlatData) - 1)
  me.getComponent().sendNewRoomData(tFlatData)
end

on flatcreated me, tFlatName, tFlatID 
  me.getComponent().sendFlatCategory(tFlatID, pRoomProps.getAt(#category))
  me.ChangeWindowView("roomatic7.window")
  tWndObj = getWindow(pWindowTitle)
  pRoomProps.setAt(#id, tFlatID)
  pRoomProps.setAt(#name, tFlatName)
  if pRoomProps.getAt(#door) = "password" then
    pRoomProps.setAt(#password, me.getPassword())
  else
    pRoomProps.setAt(#password, "")
  end if
  tText = getText("roomatic_roomnumber", "Room number:") && pRoomProps.getAt(#id)
  if tWndObj.elementExists("roomatic_newnumber") then
    tWndObj.getElement("roomatic_newnumber").setText(tText)
  end if
  tText = getText("roomatic_roomname", "Room name:") && pRoomProps.getAt(#name)
  if tWndObj.elementExists("roomatic_newname") then
    tWndObj.getElement("roomatic_newname").setText(tText)
  end if
  return(me.sendFlatInfo())
end

on sendFlatInfo me 
  tFlatMsg = "/" & replaceChars(string(pRoomProps.getAt(#id)), "/", space()) & "/" & "\r"
  tFlatMsg = tFlatMsg & "description=" & replaceChars(pRoomProps.getAt(#description), "/", space()) & "\r"
  tFlatMsg = tFlatMsg & "password=" & pRoomProps.getAt(#password) & "\r"
  tFlatMsg = tFlatMsg & "allsuperuser=" & pRoomProps.getAt(#ableothersmovefurniture)
  me.getComponent().sendSetFlatInfo(tFlatMsg)
end

on updateRadioButton me, tElement, tListOfOtherElements 
  tOnImg = member(getmemnum("button.radio_green.on")).image
  tOffImg = member(getmemnum("button.radio_green.off")).image
  tWindowObj = getWindow(pWindowTitle)
  if tWindowObj.elementExists(tElement) then
    tWindowObj.getElement(tElement).feedImage(tOnImg)
  end if
  repeat while tListOfOtherElements <= tListOfOtherElements
    tElement = getAt(tListOfOtherElements, tElement)
    if tWindowObj.elementExists(tElement) then
      tWindowObj.getElement(tElement).feedImage(tOffImg)
    end if
  end repeat
end

on updateCheckButton me, tElement, tProp, tChangeMode 
  tWindowObj = getWindow(pWindowTitle)
  tOnImg = member(getmemnum("button.checkbox_green.on")).image
  tOffImg = member(getmemnum("button.checkbox_green.off")).image
  if voidp(pRoomProps.getAt(tProp)) then
    pRoomProps.setAt(tProp, "0")
  end if
  if voidp(tChangeMode) then
    tChangeMode = 0
  end if
  if tChangeMode then
    if pRoomProps.getAt(tProp) = "1" then
      pRoomProps.setAt(tProp, "0")
    else
      pRoomProps.setAt(tProp, "1")
    end if
  end if
  if pRoomProps.getAt(tProp) = "1" then
    if tWindowObj.elementExists(tElement) then
      tWindowObj.getElement(tElement).feedImage(tOnImg)
    end if
  else
    if tWindowObj.elementExists(tElement) then
      tWindowObj.getElement(tElement).feedImage(tOffImg)
    end if
  end if
end

on checkPassword me 
  if voidp(pTempPassword.getAt("roomatic_password_field")) then
    tPw1 = []
  else
    tPw1 = pTempPassword.getAt("roomatic_password_field")
  end if
  if voidp(pTempPassword.getAt("roomatic_password2_field")) then
    tPw2 = []
  else
    tPw2 = pTempPassword.getAt("roomatic_password2_field")
  end if
  if tPw1.count = 0 then
    return("Alert_ForgotSetPassword")
  end if
  if tPw1.count < 3 then
    return("nav_error_passwordtooshort")
  end if
  if tPw1 <> tPw2 then
    return("Alert_WrongPassword")
  end if
  return(1)
end

on getPassword me 
  if pTempPassword.count = 0 then
    return("")
  end if
  tPw = ""
  f = 1
  repeat while f <= count(pTempPassword.getAt("roomatic_password_field"))
    tPw = tPw & pTempPassword.getAt("roomatic_password_field").getAt(f)
    f = 1 + f
  end repeat
  return(tPw)
end

on getSpecialLayoutRights me 
  return(getObject(#session).get("user_rights").getPos("fuse_use_special_room_layouts"))
end

on setPageValues me, tWindowName 
  if tWindowName = "roomatic2.window" then
    tWndObj = getWindow(pWindowTitle)
    if tWndObj = 0 then
      return(0)
    end if
    if not voidp(pRoomProps.getAt(#name)) then
      tWndObj.getElement("roomatic_roomname_field").setText(pRoomProps.getAt(#name))
    end if
    if not voidp(pRoomProps.getAt(#description)) then
      tWndObj.getElement("romatic_roomdescription_field").setText(pRoomProps.getAt(#description))
    end if
    pRoomProps.setAt(#owner, getObject(#session).get("user_name"))
    tWndObj.getElement("roomatic_ownername_field").setText(pRoomProps.getAt(#owner))
    if not voidp(pRoomProps.getAt(#showownername)) then
      if pRoomProps.getAt(#showownername) = 1 then
        me.updateRadioButton("roomatic_namedisplayed_yes_check", ["roomatic_namedisplayed_no_check"])
      else
        me.updateRadioButton("roomatic_namedisplayed_no_check", ["roomatic_namedisplayed_yes_check"])
      end if
    else
      pRoomProps.setAt(#showownername, 1)
      me.updateRadioButton("roomatic_namedisplayed_yes_check", ["roomatic_namedisplayed_no_check"])
    end if
    tDropDown = tWndObj.getElement("roomatic_choosecategory")
    if not ilk(tDropDown, #instance) then
      return(error(me, "Unable to retrieve dropdown:" && tDropDown, #setPageValues))
    end if
    tCatProps = getObject(#session).get("user_flat_cats")
    if not ilk(tCatProps, #propList) then
      return(error(me, "Category list was not a property list:" && tCatProps, #setPageValues))
    end if
    tCatTxtItems = []
    tCatKeyItems = []
    i = 1
    repeat while i <= tCatProps.count
      tCatTxtItems.setAt(i, getAt(tCatProps, i))
      tCatKeyItems.setAt(i, getPropAt(tCatProps, i))
      i = 1 + i
    end repeat
    if not voidp(pRoomProps.getAt(#category)) then
      tDropDown.updateData(tCatTxtItems, tCatKeyItems, void(), pRoomProps.getAt(#category))
    else
      tDropDown.updateData(tCatTxtItems, tCatKeyItems)
    end if
  else
    if tWindowName <> "roomatic3.window" then
      if tWindowName = "roomatic_club.window" then
        tRoomSpecs = pRoomsProps.getAt(pRoomIndex)
        pRoomProps.setAt(#model, tRoomSpecs.getAt(#model))
        tWndObj = getWindow(pWindowTitle)
        if tWndObj = 0 then
          return(0)
        end if
        tElem = tWndObj.getElement("rm_room_layout")
        tMemName = "rm_model_" & pRoomProps.getAt(#model) & "_layout"
        tmember = member(getmemnum(tMemName))
        tTargetWidth = tElem.getProperty(#width)
        tTargetHeight = tElem.getProperty(#height)
        tTargetImg = image(tTargetWidth, tTargetHeight, 32)
        tSourceRect = image.rect
        tOffsetX = tmember - image.width / 2
        tOffsetY = tmember - image.height / 2
        tTargetRect = tSourceRect + rect(tOffsetX, tOffsetY, tOffsetX, tOffsetY)
        tTargetImg.copyPixels(tmember.image, tTargetRect, tSourceRect)
        if tmember.type = #bitmap then
          tElem.feedImage(tTargetImg)
        end if
        if tRoomSpecs.getAt(#club) then
          tWndObj.getElement("rm_hc_icon").show()
          tWndObj.getElement("rm_hc_only").show()
        else
          tWndObj.getElement("rm_hc_icon").hide()
          tWndObj.getElement("rm_hc_only").hide()
        end if
        if tRoomSpecs.getAt(#club) and not me.getSpecialLayoutRights() then
          tWndObj.getElement("roomatic_3_button_next").hide()
        else
          tWndObj.getElement("roomatic_3_button_next").show()
        end if
        tSizeTxt = getText("roommatic_modify_size")
        tSizeTxt = replaceChunks(tSizeTxt, "%tileCount%", tRoomSpecs.getAt(#size))
        tWndObj.getElement("rm_room_size").setText(tSizeTxt)
      else
        if tWindowName = "roomatic4.window" then
          pTempPassword = [:]
          if not voidp(pRoomProps.getAt(#door)) then
            tOthers = ["open":"roomatic_security_open", "closed":"roomatic_security_locked", "password":"roomatic_security_pwc"]
            tActive = tOthers.getAt(pRoomProps.getAt(#door))
            tOthers.deleteProp(pRoomProps.getAt(#door))
            me.updateRadioButton(tActive, tOthers)
          else
            pRoomProps.setAt(#door, "open")
            tOthers = ["roomatic_security_locked", "roomatic_security_pwc"]
            me.updateRadioButton("roomatic_security_open", tOthers)
          end if
          me.updateCheckButton("roomatic_security_letmove", #ableothersmovefurniture, 0)
          if pRoomProps.getAt(#door) <> "password" then
            me.showPasswordFields(0)
          else
            me.showPasswordFields(1)
          end if
        end if
      end if
    end if
  end if
end

on showPasswordFields me, tVisible 
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return(error(me, "No window!", #showPasswordFields))
  end if
  tElems = ["roomatic_password2_field", "roomatic_password_field", "roomatic_pwdfieldsbg", "roomatic_pwd_desc"]
  repeat while tElems <= undefined
    tElemID = getAt(undefined, tVisible)
    tElem = tWndObj.getElement(tElemID)
    if not voidp(tElem) then
      tElem.setProperty(#visible, tVisible)
      if tElemID = "roomatic_password2_field" or tElemID = "roomatic_password_field" then
        tElem.setText("")
      end if
    end if
  end repeat
end

on eventProc me, tEvent, tSprID, tParm 
  if tEvent = #mouseUp then
    if tSprID = "roomatic_1_button_start" then
      me.ChangeWindowView("roomatic2.window")
    else
      if tSprID = "roomatic_1_button_cancel" then
        me.showHideRoomKiosk()
      else
        if tSprID = "roomatic_choosecategory" then
          tWndObj = getWindow(pWindowTitle)
          tDropDown = tWndObj.getElement("roomatic_choosecategory")
          tDropDown.setSelection(tParm)
          pRoomProps.setAt(#category, tParm)
        else
          if tSprID = "roomatic_2_button_cancel" then
            me.showHideRoomKiosk()
          else
            if tSprID = "roomatic_2_button_next" then
              tRoomName = replaceChars(getWindow(pWindowTitle).getElement("roomatic_roomname_field").getText(), "/", "")
              if tRoomName = "" then
                return(executeMessage(#alert, [#Msg:"roomatic_givename"]))
              end if
              pRoomProps.setAt(#name, tRoomName)
              pRoomProps.setAt(#description, getWindow(pWindowTitle).getElement("romatic_roomdescription_field").getText())
              me.ChangeWindowView("roomatic3.window")
            else
              if tSprID = "roomatic_namedisplayed_yes_check" then
                pRoomProps.setAt(#showownername, 1)
                me.updateRadioButton("roomatic_namedisplayed_yes_check", ["roomatic_namedisplayed_no_check"])
              else
                if tSprID = "roomatic_namedisplayed_no_check" then
                  pRoomProps.setAt(#showownername, 0)
                  me.updateRadioButton("roomatic_namedisplayed_no_check", ["roomatic_namedisplayed_yes_check"])
                else
                  if tSprID = "roomatic3_button_model_next" then
                    pRoomIndex = pRoomIndex + 1
                    if pRoomIndex > pRoomsProps.count then
                      pRoomIndex = 1
                    end if
                    me.setPageValues("roomatic3.window")
                  else
                    if tSprID = "roomatic3_button_model_prev" then
                      pRoomIndex = pRoomIndex - 1
                      if pRoomIndex < 1 then
                        pRoomIndex = pRoomsProps.count
                      end if
                      me.setPageValues("roomatic3.window")
                    else
                      if tSprID = "roomatic_3_button_next" then
                        me.ChangeWindowView("roomatic4.window")
                      else
                        if tSprID = "roomatic_3_button_previous" then
                          me.ChangeWindowView("roomatic2.window")
                        else
                          if tSprID = "roomatic_4_button_done" then
                            if pRoomProps.getAt(#door) = "password" then
                              tReturnValue = me.checkPassword()
                              if tReturnValue <> 1 then
                                tReturnText = getText(tReturnValue)
                                me.ChangeWindowView("roomatic5.window")
                                tWndObj = getWindow(pWindowTitle)
                                tWndObj.getElement("roomatic_errorMsg").setText(tReturnText)
                                return(1)
                              end if
                            end if
                            me.createRoom()
                            me.ChangeWindowView("roomatic6.window")
                          else
                            if tSprID = "roomatic_4_button_previous" then
                              me.ChangeWindowView("roomatic3.window")
                            else
                              if tSprID = "goto_club_layouts" then
                                me.ChangeWindowView("roomatic_club.window")
                              else
                                if tSprID = "goto_normal_layouts" then
                                  me.ChangeWindowView("roomatic3.window")
                                else
                                  if tSprID = "roomatic_security_open" then
                                    pRoomProps.setAt(#door, "open")
                                    tOthers = ["roomatic_security_locked", "roomatic_security_pwc"]
                                    me.updateRadioButton("roomatic_security_open", tOthers)
                                    pTempPassword = [:]
                                    me.showPasswordFields(0)
                                  else
                                    if tSprID = "roomatic_security_locked" then
                                      pRoomProps.setAt(#door, "closed")
                                      tOthers = ["roomatic_security_open", "roomatic_security_pwc"]
                                      me.updateRadioButton("roomatic_security_locked", tOthers)
                                      pTempPassword = [:]
                                      me.showPasswordFields(0)
                                    else
                                      if tSprID = "roomatic_security_pwc" then
                                        pRoomProps.setAt(#door, "password")
                                        tOthers = ["roomatic_security_open", "roomatic_security_locked"]
                                        me.updateRadioButton("roomatic_security_pwc", tOthers)
                                        pTempPassword = [:]
                                        me.showPasswordFields(1)
                                      else
                                        if tSprID = "roomatic_security_letmove" then
                                          me.updateCheckButton("roomatic_security_letmove", #ableothersmovefurniture, 1)
                                        else
                                          if tSprID = "roomatic_5_button_back" then
                                            me.ChangeWindowView("roomatic4.window")
                                          else
                                            if tSprID = "roomatic_7_button_go" then
                                              me.showHideRoomKiosk()
                                              if threadExists(#navigator) then
                                                getThread(#navigator).getComponent().roomkioskGoingFlat(pRoomProps)
                                              end if
                                            else
                                              if tSprID = "roomatic_7_button_cancel" then
                                                me.showHideRoomKiosk()
                                              else
                                                if tSprID = "close" then
                                                  me.showHideRoomKiosk()
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
  else
    if tEvent = #keyDown then
      tASCII = charToNum(the key)
      if tASCII < 28 then
        if tASCII <> 8 and tASCII <> 9 then
          return(1)
        end if
      end if
      if tSprID <> "roomatic_password_field" then
        if tSprID = "roomatic_password2_field" then
          if voidp(pTempPassword.getAt(tSprID)) then
            pTempPassword.setAt(tSprID, [])
          end if
          if tSprID = 48 then
            return(0)
          else
            if tSprID = 51 then
              if pTempPassword.getAt(tSprID).count > 0 then
                pTempPassword.getAt(tSprID).deleteAt(pTempPassword.getAt(tSprID).count)
              end if
            else
              if tSprID = 117 then
                pTempPassword.setAt(tSprID, [])
              else
                tValidKeys = getVariable("permitted.name.chars", "1234567890qwertyuiopasdfghjklzxcvbnm_-=+?!@<>:.,")
                tTheKey = the key
                tASCII = charToNum(tTheKey)
                if tASCII > 31 and tASCII < 128 then
                  if tValidKeys contains tTheKey or tValidKeys = "" then
                    if pTempPassword.getAt(tSprID).count < 32 then
                      pTempPassword.getAt(tSprID).append(tTheKey)
                    end if
                  end if
                end if
              end if
            end if
          end if
          tStr = ""
          repeat while tSprID <= tSprID
            tChar = getAt(tSprID, tEvent)
          end repeat
          getWindow(pWindowTitle).getElement(tSprID).setText(tStr)
          the selStart = pTempPassword.getAt(tSprID).count
          the selEnd = pTempPassword.getAt(tSprID).count
          return(1)
        end if
      end if
    end if
  end if
end
