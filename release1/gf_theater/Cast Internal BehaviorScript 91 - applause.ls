property name
global gpShowSprites

on fuseShow_on me
  set the member of sprite the spriteNum of me to member("applause_on")
end

on fuseShow_off me
  set the member of sprite the spriteNum of me to member("applause_off")
end

on beginSprite me
  if gpShowSprites = VOID then
    gpShowSprites = [:]
  end if
  name = "applause"
  setaProp(gpShowSprites, name, me.spriteNum)
end
