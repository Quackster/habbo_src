property PrepareCheckBoxs, lOtherSprites, enabledCheck, enabled, ecommand, dcommand

on enterFrame me 
  if (PrepareCheckBoxs = void()) then
    PrepareCheckBoxs = 1
    put(gProps, "T�SS�")
    if (gProps = void()) then
      gProps = [:]
    end if
    lOtherSprites = value("[" & lOtherSprites & "]")
    put(enabledCheck, value(enabledCheck))
    enabled = value(enabledCheck)
    if enabled then
      enable(me)
    else
      disable(me)
    end if
  end if
end

on mouseDown me 
  if enabled then
    disable(me)
  else
    enable(me)
  end if
end

on enable me 
  sprite(me.spriteNum).castNum = getmemnum(sprite(me.spriteNum).member.name.word[1] && "on")
  enabled = 1
  repeat while lOtherSprites <= 1
    i = getAt(1, count(lOtherSprites))
    sendSprite((me.spriteNum + i), #disable)
  end repeat
  put(ecommand)
  do(ecommand)
end

on disable me 
  enabled = 0
  sprite(me.spriteNum).castNum = getmemnum(sprite(me.spriteNum).member.name.word[1] && "off")
  if not voidp(dcommand) then
    do(dcommand)
  end if
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #ecommand, [#comment:"Enable command", #default:"setAProp gProps, #x, #y", #format:#string])
  addProp(pList, #dcommand, [#comment:"Disable command", #default:"setAProp gProps, #x, #a", #format:#string])
  addProp(pList, #lOtherSprites, [#comment:"Other sprites of this group (relative)", #default:"1,2", #format:#string])
  addProp(pList, #enabledCheck, [#comment:"Enabled check script", #default:"", #format:#string])
  return(pList)
end
