property pREquiresUpdate, pwidth, pheight, pRoomType, pAnimBottom, pAnimTop, pAnimImage, pAnimID, pScale, pSize, pAnimInstanceList, pIsUpdated, pTurnPoint, pMember, pClouds, pSkip, pSkippedFrames, pMaxItemAmount, pStopped

on construct me
  tMemberName = "anim_frame_test"
  if memberExists(tMemberName) then
    pMember = getMember(tMemberName)
  else
    createMember(tMemberName, #bitmap)
    pMember = getMember(tMemberName)
  end if
  pwidth = 720
  pheight = 400
  pAnimBottom = 400
  pAnimTop = 200
  pSkip = 0
  pTurnPoint = pwidth / 2
  pAnimInstanceList = [:]
  pAnimImage = image(1, 1, 8)
  pMaxItemAmount = 15
  pSkippedFrames = 20
  pREquiresUpdate = 1
  pStopped = 1
  return 1
end

on deconstruct me
  tMemberName = "anim_frame_test"
  if memberExists(tMemberName) then
    removeMember(tMemberName)
  end if
  repeat with pAnimInstance in pAnimInstanceList
    removeObject(pAnimInstance.getID())
  end repeat
  removeUpdate(me.getID())
  return 1
end

on define me, tdata
  pwidth = tdata[#width]
  pheight = tdata[#height]
  pAnimID = tdata[#id]
  pRoomTypeID = tdata[#roomtypeid]
  if variableExists("landscape.def." & pRoomTypeID) then
    tRoomDef = getVariableValue("landscape.def." & pRoomTypeID)
    pTurnPoint = tRoomDef[#middle]
    pAnimBottom = tRoomDef[#anim_bottom]
    pAnimTop = tRoomDef[#anim_top]
  end if
  pTurnPoint = pTurnPoint + tdata[#offset]
  me.initAnimation()
  receiveUpdate(me.getID())
end

on requiresUpdate me
  return pREquiresUpdate
end

on initAnimation me
  pAnimImage = image(pwidth, pheight, 8)
  repeat with i = 1 to pMaxItemAmount
    tProps = [:]
    tProps.setaProp(#type, random(3) - 1)
    tProps.setaProp(#turnpoint, pTurnPoint)
    tProps.setaProp(#initminv, pAnimTop)
    tProps.setaProp(#initmaxv, pAnimBottom)
    tCloud = createObject(getUniqueID(), "Landscape Cloud")
    tCloud.define(tProps)
    pAnimInstanceList.setaProp(tCloud.getID(), tCloud)
  end repeat
  me.renderFrame()
end

on setStopped me, tStopped
  pStopped = tStopped
end

on update me
  if pStopped then
    return 0
  end if
  pSkip = pSkip - 1
  if pSkip <= 0 then
    pSkip = pSkippedFrames
  else
    return 0
  end if
  me.renderFrame()
end

on renderFrame me
  pAnimImage.fill(pAnimImage.rect, rgb(255, 51, 255))
  repeat with tAnimInstance in pAnimInstanceList
    tAnimInstance.updateAnim()
    tAnimInstance.render(pAnimImage)
  end repeat
  pMember.image = pAnimImage
  pREquiresUpdate = 1
end

on getImage me
  pREquiresUpdate = 0
  return pAnimImage
end
