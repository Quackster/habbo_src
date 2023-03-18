property pClubStatus, pGiftCount, pGiftTimeOut, pAcceptedGifts

on construct me
  pClubStatus = [:]
  pGiftCount = 0
  pAcceptedGifts = 0
  pGiftTimeOut = "timeout_clubgift"
  return 1
end

on deconstruct me
  pClubStatus = [:]
  if timeoutExists(pGiftTimeOut) then
    removeTimeout(pGiftTimeOut)
  end if
  return 1
end

on showGifts me, tCount
  pGiftCount = tCount
  pAcceptedGifts = 0
  if pGiftCount > 0 then
    me.getInterface().show_giftinfo()
  end if
  return 1
end

on acceptGift me
  if pGiftCount > pAcceptedGifts then
    pAcceptedGifts = pAcceptedGifts + 1
    if pGiftCount > pAcceptedGifts then
      if timeoutExists(pGiftTimeOut) then
        removeTimeout(pGiftTimeOut)
      end if
      createTimeout(pGiftTimeOut, 1000, #showNextGift, me.getID(), VOID, 1)
    else
      return me.sendAcceptGift()
    end if
  else
    return 0
  end if
end

on rejectGift me
  if pGiftCount > 0 then
    pGiftCount = 0
    if pAcceptedGifts > 0 then
      return me.sendAcceptGift()
    else
      return 1
    end if
  else
    return 0
  end if
end

on sendAcceptGift me
  tAcceptedGifts = pAcceptedGifts
  me.resetGiftList()
  tConnection = getConnection(getVariable("connection.info.id"))
  if tConnection = 0 then
    return error(me, "Couldn't find connection:" && getVariable("connection.info.id"), #sendAcceptGift)
  end if
  return tConnection.send("SCR_GIFT_APPROVAL", [#integer: tAcceptedGifts])
end

on resetGiftList me
  pGiftCount = 0
  pAcceptedGifts = 0
end

on setStatus me, tStatus, tResponseFlag
  tOldClubStatus = pClubStatus
  pClubStatus = tStatus
  getObject(#session).set("club_status", tStatus)
  me.getInterface().updateClubStatus(tStatus, tResponseFlag, tOldClubStatus)
  executeMessage(#updateClubStatus, tStatus)
  return 1
end

on getStatus me
  if voidp(pClubStatus) then
    return 0
  else
    return pClubStatus
  end if
end

on subscribe me, tChosenLength
  if connectionExists(getVariable("connection.info.id")) then
    tList = [#string: "club_habbo", #integer: tChosenLength]
    return getConnection(getVariable("connection.info.id")).send("SCR_BUY", tList)
  else
    return error(me, "Couldn't find connection:" && getVariable("connection.info.id"), #subscribe)
  end if
end

on askforBadgeUpdate me
  if connectionExists(getVariable("connection.info.id")) then
    return getConnection(getVariable("connection.info.id")).send("GETAVAILABLEBADGES")
  else
    return error(me, "Couldn't find connection:" && getVariable("connection.info.id"), #askforBadgeUpdate)
  end if
end

on showNextGift me
  me.getInterface().show_giftinfo()
end
