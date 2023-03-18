property name, sprlocZ, anim, locX, status
global gpShowSprites

on beginSprite me
  if voidp(gpShowSprites) then
    gpShowSprites = [:]
  end if
  setAt(gpShowSprites, name, me.spriteNum)
  sprite(me.spriteNum).locZ = sprlocZ
  status = 0
  locX = sprite(me.spriteNum).locH
  sprite(me.spriteNum).locH = 1000
end

on fuseShow_off me
  sprite(me.spriteNum).visible = 0
end

on fuseShow_on me
  sprite(me.spriteNum).visible = 1
end

on fuseShow_enter me
  anim = -1
  status = 1
end

on fuseShow_out me
end

on exitFrame me
  if status > 0 then
    status = status + 1
    if status > 9 then
      anim = anim + 1
      if anim < 10 then
        sprite(me.spriteNum).locH = locX
        sprite(me.spriteNum).member = getmemnum("splash_" & anim)
      else
        status = 0
        sprite(me.spriteNum).locH = 1000
      end if
    end if
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #name, [#comment: "Name", #format: #string, #default: "discofloor"])
  addProp(pList, #sprlocZ, [#comment: "locZ", #format: #integer, #default: 0])
  return pList
end
