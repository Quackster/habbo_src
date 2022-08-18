on beginSprite me
  sprite(me.spriteNum).blend = 0
  iSpr = me.spriteNum
  set the cursor of sprite iSpr to [the number of member "cursor_cross", the number of member "cursor_cross_mask"]
end

on endSprite me
  iSpr = me.spriteNum
  set the cursor of sprite iSpr to 0
end

on mouseLeave me
end

on mouseWithin me
end

on mouseUp me
end

on mouseDown me
end
