property pScifiDoorSpeed, pScifiDoorTimeOut, pDoubleClick

on construct me 
  me.pLastActive = -1
  pScifiDoorSpeed = 7
  pScifiDoorTimeOut = 0.4 * 60
  me.pScifiDoorLocs = [0, 0, 0]
  me.pScifiDoorTimer = 0
  pDoubleClick = 0
end

on prepareForMove me 
  me.pChanges = 1
  me.update()
end

on prepare me, tdata 
  if tdata.getAt("STATUS") = "O" then
    me.setOn()
  else
    me.setOff()
  end if
  me.pScifiDoorTimer = the timer
  me.pChanges = 1
  return(1)
end

on updateStuffdata me, tProp, tValue 
  if tValue = "O" then
    me.setOn()
  else
    me.setOff()
  end if
  me.pScifiDoorTimer = the timer
  me.pChanges = 1
  pDoubleClick = 0
end

on update me 
  if not me.pChanges then
    return(0)
  end if
  if me.count(#pSprList) < 4 then
    return(0)
  end if
  return(me.updateScifiDoor())
end

on updateScifiDoor me 
  tTopSp = me.getProp(#pSprList, 4)
  tMidSp1 = me.getProp(#pSprList, 2)
  tMidSp2 = me.getProp(#pSprList, 3)
  if me.pLastActive = 0 and me.pActive = 0 then
    me.pScifiDoorLocs = [tTopSp.locV, tMidSp1.locV, tMidSp2.locV]
  end if
  if me.pActive = 0 and me.pLastActive = -1 then
    me.pScifiDoorLocs = [tTopSp.locV, tMidSp1.locV, tMidSp2.locV]
    me.pLastActive = 0
    me.pChanges = 0
    return(1)
  end if
  if me.pLastActive = 1 and me.pActive = 1 or me.pLastActive = -1 then
    me.pScifiDoorLocs = [tTopSp.locV, tMidSp1.locV, tMidSp2.locV]
    return(me.SetScifiDoor("down"))
  end if
  tDoorTimer = the timer - me.pScifiDoorTimer
  if me.pActive then
    tTopSp.locV = tTopSp.locV + pScifiDoorSpeed
    me.moveTopLine(tMidSp1, -pScifiDoorSpeed)
    me.moveTopLine(tMidSp2, -pScifiDoorSpeed)
    if tMidSp1.height <= 11 or tDoorTimer > pScifiDoorTimeOut then
      me.SetScifiDoor("down")
    end if
  else
    if tDoorTimer > pScifiDoorTimeOut then
      return(me.SetScifiDoor("up"))
    end if
    tTopSp.locV = tTopSp.locV - pScifiDoorSpeed
    me.moveTopLine(tMidSp1, pScifiDoorSpeed)
    me.moveTopLine(tMidSp2, pScifiDoorSpeed)
    if tMidSp1.height > 65 then
      me.SetScifiDoor("up")
    end if
  end if
  return(1)
end

on SetScifiDoor me, tdir 
  tTopSp = me.getProp(#pSprList, 4)
  tMidSp1 = me.getProp(#pSprList, 2)
  tMidSp2 = me.getProp(#pSprList, 3)
  if tdir = "up" then
    tTopSp.locV = me.getProp(#pScifiDoorLocs, 1)
    tMidSp1.height = 65
    tMidSp2.height = 64
    tMidSp1.locV = me.getProp(#pScifiDoorLocs, 2)
    tMidSp2.locV = me.getProp(#pScifiDoorLocs, 3)
  else
    tTopSp.locV = me.getProp(#pScifiDoorLocs, 1) + 57
    tMidSp1.height = 8
    tMidSp2.height = 7
    tMidSp1.locV = me.getProp(#pScifiDoorLocs, 2) - 2
    tMidSp2.locV = me.getProp(#pScifiDoorLocs, 3) + 5
  end if
  me.pChanges = 0
  me.pLastActive = me.pActive
  return(1)
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
  return()
end

on setOn me 
  me.pActive = 1
end

on setOff me 
  me.pActive = 0
end

on select me 
  if the doubleClick then
    if me.pChanges then
      return(0)
    end if
    pDoubleClick = 1
    if me.pActive then
      tStr = "C"
    else
      tStr = "O"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "STATUS" & "/" & tStr)
  else
    if not pDoubleClick and not me.pChanges then
      getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:me.pLocY])
    end if
  end if
  return(1)
end
