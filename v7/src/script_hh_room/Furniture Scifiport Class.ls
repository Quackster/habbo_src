on prepare(me, tdata)
  if tdata.getAt("STATUS") = "O" then
    me.setOn()
    me.pChanges = 1
  else
    me.setOff()
    me.pChanges = 0
  end if
  return(1)
  exit
end

on updateStuffdata(me, tProp, tValue)
  if tValue = "O" then
    me.setOn()
  else
    me.setOff()
  end if
  me.pChanges = 1
  exit
end

on update(me)
  if not me.pChanges then
    return()
  end if
  if me.count(#pSprList) < 4 then
    return()
  end if
  return(me.updateScifiPort())
  exit
end

on updateScifiPort(me)
  if me.count(#pSprList) < 4 then
    return(0)
  end if
  tGateSp1 = me.getProp(#pSprList, 3)
  tGateSp2 = me.getProp(#pSprList, 4)
  if me.pActive then
    tGateSp1.visible = 0
    tGateSp2.visible = 0
  else
    tGateSp1.visible = 1
    tGateSp2.visible = 1
  end if
  me.pChanges = 0
  return(1)
  exit
end

on setOn(me)
  me.pActive = 1
  exit
end

on setOff(me)
  me.pActive = 0
  exit
end

on select(me)
  if the doubleClick then
    if me.pActive then
      tStr = "C"
    else
      tStr = "O"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "STATUS" & "/" & tStr)
  end if
  return(1)
  exit
end