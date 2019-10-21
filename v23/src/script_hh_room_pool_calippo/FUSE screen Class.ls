property pSprite, pScrImg, pWriterID, pTransition, StateOfAd, pheight, pwidth, adMember, pTransitBuffer, adLink, adIdNum, pJumperObj, pTextShowState, pTargetObj, pTargetSpr, AdWaitScore, pLastCropPoint, pTextImgBuffer, pTextShowTime, pTextBlend, pSpeed, pVX, pFlexible, pVY, pTransitState, pFadeSpeed, adShowTime, pZoom, pXFactor

on construct me 
  pheight = 108
  pwidth = 102
  pVX = 0
  pVY = 0
  pXFactor = 32
  pZoom = 4
  pSpeed = 10
  pFlexible = 50
  pTransitState = 0
  pTargetObj = void()
  pTargetSpr = void()
  pLastCropPoint = point(0, 0)
  pSprite = getThread(#room).getInterface().getRoomVisualizer().getSprById("cam1")
  pScrImg = member(getmemnum("fuse_screen")).image
  pTargetSpr = pSprite
  if memberExists("fuse_screen_logo") then
    pScrImg.copyPixels(member(getmemnum("fuse_screen_logo")).image, pScrImg.rect, pScrImg.rect)
  end if
  pTransition = 0
  pTextShowState = 0
  StateOfAd = 0
  AdWaitScore = 0
  adIdNum = void()
  pWriterID = getUniqueID()
  tMetrics = getStructVariable("struct.font.bold")
  tMetrics.setaProp(#color, rgb("#FFFF99"))
  tMetrics.setaProp(#bgColor, rgb(0, 0, 0))
  if not createWriter(pWriterID, tMetrics) then
    return(error(me, "Couldn't create writer for screen!", #construct))
  else
    getWriter(pWriterID).define([#alignment:#center, #rect:rect(0, 0, 108, 10)])
    receivePrepare(me.getID())
    return TRUE
  end if
end

on deconstruct me 
  removeWriter(pWriterID)
  removePrepare(me.getID())
  return TRUE
end

on fuseShow_setcamera me, tNumber 
  if pTransition <> "fade" then
    pTransition = 0
  end if
  if (tNumber = 1) then
    pZoom = 2
  end if
  if (tNumber = 2) then
    pZoom = 4
  end if
end

on fuseShow_targetcamera me, tTrgUserID 
  if not getThread(#room).getComponent().userObjectExists(tTrgUserID) then
    tTrgUserID = void()
    pTargetSpr = pSprite
    return(error(me, "User object not found:" && tTrgUserID, #fuseShow_targetcamera))
  end if
  pTargetSpr = getThread(#room).getComponent().getUserObject(tTrgUserID).getSprites().getAt(1)
  pTargetObj = tTrgUserID
  pSpeed = (50 + random(10))
  pFlexible = (10 + random(20))
  return TRUE
end

on fuseShow_transition me, tTran 
  if (StateOfAd = 0) then
    if (tTran = "cameraPan") then
      pTransition = "cameraPan"
      pTargetObj = void()
      pSpeed = (5 + random(25))
      pFlexible = (30 + random(20))
    else
      if (tTran = "fade") then
        pTransition = "fade"
        pTargetObj = void()
        pTransitBuffer = image(pheight, pwidth, 16)
        pTransitState = 0
        pFadeSpeed = (random(2) * 10)
      end if
    end if
  end if
end

on fuseShow_showtext me, tText 
  if (StateOfAd = 0) then
    tDelim = the itemDelimiter
    the itemDelimiter = "/"
    if tText.count(#item) > 1 then
      tTemp = ""
      f = 1
      repeat while f <= tText.count(#item)
        tTemp = tTemp & tText.getProp(#item, f) & "\r"
        f = (1 + f)
      end repeat
      tText = tTemp.getProp(#line, 1, (tTemp.count(#line) - 1))
    end if
    the itemDelimiter = tDelim
    tWriObj = getWriter(pWriterID)
    if tWriObj <> 0 then
      pTextShowState = 1
      pTextImgBuffer = tWriObj.render(tText)
      pTextShowTime = (12000 + the milliSeconds)
      pTextBlend = 100
    end if
  end if
end

on fuseShow_ad me, tFuse_s 
  adIdNum = tFuse_s.getProp(#word, 1)
  adMember = tFuse_s.getProp(#word, 2)
  adLink = tFuse_s.getProp(#word, 3)
  pTextShowState = 0
end

on fuseShow_Activate_ad me 
  if not voidp(adMember) then
    StateOfAd = 1
    AdWaitScore = 0
    pTransition = "fade"
    pTargetObj = void()
    pTransitState = 0
    pFadeSpeed = 10
    adShowTime = (12000 + the milliSeconds)
    pTransitBuffer = image(pheight, pwidth, 16)
    pTransitBuffer.fill(rect(0, 0, pheight, pwidth), rgb(0, 0, 0))
    if not voidp(pSprite) then
      pSprite.cursor = [member(getmemnum("cursor.finger")), member(getmemnum("cursor.finger.mask"))]
    end if
  end if
end

on mouseDown me 
  if voidp(adLink) then
    dontPassEvent()
    return FALSE
  end if
  if sprite(me.spriteNum).cursor <> 0 then
    if adLink contains "http:" then
      openNetPage(adLink)
    end if
    getConnection(getVariable("connection.info.id")).send("ADCLICK", adIdNum)
  end if
end

on prepare me 
  pJumperObj = void()
  if objectExists(#playpackpelle_obj) then
    pJumperObj = getObject(#playpackpelle_obj)
  else
    if objectExists(#jumpingpelle_obj) then
      pJumperObj = getObject(#jumpingpelle_obj)
    end if
  end if
  if not voidp(pJumperObj) then
    if pJumperObj.pJumpReady then
      pJumperObj = void()
    else
      if (pJumperObj.pScreenUpOrDown = #down) then
        bufferImage = void()
        pZoom = 4
        pTransitState = 0
        me.cameraCrop((pJumperObj.pMyLoc - point(0, 2)))
        AdWaitScore = 1
        StateOfAd = 0
      else
        if not voidp(pJumperObj.pPelleBgImg) then
          member(getmemnum("fuse_screen")).image.copyPixels(pJumperObj.pPelleBgImg, pScrImg.rect, pScrImg.rect)
        end if
      end if
    end if
  end if
  if voidp(pJumperObj) and (pTextShowState = 0) and (StateOfAd = 0) then
    if (pTransition = 0) then
      if not voidp(pTargetObj) then
        me.cameraPan(pTargetSpr.loc)
      end if
    else
      if (pTransition = "cameraPan") then
        if not voidp(pTargetObj) then
          me.cameraPan(pTargetSpr.loc)
        end if
      else
        if (pTransition = "fade") then
          if not voidp(pTargetObj) then
            if pSprite.member <> member(getmemnum("fuse_screen")) then
              pSprite.member = member(getmemnum("fuse_screen"))
              pSprite.cursor = 0
              adIdNum = void()
              adLink = void()
            end if
            me.cameraFade(pTargetSpr.loc)
          end if
        end if
      end if
    end if
  else
    if StateOfAd <> 0 and (AdWaitScore = 0) then
      me.ad_system()
    end if
  end if
  if pTextShowState <> 0 then
    if voidp(pJumperObj) then
      me.cameraCrop(pLastCropPoint)
    end if
    me.showText()
  end if
end

on showText me 
  if pTextShowState < pTextImgBuffer.height then
    pScrImg.copyPixels(member(getmemnum("fuse_screen.bgbox")).image, rect(0, (pwidth - pTextShowState), pheight, pwidth), member(getmemnum("fuse_screen.bgbox")).rect, [#blend:40])
    pTextShowState = (pTextShowState + 2)
  else
    pTextShowState = (pTextShowState + 20)
    textLocH = (pTextImgBuffer.width - (pTextShowState - pTextImgBuffer.height))
    if textLocH > 0 then
      pScrImg.copyPixels(member(getmemnum("fuse_screen.bgbox")).image, rect(0, ((pwidth - pTextImgBuffer.height) - 2), pheight, pwidth), member(getmemnum("fuse_screen.bgbox")).rect, [#blend:40])
      pScrImg.copyPixels(pTextImgBuffer, rect(textLocH, (pwidth - pTextImgBuffer.height), (pheight + textLocH), pwidth), pTextImgBuffer.rect, [#blend:((100 - (textLocH - 8)) - 20)])
    else
      if the milliSeconds < pTextShowTime then
        if pTextBlend > 80 then
          pTextBlend = (pTextBlend - 10)
        end if
        pScrImg.copyPixels(member(getmemnum("fuse_screen.bgbox")).image, rect(0, ((pwidth - pTextImgBuffer.height) - 2), pheight, pwidth), member(getmemnum("fuse_screen.bgbox")).rect, [#blend:40])
        pScrImg.copyPixels(pTextImgBuffer, rect(0, (pwidth - pTextImgBuffer.height), pheight, pwidth), pTextImgBuffer.rect, [#blend:pTextBlend])
      else
        if pTextBlend > 0 then
          pTextBlend = (pTextBlend - 8)
        end if
        if pTextBlend <= 0 then
          pTextBlend = 0
          pTextShowState = 0
        end if
        pScrImg.copyPixels(member(getmemnum("fuse_screen.bgbox")).image, rect(0, ((pwidth - pTextImgBuffer.height) - 2), pheight, pwidth), member(getmemnum("fuse_screen.bgbox")).rect, [#blend:integer((pTextBlend / 2))])
        pScrImg.copyPixels(pTextImgBuffer, rect(0, (pwidth - pTextImgBuffer.height), pheight, pwidth), pTextImgBuffer.rect, [#blend:pTextBlend])
      end if
    end if
  end if
end

on cameraPan me, tTransitionTargetPoint 
  tX = pLastCropPoint.locH
  tY = pLastCropPoint.locV
  tAX = ((tTransitionTargetPoint.locH - tX) * (pSpeed / 100))
  tAY = ((tTransitionTargetPoint.locV - tY) * (pSpeed / 100))
  pVX = ((pVX + tAX) * (pFlexible / 100))
  pVY = ((pVY + tAY) * (pFlexible / 100))
  tX = (tX + pVX)
  tY = (tY + pVY)
  me.cameraCrop(point(tX, tY))
end

on cameraFade me, tTransitionTargetPoint 
  me.cameraCrop(tTransitionTargetPoint, 1)
  pTransitState = (pTransitState + pFadeSpeed)
  pScrImg.copyPixels(pTransitBuffer, pTransitBuffer.rect, member(getmemnum("fuse_screen")).rect, [#blend:pTransitState])
  if pTransitState > 99 then
    pTransition = 0
  end if
end

on ad_system me 
  if pTransition <> 0 then
    if (pTextShowState = 0) then
      pTransitState = (pTransitState + pFadeSpeed)
      pScrImg.copyPixels(pTransitBuffer, pTransitBuffer.rect, member(getmemnum("fuse_screen")).rect, [#blend:pTransitState])
      if pTransitState > 99 then
        pTransition = 0
      end if
    end if
  else
    if pSprite.member.name <> adMember then
      pSprite.member = member(getmemnum(adMember))
    end if
    if the milliSeconds > adShowTime then
      StateOfAd = 0
      pTransition = "fade"
      pTargetObj = void()
      pTransitBuffer = image(pheight, pwidth, 16)
      pTransitBuffer.fill(rect(0, 0, pheight, pwidth), rgb(0, 0, 0))
      pTransitState = 0
      pFadeSpeed = 20
      me.cameraCrop(pLastCropPoint, 1)
    end if
  end if
end

on cameraCrop me, tpoint, tBufferImage 
  pLastCropPoint = tpoint
  if voidp(pTargetSpr) then
    return(error(me, "Target sprite not defined!", #cameraCrop))
  end if
  if voidp(pJumperObj) then
    tpoint = (tpoint + point(0, -18))
    if (pZoom = 8) then
      tpoint = (tpoint + point(0, -6))
    end if
    if (pTargetSpr.flipH = 0) then
      tpoint = (tpoint + point(pXFactor, 0))
    end if
  end if
  if (tpoint.locH - (pheight / pZoom)) < 0 then
    tpoint.locH = (pheight / pZoom)
  end if
  if (tpoint.locH + (pheight / pZoom)) > (the stageRight - the stageLeft) then
    tpoint.locH = ((the stageRight - the stageLeft) - (pheight / pZoom))
  end if
  if (tpoint.locV - (pwidth / pZoom)) < 0 then
    tpoint.locV = (pwidth / pZoom)
  end if
  if (tpoint.locV + (pwidth / pZoom)) > 480 then
    tpoint.locV = (480 - (pwidth / pZoom))
  end if
  tCropRect = rect((tpoint.locH - (pheight / pZoom)), (tpoint.locV - (pwidth / pZoom)), (tpoint.locH + (pheight / pZoom)), (tpoint.locV + (pwidth / pZoom)))
  tCropScrImg = the stage.image.crop(tCropRect)
  if voidp(tBufferImage) then
    pScrImg.copyPixels(tCropScrImg, rect(0, 0, pheight, pwidth), tCropScrImg.rect)
  else
    pTransitBuffer.copyPixels(tCropScrImg, rect(0, 0, pheight, pwidth), tCropScrImg.rect)
  end if
end
