property buttonType, enabled, type, origmem, helpText_enabled, helptext_disabled

on beginSprite me 
  if voidp(gpUiButtons) then
    gpUiButtons = [:]
  end if
  setaProp(gpUiButtons, buttonType, me.spriteNum)
  origmem = sprite(me.spriteNum).castNum
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
  if (type = "visible") then
    sprite(me.spriteNum).visible = 1
  end if
end

on disable me 
  sprite(me.spriteNum).castNum = origmem
  enabled = 0
  if (type = "blend") or voidp(type) then
    sprite(me.spriteNum).blend = 30
  end if
  if (type = "visible") then
    sprite(me.spriteNum).visible = 0
  end if
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #enabled, [#format:#boolean, #default:0, #comment:"Default enabled"])
  addProp(pList, #buttonType, [#format:#string, #default:"rotate", #comment:"Type"])
  addProp(pList, #type, [#format:#string, #default:"blend", #range:["blend", "visible"], #comment:"Enable type"])
  addProp(pList, #helpText_enabled, [#format:#string, #default:"", #comment:"Enabled helptext"])
  addProp(pList, #helptext_disabled, [#format:#string, #default:"", #comment:"Disabled helptext"])
  return(pList)
end

on mouseEnter me 
  if enabled then
    helpText_setText(helpText_enabled)
  else
    helpText_setText(helptext_disabled)
  end if
  if not enabled then
    return()
  end if
  sprite(me.spriteNum).castNum = (origmem + 1)
end

on mouseLeave me 
  if enabled then
    helpText_empty(helpText_enabled)
  else
    helpText_empty(helptext_disabled)
  end if
  if not enabled then
    return()
  end if
  sprite(me.spriteNum).castNum = origmem
end
