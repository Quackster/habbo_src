property name, sprlocZ, anim, status, Myloc
global gpShowSprites

on beginSprite me
  if voidp(gpShowSprites) then
    gpShowSprites = [:]
  end if
  setAt(gpShowSprites, name, me.spriteNum)
  sprite(me.spriteNum).locZ = sprlocZ
  status = 0
  sprite(me.spriteNum).locH = 1000
end

on fuseShow_off me
  sprite(me.spriteNum).visible = 0
end

on fuseShow_on me
  sprite(me.spriteNum).visible = 1
end

on fuseShow_enter me, tMyloc
  if status = 0 then
    Myloc = tMyloc
    anim = -1
    status = 1
  end if
end

on exitFrame me
  if status > 0 then
    status = status + 1
    if status > 0 then
      anim = anim + 1
      if anim < 40 then
        sprite(me.spriteNum).loc = Myloc
        sprite(me.spriteNum).member = getmemnum("big_splash_" & anim / 2)
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
