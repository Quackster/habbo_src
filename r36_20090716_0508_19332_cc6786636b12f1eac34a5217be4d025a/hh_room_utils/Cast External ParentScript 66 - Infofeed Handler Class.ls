property pAnnouncedBadgeIds

on construct me
  pAnnouncedBadgeIds = []
  registerMessage(#badgeReceivedAndReady, me.getID(), #badgeReceivedAndReady)
  me.regMsgList(1)
  return 1
end

on deconstruct me
  pAnnouncedBadgeIds = []
  unregisterMessage(#badgeReceivedAndReady, me.getID())
  me.regMsgList(0)
  return 1
end

on badgeReceivedAndReady me, tBadgeID
  if pAnnouncedBadgeIds.findPos(tBadgeID) then
    return 1
  end if
  pAnnouncedBadgeIds.add(tBadgeID)
  tItem = [:]
  tItem.setaProp(#type, #newbadge)
  tItem.setaProp(#value, tBadgeID)
  me.getComponent().createItem(tItem)
  return 1
end

on handleActivityPointNotification me, tMsg
  tConn = tMsg.getaProp(#connection)
  tAmount = tConn.GetIntFrom()
  tChange = tConn.GetIntFrom()
  if tChange > 0 then
    tItem = [:]
    tItem.setaProp(#type, #pixels)
    tItem.setaProp(#value, tAmount)
    me.getComponent().createItem(tItem)
  else
    if tChange < 0 then
      executeMessage(#playPixelPurchaseSound)
    end if
  end if
  tSession = getObject(#session)
  if tSession = 0 then
    return 0
  end if
  tSession.set("user_pixelbalance", tAmount)
  executeMessage(#updateCatalogPurse)
  return 1
end

on handleRespectNotification me, tMsg
  tConn = tMsg.getaProp(#connection)
  tReceiverID = tConn.GetIntFrom()
  tAmount = tConn.GetIntFrom()
  tSession = getObject(#session)
  if tSession = 0 then
    return 0
  end if
  executeMessage(#showRespectInRoom, tReceiverID)
  if tReceiverID <> integer(tSession.GET("user_user_id")) then
    return 1
  else
    tItem = [:]
    tItem.setaProp(#type, #respect)
    tItem.setaProp(#value, tAmount)
    me.getComponent().createItem(tItem)
    playSound("magic_brimm_low2-1", #cut, [#loopCount: 1, #infiniteloop: 0, #volume: 125])
  end if
  return 1
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(438, #handleActivityPointNotification)
  tMsgs.setaProp(440, #handleRespectNotification)
  tCmds = [:]
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return 1
end
