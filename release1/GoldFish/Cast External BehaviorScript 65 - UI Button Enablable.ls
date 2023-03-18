property enabled, buttonType, origmem
global gpUiButtons

on beginSprite me
  if voidp(gpUiButtons) then
    gpUiButtons = [:]
  end if
  setaProp(gpUiButtons, buttonType, me.spriteNum)
  origmem = the castNum of sprite me.spriteNum
  if enabled then
    enable(me)
  else
    disable(me)
  end if
end

on enable me
  enabled = 1
  sprite(me.spriteNum).blend = 100
end

on disable me
  set the castNum of sprite the spriteNum of me to origmem
  enabled = 0
  sprite(me.spriteNum).blend = 30
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #enabled, [#format: #boolean, #default: 0, #comment: "Default enabled"])
  addProp(pList, #buttonType, [#format: #string, #default: "rotate", #comment: "Type"])
  return pList
end

on mouseEnter me
  if not enabled then
    return 
  end if
  set the castNum of sprite the spriteNum of me to origmem + 1
end

on mouseLeave me
  if not enabled then
    return 
  end if
  set the castNum of sprite the spriteNum of me to origmem
end
