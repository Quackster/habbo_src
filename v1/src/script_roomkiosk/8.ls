on mouseUp me 
  gFloor = 111
  gWallPaper = 201
  if gProps.getAt(#showOwnerName) = 1 then
    gChosenFlatOwner = member("roomkiosk.owner_name").text
  end if
  gFlatLetIn = 0
  member("flat_load.status").text = ""
  gConnectionInstance = 0
  gChosenUnitIp = gFloorHost
  gChosenUnitPort = integer(gFloorPort)
  Logon()
  gFlatWaitStart = the milliSeconds
  put("gChosenFlatId:" && gChosenFlatId)
  put("gChosenUnitIp:" && gChosenUnitIp)
  put("gFlatLetIn:" && gFlatLetIn)
end
