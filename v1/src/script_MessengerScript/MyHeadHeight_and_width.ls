property spriteNum

on prepareFrame me
  if ((sprite(me.spriteNum).width <> sprite(me.spriteNum).member.width) or (sprite(me.spriteNum).height <> sprite(me.spriteNum).member.height)) then
    sprite(me.spriteNum).width = sprite(me.spriteNum).member.width
    sprite(me.spriteNum).height = sprite(me.spriteNum).member.height
  end if
end
