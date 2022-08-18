on beginSprite me
  iSpr = me.spriteNum
  set the cursor of sprite iSpr to [the number of member "cursor_arrow_l", the number of member "cursor_arrow_l_mask"]
end

on endSprite me
  iSpr = me.spriteNum
  set the cursor of sprite iSpr to 0
end
