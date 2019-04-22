on construct(me)
  pInviteIndex = []
  pInviteList = []
  return(1)
  exit
end

on deconstruct(me)
  pInviteIndex = []
  pInviteList = []
  return(me.deconstruct())
  exit
end

on update(me)
  if the milliSeconds - pUpdateCounter < 1000 then
    return(1)
  end if
  pUpdateCounter = the milliSeconds
  me.updateExpirationTimers()
  return(1)
  exit
end

on updateExpirationTimers(me)
  if pInviteList.count = 0 then
    return(1)
  end if
  tPurgeList = []
  i = 1
  repeat while i <= pInviteList.count
    tItem = pInviteList.getAt(i)
    tExpires = tItem.getaProp(#expires_msec)
    tSeconds = tExpires - the milliSeconds / 1000
    tItem.setaProp(#seconds_valid, tSeconds)
    if tSeconds < 1 then
      tPurgeList.append(tItem.getaProp(#id))
    end if
    i = 1 + i
  end repeat
  repeat while me <= undefined
    tID = getAt(undefined, undefined)
    me.removeInvitation(tID, 0)
  end repeat
  if tPurgeList.count = 0 and pInviteList.count = 0 then
    return(1)
  end if
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return(0)
  end if
  if tPurgeList.count = 0 then
    tRenderObj.refreshFirstTimer(pInviteList.getAt(1).getaProp(#seconds_valid))
  else
    tRenderObj.renderSubComponents()
  end if
  return(1)
  exit
end

on setAsFirstEntry(me, tGameId)
  if tGameId = void() then
    return(0)
  end if
  if pInviteIndex.findPos(tGameId) = 0 then
    return(0)
  end if
  pInviteIndex.deleteOne(tGameId)
  pInviteIndex.addAt(1, tGameId)
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return(0)
  end if
  tRenderObj.renderSubComponents()
  return(1)
  exit
end

on storeGameInvitation(me, tdata)
  return(1)
  exit
end

on removeInvitation(me, tGameId, tRenderFlag)
  return(1)
  exit
end

on declineAllInvitations(me)
  tMainThread = me.getMainThread()
  if tMainThread = 0 then
    return(0)
  end if
  tHandler = tMainThread.getHandler()
  repeat while me <= undefined
    tGameId = getAt(undefined, undefined)
    tHandler.send_DECLINE_INVITE_REQUEST(tGameId)
  end repeat
  pInviteList = []
  pInviteIndex = []
  return(1)
  exit
end

on invitationDeclined(me, tGameId)
  me.removeInvitation(tGameId, 1)
  tMainThread = me.getMainThread()
  if tMainThread = 0 then
    return(0)
  end if
  return(tMainThread.getHandler().send_DECLINE_INVITE_REQUEST(tGameId))
  exit
end

on invitationAccepted(me, tGameId, tTeamIndex)
  me.removeInvitation(tGameId, 0)
  me.ChangeWindowView("GameList")
  tListService = me.getIGComponent("GameList")
  tListService.setJoinedGameId(tGameId, tTeamIndex)
  return(me.declineAllInvitations())
  exit
end

on getInvitationCount(me)
  return(pInviteIndex.count)
  exit
end

on getEntry(me, tGameId)
  if voidp(tGameId) then
    return(0)
  end if
  return(pInviteList.getaProp(tGameId))
  exit
end

on getEntryByIndex(me, tIndex)
  if tIndex = void() then
    return(0)
  end if
  if tIndex > pInviteIndex.count then
    return(0)
  end if
  return(pInviteList.getaProp(pInviteIndex.getAt(tIndex)))
  exit
end

on getGameByIndex(me, tIndex)
  tInfo = me.getEntryByIndex(tIndex)
  if tInfo = 0 then
    return(0)
  end if
  return(tInfo.getaProp(#game_object))
  exit
end