on exitFrame  
  if gConnectionOk = 0 or gConnectionsSecured = 0 then
    gLogin = 0
  else
    if gLogin = 0 then
      gLogin = 1
      fuseLogin(gLoginName, gLoginPw, 1)
      if gChosenFlatDoorMode <> "x" then
      end if
      put("flatpassword.nav" & field(0))
      sendFuseMsg("flatpassword.nav" & field(0))
    end if
  end if
  if gChosenFlatDoorMode = "x" and member("flat_load.status").text contains "Room password incorrect" then
    put("Room password incorrect")
    gChosenFlatDoorMode = "password"
    goContext("flat_password_wrong", gPopUpContext2)
    return()
  end if
  go(the frame)
  if gFlatLetIn = 0 then
    member("flatwait.time").text = integer(61000 - the milliSeconds - gFlatWaitStart) / 1000 && "s"
    if 61000 - the milliSeconds - gFlatWaitStart < 0 then
      gConnectionInstance = 0
      goContext("flat_noanswer", gPopUpContext2)
    end if
  end if
end
