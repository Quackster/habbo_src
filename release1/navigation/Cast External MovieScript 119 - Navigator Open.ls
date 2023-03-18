global gPopUpContext2, gNavigatorPlace, gNavigatorLastLoc, gPopUpContext, FirstPlaceNow, gPrivateDropStatus

on openNavigator
  if voidp(gNavigatorPlace) then
    gNavigatorPlace = point(234, -5)
  end if
  if gPopUpContext2 <> VOID then
    closeNavigator()
    exit
  end if
  gPrivateDropStatus = VOID
  FirstPlaceNow = 0
  if not (the movieName contains "entry") then
    if gPopUpContext <> VOID then
      closeMessenger(1)
    end if
    gPopUpContext2 = new(script("PopUp Context Class"), 2100000000, 660, 710, gNavigatorPlace)
  else
    gPopUpContext2 = new(script("PopUp Context Class"), 2100000000, 600, 650, gNavigatorPlace)
  end if
  if not (the movieName contains "entry") then
    spr1 = 661
  else
    spr1 = 601
  end if
  displayFrame(gPopUpContext2, "public")
  gNavigatorLastLoc = sprite(spr1).loc
end

on closeNavigator NotFullClose
  put "close Navigator", "NotFullClose" && NotFullClose
  if the movieName contains "entry" then
    spr1 = 601
  else
    spr1 = 661
  end if
  gNavigatorPlace = sprite(spr1).loc - gNavigatorLastLoc + gNavigatorPlace
  close(gPopUpContext2)
  gPopUpContext2 = VOID
end
