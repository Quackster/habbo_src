on beginSprite me 
  myPattern = void()
  gPrvFloorSpr = me.spriteNum
  lastChar = the last char in sprite(me.spriteNum).member.name
  sprite(me.spriteNum).castNum = sprite(me.spriteNum).castNum
  setFloor(gFloor)
end

on setPattern me, pattern 
  the itemDelimiter = ","
  sprite(me.spriteNum).castNum = getmemnum(pattern.item[1] & lastChar)
  sprite(me.spriteNum).member.palette = getmemnum(pattern.item[2])
  sprite(me.spriteNum).bgColor = rgb(integer(pattern.item[3]), integer(pattern.item[4]), integer(pattern.item[5]))
end
