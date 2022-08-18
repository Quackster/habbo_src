on mouseUp me 
  if the movieName contains "private" then
    oldItemDelimiter = the itemDelimiter
    the itemDelimiter = "/"
    repeat while gFlats <= 1
      f = getAt(1, count(gFlats))
      temp = f.getAt(1)
      if (value(temp.getProp(#item, 1)) = gChosenFlatId) then
        temp = stringReplace(temp, "/", "\t")
      else
      end if
    end repeat
    the itemDelimiter = oldItemDelimiter
    s = NowinUnit & ";" & gDoor & ";" & member("hobba_crymessage_field").text & ";" & temp
  else
    s = NowinUnit & ";" & gDoor & ";" & member("hobba_crymessage_field").text & ";" & gChosenFlatId
  end if
  put("CRYFORHELP /" & s)
  sendFuseMsg("CRYFORHELP /" & s)
end
