property pEntryVisual, pSignSprList, pItemObjList, pBottomBar, pAnimUpdate, pFrameCounter, pWaterAnimCounter, pUpdateTasks, pFirstInit, pViewMaxTime, pViewOpenTime, pViewCloseTime, pNewMsgCount, pNewBuddyRequests, pMessengerFlash, pInActiveIconBlend

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
  pFrameCounter = 0
  registerMessage(#userlogin, me.getID(), #showEntryBar)
  registerMessage(#messenger_ready, me.getID(), #activateIcon)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#userlogin, me.getID())
  unregisterMessage(#messenger_ready, me.getID())
  return(me.hideAll())
end

on showHotel me 
  if not visualizerExists(pEntryVisual) then
    if not createVisualizer(pEntryVisual, "entry.visual") then
      return FALSE
    end if
    tVisObj = getVisualizer(pEntryVisual)
    pSignSprList = []
    pSignSprList.add(tVisObj.getSprById("entry_sign"))
    pSignSprList.add(tVisObj.getSprById("entry_sign_sd"))
    pSignSprLocV = pSignSprList.getAt(1).locV
    pItemObjList = []
    tSpr = tVisObj.getSprById("fountain")
    if tSpr <> 0 then
      tObj = createObject(#temp, "Entry Fountain Class")
      tObj.define(tSpr, "sg_fountain_")
      pItemObjList.add(tObj)
    end if
    i = 1
    repeat while 1
      tSpr = tVisObj.getSprById("boat" & i)
      if tSpr <> 0 then
        tObj = createObject(#temp, "Entry Boat Class")
        if i > 1 then
          tSpr2 = tVisObj.getSprById("boat" & i & "_roof")
          tObj.define([tSpr, tSpr2], i)
        else
          tObj.define(tSpr, i)
        end if
        pItemObjList.add(tObj)
      else
      end if
      i = (i + 1)
    end repeat
    i = 1
    repeat while 1
      tSpr = tVisObj.getSprById("cloud" & i)
      if tSpr <> 0 then
        tObj = createObject(#temp, "Entry Cloud Class")
        tObj.define(tSpr, i)
        pItemObjList.add(tObj)
      else
      end if
      i = (i + 1)
    end repeat
    me.remAnimTask(#closeView)
    pViewOpenTime = (the milliSeconds + 500)
    receivePrepare(me.getID())
    me.delay(500, #addAnimTask, #openView)
  end if
  return TRUE
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
  return TRUE
end

on showEntryBar me 
  if not windowExists(pBottomBar) then
    if not createWindow(pBottomBar, "entry_bar.window", 0, 535) then
      return FALSE
    end if
    tWndObj = getWindow(pBottomBar)
    tWndObj.lock(1)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcEntryBar, me.getID(), #mouseUp)
    me.addAnimTask(#animEntryBar)
  end if
  registerMessage(#updateMessageCount, me.getID(), #updateMessageCount)
  registerMessage(#updateCreditCount, me.getID(), #updateCreditCount)
  registerMessage(#updateBuddyrequestCount, me.getID(), #updateBuddyrequestCount)
  registerMessage(#updateFigureData, me.getID(), #updateEntryBar)
  registerMessage(#updateClubStatus, me.getID(), #updateClubStatus)
  return(me.updateEntryBar())
end

on hideEntrybar me 
  unregisterMessage(#updateMessageCount, me.getID())
  unregisterMessage(#updateCreditCount, me.getID())
  unregisterMessage(#updateBuddyrequestCount, me.getID())
  unregisterMessage(#updateFigureData, me.getID())
  unregisterMessage(#updateClubStatus, me.getID())
  if timeoutExists(#flash_messenger_icon) then
    removeTimeout(#flash_messenger_icon)
  end if
  if windowExists(pBottomBar) then
    removeWindow(pBottomBar)
  end if
  return TRUE
end

on hideAll me 
  me.hideHotel()
  me.hideEntrybar()
  return TRUE
end

on prepare me 
  pAnimUpdate = not pAnimUpdate
  if pAnimUpdate then
    tVisual = getVisualizer(pEntryVisual)
    if not tVisual then
      return(removePrepare(me.getID()))
    end if
    pFrameCounter = (pFrameCounter + 1)
    if pFrameCounter > 2 then
      if voidp(pWaterAnimCounter) then
        pWaterAnimCounter = 1
      else
        pWaterAnimCounter = (pWaterAnimCounter + 1)
      end if
      if pWaterAnimCounter > 7 then
        pWaterAnimCounter = 0
      end if
      tSpr = tVisual.getSprById("bg2")
      tMem = tSpr.member
      tMem.paletteRef = member(getmemnum("water" & pWaterAnimCounter & "_palette"))
      pFrameCounter = 0
    end if
    call(#update, pItemObjList)
  end if
end

on update me 
  repeat while pUpdateTasks.duplicate() <= 1
    tMethod = getAt(1, count(pUpdateTasks.duplicate()))
    call(tMethod, me)
  end repeat
end

on updateEntryBar me 
  tWndObj = getWindow(pBottomBar)
  if (tWndObj = 0) then
    return FALSE
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
  return TRUE
end

on addAnimTask me, tMethod 
  if (pUpdateTasks.getPos(tMethod) = 0) then
    pUpdateTasks.add(tMethod)
  end if
  return(receiveUpdate(me.getID()))
end

on remAnimTask me, tMethod 
  pUpdateTasks.deleteOne(tMethod)
  if (pUpdateTasks.count = 0) then
    removeUpdate(me.getID())
  end if
  return TRUE
end

on animSign me 
  tVisObj = getVisualizer(pEntryVisual)
  if (tVisObj = 0) then
    return(me.remAnimTask(#animSign))
  end if
  repeat while pSignSprList <= 1
    tSpr = getAt(1, count(pSignSprList))
    tSpr.locV = (tSpr.locV + 30)
  end repeat
  if pSignSprList.getAt(1).locV >= 0 then
    pSignSprList.getAt(1).locV = 0
    pSignSprList.getAt(2).locV = 0
    me.remAnimTask(#animSign)
  end if
end

on openView me 
  tVisObj = getVisualizer(pEntryVisual)
  if (tVisObj = 0) then
    return(me.remAnimTask(#openView))
  end if
  tTopSpr = tVisObj.getSprById("box_top")
  tBotSpr = tVisObj.getSprById("box_bottom")
  tTimeLeft = ((pViewMaxTime - (the milliSeconds - pViewOpenTime)) / 1000)
  tmoveLeft = (tTopSpr.height - abs(tTopSpr.locV))
  if tTimeLeft <= 0 then
    tOffset = abs(tmoveLeft)
  else
    tOffset = (abs((tmoveLeft / tTimeLeft)) / the frameTempo)
  end if
  tTopSpr.locV = (tTopSpr.locV - tOffset)
  tBotSpr.locV = (tBotSpr.locV + tOffset)
  if tTopSpr.locV <= -tTopSpr.height then
    me.addAnimTask(#animSign)
    me.remAnimTask(#openView)
  end if
end

on closeView me 
  tVisObj = getVisualizer(pEntryVisual)
  if (tVisObj = 0) then
    return(me.remAnimTask(#closeView))
  end if
  tTopSpr = tVisObj.getSprById("box_top")
  tBotSpr = tVisObj.getSprById("box_bottom")
  tTimeLeft = ((pViewMaxTime - (the milliSeconds - pViewCloseTime)) / 1000)
  tmoveLeft = (0 - abs(tTopSpr.locV))
  if tTimeLeft <= 0 then
    tOffset = abs(tmoveLeft)
  else
    tOffset = (abs((tmoveLeft / tTimeLeft)) / the frameTempo)
  end if
  tTopSpr.locV = (tTopSpr.locV + tOffset)
  tBotSpr.locV = (tBotSpr.locV - tOffset)
  if tTopSpr.locV >= 0 then
    me.remAnimTask(#closeView)
    removeVisualizer(pEntryVisual)
  end if
end

on animEntryBar me 
  tWndObj = getWindow(pBottomBar)
  if (tWndObj = 0) then
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
      return FALSE
    end if
    tElement.setText(tCount && getText("int_credits"))
  end if
  return TRUE
end

on updateClubStatus me, tStatus 
  if tStatus.ilk <> #propList then
    return FALSE
  end if
  tWndObj = getWindow(pBottomBar)
  if tWndObj <> 0 then
    if not tWndObj.elementExists("club_bottombar_text1") then
      return FALSE
    end if
    if not tWndObj.elementExists("club_bottombar_text2") then
      return FALSE
    end if
    tDays = (tStatus.getAt(#daysLeft) + (tStatus.getAt(#PrepaidPeriods) * 31))
    if tStatus.getAt(#PrepaidPeriods) < 0 then
      tWndObj.getElement("club_bottombar_text1").setText(getText("club_habbo.bottombar.text.member"))
      tWndObj.getElement("club_bottombar_text2").setText(getText("club_member"))
    else
      if (tDays = 0) then
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
  return TRUE
end

on updateMessageCount me, tCount 
  tWndObj = getWindow(pBottomBar)
  if tWndObj <> 0 then
    me.activateIcon(#messenger)
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

on flashMessengerIcon me 
  tWndObj = getWindow(pBottomBar)
  if tWndObj <> 0 then
    if pMessengerFlash then
      tmember = "mes_lite_icon"
      pMessengerFlash = 0
    else
      tmember = "mes_dark_icon"
      pMessengerFlash = 1
    end if
    if (pNewMsgCount = 0) and (pNewBuddyRequests = 0) then
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
    tWndObj.getElement("messenger_icon_image").setProperty(#image, member(getmemnum(tmember)).image.duplicate())
  end if
end

on activateIcon me, tIcon 
  if windowExists(pBottomBar) then
    if (tIcon = #navigator) then
      getWindow(pBottomBar).getElement("nav_icon_image").setProperty(#blend, 100)
    else
      if (tIcon = #messenger) then
        getWindow(pBottomBar).getElement("messenger_icon_image").setProperty(#blend, 100)
      end if
    end if
  end if
end

on deActivateIcon me, tIcon 
  if windowExists(pBottomBar) then
    if (tIcon = #navigator) then
      getWindow(pBottomBar).getElement("nav_icon_image").setProperty(#blend, pInActiveIconBlend)
    else
      if (tIcon = #messenger) then
        getWindow(pBottomBar).getElement("messenger_icon_image").setProperty(#blend, pInActiveIconBlend)
      end if
    end if
  end if
end

on deActivateAllIcons me 
  tIcons = ["messenger"]
  if windowExists(pBottomBar) then
    repeat while tIcons <= 1
      tIcon = getAt(1, count(tIcons))
      getWindow(pBottomBar).getElement(tIcon & "_icon_image").setProperty(#blend, pInActiveIconBlend)
    end repeat
  end if
end

on createMyHeadIcon me 
  if objectExists("Figure_Preview") then
    getObject("Figure_Preview").createHumanPartPreview(pBottomBar, "ownhabbo_icon_image", ["hd", "fc", "ey", "hr"])
  end if
end

on eventProcEntryBar me, tEvent, tSprID, tParam 
  if (tSprID = "help_icon_image") then
    return(executeMessage(#openGeneralDialog, #help))
  else
    if tSprID <> "get_credit_text" then
      if (tSprID = "purse_icon_image") then
        return(executeMessage(#openGeneralDialog, #purse))
      else
        if (tSprID = "nav_icon_image") then
          return(executeMessage(#show_hide_navigator))
        else
          if (tSprID = "messenger_icon_image") then
            return(executeMessage(#show_hide_messenger))
          else
            if (tSprID = "new_messages_text") then
              if pNewMsgCount > 0 then
                return(executeMessage(#show_hide_messenger))
              end if
            else
              if (tSprID = "friendrequests_text") then
                if pNewBuddyRequests > 0 then
                  return(executeMessage(#show_hide_messenger))
                end if
              else
                if tSprID <> "update_habboid_text" then
                  if (tSprID = "ownhabbo_icon_image") then
                    if threadExists(#registration) then
                      getThread(#registration).getComponent().openFigureUpdate()
                    end if
                  else
                    if tSprID <> "club_icon_image" then
                      if (tSprID = "club_bottombar_text2") then
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
