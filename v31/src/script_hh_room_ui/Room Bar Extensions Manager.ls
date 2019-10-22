property pVisibleItem, pInvitationData, pVisibleItemID, pRoomInvitationClass, pBottomBarId, pShowInstantFriendRequests, pFriendRequestClass, pFriendRequestData

on construct me 
  pRoomInvitationClass = "Invitation Class"
  pFriendRequestClass = "Instant Friend Request Class"
  pVisibleItemID = "Visible Room Bar Extension Item"
  pInvitationData = [:]
  pFriendRequestData = [:]
  pVisibleItem = void()
  pShowInstantFriendRequests = 1
  registerMessage(#FriendRequestListOpened, me.getID(), #clearFriendRequestsFromStack)
  registerMessage(#updateFriendRequestCount, me.getID(), #viewNextItemInStack)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#FriendRequestListOpened, me.getID())
  unregisterMessage(#updateFriendRequestCount, me.getID())
  return TRUE
end

on define me, tBottomBarID 
  pBottomBarId = tBottomBarID
end

on hideExtensions me 
  me.hideInvitation()
  me.hideFriendRequest()
end

on registerInvitation me, tInvitationData 
  pInvitationData = tInvitationData
  me.showPendingInvitation()
end

on clearFriendRequestsFromStack me 
  me.hideFriendRequest()
  me.showPendingInvitation()
end

on showPendingInvitation me 
  if pVisibleItem <> void() then
    return FALSE
  end if
  if pInvitationData.count < 1 then
    return FALSE
  end if
  if objectExists(pVisibleItemID) then
    return TRUE
  end if
  tInvitationObj = createObject(pVisibleItemID, pRoomInvitationClass)
  if not tInvitationObj then
    return FALSE
  end if
  if not tInvitationObj.show(pInvitationData, pBottomBarId, "friend_list_icon") then
    if objectExists(pVisibleItemID) then
      removeObject(pVisibleItemID)
    end if
    return FALSE
  end if
  pVisibleItem = #invitation
  return TRUE
end

on showPendingInstantFriendRequest me 
  if not pShowInstantFriendRequests then
    return FALSE
  end if
  if not voidp(pVisibleItem) and not (pVisibleItem = #friendrequest) then
    return FALSE
  end if
  if objectExists(pVisibleItemID) then
    return TRUE
  end if
  if not threadExists(#friend_list) then
    return FALSE
  end if
  tRoomComponent = getThread(#room).getComponent()
  tRoomData = tRoomComponent.getRoomData()
  if not (ilk(tRoomData) = #propList) then
    return FALSE
  end if
  if not (tRoomData.getAt(#type) = #private) or (tRoomData.getAt(#type) = #public) then
    return FALSE
  end if
  if not threadExists(#friend_list) then
    return FALSE
  end if
  tFriendListComponent = getThread(#friend_list).getComponent()
  tFriendListInterface = getThread(#friend_list).getInterface()
  if tFriendListInterface.isFriendRequestViewOpen() then
    return FALSE
  end if
  tPendingRequests = tFriendListComponent.getPendingFriendRequests()
  if (tPendingRequests.count = 0) then
    me.hideFriendRequest()
    return FALSE
  end if
  repeat while tPendingRequests <= undefined
    tPendingRequest = getAt(undefined, undefined)
    tRoomID = tRoomComponent.getUsersRoomId(tPendingRequest.getAt(#name))
    tUserObj = tRoomComponent.getUserObject(tRoomID)
    if not (tUserObj = 0) then
      createObject(pVisibleItemID, pFriendRequestClass)
      tObj = getObject(pVisibleItemID)
      tObj.define(pBottomBarId, "friend_list_icon", tPendingRequest, me.getID())
      tObj.show()
      pFriendRequestData = tPendingRequest
      pVisibleItem = #friendrequest
      return TRUE
    end if
  end repeat
  return FALSE
end

on ignoreInstantFriendRequests me 
  pShowInstantFriendRequests = 0
  me.hideFriendRequest()
  me.showPendingInvitation()
end

on viewNextItemInStack me 
  tFrShown = me.showPendingInstantFriendRequest()
  if not tFrShown then
    me.showPendingInvitation()
  end if
end

on confirmFriendRequest me, tAccept 
  if not threadExists(#friend_list) then
    return FALSE
  end if
  tFriendListComponent = getThread(#friend_list).getComponent()
  tFriendListInterface = getThread(#friend_list).getInterface()
  tRequestId = pFriendRequestData.getAt(#id)
  if tAccept then
    if tFriendListComponent.isFriendListFull() then
      executeMessage(#alert, "console_fr_limit_exceeded_error")
      me.hideFriendRequest()
      return FALSE
    end if
    tFriendListComponent.updateFriendRequest(pFriendRequestData, #accepted)
  else
    tFriendListComponent.updateFriendRequest(pFriendRequestData, #rejected)
  end if
  me.hideFriendRequest()
end

on acceptInvitation me 
  if ilk(pInvitationData) <> #propList then
    return FALSE
  end if
  tSenderId = pInvitationData.getaProp(#userID)
  if voidp(tSenderId) then
    return FALSE
  end if
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MSG_ACCEPT_TUTOR_INVITATION", [#string:tSenderId])
  end if
  me.hideInvitation()
end

on rejectInvitation me 
  tSenderId = pInvitationData.getaProp(#userID)
  if voidp(tSenderId) then
    return FALSE
  end if
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MSG_REJECT_TUTOR_INVITATION", [#string:tSenderId])
  end if
  me.hideInvitation()
  createTimeout(#room_bar_extension_next_update, 1000, #viewNextItemInStack, me.getID(), void(), 1)
end

on hideInvitation me 
  if (pVisibleItem = #invitation) then
    removeObject(pVisibleItemID)
    pVisibleItem = void()
  end if
  pInvitationData = [:]
end

on hideFriendRequest me 
  if (pVisibleItem = #friendrequest) then
    removeObject(pVisibleItemID)
    pVisibleItem = void()
  end if
  pFriendRequestData = [:]
end

on invitationFollowFailed me 
  executeMessage(#alert, "invitation_follow_failed")
end
