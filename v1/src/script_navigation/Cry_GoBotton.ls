on mouseDown me
  global CryHelp, CryCount, gPopUpContext2, gChosenFlatId, gFlats, gUnits, gChosenUnitIp, gChosenUnitPort, gDoor
  closePurseOrHelp()
  if (gPopUpContext2 = VOID) then
    openNavigator()
  end if
  sendEPFuseMsg(("PICK_CRYFORHELP" && CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("url")))
  if ((CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("CryPrivate") <> EMPTY) or (CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("CryPrivate") contains "private")) then
    oldItemDelimiter = the itemDelimiter
    gFlats = []
    temp = []
    temp.add(CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("CryPrivate"))
    gFlats.add(temp)
    gChosenFlatId = value(CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("CryPrivate").item[1])
    the itemDelimiter = oldItemDelimiter
    put gFlats, gChosenFlatId
    openFlatInfo(1)
    GoToFlatWithNavi(gChosenFlatId)
  else
    if ((CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("Unit") <> VOID) and (CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("Unit") <> VOID)) then
      unitName = CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("Unit")
      gDoor = CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("gDoor")
      host = gUnits.getaProp(unitName).getaProp("host")
      gChosenUnitIp = char (offset("/", host) + 1) to host.length of host
      gChosenUnitPort = gUnits.getaProp(unitName).getaProp("port")
      put host, gChosenUnitIp, gChosenUnitPort
      goUnit(gUnits.getaProp(unitName).getaProp("name"), gDoor)
    end if
  end if
end
