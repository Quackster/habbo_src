property pSprite, pScrImg, pwidth, pheight, pVX, pVY, pTargetObj, pTargetSpr, pXFactor, pZoom, pSpeed, pFlexible, pTransitBuffer, pTransitState, pTargetPoint, pLastCropPoint, pFadeSpeed, pTransition, pTextImgBuffer, pTextShowState, pTextShowTime, pTextBlend, StateOfAd, adShowTime, adMember, adLink, adIdNum, AdWaitScore, pTextBgBoxImg, pPaaluPlayers, pWriterID

on construct me
  pheight = 108
  pwidth = 102
  pVX = 0.0
  pVY = 0.0
  pXFactor = 32
  pZoom = 4
  pSpeed = 10.0
  pFlexible = 50.0
  pTransitState = 0
  pTargetObj = VOID
  pTargetSpr = VOID
  pLastCropPoint = point(0, 0)
  pSprite = getThread(#room).getInterface().getRoomVisualizer().getSprById("cam1")
  pScrImg = member(getmemnum("fuse_screen")).image
  pTextBgBoxImg = image(1, 1, 24)
  pTargetSpr = pSprite
  pTextBgBoxImg.fill(pTextBgBoxImg.rect, rgb(0, 0, 0))
  if memberExists("fuse_screen_logo") then
    pScrImg.copyPixels(member(getmemnum("fuse_screen_logo")).image, pScrImg.rect, pScrImg.rect)
  end if
  pTransition = 0
  pTextShowState = 0
  StateOfAd = 0
  AdWaitScore = 0
  adIdNum = VOID
  pPaaluPlayers = [:]
  pWriterID = getUniqueID()
  tMetrics = getStructVariable("struct.font.bold")
  tMetrics.setaProp(#color, rgb("#FFFF99"))
  tMetrics.setaProp(#bgColor, rgb(0, 0, 0))
  if not createWriter(pWriterID, tMetrics) then
    return error(me, "Couldn't create writer for screen!", #construct)
  else
    getWriter(pWriterID).define([#alignment: #center, #rect: rect(0, 0, 108, 10)])
    me.fuseShow_transition("fade")
    receivePrepare(me.getID())
    return 1
  end if
end

on deconstruct me
  removeWriter(pWriterID)
  removePrepare(me.getID())
  return 1
end

on activatePaaluPlayer me, tName, tObj
  pPaaluPlayers[tName] = tObj
end

on deActivatePaaluPlayer me, tName
  if not voidp(pPaaluPlayers[tName]) then
    pPaaluPlayers.deleteProp(tName)
  end if
end

on fuseShow_setcamera me, tNumber
  if pTransition <> "fade" then
    pTransition = 0
  end if
  if tNumber = 1 then
    pZoom = 2
  end if
  if tNumber = 2 then
    pZoom = 4
  end if
end

on fuseShow_targetcamera me, tTargetObj
  tUserObj = getThread(#room).getComponent().getUserObject(tTargetObj)
  if not tUserObj then
    pTargetObj = VOID
    pTargetSpr = pSprite
    return error(me, "User object not found:" && tTargetObj, #fuseShow_targetcamera)
  end if
  pTargetSpr = tUserObj.getSprites()[1]
  pTargetObj = tTargetObj
  pSpeed = 50.0 + random(10)
  pFlexible = 10.0 + random(20)
end

on fuseShow_transition me, tTran
  if StateOfAd = 0 then
    case tTran of
      "cameraPan":
        pTransition = "cameraPan"
        pTargetObj = VOID
        pSpeed = 5.0 + random(25)
        pFlexible = 30.0 + random(20)
      "fade":
        pTransition = "fade"
        pTargetObj = VOID
        pTransitBuffer = image(pheight, pwidth, 16)
        pTransitState = 0
        pFadeSpeed = random(2) * 10
    end case
  end if
end

on fuseShow_showtext me, tText
  if StateOfAd = 0 then
    tDelim = the itemDelimiter
    the itemDelimiter = "/"
    if tText.item.count > 1 then
      tTemp = EMPTY
      repeat with f = 1 to tText.item.count
        tTemp = tTemp & tText.item[f] & RETURN
      end repeat
      tText = tTemp.line[1..tTemp.line.count - 1]
    end if
    the itemDelimiter = tDelim
    tWriObj = getWriter(pWriterID)
    if tWriObj <> 0 then
      pTextShowState = 1
      pTextImgBuffer = tWriObj.render(tText)
      pTextShowTime = 5000 + the milliSeconds
      pTextBlend = 100
    end if
  end if
end

on fuseShow_ad me, tFuse_s
  adIdNum = tFuse_s.word[1]
  adMember = tFuse_s.word[2]
  adLink = tFuse_s.word[3]
  pTextShowState = 0
end

on fuseShow_Activate_ad me
  if not voidp(adMember) then
    StateOfAd = 1
    AdWaitScore = 0
    pTransition = "fade"
    pTargetObj = VOID
    pTransitState = 0
    pFadeSpeed = 10
    adShowTime = 12000 + the milliSeconds
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
    return 0
  end if
  if the cursor of sprite me.spriteNum <> 0 then
    if adLink contains "http:" then
      openNetPage(adLink)
    end if
    getConnection(getVariable("connection.info.id")).send("ADCLICK", adIdNum)
  end if
end

on prepare me
  if pPaaluPlayers.count > 0 then
    if pPaaluPlayers.count = 2 then
      if abs(pPaaluPlayers[1].getBalance()) < abs(pPaaluPlayers[2].getBalance()) then
        tloc = pPaaluPlayers[1].pSprite.loc
      else
        tloc = pPaaluPlayers[2].pSprite.loc
      end if
    else
      tloc = pPaaluPlayers[1].pSprite.loc
    end if
    bufferImage = VOID
    pZoom = 4
    pTransitState = 0
    me.cameraCrop(tloc)
    AdWaitScore = 1
    StateOfAd = 0
  else
    if (pTextShowState = 0) and (StateOfAd = 0) then
      if pTransition = 0 then
        if not voidp(pTargetObj) then
          me.cameraPan(pTargetSpr.loc)
        end if
      else
        case pTransition of
          "cameraPan":
            if not voidp(pTargetObj) then
              me.cameraPan(pTargetSpr.loc)
            end if
          "fade":
            if not voidp(pTargetObj) then
              if pSprite.member <> member(getmemnum("fuse_screen")) then
                pSprite.member = member(getmemnum("fuse_screen"))
                pSprite.cursor = 0
                adIdNum = VOID
                adLink = VOID
              end if
              me.cameraFade(pTargetSpr.loc)
            end if
        end case
      end if
    else
      if (StateOfAd <> 0) and (AdWaitScore = 0) then
        me.ad_system()
      end if
    end if
  end if
  if pTextShowState <> 0 then
    me.cameraCrop(pLastCropPoint)
    me.showText()
  end if
end

on showText me
  if pTextShowState < pTextImgBuffer.height then
    pScrImg.copyPixels(pTextBgBoxImg, rect(0, pwidth - pTextShowState, pheight, pwidth), pTextBgBoxImg.rect, [#blend: 40])
    pTextShowState = pTextShowState + 2
  else
    pTextShowState = pTextShowState + 20
    textLocH = pTextImgBuffer.width - (pTextShowState - pTextImgBuffer.height)
    if textLocH > 0 then
      pScrImg.copyPixels(pTextBgBoxImg, rect(0, pwidth - pTextImgBuffer.height - 2, pheight, pwidth), pTextBgBoxImg.rect, [#blend: 40])
      pScrImg.copyPixels(pTextImgBuffer, rect(textLocH, pwidth - pTextImgBuffer.height, pheight + textLocH, pwidth), pTextImgBuffer.rect, [#blend: 100 - (textLocH - 8) - 20])
    else
      if the milliSeconds < pTextShowTime then
        if pTextBlend > 80 then
          pTextBlend = pTextBlend - 10
        end if
        pScrImg.copyPixels(pTextBgBoxImg, rect(0, pwidth - pTextImgBuffer.height - 2, pheight, pwidth), pTextBgBoxImg.rect, [#blend: 40])
        pScrImg.copyPixels(pTextImgBuffer, rect(0, pwidth - pTextImgBuffer.height, pheight, pwidth), pTextImgBuffer.rect, [#blend: pTextBlend])
      else
        if pTextBlend > 0 then
          pTextBlend = pTextBlend - 8
        end if
        if pTextBlend <= 0 then
          pTextBlend = 0
          pTextShowState = 0
        end if
        pScrImg.copyPixels(pTextBgBoxImg, rect(0, pwidth - pTextImgBuffer.height - 2, pheight, pwidth), pTextBgBoxImg.rect, [#blend: integer(pTextBlend / 2)])
        pScrImg.copyPixels(pTextImgBuffer, rect(0, pwidth - pTextImgBuffer.height, pheight, pwidth), pTextImgBuffer.rect, [#blend: pTextBlend])
      end if
    end if
  end if
end

on cameraPan me, tTransitionTargetPoint
  tX = pLastCropPoint.locH
  tY = pLastCropPoint.locV
  tAX = (tTransitionTargetPoint.locH - tX) * (pSpeed / 100)
  tAY = (tTransitionTargetPoint.locV - tY) * (pSpeed / 100)
  pVX = (pVX + tAX) * (pFlexible / 100)
  pVY = (pVY + tAY) * (pFlexible / 100)
  tX = tX + pVX
  tY = tY + pVY
  me.cameraCrop(point(tX, tY))
end

on cameraFade me, tTransitionTargetPoint
  me.cameraCrop(tTransitionTargetPoint, 1)
  pTransitState = pTransitState + pFadeSpeed
  pScrImg.copyPixels(pTransitBuffer, pTransitBuffer.rect, member(getmemnum("fuse_screen")).rect, [#blend: pTransitState])
  if pTransitState > 99 then
    pTransition = 0
  end if
end

on ad_system me
  if pTransition <> 0 then
    if pTextShowState = 0 then
      pTransitState = pTransitState + pFadeSpeed
      pScrImg.copyPixels(pTransitBuffer, pTransitBuffer.rect, member(getmemnum("fuse_screen")).rect, [#blend: pTransitState])
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
      pTargetObj = VOID
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
    return error(me, "Target sprite not defined!", #cameraCrop)
  end if
  tpoint = tpoint + point(0, -18)
  if pZoom = 8 then
    tpoint = tpoint + point(0, -6)
  end if
  if pTargetSpr.flipH = 0 then
    tpoint = tpoint + point(pXFactor, 0)
  end if
  if (tpoint.locH - (pheight / pZoom)) < 0 then
    tpoint.locH = pheight / pZoom
  end if
  if (tpoint.locH + (pheight / pZoom)) > (the stageRight - the stageLeft) then
    tpoint.locH = the stageRight - the stageLeft - (pheight / pZoom)
  end if
  if (tpoint.locV - (pwidth / pZoom)) < 0 then
    tpoint.locV = pwidth / pZoom
  end if
  if (tpoint.locV + (pwidth / pZoom)) > 480 then
    tpoint.locV = 480 - (pwidth / pZoom)
  end if
  tCropRect = rect(tpoint.locH - (pheight / pZoom), tpoint.locV - (pwidth / pZoom), tpoint.locH + (pheight / pZoom), tpoint.locV + (pwidth / pZoom))
  tCropScrImg = (the stage).image.crop(tCropRect)
  if voidp(tBufferImage) then
    pScrImg.copyPixels(tCropScrImg, rect(0, 0, pheight, pwidth), tCropScrImg.rect)
  else
    pTransitBuffer.copyPixels(tCropScrImg, rect(0, 0, pheight, pwidth), tCropScrImg.rect)
  end if
end
