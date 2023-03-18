property spriteNum

on exitFrame me
  if the keyboardFocusSprite = me.spriteNum then
    the keyboardFocusSprite = 0
  end if
end
