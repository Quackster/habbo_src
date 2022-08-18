property name, scr, targetPoint, h, w, TargerObject, targetspr, zoom, transition, speed, flexible, vx, vy, LastPointCrop, transitionState, transitionbuffer, fadeSpeed, textImageBuffer, textShowState, textShowTime, textBlend, StateOfAd, adShowTime, adMember, adLink, adIdNum, AdWaitScore, testTime
global gpShowSprites, xoffset, yoffset, gXFactor, gpObjects, gUserSprites, goJumper

on beginSprite me
  if voidp(gpShowSprites) then
    gpShowSprites = [:]
  end if
  setAt(gpShowSprites, name, me.spriteNum)
  h = 108
  w = 102
  member("screen").image = member(getmemnum("screen_logo")).image
  scr = member("screen").image
  TargerObject = VOID
  zoom = 4
  speed = 10.0
  flexible = 50.0
  vx = 0.0
  vy = 0.0
  transition = 0
  transitionState = 0
  LastPointCrop = point(0, 0)
  textShowState = 0
  StateOfAd = 0
  AdWaitScore = 0
  adIdNum = VOID
  me.fuseShow_transition("fade")
end

on fuseShow_setcamera me, num
  if (transition <> "fade") then
    transition = 0
  end if
  if (num = 1) then
    zoom = 2
  end if
  if (num = 2) then
    zoom = 4
  end if
end

on fuseShow_targetcamera me, TargerObj
  if ((TargerObject <> TargerObj) and (gpObjects.findPos(TargerObj) <> VOID)) then
    targetspr = gpObjects.getProp(TargerObj)
    TargerObject = TargerObj
    speed = (40.0 + random(10))
    flexible = (20.0 + random(20))
  end if
end

on fuseShow_transition me, tran
  if (StateOfAd = 0) then
    case tran of
      "cameraPan":
        transition = "cameraPan"
        TargerObject = VOID
        speed = (5.0 + random(25))
        flexible = (30.0 + random(20))
      "fade":
        transition = "fade"
        TargerObject = VOID
        transitionbuffer = image(h, w, 16)
        transitionState = 0
        fadeSpeed = [10, 20][random(2)]
    end case
  end if
end

on fuseShow_showtext me, text
  if (StateOfAd = 0) then
    the itemDelimiter = "/"
    if (text.item.count > 1) then
      temp = EMPTY
      repeat with f = 1 to text.item.count
        temp = ((temp & text.item[f]) & RETURN)
      end repeat
      member(getmemnum("screen.text")).text = temp.line[1]
    else
      member(getmemnum("screen.text")).text = text
    end if
    textShowState = 1
    textImageBuffer = member(getmemnum("screen.text")).image.duplicate()
    textShowTime = (12000 + the milliSeconds)
    textBlend = 100
  end if
end

on fuseShow_ad me, fuse_s
  put "&&&&&", fuse_s
  adIdNum = fuse_s.word[1]
  adMember = fuse_s.word[2]
  adLink = fuse_s.word[3]
  if not (the frameLabel contains "jump") then
    set the cursor of sprite the spriteNum of me to [the number of member "cursor_finger", the number of member "cursor_finger_mask"]
  end if
end

on fuseShow_Activate_ad me
  put "Activate_ad", adMember
  if (voidp(adMember) = 0) then
    StateOfAd = 1
    AdWaitScore = 0
    transition = "fade"
    TargerObject = VOID
    transitionbuffer = image(h, w, 16)
    transitionbuffer.fill(rect(0, 0, h, w), rgb(0, 0, 0))
    transitionState = 0
    fadeSpeed = 10
    adShowTime = (12000 + the milliSeconds)
    testTime = the milliSeconds
  end if
end

on mouseDown me
  if voidp(adLink) then
    dontPassEvent()
    return 
  end if
  if (the cursor of sprite me.spriteNum <> 0) then
    if (adLink contains "http:") then
      gotoNetPage(adLink, "_new")
    end if
    sendEPFuseMsg(("ADCLICK" && adIdNum))
  end if
