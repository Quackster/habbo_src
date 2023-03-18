property name, liteAnimationStatus, animCount
global gpShowSprites

on fuseShow_on me
  if the member of sprite me.spriteNum = member("lightMask") then
    return 
  end if
  set the member of sprite the spriteNum of me to member("lightMask")
  set the blend of sprite the spriteNum of me to 0
  liteAnimationStatus = 1
  animCount = 0
end

on animateLite me
  set the blend of sprite the spriteNum of me to the blend of sprite me.spriteNum + 1
  animCount = animCount + 1
  if animCount > 19 then
    liteAnimationStatus = 0
  end if
end

on fuseShow_off me
  set the member of sprite the spriteNum of me to VOID
end

on beginSprite me
  if gpShowSprites = VOID then
    gpShowSprites = [:]
  end if
  name = "lightMask"
  setaProp(gpShowSprites, name, me.spriteNum)
end
