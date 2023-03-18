property turnpoint, Vdirection

on beginSprite me
  checkCloud(me)
end

on enterFrame me
  iSpr = me.spriteNum
  sprite(iSpr).locH = sprite(iSpr).locH + 1
  if (sprite(iSpr).locH mod 2) = 0 then
    sprite(iSpr).locV = sprite(iSpr).locV + Vdirection
  end if
  if sprite(iSpr).locH > turnpoint then
    turn(me)
  end if
  if sprite(iSpr).locH > (30 + the stageRight - the stageLeft) then
    initCloud(me)
  end if
end

on initCloud me
  iSpr = me.spriteNum
  sprite(iSpr).locH = -30
  Vdirection = -1
  sprite(iSpr).flipH = 0
  sprite(iSpr).locV = random(81) + 150
end

on checkCloud me
  iSpr = me.spriteNum
  if sprite(iSpr).locH > turnpoint then
    turn(me)
  else
    Vdirection = -1
    sprite(iSpr).flipH = 0
  end if
end

on turn me
  iSpr = me.spriteNum
  Vdirection = 1
  sprite(iSpr).flipH = 1
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #turnpoint, [#format: #integer, #default: "332", #comment: "Turning point"])
  return pList
end
