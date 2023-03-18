property pBottomBarId, pFloodblocking, pFloodTimer, pMessengerFlash, pFloodEnterCount, pTextIsHelpTExt, pBouncerID, pIMFlashTimeoutID, pIMFlashState, pPopupControllerID, pTypingTimeoutName, pDisableRoomevents, pSignImg, pSignState, pOldPosH, pOldPosV

on construct me
  pBottomBarId = "RoomBarID"
  pFloodblocking = 0
  pMessengerFlash = 0
  pFloodTimer = 0
  pFloodEnterCount = 0
  pTextIsHelpTExt = 0
  pBouncerID = #roombar_messenger_icon_bouncer
  pIMFlashTimeoutID = #im_icon_flash_timeout
  pPopupControllerID = #roombar_popup_controller
  pTypingTimeoutName = "typing_state_timeout"
  pDisableRoomevents = 0
  if variableExists("disable.roomevents") then
    pDisableRoomevents = getIntVariable("disable.roomevents")
  end if
  registerMessage(#updateMessageCount, me.getID(), #updateMessageCount)
  registerMessage(#updateFriendListIcon, me.getID(), #updateFriendListIcon)
  registerMessage(#soundSettingChanged, me.getID(), #updateSoundButton)
  registerMessage(#IMStateChanged, me.getID(), #updateIMIcon)
  registerMessage(#setRollOverInfo, me.getID(), #setRollOverInfo)
  return 1
end

on deconstruct me
  if timeoutExists(pTypingTimeoutName) then
    removeTimeout(pTypingTimeoutName)
  end if
  unregisterMessage(#updateMessageCount, me.getID())
  unregisterMessage(#updateFriendListIcon, me.getID())
  unregisterMessage(#soundSettingChanged, me.getID())
  unregisterMessage(#IMStateChanged, me.getID())
  unregisterMessage(#setRollOverInfo, me.getID())
  return 1
end

on showRoomBar me, tLayout
  if not windowExists(pBottomBarId) then
    createWindow(pBottomBarId, "empty.window", 0, 487)
  end if
  if not threadExists(#room) then
    return 0
  end if
  tManager = getThread(#room).getComponent().getIconBarManager()
  tManager.define(pBottomBarId)
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return 0
  end if
  tWndObj.lock(1)
  tWndObj.unmerge()
  if not stringp(tLayout) then
    if getThread(#room).getComponent().getSpectatorMode() then
      if me.getWideDocksEnabled() then
        tLayout = "room_bar_spectator_wide.window"
      else
        tLayout = "room_bar_spectator.window"
      end if
    else
      if me.getWideDocksEnabled() then
        tLayout = "room_bar_wide.window"
      else
        tLayout = "room_bar.window"
      end if
    end if
  end if
  if not tWndObj.merge(tLayout) then
    return 0
  end if
  tWndObj.moveZ(getIntVariable("window.default.locz") - 100)
  tWndObj.lock()
  if pDisableRoomevents then
    tEventsIcon = tWndObj.getElement("int_event_image")
    tEventsIcon.setProperty(#member, getMember("event_icon_disabled"))
  end if
  me.updateIMIcon()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #keyDown)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseEnter)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseLeave)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseDown)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseWithin)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseUpOutSide)
  me.updateSoundButton()
  me.hideHiliters()
  if tWndObj.elementExists("int_drop_vote") then
    tWndObj.getElement("int_drop_vote").hide()
  end if
  return 1
end

on hideRoomBar me
  if timeoutExists(#flash_messenger_icon) then
    removeTimeout(#flash_messenger_icon)
  end if
  if windowExists(pBottomBarId) then
    removeWindow(pBottomBarId)
  end if
  if objectExists(pBouncerID) then
    removeObject(pBouncerID)
  end if
  tManager = getThread(#room).getComponent().getIconBarManager()
  tManager.hideExtensions()
end

on applyChatHelpText me
  if not windowExists(pBottomBarId) then
    return 0
  end if
  if windowExists(pBottomBarId) then
    tWindowObj = getWindow(pBottomBarId)
    if tWindowObj.elementExists("chat_field") then
      tChatElem = tWindowObj.getElement("chat_field")
      tChatElem.setText(getText("NUH_chat"))
      pTextIsHelpTExt = 1
    end if
  end if
end

on setSpeechDropdown me, tMode
  if windowExists(pBottomBarId) then
    tWndObj = getWindow(pBottomBarId)
    if tWndObj = 0 then
      return 1
    end if
    tElem = tWndObj.getElement("int_speechmode_dropmenu")
    if tElem = 0 then
      return 1
    end if
    tElem.setSelection(tMode, 1)
    return 1
  end if
end

on setRollOverInfo me, tInfo
  if tInfo = VOID then
    return 0
  end if
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return 0
  end if
  if tWndObj.elementExists("room_tooltip_text") then
    tWndObj.getElement("room_tooltip_text").setText(tInfo)
  end if
end

on updateMessageCount me, tCount
  if tCount > 0 then
    me.updateFriendListIcon(1)
  else
    me.updateFriendListIcon(0)
  end if
end

on updateFriendListIcon me, tActive
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return 0
  end if
  tIconElem = tWndObj.getElement("friend_list_icon")
  if not tIconElem then
    return 0
  end if
  if tActive then
    tIconElem.setProperty(#member, "friend_list_icon_notification")
  else
    tIconElem.setProperty(#member, "friend_list_icon")
  end if
end

on bounceIMIcon me, tstate
  if variableExists("bounce.messenger.icon") then
    if not getVariable("bounce.messenger.icon") then
      return 0
    end if
  end if
  if not objectExists(pBouncerID) then
    createObject(pBouncerID, "Element Bouncer Class")
  end if
  tBouncer = getObject(pBouncerID)
  if tstate = tBouncer.getState() then
    return 1
  end if
  if tstate then
    tBouncer.registerElement(pBottomBarId, ["im_icon"])
    tBouncer.setBounce(1)
  else
    tBouncer.setBounce(0)
  end if
end

on updateSoundButton me
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return 0
  end if
  tstate = getSoundState()
  tElem = tWndObj.getElement("int_sound_image")
  if tElem <> 0 then
    if tstate then
      tMemNum = getmemnum("sounds_small_on_icon")
      if tMemNum > 0 then
        tElem.feedImage(member(tMemNum).image)
      end if
    else
      tMemNum = getmemnum("sounds_small_off_icon")
      if tMemNum > 0 then
        tElem.feedImage(member(tMemNum).image)
      end if
    end if
  end if
end

on setTypingState me, tstate
  tTimeoutTime = 2000
  if tstate = 0 then
    if timeoutExists(pTypingTimeoutName) then
      removeTimeout(pTypingTimeoutName)
    else
      me.sendTypingState(0)
    end if
  else
    if timeoutExists(pTypingTimeoutName) then
      removeTimeout(pTypingTimeoutName)
    end if
    createTimeout(pTypingTimeoutName, tTimeoutTime, #sendTypingState, me.getID(), 1, 1)
  end if
end

on sendTypingState me, tstate
  tConn = getConnection(#Info)
  if tstate = 1 then
    tConn.send("USER_START_TYPING")
  else
    tConn.send("USER_CANCEL_TYPING")
  end if
end

on showVote me
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return 0
  end if
  tWidthLong = tWndObj.getElement("chat_field_bg_long").getProperty(#width)
  tWidthShort = tWndObj.getElement("chat_field_bg_short").getProperty(#width)
  tWndObj.getElement("chat_field").resizeBy(tWidthShort - tWidthLong, 0, 1)
  tWndObj.getElement("chat_field_bg_long").hide()
  if tWndObj.elementExists("int_drop_vote") then
    tWndObj.getElement("int_drop_vote").show()
    tWndObj.getElement("int_drop_vote").feedImage(member(getmemnum("pelle_kyltti1")).image)
    pSignState = VOID
    pOldPosH = -1
    pOldPosV = -1
    pSignImg = image(member(getmemnum("pelle_kyltti2")).width, member(getmemnum("pelle_kyltti2")).height, 16)
  end if
end

on updateIMIcon me
  if not windowExists(pBottomBarId) then
    return 0
  end if
  if not threadExists("instant_messenger") then
    return 0
  end if
  tstate = getThread("instant_messenger").getInterface().getState()
  if voidp(tstate) then
    tstate = #inactive
  end if
  tWnd = getWindow(pBottomBarId)
  tElem = tWnd.getElement("im_icon")
  if tElem = 0 then
    return 0
  end if
  case tstate of
    #Active:
      tmember = getMember("im.icon.active")
      tElem.setProperty(#cursor, "cursor.finger")
      me.bounceIMIcon(0)
      me.flashIMIcon(#stop)
    #highlighted:
      tmember = getMember("im.icon.highlighted")
      tElem.setProperty(#cursor, "cursor.finger")
      me.bounceIMIcon(1)
      me.flashIMIcon(#start)
    #inactive:
      tmember = getMember("im.icon.inactive")
      tElem.setProperty(#cursor, 0)
      me.bounceIMIcon(0)
      me.flashIMIcon(#stop)
    otherwise:
      return 0
  end case
  tElem.setProperty(#member, tmember)
  return 1
end

on flashIMIcon me, tstate
  case tstate of
    #start:
      if timeoutExists(pIMFlashTimeoutID) then
        removeTimeout(pIMFlashTimeoutID)
      end if
      if not timeoutExists(pIMFlashTimeoutID) then
        createTimeout(pIMFlashTimeoutID, 500, #flashIMIcon, me.getID(), #flash, 0)
      end if
    #stop:
      if timeoutExists(pIMFlashTimeoutID) then
        removeTimeout(pIMFlashTimeoutID)
      end if
    #flash:
      tWnd = getWindow(pBottomBarId)
      if not tWnd then
        return 0
      end if
      tElem = tWnd.getElement("im_icon")
      if not objectp(tElem) then
        return 0
      end if
      if pIMFlashState = 1 then
        tElem.setProperty(#member, "im.icon.highlighted.2")
      else
        tElem.setProperty(#member, "im.icon.highlighted")
      end if
      pIMFlashState = not pIMFlashState
  end case
end

on hideHiliters me
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return 0
  end if
  tElementList = tWndObj.getProperty(#elementList)
  repeat with i = 1 to tElementList.count
    tElemName = tElementList.getPropAt(i)
    if tElemName contains "hilite" then
      tElementList[i].hide()
    end if
  end repeat
end

on getWideDocksEnabled me
  if (the stage).image.width >= 960 then
    return 1
  else
    return 0
  end if
end

on eventProcRoomBar me, tEvent, tSprID, tParam
  if (tSprID = "chat_field") and ((tEvent = #keyDown) or (tEvent = #mouseUp)) then
    if pTextIsHelpTExt then
      tChatField = getWindow(pBottomBarId).getElement(tSprID)
      tChatField.setText(EMPTY)
      pTextIsHelpTExt = 0
    end if
  end if
  if (tEvent = #keyDown) and (tSprID = "chat_field") then
    tChatField = getWindow(pBottomBarId).getElement(tSprID)
    if the commandDown and ((the keyCode = 8) or (the keyCode = 9)) then
      if not getObject(#session).GET("user_rights").getOne("fuse_debug_window") then
        tChatField.setText(EMPTY)
        return 1
      end if
    end if
    tKeyCode = the keyCode
    case tKeyCode of
      36, 76:
        if tChatField.getText() = EMPTY then
          return 1
        end if
        if pFloodblocking then
          if the milliSeconds < pFloodTimer then
            return 0
          else
            pFloodEnterCount = VOID
          end if
        end if
        if voidp(pFloodEnterCount) then
          pFloodEnterCount = 0
          pFloodblocking = 0
          pFloodTimer = the milliSeconds
        else
          pFloodEnterCount = pFloodEnterCount + 1
          tFloodCountLimit = 2
          tFloodTimerLimit = 3000
          tFloodTimeout = 30000
          tExternalFloodTimeout = "client.flood.timeout"
          if variableExists(tExternalFloodTimeout) then
            if getVariable(tExternalFloodTimeout) > tFloodTimeout then
              tFloodTimeout = getVariable(tExternalFloodTimeout)
            end if
          end if
          if pFloodEnterCount > tFloodCountLimit then
            if the milliSeconds < (pFloodTimer + tFloodTimerLimit) then
              tChatField.setText(EMPTY)
              createObject("FloodBlocking", "Flood Blocking Class")
              getObject("FloodBlocking").Init(pBottomBarId, tSprID, tFloodTimeout)
              pFloodblocking = 1
              pFloodTimer = the milliSeconds + tFloodTimeout
            else
              pFloodEnterCount = VOID
            end if
          end if
        end if
        getThread(#room).getComponent().sendChat(tChatField.getText())
        executeMessage(#NUH_close, "chat")
        if timeoutExists(pTypingTimeoutName) then
          removeTimeout(pTypingTimeoutName)
        end if
        tChatField.setText(EMPTY)
        return 1
      51:
        if tChatField.getText().length = 1 then
          me.setTypingState(0)
        end if
      117:
        if tChatField.getText() <> EMPTY then
          me.setTypingState(0)
        end if
        tChatField.setText(EMPTY)
      otherwise:
        if tChatField.getText().length = 0 then
          me.setTypingState(1)
        end if
    end case
    return 0
  end if
  if getWindow(pBottomBarId).getElement(tSprID).getProperty(#blend) = 100 then
    case tSprID of
      "int_help_image":
        if tEvent = #mouseUp then
          executeMessage(#openGeneralDialog, #help)
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_help", "interface_icon_help")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_hand_image":
        if tEvent = #mouseUp then
          executeMessage(#NUH_close, "hand")
          getThread(#room).getInterface().getContainer().openClose()
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_hand", "interface_icon_hand")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_brochure_image":
        if tEvent = #mouseUp then
          executeMessage(#show_hide_catalogue)
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_catalog", "interface_icon_catalog")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_purse_image":
        if tEvent = #mouseUp then
          executeMessage(#openGeneralDialog, #purse)
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_purse", "interface_icon_purse")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_controller_image":
        if tEvent = #mouseUp then
          executeMessage(#NUH_close, "games")
          executeMessage(#toggle_ig)
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_ig")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_event_image":
        if tEvent = #mouseUp then
          executeMessage(#NUH_close, "events")
          if pDisableRoomevents then
            return 1
          end if
          executeMessage(#show_hide_roomevents)
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_events")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_nav_image":
        if tEvent = #mouseUp then
          executeMessage(#show_hide_navigator)
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_navigator", "interface_icon_navigator")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "get_credit_text":
        if tEvent = #mouseUp then
          executeMessage(#openGeneralDialog, #purse)
        end if
      "int_speechmode_dropmenu":
        if tEvent = #mouseUp then
          getThread(#room).getComponent().setChatMode(tParam)
        end if
      "int_tv_close":
        if tEvent = #mouseUp then
          getThread(#room).getComponent().setSpectatorMode(0)
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_tv_close")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_sound_image", "int_sound_bg_image":
        if tEvent = #mouseUp then
          setSoundState(not getSoundState())
          getThread(#room).getComponent().getRoomConnection().send("SET_SOUND_SETTING", [#integer: getSoundState()])
          me.updateSoundButton()
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_sound", "interface_icon_sound")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_drop_vote":
        me.eventProcVote(tEvent, tSprID, tParam)
      "im_icon":
        case tEvent of
          #mouseUp:
            return executeMessage(#toggle_im)
          #mouseEnter:
            me.setRollOverInfo(getText("im_tooltip"))
          #mouseLeave:
            me.setRollOverInfo(EMPTY)
        end case
      "friend_list_icon":
        if tEvent = #mouseUp then
          executeMessage(#toggle_friend_list)
          executeMessage(#NUH_close, "friends")
        else
          if tEvent = #mouseEnter then
            tInfo = getText("friend_list_title")
            me.setRollOverInfo(tInfo)
          else
            if tEvent = #mouseLeave then
              me.setRollOverInfo(EMPTY)
            end if
          end if
        end if
    end case
  end if
  if (tEvent = #mouseEnter) or (tEvent = #mouseLeave) then
    if not objectExists(pPopupControllerID) then
      createObject(pPopupControllerID, "Popup Controller Class")
    end if
    tPopupController = getObject(pPopupControllerID)
    tPopupController.handleEvent(tEvent, tSprID, tParam)
  end if
end

on eventProcVote me, tEvent, tSprID, tParam
  if tSprID = "int_drop_vote" then
    tWndObj = getWindow(pBottomBarId)
    if tEvent = #mouseDown then
      tSignMem = member(getmemnum("pelle_kyltti2"))
      tDropElem = tWndObj.getElement("int_drop_vote")
      tDropElem.getProperty(#buffer).image = tSignMem.image.duplicate()
      tDropElem.getProperty(#buffer).regPoint = point(0, 120)
      tDropElem.setProperty(#height, tSignMem.height)
      pSignState = 1
    else
      if tEvent = #mouseUp then
        tSignMem = member(getmemnum("pelle_kyltti1"))
        tDropElem = tWndObj.getElement("int_drop_vote")
        tDropElem.getProperty(#buffer).image = tSignMem.image.duplicate()
        tDropElem.getProperty(#buffer).regPoint = point(0, 0)
        tDropElem.setProperty(#height, tSignMem.height)
        if voidp(pSignState) or (pOldPosV < 7) then
          tSignMode = (pOldPosH * 7) + (pOldPosV + 1)
          if tSignMode > 14 then
            tSignMode = 14
          else
            if tSignMode < 1 then
              tSignMode = 1
            end if
          end if
          executeMessage(#sendVoteSign, tSignMode)
        end if
        pSignState = VOID
      else
        if tEvent = #mouseUpOutSide then
          tSignMem = member(getmemnum("pelle_kyltti1"))
          tDropElem = tWndObj.getElement("int_drop_vote")
          tDropElem.getProperty(#buffer).image = tSignMem.image.duplicate()
          tDropElem.getProperty(#buffer).regPoint = point(0, 0)
          tDropElem.setProperty(#height, tSignMem.height)
          pSignState = VOID
        else
          if tEvent = #mouseWithin then
            if voidp(pSignState) then
              return 
            end if
            if voidp(pSignImg) then
              return 
            end if
            w = 40
            h = 17
            pSignState = 11
            tSignMem = member(getmemnum("pelle_kyltti2"))
            tDropElem = tWndObj.getElement("int_drop_vote")
            tSpr = tDropElem.getProperty(#sprite)
            if (pOldPosH <> ((the mouseH - tSpr.left) / w)) or (pOldPosV <> ((the mouseV - tSpr.top) / h)) then
              if ((the mouseV - tSpr.top) / h) < 7 then
                pOldPosH = (the mouseH - tSpr.left) / w
                pOldPosV = (the mouseV - tSpr.top) / h
                pSignImg.copyPixels(tSignMem.image, pSignImg.rect, pSignImg.rect)
                tSignHiliterImg = member(getmemnum("kyltti_hiliter")).image
                tSignHiliterImg = image(w, h, 16)
                tSignHiliterImg.fill(tSignHiliterImg.rect, rgb(187, 187, 187))
                tdestrect = tSignHiliterImg.rect + rect((w * pOldPosH) + 1, (h * pOldPosV) + 1, (w * pOldPosH) + 1, (h * pOldPosV) + 1)
                pSignImg.copyPixels(tSignHiliterImg, tdestrect, tSignHiliterImg.rect, [#ink: 39])
              else
                pOldPosH = (the mouseH - tSpr.left) / w
                pOldPosV = (the mouseV - tSpr.top) / h
                pSignImg.copyPixels(tSignMem.image, pSignImg.rect, pSignImg.rect)
              end if
              tDropElem.getProperty(#buffer).image = pSignImg
              tDropElem.getProperty(#buffer).regPoint = point(0, 120)
            end if
          end if
        end if
      end if
    end if
  end if
end
