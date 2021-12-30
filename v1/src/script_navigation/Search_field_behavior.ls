on beginSprite me 
  myOwnStatus = 0
  NaviPrivateSearchSpr = me.spriteNum
end

on mouseDown me 
  SwapMyStatus(me, 1)
end

on SwapMyStatus me, Stat 
  if (Stat = 1) then
    myOwnStatus = 1
    sprite(me.spriteNum).editable = 1
    sprite(me.spriteNum).blend = 100
    f = me.spriteNum
    repeat while f >= (me.spriteNum - 2)
      sprite(f).blend = 100
      f = (65535 + f)
    end repeat
    exit repeat
  end if
  myOwnStatus = 0
  sprite(me.spriteNum).editable = 0
  sprite(me.spriteNum).blend = 30
  f = me.spriteNum
  repeat while f >= (me.spriteNum - 2)
    sprite(f).blend = 30
    f = (65535 + f)
  end repeat
end
