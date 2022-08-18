on beginSprite me
  if not (the movieName contains "uimakoppi") then
    sprite(me.spriteNum).flipH = 1
  end if
end

on endSprite me
  if not (the movieName contains "uimakoppi") then
    sprite(me.spriteNum).flipH = 0
  end if
end
