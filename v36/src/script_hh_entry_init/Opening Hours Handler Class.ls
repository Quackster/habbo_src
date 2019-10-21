on construct(me)
  return(me.regMsgList(1))
  exit
end

on deconstruct(me)
  return(me.regMsgList(0))
  exit
end

on handleAvailabilityStatus(me, tMsg)
  tIsOpen = tMsg.GetIntFrom()
  tShutDown = tMsg.GetIntFrom()
  tClosingState = 0
  if not tIsOpen then
    if tShutDown then
      tClosingState = 1
    else
      tClosingState = 2
    end if
  end if
  me.getComponent().setHotelClosingStatus(tClosingState)
  exit
end

on handleInfoHotelClosing(me, tMsg)
  tMinutesUntil = tMsg.GetIntFrom()
  me.getInterface().showHotelClosingAlert(tMinutesUntil)
  exit
end

on handleInfoHotelClosed(me, tMsg)
  tOpenHour = tMsg.GetIntFrom()
  tOpenMinute = tMsg.GetIntFrom()
  tDisconnect = tMsg.GetIntFrom()
  if tDisconnect then
    me.getComponent().setHotelClosedDisconnect(tOpenHour, tOpenMinute)
  else
    me.getInterface().showHotelClosedNotice(tOpenHour, tOpenMinute)
  end if
  exit
end

on handleAvailabilityTime(me, tMsg)
  tIsOpen = tMsg.GetIntFrom()
  tTimeUntil = tMsg.GetIntFrom()
  executeMessage(#hotelAvailabilityTime, tIsOpen, tTimeUntil)
  exit
end

on handleLoginFailedHotelClosed(me, tMsg)
  tOpenHour = tMsg.GetIntFrom()
  tOpenMinute = tMsg.GetIntFrom()
  me.getComponent().setHotelClosedDisconnect(tOpenHour, tOpenMinute)
  exit
end

on regMsgList(me, tBool)
  tMsgs = []
  tMsgs.setaProp(290, #handleAvailabilityStatus)
  tMsgs.setaProp(291, #handleInfoHotelClosing)
  tMsgs.setaProp(292, #handleInfoHotelClosed)
  tMsgs.setaProp(293, #handleAvailabilityTime)
  tMsgs.setaProp(294, #handleLoginFailedHotelClosed)
  tCmds = []
  tCmds.setaProp("GET_AVAILABILITY_TIME", 212)
  tConn = getVariable("connection.info.id", #info)
  if tBool then
    registerListener(tConn, me.getID(), tMsgs)
    registerCommands(tConn, me.getID(), tCmds)
  else
    unregisterListener(tConn, me.getID(), tMsgs)
    unregisterCommands(tConn, me.getID(), tCmds)
  end if
  return(1)
  exit
end