property name
global gpShowSprites, xoffset, yoffset

on beginSprite me
  if voidp(gpShowSprites) then
    gpShowSprites = [:]
  end if
  setAt(gpShowSprites, name, me.spriteNum)
  fuseShow_off(me)
end

on fuseShow_off me
  sprite(me.spriteNum).visible = 0
end

on fuseShow_on me
  sprite(me.spriteNum).visible = 1
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #name, [#comment: "Nimi", #format: #string, #default: "mirrorball1"])
  return pList
end
