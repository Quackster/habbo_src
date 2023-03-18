global gProps, gChosenFlatId

on mouseUp me
  global gFlatWaitStart, gFloorHost, gFloorPort, gFloor, gWallPaper, gChosenFlatId, gChosenFlatOwner, gFlatLetIn, gConnectionInstance, gChosenUnitIp, gChosenUnitPort
  gFloor = 111
  gWallPaper = 201
  if gProps[#showOwnerName] = 1 then
    gChosenFlatOwner = member("roomkiosk.owner_name").text
  end if
  gFlatLetIn = 0
  member("flat_load.status").text = EMPTY
  gConnectionInstance = 0
  gChosenUnitIp = gFloorHost
  gChosenUnitPort = integer(gFloorPort)
  Logon()
  gFlatWaitStart = the milliSeconds
  put "gChosenFlatId:" && gChosenFlatId
  put "gChosenUnitIp:" && gChosenUnitIp
  put "gFlatLetIn:" && gFlatLetIn
end
