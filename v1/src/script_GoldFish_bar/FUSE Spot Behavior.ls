property name, moveEndLoc, roofV, roofH, moveEndAngle, moving, moveAnimateStart, moveAnimateTime, moveStartLoc, followOn, followFigure

on beginSprite me 
  if voidp(gpShowSprites) then
    gpShowSprites = [:]
  end if
  moving = 0
  setAt(gpShowSprites, name, me.spriteNum)
  moveEndLoc = [300, 300]
  roofH = sprite(me.spriteNum).locH
  roofV = sprite(me.spriteNum).locV
end

on fuseShow_off me 
  sprite(me.spriteNum).visible = 0
end

on fuseShow_on me 
  sprite(me.spriteNum).visible = 1
end

on fuseShow_move me, params 
  followOn = 0
  x = integer(params.word[1])
  y = integer(params.word[2])
  h = integer(params.word[3])
  moveAnimateTime = integer((((float(params.word[4]) * 1) / 1000) * 60))
  moveAnimateStart = the ticks
  newLocH = integer((((x - y) * 14) + xoffset))
  newLocV = (integer((((y + x) * 7) + yoffset)) - (h * 9))
  moveStartLoc = moveEndLoc
  moveEndLoc = [newLocH, newLocV]
  moveStartAngle = sprite(me.spriteNum).skew
  moveEndAngle = ((atan((((newLocV - roofV) * 1) / abs((newLocH - roofH)))) / (2 * 3.1416)) * 360)
  if newLocH > roofH then
    moveEndAngle = -moveEndAngle
  end if
  moving = 1
end

on fuseShow_follow me, params 
  followOn = 1
  moving = 0
  followFigure = params
  put("Following:" & params)
end

on exitFrame me 
  if moving then
    factor = (((the ticks - moveAnimateStart) * 1) / moveAnimateTime)
    if factor >= 1 then
      moving = 0
      factor = 1
    end if
    newLoc = (moveStartLoc + (factor * (moveEndLoc - moveStartLoc)))
    ang = ((atan(abs((((getAt(newLoc, 1) - roofH) * 1) / (getAt(newLoc, 2) - roofV)))) / (2 * 3.1416)) * 360)
    if getAt(newLoc, 1) > roofH then
      ang = -ang
    end if
    worldcoordinate = getWorldCoordinate(getAt(newLoc, 1), getAt(newLoc, 2))
    if not voidp(worldcoordinate) then
      sprite(me.spriteNum).locZ = (((1 + getAt(worldcoordinate, 1)) + getAt(worldcoordinate, 2)) * 1000)
    end if
    d = sqrt((((getAt(newLoc, 2) - roofV) * (getAt(newLoc, 2) - roofV)) + ((getAt(newLoc, 1) - roofH) * (getAt(newLoc, 1) - roofH))))
    sprite(me.spriteNum).height = integer(d)
    sprite(me.spriteNum).skew = ang
  else
    if followOn then
      followSpr = getaProp(gpObjects, followFigure)
      if followSpr > 0 then
        newLoc = (sprite(followSpr).undefined + [0, 20])
        ang = ((atan(abs((((getAt(newLoc, 1) - roofH) * 1) / (getAt(newLoc, 2) - roofV)))) / (2 * 3.1416)) * 360)
        d = sqrt((((getAt(newLoc, 2) - roofV) * (getAt(newLoc, 2) - roofV)) + ((getAt(newLoc, 1) - roofH) * (getAt(newLoc, 1) - roofH))))
        if getAt(newLoc, 1) > roofH then
          ang = -ang
        end if
        worldcoordinate = getWorldCoordinate(getAt(newLoc, 1), getAt(newLoc, 2))
        if not voidp(worldcoordinate) then
          sprite(me.spriteNum).locZ = (((1 + getAt(worldcoordinate, 1)) + getAt(worldcoordinate, 2)) * 1000)
        end if
        sprite(me.spriteNum).height = integer(d)
        sprite(me.spriteNum).skew = ang
      end if
    end if
  end if
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #name, [#comment:"Spotin nimi", #format:#string, #default:"spot1"])
  addProp(pList, #roofH, [#comment:"Ripustupisteen h-koordinaatti", #format:#integer, #default:0])
  addProp(pList, #roofV, [#comment:"Ripustupisteen v-koordinaatti", #format:#integer, #default:0])
  addProp(pList, #width, [#comment:"Spotin leveys", #format:#integer, #default:100])
  addProp(pList, #height, [#comment:"Spotin korkeus", #format:#integer, #default:50])
  return(pList)
end
