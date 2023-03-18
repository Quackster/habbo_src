global PurseAndHelpContext

on openHelp
  gHelpPlace = point(0, 40)
  if PurseAndHelpContext <> VOID then
    if PurseAndHelpContext.frame contains "helpLinks" then
      closePurseOrHelp()
      exit
    end if
  end if
  if PurseAndHelpContext <> VOID then
    closePurseOrHelp()
  end if
  if not (the movieName contains "entry") then
    PurseAndHelpContext = new(script("PopUp Context Class"), 2130000000, 851, 870, gHelpPlace)
  else
    PurseAndHelpContext = new(script("PopUp Context Class"), 2130000000, 851, 870, gHelpPlace)
  end if
  displayFrame(PurseAndHelpContext, "helpLinks")
end

on openPurse
  gHelpPlace = point(0, 40)
  if PurseAndHelpContext <> VOID then
    if PurseAndHelpContext.frame contains "purse" then
      closePurseOrHelp()
      exit
    end if
  end if
  if PurseAndHelpContext <> VOID then
    closePurseOrHelp()
  end if
  if not (the movieName contains "entry") then
    PurseAndHelpContext = new(script("PopUp Context Class"), 2130000000, 851, 870, gHelpPlace)
  else
    PurseAndHelpContext = new(script("PopUp Context Class"), 2130000000, 851, 870, gHelpPlace)
  end if
  displayFrame(PurseAndHelpContext, "purse")
end

on closePurseOrHelp
  close(PurseAndHelpContext)
  PurseAndHelpContext = VOID
end

on OpenPickCryForHelp
  PurseAndHelpContext = VOID
  gHelpPlace = point(0, 40)
  sprite(870).locH = 2000
  if not (the movieName contains "entry") then
    PurseAndHelpContext = new(script("PopUp Context Class"), 2130000000, 851, 870, gHelpPlace)
  else
    PurseAndHelpContext = new(script("PopUp Context Class"), 2130000000, 851, 870, gHelpPlace)
  end if
  displayFrame(PurseAndHelpContext, "hobba_alert")
end
