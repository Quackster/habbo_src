property name, palette
global gpShowSprites, xoffset, yoffset

on beginSprite me
  if voidp(gpShowSprites) then
    gpShowSprites = [:]
  end if
  setAt(gpShowSprites, name, me.spriteNum)
end

on fuseShow_off me
  sprite(me.spriteNum).visible = 0
end

on fuseShow_on me
  sprite(me.spriteNum).visible = 1
end

on fuseShow_setfloor me, num
  sprite(me.spriteNum).member.paletteRef = member(getmemnum("floorpalette" & num))
end

on fuseShow_setlamp me, num
  sprite(me.spriteNum).member.paletteRef = member(getmemnum("lattialamppu" & num))
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #name, [#comment: "Name", #format: #string, #default: "discofloor"])
  return pList
end
