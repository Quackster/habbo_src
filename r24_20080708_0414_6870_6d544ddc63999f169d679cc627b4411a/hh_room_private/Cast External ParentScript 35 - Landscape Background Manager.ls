property pimage, pREquiresUpdate, pwidth, pheight, pBgID, pTurnPoint, pRoomType

on construct me
  pimage = image(1, 1, 32)
  pwidth = 720
  pheight = 400
  pTurnPoint = pwidth / 2
  pREquiresUpdate = 1
  return 1
end

on deconstruct me
  return 1
end

on define me, tdata
  pwidth = tdata[#width]
  pheight = tdata[#height]
  pBgID = tdata[#id]
  pRoomTypeID = tdata[#roomtypeid]
  if variableExists("landscape.def." & pRoomTypeID) then
    tRoomDef = getVariableValue("landscape.def." & pRoomTypeID)
    pTurnPoint = tRoomDef[#middle]
  end if
  pTurnPoint = pTurnPoint + tdata[#offset]
  pREquiresUpdate = 1
end

on requiresUpdate me
  return pREquiresUpdate
end

on getImage me
  if me.requiresUpdate() then
    pimage = image(pwidth, pheight, 32)
    pimage.fill(0, 0, pTurnPoint, pheight, color(110, 173, 200))
    pimage.fill(pTurnPoint, 0, pwidth, pheight, color(132, 206, 239))
    pREquiresUpdate = 0
  end if
  return pimage.duplicate()
end
