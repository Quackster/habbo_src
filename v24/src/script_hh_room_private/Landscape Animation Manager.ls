on construct(me)
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
  pAnimInstanceList = []
  pAnimImage = image(1, 1, 8)
  pMaxItemAmount = 15
  pSkippedFrames = 20
  pREquiresUpdate = 1
  pStopped = 1
  return(1)
  exit
end

on deconstruct(me)
  tMemberName = "anim_frame_test"
  if memberExists(tMemberName) then
    removeMember(tMemberName)
  end if
  repeat while me <= undefined
    pAnimInstance = getAt(undefined, undefined)
    removeObject(pAnimInstance.getID())
  end repeat
  removeUpdate(me.getID())
  return(1)
  exit
end

on define(me, tdata)
  pwidth = tdata.getAt(#width)
  pheight = tdata.getAt(#height)
  pAnimID = tdata.getAt(#id)
  pRoomTypeID = tdata.getAt(#roomtypeid)
  if variableExists("landscape.def." & pRoomTypeID) then
    tRoomDef = getVariableValue("landscape.def." & pRoomTypeID)
    pTurnPoint = tRoomDef.getAt(#middle)
    pAnimBottom = tRoomDef.getAt(#anim_bottom)
    pAnimTop = tRoomDef.getAt(#anim_top)
  end if
  pTurnPoint = pTurnPoint + tdata.getAt(#offset)
  me.initAnimation()
  receiveUpdate(me.getID())
  exit
end

on requiresUpdate(me)
  return(pREquiresUpdate)
  exit
end

on initAnimation(me)
  pAnimImage = image(pwidth, pheight, 8)
  i = 1
  repeat while i <= pMaxItemAmount
    tProps = []
    tProps.setaProp(#type, random(3) - 1)
    tProps.setaProp(#turnpoint, pTurnPoint)
    tProps.setaProp(#initminv, pAnimTop)
    tProps.setaProp(#initmaxv, pAnimBottom)
    tCloud = createObject(getUniqueID(), "Landscape Cloud")
    tCloud.define(tProps)
    pAnimInstanceList.setaProp(tCloud.getID(), tCloud)
    i = 1 + i
  end repeat
  me.renderFrame()
  exit
end

on setStopped(me, tStopped)
  pStopped = tStopped
  exit
end

on update(me)
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
  exit
end

on renderFrame(me)
  pAnimImage.fill(pAnimImage.rect, rgb(255, 51, 255))
  repeat while me <= undefined
    tAnimInstance = getAt(undefined, undefined)
    tAnimInstance.updateAnim()
    tAnimInstance.render(pAnimImage)
  end repeat
  pMember.image = pAnimImage
  pREquiresUpdate = 1
  exit
end

on getImage(me)
  pREquiresUpdate = 0
  return(pAnimImage)
  exit
end