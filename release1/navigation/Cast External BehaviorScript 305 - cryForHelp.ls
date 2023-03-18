global gDoor, NowinUnit, gChosenFlatId, gFlats

on mouseUp me
  if the movieName contains "private" then
    oldItemDelimiter = the itemDelimiter
    the itemDelimiter = "/"
    repeat with f in gFlats
      temp = f[1]
      if value(temp.item[1]) = gChosenFlatId then
        temp = stringReplace(temp, "/", TAB)
        exit repeat
      end if
    end repeat
    the itemDelimiter = oldItemDelimiter
    s = NowinUnit & ";" & gDoor & ";" & member("hobba_crymessage_field").text & ";" & temp
  else
    s = NowinUnit & ";" & gDoor & ";" & member("hobba_crymessage_field").text & ";" & gChosenFlatId
  end if
  put "CRYFORHELP /" & s
  sendFuseMsg("CRYFORHELP /" & s)
end
