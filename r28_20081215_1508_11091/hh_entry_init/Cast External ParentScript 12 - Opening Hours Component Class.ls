property pHotelClosingStatus, pHotelClosedDisconnectStatus

on construct me
  pHotelClosingStatus = 0
  pHotelClosedDisconnectStatus = 0
  registerMessage(#getHotelClosingStatus, me.getID(), #getHotelClosingStatus)
  registerMessage(#getHotelClosedDisconnectStatus, me.getID(), #getHotelClosedDisconnectStatus)
  registerMessage(#getAvailabilityTime, me.getID(), #sendGetAvailabilityTime)
  return 1
end

on deconstruct me
  unregisterMessage(#getHotelClosingStatus, me.getID())
  unregisterMessage(#getOpeningHours, me.getID())
  unregisterMessage(#getHotelClosedDisconnectStatus, me.getID())
  return 1
end

on getHotelClosingStatus me, tList
  tValue = 0
  if pHotelClosingStatus = 1 then
    tValue = 1
  end if
  if ilk(tList) = #propList then
    tList["retval"] = tValue
    if tValue and tList["showDialog"] then
      me.getInterface().showHotelClosingNotice()
    end if
  end if
  return tValue
end

on getHotelAvailabilityStatus me, tList
  tValue = 1
  if pHotelClosingStatus = 2 then
    tValue = 0
  end if
  if ilk(tList) = #propList then
    tList["retval"] = tValue
  end if
  return tValue
end

on getHotelClosedDisconnectStatus me, tList
  tValue = pHotelClosedDisconnectStatus
  if ilk(tList) = #propList then
    tList["retval"] = tValue
  end if
  return tValue
end

on setHotelClosingStatus me, tStatus
  pHotelClosingStatus = tStatus
end

on sendGetAvailabilityTime me
  getConnection(getVariable("connection.info.id")).send("GET_AVAILABILITY_TIME")
end

on setHotelClosedDisconnect me, tOpenHour, tOpenMinute
  pHotelClosingStatus = 2
  pHotelClosedDisconnectStatus = 1
  me.getInterface().showHotelClosedDisconnectNotice(tOpenHour, tOpenMinute)
end
