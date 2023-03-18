on exitFrame
  global gEPConnectionOk, gEPConnectionsSecured, gGoTo, gLoginName, gLoginPw
  if (gEPConnectionOk = 0) or (gEPConnectionsSecured = 0) then
    go(marker(0))
  else
    if gGoTo = "login" then
      epLogin(gLoginName, gLoginPw)
      goMovie("habbo_entry", "hotel")
    end if
  end if
end
