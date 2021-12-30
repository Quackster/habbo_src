property origXoffset, origYoffset

on beginSprite me 
  checkOffsets()
  origXoffset = xoffset
  origYoffset = yoffset
end

on updateLocation me 
  sprite(me.spriteNum).locH = (sprite(me.spriteNum).locH + (xoffset - origXoffset))
  sprite(me.spriteNum).locV = (sprite(me.spriteNum).locV + (yoffset - origYoffset))
  origXoffset = xoffset
  origYoffset = yoffset
end
