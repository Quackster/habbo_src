property isEnabled, sEnableText, sDisableText, lastText

on beginSprite me 
  if (isEnabled = 0) then
    sendSprite(me.spriteNum, #disable)
  else
    sendSprite(me.spriteNum, #enable)
  end if
end

on mouseEnter me 
  if isEnabled then
    s = sEnableText
  else
    s = sDisableText
  end if
  helpText_setText(s)
  lastText = s
end

on mouseLeave me 
  helpText_empty(lastText)
end

on disable me 
  isEnabled = 0
  sprite(me.spriteNum).undefined = 20
end

on enable me 
  isEnabled = 1
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #sEnableText, [#format:#string, #default:"", #comment:"Help text when enabled"])
  addProp(pList, #sDisableText, [#format:#string, #default:"", #comment:"Help text when disabled"])
  addProp(pList, #isEnabled, [#format:#boolean, #default:1, #comment:"Enabled"])
  return(pList)
end
