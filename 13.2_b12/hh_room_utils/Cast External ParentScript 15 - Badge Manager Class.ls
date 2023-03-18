property pChosenBadge, pChosenVisibility, pImageLibraryURL, pActiveDownloads, pUpdatedBadges

on construct me
  pChosenBadge = 1
  pChosenVisibility = 1
  pImageLibraryURL = getVariable("image.library.url")
  pActiveDownloads = []
  pUpdatedBadges = [:]
  return 1
end

on deconstruct me
  if windowExists("badge_choice_window") then
    removeWindow("badge_choice_window")
  end if
  repeat with i = 1 to pActiveDownloads.count
    abortDownLoad(pActiveDownloads[i])
  end repeat
  return 1
end

on openBadgeWindow me
  tBadgeList = getObject("session").GET("available_badges", [])
  if tBadgeList.count < 1 then
    return 0
  end if
  if not createWindow("badge_choice_window", VOID, 360, 195) then
    return 0
  end if
  tWndObj = getWindow("badge_choice_window")
  tWndObj.setProperty(#title, getText("room_badge_window_title"))
  if not tWndObj.merge("habbo_basic.window") then
    return tWndObj.close()
  end if
  tMerged = tWndObj.merge("habbo_badge_select.window")
  if not tMerged then
    removeWindow("badge_choice_window")
    return error(me, "Badge selection window not found!", #openBadgeWindow)
  end if
  registerMessage(#leaveRoom, tWndObj.getID(), #close)
  registerMessage(#changeRoom, tWndObj.getID(), #close)
  tWndObj.registerProcedure(#eventProcBadgeChooser, me.getID(), #mouseUp)
  pChosenVisibility = getObject("session").GET("badge_visible")
  pChosenBadge = getObject("session").GET("chosen_badge_index")
  if pChosenBadge < 1 then
    pChosenBadge = 1
  end if
  me.updateBadgeVisibleButtons()
  me.updateBadgeImage()
  if tBadgeList.count = 1 then
    me.hideBadgeBrowseButtons(tWndObj)
  end if
end

on closeBadgeWindow me
  tWndObj = getWindow("badge_choice_window")
  if tWndObj = 0 then
    return 0
  end if
  unregisterMessage(#leaveRoom, tWndObj.getID())
  unregisterMessage(#changeRoom, tWndObj.getID())
  tWndObj.close()
end

on updateBadgeVisibleButtons me
  tWndObj = getWindow("badge_choice_window")
  if tWndObj = 0 then
    return 0
  end if
  if (getmemnum("button.radio.on") < 1) or (getmemnum("button.radio.off") < 1) then
    return 0
  end if
  tRadioButtonOnImg = member(getmemnum("button.radio.on")).image
  tRadioButtonOffImg = member(getmemnum("button.radio.off")).image
  if pChosenVisibility = 1 then
    if tWndObj.elementExists("badge.visible.radio") then
      tWndObj.getElement("badge.visible.radio").feedImage(tRadioButtonOnImg)
    end if
    if tWndObj.elementExists("badge.hidden.radio") then
      tWndObj.getElement("badge.hidden.radio").feedImage(tRadioButtonOffImg)
    end if
  else
    if tWndObj.elementExists("badge.hidden.radio") then
      tWndObj.getElement("badge.hidden.radio").feedImage(tRadioButtonOnImg)
    end if
    if tWndObj.elementExists("badge.visible.radio") then
      tWndObj.getElement("badge.visible.radio").feedImage(tRadioButtonOffImg)
    end if
  end if
end

on hideBadgeBrowseButtons me, tWndObj
  if tWndObj.elementExists("badge.next.button") then
    tWndObj.getElement("badge.next.button").hide()
  end if
  if tWndObj.elementExists("badge.prev.button") then
    tWndObj.getElement("badge.prev.button").hide()
  end if
end

on updateBadgeImage me
  if not windowExists("badge_choice_window") then
    return 0
  end if
  tWndObj = getWindow("badge_choice_window")
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

on badgeNextPrev me, tdir
  tBadgeList = getObject("session").GET("available_badges", [])
  if tBadgeList.count = 0 then
    me.closeBadgeWindow()
    return 0
  end if
  if tdir = "next" then
    pChosenBadge = pChosenBadge + 1
    if pChosenBadge > tBadgeList.count then
      pChosenBadge = 1
    end if
  else
    pChosenBadge = pChosenBadge - 1
    if pChosenBadge < 1 then
      pChosenBadge = tBadgeList.count
    end if
  end if
  me.updateBadgeImage()
end

on eventProcBadgeChooser me, tEvent, tSprID, tParam
  case tSprID of
    "badge.hidden.radio":
      pChosenVisibility = 0
      me.updateBadgeVisibleButtons()
    "badge.visible.radio":
      pChosenVisibility = 1
      me.updateBadgeVisibleButtons()
    "badge.ok":
      tBadgeList = getObject("session").GET("available_badges")
      if pChosenBadge > tBadgeList.count then
        me.closeBadgeWindow()
        return 0
      end if
      tVisible = integer(pChosenVisibility)
      tMsg = [#string: tBadgeList[pChosenBadge], #integer: tVisible]
      getThread(#room).getComponent().getRoomConnection().send("SETBADGE", tMsg)
      getObject("session").set("chosen_badge_index", pChosenBadge)
      getObject("session").set("badge_visible", pChosenVisibility)
      getThread(#room).getInterface().getInfoStandObject().updateInfoStandBadge()
      me.closeBadgeWindow()
    "badge.cancel":
      me.closeBadgeWindow()
    "badge.next.button":
      me.badgeNextPrev("next")
    "badge.prev.button":
      me.badgeNextPrev("prev")
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
  me.updateBadgeImage()
  getThread(#room).getInterface().getInfoStandObject().updateInfoStandBadge(tBadgeName)
  pActiveDownloads.deleteOne("badge" && tBadgeName)
end

on getMyBadgeInfo me
  tBadge = " "
  tSession = getObject("session")
  tChosenBadgeNum = tSession.GET("chosen_badge_index")
  tAvailableBadges = tSession.GET("available_badges")
  if tSession.exists("badge_visible") then
    tVisibility = tSession.GET("badge_visible")
  else
    tVisibility = 1
  end if
  if tAvailableBadges.ilk = #list then
    if (tChosenBadgeNum > 0) and (tAvailableBadges.count >= tChosenBadgeNum) then
      tBadge = tAvailableBadges[tChosenBadgeNum]
    end if
  end if
  return [tBadge, tVisibility]
end

on toggleOwnBadgeVisibility me
  tMyBadgeInfo = me.getMyBadgeInfo()
  tVisibilityNow = tMyBadgeInfo[2]
  if tMyBadgeInfo[1] = " " then
    return 0
  end if
  if tVisibilityNow then
    tUpdatedVisibility = 0
  else
    tUpdatedVisibility = 1
  end if
  tMsg = [#string: tMyBadgeInfo[1], #integer: tUpdatedVisibility]
  getObject("session").set("badge_visible", tUpdatedVisibility)
  getThread(#room).getInterface().getInfoStandObject().updateInfoStandBadge()
  getThread(#room).getComponent().getRoomConnection().send("SETBADGE", tMsg)
  return 1
end

on updateInfoStandBadge me, tInfoStandID, tSelectedObj, tBadgeID, tUserID
  tWndObj = getWindow(tInfoStandID)
  if not tWndObj then
    return 0
  end if
  tElem = tWndObj.getElement("info_badge")
  tElem.clearImage()
  me.removeBadgeEffect()
  tOwnCharacter = tSelectedObj = getObject("session").GET("user_index")
  if tOwnCharacter = 0 then
    if tUserID <> VOID then
      if tUserID <> tSelectedObj then
        return 0
      end if
    end if
    tUserObj = getThread(#room).getComponent().getUserObject(tSelectedObj)
    if not objectp(tUserObj) then
      return 0
    end if
    if tUserObj.getClass() <> "user" then
      return 0
    end if
    if tUserObj.pBadge <> tBadgeID then
      return 0
    end if
  end if
  if (tBadgeID = " ") or (tBadgeID = EMPTY) or voidp(tBadgeID) then
    if not tOwnCharacter then
      return 1
    end if
  end if
  if tOwnCharacter then
    tMyBadgeInfo = me.getMyBadgeInfo()
    tBadgeID = tMyBadgeInfo[1]
    tBadgeVisible = tMyBadgeInfo[2]
    if tBadgeID <> " " then
      tElem.setProperty(#cursor, "cursor.finger")
    end if
    if tBadgeVisible then
      tElem.setProperty(#blend, 100)
    else
      tElem.setProperty(#blend, 40)
    end if
  else
    tElem.setProperty(#blend, 100)
    tElem.setProperty(#cursor, 0)
  end if
  if memberExists("badge" && tBadgeID && "localized") then
    tBadgeMember = member(getmemnum("badge" && tBadgeID && "localized"))
    tElem.feedImage(tBadgeMember.image)
  else
    if memberExists("badge" && tBadgeID) then
      tBadgeMember = member(getmemnum("badge" && tBadgeID))
      tElem.feedImage(tBadgeMember.image)
    else
      me.startBadgeDownload(tBadgeID)
      return 0
    end if
  end if
  if tBadgeID = "HC2" then
    me.createBadgeEffect(tElem)
  else
    me.removeBadgeEffect()
  end if
end

on createBadgeEffect me, tElem
  if objectExists("BadgeEffect") then
    return 0
  end if
  if createObject("BadgeEffect", "Badge Effect Class") <> 0 then
    return getObject("BadgeEffect").Init(tElem.getProperty(#rect))
  end if
end

on removeBadgeEffect me
  if objectExists("BadgeEffect") then
    return removeObject("BadgeEffect")
  end if
end
