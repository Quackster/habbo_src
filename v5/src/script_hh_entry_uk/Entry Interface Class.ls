property pEntryVisual, pSignSprList, pItemObjList, pBottomBar, pAnimUpdate, pUpdateTasks, pFirstInit, pViewMaxTime, pViewOpenTime, pViewCloseTime, pNewMsgCount, pNewBuddyRequests, pMessengerFlash, pInActiveIconBlend

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
  registerMessage(#userlogin, me.getID(), #showEntryBar)
  registerMessage(#messenger_ready, me.getID(), #activateIcon)
  registerMessage(#updateCreditCount, me.getID(), #updateCreditCount)
  registerMessage(#updateMessageCount, me.getID(), #updateMessageCount)
  registerMessage(#updateBuddyrequestCount, me.getID(), #updateBuddyrequestCount)
  registerMessage(#updateFigureData, me.getID(), #updateEntryBar)
  registerMessage(#updateClubStatus, me.getID(), #updateClubStatus)
  return(1)
end

on deconstruct me 
  unregisterMessage(#userlogin, me.getID())
  unregisterMessage(#messenger_ready, me.getID())
  unregisterMessage(#updateCreditCount, me.getID())
  unregisterMessage(#updateMessageCount, me.getID())
  unregisterMessage(#updateBuddyrequestCount, me.getID())
  unregisterMessage(#updateFigureData, me.getID())
  unregisterMessage(#updateClubStatus, me.getID())
  return(me.hideAll())
end

on showHotel me 
  if not visualizerExists(pEntryVisual) then
    createVisualizer(pEntryVisual, "entry_uk.visual")
    tVisObj = getVisualizer(pEntryVisual)
    pSignSprList = []
    pSignSprList.add(tVisObj.getSprById("entry_sign"))
    pSignSprList.add(tVisObj.getSprById("entry_sign_sd"))
    pSignSprLocV = pSignSprList.getAt(1).locV
    pItemObjList = []
    i = 1
    repeat while 1
      tSpr = tVisObj.getSprById("car" & i)
      if tSpr <> 0 then
        if i mod 2 then
          tdir = #right
        else
          tdir = #left
        end if
        tObj = createObject(#temp, "Entry Car Class")
        tObj.define(tSpr, tdir)
        pItemObjList.add(tObj)
      else
      end if
      i = i + 1
    end repeat
    i = 1
    repeat while 1
      tSpr = tVisObj.getSprById("cloud" & i)
      if tSpr <> 0 then
        tObj = createObject(#temp, "Entry Cloud Class")
        tObj.define(tSpr)
        pItemObjList.add(tObj)
      else
      end if
      i = i + 1
    end repeat
    me.remAnimTask(#closeView)
    pViewOpenTime = the milliSeconds + 500
    receivePrepare(me.getID())
    me.delay(500, #addAnimTask, #openView)
  end if
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
  return(1)
end

on showEntryBar me 
  if not windowExists(pBottomBar) then
    createWindow(pBottomBar, "entry_bar.window", 0, 535)
    tWndObj = getWindow(pBottomBar)
    tWndObj.lock(1)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcEntryBar, me.getID(), #mouseUp)
    me.addAnimTask(#animEntryBar)
  end if
  return(me.updateEntryBar())
end

on hideEntrybar me 
  if timeoutExists(#flash_messenger_icon) then
    removeTimeout(#flash_messenger_icon)
  end if
  if windowExists(pBottomBar) then
    removeWindow(pBottomBar)
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
    tSpr = tVisual.getSprById("flags")
    tName = member.name
    tNum = integer(tName.getProp(#char, length(tName)))
    tNum = tNum mod 6 + 1
    tMem = member(getmemnum("hotel_flags" & tNum))
    tSpr.member = tMem
    tSpr.width = tMem.width
    tSpr.height = tMem.height
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
  tName = tSession.get("user_name")
  tText = tSession.get("user_customData")
  if tSession.exists("user_walletbalance") then
    tCrds = tSession.get("user_walletbalance")
  else
    tCrds = getText("loading", "Loading")
  end if
  if tSession.exists("club_status") then
    tClub = tSession.get("club_status")
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
  me.updateMessageCount(0)
  me.updateBuddyrequestCount(0)
  me.createMyHeadIcon()
  me.updateClubStatus(tClub)
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
  tTimeLeft = pViewMaxTime - the milliSeconds - pViewOpenTime / 1000
  tmoveLeft = tTopSpr.height - abs(tTopSpr.locV)
  if tTimeLeft <= 0 then
    tOffset = abs(tmoveLeft)
  else
    tOffset = abs(tmoveLeft / tTimeLeft) / the frameTempo
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
  tTimeLeft = pViewMaxTime - the milliSeconds - pViewCloseTime / 1000
  tmoveLeft = 0 - abs(tTopSpr.locV)
  if tTimeLeft <= 0 then
    tOffset = abs(tmoveLeft)
  else
    tOffset = abs(tmoveLeft / tTimeLeft) / the frameTempo
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
  tWndObj.moveBy(0, -5)
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
  tWndObj = getWindow(pBottomBar)
  if tWndObj <> 0 then
    if listp(tStatus) then
      if tStatus.getAt(#status) = "active" then
        tStr = getText("club_habbo.bottombar.link.member")
        tStr = replaceChunks(tStr, "%days%", tStatus.getAt(#daysLeft))
        tWndObj.getElement("club_bottombar_text1").setText(getText("club_habbo.bottombar.text.member"))
        tWndObj.getElement("club_bottombar_text2").setText(tStr)
      else
        if tStatus.getAt(#status) = "inactive" then
          tWndObj.getElement("club_bottombar_text1").setText(getText("club_habbo.bottombar.text.notmember"))
          tWndObj.getElement("club_bottombar_text2").setText(getText("club_habbo.bottombar.link.notmember"))
        end if
      end if
    else
      tWndObj.getElement("club_bottombar_text1").setText(getText("club_habbo.bottombar.text.notmember"))
      tWndObj.getElement("club_bottombar_text2").setText(getText("club_habbo.bottombar.link.notmember"))
    end if
  end if
  return(1)
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
      tElem.getProperty(#sprite).setcursor("cursor.finger")
    else
      tFont.setaProp(#fontStyle, [#plain])
      tElem.getProperty(#sprite).setcursor(0)
    end if
    tElem.setFont(tFont)
    tElem.setText(tText)
    if pNewMsgCount > 0 then
      me.flashMessengerIcon()
    end if
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
      tElem.getProperty(#sprite).setcursor("cursor.finger")
    else
      tFont.setaProp(#fontStyle, [#plain])
      tElem.getProperty(#sprite).setcursor(0)
    end if
    tElem.setFont(tFont)
    tElem.setText(tText)
    if pNewBuddyRequests > 0 then
      me.flashMessengerIcon()
    end if
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
    if pNewMsgCount = 0 and pNewBuddyRequests = 0 then
      tmember = "mes_dark_icon"
      removeTimeout(#flash_messenger_icon)
    else
      if not timeoutExists(#flash_messenger_icon) then
        createTimeout(#flash_messenger_icon, 500, #flashMessengerIcon, me.getID(), void(), 0)
      end if
    end if
    tWndObj.getElement("messenger_icon_image").getProperty(#sprite).setMember(member(getmemnum(tmember)))
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
  if threadExists(#registration) then
    getThread(#registration).getComponent().createHumanPartPreview(pBottomBar, "ownhabbo_icon_image", ["hd", "fc", "ey", "hr"])
  end if
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
                    if threadExists(#registration) then
                      getThread(#registration).getComponent().openFigureUpdate()
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
