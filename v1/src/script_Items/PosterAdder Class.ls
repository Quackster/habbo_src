property spr, y, maskWallSpr, windowSpr, DoorSpr, pType, leftOrRight, pID, h, myLocZ

on new me, tSpr, tid, ttype, tOpenHand 
  if voidp(ttype) then
    ttype = 1
  end if
  if voidp(tOpenHand) then
    tOpenHand = 0
  end if
  pID = tid
  pType = ttype
  spr = tSpr
  DoorSpr = 3
  windowSpr = 18
  maskWallSpr = 16
  sprite(spr).blend = 40
  if not tOpenHand then
  end if
  return(me)
end

on beginSprite me 
  nothing()
end

on prepareFrame me 
  screenX = abs((the mouseH - xoffset))
  y = ((2 * screenX) / gXFactor)
  screenRef = getScreenCoordinate(0, y, 0)
  sprite(spr).locZ = (screenRef.getAt(3) - 1000)
  if sprite(spr).intersects(maskWallSpr) then
    sprite(spr).locZ = (sprite(maskWallSpr).locZ + 1)
  end if
  sprite(spr).loc = the mouseLoc
  flag1 = 0
  flag2 = 0
  IsAddOk1 = 0
  IsAddOk2 = 0
  f = 5
  repeat while f <= 16
    if sprite(f).intersects(spr) and (sprite(windowSpr).intersects(spr) = 0) and (sprite(DoorSpr).intersects(spr) = 0) then
      if sprite(f).member.name contains "left" then
        AddPointTop = point((((sprite(spr).left - sprite(f).left) + sprite(spr).width) - 1), (sprite(spr).top - sprite(f).top))
        AddPointTop2 = point((sprite(spr).left - sprite(f).left), (sprite(spr).top - sprite(f).top))
        AddPointBottom = (AddPointTop + point((-sprite(spr).width + 1), sprite(spr).height))
      else
        AddPointTop = point((sprite(spr).left - sprite(f).left), (sprite(spr).top - sprite(f).top))
        AddPointTop2 = point((((sprite(spr).left - sprite(f).left) + sprite(spr).width) - 1), (sprite(spr).top - sprite(f).top))
        AddPointBottom = (AddPointTop + point((sprite(spr).width - 1), sprite(spr).height))
      end if
      if (flag1 = 0) then
        IsAddOk1Mem = sprite(f).member.name
        IsAddOk1 = member(sprite(f).member.name).image.getPixel(AddPointTop)
        TopArea = member(sprite(f).member.name).image.getPixel(AddPointTop2)
        if IsAddOk1 <> 0 and IsAddOk1 <> paletteIndex(0) then
          flag1 = 1
        end if
      end if
      if (flag2 = 0) then
        IsAddOk2Mem = sprite(f).member.name
        IsAddOk2 = member(sprite(f).member.name).image.getPixel(AddPointBottom)
        if IsAddOk2 <> 0 and IsAddOk2 <> paletteIndex(0) then
          flag2 = 1
        end if
      end if
    end if
    f = (1 + f)
  end repeat
  if the mouseDown then
    put(IsAddOk1Mem, AddPointTop, IsAddOk1, IsAddOk2Mem, IsAddOk2, AddPointBottom)
  end if
  if IsAddOk1 <> 0 and IsAddOk2 <> 0 and IsAddOk1 <> paletteIndex(0) and IsAddOk2 <> paletteIndex(0) and TopArea <> paletteIndex(0) then
    sprite(spr).blend = 100
    if IsAddOk1Mem contains "right" and IsAddOk2Mem contains "right" then
      sprite(spr).castNum = getmemnum("rightwall poster" && pType)
    end if
    if IsAddOk1Mem contains "left" and IsAddOk2Mem contains "left" then
      sprite(spr).castNum = getmemnum("leftwall poster" && pType)
    end if
    if IsAddOk1Mem contains "left" and IsAddOk2Mem contains "right" or IsAddOk1Mem contains "right" and IsAddOk2Mem contains "left" then
      sprite(spr).blend = 40
    end if
  else
    sprite(spr).blend = 40
  end if
end

on mouseDown me 
  if (sprite(spr).blend = 100) then
    myLocZ = sprite(spr).locZ
    mh = the mouseH
    mv = the mouseV
    screenX = -(mh - (xoffset + 0))
    y = ((2 * screenX) / gXFactor)
    screenRef = getScreenCoordinate(0, y, 0)
    h = ((screenRef.getAt(2) - mv) / gHFactor)
    leftOrRight = sprite(spr).member.name
    sprMan_releaseSprite(spr)
    createPoster(me)
  else
    sprMan_releaseSprite(spr)
    s = "GETSTRIP" && "new"
    sendFuseMsg(s)
  end if
end

on hide me 
end

on show me 
end

on setLocation me 
end

on updateLocation me 
end

on createPoster me 
  if leftOrRight contains "left" then
    s = "PLACEITEMFROMSTRIP" && pID && "leftwall " & y & "," & h & "," & myLocZ & "/" & pType
  else
    s = "PLACEITEMFROMSTRIP" && pID && "frontwall " & y & "," & h & "," & myLocZ & "/" & pType
  end if
  sendFuseMsg(s)
  s = "GETSTRIP" && "new"
  sendFuseMsg(s)
end
