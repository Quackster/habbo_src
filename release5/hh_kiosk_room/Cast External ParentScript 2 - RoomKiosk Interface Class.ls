property pTempPassword, pWindowTitle, pRoomModels, pRoomProps

on construct me
  pTempPassword = [:]
  pWindowTitle = "RoomMatic"
  pRoomModels = ["a", "b", "c", "d", "e", "f", "g", "h"]
  pRoomProps = [:]
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
  pRoomProps[#marker] = "model_" & pRoomModels[value(pRoomProps["model"])]
  tFlatData = "/first floor/"
  repeat with f in [#name, #marker, #door, #showownername]
    tFlatData = tFlatData & replaceChars(pRoomProps[f], "/", SPACE) & "/"
  end repeat
  tFlatData = tFlatData.char[1..length(tFlatData) - 1]
  me.getComponent().sendNewRoomData(tFlatData)
end

on flatcreated me, tFlatData
  if tFlatData.ilk <> #propList then
    return me.showHideRoomKiosk()
  end if
  me.ChangeWindowView("roomatic7.window")
  tWndObj = getWindow(pWindowTitle)
  pRoomProps[#id] = tFlatData[#id]
  pRoomProps[#ip] = tFlatData[#ip]
  pRoomProps[#port] = tFlatData[#port]
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
  tOnImg = member(getmemnum("button.checkbox_green.on")).image
  tOffImg = member(getmemnum("button.checkbox_green.off")).image
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
  return tPw1 = tPw2
end

on getPassword me
  tPw = EMPTY
  repeat with f = 1 to count(pTempPassword["roomatic_password_field"])
    tPw = tPw & pTempPassword["roomatic_password_field"][f]
  end repeat
  return tPw
end

on setPageValues me, tWindowName
  case tWindowName of
    "roomatic2.window":
      tWndObj = getWindow(pWindowTitle)
      if not voidp(pRoomProps[#name]) then
        tWndObj.getElement("roomatic_roomname_field").setText(pRoomProps[#name])
      end if
      if not voidp(pRoomProps[#description]) then
        tWndObj.getElement("romatic_roomdescription_field").setText(pRoomProps[#description])
      end if
      pRoomProps[#owner] = getObject(#session).get("user_name")
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
    "roomatic3.window", "roomatic_club.window":
      tOthers = []
      if voidp(pRoomProps["model"]) then
        pRoomProps["model"] = "1"
      end if
      tRoomModel = pRoomProps["model"]
      repeat with f = 1 to count(pRoomModels)
        if f <> value(tRoomModel) then
          tOthers.add("roomatic_roomchoose_" & f)
        end if
      end repeat
      me.updateRadioButton("roomatic_roomchoose_" & tRoomModel, tOthers)
      if tWindowName = "roomatic3.window" then
        if not getObject(#session).get("user_rights").getPos("special_room_layouts") then
          getWindow(pWindowTitle).getElement("goto_club_layouts").hide()
        end if
      end if
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
  end case
end

on eventProc me, tEvent, tSprID, tParm
  if tEvent = #mouseUp then
    case tSprID of
      "roomatic_1_button_start":
        me.ChangeWindowView("roomatic2.window")
      "roomatic_1_button_cancel":
        me.showHideRoomKiosk()
      "roomatic_2_button_cancel":
        me.showHideRoomKiosk()
      "roomatic_2_button_next":
        tRoomName = getWindow(pWindowTitle).getElement("roomatic_roomname_field").getText()
        if tRoomName = EMPTY then
          return executeMessage(#alert, [#msg: "roomatic_givename"])
        end if
        pRoomProps[#name] = tRoomName
        pRoomProps[#description] = getWindow(pWindowTitle).getElement("romatic_roomdescription_field").getText()
        me.ChangeWindowView("roomatic3.window")
      "roomatic_1_button_cancel":
        me.ChangeWindowView("roomatic1.window")
      "roomatic_namedisplayed_yes_check":
        pRoomProps[#showownername] = 1
        me.updateRadioButton("roomatic_namedisplayed_yes_check", ["roomatic_namedisplayed_no_check"])
      "roomatic_namedisplayed_no_check":
        pRoomProps[#showownername] = 0
        me.updateRadioButton("roomatic_namedisplayed_no_check", ["roomatic_namedisplayed_yes_check"])
      "roomatic_3_button_next":
        me.ChangeWindowView("roomatic4.window")
      "roomatic_3_button_previous":
        me.ChangeWindowView("roomatic2.window")
      "roomatic_4_button_done":
        if pRoomProps[#door] = "password" then
          if not me.checkPassword() then
            return me.ChangeWindowView("roomatic5.window")
          end if
        end if
        me.createRoom()
        me.ChangeWindowView("roomatic6.window")
      "roomatic_4_button_previous":
        me.ChangeWindowView("roomatic3.window")
      "goto_club_layouts":
        me.ChangeWindowView("roomatic_club.window")
      "roomatic_security_open":
        pRoomProps[#door] = "open"
        tOthers = ["roomatic_security_locked", "roomatic_security_pwc"]
        me.updateRadioButton("roomatic_security_open", tOthers)
      "roomatic_security_locked":
        pRoomProps[#door] = "closed"
        tOthers = ["roomatic_security_open", "roomatic_security_pwc"]
        me.updateRadioButton("roomatic_security_locked", tOthers)
      "roomatic_security_pwc":
        pRoomProps[#door] = "password"
        tOthers = ["roomatic_security_open", "roomatic_security_locked"]
        me.updateRadioButton("roomatic_security_pwc", tOthers)
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
      otherwise:
        if tSprID contains "roomatic_roomchoose" then
          tDelim = the itemDelimiter
          the itemDelimiter = "_"
          tRoomModel = tSprID.item[3]
          the itemDelimiter = tDelim
          pRoomProps["model"] = tRoomModel
          tOthers = []
          repeat with f = 1 to count(pRoomModels)
            if f <> value(tRoomModel) then
              tOthers.add("roomatic_roomchoose_" & f)
            end if
          end repeat
          me.updateRadioButton("roomatic_roomchoose_" & tRoomModel, tOthers)
        end if
    end case
  else
    if tEvent = #keyDown then
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
