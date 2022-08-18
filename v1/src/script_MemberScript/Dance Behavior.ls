on beginSprite me 
  MeDancing = 0
end

on mouseUp me 
  if not MeDancing then
    sendFuseMsg("STOP CarryDrink")
    sendFuseMsg("Dance")
    sprite(me.spriteNum).undefined = "stopdance_btn active"
    MeDancing = 1
  else
    sendFuseMsg("STOP Dance")
    sprite(me.spriteNum).undefined = "dance_btn active"
    MeDancing = 0
  end if
end

on exitFrame me 
  if objectp(getaProp(gUserSprites, getaProp(gpObjects, gMyName))) then
    if getaProp(gUserSprites, getaProp(gpObjects, gMyName)).dancing then
      sprite(me.spriteNum).undefined = "stopdance_btn active"
      MeDancing = 1
    else
      sprite(me.spriteNum).undefined = "dance_btn active"
      MeDancing = 0
    end if
  end if
end

on mouseWithin me 
  if the mouseDown and (sprite(me.spriteNum).member.name.word[2] = "active") then
    if (sprite(me.spriteNum).member.name.word[2] = "active") then
      sprite(me.spriteNum).castNum = getmemnum(sprite(me.spriteNum).member.name.word[1] && "hi")
    end if
  end if
end

on mouseLeave me 
  if (sprite(me.spriteNum).member.name.word[2] = "hi") then
    sprite(me.spriteNum).castNum = getmemnum(sprite(me.spriteNum).member.name.word[1] && "active")
  end if
end
