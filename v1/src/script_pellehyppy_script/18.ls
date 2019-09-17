on beginSprite me 
  iSpr = me.spriteNum
  sprite(sprite(0).number).cursor = ["cursor_arrow_l_mask", sprite(0).number]
end

on endSprite me 
  iSpr = me.spriteNum
  sprite(iSpr).cursor = 0
end
