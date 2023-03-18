on mouseDown me
  global gProps, gMyName, gPopUpContext2
  if string(getaProp(gProps, #doorMode)) = "password" then
    if field("roompassword") <> field("roompassword2") then
      ShowAlert("CheckPasswords")
      return 
    end if
    if field("roompassword") = EMPTY then
      ShowAlert("ForgotSetPassword")
      return 
    end if
  end if
  updateFlatInfo(me)
  sendEPFuseMsg("SEARCHFLATFORUSER /" & gMyName)
  sFrame = "private_places"
  goContext(sFrame, gPopUpContext2)
end
