on exitFrame  
  if (gConnectionOk = 0) or (gConnectionsSecured = 0) then
    gLogin = 0
  else
    if (gLogin = 0) then
      gLogin = 1
      fuseLogin(gLoginName, gLoginPw, 1)
      if gChosenFlatDoorMode <> "x" then
      end if
      put("flatpassword.nav" & field(0))
      sendFuseMsg("flatpassword.nav" & field(0))
    end if
  end if
end
