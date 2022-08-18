property user, myMemberName, balloonTextmem, width, balloonSpr, balloonTextSpr, followSprite, destX, startY, bPulsePhase, animStart, pulsePhaseLength, destY, bZoomPhase, iBalloonZoomSize, bMoving, balloonmem

on new me, spr, tuser, message, tdestX, tdestY, fcolor, Bordercolor, ttype 
  if voidp(gballoonZ) then
    gballoonZ = 10000000
  end if
  if voidp(gBalloons) then
    gBalloons = []
  end if
  add(gBalloons, spr)
  if voidp(gBalloonMembers) or (gBalloonMembers = []) then
    InitBalloons()
  end if
  myMemberName = getLast(gBalloonMembers)
  gBalloonMembers.deleteAt(gBalloonMembers.count)
  pulsePhaseLength = 10
  zoomPhaseLength = 30
  lSprites = []
  user = tuser
  if gXFactor < 33 then
    destX = (tdestX + 18)
  else
    destX = (tdestX + 36)
  end if
  maxH = (the stageRight - the stageLeft)
  destY = 99
  bPulsePhase = 1
  bZoomPhase = 0
  bMoving = 0
  iBalloonZoomSize = 25
  followSprite = getObjectSprite(user)
  takeOffTime = (the ticks + 600)
  balloonTextmem = myMemberName
  
  member(balloonTextmem).text = doSpecialCharConversion(message)
  if (ttype = #shout) then
    sprite(0).undefined = "plain"
    
  else
    if (ttype = #whisper) then
      sprite(0).undefined = "plain"
      sprite(0).undefined = "italic"
    else
      sprite(0).undefined = "plain"
    end if
  end if
  field(0).textFont = "Volter-Bold (goldfish)"
  h = member(balloonTextmem).charPosToLoc(length(message))
  width = (getAt(h, 1) + 60)
  balloonmem = getmemnum("textbox_" & ((width / 25) * 25))
  balloonSpr = spr
  if sprite(0).number < 1 then
    return()
  end if
  sprite(balloonSpr).undefined = member("balloonpulse")
  if ((Bordercolor.red + Bordercolor.green) + Bordercolor.blue) >= 600 then
    BordercolorDarken = rgb(0, 0, 0)
    BordercolorDarken.red = (Bordercolor.red * 0.9)
    BordercolorDarken.green = (Bordercolor.green * 0.9)
    BordercolorDarken.blue = (Bordercolor.blue * 0.9)
    sprite(balloonSpr).color = BordercolorDarken
  else
    sprite(balloonSpr).color = Bordercolor
  end if
  sprite(balloonTextSpr).foreColor = fcolor
  balloonTextSpr = sprMan_getPuppetSprite()
  sprite(balloonTextSpr).undefined = balloonTextmem
  if balloonSpr < 1 then
    return()
  end if
  sprite(balloonSpr).locZ = gballoonZ
  sprite(balloonSpr).ink = 8
  sprite(balloonTextSpr).locZ = (gballoonZ + 1000)
  sprite(balloonTextSpr).ink = 36
  sprite(balloonTextSpr).visible = 0
  sprite(balloonSpr).visible = 1
  gballoonZ = (gballoonZ + 2)
  if gXFactor < 33 then
    startY = (sprite(followSprite).locV - 30)
  else
    startY = (sprite(followSprite).locV - 80)
  end if
  sprite(balloonSpr).locH = destX
  sprite(balloonSpr).locV = startY
  addProp(gUserBalloons, user, me)
  animStart = the ticks
  put("balloon", balloonSpr, balloonTextSpr)
  return(me)
end

on exitFrame me 
  if sprite(balloonSpr).locV < 0 then
    die(me)
  else
    if bPulsePhase then
      a = (((the ticks - animStart) * 1) / pulsePhaseLength)
      if a >= 1 then
        a = 1
        bPulsePhase = 0
        bZoomPhase = 1
        animStart = the ticks
      end if
      y = integer(((a * (destY - startY)) + startY))
      sprite(balloonSpr).locV = y
    else
      if bZoomPhase then
        sprite(balloonSpr).castNum = getmemnum("textBox_" & iBalloonZoomSize)
        iBalloonZoomSize = (iBalloonZoomSize + 100)
        if (destX + (iBalloonZoomSize / 2)) > maxH then
          destX = (maxH - (iBalloonZoomSize / 2))
          sprite(balloonSpr).locH = destX
        else
          if (destX - (iBalloonZoomSize / 2)) <= 0 then
            destX = (1 + (iBalloonZoomSize / 2))
            sprite(balloonSpr).locH = destX
          end if
        end if
        if iBalloonZoomSize >= width then
          bZoomPhase = 0
          adjustBalloon(me)
        end if
      end if
    end if
    if bMoving then
      a = (((the ticks - animStart) * 1) / pulsePhaseLength)
      if a >= 1 then
        a = 1
        bMoving = 0
      end if
      y = integer(((a * (destY - startY)) + startY))
      sprite(balloonTextSpr).locV = (y - 7)
      sprite(balloonSpr).locV = y
    end if
  end if
end

on adjustBalloon me 
  sprite(balloonTextSpr).visible = 1
  sprite(balloonSpr).castNum = member(balloonmem)
  sprite(balloonSpr).locV = destY
  if the movieName contains "pelle" then
    camspr = getaProp(gpShowSprites, "cam1")
    if camspr > 0 then
      if (destX + (width / 2)) > sprite(camspr).left then
        destX = ((sprite(camspr).left - (width / 2)) - 5)
        sprite(balloonSpr).locH = destX
      end if
    end if
  end if
  sprite(balloonTextSpr).locH = ((destX - (width / 2)) + 25)
  sprite(balloonTextSpr).locV = (destY - 7)
end

on move me, tdestY 
  destY = tdestY
  startY = sprite(balloonSpr).locV
  animStart = the ticks
  bMoving = 1
end

on moveUp me 
  move(me, (destY - 22))
end

on die me 
  sprite(balloonSpr).foreColor = 255
  sprite(balloonTextSpr).foreColor = 255
  sprMan_releaseSprite(balloonSpr)
  sprMan_releaseSprite(balloonTextSpr)
  if getPos(gBalloons, balloonSpr) >= 0 then
    deleteAt(gBalloons, getPos(gBalloons, balloonSpr))
  end if
  deleteProp(gUserBalloons, user)
  if (gBalloonMembers = []) or (gBalloonMembers.getOne(myMemberName) = 0) then
    gBalloonMembers.add(myMemberName)
  end if
end
