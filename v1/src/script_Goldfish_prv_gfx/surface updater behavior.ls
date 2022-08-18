property part, shadowed, pieceName

on beginSprite me 
  iSpr = me.spriteNum
  if (gWallsAndFloor = void()) then
    gWallsAndFloor = [#wallPattern:1, #wallColor:1, #floorPattern:1, #floorColor:1, #wallSprites:[], #floorSprites:[]]
  end if
  put(getaProp(gWallsAndFloor, symbol(part & "Sprites")))
  add(getaProp(gWallsAndFloor, symbol(part & "Sprites")), me.spriteNum)
  pieceNameWhole = sprite(iSpr).undefined.name
  save = the itemDelimiter
  the itemDelimiter = "_"
  pieceName = pieceNameWhole.item[2]
  the itemDelimiter = save
  update(me)
end

on update me 
  iSpr = me.spriteNum
  save = the itemDelimiter
  the itemDelimiter = ","
  dataFieldName = member(part & "pattern_patterns").text.line[getaProp(gWallsAndFloor, symbol(part & "Pattern"))]
  fieldData = member(dataFieldName).text
  patternName = fieldData.item[1]
  colorR = integer(fieldData.item[3])
  colorG = integer(fieldData.item[4])
  colorB = integer(fieldData.item[5])
  if (shadowed = 1) then
    colorR = (colorR * 0.9)
    colorG = (colorG * 0.9)
    colorB = (colorB * 0.9)
    sprite(iSpr).bgColor = rgb(colorR, colorG, colorB)
  else
    sprite(iSpr).bgColor = rgb(colorR, colorG, colorB)
  end if
  sprite(iSpr).undefined = patternName & "_" & pieceName
  sprite(iSpr).width = member(patternName & "_" & pieceName).width
  sprite(iSpr).height = member(patternName & "_" & pieceName).height
  paletteName = fieldData.item[2]
  member(patternName & "_" & pieceName).palette = member(paletteName)
  the itemDelimiter = save
end

on getPropertyDescriptionList me 
  return([#part:[#comment:"Part", #format:#string, #default:"wall"], #shadowed:[#comment:"shadowed?", #format:#boolean, #default:"false"]])
end
