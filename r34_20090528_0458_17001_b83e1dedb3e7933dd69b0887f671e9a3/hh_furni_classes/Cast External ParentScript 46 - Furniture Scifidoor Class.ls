property pChanges, pActive, pLastActive, pScifiDoorSpeed, pScifiDoorLocs, pScifiDoorTimer, pScifiDoorTimeOut, pDoubleClick, pSizeMultiplier, pStopped

on construct me
  pLastActive = -1
  pScifiDoorSpeed = 7
  pScifiDoorTimeOut = 0.40000000000000002 * 60
  pScifiDoorLocs = [0, 0, 0]
  pScifiDoorTimer = 0
  pDoubleClick = 0
  pStopped = 1
  if me.pXFactor = 32 then
    pSizeMultiplier = 0.5
  else
    pSizeMultiplier = 1.0
  end if
end

on prepareForMove me
  pChanges = 1
  me.update()
end

on prepare me, tdata
  tValue = integer(tdata[#stuffdata])
  if tValue = 0 then
    me.setOff()
  else
    me.setOn()
  end if
  pScifiDoorTimer = the timer
  pChanges = 1
  return 1
end

on updateStuffdata me, tValue
  tValue = integer(tValue)
  if tValue = 0 then
    me.setOff()
  else
    me.setOn()
  end if
  pScifiDoorTimer = the timer
  pStopped = 0
  pChanges = 1
  pDoubleClick = 0
end

on update me
  if not pChanges then
    return 0
  end if
  if me.pSprList.count < 4 then
    return 0
  end if
  return me.updateScifiDoor()
end

on updateScifiDoor me
  if me.pSprList.count < 4 then
    return 0
  end if
  tTopSp = me.pSprList[4]
  tMidSp1 = me.pSprList[2]
  tMidSp2 = me.pSprList[3]
  if (pLastActive = 0) and (pActive = 0) then
    pScifiDoorLocs = [tTopSp.locV, tMidSp1.locV, tMidSp2.locV]
  end if
  if pStopped and (pActive = 0) and (pLastActive = -1) then
    pScifiDoorLocs = [tTopSp.locV, tMidSp1.locV, tMidSp2.locV]
    pLastActive = 0
    pChanges = 0
    return 1
  end if
  if pStopped and (((pLastActive = 1) and (pActive = 1)) or (pLastActive = -1)) then
    pScifiDoorLocs = [tTopSp.locV, tMidSp1.locV, tMidSp2.locV]
    return me.SetScifiDoor("down")
  end if
  tDoorTimer = the timer - me.pScifiDoorTimer
  if pActive then
    tTopSp.locV = tTopSp.locV + pScifiDoorSpeed
    me.moveTopLine(tMidSp1, -pScifiDoorSpeed)
    me.moveTopLine(tMidSp2, -pScifiDoorSpeed)
    if (tMidSp1.height <= (11 * pSizeMultiplier)) or (tDoorTimer > pScifiDoorTimeOut) then
      me.SetScifiDoor("down")
    end if
  else
    if tDoorTimer > pScifiDoorTimeOut then
      return me.SetScifiDoor("up")
    end if
    if pSizeMultiplier = 1.0 then
      tTopSp.locV = tTopSp.locV - pScifiDoorSpeed
    else
      tTopSp.locV = tTopSp.locV - pScifiDoorSpeed
    end if
    me.moveTopLine(tMidSp1, pScifiDoorSpeed)
    me.moveTopLine(tMidSp2, pScifiDoorSpeed)
    if tMidSp1.height > (65 * pSizeMultiplier) then
      me.SetScifiDoor("up")
    end if
  end if
  return 1
end

on SetScifiDoor me, tdir
  if me.pSprList.count < 4 then
    return 0
  end if
  tTopSp = me.pSprList[4]
  tMidSp1 = me.pSprList[2]
  tMidSp2 = me.pSprList[3]
  if tdir = "up" then
    tTopSp.locV = pScifiDoorLocs[1]
    tMidSp1.height = 65 * pSizeMultiplier
    tMidSp2.height = 64 * pSizeMultiplier
    tMidSp1.locV = pScifiDoorLocs[2]
    tMidSp2.locV = pScifiDoorLocs[3]
  else
    if pSizeMultiplier = 1.0 then
      tTopSp.locV = pScifiDoorLocs[1] + 57
      tMidSp1.height = 8
      tMidSp2.height = 7
    else
      tTopSp.locV = pScifiDoorLocs[1] + 27
      tMidSp1.height = 2
      tMidSp2.height = 2
    end if
    tMidSp1.height = 8 * pSizeMultiplier
    tMidSp2.height = 7 * pSizeMultiplier
    tMidSp1.locV = pScifiDoorLocs[2] - (2 * pSizeMultiplier)
    tMidSp2.locV = pScifiDoorLocs[3] + (5 * pSizeMultiplier)
  end if
  pChanges = 0
  pLastActive = pActive
  pStopped = 1
  return 1
end

on moveTopLine me, tSpr, tAmount
  tBot = tSpr.bottom
  tSpr.height = tSpr.height + tAmount
  if tBot > tSpr.bottom then
    tSpr.locV = tSpr.locV + 1
  end if
  if tBot < tSpr.bottom then
    tSpr.locV = tSpr.locV - 1
  end if
  return 1
end

on setOn me
  pActive = 1
end

on setOff me
  pActive = 0
end

on select me
  if the doubleClick then
    if pChanges then
      return 0
    end if
    pDoubleClick = 1
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer: integer(me.getID()), #integer: 0])
  else
    if not pDoubleClick and not pChanges then
      getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer: me.pLocX, #integer: me.pLocY])
    end if
  end if
  return 1
end
