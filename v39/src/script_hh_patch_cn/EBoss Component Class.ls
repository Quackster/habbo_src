on construct(me)
  registerMessage(#partnerRegistrationRequired, me.getID(), #partnerRegistrationRequired)
  registerMessage(#partnerRegistration, me.getID(), #partnerRegistration)
  pUserId = ""
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#partnerRegistrationRequired, me.getID())
  unregisterMessage(#partnerRegistration, me.getID())
  return(1)
  exit
end

on login(me)
  if not connectionExists(getVariable("connection.info.id")) then
    executeMessage(#openConnection)
  else
    tConn = getConnection(getVariable("connection.info.id"))
    executeMessage(#performLogin, tConn)
  end if
  exit
end

on handlePartnerRegistration(me, tMsg)
  executeMessage(#hideLogin)
  me.partnerRegistration(tMsg)
  executeMessage(#closeConnection)
  exit
end

on partnerRegistrationRequired(me, tArg)
  tSession = getObject(#session)
  tPartnerRegistration = tSession.GET("conf_partner_integration")
  if ilk(tArg) = #propList then
    tArg.setAt("retval", tPartnerRegistration)
  end if
  return(tPartnerRegistration)
  exit
end

on partnerRegistration(me, tUserID)
  pUserId = tUserID
  me.showDialog()
  exit
end

on showDialog(me)
  me.getInterface().showDialog()
  exit
end

on userID(me)
  return(pUserId)
  exit
end