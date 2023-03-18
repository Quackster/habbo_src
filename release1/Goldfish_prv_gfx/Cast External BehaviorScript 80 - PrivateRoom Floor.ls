global gPrvFloorSpr

on beginSprite me
  gPrvFloorSpr = me.spriteNum
  sprite(me.spriteNum).castNum = getmemnum("floor0")
end

on setPattern me, pattern
  the itemDelimiter = ","
  sprite(me.spriteNum).castNum = getmemnum(item 1 of pattern)
  sprite(me.spriteNum).member.palette = getmemnum(item 2 of pattern)
  sprite(me.spriteNum).bgColor = rgb(integer(item 3 of pattern), integer(item 4 of pattern), integer(item 5 of pattern))
end
