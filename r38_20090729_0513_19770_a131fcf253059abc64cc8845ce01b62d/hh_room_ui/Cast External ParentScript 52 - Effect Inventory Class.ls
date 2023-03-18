property pInventoryList, pInventoryEffects, pActiveEffects, pActiveEffectIndex, pSelectedEffectType, pActiveSlot, pSlotOffset, pBadgeWindowID, pListRenderer, pUpdateTimerId, pState

on construct me
  pState = 0
  me.regMsgList(1)
  pInventoryList = [:]
  pInventoryEffects = []
  pActiveEffects = [:]
  pActiveEffectIndex = []
  pBadgeWindowID = "badgeSelectionWindowID"
  pUpdateTimerId = "fx_inventory_timer"
  pSlotOffset = 0
  getObject(#session).set("active_fx", [])
  pListRenderer = createObject(getUniqueID(), "FX List Class")
  registerMessage(#use_avatar_effect, me.getID(), #send_use_avatar_effect)
  registerMessage(#activate_avatar_effect, me.getID(), #send_activate_avatar_effect)
  registerMessage(#openFxWindow, me.getID(), #openFxWindow)
  return 1
end

on deconstruct me
  pState = 0
  me.setUpdateTimer(0)
  me.regMsgList(0)
  if windowExists(pBadgeWindowID) then
    removeWindow(pBadgeWindowID)
  end if
  unregisterMessage(#openFxWindow, me.getID())
  if objectp(pListRenderer) then
    removeObject(pListRenderer.getID())
  end if
  return 1
end

on openFxWindow me
  if not pState then
    return 1
  end if
  if pInventoryEffects.findPos(pSelectedEffectType) = 0 then
    pSelectedEffectType = VOID
  end if
  if voidp(pSelectedEffectType) then
    if pInventoryList.count > 1 then
      pSelectedEffectType = pInventoryList.getPropAt(1)
    end if
  end if
  me.getWindowObj()
  me.updateFxView()
  me.setUpdateTimer(1)
end

on setCatalogLinkVisibility me
  tWndObj = getWindow(pBadgeWindowID)
  if tWndObj = 0 then
    return 0
  end if
  if pInventoryEffects.count > 0 then
    tWndObj.getElement("selected_fx").show()
    tWndObj.getElement("selected_fx_bg").show()
    tWndObj.getElement("fx_catalog_link_text").hide()
  else
    tWndObj.getElement("selected_fx").hide()
    tWndObj.getElement("selected_fx_bg").hide()
    tWndObj.getElement("fx_catalog_link_text").show()
  end if
end

on updateListImage me
  tWndObj = getWindow(pBadgeWindowID)
  if tWndObj = 0 then
    return 0
  end if
  if not tWndObj.elementExists("fx_list") then
    return 0
  end if
  tListElem = tWndObj.getElement("fx_list")
  tListElem.feedImage(pListRenderer.render(pInventoryEffects, pActiveEffectIndex, VOID, pSelectedEffectType))
  return 1
end

on updatePreview me
  if not windowExists(pBadgeWindowID) then
    return 0
  end if
  tWindow = getWindow(pBadgeWindowID)
  tItemData = pInventoryList.getaProp(pSelectedEffectType)
  if tItemData = VOID then
    return 0
  end if
  if tWindow.elementExists("selected_fx") then
    tElem = tWindow.getElement("selected_fx")
    if (pSelectedEffectType <> 0) and memberExists("ctlg_fx_prev_" & pSelectedEffectType) then
      tBadgeImage = member(getmemnum("ctlg_fx_prev_" & pSelectedEffectType)).image
    else
      tBadgeImage = image(1, 1, 8)
    end if
    tConvertImage = image(tBadgeImage.width, tBadgeImage.height, 32)
    tConvertImage.copyPixels(tBadgeImage, tBadgeImage.rect, tBadgeImage.rect)
    tBadgeImage = tConvertImage
    tBadgeImage = pListRenderer.centerImage(tBadgeImage, rect(0, 0, tElem.getProperty(#width), tElem.getProperty(#height)))
    tElem.feedImage(tBadgeImage)
  end if
  if tWindow.elementExists("fx_title") then
    tNameElem = tWindow.getElement("fx_title")
    if pSelectedEffectType <> 0 then
      tNameElem.setText(getText("fx_" & pSelectedEffectType))
    else
      tNameElem.hide()
    end if
  end if
  if tWindow.elementExists("fx_desc") then
    tDescElem = tWindow.getElement("fx_desc")
    if pSelectedEffectType <> 0 then
      tText = getText("fx_" & pSelectedEffectType & "_desc") & getText("fx_desc_duration")
      tText = replaceChunks(tText, "%r", RETURN)
      tText = replaceChunks(tText, "%h", me.getHours(tItemData.getaProp(#time_duration)))
      tText = replaceChunks(tText, "%m", me.getMinutes(tItemData.getaProp(#time_duration)) mod 60)
      tText = replaceChunks(tText, "%d", me.getHours(tItemData.getaProp(#time_duration)) & ":" & me.getMinutes(tItemData.getaProp(#time_duration)) mod 60)
      tText = replaceChunks(tText, "%c", tItemData.getaProp(#count))
      tDescElem.setText(tText)
    else
      tDescElem.hide()
    end if
  end if
  if tWindow.elementExists("fx_activate_button") then
    tElem = tWindow.getElement("fx_activate_button")
    if me.pActiveEffectIndex.findPos(pSelectedEffectType) > 0 then
      tElem.hide()
    else
      tElem.show()
    end if
  end if
  return 1
end

on getHours me, tSeconds
  return tSeconds / 3600
end

on getMinutes me, tSeconds
  return tSeconds / 60
end

on selectSlot me, tSlotIndex
  tSlotIndex = integer(tSlotIndex)
  if (tSlotIndex < 1) or (tSlotIndex > pActiveEffects.count) then
    return error(me, "Slot index out of range", #selectSlot, #major)
  end if
  tBadgeID = pActiveEffectIndex[tSlotIndex]
  if tBadgeID <> 0 then
    me.selectBadge(tBadgeID)
  end if
end

on clearActiveSlot me
  if pActiveSlot = 0 then
    return 0
  end if
  pSelectedBadges([pActiveSlot] = 0)
  me.updateBadgeView()
end

on updateSlots me
  if not pState then
    return 1
  end if
  if not windowExists(pBadgeWindowID) then
    me.setUpdateTimer(0)
    return 0
  end if
  tWindow = getWindow(pBadgeWindowID)
  if not tWindow.elementExists("fx_slot_1") then
    me.setUpdateTimer(0)
    return 0
  end if
  tElem = tWindow.getElement("slot_arrow_left")
  if tElem = 0 then
    return 0
  end if
  if pSlotOffset < 1 then
    tElem.setProperty(#member, "fxarrow.inactive.left")
    tElem.setProperty(#cursor, 0)
  else
    tElem.setProperty(#member, "fxarrow.active.left")
    tElem.setProperty(#cursor, "cursor.finger")
  end if
  tElem = tWindow.getElement("slot_arrow_right")
  if tElem = 0 then
    return 0
  end if
  if (pSlotOffset + 5) >= pActiveEffects.count then
    tElem.setProperty(#member, "fxarrow.inactive.right")
    tElem.setProperty(#cursor, 0)
  else
    tElem.setProperty(#member, "fxarrow.active.right")
    tElem.setProperty(#cursor, "cursor.finger")
  end if
  repeat with tSlot = 1 to 5
    if not tWindow.elementExists("fx_slot_" & tSlot) then
      next repeat
    end if
    tElem = tWindow.getElement("fx_slot_" & tSlot)
    if pActiveEffects.count < (tSlot + pSlotOffset) then
      tElem.hide()
      tSlotElem = tWindow.getElement("slot_bg_" & tSlot)
      tSlotElem.setProperty(#member, "slot")
      tTimeElem = tWindow.getElement("fx_slot_" & tSlot & "_time")
      if tTimeElem <> 0 then
        tTimeElem.setText(EMPTY)
      end if
      next repeat
    end if
    tElem.show()
    tBadgeID = pActiveEffects.getPropAt(tSlot + pSlotOffset)
    tEndTime = pActiveEffects[tSlot + pSlotOffset]
    tMemNum = getmemnum("ctlg_pic_small_fx_" & tBadgeID)
    if (tBadgeID = 0) or (tMemNum = 0) then
      tBadgeImage = image(1, 1, 8)
    else
      tBadgeImage = member(tMemNum).image
    end if
    tWidth = tElem.getProperty(#width)
    tHeight = tElem.getProperty(#height)
    tCenteredImage = pListRenderer.centerImage(tBadgeImage, rect(0, 0, tWidth, tHeight))
    tElem.feedImage(tCenteredImage)
    if tWindow.elementExists("slot_bg_" & tSlot) then
      tSlotElem = tWindow.getElement("slot_bg_" & tSlot)
      if tBadgeID = pSelectedEffectType then
        tSlotElem.setProperty(#member, "slot_hilite")
      else
        tSlotElem.setProperty(#member, "slot")
      end if
    end if
    tTimeInt = (tEndTime - the milliSeconds) / 1000
    tMin = tTimeInt mod 60
    tHour = (tTimeInt - tMin) / 60
    if tMin < 10 then
      tMin = "0" & tMin
    end if
    if tHour < 10 then
      tHour = "0" & tHour
    end if
    tElem = tWindow.getElement("fx_slot_" & tSlot & "_time")
    if tElem = 0 then
      return 0
    end if
    tElem.setText(tHour & ":" & tMin)
  end repeat
end

on selectItem me, tBadgeID
  pSelectedEffectType = tBadgeID
  me.updateFxView()
end

on updateFxView me
  if not pState then
    return 1
  end if
  if voidp(pSelectedEffectType) then
    if pInventoryList.count > 1 then
      pSelectedEffectType = pInventoryList.getPropAt(1)
    end if
  end if
  me.setCatalogLinkVisibility()
  me.updateListImage()
  me.updatePreview()
  me.updateSlots()
end

on getWindowObj me
  tTitleStr = getText("fx_inv_window_title")
  if windowExists(pBadgeWindowID) then
    tWndObj = getWindow(pBadgeWindowID)
    if tWndObj.getProperty(#title) = tTitleStr then
      return getWindow(pBadgeWindowID)
    end if
    removeWindow(pBadgeWindowID)
  end if
  if not createWindow(pBadgeWindowID) then
    return error(me, "Badge choice window not created!", #getWindowObj, #major)
  end if
  tWndObj = getWindow(pBadgeWindowID)
  tWndObj.setProperty(#title, tTitleStr)
  tMerged = tWndObj.merge("habbo_basic.window")
  if tMerged then
    tMerged = tWndObj.merge("FX.window")
  end if
  if not tMerged then
    removeWindow(pBadgeWindowID)
    return error(me, "FX Inventory selection window not merged!", #getWindowObj, #major)
  end if
  me.setCatalogLinkVisibility()
  registerMessage(#leaveRoom, tWndObj.getID(), #close)
  registerMessage(#changeRoom, tWndObj.getID(), #close)
  tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
  return tWndObj
end

on removeWindowObj me
  if windowExists(pBadgeWindowID) then
    tWndObj = getWindow(pBadgeWindowID)
    unregisterMessage(#leaveRoom, tWndObj.getID())
    unregisterMessage(#changeRoom, tWndObj.getID())
    tWndObj.close()
  end if
end

on setUpdateTimer me, tstate
  if not pState then
    return 1
  end if
  if tstate then
    if timeoutExists(pUpdateTimerId) then
      return 1
    end if
    createTimeout(pUpdateTimerId, 10000, #updateSlots, me.getID())
  else
    if timeoutExists(pUpdateTimerId) then
      removeTimeout(pUpdateTimerId)
    end if
  end if
  return 1
end

on send_use_avatar_effect me, ttype
  if not pState then
    return 1
  end if
  tConn = getConnection(#Info)
  if tConn = 0 then
    return 0
  end if
  return tConn.send("USE_AVATAR_EFFECT", [#integer: ttype])
end

on send_activate_avatar_effect me, ttype
  tConn = getConnection(#Info)
  if tConn = 0 then
    return 0
  end if
  return tConn.send("ACTIVATE_AVATAR_EFFECT", [#integer: ttype])
end

on handle_avatar_effects me, tMsg
  tConn = tMsg.getaProp(#connection)
  tList = [:]
  tIndex = []
  tActiveIndex = []
  tActiveList = [:]
  tTypeCount = tConn.GetIntFrom()
  repeat with i = 1 to tTypeCount
    ttype = tConn.GetIntFrom()
    tItem = [:]
    tItem.setaProp(#time_duration, tConn.GetIntFrom())
    tItem.setaProp(#count, tConn.GetIntFrom())
    tTimeLeft = tConn.GetIntFrom()
    tItem.setaProp(#time_left, tTimeLeft)
    tList.setaProp(ttype, tItem)
    tIndex.append(ttype)
    if tTimeLeft > 0 then
      if tActiveIndex.findPos(ttype) = 0 then
        tActiveIndex.append(ttype)
        tActiveList.setaProp(ttype, the milliSeconds + (tTimeLeft * 1000))
      end if
    end if
  end repeat
  pInventoryList = tList
  pInventoryEffects = tIndex
  pActiveEffects = tActiveList
  pActiveEffectIndex = tActiveIndex
  getObject(#session).set("active_fx", pActiveEffects)
  if tTypeCount > 0 then
    pSelectedEffectType = tIndex[1]
  else
    pSelectedEffectType = VOID
  end if
  pState = 1
  getObject(#session).set(#fx_on, 1)
  return me.updateFxView()
end

on handle_avatar_effect_added me, tMsg
  tConn = tMsg.getaProp(#connection)
  tItem = [:]
  ttype = tConn.GetIntFrom()
  if pInventoryList.findPos(ttype) = 0 then
    tItem.setaProp(#type, ttype)
    tItem.setaProp(#count, 1)
    pInventoryList.setaProp(ttype, tItem)
    pInventoryEffects.append(ttype)
  else
    tItem = pInventoryList.getaProp(ttype)
    tItem.setaProp(#count, tItem.getaProp(#count) + 1)
  end if
  tTime = tConn.GetIntFrom()
  tItem.setaProp(#time_duration, tTime)
  tItem.setaProp(#time_left, tTime)
  return me.updateFxView()
end

on handle_avatar_effect_activated me, tMsg
  tConn = tMsg.getaProp(#connection)
  ttype = tConn.GetIntFrom()
  tTime = tConn.GetIntFrom()
  if pActiveEffectIndex.findPos(ttype) = 0 then
    pActiveEffectIndex.add(ttype)
    pActiveEffects.setaProp(ttype, the milliSeconds + (tTime * 1000))
  end if
  getObject(#session).set("active_fx", pActiveEffects)
  tSlotCount = 5
  if pActiveEffectIndex.count > tSlotCount then
    pSlotOffset = pActiveEffectIndex.count - tSlotCount
  end if
  return me.updateFxView()
end

on handle_avatar_effect_expired me, tMsg, tTestType
  if voidp(tMsg) then
    if not voidp(tTestType) then
      ttype = tTestType
    else
      return 0
    end if
  else
    tConn = tMsg.getaProp(#connection)
    ttype = tConn.GetIntFrom()
  end if
  pActiveEffects.deleteProp(ttype)
  pActiveEffectIndex.deleteOne(ttype)
  tEffectListItem = pInventoryList.getaProp(ttype)
  if ilk(tEffectListItem) = #propList then
    if tEffectListItem[#count] > 1 then
      pInventoryList.getaProp(ttype)[#count] = tEffectListItem[#count] - 1
    else
      pInventoryList.deleteProp(ttype)
      pInventoryEffects.deleteOne(ttype)
    end if
  else
    pInventoryEffects.deleteOne(ttype)
  end if
  getObject(#session).set("active_fx", pActiveEffects)
  if ttype = pSelectedEffectType then
    if pInventoryEffects.count > 0 then
      pSelectedEffectType = pInventoryEffects[1]
    else
      pSelectedEffectType = VOID
    end if
  end if
  executeMessage(#updateInfostandAvatar)
  return me.updateFxView()
end

on handle_avatar_effect_selected me, tMsg
  tConn = tMsg.getaProp(#connection)
  ttype = tConn.GetIntFrom()
  executeMessage(#fx_selected, ttype)
  return me.updateFxView()
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(460, #handle_avatar_effects)
  tMsgs.setaProp(461, #handle_avatar_effect_added)
  tMsgs.setaProp(462, #handle_avatar_effect_activated)
  tMsgs.setaProp(463, #handle_avatar_effect_expired)
  tMsgs.setaProp(464, #handle_avatar_effect_selected)
  tCmds = [:]
  tCmds.setaProp("USE_AVATAR_EFFECT", 372)
  tCmds.setaProp("ACTIVATE_AVATAR_EFFECT", 373)
  if tBool then
    registerListener(getVariable("connection.info.id", #Info), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id", #Info), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id", #Info), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id", #Info), me.getID(), tCmds)
  end if
  return 1
end

on eventProc me, tEvent, tSprID, tParam, tWndID
  if not pState then
    return 1
  end if
  case tSprID of
    "fx_activate_button":
      return me.send_activate_avatar_effect(pSelectedEffectType)
    "slot_arrow_right":
      if pSlotOffset >= (pActiveEffectIndex.count - 5) then
        return 1
      end if
      pSlotOffset = pSlotOffset + 1
      return me.updateSlots()
    "slot_arrow_left":
      if pSlotOffset < 1 then
        return 1
      end if
      pSlotOffset = pSlotOffset - 1
      return me.updateSlots()
    "badges_tab":
      return executeMessage(#openBadgeWindow)
    "achievements_tab":
      return executeMessage(#openAchievementsWindow)
    "fx_list":
      if tParam.ilk <> #point then
        return 0
      end if
      tFXId = pListRenderer.getBadgeAt(tParam)
      if not tFXId then
        return 0
      end if
      me.selectItem(tFXId)
    "slot_bg_1", "slot_bg_2", "slot_bg_3", "slot_bg_4", "slot_bg_5", "fx_slot_1", "fx_slot_2", "fx_slot_3", "fx_slot_4", "fx_slot_5":
      tPos = pSlotOffset + integer(tSprID.char[9])
      if tPos > pActiveEffectIndex.count then
        return 1
      end if
      me.selectItem(pActiveEffectIndex[tPos])
    "fx_catalog_link_text":
      getThread(#catalogue).getComponent().preparePageByName(getText("fx.catalog.link.nodename", "Special Effects"))
  end case
  return 1
end
