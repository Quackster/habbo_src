property spriteNum, pPalette

on beginSprite me
  if voidp(pPalette) then
    return 
  end if
  if pPalette.char[1] = "#" then
    pPalette = value(pPalette)
  else
    pPalette = member(pPalette)
  end if
  sprite(spriteNum).member.paletteRef = pPalette
end

on getPropertyDescriptionList
  tDescription = [:]
  addProp(tDescription, #pPalette, [#default: EMPTY, #format: #string, #comment: "Give me the name of the paletteMember...!"])
  return tDescription
end
