property registerSpr

on beginSprite me
  global gPlastoSpr
  if registerSpr then
    gPlastoSpr = me.spriteNum
  end if
  updateColor(me)
end

on updateColor me
  global gPlastoColor
  if voidp(gPlastoColor) then
    gPlastoColor = "255,255,255"
  end if
  save = the itemDelimiter
  the itemDelimiter = ","
  colorR = integer(item 1 of gPlastoColor)
  colorG = integer(item 2 of gPlastoColor)
  colorB = integer(item 3 of gPlastoColor)
  the itemDelimiter = save
  sprite(me.spriteNum).bgColor = rgb(colorR, colorG, colorB)
end

on getPropertyDescriptionList me
  return [#registerSpr: [#comment: "Register Sprite?", #format: #boolean, #default: 1]]
end
