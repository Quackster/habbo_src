property pBottomBarId, pBottomBarExtensionsID, pFloodblocking, pFloodTimer, pMessengerFlash, pNewMsgCount, pNewBuddyReq, pFloodEnterCount, pTextIsHelpTExt, pBouncerID, pPopupControllerID, pTypingTimeoutName, pSignImg, pSignState, pOldPosH, pOldPosV

on construct me
  pBottomBarId = "RoomBarID"
  pBottomBarExtensionsID = "RoomBarExtension"
  pFloodblocking = 0
  pMessengerFlash = 0
  pFloodTimer = 0
  pNewMsgCount = 0
  pNewBuddyReq = 0
  pFloodEnterCount = 0
  pTextIsHelpTExt = 0
  pBouncerID = #roombar_messenger_icon_bouncer
  pPopupControllerID = #roombar_popup_controller
  pTypingTimeoutName = "typing_state_timeout"
  registerMessage(#notify, me.getID(), #notify)
  registerMessage(#updateMessageCount, me.getID(), #updateMessageCount)
  registerMessage(#updateBuddyrequestCount, me.getID(), #updateBuddyrequestCount)
  registerMessage(#soundSettingChanged, me.getID(), #updateSoundButton)
  return 1
end

on deconstruct me
  if timeoutExists(pTypingTimeoutName) then
    removeTimeout(pTypingTimeoutName)
  end if
  if objectExists(pBottomBarExtensionsID) then
    removeObject(pBottomBarExtensionsID)
  end if
  unregisterMessage(#notify, me.getID())
  unregisterMessage(#updateMessageCount, me.getID())
  unregisterMessage(#updateBuddyrequestCount, me.getID())
  unregisterMessage(#objectFinalized, me.getID())
  unregisterMessage(#soundSettingChanged, me.getID())
  unregisterMessage(#showInvitation, me.getID())
  return 1
end

on showRoomBar me
  if not windowExists(pBottomBarId) then
    createWindow(pBottomBarId, "empty.window", 0, 487)
  end if
  if not objectExists(pBottomBarExtensionsID) then
    createObject(pBottomBarExtensionsID, "Room Bar Extensions Manager")
    tObj = getObject(pBottomBarExtensionsID)
    tObj.define(pBottomBarId)
  end if
  tWndObj = getWindow(pBottomBarId)
  if (tWndObj = 0) then
    return 0
  end if
  tWndObj.lock(1)
  tWndObj.unmerge()
  if getThread(#room).getComponent().getSpectatorMode() then
    tLayout = "room_bar_spectator.window"
  else
    tLayout = "room_bar.window"
  end if
  if not tWndObj.merge(tLayout) then
    return 0
  end if
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #keyDown)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseEnter)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseLeave)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseDown)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseWithin)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseUpOutSide)
  me.updateSoundButton()
  executeMessage(#messageUpdateRequest)
  executeMessage(#buddyUpdateRequest)
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
  if objectExists(pBottomBarExtensionsID) then
    tObj = getObject(pBottomBarExtensionsID)
    tObj.hideExtensions()
  end if
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
    if (tWndObj = 0) then
      return 1
    end if
    tElem = tWndObj.getElement("int_speechmode_dropmenu")
    if (tElem = 0) then
      return 1
    end if
    tElem.setSelection(tMode, 1)
    return 1
  end if
end

on setRollOverInfo me, tInfo
  tWndObj = getWindow(pBottomBarId)
  if tWndObj.elementExists("room_tooltip_text") then
    tWndObj.getElement("room_tooltip_text").setText(tInfo)
  end if
end

on updateMessageCount me, tMsgCount
  if windowExists(pBottomBarId) then
    if (value(tMsgCount) > pNewMsgCount) then
      me.bounceMessengerIcon(1)
    end if
    pNewMsgCount = value(tMsgCount)
    me.flashMessengerIcon()
  end if
  return 1
end

on updateBuddyrequestCount me, tReqCount
  if windowExists(pBottomBarId) then
    if (value(tReqCount) > pNewBuddyReq) then
      me.bounceMessengerIcon(1)
    end if
    pNewBuddyReq = value(tReqCount)
    me.flashMessengerIcon()
  end if
  return 1
end

on bounceMessengerIcon me, tstate
  if variableExists("bounce.messenger.icon") then
    if not getVariable("bounce.messenger.icon") then
      return 0
    end if
  end if
  if not objectExists(pBouncerID) then
    createObject(pBouncerID, "Element Bouncer Class")
  end if
  tBouncer = getObject(pBouncerID)
  if (tstate = tBouncer.getState()) then
    return 1
  end if
  if tstate then
    tBouncer.registerElement(pBottomBarId, ["int_messenger_image", "messenger_icon_shadow"])
    tBouncer.setBounce(1)
  else
    tBouncer.setBounce(0)
  end if
end

on flashMessengerIcon me
  tWndObj = getWindow(pBottomBarId)
  if (tWndObj = 0) then
    return 0
  end if
  if not tWndObj.elementExists("int_messenger_image") then
    return 0
  end if
  if pMessengerFlash then
    tmember = "mes_lite_icon"
    pMessengerFlash = 0
  else
    tmember = "mes_dark_icon"
    pMessengerFlash = 1
  end if
  if ((pNewMsgCount = 0) and (pNewBuddyReq = 0)) then
    me.bounceMessengerIcon(0)
    tmember = "mes_dark_icon"
    if timeoutExists(#flash_messenger_icon) then
      removeTimeout(#flash_messenger_icon)
    end if
  else
    if (pNewMsgCount > 0) then
      if not timeoutExists(#flash_messenger_icon) then
        createTimeout(#flash_messenger_icon, 500, #flashMessengerIcon, me.getID(), VOID, 0)
      end if
    else
      tmember = "mes_lite_icon"
      if timeoutExists(#flash_messenger_icon) then
        removeTimeout(#flash_messenger_icon)
      end if
    end if
  end if
  tWndObj.getElement("int_messenger_image").getProperty(#sprite).setMember(member(getmemnum(tmember)))
  return 1
end

on updateSoundButton me
  tWndObj = getWindow(pBottomBarId)
  if (tWndObj = 0) then
    return 0
  end if
  tstate = getSoundState()
  tElem = tWndObj.getElement("int_sound_image")
  if (tElem <> 0) then
    if tstate then
      tMemNum = getmemnum("sounds_small_on_icon")
      if (tMemNum > 0) then
        tElem.feedImage(member(tMemNum).image)
      end if
    else
      tMemNum = getmemnum("sounds_small_off_icon")
      if (tMemNum > 0) then
        tElem.feedImage(member(tMemNum).image)
      end if
    end if
  end if
end

on setTypingState me, tstate
  tTimeoutTime = 2000
  if (tstate = 0) then
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
  if (tstate = 1) then
    tConn.send("USER_START_TYPING")
  else
    tConn.send("USER_CANCEL_TYPING")
  end if
end

on showVote me
  tWndObj = getWindow(pBottomBarId)
  tWidthLong = tWndObj.getElement("chat_field_bg_long").getProperty(#width)
  tWidthShort = tWndObj.getElement("chat_field_bg_short").getProperty(#width)
  tWndObj.getElement("chat_field").resizeBy((tWidthShort - tWidthLong), 0, 1)
  tWndObj.getElement("chat_field_bg_long").hide()
  if tWndObj.elementExists("int_drop_vote") then
    tWndObj.getElement("int_drop_vote").feedImage(member(getmemnum("pelle_kyltti1")).image)
    pSignState = VOID
    pOldPosH = -1
    pOldPosV = -1
    pSignImg = image(member(getmemnum("pelle_kyltti2")).width, member(getmemnum("pelle_kyltti2")).height, 16)
  end if
end

on eventProcRoomBar me, tEvent, tSprID, tParam
  if ((tSprID = "chat_field") and ((tEvent = #keyDown) or (tEvent = #mouseUp))) then
    if pTextIsHelpTExt then
      tChatField = getWindow(pBottomBarId).getElement(tSprID)
      tChatField.setText(EMPTY)
      pTextIsHelpTExt = 0
    end if
  end if
  if ((tEvent = #keyDown) and (tSprID = "chat_field")) then
    tChatField = getWindow(pBottomBarId).getElement(tSprID)
    if (the commandDown and ((the keyCode = 8) or (the keyCode = 9))) then
      if not getObject(#session).GET("user_rights").getOne("fuse_debug_window") then
        tChatField.setText(EMPTY)
        return 1
      end if
    end if
    tKeyCode = the keyCode
    case tKeyCode of
      36, 76:
        if (tChatField.getText() = EMPTY) then
          return 1
        end if
        if pFloodblocking then
          if (the milliSeconds < pFloodTimer) then
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
          pFloodEnterCount = (pFloodEnterCount + 1)
          tFloodCountLimit = 2
          tFloodTimerLimit = 3000
          tFloodTimeout = 30000
          if (pFloodEnterCount > tFloodCountLimit) then
            if (the milliSeconds < (pFloodTimer + tFloodTimerLimit)) then
              tChatField.setText(EMPTY)
              createObject("FloodBlocking", "Flood Blocking Class")
              getObject("FloodBlocking").Init(pBottomBarId, tSprID, tFloodTimeout)
              pFloodblocking = 1
              pFloodTimer = (the milliSeconds + tFloodTimeout)
            else
              pFloodEnterCount = VOID
            end if
          end if
        end if
        getThread(#room).getComponent().sendChat(tChatField.getText())
        if threadExists("new_user_help") then
          tComponent = getThread("new_user_help").getComponent()
          tComponent.setHelpItemClosed("chat")
        end if
        if timeoutExists(pTypingTimeoutName) then
          removeTimeout(pTypingTimeoutName)
        end if
        tChatField.setText(EMPTY)
        return 1
      51:
        if (tChatField.getText().length = 1) then
          me.setTypingState(0)
        end if
      117:
        if (tChatField.getText() <> EMPTY) then
          me.setTypingState(0)
        end if
        tChatField.setText(EMPTY)
      otherwise:
        if (tChatField.getText().length = 0) then
          me.setTypingState(1)
        end if
    end case
    return 0
  end if
  if (getWindow(pBottomBarId).getElement(tSprID).getProperty(#blend) = 100) then
    case tSprID of
      "int_help_image":
        if (tEvent = #mouseUp) then
          executeMessage(#openGeneralDialog, #help)
        end if
        if (tEvent = #mouseEnter) then
          tInfo = getText("interface_icon_help", "interface_icon_help")
          me.setRollOverInfo(tInfo)
        else
          if (tEvent = #mouseLeave) then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_hand_image":
        if (tEvent = #mouseUp) then
          getThread(#room).getInterface().getContainer().openClose()
        end if
        if (tEvent = #mouseEnter) then
          tInfo = getText("interface_icon_hand", "interface_icon_hand")
          me.setRollOverInfo(tInfo)
        else
          if (tEvent = #mouseLeave) then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_brochure_image":
        if (tEvent = #mouseUp) then
          executeMessage(#show_hide_catalogue)
        end if
        if (tEvent = #mouseEnter) then
          tInfo = getText("interface_icon_catalog", "interface_icon_catalog")
          me.setRollOverInfo(tInfo)
        else
          if (tEvent = #mouseLeave) then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_purse_image":
        if (tEvent = #mouseUp) then
          executeMessage(#openGeneralDialog, #purse)
        end if
        if (tEvent = #mouseEnter) then
          tInfo = getText("interface_icon_purse", "interface_icon_purse")
          me.setRollOverInfo(tInfo)
        else
          if (tEvent = #mouseLeave) then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_event_image":
        if (tEvent = #mouseUp) then
          executeMessage(#show_hide_roomevents)
        end if
        if (tEvent = #mouseEnter) then
          tInfo = getText("interface_icon_events")
          me.setRollOverInfo(tInfo)
        else
          if (tEvent = #mouseLeave) then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_nav_image":
        if (tEvent = #mouseUp) then
          executeMessage(#show_hide_navigator)
        end if
        if (tEvent = #mouseEnter) then
          tInfo = getText("interface_icon_navigator", "interface_icon_navigator")
          me.setRollOverInfo(tInfo)
        else
          if (tEvent = #mouseLeave) then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_messenger_image":
        if (tEvent = #mouseUp) then
          me.bounceMessengerIcon(0)
          executeMessage(#show_hide_messenger)
        end if
        if (tEvent = #mouseEnter) then
          tInfo = getText("interface_icon_messenger", "interface_icon_messenger")
          me.setRollOverInfo(tInfo)
        else
          if (tEvent = #mouseLeave) then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_hand_image":
        if (tEvent = #mouseUp) then
          getThread(#room).getInterface().getContainer().openClose()
        end if
      "get_credit_text":
        if (tEvent = #mouseUp) then
          executeMessage(#openGeneralDialog, #purse)
        end if
      "int_speechmode_dropmenu":
        if (tEvent = #mouseUp) then
          getThread(#room).getComponent().setChatMode(tParam)
        end if
      "int_tv_close":
        if (tEvent = #mouseUp) then
          getThread(#room).getComponent().setSpectatorMode(0)
        end if
        if (tEvent = #mouseEnter) then
          tInfo = getText("interface_icon_tv_close")
          me.setRollOverInfo(tInfo)
        else
          if (tEvent = #mouseLeave) then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_sound_image", "int_sound_bg_image":
        if (tEvent = #mouseUp) then
          setSoundState(not getSoundState())
          getThread(#room).getComponent().getRoomConnection().send("SET_SOUND_SETTING", [#integer: getSoundState()])
          me.updateSoundButton()
        end if
        if (tEvent = #mouseEnter) then
          tInfo = getText("interface_icon_sound", "interface_icon_sound")
          me.setRollOverInfo(tInfo)
        else
          if (tEvent = #mouseLeave) then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_drop_vote":
        me.eventProcVote(tEvent, tSprID, tParam)
    end case
  end if
  if ((tEvent = #mouseEnter) or (tEvent = #mouseLeave)) then
    if not objectExists(pPopupControllerID) then
      createObject(pPopupControllerID, "Popup Controller Class")
    end if
    tPopupController = getObject(pPopupControllerID)
    tPopupController.handleEvent(tEvent, tSprID, tParam)
  end if
end

on eventProcVote me, tEvent, tSprID, tParam
  if (tSprID = "int_drop_vote") then
    tWndObj = getWindow(pBottomBarId)
    if (tEvent = #mouseDown) then
      tSignMem = member(getmemnum("pelle_kyltti2"))
      tDropElem = tWndObj.getElement("int_drop_vote")
      tDropElem.getProperty(#buffer).image = tSignMem.image.duplicate()
      tDropElem.getProperty(#buffer).regPoint = point(0, 120)
      tDropElem.setProperty(#height, tSignMem.height)
      pSignState = 1
    else
      if (tEvent = #mouseUp) then
        tSignMem = member(getmemnum("pelle_kyltti1"))
        tDropElem = tWndObj.getElement("int_drop_vote")
        tDropElem.getProperty(#buffer).image = tSignMem.image.duplicate()
        tDropElem.getProperty(#buffer).regPoint = point(0, 0)
        tDropElem.setProperty(#height, tSignMem.height)
        if (voidp(pSignState) or (pOldPosV < 7)) then
          tSignMode = ((pOldPosH * 7) + (pOldPosV + 1))
          if (tSignMode > 14) then
            tSignMode = 14
          else
            if (tSignMode < 1) then
              tSignMode = 1
            end if
          end if
          executeMessage(#sendVoteSign, tSignMode)
        end if
        pSignState = VOID
      else
        if (tEvent = #mouseUpOutSide) then
          tSignMem = member(getmemnum("pelle_kyltti1"))
          tDropElem = tWndObj.getElement("int_drop_vote")
          tDropElem.getProperty(#buffer).image = tSignMem.image.duplicate()
          tDropElem.getProperty(#buffer).regPoint = point(0, 0)
          tDropElem.setProperty(#height, tSignMem.height)
          pSignState = VOID
        else
          if (tEvent = #mouseWithin) then
            if voidp(pSignState) then
              return 
            end if
            w = 40
            h = 17
            pSignState = 11
            tSignMem = member(getmemnum("pelle_kyltti2"))
            tDropElem = tWndObj.getElement("int_drop_vote")
            tSpr = tDropElem.getProperty(#sprite)
            if ((pOldPosH <> ((the mouseH - tSpr.left) / w)) or (pOldPosV <> ((the mouseV - tSpr.top) / h))) then
              if (((the mouseV - tSpr.top) / h) < 7) then
                pOldPosH = ((the mouseH - tSpr.left) / w)
                pOldPosV = ((the mouseV - tSpr.top) / h)
                pSignImg.copyPixels(tSignMem.image, pSignImg.rect, pSignImg.rect)
                tSignHiliterImg = member(getmemnum("kyltti_hiliter")).image
                tSignHiliterImg = image(w, h, 16)
                tSignHiliterImg.fill(tSignHiliterImg.rect, rgb(187, 187, 187))
                tdestrect = (tSignHiliterImg.rect + rect(((w * pOldPosH) + 1), ((h * pOldPosV) + 1), ((w * pOldPosH) + 1), ((h * pOldPosV) + 1)))
                pSignImg.copyPixels(tSignHiliterImg, tdestrect, tSignHiliterImg.rect, [#ink: 39])
              else
                pOldPosH = ((the mouseH - tSpr.left) / w)
                pOldPosV = ((the mouseV - tSpr.top) / h)
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
