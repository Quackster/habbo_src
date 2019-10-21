on construct(me)
  pRoomInvitationClass = "Invitation Class"
  pFriendRequestClass = "Instant Friend Request Class"
  pVisibleItemID = "Visible Room Bar Extension Item"
  pInvitationData = []
  pFriendRequestData = []
  pVisibleItem = void()
  pShowInstantFriendRequests = 1
  registerMessage(#showInvitation, me.getID(), #registerInvitation)
  registerMessage(#hideInvitation, me.getID(), #hideInvitation)
  registerMessage(#acceptInvitation, me.getID(), #acceptInvitation)
  registerMessage(#rejectInvitation, me.getID(), #rejectInvitation)
  registerMessage(#messengerOpened, me.getID(), #clearFriendRequestsFromStack)
  registerMessage(#updateBuddyrequestCount, me.getID(), #showPendingInstantFriendRequest)
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#acceptInvitation, me.getID())
  unregisterMessage(#rejectInvitation, me.getID())
  unregisterMessage(#showInvitation, me.getID())
  unregisterMessage(#hideInvitation, me.getID())
  unregisterMessage(#messengerOpened, me.getID())
  unregisterMessage(#updateBuddyrequestCount, me.getID())
  return(1)
  exit
end

on define(me, tBottomBarID)
  pBottomBarId = tBottomBarID
  exit
end

on hideExtensions(me)
  me.hideInvitation()
  me.hideFriendRequest()
  exit
end

on registerInvitation(me, tInvitationData)
  pInvitationData = tInvitationData
  me.showPendingInvitation()
  exit
end

on clearFriendRequestsFromStack(me)
  me.hideFriendRequest()
  me.showPendingInvitation()
  exit
end

on showPendingInvitation(me)
  if pVisibleItem <> void() then
    return(0)
  end if
  if pInvitationData.count < 1 then
    return(0)
  end if
  tInvitationObj = createObject(pVisibleItemID, pRoomInvitationClass)
  tInvitationObj.show(pInvitationData, pBottomBarId, "int_messenger_image")
  pVisibleItem = #invitation
  return(1)
  exit
end

on showPendingInstantFriendRequest(me)
  if not pShowInstantFriendRequests then
    return(0)
  end if
  if not voidp(pVisibleItem) and not pVisibleItem = #friendrequest then
    return(0)
  end if
  if not threadExists(#messenger) then
    return(0)
  end if
  if not windowExists(pBottomBarId) then
    return(0)
  end if
  tMessengerComponent = getThread(#messenger).getComponent()
  tMessengerInterface = getThread(#messenger).getInterface()
  if tMessengerInterface.isMessengerOpen() then
    return(0)
  end if
  tPendingRequest = tMessengerComponent.getNextPendingInstantBuddyRequest()
  if listp(tPendingRequest) then
    createObject(pVisibleItemID, pFriendRequestClass)
    tObj = getObject(pVisibleItemID)
    tObj.define(pBottomBarId, "int_messenger_image", tPendingRequest, me.getID())
    tObj.show()
    pFriendRequestData = tPendingRequest
    pVisibleItem = #friendrequest
    return(1)
  else
    me.hideFriendRequest()
  end if
  return(0)
  exit
end

on ignoreInstantFriendRequests(me)
  pShowInstantFriendRequests = 0
  me.hideFriendRequest()
  me.showPendingInvitation()
  exit
end

on viewNextItemInStack(me)
  tFrShown = me.showPendingInstantFriendRequest()
  if not tFrShown then
    me.showPendingInvitation()
  end if
  exit
end

on confirmFriendRequest(me, tAccept)
  if threadExists(#messenger) then
    tMessengerComponent = getThread(#messenger).getComponent()
    tMessengerInterface = getThread(#messenger).getInterface()
    tRequestId = pFriendRequestData.getAt(#id)
    if tAccept then
      if tMessengerInterface.getFriendRequestRenderer().isBuddyListFull() then
        executeMessage(#alert, "console_fr_limit_exceeded_error")
        me.hideFriendRequest()
        return(0)
      end if
      tMessengerComponent.acceptRequest(tRequestId)
    else
      tMessengerComponent.declineRequest(tRequestId)
    end if
  end if
  tMessengerComponent.clearRequests()
  me.hideFriendRequest()
  exit
end

on acceptInvitation(me)
  tSenderId = pInvitationData.getaProp(#userID)
  if voidp(tSenderId) then
    return(0)
  end if
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MSG_ACCEPT_TUTOR_INVITATION", [#string:tSenderId])
  end if
  me.hideInvitation()
  exit
end

on rejectInvitation(me)
  tSenderId = pInvitationData.getaProp(#userID)
  if voidp(tSenderId) then
    return(0)
  end if
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MSG_REJECT_TUTOR_INVITATION", [#string:tSenderId])
  end if
  me.hideInvitation()
  createTimeout(#room_bar_extension_next_update, 1000, #viewNextItemInStack, me.getID(), void(), 1)
  exit
end

on hideInvitation(me)
  if pVisibleItem = #invitation then
    removeObject(pVisibleItemID)
    pVisibleItem = void()
  end if
  pInvitationData = []
  exit
end

on hideFriendRequest(me)
  if pVisibleItem = #friendrequest then
    removeObject(pVisibleItemID)
    pVisibleItem = void()
  end if
  pFriendRequestData = []
  exit
end

on invitationFollowFailed(me)
  executeMessage(#alert, "invitation_follow_failed")
  exit
end