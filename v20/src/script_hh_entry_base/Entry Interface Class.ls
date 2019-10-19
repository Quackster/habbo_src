property pSwapAnimations, pEntryVisual, pSignSprList, pItemObjList, pBottomBar, pBouncerID, pAnimUpdate, pUpdateTasks, pFirstInit, pViewMaxTime, pViewOpenTime, pViewCloseTime, pNewMsgCount, pNewBuddyRequests, pMessengerFlash, pInActiveIconBlend

on construct me 
  pEntryVisual = "entry_view"
  pBottomBar = "entry_bar"
  pSignSprList = []
  pSignSprLocV = 0
  pItemObjList = []
  pUpdateTasks = []
  pViewMaxTime = 500
  pViewOpenTime = void()
  pViewCloseTime = void()
  pAnimUpdate = 0
  pInActiveIconBlend = 40
  pNewMsgCount = 0
  pNewBuddyRequests = 0
  pClubDaysCount = 0
  pMessengerFlash = 0
  pFirstInit = 1
  pSwapAnimations = []
  pBouncerID = #entry_messenger_icon_bouncer
  registerMessage(#userlogin, me.getID(), #showEntryBar)
  registerMessage(#messenger_ready, me.getID(), #activateIcon)
  registerMessage(#showHotelView, me.getID(), #showHotel)
  registerMessage(#showInvitation, me.getID(), #showInvitation)
  executeMessage(#requestHotelView)
  return(1)
end

on deconstruct me 
  unregisterMessage(#userlogin, me.getID())
  unregisterMessage(#messenger_ready, me.getID())
  unregisterMessage(#showHotelView, me.getID())
  unregisterMessage(#showInvitation, me.getID())
  repeat while pSwapAnimations <= undefined
    tAnimation = getAt(undefined, undefined)
    tAnimation.deconstruct()
  end repeat
  pSwapAnimations = []
  return(me.hideAll())
end

on showHotel me 
  if not visualizerExists(pEntryVisual) then
    if not createVisualizer(pEntryVisual, "entry.visual") then
      return(0)
    end if
    tVisObj = getVisualizer(pEntryVisual)
    pSignSprList = []
    pSignSprList.add(tVisObj.getSprById("entry_sign"))
    pSignSprList.add(tVisObj.getSprById("entry_sign_sd"))
    pSignSprLocV = pSignSprList.getAt(1).locV
    tAnimations = tVisObj.getProperty(#swapAnims)
    if tAnimations <> 0 then
      repeat while tAnimations <= undefined
        tAnimation = getAt(undefined, undefined)
        tObj = createObject(#random, getVariableValue("swap.animation.class"))
        if tObj = 0 then
          error(me, "Error creating swap animation", #showHotel, #minor)
        else
          pSwapAnimations.add(tObj)
          pSwapAnimations.getAt(pSwapAnimations.count).define(tAnimation)
        end if
      end repeat
    end if
    pItemObjList = []
    tAnimations = getVariableValue("hotel.view.animations", [])
    i = 1
    repeat while i <= tAnimations.count
      j = 1
      tAnimationType = tAnimations.getAt(i)
      repeat while 1
        tSpr = tVisObj.getSprById(tAnimationType.getAt(1) & j)
        if tSpr <> 0 then
          tObj = createObject(#temp, tAnimationType.getAt(2))
          if tObj <> 0 then
            tObj.define(tSpr, j)
            pItemObjList.add(tObj)
          else
            error(me, "Error creating object:" && tAnimationType, #showHotel, #minor)
          end if
        else
        end if
        j = j + 1
      end repeat
      i = 1 + i
    end repeat
  end if
  me.remAnimTask(#closeView)
  pViewOpenTime = the milliSeconds + 500
  receivePrepare(me.getID())
  me.delay(500, #addAnimTask, #openView)
  return(1)
end

on hideHotel me 
  if visualizerExists(pEntryVisual) then
    me.addAnimTask(#closeView)
    me.remAnimTask(#animSign)
    me.remAnimTask(#openView)
    pViewCloseTime = the milliSeconds
  end if
  pItemObjList = []
  removePrepare(me.getID())
  repeat while pSwapAnimations <= undefined
    tAnim = getAt(undefined, undefined)
    tAnim.deconstruct()
  end repeat
  pSwapAnimations = []
  return(1)
end

on showEntryBar me 
  if not windowExists(pBottomBar) then
    if not createWindow(pBottomBar, "entry_bar.window", 0, 535) then
      return(0)
    end if
    tWndObj = getWindow(pBottomBar)
    tWndObj.lock(1)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcEntryBar, me.getID(), #mouseUp)
    me.addAnimTask(#animEntryBar)
  end if
  registerMessage(#updateCreditCount, me.getID(), #updateCreditCount)
  registerMessage(#updateMessageCount, me.getID(), #updateMessageCount)
  registerMessage(#updateBuddyrequestCount, me.getID(), #updateBuddyrequestCount)
  registerMessage(#updateFigureData, me.getID(), #updateEntryBar)
  registerMessage(#updateClubStatus, me.getID(), #updateClubStatus)
  return(me.updateEntryBar())
end

on hideEntrybar me 
  unregisterMessage(#updateCreditCount, me.getID())
  unregisterMessage(#updateMessageCount, me.getID())
  unregisterMessage(#updateBuddyrequestCount, me.getID())
  unregisterMessage(#updateFigureData, me.getID())
  unregisterMessage(#updateClubStatus, me.getID())
  if timeoutExists(#flash_messenger_icon) then
    removeTimeout(#flash_messenger_icon)
  end if
  if windowExists(pBottomBar) then
    removeWindow(pBottomBar)
  end if
  if objectExists(pBouncerID) then
    removeObject(pBouncerID)
  end if
  return(1)
end

on hideAll me 
  me.hideHotel()
  me.hideEntrybar()
  return(1)
end

on prepare me 
  pAnimUpdate = not pAnimUpdate
  if pAnimUpdate then
    tVisual = getVisualizer(pEntryVisual)
    if not tVisual then
      return(removePrepare(me.getID()))
    end if
    call(#update, pItemObjList)
  end if
end

on update me 
  repeat while pUpdateTasks.duplicate() <= undefined
    tMethod = getAt(undefined, undefined)
    call(tMethod, me)
  end repeat
end

on updateEntryBar me 
  tWndObj = getWindow(pBottomBar)
  if tWndObj = 0 then
    return(0)
  end if
  tSession = getObject(#session)
  tName = tSession.GET("user_name")
  tText = tSession.GET("user_customData")
  if tSession.exists("user_walletbalance") then
    tCrds = tSession.GET("user_walletbalance")
  else
    tCrds = getText("loading", "Loading")
  end if
  if tSession.exists("club_status") then
    tClub = tSession.GET("club_status")
  else
    tClub = getText("loading", "Loading")
  end if
  tWndObj.getElement("ownhabbo_name_text").setText(tName)
  tWndObj.getElement("ownhabbo_mission_text").setText(tText)
  if pFirstInit then
    me.deActivateAllIcons()
    pFirstInit = 0
  end if
  me.updateCreditCount(tCrds)
  executeMessage(#messageUpdateRequest)
  executeMessage(#buddyUpdateRequest)
  me.updateClubStatus(tClub)
  me.createMyHeadIcon()
  return(1)
end

on addAnimTask me, tMethod 
  if pUpdateTasks.getPos(tMethod) = 0 then
    pUpdateTasks.add(tMethod)
  end if
  return(receiveUpdate(me.getID()))
end

on remAnimTask me, tMethod 
  pUpdateTasks.deleteOne(tMethod)
  if pUpdateTasks.count = 0 then
    removeUpdate(me.getID())
  end if
  return(1)
end

on animSign me 
  tVisObj = getVisualizer(pEntryVisual)
  if tVisObj = 0 then
    return(me.remAnimTask(#animSign))
  end if
  repeat while pSignSprList <= undefined
    tSpr = getAt(undefined, undefined)
    tSpr.locV = tSpr.locV + 30
  end repeat
  if pSignSprList.getAt(1).locV >= 0 then
    pSignSprList.getAt(1).locV = 0
    pSignSprList.getAt(2).locV = 0
    me.remAnimTask(#animSign)
  end if
end

on openView me 
  tVisObj = getVisualizer(pEntryVisual)
  if tVisObj = 0 then
    return(me.remAnimTask(#openView))
  end if
  tTopSpr = tVisObj.getSprById("box_top")
  tBotSpr = tVisObj.getSprById("box_bottom")
  tTimeLeft = (pViewMaxTime - the milliSeconds - pViewOpenTime / 1000)
  tmoveLeft = tTopSpr.height - abs(tTopSpr.locV)
  if tTimeLeft <= 0 then
    tOffset = abs(tmoveLeft)
  else
    tOffset = (abs((tmoveLeft / tTimeLeft)) / the frameTempo)
  end if
  tTopSpr.locV = tTopSpr.locV - tOffset
  tBotSpr.locV = tBotSpr.locV + tOffset
  if tTopSpr.locV <= -tTopSpr.height then
    me.addAnimTask(#animSign)
    me.remAnimTask(#openView)
  end if
end

on closeView me 
  tVisObj = getVisualizer(pEntryVisual)
  if tVisObj = 0 then
    return(me.remAnimTask(#closeView))
  end if
  tTopSpr = tVisObj.getSprById("box_top")
  tBotSpr = tVisObj.getSprById("box_bottom")
  tTimeLeft = (pViewMaxTime - the milliSeconds - pViewCloseTime / 1000)
  tmoveLeft = 0 - abs(tTopSpr.locV)
  if tTimeLeft <= 0 then
    tOffset = abs(tmoveLeft)
  else
    tOffset = (abs((tmoveLeft / tTimeLeft)) / the frameTempo)
  end if
  tTopSpr.locV = tTopSpr.locV + tOffset
  tBotSpr.locV = tBotSpr.locV - tOffset
  if tTopSpr.locV >= 0 then
    me.remAnimTask(#closeView)
    removeVisualizer(pEntryVisual)
  end if
end

on animEntryBar me 
  tWndObj = getWindow(pBottomBar)
  if tWndObj = 0 then
    return(me.remAnimTask(#animEntryBar))
  end if
  tWndObj = getWindow(pBottomBar)
  if the platform contains "windows" then
    tWndObj.moveBy(0, -5)
  else
    tWndObj.moveTo(0, 485)
  end if
  if tWndObj.getProperty(#locY) <= 485 then
    me.remAnimTask(#animEntryBar)
  end if
end

on updateCreditCount me, tCount 
  tWndObj = getWindow(pBottomBar)
  if tWndObj <> 0 then
    tElement = tWndObj.getElement("own_credits_text")
    if not tElement then
      return(0)
    end if
    tElement.setText(tCount && getText("int_credits"))
  end if
  return(1)
end

on updateClubStatus me, tStatus 
  if tStatus.ilk <> #propList then
    return(0)
  end if
  tWndObj = getWindow(pBottomBar)
  if tWndObj <> 0 then
    if not tWndObj.elementExists("club_bottombar_text1") then
      return(0)
    end if
    if not tWndObj.elementExists("club_bottombar_text2") then
      return(0)
    end if
    tDays = tStatus.getAt(#daysLeft) + (tStatus.getAt(#PrepaidPeriods) * 31)
    if tStatus.getAt(#PrepaidPeriods) < 0 then
      tWndObj.getElement("club_bottombar_text1").setText(getText("club_habbo.bottombar.text.member"))
      tWndObj.getElement("club_bottombar_text2").setText(getText("club_member"))
    else
      if tDays = 0 then
        tWndObj.getElement("club_bottombar_text1").setText(getText("club_habbo.bottombar.text.notmember"))
        tWndObj.getElement("club_bottombar_text2").setText(getText("club_habbo.bottombar.link.notmember"))
      else
        tStr = getText("club_habbo.bottombar.link.member")
        tStr = replaceChunks(tStr, "%days%", tDays)
        tWndObj.getElement("club_bottombar_text1").setText(getText("club_habbo.bottombar.text.member"))
        tWndObj.getElement("club_bottombar_text2").setText(tStr)
      end if
    end if
  end if
  return(1)
end

on updateMessageCount me, tCount 
  tWndObj = getWindow(pBottomBar)
  if tWndObj <> 0 then
    me.activateIcon(#messenger)
    if value(tCount) > pNewMsgCount then
      me.bounceMessengerIcon(1)
    end if
    pNewMsgCount = value(tCount)
    tText = tCount && getText("int_newmessages")
    tElem = tWndObj.getElement("new_messages_text")
    tFont = tElem.getFont()
    if pNewMsgCount > 0 then
      tFont.setaProp(#fontStyle, [#underline])
      tElem.setProperty(#cursor, "cursor.finger")
    else
      tFont.setaProp(#fontStyle, [#plain])
      tElem.setProperty(#cursor, 0)
    end if
    tElem.setFont(tFont)
    tElem.setText(tText)
    me.flashMessengerIcon()
  end if
end

on updateBuddyrequestCount me, tCount 
  tWndObj = getWindow(pBottomBar)
  if tWndObj <> 0 then
    me.activateIcon(#messenger)
    if value(tCount) > pNewBuddyRequests then
      me.bounceMessengerIcon(1)
    end if
    pNewBuddyRequests = value(tCount)
    tText = tCount && getText("int_newrequests")
    tElem = tWndObj.getElement("friendrequests_text")
    tFont = tElem.getFont()
    if pNewBuddyRequests > 0 then
      tFont.setaProp(#fontStyle, [#underline])
      tElem.setProperty(#cursor, "cursor.finger")
    else
      tFont.setaProp(#fontStyle, [#plain])
      tElem.setProperty(#cursor, 0)
    end if
    tElem.setFont(tFont)
    tElem.setText(tText)
    me.flashMessengerIcon()
  end if
end

on bounceMessengerIcon me, tstate 
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
    tBouncer.registerElement(pBottomBar, ["messenger_icon_image"])
    tBouncer.setBounce(1)
  else
    tBouncer.setBounce(0)
  end if
end

on flashMessengerIcon me 
  if not windowExists(pBottomBar) then
    return(0)
  end if
  tWndObj = getWindow(pBottomBar)
  if not tWndObj.elementExists("messenger_icon_image") then
    return(0)
  end if
  if tWndObj <> 0 then
    if pMessengerFlash then
      tmember = "mes_lite_icon"
      pMessengerFlash = 0
    else
      tmember = "mes_dark_icon"
      pMessengerFlash = 1
    end if
    if pNewMsgCount = 0 and pNewBuddyRequests = 0 then
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
    #image.setProperty(member(getmemnum(tmember)), image.duplicate())
  end if
end

on activateIcon me, tIcon 
  if windowExists(pBottomBar) then
    if tIcon = #navigator then
      getWindow(pBottomBar).getElement("nav_icon_image").setProperty(#blend, 100)
    else
      if tIcon = #messenger then
        getWindow(pBottomBar).getElement("messenger_icon_image").setProperty(#blend, 100)
      end if
    end if
  end if
end

on deActivateIcon me, tIcon 
  if windowExists(pBottomBar) then
    if tIcon = #navigator then
      getWindow(pBottomBar).getElement("nav_icon_image").setProperty(#blend, pInActiveIconBlend)
    else
      if tIcon = #messenger then
        getWindow(pBottomBar).getElement("messenger_icon_image").setProperty(#blend, pInActiveIconBlend)
      end if
    end if
  end if
end

on deActivateAllIcons me 
  tIcons = ["messenger"]
  if windowExists(pBottomBar) then
    repeat while tIcons <= undefined
      tIcon = getAt(undefined, undefined)
      getWindow(pBottomBar).getElement(tIcon & "_icon_image").setProperty(#blend, pInActiveIconBlend)
    end repeat
  end if
end

on createMyHeadIcon me 
  if objectExists("Figure_Preview") then
    getObject("Figure_Preview").createHumanPartPreview(pBottomBar, "ownhabbo_icon_image", #head)
  end if
end

on showInvitation me, tInvitationData 
  tInvitation = createObject(#random, "Invitation Class")
  tInvitation.show(tInvitationData, pBottomBar, "messenger_icon_image")
end

on eventProcEntryBar me, tEvent, tSprID, tParam 
  if tSprID = "help_icon_image" then
    return(executeMessage(#openGeneralDialog, "help"))
  else
    if tSprID <> "get_credit_text" then
      if tSprID = "purse_icon_image" then
        return(executeMessage(#openGeneralDialog, "purse"))
      else
        if tSprID = "nav_icon_image" then
          return(executeMessage(#show_hide_navigator))
        else
          if tSprID = "messenger_icon_image" then
            me.bounceMessengerIcon(0)
            return(executeMessage(#show_hide_messenger))
          else
            if tSprID = "new_messages_text" then
              if pNewMsgCount > 0 then
                return(executeMessage(#show_hide_messenger))
              end if
            else
              if tSprID = "friendrequests_text" then
                if pNewBuddyRequests > 0 then
                  return(executeMessage(#show_hide_messenger))
                end if
              else
                if tSprID <> "update_habboid_text" then
                  if tSprID = "ownhabbo_icon_image" then
                    tAllowModify = 1
                    if getObject(#session).exists("allow_profile_editing") then
                      tAllowModify = getObject(#session).GET("allow_profile_editing")
                    end if
                    if tAllowModify then
                      if threadExists(#registration) then
                        getThread(#registration).getComponent().openFigureUpdate()
                      end if
                    else
                      openNetPage(getText("url_figure_editor"))
                    end if
                  else
                    if tSprID <> "club_icon_image" then
                      if tSprID = "club_bottombar_text2" then
                        return(executeMessage(#show_clubinfo))
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
