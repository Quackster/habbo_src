on mouseUp me
  global gMyName, gPopUpContext2
  sendEPFuseMsg("SEARCHFLATFORUSER /" & gMyName)
  sFrame = "private_places"
  goContext(sFrame, gPopUpContext2)
end
