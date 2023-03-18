property origXoffset, origYoffset
global xoffset, yoffset

on beginSprite me
  checkOffsets()
  origXoffset = xoffset
  origYoffset = yoffset
end

on updateLocation me
  set the locH of sprite the spriteNum of me to the locH of sprite me.spriteNum + (xoffset - origXoffset)
  set the locV of sprite the spriteNum of me to the locV of sprite me.spriteNum + (yoffset - origYoffset)
  origXoffset = xoffset
  origYoffset = yoffset
end
