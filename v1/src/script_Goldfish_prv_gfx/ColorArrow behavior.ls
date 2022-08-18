property direction, part
global gWallsAndFloor

on mouseUp me
  oldvalue = getaProp(gWallsAndFloor, symbol((part & "Color")))
  checkField = line getaProp(gWallsAndFloor, (part & "Pattern")) of the text of member((part & "Pattern_patterns"))
  if (direction = 1) then
    if (oldvalue < the number of lines in the text of member(checkField)) then
      setaProp(gWallsAndFloor, symbol((part & "Color")), (oldvalue + 1))
    else
      setaProp(gWallsAndFloor, symbol((part & "Color")), 1)
    end if
  else
    if (oldvalue > 1) then
      setaProp(gWallsAndFloor, symbol((part & "Color")), (oldvalue - 1))
    else
      setaProp(gWallsAndFloor, symbol((part & "Color")), the number of lines in the text of member(checkField))
    end if
  end if
  repeat with i = 1 to getaProp(gWallsAndFloor, (part & "Sprites")).count
    sendSprite(getAt(getaProp(gWallsAndFloor, symbol((part & "Sprites"))), i), #update)
  end repeat
  updateCode(me)
end

on beginSprite me
  updateCode(me)
end

on updateCode me
  save = the itemDelimiter
  the itemDelimiter = ","
  checkField = line getaProp(gWallsAndFloor, (part & "Pattern")) of the text of member((part & "Pattern_patterns"))
  case part of
    "wall":
      smsCodeLetter = "T"
    "floor":
      smsCodeLetter = "L"
  end case
  set the text of field (part & "_smscode") to (("A2 " & smsCodeLetter) && item 6 of field checkField)
  the itemDelimiter = save
end

on getPropertyDescriptionList me
  return [#direction: [#comment: "forward?", #format: #boolean, #default: "true"], #part: [#comment: "Part", #format: #string, #default: "wall"]]
end
