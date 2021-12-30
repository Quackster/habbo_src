on createFuseObject name, memberPrefix, memberType, locX, locY, height, dir, lDimensions, altitude, pData, partColors, update 
  if (memberPrefix.length = 0) then
    return()
  end if
  newSpr = sprMan_getPuppetSprite()
  dir = (dir mod 8)
  if getmemnum(memberPrefix && "Class") > 0 then
    scriptName = memberPrefix && "Class"
  else
    scriptName = "FuseMember Class"
  end if
  if offset("*", name) > 0 then
    name = name.char[1..(offset("*", name) - 1)] & name.char[(offset("*", name) + 2)..name.length]
  end if
  if offset("*", memberPrefix) > 0 then
    memberPrefix = memberPrefix.char[1..(offset("*", memberPrefix) - 1)]
  end if
  o = new(script(scriptName), name, memberPrefix, memberType, locX, locY, height, dir, lDimensions, newSpr, altitude, pData, partColors, update)
  setProp(o, #spriteNum, newSpr)
  beginSprite(o)
  sprite(newSpr).undefined = [o]
  return(o)
end

on createBalloon user, message, ttype 
  user = doSpecialCharConversion(user)
  message = doSpecialCharConversion(message)
  gLastBalloon = the ticks
  if gBalloons.count > 15 then
    put("Too many Balloon Sprites ! So kill first one." && gBalloons.getAt(1))
    sendSprite(gBalloons.getAt(1), #die)
  end if
  newSpr = sprMan_getPuppetSprite()
  balloonsUp()
  userObj = getaProp(gUserSprites, getObjectSprite(user))
  if not objectp(userObj) then
    return()
  end if
  locX = getaProp(userObj, #locX)
  locY = getaProp(userObj, #locY)
  height = getaProp(userObj, #locHe)
  screenLocs = getScreenCoordinate(locX, locY, height)
  if (newSpr = 0) then
    return()
  end if
  balloonColor = getProp(userObj.pColors, #ch)
  o = new(script("Balloon Class"), newSpr, user, user & ": " & message, screenLocs.getAt(1), 281, 255, balloonColor, ttype)
  sprite(newSpr).undefined = [o]
end

on balloonsUp  
  if voidp(gBalloons) then
    return()
  end if
  i = count(gBalloons)
  repeat while i >= 1
    sendSprite(getAt(gBalloons, i), #moveUp)
    i = (65535 + i)
  end repeat
end

on loadHeightMap data 
  glHeightMap = []
  glObjectPlaceMap = []
  i = 1
  repeat while i <= the number of line in data
    l = []
    k = []
    ln = data.line[i]
    j = 1
    repeat while j <= ln.length
      if (ln.char[j] = "x") then
        add(l, 100000)
        add(k, 100000)
      else
        if (ln.char[j] = "y") then
          add(l, 0)
          add(k, 10000)
        else
          add(l, integer(ln.char[j]))
          add(k, 0)
        end if
      end if
      j = (1 + j)
    end repeat
    add(glHeightMap, l)
    add(glObjectPlaceMap, k)
    i = (1 + i)
  end repeat
end

on getScreenCoordinate locX, locY, height 
  locH = (((locX - locY) * (gXFactor * 0.5)) + xoffset)
  locV = (float(((((locY + locX) * gYFactor) * 0.5) + yoffset)) - (height * gHFactor))
  locZ = (1000 * ((locX + locY) + 1))
  return([integer(locH), integer(locV), integer(locZ)])
end

on getCoordinateHeight x, y 
  x = integer(x)
  y = integer(y)
  if y < 0 or y >= count(glHeightMap) then
    return FALSE
  end if
  l = getAt(glHeightMap, integer((y + 1)))
  if x < 0 or x >= count(l) then
    return FALSE
  end if
  return(getAt(l, (x + 1)))
end

on getWorldCoordinate locX, locY, ignoreObjectCoordinates 
  if voidp(glHeightMap) then
    return(void())
  end if
  x = integer(((((locX - gYFactor) - xoffset) / gXFactor) + ((locY - yoffset) / gYFactor)))
  y = integer((((locY - yoffset) / gYFactor) - (((locX - gYFactor) - xoffset) / gXFactor)))
  height = -1
  if y >= 0 and y < count(glHeightMap) then
    if x >= 0 and x < count(getAt(glHeightMap, (y + 1))) then
      height = getAt(getAt(glHeightMap, (y + 1)), (x + 1))
    end if
  end if
  if (height = 0) then
    return([x, y, height])
  else
    i = 1
    repeat while i <= 9
      x = integer(((((locX - gYFactor) - xoffset) / gXFactor) + (((locY + (i * gHFactor)) - yoffset) / gYFactor)))
      y = integer(((((locY + (i * gHFactor)) - yoffset) / gYFactor) - (((locX - gYFactor) - xoffset) / gXFactor)))
      height = -1
      if y >= 0 and y < count(glHeightMap) then
        if x >= 0 and x < count(getAt(glHeightMap, (y + 1))) then
          height = getAt(getAt(glHeightMap, (y + 1)), (x + 1))
        end if
      end if
      if (height = i) then
        return([x, y, height])
      end if
      i = (1 + i)
    end repeat
  end if
  return(void())
end
