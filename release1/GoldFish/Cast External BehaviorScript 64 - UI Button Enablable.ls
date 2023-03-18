property enabled, buttonType, origmem, type, helptext_disabled, helpText_enabled
global gpUiButtons

on beginSprite me
  helpText_enabled = AddTextToField(helpText_enabled)
  helptext_disabled = AddTextToField(helptext_disabled)
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
  if (type = "blend") or voidp(type) then
    sprite(me.spriteNum).blend = 100
  end if
  if type = "visible" then
    sprite(me.spriteNum).visible = 1
  end if
end

on disable me
  if type <> "dance" then
    set the castNum of sprite the spriteNum of me to origmem
  end if
  enabled = 0
  if (type = "blend") or voidp(type) then
    sprite(me.spriteNum).blend = 30
  end if
  if type = "visible" then
    sprite(me.spriteNum).visible = 0
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #enabled, [#format: #boolean, #default: 0, #comment: "Default enabled"])
  addProp(pList, #buttonType, [#format: #string, #default: "rotate", #comment: "Type"])
  addProp(pList, #type, [#format: #string, #default: "blend", #range: ["blend", "visible"], #comment: "Enable type"])
  addProp(pList, #helpText_enabled, [#format: #string, #default: EMPTY, #comment: "Enabled helptext"])
  addProp(pList, #helptext_disabled, [#format: #string, #default: EMPTY, #comment: "Disabled helptext"])
  return pList
end

on mouseEnter me
  if enabled then
    helpText_setText(helpText_enabled)
  else
    helpText_setText(helptext_disabled)
  end if
  if not enabled then
    return 
  end if
end

on mouseLeave me
  if enabled then
    helpText_empty(helpText_enabled)
  else
    helpText_empty(helptext_disabled)
  end if
  if not enabled then
    return 
  end if
end
