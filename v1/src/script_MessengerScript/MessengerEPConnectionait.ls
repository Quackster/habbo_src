on exitFrame  
  if (gEPConnectionOk = 0) or (gEPConnectionsSecured = 0) then
    goContext(the frame)
  else
    sendEPFuseMsg("AUTOLOGINCLIENTIP" && getNetAddressCookie(gEPConnectionInstance, 0))
  end if
end
