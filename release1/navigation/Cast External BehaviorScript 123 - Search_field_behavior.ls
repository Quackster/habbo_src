property myOwnStatus
global NaviPrivateSearchSpr

on beginSprite me
  myOwnStatus = 0
  NaviPrivateSearchSpr = me.spriteNum
end

on mouseDown me
  SwapMyStatus(me, 1)
end

on SwapMyStatus me, Stat
  if Stat = 1 then
    myOwnStatus = 1
    sprite(me.spriteNum).editable = 1
    sprite(me.spriteNum).blend = 100
    repeat with f = me.spriteNum down to me.spriteNum - 2
      sprite(f).blend = 100
    end repeat
  else
    myOwnStatus = 0
    sprite(me.spriteNum).editable = 0
    sprite(me.spriteNum).blend = 30
    repeat with f = me.spriteNum down to me.spriteNum - 2
      sprite(f).blend = 30
    end repeat
  end if
end
