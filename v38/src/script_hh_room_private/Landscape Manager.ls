property pLandscapeMem, pwidth, pheight, pWallMaskMngr, pHasAnimation, pLandscapeAnimMngr, pWideScreenOffset, pLandscapeBgMngr, pRemoveUpdate, pWallStruct, pTurnPointList

on construct me 
  pLandscapeBgMngr = createObject("landscape_background_manager", "Landscape Background Manager")
  pLandscapeAnimMngr = createObject("landscape_animation_manager", "Landscape Animation Manager")
  pWallMaskMngr = createObject("wall_mask_manager", "Wall Mask Manager")
  pWideScreenOffset = 0
  pRemoveUpdate = 0
  if threadExists(#room) then
    pWideScreenOffset = getThread(#room).getInterface().getProperty(#widescreenoffset)
  end if
  pwidth = (the stageRight - the stageLeft)
  pheight = integer(getVariable("landscape.height", 400))
  tMemberName = "room_landscape"
  if memberExists(tMemberName) then
    pLandscapeMem = getMember(tMemberName)
  else
    createMember(tMemberName, #bitmap)
    pLandscapeMem = getMember(tMemberName)
    pLandscapeMem.image = image(pwidth, pheight, 32)
  end if
  return TRUE
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
  pWallStruct = void()
  return TRUE
end

on insertWallMaskItem me, tID, tClassID, tloc, tdir, tSize 
  if (tloc.locV = -1000) then
    return FALSE
  end if
  pWallMaskMngr.insertWallMaskItem(tID, tClassID, tloc, tdir, tSize)
  if (pWallMaskMngr.getItemCount() = 1) then
    me.setActivate(1)
  end if
  me.update()
end

on removeWallMaskItem me, tID 
  pWallMaskMngr.removeWallMaskItem(tID)
  if (pWallMaskMngr.getItemCount() = 0) then
    me.setActivate(0)
  end if
  me.update()
end

on setActivate me, tActive 
  if tActive then
    tViz = me.getRoomVisualizer()
    if objectp(tViz) then
      tSpr = tViz.getSprById("landscape")
      if (ilk(tSpr) = #sprite) then
        tSpr.member = pLandscapeMem
        tSpr.blend = 100
        tSpr.width = pwidth
        tSpr.height = pheight
        tSpr.locH = 0
        tSpr.locV = 0
        pLandscapeMem.regPoint = point(0, 0)
      end if
    end if
    if pHasAnimation then
      pLandscapeAnimMngr.start()
    end if
  else
    pLandscapeAnimMngr.stop()
  end if
end

on setLandscape me, tLandscapeType, tRoomType 
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tRoomTypeID = tRoomType.getProp(#item, 2)
  the itemDelimiter = tDelim
  if (tRoomTypeID = "") then
    return FALSE
  end if
  tLimiter = the itemDelimiter
  the itemDelimiter = "."
  tdata = [:]
  tdata.setAt(#width, pwidth)
  tdata.setAt(#height, pheight)
  tdata.setAt(#gradient, tLandscapeType.getProp(#item, 1))
  tdata.setAt(#type, tLandscapeType.getProp(#item, 2))
  tdata.setAt(#roomtypeid, tRoomTypeID)
  tdata.setAt(#offset, pWideScreenOffset)
  the itemDelimiter = tLimiter
  tRoomWallStruct = me.getRoomWallStruct(tRoomType)
  tFactorX = tRoomWallStruct.getaProp(#factorx)
  tLandscapeProps = me.getLandscapeProps(tdata.getAt(#type), tFactorX)
  pLandscapeBgMngr.define(tdata, tRoomWallStruct, tLandscapeProps)
  if tLandscapeProps <> 0 then
    tCloudFlag = tLandscapeProps.getaProp(#clouds)
    if voidp(tCloudFlag) or (tCloudFlag = 1) then
      pHasAnimation = 1
      me.setLandscapeAnimation(1, tRoomType, tdata.getAt(#type))
    else
      pHasAnimation = 0
      me.setLandscapeAnimation(0)
    end if
  end if
  me.updateLandscape()
  receiveUpdate(me.getID())
end

on setLandscapeAnimation me, tAnimationID, tRoomType, tLandscapeType 
  if (pLandscapeAnimMngr = 0) then
    return(error(me, "Landscape animation manager not available!", #setLandscapeAnimation, #major))
  end if
  if (tAnimationID = 0) then
    pLandscapeAnimMngr.stop()
    return()
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tRoomTypeID = tRoomType.getProp(#item, 2)
  the itemDelimiter = tDelim
  if (tRoomTypeID = "") then
    return FALSE
  end if
  tStruct = me.getRoomWallStruct(tRoomType)
  if (tStruct = void()) then
    return FALSE
  end if
  tdata = [:]
  tdata.setAt(#width, pwidth)
  tdata.setAt(#height, pheight)
  tdata.setAt(#wallheight, tStruct.getaProp(#height))
  tdata.setAt(#id, tAnimationID)
  tdata.setAt(#roomtypeid, tRoomTypeID)
  tdata.setAt(#offset, pWideScreenOffset)
  tdata.setAt(#landscape, tLandscapeType)
  pLandscapeAnimMngr.define(tdata, me.getRoomTurnPointList(tRoomType))
  if pWallMaskMngr.getItemCount() > 0 then
    me.setActivate(1)
  end if
  me.updateLandscape()
end

on getRoomVisualizer me 
  if threadExists(#room) then
    tInterface = getThread(#room).getInterface()
    tComponent = getThread(#room).getComponent()
    if (tComponent.getRoomID() = "private") then
      tVisualizer = getThread(#room).getInterface().getRoomVisualizer()
      if objectp(tVisualizer) then
        return(tVisualizer)
      end if
    end if
  end if
  return FALSE
end

on updateLandscape me 
  tBgImg = pLandscapeBgMngr.getImage()
  if (tBgImg = 0) then
    return FALSE
  end if
  tMask = pWallMaskMngr.getMask()
  tLandscapeImg = pLandscapeMem.image
  tLandscapeImg.fill(0, 0, pwidth, pheight, color(255, 255, 255))
  tLandscapeImg.copyPixels(tBgImg, tBgImg.rect, tBgImg.rect, [#maskImage:tMask])
  tViz = me.getRoomVisualizer()
  if objectp(tViz) then
    tSpr = tViz.getSprById("landscape")
    if (tSpr.ilk = #sprite) then
      pLandscapeAnimMngr.resetSprite(tSpr, tMask)
    end if
  end if
end

on update me 
  if pLandscapeBgMngr.requiresUpdate() or pWallMaskMngr.requiresUpdate() then
    me.updateLandscape()
    if pRemoveUpdate and not pWallMaskMngr.requiresUpdate() and not pLandscapeBgMngr.requiresUpdate() then
      removeUpdate(me.getID())
      pRemoveUpdate = 0
    else
      pRemoveUpdate = 1
    end if
  end if
end

on getRoomWallStruct me, tRoomType 
  if (pWallStruct = void()) then
    me.parseRoomLayout(tRoomType)
  end if
  return(pWallStruct)
end

on getRoomTurnPointList me, tRoomType 
  if (pTurnPointList = void()) then
    me.parseRoomLayout(tRoomType)
  end if
  return(pTurnPointList)
end

on parseRoomLayout me, tRoomType 
  tRoomField = tRoomType & ".room"
  tParser = getObject(#layout_parser)
  if (tParser = 0) then
    return FALSE
  end if
  tFieldData = tParser.parse(tRoomField)
  if (tFieldData = 0) then
    return FALSE
  end if
  tRoomData = tFieldData.getaProp(#roomdata).getAt(1)
  tElements = tFieldData.getaProp(#elements)
  if (tElements = 0) then
    return FALSE
  end if
  pWallStruct = [:]
  tWallPieceStruct = []
  pTurnPointList = [:]
  tLeft = 0
  tRight = 0
  tWallHeight = 0
  tMaxPieceHeight = 0
  tOffsetX = tRoomData.getaProp(#offsetx)
  tOffsetY = tRoomData.getaProp(#offsety)
  tFactorX = tRoomData.getaProp(#factorx)
  repeat while tElements <= undefined
    tElement = getAt(undefined, tRoomType)
    tWrapperId = tElement.getaProp(#wrapperID)
    tmember = tElement.getaProp(#member)
    if tmember contains "wallpart" or tmember contains "wallmask" or tmember contains "stairs" then
      tItem = [:]
      tMemName = tElement.getaProp(#member)
      tLocH = tElement.getaProp(#locH)
      tHeight = tElement.getaProp(#height)
      tWidth = tElement.getaProp(#width)
      tItem.setaProp(#member, tMemName)
      tItem.setaProp(#locH, tLocH)
      tItem.setaProp(#locV, tElement.getaProp(#locV))
      tItem.setaProp(#width, tWidth)
      tItem.setaProp(#height, tHeight)
      tItem.setaProp(#locX, tElement.getaProp(#locX))
      tItem.setaProp(#locY, tElement.getaProp(#locY))
      if voidp(tLeft) or tLeft > tLocH then
        tLeft = tLocH
      end if
      if voidp(tRight) or tRight < (tLocH + tWidth) then
        tRight = (tLocH + tWidth)
      end if
      if tHeight > tMaxPieceHeight then
        tMaxPieceHeight = tHeight
      end if
      tWallPieceStruct.append(tItem)
      tHeight = (tHeight - (tWidth / 2))
      if tHeight > tWallHeight then
        tWallHeight = tHeight
      end if
    end if
  end repeat
  tSideLeftH = void()
  tItem = tWallPieceStruct.getAt(1)
  tWallDefIndex = 1
  tside = #left
  tSideRight = void()
  repeat while tItem <> 0
    if tWallDefIndex > tWallPieceStruct.count then
    else
      tItem = tWallPieceStruct.getAt(tWallDefIndex)
      tMemName = tItem.getaProp(#member)
      tmember = member(getmemnum(tMemName))
      if tMemName contains "right" then
        tPieceSide = #right
      else
        tPieceSide = #left
      end if
      if (tPieceSide = tside) then
        tLocH = (tItem.getaProp(#locH) - tmember.regPoint.locH)
        tLocV = (tItem.getaProp(#locV) - tmember.regPoint.locV)
        if voidp(tSideLeftH) or not voidp(tSideLeftH) and tLocH < tSideLeftH then
          tSideLeftH = tLocH
          tSideLeftV = tLocV
          tSideLeftElemWidth = tItem.getaProp(#width)
        end if
        tWallDefIndex = (tWallDefIndex + 1)
      end if
      if tPieceSide <> tside or tWallDefIndex > tWallPieceStruct.count then
        if (tside = #right) then
          tSideLeftV = (tSideLeftV + 1)
        else
          tSideLeftV = (tSideLeftV + (tSideLeftElemWidth / 2))
        end if
        pTurnPointList.setaProp(point((tSideLeftH + pWideScreenOffset), tSideLeftV), tside)
        tSideLeftH = void()
        tside = tPieceSide
      end if
    end if
  end repeat
  pWallStruct.setaProp(#struct, tWallPieceStruct)
  pWallStruct.setaProp(#factorx, tRoomData.getaProp(#factorx))
  pWallStruct.setaProp(#height, tWallHeight)
  pWallStruct.setaProp(#max_piece_height, tMaxPieceHeight)
  return TRUE
end

on getLandscapeProps me, tLandscapeID, tFactorX 
  tMemName = "lsd_" & tLandscapeID & ".props"
  if (tFactorX = 32) then
    tMemName = "s_" & tMemName
  end if
  if not memberExists(tMemName) then
    return([:])
  end if
  tPropList = value(field(0))
  return(tPropList)
end

on getWallMaskCount me 
  if objectp(pWallMaskMngr) then
    return(pWallMaskMngr.getItemCount())
  end if
end
