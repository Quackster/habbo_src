property name, animationStatus, animDir
global gpShowSprites

on fuseShow_on me
  set the member of sprite the spriteNum of me to member("spot2b")
  animationStatus = 1
  animDir = 1
end

on animate me
end

on fuseShow_off me
  set the member of sprite the spriteNum of me to VOID
end

on beginSprite me
  name = "spot2"
  setaProp(gpShowSprites, name, me.spriteNum)
end