end

on exitFrame me
  global gMyName, gpelleBgImg
  jumperIsUpScreen = 0
  if (voidp(goJumper) = 0) then
    if (((sprite(me.spriteNum).member <> member(getmemnum("screen"))) and (StateOfAd = 0)) or ((sprite(me.spriteNum).member <> member(getmemnum("screen"))) and (goJumper.name = gMyName))) then
      sprite(me.spriteNum).member = member(getmemnum("screen"))
      set the cursor of sprite the spriteNum of me to 0
      adIdNum = VOID
      adLink = VOID
      StateOfAd = 0
      adMember = VOID
      jumperIsUpScreen = 0
    else
      sprite(me.spriteNum).locZ = 32000
      if (StateOfAd and (goJumper.name <> gMyName)) then
        sprite(me.spriteNum).locZ = 34000
      end if
      jumperIsUpScreen = 1
      if (goJumper.pScreenUpOrDown = #down) then
        jumperIsUpScreen = 1
        zoom = 4
        transitionState = 0
        me.cameraCrop(point(goJumper.pMyLoc.locH, goJumper.pMyLoc.locV))
        AdWaitScore = 1
      else
        if (voidp(gpelleBgImg) = 0) then
          member(getmemnum("screen")).image = gpelleBgImg
        end if
      end if
    end if
  end if
  if (((jumperIsUpScreen = 0) and (textShowState = 0)) and (StateOfAd = 0)) then
    if (transition = 0) then
      if (TargerObject <> VOID) then
        me.cameraPan((sprite(targetspr).loc + point(gXFactor, -20)))
      end if
    else
      case transition of
        "cameraPan":
          if (TargerObject <> VOID) then
            me.cameraPan((sprite(targetspr).loc + point((gXFactor / 2), -20)))
          end if
        "fade":
          if (TargerObject <> VOID) then
            if (sprite(me.spriteNum).member <> member(getmemnum("screen"))) then
              sprite(me.spriteNum).member = member(getmemnum("screen"))
              set the cursor of sprite the spriteNum of me to 0
              adIdNum = VOID
              adLink = VOID
            end if
            me.cameraFade((sprite(targetspr).loc + point((gXFactor / 2), -20)))
          end if
      end case
    end if
  else
    if ((StateOfAd <> 0) and (AdWaitScore = 0)) then
      me.ad_system()
    end if
  end if
  if (textShowState <> 0) then
    if voidp(goJumper) then
      me.cameraCrop(LastPointCrop)
    end if
    me.showText()
  end if
end

on showText me
  if (textShowState < textImageBuffer.height) then
    scr.copyPixels(member(getmemnum("screen.bgbox")).image, rect(0, (w - textShowState), h, w), member(getmemnum("screen.bgbox")).rect, [#blend: 40])
    textShowState = (textShowState + 2)
  else
    textShowState = (textShowState + 20)
    textLocH = (textImageBuffer.width - (textShowState - textImageBuffer.height))
    if (textLocH > 0) then
      scr.copyPixels(member(getmemnum("screen.bgbox")).image, rect(0, ((w - textImageBuffer.height) - 2), h, w), member(getmemnum("screen.bgbox")).rect, [#blend: 40])
      scr.copyPixels(textImageBuffer, rect(textLocH, (w - textImageBuffer.height), (h + textLocH), w), textImageBuffer.rect, [#blend: ((100 - (textLocH - 8)) - 20)])
    else
      if (the milliSeconds < textShowTime) then
        if (textBlend > 80) then
          textBlend = (textBlend - 10)
        end if
        scr.copyPixels(member(getmemnum("screen.bgbox")).image, rect(0, ((w - textImageBuffer.height) - 2), h, w), member(getmemnum("screen.bgbox")).rect, [#blend: 40])
        scr.copyPixels(textImageBuffer, rect(0, (w - textImageBuffer.height), h, w), textImageBuffer.rect, [#blend: textBlend])
      else
        if (textBlend > 0) then
          textBlend = (textBlend - 8)
        end if
        if (textBlend <= 0) then
          textBlend = 0
          textShowState = 0
        end if
        scr.copyPixels(member(getmemnum("screen.bgbox")).image, rect(0, ((w - textImageBuffer.height) - 2), h, w), member(getmemnum("screen.bgbox")).rect, [#blend: integer((textBlend / 2))])
        scr.copyPixels(textImageBuffer, rect(0, (w - textImageBuffer.height), h, w), textImageBuffer.rect, [#blend: textBlend])
      end if
    end if
  end if
end

on cameraPan me, TransitionTargetPoint
  x = LastPointCrop.locH
  y = LastPointCrop.locV
  ax = ((TransitionTargetPoint.locH - x) * (speed / 100))
  ay = ((TransitionTargetPoint.locV - y) * (speed / 100))
  vx = ((vx + ax) * (flexible / 100))
  vy = ((vy + ay) * (flexible / 100))
  x = (x + vx)
  y = (y + vy)
  me.cameraCrop(point(x, y))
end

on cameraFade me, TransitionTargetPoint
  me.cameraCrop(TransitionTargetPoint, 1)
  transitionState = (transitionState + fadeSpeed)
  scr.copyPixels(transitionbuffer, transitionbuffer.rect, member("screen").rect, [#blend: transitionState])
  if (transitionState > 99) then
    transition = 0
  end if
end

on ad_system me
  if (transition <> 0) then
    if (textShowState = 0) then
      transitionState = (transitionState + fadeSpeed)
      scr.copyPixels(transitionbuffer, transitionbuffer.rect, member("screen").rect, [#blend: transitionState])
      if (transitionState > 99) then
        transition = 0
      end if
    end if
  else
    if (sprite(me.spriteNum).member.name <> adMember) then
      sprite(me.spriteNum).member = getmemnum(adMember)
    end if
    if (the milliSeconds > adShowTime) then
      put ("Mainosta n�ytetty" && (the milliSeconds - testTime))
      StateOfAd = 0
      transition = "fade"
      TargerObject = VOID
      transitionbuffer = image(h, w, 16)
      transitionbuffer.fill(rect(0, 0, h, w), rgb(0, 0, 0))
      transitionState = 0
      fadeSpeed = 20
      me.cameraCrop(LastPointCrop, 1)
    end if
  end if
end

on cameraCrop me, tpoint, bufferImage
  LastPointCrop = tpoint
  if voidp(goJumper) then
    if (zoom = 8) then
      tpoint = (tpoint + point(0, -6))
    end if
    if sendSprite(targetspr, #FlipedOrNot) then
      if (transition <> 0) then
        tpoint = (tpoint - point((gXFactor / 2), 0))
      else
        tpoint = (tpoint - point((gXFactor * 2), 0))
      end if
    end if
  end if
  if ((tpoint.locH - (h / zoom)) < 0) then
    tpoint.locH = (h / zoom)
  end if
  if ((tpoint.locH + (h / zoom)) > (the stageRight - the stageLeft)) then
    tpoint.locH = ((the stageRight - the stageLeft) - (h / zoom))
  end if
  if ((tpoint.locV - (w / zoom)) < 0) then
    tpoint.locV = (w / zoom)
  end if
  if ((tpoint.locV + (w / zoom)) > 480) then
    tpoint.locV = (480 - (w / zoom))
  end if
  cropRect = rect((tpoint.locH - (h / zoom)), (tpoint.locV - (w / zoom)), (tpoint.locH + (h / zoom)), (tpoint.locV + (w / zoom)))
  Cropscreen = the stage.image.crop(cropRect)
  if (bufferImage = VOID) then
    scr.copyPixels(Cropscreen, rect(0, 0, h, w), Cropscreen.rect)
  else
    transitionbuffer.copyPixels(Cropscreen, rect(0, 0, h, w), Cropscreen.rect)
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #name, [#comment: "Name", #format: #string, #default: "discofloor"])
  return pList
end
