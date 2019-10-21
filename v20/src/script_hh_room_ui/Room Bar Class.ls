on construct(me)
  pBottomBarId = "RoomBarID"
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
  registerMessage(#showInvitation, me.getID(), #showInvitation)
  return(1)
  exit
end

on deconstruct(me)
  if timeoutExists(pTypingTimeoutName) then
    removeTimeout(pTypingTimeoutName)
  end if
  unregisterMessage(#notify, me.getID())
  unregisterMessage(#updateMessageCount, me.getID())
  unregisterMessage(#updateBuddyrequestCount, me.getID())
  unregisterMessage(#objectFinalized, me.getID())
  unregisterMessage(#soundSettingChanged, me.getID())
  unregisterMessage(#showInvitation, me.getID())
  return(1)
  exit
end

on showRoomBar(me)
  if not windowExists(pBottomBarId) then
    createWindow(pBottomBarId, "empty.window", 0, 487)
  end if
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return(0)
  end if
  tWndObj.lock(1)
  tWndObj.unmerge()
  if getThread(#room).getComponent().getSpectatorMode() then
    tLayout = "room_bar_spectator.window"
  else
    tLayout = "room_bar.window"
  end if
  if not tWndObj.merge(tLayout) then
    return(0)
  end if
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #keyDown)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseEnter)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseLeave)
  me.updateSoundButton()
  executeMessage(#messageUpdateRequest)
  executeMessage(#buddyUpdateRequest)
  return(1)
  exit
end

on hideRoomBar(me)
  if timeoutExists(#flash_messenger_icon) then
    removeTimeout(#flash_messenger_icon)
  end if
  if windowExists(pBottomBarId) then
    removeWindow(pBottomBarId)
  end if
  if objectExists(pBouncerID) then
    removeObject(pBouncerID)
  end if
  executeMessage(#hideInvitation)
  exit
end

on applyChatHelpText(me)
  if not windowExists(pBottomBarId) then
    return(0)
  end if
  if windowExists(pBottomBarId) then
    tWindowObj = getWindow(pBottomBarId)
    if tWindowObj.elementExists("chat_field") then
      tChatElem = tWindowObj.getElement("chat_field")
      tChatElem.setText(getText("NUH_chat"))
      pTextIsHelpTExt = 1
    end if
  end if
  exit
end

on setSpeechDropdown(me, tMode)
  if windowExists(pBottomBarId) then
    tWndObj = getWindow(pBottomBarId)
    if tWndObj = 0 then
      return(1)
    end if
    tElem = tWndObj.getElement("int_speechmode_dropmenu")
    if tElem = 0 then
      return(1)
    end if
    tElem.setSelection(tMode, 1)
    return(1)
  end if
  exit
end

on setRollOverInfo(me, tInfo)
  tWndObj = getWindow(pBottomBarId)
  if tWndObj.elementExists("room_tooltip_text") then
    tWndObj.getElement("room_tooltip_text").setText(tInfo)
  end if
  exit
end

on updateMessageCount(me, tMsgCount)
  if windowExists(pBottomBarId) then
    if value(tMsgCount) > pNewMsgCount then
      me.bounceMessengerIcon(1)
    end if
    pNewMsgCount = value(tMsgCount)
    me.flashMessengerIcon()
  end if
  return(1)
  exit
end

on updateBuddyrequestCount(me, tReqCount)
  if windowExists(pBottomBarId) then
    if value(tReqCount) > pNewBuddyReq then
      me.bounceMessengerIcon(1)
    end if
    pNewBuddyReq = value(tReqCount)
    me.flashMessengerIcon()
  end if
  return(1)
  exit
end

on bounceMessengerIcon(me, tstate)
  if variableExists("bounce.messenger.icon") then
    if not getVariable("bounce.messenger.icon") then
      return(0)
    end if
  end if
  if not objectExists(pBouncerID) then
    createObject(pBouncerID, "Element Bouncer Class")
  end if
  tBouncer = getObject(pBouncerID)
  if tstate = tBouncer.getState() then
    return(1)
  end if
  if tstate then
    tBouncer.registerElement(pBottomBarId, ["int_messenger_image", "messenger_icon_shadow"])
    tBouncer.setBounce(1)
  else
    tBouncer.setBounce(0)
  end if
  exit
end

on flashMessengerIcon(me)
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return(0)
  end if
  if not tWndObj.elementExists("int_messenger_image") then
    return(0)
  end if
  if pMessengerFlash then
    tmember = "mes_lite_icon"
    pMessengerFlash = 0
  else
    tmember = "mes_dark_icon"
    pMessengerFlash = 1
  end if
  if pNewMsgCount = 0 and pNewBuddyReq = 0 then
    me.bounceMessengerIcon(0)
    tmember = "mes_dark_icon"
    if timeoutExists(#flash_messenger_icon) then
      removeTimeout(#flash_messenger_icon)
    end if
  else
    if pNewMsgCount > 0 then
      if not timeoutExists(#flash_messenger_icon) then
        createTimeout(#flash_messenger_icon, 500, #flashMessengerIcon, me.getID(), void(), 0)
      end if
    else
      tmember = "mes_lite_icon"
      if timeoutExists(#flash_messenger_icon) then
        removeTimeout(#flash_messenger_icon)
      end if
    end if
  end if
  tWndObj.getElement("int_messenger_image").getProperty(#sprite).setMember(member(getmemnum(tmember)))
  return(1)
  exit
end

on updateSoundButton(me)
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return(0)
  end if
  tstate = getSoundState()
  tElem = tWndObj.getElement("int_sound_image")
  if tElem <> 0 then
    if tstate then
      tMemNum = getmemnum("sounds_on_icon")
      if tMemNum > 0 then
        tElem.feedImage(member(tMemNum).image)
      end if
    else
      tMemNum = getmemnum("sounds_off_icon")
      if tMemNum > 0 then
        tElem.feedImage(member(tMemNum).image)
      end if
    end if
  end if
  tElem = tWndObj.getElement("int_sound_bg_image")
  if tElem <> 0 then
    if tstate then
      tMemNum = getmemnum("sounds_on_icon_sd")
      if tMemNum > 0 then
        tElem.feedImage(member(tMemNum).image)
      end if
    else
      tMemNum = getmemnum("sounds_off_icon_sd")
      if tMemNum > 0 then
        tElem.feedImage(member(tMemNum).image)
      end if
    end if
  end if
  exit
end

on showInvitation(me, tInvitationData)
  tInvitation = createObject(#random, "Invitation Class")
  tInvitation.show(tInvitationData, pBottomBarId, "int_messenger_image")
  exit
end

on setTypingState(me, tstate)
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
  exit
end

on sendTypingState(me, tstate)
  tConn = getConnection(#info)
  if tstate = 1 then
    tConn.send("USER_START_TYPING")
  else
    tConn.send("USER_CANCEL_TYPING")
  end if
  exit
end

on eventProcRoomBar(me, tEvent, tSprID, tParam)
  if tSprID = "chat_field" and tEvent = #keyDown or tEvent = #mouseUp then
    if pTextIsHelpTExt then
      tChatField = getWindow(pBottomBarId).getElement(tSprID)
      tChatField.setText("")
      pTextIsHelpTExt = 0
    end if
  end if
  if tEvent = #keyDown and tSprID = "chat_field" then
    tChatField = getWindow(pBottomBarId).getElement(tSprID)
    if the commandDown and the keyCode = 8 or the keyCode = 9 then
      if not getObject(#session).GET("user_rights").getOne("fuse_debug_window") then
        tChatField.setText("")
        return(1)
      end if
    end if
    tKeyCode = the keyCode
    if me <> 36 then
      if me = 76 then
        if tChatField.getText() = "" then
          return(1)
        end if
        if pFloodblocking then
          if the milliSeconds < pFloodTimer then
            return(0)
          else
            pFloodEnterCount = void()
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
          if pFloodEnterCount > tFloodCountLimit then
            if the milliSeconds < pFloodTimer + tFloodTimerLimit then
              tChatField.setText("")
              createObject("FloodBlocking", "Flood Blocking Class")
              getObject("FloodBlocking").Init(pBottomBarId, tSprID, tFloodTimeout)
              pFloodblocking = 1
              pFloodTimer = the milliSeconds + tFloodTimeout
            else
              pFloodEnterCount = void()
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
        tChatField.setText("")
        return(1)
      else
        if me = 51 then
          if tChatField.getText().length = 1 then
            me.setTypingState(0)
          end if
        else
          if me = 117 then
            if tChatField.getText() <> "" then
              me.setTypingState(0)
            end if
            tChatField.setText("")
          else
            if tChatField.getText().length = 0 then
              me.setTypingState(1)
            end if
          end if
        end if
      end if
      return(0)
      if getWindow(pBottomBarId).getElement(tSprID).getProperty(#blend) = 100 then
        if me = "int_help_image" then
          if tEvent = #mouseUp then
            executeMessage(#openGeneralDialog, #help)
          end if
          if tEvent = #mouseEnter then
            tInfo = getText("interface_icon_help", "interface_icon_help")
            me.setRollOverInfo(tInfo)
          else
            if tEvent = #mouseLeave then
              me.setRollOverInfo("")
            end if
          end if
        else
          if me = "int_hand_image" then
            if tEvent = #mouseUp then
              getThread(#room).getInterface().getContainer().openClose()
            end if
            if tEvent = #mouseEnter then
              tInfo = getText("interface_icon_hand", "interface_icon_hand")
              me.setRollOverInfo(tInfo)
            else
              if tEvent = #mouseLeave then
                me.setRollOverInfo("")
              end if
            end if
          else
            if me = "int_brochure_image" then
              if tEvent = #mouseUp then
                executeMessage(#show_hide_catalogue)
              end if
              if tEvent = #mouseEnter then
                tInfo = getText("interface_icon_catalog", "interface_icon_catalog")
                me.setRollOverInfo(tInfo)
              else
                if tEvent = #mouseLeave then
                  me.setRollOverInfo("")
                end if
              end if
            else
              if me = "int_purse_image" then
                if tEvent = #mouseUp then
                  executeMessage(#openGeneralDialog, #purse)
                end if
                if tEvent = #mouseEnter then
                  tInfo = getText("interface_icon_purse", "interface_icon_purse")
                  me.setRollOverInfo(tInfo)
                else
                  if tEvent = #mouseLeave then
                    me.setRollOverInfo("")
                  end if
                end if
              else
                if me = "int_nav_image" then
                  if tEvent = #mouseUp then
                    executeMessage(#show_hide_navigator)
                  end if
                  if tEvent = #mouseEnter then
                    tInfo = getText("interface_icon_navigator", "interface_icon_navigator")
                    me.setRollOverInfo(tInfo)
                  else
                    if tEvent = #mouseLeave then
                      me.setRollOverInfo("")
                    end if
                  end if
                else
                  if me = "int_messenger_image" then
                    if tEvent = #mouseUp then
                      me.bounceMessengerIcon(0)
                      executeMessage(#show_hide_messenger)
                    end if
                    if tEvent = #mouseEnter then
                      tInfo = getText("interface_icon_messenger", "interface_icon_messenger")
                      me.setRollOverInfo(tInfo)
                    else
                      if tEvent = #mouseLeave then
                        me.setRollOverInfo("")
                      end if
                    end if
                  else
                    if me = "int_hand_image" then
                      if tEvent = #mouseUp then
                        getThread(#room).getInterface().getContainer().openClose()
                      end if
                    else
                      if me = "get_credit_text" then
                        if tEvent = #mouseUp then
                          executeMessage(#openGeneralDialog, #purse)
                        end if
                      else
                        if me = "int_speechmode_dropmenu" then
                          if tEvent = #mouseUp then
                            getThread(#room).getComponent().setChatMode(tParam)
                          end if
                        else
                          if me = "int_tv_close" then
                            if tEvent = #mouseUp then
                              getThread(#room).getComponent().setSpectatorMode(0)
                            end if
                            if tEvent = #mouseEnter then
                              tInfo = getText("interface_icon_tv_close")
                              me.setRollOverInfo(tInfo)
                            else
                              if tEvent = #mouseLeave then
                                me.setRollOverInfo("")
                              end if
                            end if
                          else
                            if me <> "int_sound_image" then
                              if me = "int_sound_bg_image" then
                                if tEvent = #mouseUp then
                                  setSoundState(not getSoundState())
                                  getThread(#room).getComponent().getRoomConnection().send("SET_SOUND_SETTING", [#integer:getSoundState()])
                                  me.updateSoundButton()
                                end if
                                if tEvent = #mouseEnter then
                                  tInfo = getText("interface_icon_sound", "interface_icon_sound")
                                  me.setRollOverInfo(tInfo)
                                else
                                  if tEvent = #mouseLeave then
                                    me.setRollOverInfo("")
                                  end if
                                end if
                              end if
                              if tEvent = #mouseEnter or tEvent = #mouseLeave then
                                if not objectExists(pPopupControllerID) then
                                  createObject(pPopupControllerID, "Popup Controller Class")
                                end if
                                tPopupController = getObject(pPopupControllerID)
                                tPopupController.handleEvent(tEvent, tSprID, tParam)
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
end