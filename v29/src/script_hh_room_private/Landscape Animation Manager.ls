property pMember, pSprite, pLandscapeType, pAnimMemberId, pAnimMemberCount, pREquiresUpdate, pMaxItemAmount, pTurnPointList, pWallHeight, pAnimInstanceList, pStopped, pSkip, pSkippedFrames, pwidth, pheight, pAnimImage, pMaskImage

on construct me 
  tMemberName = "anim_frame_test"
  if memberExists(tMemberName) then
    pMember = getMember(tMemberName)
  else
    createMember(tMemberName, #bitmap)
    pMember = getMember(tMemberName)
  end if
  pMember.regPoint = point(0, 0)
  pwidth = 720
  pheight = 400
  pSkip = 0
  pAnimInstanceList = []
  pAnimImage = image(1, 1, 8)
  pMaxItemAmount = 15
  pSkippedFrames = 20
  pREquiresUpdate = 1
  pStopped = 1
  tSpriteNum = reserveSprite(me.getID())
  pSprite = sprite(tSpriteNum)
  pSprite.member = pMember
  me.resetImage()
  return(1)
end

on deconstruct me 
  removeUpdate(me.getID())
  tMemberName = "anim_frame_test"
  if memberExists(tMemberName) then
    removeMember(tMemberName)
  end if
  pAnimInstanceList = []
  if pSprite <> void() then
    releaseSprite(pSprite.spriteNum)
  end if
  return(1)
end

on define me, tdata, tTurnOffsetList 
  pwidth = tdata.getAt(#width)
  pheight = tdata.getAt(#height)
  pAnimID = tdata.getAt(#id)
  pRoomTypeID = tdata.getAt(#roomtypeid)
  pWallHeight = tdata.getaProp(#wallheight)
  pLandscapeType = tdata.getaProp(#landscape)
  pAnimMemberId = "lsd_" & pLandscapeType & "_cloud_"
  tMemNum = getmemnum(pAnimMemberId & "0_left")
  if tMemNum = 0 then
    pAnimMemberId = "landscape_cloud_"
    pAnimMemberCount = 3
  else
    pAnimMemberCount = 0
    repeat while tMemNum <> 0
      pAnimMemberCount = pAnimMemberCount + 1
      tMemNum = getmemnum(pAnimMemberId & pAnimMemberCount + 1 & "_left")
    end repeat
  end if
  pTurnPointList = tTurnOffsetList
  me.setStopped(1)
end

on requiresUpdate me 
  return(pREquiresUpdate)
end

on initAnimation me 
  me.resetImage()
  if pAnimMemberCount = 0 then
    return(me.setStopped(1))
  end if
  i = 1
  repeat while i <= pMaxItemAmount
    tProps = [:]
    tProps.setaProp(#type, random(pAnimMemberCount) - 1)
    tProps.setaProp(#memberid, pAnimMemberId)
    tProps.setaProp(#turnPointList, pTurnPointList)
    tProps.setaProp(#wallheight, pWallHeight)
    tProps.setaProp(#landscape, pLandscapeType)
    tCloud = createObject(#temp, "Landscape Cloud")
    if tCloud.define(tProps) then
      pAnimInstanceList.append(tCloud)
    end if
    i = 1 + i
  end repeat
end

on setStopped me, tStopped 
  pStopped = tStopped
  if pStopped then
    removeUpdate(me.getID())
    pAnimInstanceList = []
    pAnimImage = image(1, 1, 32)
    pMember.image = image(1, 1, 32)
  else
    me.initAnimation()
    receiveUpdate(me.getID())
  end if
end

on update me 
  if pStopped then
    return(0)
  end if
  pSkip = pSkip - 1
  if pSkip <= 0 then
    pSkip = pSkippedFrames
  else
    return(0)
  end if
  me.renderFrame()
end

on resetImage me 
  pMember.image = image(pwidth, pheight, 32)
  pAnimImage = image(pwidth, pheight, 32)
  pAnimImage.fill(0, 0, pwidth, pheight, color(112, 112, 112))
  pAnimInstanceList = []
end

on resetSprite me, tVisSpr, tMaskImage 
  pMaskImage = tMaskImage
  pMember.regPoint = point(0, 0)
  pSprite.locH = tVisSpr.locH
  pSprite.locV = tVisSpr.locV
  pSprite.locZ = tVisSpr.locZ + 1
  pSprite.member = pMember
  pSprite.width = tVisSpr.width
  pSprite.height = tVisSpr.height
  pSprite.ink = 36
end

on renderFrame me 
  pAnimImage.fill(pAnimImage.rect, rgb(255, 255, 255))
  repeat while pAnimInstanceList <= undefined
    tAnimInstance = getAt(undefined, undefined)
    tAnimInstance.updateAnim()
    tAnimInstance.render(pAnimImage)
  end repeat
  pMember.fill(image.rect, rgb(255, 255, 255))
  image.copyPixels(pAnimImage, pAnimImage.rect, pAnimImage.rect, [#maskImage:pMaskImage])
  pSprite.member = pMember
  pREquiresUpdate = 1
end

on copyToImage me, tImage 
  repeat while pAnimInstanceList <= undefined
    tAnimInstance = getAt(undefined, tImage)
    tAnimInstance.render(tImage)
  end repeat
  return(tImage)
end

on getImage me 
  pREquiresUpdate = 0
  return(pAnimImage)
end
