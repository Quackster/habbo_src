property pCryWindowID, pAlertSpr, pModtoolButtonSpr, pCurrCryNum, pModtoolWindowID, pCurrCryID, pCurrCryData, pAlertTimer, pCryWndMode, pModToolCheckBoxes, pAudioAlertCheckBox, pModToolMode

on construct me 
  pCryWindowID = getText("hobba_alert")
  pModtoolWindowID = getText("modtool_header")
  pAlertSpr = void()
  pModtoolButtonSpr = void()
  pAlertTimer = 0
  pCurrCryID = ""
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
  registerMessage(#gamesystem_constructed, me.getID(), #hideModtoolButton)
  registerMessage(#gamesystem_deconstructed, me.getID(), #hideModtoolButton)
  return TRUE
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
  pCurrCryID = ""
  pCurrCryNum = 0
  pCurrCryData = [:]
  unregisterMessage(#userlogin, me.getID())
  unregisterMessage(#userClicked, me.getID())
  unregisterMessage(#gamesystem_constructed, me.getID())
  unregisterMessage(#gamesystem_deconstructed, me.getID())
  return TRUE
end

on ShowAlert me 
  if me.pAudioAlertCheckBox then
    playSound("sound_cfh_received", #cut)
  end if
  if pAlertSpr.ilk <> #sprite then
    pAlertSpr = sprite(reserveSprite(me.getID()))
    if (pAlertSpr = sprite(0)) then
      return FALSE
    end if
    pAlertSpr.memberNum = getmemnum("hobba_alert_0")
    pAlertSpr.ink = 8
    pAlertSpr.loc = point(me.buttonLocH(2), 5)
    pAlertSpr.locZ = 200000000
    setEventBroker(pAlertSpr.spriteNum, me.getID() & "_alert_spr")
    pAlertSpr.registerProcedure(#eventProcAlert, me.getID(), #mouseUp)
    pAlertSpr.setcursor("cursor.finger")
    pAlertTimer = 0
  end if
  return(receiveUpdate(me.getID()))
end

on showModtoolButton me 
  if not listp(getObject(#session).GET("user_rights")) then
    return FALSE
  end if
  if (getObject(#session).GET("user_rights").getOne("fuse_kick") = 0) then
    return TRUE
  end if
  if pModtoolButtonSpr.ilk <> #sprite then
    pModtoolButtonSpr = sprite(reserveSprite(me.getID()))
    if (pModtoolButtonSpr = sprite(0)) then
      return FALSE
    end if
    pModtoolButtonSpr.memberNum = getmemnum("mod_tool_icon")
    pModtoolButtonSpr.ink = 8
    pModtoolButtonSpr.loc = point(me.buttonLocH(1), 5)
    pModtoolButtonSpr.locZ = 200000000
    setEventBroker(pModtoolButtonSpr.spriteNum, me.getID() & "_modtool_spr")
    pModtoolButtonSpr.registerProcedure(#eventProcModToolButton, me.getID(), #mouseUp)
    pModtoolButtonSpr.setcursor("cursor.finger")
    pAlertTimer = 0
  end if
  return TRUE
end

on hideModtoolButton me 
  if voidp(pModtoolButtonSpr) then
    return FALSE
  end if
  if (pModtoolButtonSpr.ilk = #sprite) then
    if (pModtoolButtonSpr = sprite(0)) then
      return FALSE
    end if
    pModtoolButtonSpr.setcursor(#arrow)
    pModtoolButtonSpr.removeProcedure(#mouseUp)
    removeEventBroker(pModtoolButtonSpr.spriteNum)
    releaseSprite(pModtoolButtonSpr.spriteNum)
    pModtoolButtonSpr = void()
  end if
end

on hideAlert me 
  if ilk(pAlertSpr, #sprite) then
    releaseSprite(pAlertSpr.spriteNum)
    pAlertSpr = void()
  end if
  return(removeUpdate(me.getID()))
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
    if pCurrCryNum < 1 or pCurrCryNum > tCryDB.count then
      pCurrCryNum = tCryDB.count
    end if
  end if
  pCryWndMode = "browse"
  if (getObject(#session).GET("user_rights").getOne("fuse_see_chat_log_link") = 0) then
    tWndObj.getElement("hobba_seelog").hide()
  end if
  return(me.updateCryData(pCurrCryNum))
end

on hideCryWnd me 
  pCurrCryData = [:]
  if windowExists(pCryWindowID) then
    pCryWndMode = "closed"
    return(removeWindow(pCryWindowID))
  else
    return FALSE
  end if
end

on hideModToolWnd me 
  if windowExists(pModtoolWindowID) then
    return(removeWindow(pModtoolWindowID))
  else
    return FALSE
  end if
end

on updateCryWnd me 
  me.updateCryData(pCurrCryID)
  return TRUE
end

on showModToolWnd me 
  if windowExists(pModtoolWindowID) then
    tWndObj = getWindow(pModtoolWindowID)
    tWndObj.unmerge()
  else
    createWindow(pModtoolWindowID, "habbo_full.window")
    tWndObj = getWindow(pModtoolWindowID)
    if (tWndObj = 0) then
      return FALSE
    end if
  end if
  if not tWndObj.merge("habbo_modtool_main.window") then
    return(removeWindow(pModtoolWindowID))
  end if
  me.initAudioAlertCheckBox()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcModToolWnd, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProcModToolWnd, me.getID(), #keyDown)
  return TRUE
end

on buttonLocH me, tPos 
  if (tPos = 1) then
    return(75)
  else
    if (tPos = 2) then
      return(105)
    end if
  end if
  return(5)
end

on userClicked me, tName 
  if not windowExists(pModtoolWindowID) then
    return TRUE
  end if
  if (tName = getObject(#session).GET("user_name")) then
    return TRUE
  end if
  tWndObj = getWindow(pModtoolWindowID)
  if tWndObj.elementExists("modtool_name") then
    tWndObj.getElement("modtool_name").setText(tName)
  end if
  return TRUE
end

on changeModtoolView me, tWndName, tAction 
  pModToolMode = tAction
  if windowExists(pModtoolWindowID) then
    tWndObj = getWindow(pModtoolWindowID)
    tWndObj.unmerge()
  else
    createWindow(pModtoolWindowID, "habbo_full.window")
    if not windowExists(pModtoolWindowID) then
      return FALSE
    end if
    tWndObj = getWindow(pModtoolWindowID)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcModToolWnd, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcModToolWnd, me.getID(), #keyDown)
  end if
  tHeader = ""
  if (tWndName = "user") then
    if not tWndObj.merge("habbo_modtool_user.window") then
      return(removeWindow(pModtoolWindowID))
    end if
    if (tWndName = "kick") then
      tHeader = getText("modtool_kickuser")
    else
      if (tWndName = "alert") then
        tHeader = getText("modtool_alertuser")
      else
        if (tWndName = "ban") then
          tHeader = getText("modtool_banuser")
        end if
      end if
    end if
    tWndObj.getElement("modtool_subtitle").setText(getText("modtool_message"))
  else
    if (tWndName = "room") then
      if not tWndObj.merge("habbo_modtool_room.window") then
        return(removeWindow(pModtoolWindowID))
      end if
      if (tWndName = "roomalert") then
        tHeader = getText("modtool_roomalert")
      else
        if (tWndName = "roomkick") then
          tHeader = getText("modtool_roomkick")
        end if
      end if
    else
      if (tWndName = "ban") then
        tWndObj.merge("habbo_modtool_ban.window")
        me.InitializeBanCheckBoxes()
        me.initializeBanDropDown()
      end if
    end if
  end if
  if tHeader <> "" then
    tWndObj.getElement("modtool_title").setText(tHeader)
  end if
  return TRUE
end

on openCryReplyWindow me 
  if not windowExists(pCryWindowID) then
    return FALSE
  end if
  tWndObj = getWindow(pCryWindowID)
  pCryWndMode = "reply"
  tWndObj.unmerge()
  if not tWndObj.merge("habbo_hobba_reply.window") then
    return(removeWindow(pCryWindowID))
  end if
  tName = pCurrCryData.getAt(#sender)
  tMsg = pCurrCryData.getAt(#Msg)
  tWndObj.getElement("hobba_reply_header").setText(getText("hobba_reply_cfh") && tName)
  tWndObj.getElement("hobba_reply_text").setText(tMsg)
  return TRUE
end

on update me 
  pAlertTimer = ((pAlertTimer + 1) mod 4)
  if pAlertTimer <> 0 then
    return TRUE
  end if
  if pAlertSpr.ilk <> #sprite then
    return(removeUpdate(me.getID()))
  end if
  tName = pAlertSpr.member.name
  tNum = integer(tName.getProp(#char, length(tName)))
  tName = tName.getProp(#char, 1, (length(tName) - 1)) & not tNum
  pAlertSpr.memberNum = getmemnum(tName)
  return TRUE
end

on updateCryData me, tCryNumOrID 
  tCryDB = me.getComponent().getCryDataBase()
  tCryCount = tCryDB.count
  if (tCryCount = 0) then
    me.hideAlert()
    me.hideCryWnd()
    return TRUE
  end if
  tUnpickedFound = 0
  repeat while tCryDB <= undefined
    tCry = getAt(undefined, tCryNumOrID)
    if (tCry.getAt(#picker) = "") then
      tUnpickedFound = 1
    else
    end if
  end repeat
  if not tUnpickedFound then
    me.stopAlert()
  end if
  if not windowExists(pCryWindowID) then
    return FALSE
  end if
  if stringp(tCryNumOrID) then
    tCryID = tCryNumOrID
    pCurrCryData = tCryDB.getAt(tCryID)
    i = 1
    repeat while i <= tCryCount
      if (tCryDB.getPropAt(i) = tCryID) then
        pCurrCryNum = i
      else
        i = (1 + i)
      end if
    end repeat
    exit repeat
  end if
  if integerp(tCryNumOrID) then
    if tCryNumOrID < 1 or tCryNumOrID > tCryCount then
      return FALSE
    end if
    tCryID = tCryDB.getPropAt(tCryNumOrID)
    pCurrCryData = tCryDB.getAt(tCryID)
    pCurrCryNum = tCryNumOrID
  else
    return(error(me, "String or integer expected:" && tCryNumOrID, #updateCryData, #major))
  end if
  if voidp(pCurrCryData) then
    if pCurrCryNum > 0 and pCurrCryNum <= count(tCryDB) then
      tNewID = tCryDB.getPropAt(pCurrCryNum)
    else
      tNewID = tCryDB.getPropAt(count(tCryDB))
    end if
    return(me.updateCryData(tNewID))
  else
    pCurrCryID = tCryID
  end if
  if pCryWndMode <> "browse" then
    return TRUE
  end if
  me.redrawCryWindow()
  return TRUE
end

on redrawCryWindow me 
  tCryDB = me.getComponent().getCryDataBase()
  tCryCount = tCryDB.count
  tName = pCurrCryData.getAt(#sender)
  tPlace = pCurrCryData.getAt(#roomname)
  tMsg = pCurrCryData.getAt(#Msg)
  tTime = pCurrCryData.getAt(#time)
  tCategory = pCurrCryData.getAt(#category)
  tRoomID = pCurrCryData.getAt(#room_id)
  ttype = pCurrCryData.getAt(#type)
  if tRoomID <> void() and getObject(#session).GET("user_rights").getOne("fuse_see_flat_ids") <> 0 then
    tShowRoomID = "(id: " & tRoomID & ")"
  else
    tShowRoomID = ""
  end if
  tWndObj = getWindow(pCryWindowID)
  tNeededElements = ["hobba_header", "hobba_change_cfh_type", "hobba_pickedby", "hobba_cry_text", "page_num"]
  repeat while tNeededElements <= undefined
    tElem = getAt(undefined, undefined)
    if not tWndObj.elementExists(tElem) then
      return FALSE
    end if
  end repeat
  if (tCategory = 1) or (tCategory = 2) then
    tWndObj.getElement("hobba_header").setProperty(#color, rgb(0, 0, 0))
    tWndObj.getElement("hobba_header").setText(getText("hobba_emergency_help") && tName)
    tWndObj.getElement("hobba_change_cfh_type").setText(getText("hobba_mark_normal"))
  else
    if (tCategory = 3) then
      tWndObj.getElement("hobba_header").setProperty(#color, rgb(255, 0, 0))
      tWndObj.getElement("hobba_header").setText(getText("hobba_cryforhelp") && tName)
      tWndObj.getElement("hobba_change_cfh_type").setText(getText("hobba_mark_emergency"))
    else
      if (tCategory = 4) then
        tWndObj.getElement("hobba_header").setProperty(#color, rgb(255, 0, 0))
        tWndObj.getElement("hobba_header").setText(getText("hobba_im_cryforhelp") && tName)
        tWndObj.getElement("hobba_change_cfh_type").setText(getText("hobba_mark_emergency"))
      end if
    end if
  end if
  if (tCategory = 3) or (tCategory = 4) then
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
  tWndObj.getElement("hobba_cry_text").setText(tPlace && tShowRoomID & "\r" & "\r" & tMsg)
  tWndObj.getElement("page_num").setText(pCurrCryNum & "/" & tCryCount)
  if (pCurrCryData.picker = "") then
    tWndObj.getElement("hobba_pickedby").setText(tTime)
  else
    tWndObj.getElement("hobba_pickedby").setText(getText("hobba_pickedby") && pCurrCryData.picker)
  end if
end

on initAudioAlertCheckBox me 
  if not windowExists(pModtoolWindowID) then
    return FALSE
  end if
  tWndObj = getWindow(pModtoolWindowID)
  if not tWndObj.elementExists("modtool_checkbox_audioalert") then
    return FALSE
  end if
  if not memberExists("button.checkbox.off") then
    return FALSE
  end if
  if not memberExists("button.checkbox.on") then
    return FALSE
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
    return FALSE
  end if
  tWndObj = getWindow(pModtoolWindowID)
  if not tWndObj.elementExists("modtool_checkbox_ip") then
    return FALSE
  end if
  if not memberExists("button.checkbox.off") then
    return FALSE
  end if
  tOffImg = getMember("button.checkbox.off").image
  tWndObj.getElement("modtool_checkbox_ip").feedImage(tOffImg)
  tWndObj.getElement("modtool_checkbox_computer").feedImage(tOffImg)
  pModToolCheckBoxes = [0, 0]
  return TRUE
end

on initializeBanDropDown me 
  tWndObj = getWindow(pModtoolWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  if not tWndObj.elementExists("ban_length_menu") then
    return FALSE
  end if
  tDropDown = tWndObj.getElement("ban_length_menu")
  tHours = getText("modtool_hours")
  tDays = getText("modtool_days")
  tVisOptions = ["2" && tHours, "4" && tHours, "12" && tHours, "24" && tHours, "2" && tDays, "3" && tDays, "7" && tDays, "14" && tDays]
  tVisOptions.add("21" && tDays)
  tVisOptions.add("30" && tDays)
  tVisOptions.add("60" && tDays)
  tVisOptions.add("365" && tDays)
  tVisOptions.add("730" && tDays)
  tVisOptions.add("4167" && tDays)
  tBanLengths = [2, 4, 12, 24, (2 * 24), (3 * 24), (7 * 24), (14 * 24), (21 * 24), (30 * 24), (60 * 24), (365 * 24), (730 * 24), 100000]
  tDropDown.updateData(tVisOptions, tBanLengths, 1)
  tDropDown.setOrdering(0)
  return TRUE
end

on checkBoxClicked me, ttype 
  if not windowExists(pModtoolWindowID) then
    return FALSE
  end if
  if not memberExists("button.checkbox.on") then
    return FALSE
  end if
  tMemOn = getMember("button.checkbox.on")
  tMemOff = getMember("button.checkbox.off")
  if tMemOn.type <> #bitmap or tMemOff.type <> #bitmap then
    return FALSE
  end if
  tWndObj = getWindow(pModtoolWindowID)
  if (ttype = "ip") then
    pModToolCheckBoxes.setAt(1, not pModToolCheckBoxes.getAt(1))
    if pModToolCheckBoxes.getAt(1) then
      tWndObj.getElement("modtool_checkbox_ip").feedImage(tMemOn.image)
    else
      tWndObj.getElement("modtool_checkbox_ip").feedImage(tMemOff.image)
    end if
  else
    if (ttype = "computer") then
      pModToolCheckBoxes.setAt(2, not pModToolCheckBoxes.getAt(2))
      if pModToolCheckBoxes.getAt(2) then
        tWndObj.getElement("modtool_checkbox_computer").feedImage(tMemOn.image)
      else
        tWndObj.getElement("modtool_checkbox_computer").feedImage(tMemOff.image)
      end if
    else
      if (ttype = "audioalert") then
        pAudioAlertCheckBox = not pAudioAlertCheckBox
        if pAudioAlertCheckBox then
          tWndObj.getElement("modtool_checkbox_audioalert").feedImage(tMemOn.image)
        else
          tWndObj.getElement("modtool_checkbox_audioalert").feedImage(tMemOff.image)
        end if
      end if
    end if
  end if
  return TRUE
end

on sendModCommand me 
  if not windowExists(pModtoolWindowID) then
    return TRUE
  end if
  tWndObj = getWindow(pModtoolWindowID)
  tCommandString = ""
  if tWndObj.elementExists("modtool_name") then
    tName = tWndObj.getElement("modtool_name").getText()
  end if
  if tWndObj.elementExists("modtool_reason") then
    tReason = tWndObj.getElement("modtool_reason").getText()
  end if
  if tWndObj.elementExists("modtool_extrainfo") then
    tExtrainfo = tWndObj.getElement("modtool_extrainfo").getText()
  end if
  if (pModToolMode = "ban") then
    if not tWndObj.elementExists("ban_length_menu") then
      return FALSE
    end if
    tHours = tWndObj.getElement("ban_length_menu").getSelection()
    tBanIP = pModToolCheckBoxes.getAt(1)
    tBanComputer = pModToolCheckBoxes.getAt(2)
  else
    if (pModToolMode = "alert") then
      tTargetType = 0
      tActionType = 0
    else
      if (pModToolMode = "kick") then
        tTargetType = 0
        tActionType = 1
      else
        if (pModToolMode = "roomkick") then
          tTargetType = 1
          tActionType = 1
        else
          if (pModToolMode = "roomalert") then
            tTargetType = 1
            tActionType = 0
          end if
        end if
      end if
    end if
  end if
  if (pModToolMode = "ban") then
    tStruct = [#integer:0, #integer:2, #string:tReason, #string:tExtrainfo, #string:tName, #integer:tHours, #integer:tBanComputer, #integer:tBanIP]
  else
    if (tTargetType = 0) then
      tStruct = [#integer:tTargetType, #integer:tActionType, #string:tReason, #string:tExtrainfo, #string:tName]
    else
      tStruct = [#integer:tTargetType, #integer:tActionType, #string:tReason, #string:tExtrainfo]
    end if
  end if
  getConnection(getVariable("connection.info.id")).send("MODERATIONACTION", tStruct)
  return(me.showModToolWnd())
end

on eventProcCryWnd me, tEvent, tElemID, tParam 
  if (tEvent = #mouseUp) then
    if (tElemID = "close") then
      return(me.hideCryWnd())
    else
      if (tElemID = "hobba_prev") then
        return(me.updateCryData((pCurrCryNum - 1)))
      else
        if (tElemID = "hobba_next") then
          return(me.updateCryData((pCurrCryNum + 1)))
        else
          if (tElemID = "hobba_seelog") then
            tUrlPrefix = getText("chatlog.url")
            if tUrlPrefix contains "http" then
              executeMessage(#externalLinkClick, the mouseLoc)
              return(openNetPage(tUrlPrefix & pCurrCryData.getAt(#url_id), "_new"))
            else
              return(error(me, "CFH log url prefix not defined or illegal:" && tUrlPrefix, #eventProcCryWnd, #minor))
            end if
          else
            if (tElemID = "hobba_pickup") then
              return(me.getComponent().send_cryPick(pCurrCryID, 0))
            else
              if (tElemID = "hobba_pickup_go") then
                return(me.getComponent().send_cryPick(pCurrCryID, 1))
              else
                if (tElemID = "hobba_pickandreply") then
                  me.openCryReplyWindow()
                  return(me.getComponent().send_cryPick(pCurrCryID, 0))
                else
                  if (tElemID = "hobba_reply_button") then
                    tText = getWindow(pCryWindowID).getElement("hobba_reply_field").getText()
                    me.getComponent().send_CfhReply(pCurrCryID, tText)
                    me.hideCryWnd()
                    return(me.showCryWnd())
                  else
                    if (tElemID = "hobba_reply_cancel") then
                      me.hideCryWnd()
                      return(me.showCryWnd())
                    else
                      if (tElemID = "hobba_change_cfh_type") then
                        return(me.getComponent().send_changeCfhType(pCurrCryID, pCurrCryData.getAt(#category)))
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
  else
    if (tEvent = #keyDown) then
      if (tElemID = "hobba_reply_field") then
        tKeyCode = the keyCode
        if not (tKeyCode = 51) or (tKeyCode = 117) then
          tWndObj = getWindow(pCryWindowID)
          tElem = tWndObj.getElement("hobba_reply_field")
          tText = tElem.getText()
          tMaxTextLength = 512
          tMaxLineCounts = 4
          if tText.length >= 512 or tText.count(#line) > tMaxLineCounts then
            return TRUE
          end if
        end if
        pass()
      end if
    end if
  end if
end

on eventProcModToolWnd me, tEvent, tElemID, tParam 
  if (tEvent = #mouseUp) then
    if (tElemID = "close") then
      me.hideModToolWnd()
    else
      if (tElemID = "modtool_cancel") then
        me.showModToolWnd()
      else
        if (tElemID = "modtool_kickuser") then
          me.changeModtoolView("user", "kick")
        else
          if (tElemID = "modtool_banuser") then
            me.changeModtoolView("ban", "ban")
          else
            if (tElemID = "modtool_alertuser") then
              me.changeModtoolView("user", "alert")
            else
              if (tElemID = "modtool_roomkick") then
                me.changeModtoolView("room", "roomkick")
              else
                if (tElemID = "modtool_roomalert") then
                  me.changeModtoolView("room", "roomalert")
                else
                  if (tElemID = "modtool_checkbox_ip") then
                    me.checkBoxClicked("ip")
                  else
                    if (tElemID = "modtool_checkbox_computer") then
                      me.checkBoxClicked("computer")
                    else
                      if (tElemID = "modtool_ok") then
                        return(me.sendModCommand())
                      else
                        if (tElemID = "modtool_checkbox_audioalert") then
                          me.checkBoxClicked("audioalert")
                        else
                          if (tElemID = "aa_checkbox_text") then
                            me.checkBoxClicked("audioalert")
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
  if (tEvent = #keyDown) then
    if (the key = "\t") then
      if not windowExists(pModtoolWindowID) then
        return FALSE
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
        if not (tKeyCode = 51) or (tKeyCode = 117) then
          tWndObj = getWindow(pModtoolWindowID)
          tElem = tWndObj.getElement("modtool_reason")
          tText = tElem.getText()
          tMaxTextLength = 512
          tMaxLineCounts = 4
          if tText.length >= 512 or tText.count(#line) > tMaxLineCounts then
            return TRUE
          end if
        end if
      end if
      pass()
    end if
  end if
  return TRUE
end

on eventProcAlert me, tEvent, tElemID, tParam 
  me.showCryWnd()
  return TRUE
end

on eventProcModToolButton me 
  me.showModToolWnd()
  return TRUE
end
