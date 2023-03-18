property tpalette

on beginSprite me
  (the member of sprite me.spriteNum).paletteRef = tpalette
end

on endSprite me
  (the member of sprite me.spriteNum).paletteRef = "lamp1"
end

on getPropertyDescriptionList me
  return [#tpalette: [#comment: "Palette for the light", #format: #palette, #default: "lamp1"]]
end
