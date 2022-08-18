property name, roofH, roofV, moving, moveAnimateTime, moveAnimateStart, moveStartAngle, moveEndAngle, startColor, destColor, animating
global gpShowSprites, xoffset, yoffset

on beginSprite me
  if voidp(gpShowSprites) then
    gpShowSprites = [:]
  end if
  moving = 0
  setAt(gpShowSprites, name, me.spriteNum)
end

on fuseShow_off me
  sprite(me.spriteNum).visible = 0
end

on fuseShow_on me
  sprite(me.spriteNum).visible = 1
end

on fuseShow_fade me, params
  destColor = [integer(word 1 of params), integer(word 2 of params), integer(word 3 of params)]
  if voidp(startColor) then
    startColor = [integer(word 1 of params), integer(word 2 of params), integer(word 3 of params)]
  end if
  moveAnimateStart = the ticks
  moveAnimateTime = ((float(word 4 of params) / 1000.0) * 60)
  if (moveAnimateTime < 1) then
    moveAnimateTime = 1
  end if
  animating = 1
end

on exitFrame me
  if animating then
    factor = (((the ticks - moveAnimateStart) * 1.0) / moveAnimateTime)
    if (factor >= 1.0) then
      animating = 0
      startColor = destColor
      newrgb = color(#rgb, integer(getAt(destColor, 1)), integer(getAt(destColor, 2)), integer(getAt(destColor, 3)))
      sprite(me.spriteNum).color = newrgb
      return 
    end if
    l = (startColor + ((destColor - startColor) * factor))
    newrgb = color(#rgb, integer(getAt(l, 1)), integer(getAt(l, 2)), integer(getAt(l, 3)))
    sprite(me.spriteNum).color = newrgb
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #name, [#comment: "Spotin nimi", #format: #string, #default: "spot1"])
  return pList
end
