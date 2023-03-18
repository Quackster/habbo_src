property origmem

on beginSprite me
  origmem = the castNum of sprite me.spriteNum
end

on mouseEnter me
  set the castNum of sprite the spriteNum of me to origmem + 1
end

on mouseLeave me
  set the castNum of sprite the spriteNum of me to origmem
end
