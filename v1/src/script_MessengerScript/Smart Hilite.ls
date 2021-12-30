on beginSprite me 
end

on mouseEnter me 
  sprite(sprite(me.spriteNum).undefined.name.word[1] && "hi").castNum = sprite(0).number
end

on mouseLeave me 
  sprite(sprite(me.spriteNum).undefined.name.word[1]).castNum = sprite(0).number
end
