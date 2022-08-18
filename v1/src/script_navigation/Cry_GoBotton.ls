on mouseDown me 
  closePurseOrHelp()
  if (gPopUpContext2 = void()) then
    openNavigator()
  end if
  sendEPFuseMsg("PICK_CRYFORHELP" && CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("url"))
  if CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("CryPrivate") <> "" or CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("CryPrivate") contains "private" then
    oldItemDelimiter = the itemDelimiter
    gFlats = []
    temp = []
    temp.add(CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("CryPrivate"))
    gFlats.add(temp)
    gChosenFlatId = value(CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("CryPrivate").getProp(#item, 1))
    the itemDelimiter = oldItemDelimiter
    put(gFlats, gChosenFlatId)
    openFlatInfo(1)
    GoToFlatWithNavi(gChosenFlatId)
  else
    if CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("Unit") <> void() and CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("Unit") <> void() then
      unitName = CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("Unit")
      gDoor = CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("gDoor")
      host = gUnits.getaProp(unitName).getaProp("host")
      gChosenUnitIp = host.char[(offset("/", host) + 1)..host.length]
      gChosenUnitPort = gUnits.getaProp(unitName).getaProp("port")
      put(host, gChosenUnitIp, gChosenUnitPort)
      goUnit(gUnits.getaProp(unitName).getaProp("name"), gDoor)
    end if
  end if
end
