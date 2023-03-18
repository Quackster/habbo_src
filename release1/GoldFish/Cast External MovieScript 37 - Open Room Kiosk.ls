global gPopUpContext, gRoomkioskPlace, gRoomkioskLastLoc, gMyName

on openRoomkiosk
  if voidp(gRoomkioskPlace) then
    gRoomkioskPlace = point(0, 0)
  end if
  put EMPTY into field "roomkiosk.roomname"
  put EMPTY into field "roomkiosk.description"
  put gMyName into field "roomkiosk.owner_name"
  if objectp(gPopUpContext) then
    close(gPopUpContext)
  end if
  if not (the movieName contains "entry") then
    gPopUpContext = new(script("PopUp Context Class"), 2000000000, 660, 710, gRoomkioskPlace)
  else
    gPopUpContext = new(script("PopUp Context Class"), 2000000000, 380, 430, gRoomkioskPlace)
  end if
  if the movieName contains "entry" then
    spr1 = 381
  else
    spr1 = 661
  end if
  displayFrame(gPopUpContext, "start")
  gRoomkioskLastLoc = sprite(spr1).loc
end

on closeRoomkiosk
  if the movieName contains "entry" then
    spr1 = 381
  else
    spr1 = 661
  end if
  gRoomkioskPlace = sprite(spr1).loc - gRoomkioskLastLoc + gRoomkioskPlace
  close(gPopUpContext)
end

on openSplashKiosk
  global gSplashKioskOpenTime
  gSplashKioskOpenTime = the ticks
  gPopUpContext = new(script("PopUp Context Class"), 2000000000, 660, 710, point(0, 0))
  displayFrame(gPopUpContext, "sp_main")
end
