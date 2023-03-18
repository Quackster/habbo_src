property pHotelClosingID, pLoginFailedID

on construct me
  pHotelClosingID = getText("opening_hours_title")
  pLoginFailedID = "opening_hours_login_failed"
  return 1
end

on deconstruct me
  return me.hideAll()
end

on hideAll me
  me.hideHotelClosingAlert()
  me.hideHotelClosingNotice()
  me.hideHotelClosedNotice()
  me.hideHotelClosedDisconnectNotice()
  return 1
end

on showHotelClosingAlert me, tTimeDelta
  if not windowExists(pHotelClosingID) then
    createWindow(pHotelClosingID, "habbo_basic.window", 0, 0, #modal)
    tWndObj = getWindow(pHotelClosingID)
    if tWndObj = 0 then
      return 0
    end if
  else
    tWndObj = getWindow(pHotelClosingID)
    tWndObj.unmerge()
  end if
  tWindow = "openhrs"
  if not tWndObj.merge(tWindow & ".window") then
    return me.hideHotelClosingStatusAlert()
  end if
  tTextId = "opening_hours_text_shutdown"
  tText = getText(tTextId)
  if voidp(tTimeDelta) then
    tText = replaceChunks(tText, "%d%", EMPTY)
  else
    tText = replaceChunks(tText, "%d%", string(tTimeDelta))
  end if
  tWndObj.getElement("openhrs_txt").setText(tText)
  tWndObj.center()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcStatus, me.getID(), #mouseUp)
end

on showHotelClosingNotice me
  if not windowExists(pHotelClosingID) then
    createWindow(pHotelClosingID, "habbo_basic.window", 0, 0, #modal)
    tWndObj = getWindow(pHotelClosingID)
    if tWndObj = 0 then
      return 0
    end if
  else
    tWndObj = getWindow(pHotelClosingID)
    tWndObj.unmerge()
  end if
  if not tWndObj.merge("openhrs.window") then
    return me.hideHotelClosingNotice()
  end if
  tWndObj.center()
  tText = getText("opening_hours_text_disabled")
  tWndObj.getElement("openhrs_txt").setText(tText)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcNotice, me.getID(), #mouseUp)
end

on showHotelClosedDisconnectNotice me, tOpenHour, tOpenMinute
  if not windowExists(pLoginFailedID) then
    createWindow(pLoginFailedID, "error.window", 0, 0, #modal)
    tWndObj = getWindow(pLoginFailedID)
    if tWndObj = 0 then
      return 0
    end if
    tWndObj.center()
    tText = getText("opening_hours_text_opening_time")
    tHour = string(tOpenHour)
    if tHour.length = 1 then
      tHour = "0" & tHour
    end if
    tMinute = string(tOpenMinute)
    if tMinute.length = 1 then
      tMinute = "0" & tMinute
    end if
    tText = replaceChunks(tText, "%h%", tHour)
    tText = replaceChunks(tText, "%m%", tMinute)
    tWndObj.getElement("error_title").setText(getText("Alert_ConnectionFailure"))
    tWndObj.getElement("error_text").setText(tText)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcLoginFailed, me.getID(), #mouseUp)
  end if
  return 1
end

on showHotelClosedNotice me, tOpenHour, tOpenMinute
  if not windowExists(pHotelClosingID) then
    createWindow(pHotelClosingID, "habbo_basic.window", 0, 0, #modal)
    tWndObj = getWindow(pHotelClosingID)
    if tWndObj = 0 then
      return 0
    end if
  else
    tWndObj = getWindow(pHotelClosingID)
    tWndObj.unmerge()
  end if
  if not tWndObj.merge("openhrs.window") then
    return me.hideHotelClosedNotice()
  end if
  tWndObj.center()
  tText = getText("opening_hours_text_closed")
  tHour = string(tOpenHour)
  if tHour.length = 1 then
    tHour = "0" & tHour
  end if
  tMinute = string(tOpenMinute)
  if tMinute.length = 1 then
    tMinute = "0" & tMinute
  end if
  tText = replaceChunks(tText, "%h%", tHour)
  tText = replaceChunks(tText, "%m%", tMinute)
  tWndObj.getElement("openhrs_txt").setText(tText)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcClosed, me.getID(), #mouseUp)
end

on hideHotelClosingAlert me
  if windowExists(pHotelClosingID) then
    return removeWindow(pHotelClosingID)
  end if
  return 0
end

on hideHotelClosingNotice me
  if windowExists(pHotelClosingID) then
    return removeWindow(pHotelClosingID)
  end if
  return 0
end

on hideHotelClosedDisconnectNotice me
  if windowExists(pLoginFailedID) then
    return removeWindow(pLoginFailedID)
  end if
  return 0
end

on hideHotelClosedNotice me
  if windowExists(pHotelClosingID) then
    return removeWindow(pHotelClosingID)
  end if
  return 0
end

on eventProcStatus me, tEvent, tElemID, tParam
  if tEvent = #mouseUp then
    case tElemID of
      "close":
        return me.hideHotelClosingAlert()
      "openhrs_ok":
        return me.hideHotelClosingAlert()
      otherwise:
        return 0
    end case
  end if
  return 1
end

on eventProcNotice me, tEvent, tElemID, tParam
  if tEvent = #mouseUp then
    case tElemID of
      "close":
        return me.hideHotelClosingNotice()
      "openhrs_ok":
        return me.hideHotelClosingNotice()
      otherwise:
        return 0
    end case
  end if
  return 1
end

on eventProcLoginFailed me, tEvent, tElemID, tParam
  if tEvent = #mouseUp then
    case tElemID of
      otherwise:
        return 0
    end case
  end if
  return 1
end

on eventProcClosed me, tEvent, tElemID, tParam
  if tEvent = #mouseUp then
    case tElemID of
      "close":
        return me.hideHotelClosingNotice()
      "openhrs_ok":
        return me.hideHotelClosingNotice()
      otherwise:
        return 0
    end case
  end if
  return 1
end
