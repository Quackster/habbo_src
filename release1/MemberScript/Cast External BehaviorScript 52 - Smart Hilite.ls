on beginSprite me
end

on mouseEnter me
  set the castNum of sprite the spriteNum of me to the number of member (word 1 of the name of the member of sprite the spriteNum of me && "hi")
end

on mouseLeave me
  set the castNum of sprite the spriteNum of me to the number of member word 1 of the name of the member of sprite the spriteNum of me
end
