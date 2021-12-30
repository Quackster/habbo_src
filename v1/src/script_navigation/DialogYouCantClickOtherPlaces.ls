on beginSprite me 
  sprite(me.spriteNum).blend = 0
  iSpr = me.spriteNum
  sprite(sprite(0).number).cursor = ["cursor_cross_mask", sprite(0).number]
end

on endSprite me 
  iSpr = me.spriteNum
  sprite(iSpr).cursor = 0
end

on mouseLeave me 
end

on mouseWithin me 
end

on mouseUp me 
end

on mouseDown me 
end
