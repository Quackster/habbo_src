property name, roofH, roofV, moving, moveAnimateTime, moveAnimateStart, moveStartAngle, moveEndAngle, moveStartLoc, moveEndLoc, width, height, followOn, followFigure
global gpShowSprites, xoffset, yoffset, gpObjects

on beginSprite me
  if voidp(gpShowSprites) then
    gpShowSprites = [:]
  end if
  moving = 0
  setAt(gpShowSprites, name, me.spriteNum)
  moveEndLoc = [300, 300]
  roofH = the locH of sprite me.spriteNum
  roofV = the locV of sprite me.spriteNum
end

on fuseShow_off me
  sprite(me.spriteNum).visible = 0
end

on fuseShow_on me
  sprite(me.spriteNum).visible = 1
end

on fuseShow_move me, params
  followOn = 0
  x = integer(word 1 of params)
  y = integer(word 2 of params)
  h = integer(word 3 of params)
  moveAnimateTime = integer((((float(word 4 of params) * 1.0) / 1000.0) * 60))
  if (moveAnimateTime < 1) then
    moveAnimateTime = 1
  end if
  moveAnimateStart = the ticks
  newLocH = integer((((x - y) * 18) + xoffset))
  newLocV = (integer((((y + x) * 9) + yoffset)) - (h * 9))
  moveStartLoc = moveEndLoc
  moveEndLoc = [newLocH, newLocV]
  moveStartAngle = sprite(me.spriteNum).skew
  moveEndAngle = ((atan((((newLocV - roofV) * 1.0) / abs((newLocH - roofH)))) / (2 * 3.14159999999999995)) * 360.0)
  if (newLocH > roofH) then
    moveEndAngle = -moveEndAngle
  end if
  moving = 1
end

on fuseShow_follow me, params
  followOn = 1
  moving = 0
  followFigure = params
  put ("Following:" & params)
end

on exitFrame me
  if moving then
    factor = (((the ticks - moveAnimateStart) * 1.0) / moveAnimateTime)
    if (factor >= 1.0) then
      moving = 0
      factor = 1.0
    end if
    newLoc = (moveStartLoc + (factor * (moveEndLoc - moveStartLoc)))
    ang = ((atan(abs((((getAt(newLoc, 1) - roofH) * 1.0) / (getAt(newLoc, 2) - roofV)))) / (2 * 3.14159999999999995)) * 360.0)
    if (getAt(newLoc, 1) > roofH) then
      ang = -ang
    end if
    worldcoordinate = getWorldCoordinate(getAt(newLoc, 1), getAt(newLoc, 2))
    if not voidp(worldcoordinate) then
      sprite(me.spriteNum).locZ = (((1 + getAt(worldcoordinate, 1)) + getAt(worldcoordinate, 2)) * 1000)
    end if
    d = sqrt((((getAt(newLoc, 2) - roofV) * (getAt(newLoc, 2) - roofV)) + ((getAt(newLoc, 1) - roofH) * (getAt(newLoc, 1) - roofH))))
    set the height of sprite the spriteNum of me to integer(d)
    sprite(me.spriteNum).skew = ang
  else
    if followOn then
      followSpr = getaProp(gpObjects, followFigure)
      if (followSpr > 0) then
        newLoc = (the loc of sprite followSpr + [0, 20])
        ang = ((atan(abs((((getAt(newLoc, 1) - roofH) * 1.0) / (getAt(newLoc, 2) - roofV)))) / (2 * 3.14159999999999995)) * 360.0)
        d = sqrt((((getAt(newLoc, 2) - roofV) * (getAt(newLoc, 2) - roofV)) + ((getAt(newLoc, 1) - roofH) * (getAt(newLoc, 1) - roofH))))
        if (getAt(newLoc, 1) > roofH) then
          ang = -ang
        end if
        worldcoordinate = getWorldCoordinate(getAt(newLoc, 1), getAt(newLoc, 2))
        if not voidp(worldcoordinate) then
          sprite(me.spriteNum).locZ = (((1 + getAt(worldcoordinate, 1)) + getAt(worldcoordinate, 2)) * 1000)
        end if
        set the height of sprite the spriteNum of me to integer(d)
        sprite(me.spriteNum).skew = ang
      end if
    end if
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #name, [#comment: "Spotin nimi", #format: #string, #default: "spot1"])
  addProp(pList, #roofH, [#comment: "Ripustupisteen h-koordinaatti", #format: #integer, #default: 0])
  addProp(pList, #roofV, [#comment: "Ripustupisteen v-koordinaatti", #format: #integer, #default: 0])
  addProp(pList, #width, [#comment: "Spotin leveys", #format: #integer, #default: 100])
  addProp(pList, #height, [#comment: "Spotin korkeus", #format: #integer, #default: 50])
  return pList
end
