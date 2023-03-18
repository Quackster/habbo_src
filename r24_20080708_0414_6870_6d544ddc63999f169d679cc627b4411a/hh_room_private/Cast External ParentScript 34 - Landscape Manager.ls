property pLandscapeBgMngr, pLandscapeAnimMngr, pWallMaskMngr, pActive, pLandscapeMem, pwidth, pheight, pWideScreenOffset, pRemoveUpdate

on construct me
  pLandscapeBgMngr = createObject("landscape_background_manager", "Landscape Background Manager")
  pLandscapeAnimMngr = createObject("landscape_animation_manager", "Landscape Animation Manager")
  pWallMaskMngr = createObject("wall_mask_manager", "Wall Mask Manager")
  pActive = 0
  pWideScreenOffset = 0
  pRemoveUpdate = 0
  if threadExists(#room) then
    pWideScreenOffset = getThread(#room).getInterface().getProperty(#widescreenoffset)
  end if
  pwidth = the stageRight - the stageLeft
  pheight = integer(getVariable("landscape.height", 400))
  tMemberName = "room_landscape"
  if memberExists(tMemberName) then
    pLandscapeMem = getMember(tMemberName)
  else
    createMember(tMemberName, #bitmap)
    pLandscapeMem = getMember(tMemberName)
    pLandscapeMem.image = image(pwidth, pheight, 32)
  end if
  if threadExists(#room) then
    tRoomType = getThread(#room).getComponent().getRoomModel()
    me.setLandscape(1, tRoomType)
    me.setLandscapeAnimation(1, tRoomType)
  end if
  return 1
end

on deconstruct me
  if objectExists("landscape_background_manager") then
    removeObject("landscape_background_manager")
  end if
  if objectExists("landscape_animation_manager") then
    removeObject("landscape_animation_manager")
  end if
  if objectExists("wall_mask_manager") then
    removeObject("wall_mask_manager")
  end if
  tMemberName = "room_landscape"
  if memberExists(tMemberName) then
    removeMember(tMemberName)
  end if
  removeUpdate(me.getID())
  return 1
end

on insertWallMaskItem me, tID, tClassID, tloc, tdir, tSize
  pWallMaskMngr.insertWallMaskItem(tID, tClassID, tloc, tdir, tSize)
  if pWallMaskMngr.getItemCount() = 1 then
    me.setActivate(1)
  end if
end

on removeWallMaskItem me, tID
  pWallMaskMngr.removeWallMaskItem(tID)
  if pWallMaskMngr.getItemCount() = 0 then
    me.setActivate(0)
  end if
end

on setActivate me, tActive
  if tActive then
    receiveUpdate(me.getID())
    tViz = me.getRoomVisualizer()
    if objectp(tViz) then
      tSpr = tViz.getSprById("landscape")
      if ilk(tSpr) = #sprite then
        tSpr.member = pLandscapeMem
        tSpr.blend = 100
        tSpr.width = pwidth
        tSpr.height = pheight
        tSpr.locH = 0
        tSpr.locV = 0
        pLandscapeMem.regPoint = point(0, 0)
      end if
    end if
    pLandscapeAnimMngr.setStopped(0)
  else
    pRemoveUpdate = 1
    pLandscapeAnimMngr.setStopped(1)
  end if
end

on setLandscape me, tLandscapeID, tRoomType
  pUseDefaultLandscape = 0
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tRoomTypeID = tRoomType.item[2]
  the itemDelimiter = tDelim
  if tRoomTypeID = EMPTY then
    return 0
  end if
  tdata = [:]
  tdata[#width] = pwidth
  tdata[#height] = pheight
  tdata[#id] = tLandscapeID
  tdata[#roomtypeid] = tRoomTypeID
  tdata[#offset] = pWideScreenOffset
  pLandscapeBgMngr.define(tdata)
  me.updateLandscape()
end

on setLandscapeAnimation me, tAnimationID, tRoomType
  pUseDefaultLandscapeAnim = 0
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tRoomTypeID = tRoomType.item[2]
  the itemDelimiter = tDelim
  if tRoomTypeID = EMPTY then
    return 0
  end if
  tdata = [:]
  tdata[#width] = pwidth
  tdata[#height] = pheight
  tdata[#id] = tAnimationID
  tdata[#roomtypeid] = tRoomTypeID
  tdata[#offset] = pWideScreenOffset
  pLandscapeAnimMngr.define(tdata)
  me.updateLandscape()
end

on getRoomVisualizer me
  if threadExists(#room) then
    tInterface = getThread(#room).getInterface()
    tComponent = getThread(#room).getComponent()
    if tComponent.getRoomID() = "private" then
      tVisualizer = getThread(#room).getInterface().getRoomVisualizer()
      if objectp(tVisualizer) then
        return tVisualizer
      end if
    end if
  end if
  return 0
end

on updateLandscape me
  tBgImg = pLandscapeBgMngr.getImage()
  tAnimImg = pLandscapeAnimMngr.getImage()
  tMask = pWallMaskMngr.getMask()
  tLandscapeImg = image(pwidth, pheight, 32)
  tBgImg.copyPixels(tAnimImg, tAnimImg.rect, tAnimImg.rect, [#ink: 36, #bgColor: color(255, 51, 255)])
  tLandscapeImg.copyPixels(tBgImg, tBgImg.rect, tBgImg.rect, [#maskImage: tMask])
  tViz = me.getRoomVisualizer()
  if objectp(tViz) then
    tSpr = tViz.getSprById("landscape")
    if ilk(tSpr) = #sprite then
      tSpr.member.image.copyPixels(tLandscapeImg, tLandscapeImg.rect, tLandscapeImg.rect)
    end if
  end if
end

on update me
  if pLandscapeBgMngr.requiresUpdate() or pLandscapeAnimMngr.requiresUpdate() or pWallMaskMngr.requiresUpdate() then
    me.updateLandscape()
    if pRemoveUpdate and not pWallMaskMngr.requiresUpdate() then
      removeUpdate(me.getID())
      pRemoveUpdate = 0
    end if
  end if
end
