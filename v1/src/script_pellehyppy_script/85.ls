property name, transition, TargerObject, StateOfAd, h, w, adMember, transitionbuffer, adLink, adIdNum, textShowState, targetspr, AdWaitScore, LastPointCrop, textImageBuffer, scr, textShowTime, textBlend, speed, vx, flexible, vy, transitionState, fadeSpeed, adShowTime, testTime, zoom

on beginSprite me 
  if voidp(gpShowSprites) then
    gpShowSprites = [:]
  end if
  setAt(gpShowSprites, name, me.spriteNum)
  h = 108
  w = 102
  member("screen").image = member(getmemnum("screen_logo")).image
  scr = member("screen").image
  TargerObject = void()
  zoom = 4
  speed = 10
  flexible = 50
  vx = 0
  vy = 0
  transition = 0
  transitionState = 0
  LastPointCrop = point(0, 0)
  textShowState = 0
  StateOfAd = 0
  AdWaitScore = 0
  adIdNum = void()
  me.fuseShow_transition("fade")
end

on fuseShow_setcamera me, num 
  if transition <> "fade" then
    transition = 0
  end if
  if num = 1 then
    zoom = 2
  end if
  if num = 2 then
    zoom = 4
  end if
end

on fuseShow_targetcamera me, TargerObj 
  if TargerObject <> TargerObj and gpObjects.findPos(TargerObj) <> void() then
    targetspr = gpObjects.getProp(TargerObj)
    TargerObject = TargerObj
    speed = 40 + random(10)
    flexible = 20 + random(20)
  end if
end

on fuseShow_transition me, tran 
  if StateOfAd = 0 then
    if tran = "cameraPan" then
      transition = "cameraPan"
      TargerObject = void()
      speed = 5 + random(25)
      flexible = 30 + random(20)
    else
      if tran = "fade" then
        transition = "fade"
        TargerObject = void()
        transitionbuffer = image(h, w, 16)
        transitionState = 0
        fadeSpeed = [10, 20].getAt(random(2))
      end if
    end if
  end if
end

