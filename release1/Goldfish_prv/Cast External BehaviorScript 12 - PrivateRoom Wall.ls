property brightness, type, lastChar, myPattern
global gWallPaper

on beginSprite me
  myPattern = VOID
  sprite(me.spriteNum).castNum = the castNum of sprite me.spriteNum
  lastChar = the last char in the name of the member of sprite(the spriteNum of me)
  setWallPaper(gWallPaper)
end

on setWallPattern me, pattern
  put pattern
  the itemDelimiter = ","
  sprite(me.spriteNum).castNum = getmemnum(type & item 1 of pattern & lastChar)
  sprite(me.spriteNum).member.palette = getmemnum(item 2 of pattern)
  sprite(me.spriteNum).bgColor = rgb(integer(brightness * item 3 of pattern), integer(brightness * item 4 of pattern), integer(brightness * item 5 of pattern))
end

on getPropertyDescriptionList me
  return [#brightness: [#comment: "Brightness", #format: #float, #default: 1.0], #type: [#comment: "Type", #format: #string, #default: "exampleright"]]
end
