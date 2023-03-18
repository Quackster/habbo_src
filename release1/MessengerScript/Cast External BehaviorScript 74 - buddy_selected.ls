global buddySelectHiSpr

on beginSprite me
  buddySelectHiSpr = me.spriteNum
  sprite(me.spriteNum).visible = 0
end

on BuddySelectSwap me, HiliterlocY
  if (HiliterlocY <> VOID) or (HiliterlocY <> "HIDE") then
    sprite(me.spriteNum).locV = HiliterlocY - 2
  end if
  if sprite(me.spriteNum).visible = 0 then
    sprite(me.spriteNum).visible = 1
  else
    sprite(me.spriteNum).visible = 0
  end if
end
