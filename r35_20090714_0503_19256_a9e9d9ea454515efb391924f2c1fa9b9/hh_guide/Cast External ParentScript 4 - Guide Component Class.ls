property pState, pInvitationData

on construct me
  pState = #disabled
  pInvitationData = [:]
  registerMessage(#userlogin, me.getID(), #Init)
  registerMessage(#showInvitation, me.getID(), #setInvitation)
  return 1
end

on deconstruct me
  unregisterMessage(#userlogin, me.getID(), #Init)
  unregisterMessage(#showInvitation, me.getID(), #setInvitation)
  return 1
end

on setInvitation me, tInvitationData
  if tInvitationData.ilk <> #propList then
    tInvitationData = [:]
  end if
  pInvitationData = tInvitationData
  me.setState(#ready)
end

on getInvitation me
  return pInvitationData
end

on cancelInvitation me
  pInvitationData = [:]
  me.setState(#waiting)
end

on getState me
  return pState
end

on setState me, tstate
  if tstate = pState then
    return 1
  end if
  pState = tstate
  me.getInterface().update()
end

on Init me
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MSG_INIT_TUTORSERVICE")
  end if
end

on startWaiting me
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MSG_WAIT_FOR_TUTOR_INVITATIONS")
  end if
  me.setState(#waiting)
end

on cancelWaiting me
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MSG_CANCEL_WAIT_FOR_TUTOR_INVITATIONS")
  end if
  me.setState(#enabled)
end

on acceptInvitation me
  if ilk(pInvitationData) <> #propList then
    return 0
  end if
  tSenderId = pInvitationData.getaProp(#userID)
  if voidp(tSenderId) then
    return 0
  end if
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MSG_ACCEPT_TUTOR_INVITATION", [#string: tSenderId])
  end if
  me.setState(#enabled)
end

on rejectInvitation me
  tSenderId = pInvitationData.getaProp(#userID)
  if voidp(tSenderId) then
    return 0
  end if
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MSG_REJECT_TUTOR_INVITATION", [#string: tSenderId])
  end if
  me.setState(#enabled)
end
