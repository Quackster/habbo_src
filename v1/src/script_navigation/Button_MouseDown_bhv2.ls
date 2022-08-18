on mouseWithin me 
  if the mouseDown and (sprite(me.spriteNum).member.name.word[2] = "active") then
    if (sprite(me.spriteNum).member.name.word[2] = "active") then
      sprite(me.spriteNum).member = sprite(me.spriteNum).member.name.word[1] && "hi"
    end if
  end if
end

on mouseLeave me 
  if (sprite(me.spriteNum).member.name.word[2] = "hi") then
    sprite(me.spriteNum).member = sprite(me.spriteNum).member.name.word[1] && "active"
  end if
end
