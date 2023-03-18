property name, VerholocZ
global gpShowSprites, xoffset, yoffset, gXFactor, gpObjects, gUserSprites

on beginSprite me
  if voidp(gpShowSprites) then
    gpShowSprites = [:]
  end if
  setAt(gpShowSprites, name, me.spriteNum)
  sprite(me.spriteNum).locZ = VerholocZ - 2000
end

on fuseShow_off me
  sprite(me.spriteNum).visible = 0
end

on fuseShow_on me
  sprite(me.spriteNum).visible = 1
end

on fuseShow_Open me
  sprite(me.spriteNum).member = getmemnum("verhot auki")
  sprite(me.spriteNum).locZ = VerholocZ - 2000
end

on fuseShow_close me
  sprite(me.spriteNum).member = getmemnum("verho kiinni")
  sprite(me.spriteNum).locZ = VerholocZ
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #name, [#comment: "Name", #format: #string, #default: "discofloor"])
  addProp(pList, #VerholocZ, [#comment: "locZ", #format: #integer, #default: 0])
  return pList
end
