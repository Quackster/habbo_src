on openHelp  
  gHelpPlace = point(0, 40)
  if PurseAndHelpContext <> void() then
    if PurseAndHelpContext.frame contains "helpLinks" then
      closePurseOrHelp()
    end if
  end if
  if PurseAndHelpContext <> void() then
    closePurseOrHelp()
  end if
  if not the movieName contains "entry" then
    PurseAndHelpContext = new(script("PopUp Context Class"), 2130000000, 851, 870, gHelpPlace)
  else
    PurseAndHelpContext = new(script("PopUp Context Class"), 2130000000, 851, 870, gHelpPlace)
  end if
  displayFrame(PurseAndHelpContext, "helpLinks")
end

on openPurse  
  gHelpPlace = point(0, 40)
  if PurseAndHelpContext <> void() then
    if PurseAndHelpContext.frame contains "purse" then
      closePurseOrHelp()
    end if
  end if
  if PurseAndHelpContext <> void() then
    closePurseOrHelp()
  end if
  if not the movieName contains "entry" then
    PurseAndHelpContext = new(script("PopUp Context Class"), 2130000000, 851, 870, gHelpPlace)
  else
    PurseAndHelpContext = new(script("PopUp Context Class"), 2130000000, 851, 870, gHelpPlace)
  end if
  displayFrame(PurseAndHelpContext, "purse")
end

on closePurseOrHelp  
  close(PurseAndHelpContext)
  PurseAndHelpContext = void()
end

on OpenPickCryForHelp  
  PurseAndHelpContext = void()
  gHelpPlace = point(0, 40)
  sprite(870).locH = 2000
  if not the movieName contains "entry" then
    PurseAndHelpContext = new(script("PopUp Context Class"), 2130000000, 851, 870, gHelpPlace)
  else
    PurseAndHelpContext = new(script("PopUp Context Class"), 2130000000, 851, 870, gHelpPlace)
  end if
  displayFrame(PurseAndHelpContext, "hobba_alert")
end
