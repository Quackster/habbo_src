property direction

on mouseUp me
  global CryCount, CryHelp
  if direction = 1 then
    CryCount = CryCount + 1
  else
    CryCount = CryCount - 1
  end if
  if CryCount > count(CryHelp) then
    CryCount = count(CryHelp)
  end if
  if CryCount < 1 then
    CryCount = 1
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #direction, [#comment: "My Direction -1/1.", #format: #integer, #default: 1])
  return pList
end