on fuseShow_showtext me, text 
  if StateOfAd = 0 then
    the itemDelimiter = "/"
    if text.count(#item) > 1 then
      temp = ""
      f = 1
      repeat while f <= text.count(#item)
        temp = temp & text.getProp(#item, f) & "\r"
        f = 1 + f
      end repeat
      member(getmemnum("screen.text")).text = temp.getProp(#line, 1, temp.count(#line) - 1)
    else
      member(getmemnum("screen.text")).text = text
    end if
    textShowState = 1
    textImageBuffer = member(getmemnum("screen.text")).image.duplicate()
    textShowTime = 12000 + the milliSeconds
    textBlend = 100
  end if
end

on fuseShow_ad me, fuse_s 
  put("&&&&&", fuse_s)
  adIdNum = fuse_s.getProp(#word, 1)
  adMember = fuse_s.getProp(#word, 2)
  adLink = fuse_s.getProp(#word, 3)
  if not the frameLabel contains "jump" then
    sprite(sprite(0).number).cursor = ["cursor_finger_mask", sprite(0).number]
  end if
end

on fuseShow_Activate_ad me 
  put("Activate_ad", adMember)
  if voidp(adMember) = 0 then
    StateOfAd = 1
    AdWaitScore = 0
    transition = "fade"
    TargerObject = void()
    transitionbuffer = image(h, w, 16)
    transitionbuffer.fill(rect(0, 0, h, w), rgb(0, 0, 0))
    transitionState = 0
    fadeSpeed = 10
    adShowTime = 12000 + the milliSeconds
    testTime = the milliSeconds
  end if
end

on mouseDown me 
  if voidp(adLink) then
    dontPassEvent()
    return()
  end if
  if sprite(me.spriteNum).cursor <> 0 then
    if adLink contains "http:" then
      gotoNetPage(adLink, "_new")
    end if
    sendEPFuseMsg("ADCLICK" && adIdNum)
  end if
end

on exitFrame me 
  jumperIsUpScreen = 0
  if voidp(goJumper) = 0 then
    if sprite(me.spriteNum).member <> member(getmemnum("screen")) and StateOfAd = 0 or sprite(me.spriteNum).member <> member(getmemnum("screen")) and goJumper.name = gMyName then
      sprite(me.spriteNum).member = member(getmemnum("screen"))
      sprite(me.spriteNum).cursor = 0
      adIdNum = void()
      adLink = void()
      StateOfAd = 0
      adMember = void()
      jumperIsUpScreen = 0
    else
      sprite(me.spriteNum).locZ = 32000
      if StateOfAd and goJumper.name <> gMyName then
        sprite(me.spriteNum).locZ = 34000
      end if
      jumperIsUpScreen = 1
      if goJumper.pScreenUpOrDown = #down then
        jumperIsUpScreen = 1
        zoom = 4
        transitionState = 0
        me.cameraCrop(point(goJumper.pMyLoc.locH, goJumper.pMyLoc.locV))
        AdWaitScore = 1
      else
        if voidp(gpelleBgImg) = 0 then
          member(getmemnum("screen")).image = gpelleBgImg
        end if
      end if
    end if
  end if
  if jumperIsUpScreen = 0 and textShowState = 0 and StateOfAd = 0 then
    if transition = 0 then
      if TargerObject <> void() then
        me.cameraPan(sprite(targetspr).loc + point(gXFactor, -20))
      end if
    else
      if transition = "cameraPan" then
        if TargerObject <> void() then
          me.cameraPan(sprite(targetspr).loc + point(gXFactor / 2, -20))
        end if
      else
        if transition = "fade" then
          if TargerObject <> void() then
            if sprite(me.spriteNum).member <> member(getmemnum("screen")) then
              sprite(me.spriteNum).member = member(getmemnum("screen"))
              sprite(me.spriteNum).cursor = 0
              adIdNum = void()
              adLink = void()
            end if
            me.cameraFade(sprite(targetspr).loc + point(gXFactor / 2, -20))
          end if
        end if
      end if
    end if
  else
    if StateOfAd <> 0 and AdWaitScore = 0 then
      me.ad_system()
    end if
  end if
  if textShowState <> 0 then
    if voidp(goJumper) then
      me.cameraCrop(LastPointCrop)
    end if
    me.showText()
  end if
end

on showText me 
  if textShowState < textImageBuffer.height then
    scr.copyPixels(member(getmemnum("screen.bgbox")).image, rect(0, w - textShowState, h, w), member(getmemnum("screen.bgbox")).rect, [#blend:40])
    textShowState = textShowState + 2
  else
    textShowState = textShowState + 20
    textLocH = textImageBuffer.width - textShowState - textImageBuffer.height
    if textLocH > 0 then
      scr.copyPixels(member(getmemnum("screen.bgbox")).image, rect(0, w - textImageBuffer.height - 2, h, w), member(getmemnum("screen.bgbox")).rect, [#blend:40])
      scr.copyPixels(textImageBuffer, rect(textLocH, w - textImageBuffer.height, h + textLocH, w), textImageBuffer.rect, [#blend:100 - textLocH - 8 - 20])
    else
      if the milliSeconds < textShowTime then
        if textBlend > 80 then
          textBlend = textBlend - 10
        end if
        scr.copyPixels(member(getmemnum("screen.bgbox")).image, rect(0, w - textImageBuffer.height - 2, h, w), member(getmemnum("screen.bgbox")).rect, [#blend:40])
        scr.copyPixels(textImageBuffer, rect(0, w - textImageBuffer.height, h, w), textImageBuffer.rect, [#blend:textBlend])
      else
        if textBlend > 0 then
          textBlend = textBlend - 8
        end if
        if textBlend <= 0 then
          textBlend = 0
          textShowState = 0
        end if
        scr.copyPixels(member(getmemnum("screen.bgbox")).image, rect(0, w - textImageBuffer.height - 2, h, w), member(getmemnum("screen.bgbox")).rect, [#blend:integer(textBlend / 2)])
        scr.copyPixels(textImageBuffer, rect(0, w - textImageBuffer.height, h, w), textImageBuffer.rect, [#blend:textBlend])
      end if
    end if
  end if
end

on cameraPan me, TransitionTargetPoint 
  x = LastPointCrop.locH
  y = LastPointCrop.locV
  ax = TransitionTargetPoint.locH - x * speed / 100
  ay = TransitionTargetPoint.locV - y * speed / 100
  vx = vx + ax * flexible / 100
  vy = vy + ay * flexible / 100
  x = x + vx
  y = y + vy
  me.cameraCrop(point(x, y))
end

on cameraFade me, TransitionTargetPoint 
  me.cameraCrop(TransitionTargetPoint, 1)
  transitionState = transitionState + fadeSpeed
  scr.copyPixels(transitionbuffer, transitionbuffer.rect, member("screen").rect, [#blend:transitionState])
  if transitionState > 99 then
    transition = 0
  end if
end

on ad_system me 
  if transition <> 0 then
    if textShowState = 0 then
      transitionState = transitionState + fadeSpeed
      scr.copyPixels(transitionbuffer, transitionbuffer.rect, member("screen").rect, [#blend:transitionState])
      if transitionState > 99 then
        transition = 0
      end if
    end if
  else
    if sprite(me.spriteNum).member.name <> adMember then
      sprite(me.spriteNum).member = getmemnum(adMember)
    end if
    if the milliSeconds > adShowTime then
      put("Mainosta n�ytetty" && the milliSeconds - testTime)
      StateOfAd = 0
      transition = "fade"
      TargerObject = void()
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
    if zoom = 8 then
      tpoint = tpoint + point(0, -6)
    end if
    if sendSprite(targetspr, #FlipedOrNot) then
      if transition <> 0 then
        tpoint = tpoint - point(gXFactor / 2, 0)
      else
        tpoint = tpoint - point(gXFactor * 2, 0)
      end if
    end if
  end if
  if tpoint.locH - h / zoom < 0 then
    tpoint.locH = h / zoom
  end if
  if tpoint.locH + h / zoom > the stageRight - the stageLeft then
    tpoint.locH = the stageRight - the stageLeft - h / zoom
  end if
  if tpoint.locV - w / zoom < 0 then
    tpoint.locV = w / zoom
  end if
  if tpoint.locV + w / zoom > 480 then
    tpoint.locV = 480 - w / zoom
  end if
  cropRect = rect(tpoint.locH - h / zoom, tpoint.locV - w / zoom, tpoint.locH + h / zoom, tpoint.locV + w / zoom)
  Cropscreen = the stage.image.crop(cropRect)
  if bufferImage = void() then
    scr.copyPixels(Cropscreen, rect(0, 0, h, w), Cropscreen.rect)
  else
    transitionbuffer.copyPixels(Cropscreen, rect(0, 0, h, w), Cropscreen.rect)
  end if
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #name, [#comment:"Name", #format:#string, #default:"discofloor"])
  return(pList)
end
