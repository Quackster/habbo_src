property takeOffTime, lSprites, user, followSprite, lines, dir, balloonTextmem, balloonmem, balloonSpr, balloonTextSpr, bPulsePhase, iBalloonZoomSize, bZoomPhase, bMoving, animStart, startY, destX, destY, width, pulsePhaseLength, zoomPhaseLength, myMemberName
global gMyName, maxH, gXFactor, gballoonZ, gUserBalloons, gBalloons, gBalloonMembers

on new me, spr, tuser, message, tdestX, tdestY, fcolor, Bordercolor, ttype
  if voidp(gballoonZ) then
    gballoonZ = 10000000
  end if
  if voidp(gBalloons) then
    gBalloons = []
  end if
  add(gBalloons, spr)
  if (voidp(gBalloonMembers) or (gBalloonMembers = [])) then
    InitBalloons()
  end if
  myMemberName = getLast(gBalloonMembers)
  gBalloonMembers.deleteAt(gBalloonMembers.count)
  pulsePhaseLength = 10
  zoomPhaseLength = 30
  lSprites = []
  user = tuser
  if (gXFactor < 33.0) then
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
  set the textFont of field balloonTextmem to "Volter (goldfish)"
  member(balloonTextmem).text = doSpecialCharConversion(message)
  if (ttype = #shout) then
    set the textStyle of member balloonTextmem to "plain"
    set the textFont of field balloonTextmem to "Volter-Bold (goldfish)"
  else
    if (ttype = #whisper) then
      set the textStyle of member balloonTextmem to "plain"
      set the textStyle of member balloonTextmem to "italic"
    else
      set the textStyle of member balloonTextmem to "plain"
    end if
  end if
  set the textFont of word 1 of field balloonTextmem to "Volter-Bold (goldfish)"
  h = member(balloonTextmem).charPosToLoc(length(message))
  width = (getAt(h, 1) + 60)
  balloonmem = getmemnum(("textbox_" & ((width / 25) * 25)))
  balloonSpr = spr
  if (the number of member "balloonpulse" < 1) then
    return 
  end if
  set the member of sprite balloonSpr to member("balloonpulse")
  if (((Bordercolor.red + Bordercolor.green) + Bordercolor.blue) >= 600) then
    BordercolorDarken = rgb(0, 0, 0)
    BordercolorDarken.red = (Bordercolor.red * 0.90000000000000002)
    BordercolorDarken.green = (Bordercolor.green * 0.90000000000000002)
    BordercolorDarken.blue = (Bordercolor.blue * 0.90000000000000002)
    sprite(balloonSpr).color = BordercolorDarken
  else
    sprite(balloonSpr).color = Bordercolor
  end if
  set the foreColor of sprite balloonTextSpr to fcolor
  balloonTextSpr = sprMan_getPuppetSprite()
  set the member of sprite balloonTextSpr to balloonTextmem
  if (balloonSpr < 1) then
    return 
  end if
  sprite(balloonSpr).locZ = gballoonZ
  set the ink of sprite balloonSpr to 8
  sprite(balloonTextSpr).locZ = (gballoonZ + 1000)
  set the ink of sprite balloonTextSpr to 36
  sprite(balloonTextSpr).visible = 0
  sprite(balloonSpr).visible = 1
  gballoonZ = (gballoonZ + 2)
  if (gXFactor < 33.0) then
    startY = (the locV of sprite followSprite - 30)
  else
    startY = (the locV of sprite followSprite - 80)
  end if
  set the locH of sprite balloonSpr to destX
  set the locV of sprite balloonSpr to startY
  addProp(gUserBalloons, user, me)
  animStart = the ticks
  put "balloon", balloonSpr, balloonTextSpr
  return me
end

on exitFrame me
  if (the locV of sprite balloonSpr < 0) then
    die(me)
  else
    if bPulsePhase then
      a = (((the ticks - animStart) * 1.0) / pulsePhaseLength)
      if (a >= 1.0) then
        a = 1.0
        bPulsePhase = 0
        bZoomPhase = 1
        animStart = the ticks
      end if
      y = integer(((a * (destY - startY)) + startY))
      set the locV of sprite balloonSpr to y
    else
      if bZoomPhase then
        set the castNum of sprite balloonSpr to getmemnum(("textBox_" & iBalloonZoomSize))
        iBalloonZoomSize = (iBalloonZoomSize + 100)
        if ((destX + (iBalloonZoomSize / 2)) > maxH) then
          destX = (maxH - (iBalloonZoomSize / 2))
          set the locH of sprite balloonSpr to destX
        else
          if ((destX - (iBalloonZoomSize / 2)) <= 0) then
            destX = (1 + (iBalloonZoomSize / 2))
            set the locH of sprite balloonSpr to destX
          end if
        end if
        if (iBalloonZoomSize >= width) then
          bZoomPhase = 0
          adjustBalloon(me)
        end if
      end if
    end if
    if bMoving then
      a = (((the ticks - animStart) * 1.0) / pulsePhaseLength)
      if (a >= 1.0) then
        a = 1.0
        bMoving = 0
      end if
      y = integer(((a * (destY - startY)) + startY))
      set the locV of sprite balloonTextSpr to (y - 7)
      set the locV of sprite balloonSpr to y
    end if
  end if
end

on adjustBalloon me
  global gpShowSprites
  sprite(balloonTextSpr).visible = 1
  set the castNum of sprite balloonSpr to member(balloonmem)
  set the locV of sprite balloonSpr to destY
  if (the movieName contains "pelle") then
    camspr = getaProp(gpShowSprites, "cam1")
    if (camspr > 0) then
      if ((destX + (width / 2)) > sprite(camspr).left) then
        destX = ((sprite(camspr).left - (width / 2)) - 5)
        sprite(balloonSpr).locH = destX
      end if
    end if
  end if
  set the locH of sprite balloonTextSpr to ((destX - (width / 2)) + 25)
  set the locV of sprite balloonTextSpr to (destY - 7)
end

on move me, tdestY
  destY = tdestY
  startY = the locV of sprite balloonSpr
  animStart = the ticks
  bMoving = 1
end

on moveUp me
  move(me, (destY - 22))
end

on die me
  set the foreColor of sprite balloonSpr to 255
  set the foreColor of sprite balloonTextSpr to 255
  sprMan_releaseSprite(balloonSpr)
  sprMan_releaseSprite(balloonTextSpr)
  if (getPos(gBalloons, balloonSpr) >= 0) then
    deleteAt(gBalloons, getPos(gBalloons, balloonSpr))
  end if
  deleteProp(gUserBalloons, user)
  if ((gBalloonMembers = []) or (gBalloonMembers.getOne(myMemberName) = 0)) then
    gBalloonMembers.add(myMemberName)
  end if
end
