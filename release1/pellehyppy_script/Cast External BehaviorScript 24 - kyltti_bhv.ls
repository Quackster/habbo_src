property status, w, h, OldPosH, OldPosV, bgImage

on beginSprite me
  status = "closed"
  w = 40
  h = 17
  OldPosH = 0
  OldPosV = 0
end

on mouseUp me
  if status = "closed" then
    status = "open"
    sprite(me.spriteNum).member = getmemnum("kylttiOff")
  else
    if status = "open" then
      whichX = (the mouseH - sprite(me.spriteNum).left) / w
      whichY = (the mouseV - sprite(me.spriteNum).top + 3) / h
      pSignMode = (whichX * 7) + (whichY + 1)
      if pSignMode > 14 then
        pSignMode = 14
      end if
      sendFuseMsg("Sign " & string(pSignMode))
      status = "closed"
      sprite(me.spriteNum + 1).locH = 1000
      sprite(me.spriteNum).member = "kyltti"
    end if
  end if
end

on mouseWithin me
  if status = "open" then
    if ((the mouseV - sprite(me.spriteNum).top) / h) < 7 then
      if (OldPosH <> ((the mouseH - sprite(me.spriteNum).left) / w)) or (OldPosV <> ((the mouseV - sprite(me.spriteNum).top) / h)) then
        OldPosH = (the mouseH - sprite(me.spriteNum).left) / w
        OldPosV = (the mouseV - sprite(me.spriteNum).top) / h
        whichX = (the mouseH - sprite(me.spriteNum).left) / w
        whichY = (the mouseV - sprite(me.spriteNum).top) / h
        sprite(me.spriteNum + 1).loc = point((40 * whichX) + sprite(me.spriteNum).left + 1, (17 * whichY) + sprite(me.spriteNum).top + 1)
      end if
    end if
  else
    sprite(me.spriteNum + 1).locH = 1000
  end if
end

on mouseLeave me
  status = "closed"
  sprite(me.spriteNum + 1).locH = 1000
  sprite(me.spriteNum).member = "kyltti"
end
