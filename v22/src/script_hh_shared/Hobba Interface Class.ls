property pCryWindowID, pAlertSpr, pAlertTimer, pCurrCryID, pCurrCryNum, pCurrCryData, pModtoolButtonSpr, pModtoolWindowID, pModToolCheckBoxes, pModToolMode, pCryWndMode, pButtonLocH, pAudioAlertCheckBox

on construct me
  pCryWindowID = getText("hobba_alert")
  pModtoolWindowID = getText("modtool_header")
  pAlertSpr = VOID
  pModtoolButtonSpr = VOID
  pAlertTimer = 0
  pCurrCryID = EMPTY
  pCurrCryNum = 0
  pCurrCryData = [:]
  pModToolCheckBoxes = [0, 0]
  pModToolMode = "closed"
  pCryWndMode = "closed"
  pButtonLocH = 5
  pAudioAlertCheckBox = 1
  registerMessage(#enterRoom, me.getID(), #showModtoolButton)
  registerMessage(#leaveRoom, me.getID(), #hideModtoolButton)
  registerMessage(#userClicked, me.getID(), #userClicked)
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  if windowExists(pCryWindowID) then
    removeWindow(pCryWindowID)
  end if
  if (pAlertSpr.ilk = #sprite) then
    releaseSprite(pAlertSpr.spriteNum)
  end if
  if (pModtoolButtonSpr.ilk = #sprite) then
    releaseSprite(pModtoolButtonSpr.spriteNum)
  end if
  pCurrCryID = EMPTY
  pCurrCryNum = 0
  pCurrCryData = [:]
  unregisterMessage(#userlogin, me.getID())
  unregisterMessage(#userClicked, me.getID())
  return 1
end

on ShowAlert me
  if me.pAudioAlertCheckBox then
    playSound("sound_cfh_received", #cut)
  end if
  if (pAlertSpr.ilk <> #sprite) then
    pAlertSpr = sprite(reserveSprite(me.getID()))
    if (pAlertSpr = sprite(0)) then
      return 0
    end if
    pAlertSpr.memberNum = getmemnum("hobba_alert_0")
    pAlertSpr.ink = 8
    pAlertSpr.loc = point(me.buttonLocH(2), 5)
    pAlertSpr.locZ = 200000000
    setEventBroker(pAlertSpr.spriteNum, (me.getID() & "_alert_spr"))
    pAlertSpr.registerProcedure(#eventProcAlert, me.getID(), #mouseUp)
    pAlertSpr.setcursor("cursor.finger")
    pAlertTimer = 0
  end if
  return receiveUpdate(me.getID())
end

on showModtoolButton me
  if not listp(getObject(#session).GET("user_rights")) then
    return 0
  end if
  if (getObject(#session).GET("user_rights").getOne("fuse_kick") = 0) then
    return 1
  end if
  if (pModtoolButtonSpr.ilk <> #sprite) then
    pModtoolButtonSpr = sprite(reserveSprite(me.getID()))
    if (pModtoolButtonSpr = sprite(0)) then
      return 0
    end if
    pModtoolButtonSpr.memberNum = getmemnum("mod_tool_icon")
    pModtoolButtonSpr.ink = 8
    pModtoolButtonSpr.loc = point(me.buttonLocH(1), 5)
    pModtoolButtonSpr.locZ = 200000000
    setEventBroker(pModtoolButtonSpr.spriteNum, (me.getID() & "_modtool_spr"))
    pModtoolButtonSpr.registerProcedure(#eventProcModToolButton, me.getID(), #mouseUp)
    pModtoolButtonSpr.setcursor("cursor.finger")
    pAlertTimer = 0
  end if
  return 1
end

on hideModtoolButton me
  if voidp(pModtoolButtonSpr) then
    return 0
  end if
  if (pModtoolButtonSpr.ilk = #sprite) then
    if (pModtoolButtonSpr = sprite(0)) then
      return 0
    end if
    pModtoolButtonSpr.setcursor(#arrow)
    pModtoolButtonSpr.removeProcedure(#mouseUp)
    removeEventBroker(pModtoolButtonSpr.spriteNum)
    releaseSprite(pModtoolButtonSpr.spriteNum)
    pModtoolButtonSpr = VOID
  end if
end

on hideAlert me
  if ilk(pAlertSpr, #sprite) then
    releaseSprite(pAlertSpr.spriteNum)
    pAlertSpr = VOID
  end if
  return removeUpdate(me.getID())
end

on stopAlert me
  if ilk(pAlertSpr, #sprite) then
    pAlertSpr.memberNum = getmemnum("hobba_alert_0")
    removeUpdate(me.getID())
  end if
end

on showCryWnd me
  if windowExists(pCryWindowID) then
    tWndObj = getWindow(pCryWindowID)
    tCryDB = me.getComponent().getCryDataBase()
    pCurrCryNum = tCryDB.count
  else
    createWindow(pCryWindowID, "habbo_basic.window")
    tWndObj = getWindow(pCryWindowID)
    tWndObj.merge("habbo_hobba_alert.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcCryWnd, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcCryWnd, me.getID(), #keyDown)
    tCryDB = me.getComponent().getCryDataBase()
    if ((pCurrCryNum < 1) or (pCurrCryNum > tCryDB.count)) then
      pCurrCryNum = tCryDB.count
    end if
  end if
  pCryWndMode = "browse"
  if (getObject(#session).GET("user_rights").getOne("fuse_see_chat_log_link") = 0) then
    tWndObj.getElement("hobba_seelog").hide()
  end if
  return me.updateCryData(pCurrCryNum)
end

on hideCryWnd me
  pCurrCryData = [:]
  if windowExists(pCryWindowID) then
    pCryWndMode = "closed"
    return removeWindow(pCryWindowID)
  else
    return 0
  end if
end

on hideModToolWnd me
  if windowExists(pModtoolWindowID) then
    return removeWindow(pModtoolWindowID)
  else
    return 0
  end if
end

on updateCryWnd me
  me.updateCryData(pCurrCryID)
  return 1
end

on showModToolWnd me
  if windowExists(pModtoolWindowID) then
    tWndObj = getWindow(pModtoolWindowID)
    tWndObj.unmerge()
  else
    createWindow(pModtoolWindowID, "habbo_full.window")
    tWndObj = getWindow(pModtoolWindowID)
    if (tWndObj = 0) then
      return 0
    end if
  end if
  if not tWndObj.merge("habbo_modtool_main.window") then
    return removeWindow(pModtoolWindowID)
  end if
  me.initAudioAlertCheckBox()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcModToolWnd, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProcModToolWnd, me.getID(), #keyDown)
  return 1
end

on buttonLocH me, tPos
  if (tPos = 1) then
    return 40
  else
    if (tPos = 2) then
      return 70
    end if
  end if
  return 5
end

on userClicked me, tName
  if not windowExists(pModtoolWindowID) then
    return 1
  end if
  if (tName = getObject(#session).GET("user_name")) then
    return 1
  end if
  tWndObj = getWindow(pModtoolWindowID)
  if tWndObj.elementExists("modtool_name") then
    tWndObj.getElement("modtool_name").setText(tName)
  end if
  return 1
end

on changeModtoolView me, tWndName, tAction
  pModToolMode = tAction
  if windowExists(pModtoolWindowID) then
    tWndObj = getWindow(pModtoolWindowID)
    tWndObj.unmerge()
  else
    createWindow(pModtoolWindowID, "habbo_full.window")
    if not windowExists(pModtoolWindowID) then
      return 0
    end if
    tWndObj = getWindow(pModtoolWindowID)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcModToolWnd, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcModToolWnd, me.getID(), #keyDown)
  end if
  tHeader = EMPTY
  case tWndName of
    "user":
      if not tWndObj.merge("habbo_modtool_user.window") then
        return removeWindow(pModtoolWindowID)
      end if
      case tAction of
        "kick":
          tHeader = getText("modtool_kickuser")
        "alert":
          tHeader = getText("modtool_alertuser")
        "ban":
          tHeader = getText("modtool_banuser")
      end case
      tWndObj.getElement("modtool_subtitle").setText(getText("modtool_message"))
    "room":
      if not tWndObj.merge("habbo_modtool_room.window") then
        return removeWindow(pModtoolWindowID)
      end if
      case tAction of
        "roomalert":
          tHeader = getText("modtool_roomalert")
        "roomkick":
          tHeader = getText("modtool_roomkick")
      end case
    "ban":
      tWndObj.merge("habbo_modtool_ban.window")
      me.InitializeBanCheckBoxes()
      me.initializeBanDropDown()
  end case
  if (tHeader <> EMPTY) then
    tWndObj.getElement("modtool_title").setText(tHeader)
  end if
  return 1
end

on openCryReplyWindow me
  if not windowExists(pCryWindowID) then
    return 0
  end if
  tWndObj = getWindow(pCryWindowID)
  pCryWndMode = "reply"
  tWndObj.unmerge()
  if not tWndObj.merge("habbo_hobba_reply.window") then
    return removeWindow(pCryWindowID)
  end if
  tName = pCurrCryData[#sender]
  tMsg = pCurrCryData[#Msg]
  tWndObj.getElement("hobba_reply_header").setText((getText("hobba_reply_cfh") && tName))
  tWndObj.getElement("hobba_reply_text").setText(tMsg)
  return 1
end

on update me
  pAlertTimer = ((pAlertTimer + 1) mod 4)
  if (pAlertTimer <> 0) then
    return 1
  end if
  if (pAlertSpr.ilk <> #sprite) then
    return removeUpdate(me.getID())
  end if
  tName = pAlertSpr.member.name
  tNum = integer(tName.char[length(tName)])
  tName = (tName.char[1] & not tNum)
  pAlertSpr.memberNum = getmemnum(tName)
  return 1
end

on updateCryData me, tCryNumOrID
  tCryDB = me.getComponent().getCryDataBase()
  tCryCount = tCryDB.count
  if (tCryCount = 0) then
    me.hideAlert()
    me.hideCryWnd()
    return 1
  end if
  tUnpickedFound = 0
  repeat with tCry in tCryDB
    if (tCry[#picker] = EMPTY) then
      tUnpickedFound = 1
      exit repeat
    end if
  end repeat
  if not tUnpickedFound then
    me.stopAlert()
  end if
  if not windowExists(pCryWindowID) then
    return 0
  end if
  if stringp(tCryNumOrID) then
    tCryID = tCryNumOrID
    pCurrCryData = tCryDB[tCryID]
    repeat with i = 1 to tCryCount
      if (tCryDB.getPropAt(i) = tCryID) then
        pCurrCryNum = i
        exit repeat
      end if
    end repeat
  else
    if integerp(tCryNumOrID) then
      if ((tCryNumOrID < 1) or (tCryNumOrID > tCryCount)) then
        return 0
      end if
      tCryID = tCryDB.getPropAt(tCryNumOrID)
      pCurrCryData = tCryDB[tCryID]
      pCurrCryNum = tCryNumOrID
    else
      return error(me, ("String or integer expected:" && tCryNumOrID), #updateCryData, #major)
    end if
  end if
  if voidp(pCurrCryData) then
    if ((pCurrCryNum > 0) and (pCurrCryNum <= count(tCryDB))) then
      tNewID = tCryDB.getPropAt(pCurrCryNum)
    else
      tNewID = tCryDB.getPropAt(count(tCryDB))
    end if
    return me.updateCryData(tNewID)
  else
    pCurrCryID = tCryID
  end if
  if (pCryWndMode <> "browse") then
    return 1
  end if
  me.redrawCryWindow()
  return 1
end

on redrawCryWindow me
  tCryDB = me.getComponent().getCryDataBase()
  tCryCount = tCryDB.count
  tName = pCurrCryData[#sender]
  tPlace = pCurrCryData[#roomname]
  tMsg = pCurrCryData[#Msg]
  tTime = pCurrCryData[#time]
  tCategory = pCurrCryData[#category]
  tRoomID = pCurrCryData[#room_id]
  ttype = pCurrCryData[#type]
  if ((tRoomID <> VOID) and (getObject(#session).GET("user_rights").getOne("fuse_see_flat_ids") <> 0)) then
    tShowRoomID = (("(id: " & tRoomID) & ")")
  else
    tShowRoomID = EMPTY
  end if
  tWndObj = getWindow(pCryWindowID)
  tNeededElements = ["hobba_header", "hobba_change_cfh_type", "hobba_pickedby", "hobba_cry_text", "page_num"]
  repeat with tElem in tNeededElements
    if not tWndObj.elementExists(tElem) then
      return 0
    end if
  end repeat
  if (tCategory = 1) then
    tWndObj.getElement("hobba_header").setText((getText("hobba_emergency_help") && tName))
    tWndObj.getElement("hobba_change_cfh_type").setText(getText("hobba_mark_normal"))
  else
    tWndObj.getElement("hobba_header").setText((getText("hobba_cryforhelp") && tName))
    tWndObj.getElement("hobba_change_cfh_type").setText(getText("hobba_mark_emergency"))
  end if
  if (tCategory = 3) then
    tWndObj.getElement("hobba_change_cfh_type").deactivate()
  else
    tWndObj.getElement("hobba_change_cfh_type").Activate()
  end if
  tGoButton = tWndObj.getElement("hobba_pickup_go")
  if (ttype = #instantMessage) then
    tGoButton.deactivate()
  else
    tGoButton.Activate()
  end if
  tWndObj.getElement("hobba_cry_text").setText(((((tPlace && tShowRoomID) & RETURN) & RETURN) & tMsg))
  tWndObj.getElement("page_num").setText(((pCurrCryNum & "/") & tCryCount))
  if (pCurrCryData.picker = EMPTY) then
    tWndObj.getElement("hobba_pickedby").setText(tTime)
  else
    tWndObj.getElement("hobba_pickedby").setText((getText("hobba_pickedby") && pCurrCryData.picker))
  end if
end

on initAudioAlertCheckBox me
  if not windowExists(pModtoolWindowID) then
    return 0
  end if
  tWndObj = getWindow(pModtoolWindowID)
  if not tWndObj.elementExists("modtool_checkbox_audioalert") then
    return 0
  end if
  if not memberExists("button.checkbox.off") then
    return 0
  end if
  if not memberExists("button.checkbox.on") then
    return 0
  end if
  tOffImg = getMember("button.checkbox.off").image
  tOnImg = getMember("button.checkbox.on").image
  if me.pAudioAlertCheckBox then
    tWndObj.getElement("modtool_checkbox_audioalert").feedImage(tOnImg)
  else
    tWndObj.getElement("modtool_checkbox_audioalert").feedImage(tOffImg)
  end if
end

on InitializeBanCheckBoxes me
  if not windowExists(pModtoolWindowID) then
    return 0
  end if
  tWndObj = getWindow(pModtoolWindowID)
  if not tWndObj.elementExists("modtool_checkbox_ip") then
    return 0
  end if
  if not memberExists("button.checkbox.off") then
    return 0
  end if
  tOffImg = getMember("button.checkbox.off").image
  tWndObj.getElement("modtool_checkbox_ip").feedImage(tOffImg)
  tWndObj.getElement("modtool_checkbox_computer").feedImage(tOffImg)
  pModToolCheckBoxes = [0, 0]
  return 1
end

on initializeBanDropDown me
  tWndObj = getWindow(pModtoolWindowID)
  if (tWndObj = 0) then
    return 0
  end if
  if not tWndObj.elementExists("ban_length_menu") then
    return 0
  end if
  tDropDown = tWndObj.getElement("ban_length_menu")
  tHours = getText("modtool_hours")
  tDays = getText("modtool_days")
  tVisOptions = [("2" && tHours), ("4" && tHours), ("12" && tHours), ("24" && tHours), ("2" && tDays), ("3" && tDays), ("7" && tDays), ("14" && tDays)]
  tVisOptions.add(("21" && tDays))
  tVisOptions.add(("30" && tDays))
  tVisOptions.add(("60" && tDays))
  tVisOptions.add(("365" && tDays))
  tVisOptions.add(("730" && tDays))
  tVisOptions.add(("4167" && tDays))
  tBanLengths = [2, 4, 12, 24, (2 * 24), (3 * 24), (7 * 24), (14 * 24), (21 * 24), (30 * 24), (60 * 24), (365 * 24), (730 * 24), 100000]
  tDropDown.updateData(tVisOptions, tBanLengths, 1)
  tDropDown.setOrdering(0)
  return 1
end

on checkBoxClicked me, ttype
  if not windowExists(pModtoolWindowID) then
    return 0
  end if
  if not memberExists("button.checkbox.on") then
    return 0
  end if
  tMemOn = getMember("button.checkbox.on")
  tMemOff = getMember("button.checkbox.off")
  if ((tMemOn.type <> #bitmap) or (tMemOff.type <> #bitmap)) then
    return 0
  end if
  tWndObj = getWindow(pModtoolWindowID)
  case ttype of
    "ip":
      pModToolCheckBoxes[1] = not pModToolCheckBoxes[1]
      if pModToolCheckBoxes[1] then
        tWndObj.getElement("modtool_checkbox_ip").feedImage(tMemOn.image)
      else
        tWndObj.getElement("modtool_checkbox_ip").feedImage(tMemOff.image)
      end if
    "computer":
      pModToolCheckBoxes[2] = not pModToolCheckBoxes[2]
      if pModToolCheckBoxes[2] then
        tWndObj.getElement("modtool_checkbox_computer").feedImage(tMemOn.image)
      else
        tWndObj.getElement("modtool_checkbox_computer").feedImage(tMemOff.image)
      end if
    "audioalert":
      pAudioAlertCheckBox = not pAudioAlertCheckBox
      if pAudioAlertCheckBox then
        tWndObj.getElement("modtool_checkbox_audioalert").feedImage(tMemOn.image)
      else
        tWndObj.getElement("modtool_checkbox_audioalert").feedImage(tMemOff.image)
      end if
  end case
  return 1
end

on sendModCommand me
  if not windowExists(pModtoolWindowID) then
    return 1
  end if
  tWndObj = getWindow(pModtoolWindowID)
  tCommandString = EMPTY
  if tWndObj.elementExists("modtool_name") then
    tName = tWndObj.getElement("modtool_name").getText()
  end if
  if tWndObj.elementExists("modtool_reason") then
    tReason = tWndObj.getElement("modtool_reason").getText()
  end if
  if tWndObj.elementExists("modtool_extrainfo") then
    tExtrainfo = tWndObj.getElement("modtool_extrainfo").getText()
  end if
  case pModToolMode of
    "ban":
      if not tWndObj.elementExists("ban_length_menu") then
        return 0
      end if
      tHours = tWndObj.getElement("ban_length_menu").getSelection()
      tBanIP = pModToolCheckBoxes[1]
      tBanComputer = pModToolCheckBoxes[2]
    "alert":
      tTargetType = 0
      tActionType = 0
    "kick":
      tTargetType = 0
      tActionType = 1
    "roomkick":
      tTargetType = 1
      tActionType = 1
    "roomalert":
      tTargetType = 1
      tActionType = 0
  end case
  if (pModToolMode = "ban") then
    tStruct = [#integer: 0, #integer: 2, #string: tReason, #string: tExtrainfo, #string: tName, #integer: tHours, #integer: tBanComputer, #integer: tBanIP]
  else
    if (tTargetType = 0) then
      tStruct = [#integer: tTargetType, #integer: tActionType, #string: tReason, #string: tExtrainfo, #string: tName]
    else
      tStruct = [#integer: tTargetType, #integer: tActionType, #string: tReason, #string: tExtrainfo]
    end if
  end if
  getConnection(getVariable("connection.info.id")).send("MODERATIONACTION", tStruct)
  return me.showModToolWnd()
end

on eventProcCryWnd me, tEvent, tElemID, tParam
  if (tEvent = #mouseUp) then
    case tElemID of
      "close":
        return me.hideCryWnd()
      "hobba_prev":
        return me.updateCryData((pCurrCryNum - 1))
      "hobba_next":
        return me.updateCryData((pCurrCryNum + 1))
      "hobba_seelog":
        tUrlPrefix = getText("chatlog.url")
        if (tUrlPrefix contains "http") then
          return openNetPage((tUrlPrefix & pCurrCryData[#url_id]), "_new")
        else
          return error(me, ("CFH log url prefix not defined or illegal:" && tUrlPrefix), #eventProcCryWnd, #minor)
        end if
      "hobba_pickup":
        return me.getComponent().send_cryPick(pCurrCryID, 0)
      "hobba_pickup_go":
        return me.getComponent().send_cryPick(pCurrCryID, 1)
      "hobba_pickandreply":
        me.openCryReplyWindow()
        return me.getComponent().send_cryPick(pCurrCryID, 0)
      "hobba_reply_button":
        tText = getWindow(pCryWindowID).getElement("hobba_reply_field").getText()
        me.getComponent().send_CfhReply(pCurrCryID, tText)
        me.hideCryWnd()
        return me.showCryWnd()
      "hobba_reply_cancel":
        me.hideCryWnd()
        return me.showCryWnd()
      "hobba_change_cfh_type":
        return me.getComponent().send_changeCfhType(pCurrCryID, pCurrCryData[#category])
    end case
    return 0
  else
    if (tEvent = #keyDown) then
      case tElemID of
        "hobba_reply_field":
          tKeyCode = the keyCode
          if not ((tKeyCode = 51) or (tKeyCode = 117)) then
            tWndObj = getWindow(pCryWindowID)
            tElem = tWndObj.getElement("hobba_reply_field")
            tText = tElem.getText()
            tMaxTextLength = 512
            tMaxLineCounts = 4
            if ((tText.length >= 512) or (tText.line.count > tMaxLineCounts)) then
              return 1
            end if
          end if
          pass()
      end case
    end if
  end if
end

on eventProcModToolWnd me, tEvent, tElemID, tParam
  if (tEvent = #mouseUp) then
    case tElemID of
      "close":
        me.hideModToolWnd()
      "modtool_cancel":
        me.showModToolWnd()
      "modtool_kickuser":
        me.changeModtoolView("user", "kick")
      "modtool_banuser":
        me.changeModtoolView("ban", "ban")
      "modtool_alertuser":
        me.changeModtoolView("user", "alert")
      "modtool_roomkick":
        me.changeModtoolView("room", "roomkick")
      "modtool_roomalert":
        me.changeModtoolView("room", "roomalert")
      "modtool_checkbox_ip":
        me.checkBoxClicked("ip")
      "modtool_checkbox_computer":
        me.checkBoxClicked("computer")
      "modtool_ok":
        return me.sendModCommand()
      "modtool_checkbox_audioalert":
        me.checkBoxClicked("audioalert")
      "aa_checkbox_text":
        me.checkBoxClicked("audioalert")
    end case
    return 0
  end if
  if (tEvent = #keyDown) then
    if (the key = TAB) then
      if not windowExists(pModtoolWindowID) then
        return 0
      end if
      tWndObj = getWindow(pModtoolWindowID)
      if (tElemID = "modtool_name") then
        tElem = tWndObj.getElement("modtool_reason")
        if objectp(tElem) then
          tElem.setFocus(1)
        end if
      else
        if (tElemID = "modtool_reason") then
          tElem = tWndObj.getElement("modtool_extrainfo")
          if objectp(tElem) then
            tElem.setFocus(1)
          end if
        else
          if (tElemID = "modtool_extrainfo") then
            tElem = tWndObj.getElement("modtool_name")
            if objectp(tElem) then
              tElem.setFocus(1)
            else
              tElem = tWndObj.getElement("modtool_reason")
              if objectp(tElem) then
                tElem.setFocus(1)
              end if
            end if
          end if
        end if
      end if
    else
      tKeyCode = the keyCode
      if (tElemID = "modtool_reason") then
        if not ((tKeyCode = 51) or (tKeyCode = 117)) then
          tWndObj = getWindow(pModtoolWindowID)
          tElem = tWndObj.getElement("modtool_reason")
          tText = tElem.getText()
          tMaxTextLength = 512
          tMaxLineCounts = 4
          if ((tText.length >= 512) or (tText.line.count > tMaxLineCounts)) then
            return 1
          end if
        end if
      end if
      pass()
    end if
  end if
  return 1
end

on eventProcAlert me, tEvent, tElemID, tParam
  me.showCryWnd()
  return 1
end

on eventProcModToolButton me
  me.showModToolWnd()
  return 1
end
