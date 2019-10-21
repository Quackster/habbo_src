on mouseDown(me)
  gPlastoColor = plastoColor
  sendSprite(gPlastoSpr, #updateColor)
  sendSprite(gPlastoSpr + 2, #updateColor)
  gPlastoCodeColor = plastoColorCode
  sendSprite(gPlastoCodeSpr, #updateCode)
  exit
end

on beginSprite(me)
  save = the itemDelimiter
  the itemDelimiter = ","
  colorR = integer(plastoColor.item[1])
  colorG = integer(plastoColor.item[2])
  colorB = integer(plastoColor.item[3])
  the itemDelimiter = save
  sprite(me.spriteNum).bgColor = rgb(colorR, colorG, colorB)
  exit
end

on getPropertyDescriptionList(me)
  return([#plastoColor:[#comment:"Plasto Color", #format:#string, #default:"255,255,255"], #plastoColorCode:[#comment:"ColorCode", #format:#string, #default:"H"]])
  exit
end