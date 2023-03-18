property pTempPassword, pWindowTitle, pRoomProps, pRoomsProps, pRoomIndex

on construct me
  pTempPassword = [:]
  pWindowTitle = "RoomMatic"
  pRoomProps = [:]
  pRoomsProps = getVariableValue("private.room.properties")
  pRoomIndex = 1
  return 1
end

on deconstruct me
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
  return 1
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
  pRoomProps[#name] = getStringServices().convertSpecialChars(pRoomProps[#name], 1)
  pRoomProps[#description] = getStringServices().convertSpecialChars(pRoomProps[#description], 1)
  pRoomProps[#marker] = "model_" & pRoomProps["model"]
  tFlatData = "/first floor/"
  repeat with f in [#name, #marker, #door, #showownername]
    tFlatData = tFlatData & replaceChars(pRoomProps[f], "/", SPACE) & "/"
  end repeat
  tFlatData = tFlatData.char[1..length(tFlatData) - 1]
  me.getComponent().sendNewRoomData(tFlatData)
end

on flatcreated me, tFlatName, tFlatID
  me.getComponent().sendFlatCategory(tFlatID, pRoomProps[#category])
  me.ChangeWindowView("roomatic7.window")
  tWndObj = getWindow(pWindowTitle)
  pRoomProps[#id] = tFlatID
  pRoomProps[#name] = tFlatName
  if pRoomProps[#door] = "password" then
    pRoomProps[#password] = me.getPassword()
  else
    pRoomProps[#password] = EMPTY
  end if
  tText = getText("roomatic_roomnumber", "Room number:") && pRoomProps[#id]
  if tWndObj.elementExists("roomatic_newnumber") then
    tWndObj.getElement("roomatic_newnumber").setText(tText)
  end if
  tText = getText("roomatic_roomname", "Room name:") && pRoomProps[#name]
  if tWndObj.elementExists("roomatic_newname") then
    tWndObj.getElement("roomatic_newname").setText(tText)
  end if
  return me.sendFlatInfo()
end

on sendFlatInfo me
  tFlatMsg = "/" & replaceChars(string(pRoomProps[#id]), "/", SPACE) & "/" & RETURN
  tFlatMsg = tFlatMsg & "description=" & replaceChars(pRoomProps[#description], "/", SPACE) & RETURN
  tFlatMsg = tFlatMsg & "password=" & pRoomProps[#password] & RETURN
  tFlatMsg = tFlatMsg & "allsuperuser=" & pRoomProps[#ableothersmovefurniture]
  me.getComponent().sendSetFlatInfo(tFlatMsg)
end

on updateRadioButton me, tElement, tListOfOtherElements
  tOnImg = member(getmemnum("button.radio_green.on")).image
  tOffImg = member(getmemnum("button.radio_green.off")).image
  tWindowObj = getWindow(pWindowTitle)
  if tWindowObj.elementExists(tElement) then
    tWindowObj.getElement(tElement).feedImage(tOnImg)
  end if
  repeat with tElement in tListOfOtherElements
    if tWindowObj.elementExists(tElement) then
      tWindowObj.getElement(tElement).feedImage(tOffImg)
    end if
  end repeat
end

on updateCheckButton me, tElement, tProp, tChangeMode
  tWindowObj = getWindow(pWindowTitle)
  tOnImg = member(getmemnum("button.checkbox_green.on")).image
  tOffImg = member(getmemnum("button.checkbox_green.off")).image
  if voidp(pRoomProps[tProp]) then
    pRoomProps[tProp] = "0"
  end if
  if voidp(tChangeMode) then
    tChangeMode = 0
  end if
  if tChangeMode then
    if pRoomProps[tProp] = "1" then
      pRoomProps[tProp] = "0"
    else
      pRoomProps[tProp] = "1"
    end if
  end if
  if pRoomProps[tProp] = "1" then
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
  if voidp(pTempPassword["roomatic_password_field"]) then
    tPw1 = []
  else
    tPw1 = pTempPassword["roomatic_password_field"]
  end if
  if voidp(pTempPassword["roomatic_password2_field"]) then
    tPw2 = []
  else
    tPw2 = pTempPassword["roomatic_password2_field"]
  end if
  if tPw1.count = 0 then
    return "Alert_ForgotSetPassword"
  end if
  if tPw1.count < 3 then
    return "nav_error_passwordtooshort"
  end if
  if tPw1 <> tPw2 then
    return "Alert_WrongPassword"
  end if
  return 1
end

on getPassword me
  if pTempPassword.count = 0 then
    return EMPTY
  end if
  tPw = EMPTY
  repeat with f = 1 to count(pTempPassword["roomatic_password_field"])
    tPw = tPw & pTempPassword["roomatic_password_field"][f]
  end repeat
  return tPw
end

on getSpecialLayoutRights me
  return getObject(#session).GET("user_rights").getPos("fuse_use_special_room_layouts")
end

on setPageValues me, tWindowName
  case tWindowName of
    "roomatic2.window":
      tWndObj = getWindow(pWindowTitle)
      if tWndObj = 0 then
        return 0
      end if
      if not voidp(pRoomProps[#name]) then
        tWndObj.getElement("roomatic_roomname_field").setText(pRoomProps[#name])
      end if
      if not voidp(pRoomProps[#description]) then
        tWndObj.getElement("romatic_roomdescription_field").setText(pRoomProps[#description])
      end if
      pRoomProps[#owner] = getObject(#session).GET("user_name")
      tWndObj.getElement("roomatic_ownername_field").setText(pRoomProps[#owner])
      if not voidp(pRoomProps[#showownername]) then
        if pRoomProps[#showownername] = 1 then
          me.updateRadioButton("roomatic_namedisplayed_yes_check", ["roomatic_namedisplayed_no_check"])
        else
          me.updateRadioButton("roomatic_namedisplayed_no_check", ["roomatic_namedisplayed_yes_check"])
        end if
      else
        pRoomProps[#showownername] = 1
        me.updateRadioButton("roomatic_namedisplayed_yes_check", ["roomatic_namedisplayed_no_check"])
      end if
      tDropDown = tWndObj.getElement("roomatic_choosecategory")
      if not ilk(tDropDown, #instance) then
        return error(me, "Unable to retrieve dropdown:" && tDropDown, #setPageValues)
      end if
      tCatProps = getObject(#session).GET("user_flat_cats")
      if not ilk(tCatProps, #propList) then
        return error(me, "Category list was not a property list:" && tCatProps, #setPageValues)
      end if
      tCatTxtItems = []
      tCatKeyItems = []
      repeat with i = 1 to tCatProps.count
        tCatTxtItems[i] = getAt(tCatProps, i)
        tCatKeyItems[i] = getPropAt(tCatProps, i)
      end repeat
      if not voidp(pRoomProps[#category]) then
        tDropDown.updateData(tCatTxtItems, tCatKeyItems, VOID, pRoomProps[#category])
      else
        tDropDown.updateData(tCatTxtItems, tCatKeyItems)
      end if
    "roomatic3.window", "roomatic_club.window":
      tRoomSpecs = pRoomsProps[pRoomIndex]
      pRoomProps[#model] = tRoomSpecs[#model]
      tWndObj = getWindow(pWindowTitle)
      if tWndObj = 0 then
        return 0
      end if
      tElem = tWndObj.getElement("rm_room_layout")
      tMemName = "rm_model_" & pRoomProps[#model] & "_layout"
      tmember = member(getmemnum(tMemName))
      tTargetWidth = tElem.getProperty(#width)
      tTargetHeight = tElem.getProperty(#height)
      tTargetImg = image(tTargetWidth, tTargetHeight, 32)
      tSourceRect = tmember.image.rect
      tOffsetX = (tTargetWidth - tmember.image.width) / 2
      tOffsetY = (tTargetHeight - tmember.image.height) / 2
      tTargetRect = tSourceRect + rect(tOffsetX, tOffsetY, tOffsetX, tOffsetY)
      tTargetImg.copyPixels(tmember.image, tTargetRect, tSourceRect)
      if tmember.type = #bitmap then
        tElem.feedImage(tTargetImg)
      end if
      if tRoomSpecs[#club] then
        tWndObj.getElement("rm_hc_icon").show()
        tWndObj.getElement("rm_hc_only").show()
      else
        tWndObj.getElement("rm_hc_icon").hide()
        tWndObj.getElement("rm_hc_only").hide()
      end if
      if tRoomSpecs[#club] and not me.getSpecialLayoutRights() then
        tWndObj.getElement("roomatic_3_button_next").hide()
      else
        tWndObj.getElement("roomatic_3_button_next").show()
      end if
      tSizeTxt = getText("roommatic_modify_size")
      tSizeTxt = replaceChunks(tSizeTxt, "%tileCount%", tRoomSpecs[#size])
      tWndObj.getElement("rm_room_size").setText(tSizeTxt)
    "roomatic4.window":
      pTempPassword = [:]
      if not voidp(pRoomProps[#door]) then
        tOthers = ["open": "roomatic_security_open", "closed": "roomatic_security_locked", "password": "roomatic_security_pwc"]
        tActive = tOthers[pRoomProps[#door]]
        tOthers.deleteProp(pRoomProps[#door])
        me.updateRadioButton(tActive, tOthers)
      else
        pRoomProps[#door] = "open"
        tOthers = ["roomatic_security_locked", "roomatic_security_pwc"]
        me.updateRadioButton("roomatic_security_open", tOthers)
      end if
      me.updateCheckButton("roomatic_security_letmove", #ableothersmovefurniture, 0)
      if pRoomProps[#door] <> "password" then
        me.showPasswordFields(0)
      else
        me.showPasswordFields(1)
      end if
  end case
end

on showPasswordFields me, tVisible
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return error(me, "No window!", #showPasswordFields)
  end if
  tElems = ["roomatic_password2_field", "roomatic_password_field", "roomatic_pwdfieldsbg", "roomatic_pwd_desc"]
  repeat with tElemID in tElems
    tElem = tWndObj.getElement(tElemID)
    if not voidp(tElem) then
      tElem.setProperty(#visible, tVisible)
      if (tElemID = "roomatic_password2_field") or (tElemID = "roomatic_password_field") then
        tElem.setText(EMPTY)
      end if
    end if
  end repeat
end

on eventProc me, tEvent, tSprID, tParm
  if tEvent = #mouseUp then
    case tSprID of
      "roomatic_1_button_start":
        me.ChangeWindowView("roomatic2.window")
      "roomatic_1_button_cancel":
        me.showHideRoomKiosk()
      "roomatic_choosecategory":
        tWndObj = getWindow(pWindowTitle)
        tDropDown = tWndObj.getElement("roomatic_choosecategory")
        tDropDown.setSelection(tParm)
        pRoomProps[#category] = tParm
      "roomatic_2_button_cancel":
        me.showHideRoomKiosk()
      "roomatic_2_button_next":
        tRoomName = replaceChars(getWindow(pWindowTitle).getElement("roomatic_roomname_field").getText(), "/", EMPTY)
        if tRoomName = EMPTY then
          return executeMessage(#alert, [#Msg: "roomatic_givename"])
        end if
        pRoomProps[#name] = tRoomName
        pRoomProps[#description] = getWindow(pWindowTitle).getElement("romatic_roomdescription_field").getText()
        me.ChangeWindowView("roomatic3.window")
      "roomatic_namedisplayed_yes_check":
        pRoomProps[#showownername] = 1
        me.updateRadioButton("roomatic_namedisplayed_yes_check", ["roomatic_namedisplayed_no_check"])
      "roomatic_namedisplayed_no_check":
        pRoomProps[#showownername] = 0
        me.updateRadioButton("roomatic_namedisplayed_no_check", ["roomatic_namedisplayed_yes_check"])
      "roomatic3_button_model_next":
        pRoomIndex = pRoomIndex + 1
        if pRoomIndex > pRoomsProps.count then
          pRoomIndex = 1
        end if
        me.setPageValues("roomatic3.window")
      "roomatic3_button_model_prev":
        pRoomIndex = pRoomIndex - 1
        if pRoomIndex < 1 then
          pRoomIndex = pRoomsProps.count
        end if
        me.setPageValues("roomatic3.window")
      "roomatic_3_button_next":
        me.ChangeWindowView("roomatic4.window")
      "roomatic_3_button_previous":
        me.ChangeWindowView("roomatic2.window")
      "roomatic_4_button_done":
        if pRoomProps[#door] = "password" then
          tReturnValue = me.checkPassword()
          if tReturnValue <> 1 then
            tReturnText = getText(tReturnValue)
            me.ChangeWindowView("roomatic5.window")
            tWndObj = getWindow(pWindowTitle)
            tWndObj.getElement("roomatic_errorMsg").setText(tReturnText)
            return 1
          end if
        end if
        me.createRoom()
        me.ChangeWindowView("roomatic6.window")
      "roomatic_4_button_previous":
        me.ChangeWindowView("roomatic3.window")
      "goto_club_layouts":
        me.ChangeWindowView("roomatic_club.window")
      "goto_normal_layouts":
        me.ChangeWindowView("roomatic3.window")
      "roomatic_security_open":
        pRoomProps[#door] = "open"
        tOthers = ["roomatic_security_locked", "roomatic_security_pwc"]
        me.updateRadioButton("roomatic_security_open", tOthers)
        pTempPassword = [:]
        me.showPasswordFields(0)
      "roomatic_security_locked":
        pRoomProps[#door] = "closed"
        tOthers = ["roomatic_security_open", "roomatic_security_pwc"]
        me.updateRadioButton("roomatic_security_locked", tOthers)
        pTempPassword = [:]
        me.showPasswordFields(0)
      "roomatic_security_pwc":
        pRoomProps[#door] = "password"
        tOthers = ["roomatic_security_open", "roomatic_security_locked"]
        me.updateRadioButton("roomatic_security_pwc", tOthers)
        pTempPassword = [:]
        me.showPasswordFields(1)
      "roomatic_security_letmove":
        me.updateCheckButton("roomatic_security_letmove", #ableothersmovefurniture, 1)
      "roomatic_5_button_back":
        me.ChangeWindowView("roomatic4.window")
      "roomatic_7_button_go":
        me.showHideRoomKiosk()
        if threadExists(#navigator) then
          getThread(#navigator).getComponent().roomkioskGoingFlat(pRoomProps)
        end if
      "roomatic_7_button_cancel":
        me.showHideRoomKiosk()
      "close":
        me.showHideRoomKiosk()
    end case
  else
    if tEvent = #keyDown then
      tASCII = charToNum(the key)
      if tASCII < 28 then
        if (tASCII <> 8) and (tASCII <> 9) then
          return 1
        end if
      end if
      case tSprID of
        "roomatic_password_field", "roomatic_password2_field":
          if voidp(pTempPassword[tSprID]) then
            pTempPassword[tSprID] = []
          end if
          case the keyCode of
            48:
              return 0
            51:
              if pTempPassword[tSprID].count > 0 then
                pTempPassword[tSprID].deleteAt(pTempPassword[tSprID].count)
              end if
            117:
              pTempPassword[tSprID] = []
            otherwise:
              tValidKeys = getVariable("permitted.name.chars", "1234567890qwertyuiopasdfghjklzxcvbnm_-=+?!@<>:.,")
              tTheKey = the key
              tASCII = charToNum(tTheKey)
              if (tASCII > 31) and (tASCII < 128) then
                if (tValidKeys contains tTheKey) or (tValidKeys = EMPTY) then
                  if pTempPassword[tSprID].count < 32 then
                    pTempPassword[tSprID].append(tTheKey)
                  end if
                end if
              end if
          end case
          tStr = EMPTY
          repeat with tChar in pTempPassword[tSprID]
            put "*" after tStr
          end repeat
          getWindow(pWindowTitle).getElement(tSprID).setText(tStr)
          set the selStart to pTempPassword[tSprID].count
          set the selEnd to pTempPassword[tSprID].count
          return 1
      end case
    end if
  end if
end
