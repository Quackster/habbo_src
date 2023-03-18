on exitFrame
  global gEPConnectionOk, gEPConnectionsSecured, gGoTo, gEPConnectionInstance
  if (gEPConnectionOk = 0) or (gEPConnectionsSecured = 0) then
    goContext(the frame)
  else
    sendEPFuseMsg("AUTOLOGINCLIENTIP" && GetNetAddressCookie(gEPConnectionInstance, 0))
  end if
end
