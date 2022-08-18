on mouseWithin me
  if (the mouseDown and (word 2 of the name of the member of sprite(the spriteNum of me) = "active")) then
    if (word 2 of the name of the member of sprite(the spriteNum of me) = "active") then
      sprite(me.spriteNum).castNum = getmemnum((word 1 of the name of the member of sprite(the spriteNum of me) && "hi"))
    end if
  end if
end

on mouseLeave me
  if (word 2 of the name of the member of sprite(the spriteNum of me) = "hi") then
    sprite(me.spriteNum).castNum = getmemnum((word 1 of the name of the member of sprite(the spriteNum of me) && "active"))
  end if
end
