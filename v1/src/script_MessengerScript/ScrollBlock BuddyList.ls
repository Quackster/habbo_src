property scrollOn, vOffset, b
global gBuddyList, gBLScrollBlockSpr, gBLScrollBarSpr

on beginSprite me
  sprite(me.spriteNum).visible = 0
  gBLScrollBlockSpr = me.spriteNum
  b = 1
end

on exitFrame me
  if b then
    update(gBuddyList)
    b = 0
  end if
  vOffset = (sprite(me.spriteNum).locV - sprite(me.spriteNum).top)
  if (scrollOn and the mouseDown) then
    nv = the mouseV
    if (nv < ((sprite(gBLScrollBarSpr).top + vOffset) + 2)) then
      nv = ((sprite(gBLScrollBarSpr).top + vOffset) + 2)
    end if
    if (nv > ((sprite(gBLScrollBarSpr).bottom - (sprite(me.spriteNum).height / 2)) - 2)) then
      nv = ((sprite(gBLScrollBarSpr).bottom - (sprite(me.spriteNum).height / 2)) - 2)
    end if
    sprite(me.spriteNum).locV = nv
  else
    nv = sprite(me.spriteNum).locV
    if scrollOn then
      scroll(gBuddyList, ((((nv - vOffset) - (sprite(gBLScrollBarSpr).locV - (sprite(gBLScrollBarSpr).height / 2))) * 1.0) / ((sprite(gBLScrollBarSpr).height - 28) - (vOffset * 2))))
    end if
    scrollOn = 0
  end if
end

on mouseDown me
  scrollOn = 1
end

on update me, f
  vOffset = sprite(me.spriteNum).member.regPoint[2]
  sprite(me.spriteNum).visible = 1
  nv = integer((((sprite(gBLScrollBarSpr).locV - (sprite(gBLScrollBarSpr).height / 2)) + vOffset) + (f * ((sprite(gBLScrollBarSpr).height - 1) - (vOffset * 2)))))
  if (nv > ((sprite(gBLScrollBarSpr).bottom - (sprite(me.spriteNum).height / 2)) - 2)) then
    nv = ((sprite(gBLScrollBarSpr).bottom - (sprite(me.spriteNum).height / 2)) - 2)
  end if
  sprite(me.spriteNum).locV = nv
end
