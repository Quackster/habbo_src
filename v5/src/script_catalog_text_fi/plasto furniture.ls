on beginSprite(me)
  if registerSpr then
    gPlastoSpr = me.spriteNum
  end if
  updateColor(me)
  exit
end

on updateColor(me)
  if voidp(gPlastoColor) then
    gPlastoColor = "255,255,255"
  end if
  save = the itemDelimiter
  the itemDelimiter = ","
  colorR = integer(gPlastoColor.item[1])
  colorG = integer(gPlastoColor.item[2])
  colorB = integer(gPlastoColor.item[3])
  the itemDelimiter = save
  sprite(me.spriteNum).bgColor = rgb(colorR, colorG, colorB)
  exit
end

on getPropertyDescriptionList(me)
  return([#registerSpr:[#comment:"Register Sprite?", #format:#boolean, #default:1]])
  exit
end