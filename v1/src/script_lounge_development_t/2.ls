property tpalette

on beginSprite me 
  sprite(me.spriteNum).undefined.paletteRef = tpalette
end

on endSprite me 
  sprite(me.spriteNum).undefined.paletteRef = "lamp1"
end

on getPropertyDescriptionList me 
  return([#tpalette:[#comment:"Palette for the light", #format:#palette, #default:"lamp1"]])
end
