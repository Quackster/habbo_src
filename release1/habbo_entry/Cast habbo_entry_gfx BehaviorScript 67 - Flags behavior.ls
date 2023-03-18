property pFrame, pWait, pSprite

on beginSprite me
  pSprite = me.spriteNum
  pFrame = 1
  pWait = 3
end

on exitFrame me
  if pWait <= 0 then
    if pFrame <= 6 then
      sprite(pSprite).member = "hotel_flags" & pFrame
      pWait = 3
      pFrame = pFrame + 1
    else
      pFrame = 1
    end if
  else
    pWait = pWait - 1
  end if
end
