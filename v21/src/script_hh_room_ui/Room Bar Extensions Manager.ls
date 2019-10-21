property pVisibleItem, pInvitationData, pVisibleItemID, pRoomInvitationClass, pBottomBarId, pShowInstantFriendRequests, pFriendRequestClass, pFriendRequestData

on construct me 
  pRoomInvitationClass = "Invitation Class"
  pFriendRequestClass = "Instant Friend Request Class"
  pVisibleItemID = "Visible Room Bar Extension Item"
  pInvitationData = [:]
  pFriendRequestData = [:]
  pVisibleItem = void()
  pShowInstantFriendRequests = 1
  registerMessage(#showInvitation, me.getID(), #registerInvitation)
  registerMessage(#hideInvitation, me.getID(), #hideInvitation)
  registerMessage(#acceptInvitation, me.getID(), #acceptInvitation)
  registerMessage(#rejectInvitation, me.getID(), #rejectInvitation)
  registerMessage(#messengerOpened, me.getID(), #clearFriendRequestsFromStack)
  registerMessage(#updateBuddyrequestCount, me.getID(), #showPendingInstantFriendRequest)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#acceptInvitation, me.getID())
  unregisterMessage(#rejectInvitation, me.getID())
  unregisterMessage(#showInvitation, me.getID())
  unregisterMessage(#hideInvitation, me.getID())
  unregisterMessage(#messengerOpened, me.getID())
  unregisterMessage(#updateBuddyrequestCount, me.getID())
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
  tInvitationObj = createObject(pVisibleItemID, pRoomInvitationClass)
  tInvitationObj.show(pInvitationData, pBottomBarId, "int_messenger_image")
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
  if not threadExists(#messenger) then
    return FALSE
  end if
  if not windowExists(pBottomBarId) then
    return FALSE
  end if
  tMessengerComponent = getThread(#messenger).getComponent()
  tMessengerInterface = getThread(#messenger).getInterface()
  if tMessengerInterface.isMessengerOpen() then
    return FALSE
  end if
  tPendingRequest = tMessengerComponent.getNextPendingInstantBuddyRequest()
  if listp(tPendingRequest) then
    createObject(pVisibleItemID, pFriendRequestClass)
    tObj = getObject(pVisibleItemID)
    tObj.define(pBottomBarId, "int_messenger_image", tPendingRequest, me.getID())
    tObj.show()
    pFriendRequestData = tPendingRequest
    pVisibleItem = #friendrequest
    return TRUE
  else
    me.hideFriendRequest()
  end if
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
  if threadExists(#messenger) then
    tMessengerComponent = getThread(#messenger).getComponent()
    tMessengerInterface = getThread(#messenger).getInterface()
    tRequestId = pFriendRequestData.getAt(#id)
    if tAccept then
      if tMessengerInterface.getFriendRequestRenderer().isBuddyListFull() then
        executeMessage(#alert, "console_fr_limit_exceeded_error")
        me.hideFriendRequest()
        return FALSE
      end if
      tMessengerComponent.acceptRequest(tRequestId)
    else
      tMessengerComponent.declineRequest(tRequestId)
    end if
  end if
  tMessengerComponent.clearRequests()
  me.hideFriendRequest()
end

on acceptInvitation me 
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
