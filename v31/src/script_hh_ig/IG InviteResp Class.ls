property pUpdateCounter, pInviteList, pInviteIndex

on construct me 
  pInviteIndex = []
  pInviteList = [:]
  return TRUE
end

on deconstruct me 
  pInviteIndex = []
  pInviteList = [:]
  return(me.ancestor.deconstruct())
end

on update me 
  if (the milliSeconds - pUpdateCounter) < 1000 then
    return TRUE
  end if
  pUpdateCounter = the milliSeconds
  me.updateExpirationTimers()
  return TRUE
end

on updateExpirationTimers me 
  if (pInviteList.count = 0) then
    return TRUE
  end if
  tPurgeList = []
  i = 1
  repeat while i <= pInviteList.count
    tItem = pInviteList.getAt(i)
    tExpires = tItem.getaProp(#expires_msec)
    tSeconds = ((tExpires - the milliSeconds) / 1000)
    tItem.setaProp(#seconds_valid, tSeconds)
    if tSeconds < 1 then
      tPurgeList.append(tItem.getaProp(#id))
    end if
    i = (1 + i)
  end repeat
  repeat while tPurgeList <= undefined
    tID = getAt(undefined, undefined)
    me.removeInvitation(tID, 0)
  end repeat
  if (tPurgeList.count = 0) and (pInviteList.count = 0) then
    return TRUE
  end if
  tRenderObj = me.getRenderer()
  if (tRenderObj = 0) then
    return FALSE
  end if
  if (tPurgeList.count = 0) then
    tRenderObj.refreshFirstTimer(pInviteList.getAt(1).getaProp(#seconds_valid))
  else
    tRenderObj.renderSubComponents()
  end if
  return TRUE
end

on setAsFirstEntry me, tGameId 
  if (tGameId = void()) then
    return FALSE
  end if
  if (pInviteIndex.findPos(tGameId) = 0) then
    return FALSE
  end if
  pInviteIndex.deleteOne(tGameId)
  pInviteIndex.addAt(1, tGameId)
  tRenderObj = me.getRenderer()
  if (tRenderObj = 0) then
    return FALSE
  end if
  tRenderObj.renderSubComponents()
  return TRUE
end

on storeGameInvitation me, tdata 
  return TRUE
end

on removeInvitation me, tGameId, tRenderFlag 
  return TRUE
end

on declineAllInvitations me 
  tMainThread = me.getMainThread()
  if (tMainThread = 0) then
    return FALSE
  end if
  tHandler = tMainThread.getHandler()
  repeat while pInviteIndex <= undefined
    tGameId = getAt(undefined, undefined)
    tHandler.send_DECLINE_INVITE_REQUEST(tGameId)
  end repeat
  pInviteList = [:]
  pInviteIndex = []
  return TRUE
end

on invitationDeclined me, tGameId 
  me.removeInvitation(tGameId, 1)
  tMainThread = me.getMainThread()
  if (tMainThread = 0) then
    return FALSE
  end if
  return(tMainThread.getHandler().send_DECLINE_INVITE_REQUEST(tGameId))
end

on invitationAccepted me, tGameId, tTeamIndex 
  me.removeInvitation(tGameId, 0)
  me.ChangeWindowView("GameList")
  tListService = me.getIGComponent("GameList")
  tListService.setJoinedGameId(tGameId, tTeamIndex)
  return(me.declineAllInvitations())
end

on getInvitationCount me 
  return(pInviteIndex.count)
end

on getEntry me, tGameId 
  if voidp(tGameId) then
    return FALSE
  end if
  return(pInviteList.getaProp(tGameId))
end

on getEntryByIndex me, tIndex 
  if (tIndex = void()) then
    return FALSE
  end if
  if tIndex > pInviteIndex.count then
    return FALSE
  end if
  return(pInviteList.getaProp(pInviteIndex.getAt(tIndex)))
end

on getGameByIndex me, tIndex 
  tInfo = me.getEntryByIndex(tIndex)
  if (tInfo = 0) then
    return FALSE
  end if
  return(tInfo.getaProp(#game_object))
end
