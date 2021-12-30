on beginSprite me 
  gPrvFloorSpr = me.spriteNum
  sprite(me.spriteNum).castNum = getmemnum("floor0")
end

on setPattern me, pattern 
  the itemDelimiter = ","
  sprite(me.spriteNum).castNum = getmemnum(pattern.item[1])
  sprite(me.spriteNum).member.palette = getmemnum(pattern.item[2])
  sprite(me.spriteNum).bgColor = rgb(integer(pattern.item[3]), integer(pattern.item[4]), integer(pattern.item[5]))
end
