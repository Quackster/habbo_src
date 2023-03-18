property myPattern
global gPrvFloorSpr, lastChar, gFloor

on beginSprite me
  myPattern = VOID
  gPrvFloorSpr = me.spriteNum
  lastChar = the last char in the name of the member of sprite(the spriteNum of me)
  sprite(me.spriteNum).castNum = the castNum of sprite me.spriteNum
  setFloor(gFloor)
end

on setPattern me, pattern
  the itemDelimiter = ","
  sprite(me.spriteNum).castNum = getmemnum(item 1 of pattern & lastChar)
  sprite(me.spriteNum).member.palette = getmemnum(item 2 of pattern)
  sprite(me.spriteNum).bgColor = rgb(integer(item 3 of pattern), integer(item 4 of pattern), integer(item 5 of pattern))
end
