property pChosenBadge, pChosenVisibility, pImageLibraryURL, pActiveDownloads, pUpdatedBadges, pBadgeListRenderer, pBadgeWindowID, pActiveBadgeID, pActiveSlot, pSelectedBadges, pNewBadges, pNewBadgeDownloads

on construct me
  pChosenBadge = 1
  pChosenVisibility = 1
  pImageLibraryURL = getVariable("image.library.url")
  pActiveDownloads = []
  pBadgeWindowID = "badgeSelectionWindowID"
  pUpdatedBadges = [:]
  pActiveBadgeID = 0
  pActiveSlot = 0
  pSelectedBadges = []
  pNewBadges = []
  pNewBadgeDownloads = []
  pSelectedBadges[5] = 0
  pBadgeListRenderer = createObject(getUniqueID(), "Badge List Class")
  registerMessage(#achievementsUpdated, me.getID(), #updateAchievements)
  registerMessage(#badgeReceived, me.getID(), #addNewBadge)
  registerMessage(#badgeRemoved, me.getID(), #handleBadgeRemove)
  registerMessage(#openBadgeWindow, me.getID(), #openBadgeWindow)
  registerMessage(#openAchievementsWindow, me.getID(), #openAchievementsWindow)
  return 1
end

on deconstruct me
  if windowExists(pBadgeWindowID) then
    removeWindow(pBadgeWindowID)
  end if
  if objectp(pBadgeListRenderer) then
    removeObject(pBadgeListRenderer.getID())
  end if
  repeat with i = 1 to pActiveDownloads.count
    abortDownLoad(pActiveDownloads[i])
  end repeat
  unregisterMessage(#openBadgeWindow, me.getID())
  unregisterMessage(#openAchievementsWindow, me.getID())
  unregisterMessage(#achievementsUpdated, me.getID())
  unregisterMessage(#badgeReceived, me.getID())
  unregisterMessage(#badgeRemoved, me.getID())
  pSelectedBadges = []
  pNewBadges = []
  pNewBadgeDownloads = []
  return 1
end

on openBadgeWindow me
  me.closeBadgeWindow()
  tOwnUser = getObject(#session).GET("user_index")
  tSelectedObj = getThread(#room).getComponent().getUserObject(tOwnUser)
  if not tSelectedObj then
    return 0
  end if
  tBadges = tSelectedObj.getProperty(#badges)
  if tBadges.ilk <> #propList then
    tBadges = [:]
  end if
  pSelectedBadges = [0, 0, 0, 0, 0]
  repeat with i = 1 to tBadges.count
    pSelectedBadges[tBadges.getPropAt(i)] = tBadges[i]
  end repeat
  tAllBadges = getObject("session").GET("available_badges", [])
  me.loadBadgeImages(tAllBadges)
  if not createWindow(pBadgeWindowID) then
    return error(me, "Badge choice window not created!", #openBadgeWindow, #major)
  end if
  tWndObj = getWindow(pBadgeWindowID)
  tWndObj.setProperty(#title, getText("badges_window_title"))
  tMerged = tWndObj.merge("habbo_basic.window")
  if tMerged then
    tMerged = tWndObj.merge("badge_select.window")
  end if
  if not tMerged then
    removeWindow(pBadgeWindowID)
    return error(me, "Badge selection window not merged!", #openBadgeWindow, #major)
  end if
  registerMessage(#leaveRoom, tWndObj.getID(), #close)
  registerMessage(#changeRoom, tWndObj.getID(), #close)
  tWndObj.registerProcedure(#eventProcBadgeChooser, me.getID(), #mouseUp)
  if (pActiveBadgeID = 0) and (tAllBadges.count > 0) then
    me.selectBadge(tAllBadges[1])
  else
    me.selectBadge(pActiveBadgeID)
  end if
  me.updateBadgeView()
end

on closeBadgeWindow me
  if windowExists(pBadgeWindowID) then
    tWndObj = getWindow(pBadgeWindowID)
    unregisterMessage(#leaveRoom, tWndObj.getID())
    unregisterMessage(#changeRoom, tWndObj.getID())
    tWndObj.close()
  end if
end

on openAchievementsWindow me
  if windowExists(pBadgeWindowID) then
    removeWindow(pBadgeWindowID)
  end if
  if not createWindow(pBadgeWindowID) then
    return error(me, "Achievements window not created!", #openBadgeWindow, #major)
  end if
  tWndObj = getWindow(pBadgeWindowID)
  tWndObj.setProperty(#title, getText("badges_window_title"))
  tMerged = tWndObj.merge("habbo_basic.window")
  if tMerged then
    tMerged = tWndObj.merge("achievements.window")
  end if
  if not tMerged then
    removeWindow(pBadgeWindowID)
    return error(me, "Badge selection window not merged!", #openBadgeWindow, #major)
  end if
  registerMessage(#leaveRoom, tWndObj.getID(), #close)
  registerMessage(#changeRoom, tWndObj.getID(), #close)
  tWndObj.registerProcedure(#eventProcBadgeChooser, me.getID(), #mouseUp)
  me.updateAchievements()
end

on updateAchievements me
  if not windowExists(pBadgeWindowID) then
    return 0
  end if
  tWindow = getWindow(pBadgeWindowID)
  if tWindow.elementExists("achievement_list") and threadExists(#room) then
    tAchievements = getObject(#session).GET("possible_achievements")
    if listp(tAchievements) then
      tBadgeIDs = []
      repeat with tPropNum = 1 to tAchievements.count
        tBadgeIDs.add(tAchievements.getPropAt(tPropNum))
      end repeat
      me.loadBadgeImages(tBadgeIDs)
      tElem = tWindow.getElement("achievement_list")
      tAchievementsImage = pBadgeListRenderer.renderAchievements(tBadgeIDs)
      tElem.feedImage(tAchievementsImage)
    end if
  end if
end

on updateBadgeImage me
  if not windowExists(pBadgeWindowID) then
    return 0
  end if
  tWndObj = getWindow(pBadgeWindowID)
  tBadgeList = getObject("session").GET("available_badges", [])
  if (pChosenBadge > tBadgeList.count) or (pChosenBadge < 1) then
    return 0
  end if
  tBadgeName = tBadgeList[pChosenBadge]
  tMemNum = getmemnum("badge" && tBadgeName)
  if (tMemNum < 1) or (pUpdatedBadges[tBadgeName] = 0) then
    tWndObj.getElement("badge_preview").clearImage()
    me.startBadgeDownload(tBadgeName)
    return 0
  end if
  tWidth = tWndObj.getElement("badge_preview").getProperty(#width)
  tHeight = tWndObj.getElement("badge_preview").getProperty(#height)
  tBadgeImage = member(tMemNum).image
  tCenteredImage = image(tWidth, tHeight, 32)
  tXchange = (tCenteredImage.width - tBadgeImage.width) / 2
  tYchange = (tCenteredImage.height - tBadgeImage.height) / 2
  tRect1 = tBadgeImage.rect + rect(tXchange, tYchange, tXchange, tYchange)
  tCenteredImage.copyPixels(tBadgeImage, tRect1, tBadgeImage.rect)
  tWndObj.getElement("badge_preview").feedImage(tCenteredImage)
  return 1
end

on sendSetBadges me
  tMsg = [:]
  repeat with i = 1 to 5
    tMsg.addProp(#integer, i)
    if pSelectedBadges[i].ilk = #string then
      tMsg.addProp(#string, pSelectedBadges[i])
      next repeat
    end if
    tMsg.addProp(#string, EMPTY)
  end repeat
  getThread(#room).getComponent().getRoomConnection().send("SETBADGE", tMsg)
end

on eventProcBadgeChooser me, tEvent, tSprID, tParam
  if tSprID contains "badge_slot" then
    tSlotNum = tSprID.char[tSprID.length]
    me.selectSlot(tSlotNum)
    return 1
  end if
  case tSprID of
    "badge_list":
      if tParam.ilk <> #point then
        return 0
      end if
      tBadgeID = pBadgeListRenderer.getBadgeAt(tParam)
      if not tBadgeID then
        return 0
      end if
      me.selectBadge(tBadgeID)
    "selected_badge_button":
      if pSelectedBadges.findPos(pActiveBadgeID) > 0 then
        me.clearActiveSlot()
      else
        tFreeSlot = pSelectedBadges.getPos(0)
        if tFreeSlot > 0 then
          me.selectSlot(tFreeSlot)
        end if
      end if
    "badges_tab":
      me.openBadgeWindow()
    "achievements_tab":
      me.openAchievementsWindow()
    "fx_tab":
      return executeMessage(#openFxWindow)
    "button_ok":
      me.sendSetBadges()
      me.closeBadgeWindow()
    "button_cancel":
      me.closeBadgeWindow()
  end case
end

on startBadgeDownload me, tBadgeName
  if (tBadgeName = EMPTY) or (tBadgeName = " ") or voidp(tBadgeName) then
    return 0
  end if
  if downloadExists("badge" && tBadgeName) then
    return 0
  end if
  if downloadExists("badge localized" && tBadgeName) then
    return 0
  end if
  tSourceURL = pImageLibraryURL & "Badges/" & tBadgeName & ".gif"
  if getmemnum("badge" && tBadgeName) <> 0 then
    tBadgeMemNum = queueDownload(tSourceURL, "badge localized" && tBadgeName, #bitmap, 1)
  else
    tBadgeMemNum = queueDownload(tSourceURL, "badge" && tBadgeName, #bitmap, 1)
  end if
  if tBadgeMemNum = 0 then
    return 0
  end if
  member(tBadgeMemNum).image = image(1, 1, 32)
  member(tBadgeMemNum).trimWhiteSpace = 0
  registerDownloadCallback(tBadgeMemNum, #badgeLoaded, me.getID(), tBadgeName)
  pActiveDownloads.add("badge" && tBadgeName)
  return 1
end

on badgeLoaded me, tBadgeName
  pUpdatedBadges[tBadgeName] = 1
  tLoadedBadgeNum = getmemnum("badge localized" && tBadgeName)
  if tLoadedBadgeNum <> 0 then
    if member(tLoadedBadgeNum).image.rect <> rect(0, 0, 1, 1) then
      tBadgeNum = getmemnum("badge" && tBadgeName)
      if tBadgeNum <> 0 then
        member(tBadgeNum).image = member(tLoadedBadgeNum).image
      end if
    end if
  end if
  if pNewBadgeDownloads.findPos(tBadgeName) > 0 then
    tmember = me.getBadgeMember(tBadgeName)
    if tmember = 0 then
      return 0
    end if
    if tmember.image.rect <> rect(0, 0, 1, 1) then
      pNewBadgeDownloads.deleteOne(tBadgeName)
      executeMessage(#badgeReceivedAndReady, tBadgeName)
    end if
  end if
  executeMessage(#updateInfoStandBadge, tBadgeName)
  pActiveDownloads.deleteOne("badge" && tBadgeName)
  if pActiveBadgeID = tBadgeName then
    me.selectBadge(tBadgeName)
  end if
  me.updateBadgeView()
  me.updateAchievements()
end

on addNewBadge me, tBadgeID
  if pNewBadgeDownloads.findPos(tBadgeID) = 0 then
    pNewBadgeDownloads.add(tBadgeID)
  end if
  if me.getBadgeMember(tBadgeID) = 0 then
    me.loadBadgeImages([tBadgeID])
  else
    me.badgeLoaded(tBadgeID)
  end if
  if pNewBadges.getPos(tBadgeID) > 0 then
    return 0
  end if
  pNewBadges.add(tBadgeID)
  me.updateBadgeView()
end

on handleBadgeRemove me, tBadgeID
  tPos = pSelectedBadges.getPos(tBadgeID)
  if tPos > 0 then
    pSelectedBadges[tPos] = 0
  end if
  if pActiveBadgeID = tBadgeID then
    pActiveBadgeID = 0
  end if
  me.updateBadgeView()
end

on updateBadgeView me
  me.updateBadgeListImage()
  me.updatePreview()
  me.updateSlots()
end

on updateBadgeListImage me
  if not windowExists(pBadgeWindowID) then
    return 0
  end if
  tWindow = getWindow(pBadgeWindowID)
  if not tWindow.elementExists("badge_list") then
    return 0
  end if
  tBadges = getObject(#session).GET("available_badges", [])
  tListElem = tWindow.getElement("badge_list")
  tListElem.feedImage(pBadgeListRenderer.render(tBadges, pSelectedBadges, pNewBadges, pActiveBadgeID))
end

on updateInfoStandBadge me, tInfoStandID, tSelectedObjID, tBadges
  tWndObj = getWindow(tInfoStandID)
  if not tWndObj then
    return 0
  end if
  tUserObj = getThread(#room).getComponent().getUserObject(tSelectedObjID)
  if not objectp(tUserObj) then
    return 0
  end if
  if tBadges.ilk <> #propList then
    return 0
  end if
  tOwnCharacter = tSelectedObjID = getObject("session").GET("user_index")
  if tUserObj.pBadges <> tBadges then
    return 0
  end if
  repeat with tBadgeIndex = 1 to 5
    if not tWndObj.elementExists("info_badge_" & tBadgeIndex) then
      next repeat
    end if
    tElem = tWndObj.getElement("info_badge_" & tBadgeIndex)
    tElem.clearImage()
    tBadgeID = tBadges.getaProp(tBadgeIndex)
    if voidp(tBadgeID) then
      next repeat
    end if
    if tOwnCharacter then
      tElem.setProperty(#cursor, "cursor.finger")
    end if
    if memberExists("badge" && tBadgeID && "localized") then
      tBadgeMember = member(getmemnum("badge" && tBadgeID && "localized"))
      if tBadgeMember.type = #bitmap then
        tElem.feedImage(tBadgeMember.image)
      end if
      next repeat
    end if
    if memberExists("badge" && tBadgeID) then
      tBadgeMember = member(getmemnum("badge" && tBadgeID))
      if tBadgeMember.type = #bitmap then
        tElem.feedImage(tBadgeMember.image)
      end if
      next repeat
    end if
    me.startBadgeDownload(tBadgeID)
    return 0
  end repeat
end

on createBadgeEffect me, tElem
  if objectExists("BadgeEffect") then
    return 0
  end if
  if createObject("BadgeEffect", "Badge Effect Class") <> 0 then
    return getObject("BadgeEffect").Init(tElem)
  end if
end

on removeBadgeEffect me
  if objectExists("BadgeEffect") then
    return removeObject("BadgeEffect")
  end if
end

on selectBadge me, tBadgeID
  tPos = pNewBadges.getPos(tBadgeID)
  if tPos > 0 then
    pNewBadges.deleteAt(tPos)
  end if
  pActiveBadgeID = tBadgeID
  me.updateBadgeView()
end

on updatePreview me
  if not windowExists(pBadgeWindowID) then
    return 0
  end if
  tWindow = getWindow(pBadgeWindowID)
  if tWindow.elementExists("selected_badge") then
    tBadgeElem = tWindow.getElement("selected_badge")
    if (pActiveBadgeID <> 0) and memberExists("badge" && pActiveBadgeID) then
      tBadgeImage = member(getmemnum("badge" && pActiveBadgeID)).image
    else
      tBadgeImage = image(1, 1, 8)
    end if
    tDouble = image(tBadgeImage.width * 2, tBadgeImage.height * 2, tBadgeImage.depth)
    tDouble.copyPixels(tBadgeImage, tBadgeImage.rect * 2, tBadgeImage.rect)
    tDouble = pBadgeListRenderer.centerImage(tDouble, rect(0, 0, 94, 94))
    tBadgeElem.feedImage(tDouble)
  end if
  if tWindow.elementExists("selected_badge_name") then
    tNameElem = tWindow.getElement("selected_badge_name")
    if pActiveBadgeID <> 0 then
      tNameElem.setText(getText("badge_name_" & pActiveBadgeID))
    else
      tNameElem.hide()
    end if
  end if
  if tWindow.elementExists("selected_badge_name") then
    tDescElem = tWindow.getElement("selected_badge_desc")
    if pActiveBadgeID <> 0 then
      tDescElem.setText(getText("badge_desc_" & pActiveBadgeID))
    else
      tDescElem.hide()
    end if
  end if
  if tWindow.elementExists("selected_badge_button") and tWindow.elementExists("slots_full_text") then
    tButton = tWindow.getElement("selected_badge_button")
    tTextElem = tWindow.getElement("slots_full_text")
    if pSelectedBadges.getPos(pActiveBadgeID) = 0 then
      tButtonText = getText("badge_wear")
      pActiveSlot = 0
      if pSelectedBadges.getPos(0) = 0 then
        tButton.hide()
        tTextElem.show()
      else
        tButton.show()
        tTextElem.hide()
      end if
    else
      tButtonText = getText("badge_remove")
      pActiveSlot = pSelectedBadges.getPos(pActiveBadgeID)
      tButton.show()
      tTextElem.hide()
    end if
    tButton.setText(tButtonText)
  end if
end

on selectSlot me, tSlotIndex
  tSlotIndex = integer(tSlotIndex)
  if (tSlotIndex < 1) or (tSlotIndex > pSelectedBadges.count) then
    return error(me, "Slot index out of range", #selectSlot, #major)
  end if
  tBadgeID = pSelectedBadges[tSlotIndex]
  if tBadgeID <> 0 then
    me.selectBadge(tBadgeID)
  else
    if (pActiveBadgeID <> 0) and (pSelectedBadges.getPos(pActiveBadgeID) = 0) then
      pSelectedBadges[tSlotIndex] = pActiveBadgeID
      me.updateBadgeView()
    end if
  end if
end

on clearActiveSlot me
  if pActiveSlot = 0 then
    return 0
  end if
  pSelectedBadges[pActiveSlot] = 0
  me.updateBadgeView()
end

on updateSlots me
  if not windowExists(pBadgeWindowID) then
    return 0
  end if
  tWindow = getWindow(pBadgeWindowID)
  repeat with tSlot = 1 to 5
    if not tWindow.elementExists("badge_slot_" & tSlot) then
      next repeat
    end if
    tBadgeID = pSelectedBadges[tSlot]
    tElem = tWindow.getElement("badge_slot_" & tSlot)
    tMemNum = getmemnum("badge" && tBadgeID)
    if (tBadgeID = 0) or (tMemNum = 0) then
      tBadgeImage = image(1, 1, 8)
    else
      tBadgeImage = member(tMemNum).image
    end if
    tWidth = tElem.getProperty(#width)
    tHeight = tElem.getProperty(#height)
    tCenteredImage = pBadgeListRenderer.centerImage(tBadgeImage, rect(0, 0, tWidth, tHeight))
    tElem.feedImage(tCenteredImage)
    if tWindow.elementExists("slot_bg_" & tSlot) then
      tSlotElem = tWindow.getElement("slot_bg_" & tSlot)
      if tBadgeID = pActiveBadgeID then
        tSlotElem.setProperty(#member, "slot_hilite")
        next repeat
      end if
      tSlotElem.setProperty(#member, "slot")
    end if
  end repeat
end

on loadBadgeImages me, tBadgeList
  repeat with tBadgeID in tBadgeList
    if not memberExists("badge" && tBadgeID) then
      me.startBadgeDownload(tBadgeID)
    end if
  end repeat
end

on getBadgeMember me, tBadgeID
  tMemNum = getmemnum("badge" && tBadgeID && "localized")
  if tMemNum <> 0 then
    return member(tMemNum)
  end if
  tMemNum = getmemnum("badge" && tBadgeID)
  if tMemNum <> 0 then
    return member(tMemNum)
  end if
  return 0
end
