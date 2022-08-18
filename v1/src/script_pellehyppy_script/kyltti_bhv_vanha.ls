property status, w, h, OldPosH, OldPosV, bgImage

on beginSprite me
  status = "closed"
  w = 32
  h = 17
  OldPosH = 0
  OldPosV = 0
  bgImage = image(16, member(getmemnum("kylttiOff")).width, member(getmemnum("kylttiOff")).height)
  bgImage = member("kylttiOff").image.duplicate()
end

on mouseDown me
  if (status = "closed") then
    status = "open"
    sprite(me.spriteNum).member = getmemnum("kylttiOff")
  end if
end

on mouseUp me
end

on mouseWithin me
  if (status = "open") then
    if (((the mouseV - sprite(me.spriteNum).top) / h) < 6) then
      if ((OldPosH <> ((the mouseH - sprite(me.spriteNum).left) / w)) or (OldPosV <> ((the mouseV - sprite(me.spriteNum).top) / h))) then
        put ((the mouseH - sprite(me.spriteNum).left) / w), ((the mouseV - sprite(me.spriteNum).top) / h)
        OldPosH = ((the mouseH - sprite(me.spriteNum).left) / w)
        OldPosV = ((the mouseV - sprite(me.spriteNum).top) / h)
        member("kylttiOff").image.copyPixels(bgImage, bgImage.rect, bgImage.rect)
        whichX = ((the mouseH - sprite(me.spriteNum).left) / w)
        whichY = ((the mouseV - sprite(me.spriteNum).top) / h)
        r = rect((w * whichX), (h * whichY), ((w * whichX) + w), ((h * whichY) + h))
        member(getmemnum("kylttiOff")).image.copyPixels(member("kylttiOn").image, r, r)
      end if
    end if
  end if
end

on mouseLeave me
  status = "closed"
  member("kylttiOff").image.copyPixels(bgImage, bgImage.rect, bgImage.rect)
  sprite(me.spriteNum).member = "kyltti"
end
