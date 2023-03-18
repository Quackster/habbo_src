property pWindowID, pUseRatings

on construct me
  pWindowID = "RoomInfoWindow"
  pUseRatings = 0
  if variableExists("room.rating.enable") then
    if getVariable("room.rating.enable") = 1 then
      pUseRatings = 1
    end if
  end if
  registerMessage(#roomRatingChanged, me.getID(), #updateRatingData)
  return 1
end

on deconstruct me
  return 1
end

on showRoomInfo me
  if getThread(#room).getComponent().getRoomData().type = #private then
    tWndObj = me.createInfoWindow()
    if tWndObj = 0 then
      return 0
    end if
    tRoomData = getThread(#room).getComponent().pSaveData
    tWndObj.getElement("room_info_room_name").setText(tRoomData[#name])
    tWndObj.getElement("room_info_owner").setText(getText("room_owner") && tRoomData[#owner])
    me.updateRatingData()
  else
    me.hideRoomInfo()
  end if
end

on hideRoomInfo me
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
end

on createInfoWindow me
  if not windowExists(pWindowID) then
    if pUseRatings then
      tSuccess = createWindow(pWindowID, "room_info.window", 10, 420)
    else
      tSuccess = createWindow(pWindowID, "room_info_no_rating.window", 10, 437)
    end if
    if tSuccess = 0 then
      return 0
    else
      tWndObj = getWindow(pWindowID)
      tWndObj.lock()
      tWndObj.registerProcedure(#eventProcInfo, me.getID())
      return tWndObj
    end if
  else
    return getWindow(pWindowID)
  end if
end

on sendFlatRate me, tValue
  getThread(#room).getComponent().getRoomConnection().send("RATEFLAT", [#integer: tValue])
end

on updateRatingData me
  if not pUseRatings then
    return 1
  end if
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return 0
  end if
  if not tWndObj.elementExists("room_info_rate_plus") then
    return 0
  end if
  tRoomRatings = getThread(#room).getComponent().getRoomRating()
  if tRoomRatings[#rate] = -1 then
    tWndObj.getElement("room_info_rate_plus").setProperty(#visible, 1)
    tWndObj.getElement("room_info_rate_minus").setProperty(#visible, 1)
    tWndObj.getElement("room_info_rate_room").setProperty(#visible, 1)
    tWndObj.getElement("room_info_rate_value").setProperty(#visible, 0)
  else
    tWndObj.getElement("room_info_rate_plus").setProperty(#visible, 0)
    tWndObj.getElement("room_info_rate_minus").setProperty(#visible, 0)
    tWndObj.getElement("room_info_rate_room").setProperty(#visible, 0)
    tWndObj.getElement("room_info_rate_value").setProperty(#visible, 1)
    tRateText = getText("room_info_rated") && tRoomRatings[#rate]
    tWndObj.getElement("room_info_rate_value").setText(tRateText)
  end if
end

on eventProcInfo me, tEvent, tSprID, tParam
  if tEvent <> #mouseUp then
    return 0
  end if
  case tSprID of
    "room_info_rate_plus":
      me.sendFlatRate(1)
    "room_info_rate_minus":
      me.sendFlatRate(-1)
  end case
end
