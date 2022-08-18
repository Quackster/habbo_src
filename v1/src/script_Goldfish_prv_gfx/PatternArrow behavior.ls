property part, direction

on mouseUp me 
  oldvalue = getaProp(gWallsAndFloor, symbol(part & "Pattern"))
  checkField = part & "pattern_patterns"
  if (direction = 1) then
    if oldvalue < the number of line in member(checkField).text then
      setaProp(gWallsAndFloor, symbol(part & "Pattern"), (oldvalue + 1))
    else
      setaProp(gWallsAndFloor, symbol(part & "Pattern"), 1)
    end if
  else
    if oldvalue > 1 then
      setaProp(gWallsAndFloor, symbol(part & "Pattern"), (oldvalue - 1))
    else
      setaProp(gWallsAndFloor, symbol(part & "Pattern"), the number of line in member(checkField).text)
    end if
  end if
  setaProp(gWallsAndFloor, symbol(part & "Color"), 1)
  i = 1
  repeat while i <= getaProp(gWallsAndFloor, part & "Sprites").count
    sendSprite(getAt(getaProp(gWallsAndFloor, symbol(part & "Sprites")), i), #update)
    i = (1 + i)
  end repeat
  updateCode(me)
end

on beginSprite me 
  updateCode(me)
end

on updateCode me 
  save = the itemDelimiter
  the itemDelimiter = ","
  checkField = member(part & "Pattern_patterns").text.line[getaProp(gWallsAndFloor, part & "Pattern")]
  if (part = "wall") then
    smsCodeLetter = "T"
  else
    if (part = "floor") then
      smsCodeLetter = "L"
    end if
  end if
  
  the itemDelimiter = save
end

on getPropertyDescriptionList me 
  return([#direction:[#comment:"forward?", #format:#boolean, #default:"true"], #part:[#comment:"Part", #format:#string, #default:"wall"]])
end
