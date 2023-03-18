global FirstPlaceNow, gTop10SearchSprite, gTop10FirstInit

on beginSprite me
  FirstPlaceNow = 0
end

on UpdateBusyFlats me
  sendEPFuseMsg("SEARCHBUSYFLATS /" & FirstPlaceNow & ",11")
end

on mouseUp me
  FirstPlaceNow = 0
  put "SEARCHBUSYFLATS /" & FirstPlaceNow & ",11"
  sendEPFuseMsg("SEARCHBUSYFLATS /" & FirstPlaceNow & ",11")
end
