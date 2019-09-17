property type, lastChar, brightness

on beginSprite me 
  myPattern = void()
  sprite(me.spriteNum).castNum = sprite(me.spriteNum).castNum
  lastChar = the last char in sprite(me.spriteNum).member.name
  setWallPaper(gWallPaper)
end

on setWallPattern me, pattern 
  put(pattern)
  the itemDelimiter = ","
  sprite(me.spriteNum).castNum = getmemnum(type & pattern.item[1] & lastChar)
  sprite(me.spriteNum).member.palette = getmemnum(pattern.item[2])
  sprite(me.spriteNum).bgColor = rgb(integer(brightness * pattern.item[3]), integer(brightness * pattern.item[4]), integer(brightness * pattern.item[5]))
end

on getPropertyDescriptionList me 
  return([#brightness:[#comment:"Brightness", #format:#float, #default:1], #type:[#comment:"Type", #format:#string, #default:"exampleright"]])
end
