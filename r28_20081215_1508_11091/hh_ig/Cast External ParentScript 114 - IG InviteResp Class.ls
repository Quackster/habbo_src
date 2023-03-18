property pInviteIndex, pInviteList, pUpdateCounter

on construct me
  pInviteIndex = []
  pInviteList = [:]
  return 1
end

on deconstruct me
  pInviteIndex = []
  pInviteList = [:]
  return me.ancestor.deconstruct()
end

on update me
  if (the milliSeconds - pUpdateCounter) < 1000 then
    return 1
  end if
  pUpdateCounter = the milliSeconds
  me.updateExpirationTimers()
  return 1
end

on updateExpirationTimers me
  if pInviteList.count = 0 then
    return 1
  end if
  tPurgeList = []
  repeat with i = 1 to pInviteList.count
    tItem = pInviteList[i]
    tExpires = tItem.getaProp(#expires_msec)
    tSeconds = (tExpires - the milliSeconds) / 1000
    tItem.setaProp(#seconds_valid, tSeconds)
    if tSeconds < 1 then
      tPurgeList.append(tItem.getaProp(#id))
    end if
  end repeat
  repeat with tID in tPurgeList
    me.removeInvitation(tID, 0)
  end repeat
  if (tPurgeList.count = 0) and (pInviteList.count = 0) then
    return 1
  end if
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return 0
  end if
  if tPurgeList.count = 0 then
    tRenderObj.refreshFirstTimer(pInviteList[1].getaProp(#seconds_valid))
  else
    tRenderObj.renderSubComponents()
  end if
  return 1
end

on setAsFirstEntry me, tGameId
  if tGameId = VOID then
    return 0
  end if
  if pInviteIndex.findPos(tGameId) = 0 then
    return 0
  end if
  pInviteIndex.deleteOne(tGameId)
  pInviteIndex.addAt(1, tGameId)
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return 0
  end if
  tRenderObj.renderSubComponents()
  return 1
end

on storeGameInvitation me, tdata
  return 1
end

on removeInvitation me, tGameId, tRenderFlag
  put "* removeInvitation" && tGameId && tRenderFlag
  return 1
end

on declineAllInvitations me
  put "* declineAllInvitations"
  tMainThread = me.getMainThread()
  if tMainThread = 0 then
    return 0
  end if
  tHandler = tMainThread.getHandler()
  repeat with tGameId in pInviteIndex
    tHandler.send_DECLINE_INVITE_REQUEST(tGameId)
  end repeat
  pInviteList = [:]
  pInviteIndex = []
  return 1
end

on invitationDeclined me, tGameId
  me.removeInvitation(tGameId, 1)
  tMainThread = me.getMainThread()
  if tMainThread = 0 then
    return 0
  end if
  return tMainThread.getHandler().send_DECLINE_INVITE_REQUEST(tGameId)
end

on invitationAccepted me, tGameId, tTeamIndex
  put "* invitationAccepted, join team" && tTeamIndex
  me.removeInvitation(tGameId, 0)
  me.ChangeWindowView("GameList")
  tListService = me.getIGComponent("GameList")
  tListService.setJoinedGameId(tGameId, tTeamIndex)
  return me.declineAllInvitations()
end

on getInvitationCount me
  return pInviteIndex.count
end

on getEntry me, tGameId
  if voidp(tGameId) then
    return 0
  end if
  return pInviteList.getaProp(tGameId)
end

on getEntryByIndex me, tIndex
  if tIndex = VOID then
    return 0
  end if
  if tIndex > pInviteIndex.count then
    return 0
  end if
  return pInviteList.getaProp(pInviteIndex[tIndex])
end

on getGameByIndex me, tIndex
  tInfo = me.getEntryByIndex(tIndex)
  if tInfo = 0 then
    return 0
  end if
  return tInfo.getaProp(#game_object)
end
