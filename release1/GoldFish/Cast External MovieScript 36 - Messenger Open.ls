global gPopUpContext, gMessengerPlace, gMessengerLastLoc, gPopUpContext2

on openMessenger
  global gOldpersistentmessage, gBuddyList
  if voidp(gMessengerPlace) then
    gMessengerPlace = point(300, 100)
  end if
  if gPopUpContext <> VOID then
    closeMessenger()
    exit
  end if
  if getAt(gMessengerPlace, 1) < 0 then
    gMessengerPlace = point(300, 100)
  end if
  if not (the movieName contains "entry") then
    if gPopUpContext2 <> VOID then
      closeNavigator(1)
    end if
    gPopUpContext = new(script("PopUp Context Class"), 2110000000, 660, 710, gMessengerPlace)
  else
    gPopUpContext = new(script("PopUp Context Class"), 2110000000, 380, 430, gMessengerPlace)
  end if
  if the movieName contains "entry" then
    spr1 = 381
  else
    spr1 = 661
  end if
  gOldpersistentmessage = member("messenger.my_persistent_message").text
  displayFrame(gPopUpContext, "main")
  update(gBuddyList)
  gMessengerLastLoc = sprite(spr1).loc
end

on closeMessenger NotFullClose
  put "close Messenger", "NotFullClose" && NotFullClose
  if the movieName contains "entry" then
    spr1 = 381
  else
    spr1 = 661
  end if
  gMessengerPlace = sprite(spr1).loc - gMessengerLastLoc + gMessengerPlace
  close(gPopUpContext)
  gPopUpContext = VOID
end
