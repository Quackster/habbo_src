property spr, y, h, stripItemId, noOfPostits, myColor, popUpLoc, leftOrRight, leftWallMatteSpr, DoorSpr, DoorSpr2, maskWallSpr, windowSpr, myLocZ
global xoffset, gpopUpAdder, gPostItColor, gXFactor, gYFactor, gHFactor, MyMaxLines, gPostitCounter

on new me, tSpr, tstripItemId, tNoOfPostIts
  global gPostItColor
  spr = tSpr
  myColor = "FFFF31"
  gPostItColor = rgb(myColor)
  DoorSpr = 3
  windowSpr = 18
  stripItemId = tstripItemId
  noOfPostits = tNoOfPostIts
  MyMaxLines = 12
  maskWallSpr = 16
  sprite(spr).blend = 40
  return me
end

on beginSprite me
  gpopUpAdder = me
end

on prepareFrame me
  screenX = abs(the mouseH - xoffset)
  y = 2 * screenX / gXFactor
  screenRef = getScreenCoordinate(0, y, 0)
  sprite(spr).locZ = screenRef[3] - 1000
  if sprite(spr).intersects(maskWallSpr) then
    sprite(spr).locZ = sprite(maskWallSpr).locZ + 1
  end if
  sprite(spr).loc = the mouseLoc
  flag1 = 0
  flag2 = 0
  IsAddOk1 = 0
  IsAddOk2 = 0
  repeat with f = 5 to 16
    if sprite spr intersects f and (sprite spr intersects windowSpr = 0) and (sprite spr intersects DoorSpr = 0) then
      if sprite(f).member.name contains "left" then
        AddPointTop = point(sprite(spr).left - sprite(f).left + sprite(spr).width - 1, sprite(spr).top - sprite(f).top)
        AddPointTop2 = point(sprite(spr).left - sprite(f).left, sprite(spr).top - sprite(f).top)
        AddPointBottom = AddPointTop + point(-sprite(spr).width + 1, sprite(spr).height)
      else
        AddPointTop = point(sprite(spr).left - sprite(f).left, sprite(spr).top - sprite(f).top)
        AddPointTop2 = point(sprite(spr).left - sprite(f).left + sprite(spr).width - 1, sprite(spr).top - sprite(f).top)
        AddPointBottom = AddPointTop + point(sprite(spr).width - 1, sprite(spr).height)
      end if
      if flag1 = 0 then
        IsAddOk1Mem = sprite(f).member.name
        IsAddOk1 = member(sprite(f).member.name).image.getPixel(AddPointTop)
        TopArea = member(sprite(f).member.name).image.getPixel(AddPointTop2)
        if (IsAddOk1 <> 0) and (IsAddOk1 <> paletteIndex(0)) then
          flag1 = 1
        end if
      end if
      if flag2 = 0 then
        IsAddOk2Mem = sprite(f).member.name
        IsAddOk2 = member(sprite(f).member.name).image.getPixel(AddPointBottom)
        if (IsAddOk2 <> 0) and (IsAddOk2 <> paletteIndex(0)) then
          flag2 = 1
        end if
      end if
    end if
  end repeat
  if the mouseDown then
    put IsAddOk1Mem, AddPointTop, IsAddOk1, IsAddOk2Mem, IsAddOk2, AddPointBottom
  end if
  if (IsAddOk1 <> 0) and (IsAddOk2 <> 0) and (IsAddOk1 <> paletteIndex(0)) and (IsAddOk2 <> paletteIndex(0)) and (TopArea <> paletteIndex(0)) then
    sprite(spr).blend = 100
    if (IsAddOk1Mem contains "right") and (IsAddOk2Mem contains "right") then
      sprite(spr).castNum = getmemnum("rightwall post.it")
    end if
    if (IsAddOk1Mem contains "left") and (IsAddOk2Mem contains "left") then
      sprite(spr).castNum = getmemnum("leftwall post.it")
    end if
    if ((IsAddOk1Mem contains "left") and (IsAddOk2Mem contains "right")) or ((IsAddOk1Mem contains "right") and (IsAddOk2Mem contains "left")) then
      sprite(spr).blend = 40
    end if
  else
    sprite(spr).blend = 40
  end if
end

on mouseDown me
  if sprite(spr).blend = 100 then
    myLocZ = sprite(spr).locZ
    mh = the mouseH
    mv = the mouseV
    popUpLoc = the mouseLoc
    if popUpLoc[1] < 100 then
      popUpLoc[1] = 120
    end if
    if popUpLoc[2] < 100 then
      popUpLoc[2] = 110
    end if
    if popUpLoc[1] > 600 then
      popUpLoc[1] = 570
    end if
    if popUpLoc[2] > 400 then
      popUpLoc[2] = 370
    end if
    screenX = -(mh - (xoffset + 0))
    y = 2 * screenX / gXFactor
    screenRef = getScreenCoordinate(0, y, 0)
    h = (screenRef[2] - mv) / gHFactor
    put EMPTY into field "post.it field_Add"
    popup("post.it add .pop", popUpLoc, "post.it add")
    leftOrRight = sprite(spr).member.name
    sprMan_releaseSprite(spr)
  end if
end

on createPostIt me
  global gpPostItNos
  if leftOrRight contains "left" then
    s = "ADDITEM /post.it/leftwall " & y & "," & h & "," & myLocZ & "/" & myColor && field("post.it field_Add")
  else
    s = "ADDITEM /post.it/frontwall " & y & "," & h & "," & myLocZ & "/" & myColor && field("post.it field_Add")
  end if
  sendFuseMsg(s)
  noOfPostits = getaProp(gpPostItNos, stripItemId)
  if noOfPostits = VOID then
    noOfPostits = 20
  end if
  s = "SETSTRIPITEMDATA " & RETURN & stripItemId & RETURN & noOfPostits - 1
  sendFuseMsg(s)
  setaProp(gpPostItNos, stripItemId, noOfPostits - 1)
  if (noOfPostits - 1) <= 0 then
    s = "REMOVESTRIPITEM " & stripItemId
    sendFuseMsg(s)
    sendFuseMsg("GETSTRIP new")
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

on setPostItColor me, col
  myColor = col
  gPostItColor = rgb(myColor)
  popupClose("post.it add")
  popup("post.it add .pop", popUpLoc, "post.it add")
end
