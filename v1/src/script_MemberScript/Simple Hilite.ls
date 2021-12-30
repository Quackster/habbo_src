property origmem

on beginSprite me 
  origmem = sprite(me.spriteNum).castNum
end

on mouseEnter me 
  sprite(me.spriteNum).castNum = (origmem + 1)
end

on mouseLeave me 
  sprite(me.spriteNum).castNum = origmem
end
