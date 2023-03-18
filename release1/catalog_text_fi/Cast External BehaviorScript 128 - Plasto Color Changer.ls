property plastoColor, plastoColorCode

on mouseDown me
  global gPlastoSpr, gPlastoColor, gPlastoCodeSpr, gPlastoCodeColor, gCatalogPopUp
  gPlastoColor = plastoColor
  sendSprite(gPlastoSpr, #updateColor)
  sendSprite(gPlastoSpr + 2, #updateColor)
  gPlastoCodeColor = plastoColorCode
  sendSprite(gPlastoCodeSpr, #updateCode)
end

on beginSprite me
  save = the itemDelimiter
  the itemDelimiter = ","
  colorR = integer(item 1 of plastoColor)
  colorG = integer(item 2 of plastoColor)
  colorB = integer(item 3 of plastoColor)
  the itemDelimiter = save
  sprite(me.spriteNum).bgColor = rgb(colorR, colorG, colorB)
end

on getPropertyDescriptionList me
  return [#plastoColor: [#comment: "Plasto Color", #format: #string, #default: "255,255,255"], #plastoColorCode: [#comment: "ColorCode", #format: #string, #default: "H"]]
end
